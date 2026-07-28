# PROMPT PROJECT — STAYZ

> Tài liệu nền để AI/developer hiểu đúng hệ thống trước khi phân tích, sửa hoặc mở rộng dự án. Nội dung được đối chiếu trực tiếp với mã nguồn hiện tại.

## 1. Vai trò và nguyên tắc làm việc

Bạn là kỹ sư phần mềm phụ trách **StayZ**, ứng dụng đặt phòng khách sạn gồm:

- Mobile client: Flutter/Dart.
- REST API: Node.js + Express.
- Database: MongoDB/Mongoose.
- Cache và distributed lock: Redis + Redlock.
- Thanh toán: PayOS.
- Ảnh: Cloudinary/local static files.
- Xác thực: JWT, secure storage và Google OAuth/deep link.

Khi thực hiện yêu cầu:

1. Đọc code liên quan trước khi đề xuất thay đổi; không suy đoán endpoint, model hoặc trạng thái.
2. Không gọi API trực tiếp từ màn hình mới. Đi qua service/repository hiện hữu.
3. Frontend chỉ hiển thị và điều phối UX; backend là nguồn sự thật cho giá, tồn phòng, quyền và chuyển trạng thái.
4. Luôn kiểm tra `mounted` sau `await` trước khi dùng `BuildContext` hoặc `setState`.
5. Mọi thao tác ghi phải có loading guard để tránh double submit.
6. Giữ tương thích tiếng Việt/Anh, light/dark theme, responsive và accessibility.
7. Không xác nhận thanh toán từ client. Chỉ webhook PayOS đã xác thực được phép xác nhận booking.
8. Không cho client tự tạo booking ở trạng thái `completed`/`cancelled` hoặc tự chuyển sang `confirmed`.
9. Khi thay đổi property/room phải xét cache invalidation; khi đặt phòng phải xét race condition và tồn phòng theo khoảng ngày.
10. Trước khi kết luận hoàn tất, liệt kê file đã tác động và các luồng nghiệp vụ bị ảnh hưởng.

## 2. Bản đồ kiến trúc thực tế

### Flutter

```text
lib/main.dart
  └─ load locale + theme
     └─ StayZApp / MaterialApp
        └─ AppRoutes (named routes)
           └─ feature/presentation/pages
              ├─ widgets
              ├─ ApiStayzRepository / AdminRepository
              ├─ AuthService / ApiService / StorageService
              └─ shared models, data, notifications
```

- `lib/main.dart`: khởi tạo binding, nạp locale và theme song song rồi `runApp`.
- `lib/app/app.dart`: `MaterialApp`, theme sáng/tối/high contrast, localization và route fallback.
- `lib/app/routes/app_routes.dart`: registry named-route; `initialRoute` là `/auth-gate`.
- `lib/features/*/presentation`: UI được chia theo feature.
- `lib/shared/repositories/stayz_repository.dart`: cổng dữ liệu chính của app.
- `lib/services/api_service.dart`: HTTP, Bearer token, UTF-8 JSON, timeout 20 giây, chuẩn hóa lỗi và unwrap `metaData`.
- `lib/services/auth_service.dart`: session, onboarding, login/register/reset password/Google callback.
- `lib/shared/models`: DTO/domain model dùng xuyên các màn hình.
- State hiện tại chủ yếu là state cục bộ bằng `StatefulWidget`, `FutureBuilder`, singleton `ChangeNotifier`/controller; chưa dùng BLoC/Riverpod/Provider.

### Backend

```text
HTTP request
  └─ server.js
     └─ /api → rootRouter
        └─ feature router
           └─ protect/admin/rate-limit/upload middleware
              └─ controller
                 └─ service (business rules)
                    └─ Mongoose model / Redis / PayOS / Cloudinary
```

- Route chỉ ánh xạ endpoint và middleware.
- Controller nhận request, gọi service, trả response.
- Service chứa nghiệp vụ, phân quyền, kiểm tra trạng thái và side effect.
- Model định nghĩa persistence.
- `protect.middleware.js` xác thực; `admin.middleware.js` bảo vệ nghiệp vụ quản trị.
- `response.helper.js` tạo envelope; Flutter `ApiService` lấy `metaData`.

## 3. Kết luận mô hình: MVC, MVVM hay kiến trúc nào?

1. **Kết luận ngắn:** project hiện tại **không phải MVVM thuần**. Kiến trúc đúng nhất để mô tả là:

   ```text
   Flutter: Feature-first + Presentation/Repository/Service
   Backend: Layered MVC (Route → Controller → Service → Model)
   Toàn hệ thống: Client–Server layered architecture
   ```

2. **Backend gần MVC nhất**, nhưng có thêm Service Layer:

   1. **Model:** Mongoose schema và dữ liệu trong `backend/stayz_api/src/models/`.
   2. **View:** JSON response gửi cho Flutter; backend không render HTML.
   3. **Controller:** nhận `req`, đọc params/body/user, gọi service và trả response.
   4. **Service:** chứa business logic thực tế như tính giá, kiểm tra quyền, tồn phòng và chuyển trạng thái.
   5. **Router:** định nghĩa URL và middleware trước controller.

3. Chuỗi backend thực tế:

   ```text
   Router
     → Authentication/Authorization middleware
     → Controller
     → Service
     → Mongoose Model / Redis / PayOS
     → Controller
     → JSON response
   ```

4. Ví dụ booking:

   1. Route: `backend/stayz_api/src/routes/booking.router.js:15`
   2. Controller: `backend/stayz_api/src/controllers/booking.controller.js:46`
   3. Service: `backend/stayz_api/src/services/booking.service.js:227`
   4. Model: `backend/stayz_api/src/models/bookings.model.js`

5. **Flutter không có ViewModel riêng**, nên chưa phải MVVM:

   1. **View:** các `Page` và `Widget` trong `lib/features/*/presentation/`.
   2. **State/điều phối:** thường nằm ngay trong `State<Page>`.
   3. **Data access:** `ApiStayzRepository`, `AdminRepository`, `AuthService`.
   4. **Models:** `lib/shared/models/`.
   5. Không có lớp `*ViewModel`, `ChangeNotifier` theo từng màn hình, Riverpod notifier hoặc BLoC đứng giữa View và Repository.

6. Ví dụ `SearchPage` đang gộp View và phần việc thường thuộc ViewModel:

   ```dart
   void _onSearchChanged(String value) {
     _debounce?.cancel();
     _filters = _filters.copyWith(keyword: value.trim());
     setState(() => _suggestions = _buildSuggestions(value));
     _debounce = Timer(const Duration(seconds: 1), () {
       if (!mounted) return;
       _applyFilters(
         _filters.copyWith(keyword: _searchController.text.trim()),
         syncTextField: false,
       );
     });
   }
   ```

   Kiểm tra tại: `lib/features/search/presentation/pages/search_page.dart:122`.

7. Nếu gọi đúng theo từng phía:

   1. **Flutter:** feature-first layered architecture, stateful presentation.
   2. **Backend:** service-oriented MVC/layered MVC.
   3. **Không nên ghi:** “toàn project dùng MVVM”.
   4. **Có thể phát triển thành MVVM:** tách debounce, filters, loading, error và commands ra `SearchViewModel`; View chỉ bind state và phát event.

## 4. Danh sách endpoint hiện có

> Base URL production trong app: `https://stayz-api.onrender.com/api`. Có thể thay bằng `--dart-define=STAYZ_API_BASE_URL=...`. Router gốc được kiểm tra tại `backend/stayz_api/src/routes/rootRouter.router.js:17`.
>
> Tài liệu request/body/code xử lý cho từng endpoint: [`docs/stayz-api-cookbook.md`](docs/stayz-api-cookbook.md).

1. **System**

   1. `GET /health` — kiểm tra MongoDB/Redis và trạng thái server.
   2. Code: `backend/stayz_api/server.js:67`.
   3. Lưu ý: health nằm ở root server, không nằm dưới `/api`.

2. **Users và xác thực**

   1. `GET /api/users/admin/audit` — nhật ký admin; JWT + admin.
   2. `GET /api/users/getAll` — danh sách user; JWT + admin.
   3. `GET /api/users/getById/:id` — chi tiết user; JWT.
   4. `DELETE /api/users/delete/:id` — xóa user; JWT + admin.
   5. `PATCH /api/users/update/:id` — cập nhật user; JWT + admin audit.
   6. `POST /api/users/create` — đăng ký; giới hạn 5 lần/15 phút.
   7. `POST /api/users/admin/create` — admin tạo user.
   8. `POST /api/users/login` — đăng nhập; giới hạn 5 lần/60 giây.
   9. `POST /api/users/refresh-token` — làm mới access token.
   10. `POST /api/users/logout` — đăng xuất/thu hồi refresh token.
   11. `POST /api/users/request-register-otp` — gửi OTP đăng ký.
   12. `POST /api/users/verify-register-otp` — xác minh OTP đăng ký.
   13. `POST /api/users/request-password-reset` — yêu cầu reset password.
   14. `POST /api/users/verify-reset-code` — xác minh mã reset.
   15. `POST /api/users/reset-password` — đặt mật khẩu mới.
   16. `PATCH /api/users/avatar/local` — upload avatar local; JWT.
   17. `PATCH /api/users/avatar/cloud` — upload avatar Cloudinary; JWT.
   18. `PATCH /api/users/avatar/cloud/:id` — admin upload avatar cho user.
   19. `GET /api/auth/google` — bắt đầu Google OAuth.
   20. `GET /api/auth/google/callback` — Google callback.
   21. Code router: `backend/stayz_api/src/routes/users.router.js` và `backend/stayz_api/src/routes/auth.router.js`.

3. **Properties và tìm kiếm khách sạn**

   1. `GET /api/properties/search` — tìm kiếm/lọc khách sạn.
   2. `GET /api/properties/search/history` — lịch sử tìm kiếm; JWT.
   3. `DELETE /api/properties/search/history` — xóa lịch sử; JWT.
   4. `GET /api/properties/featured` — khách sạn nổi bật.
   5. `GET /api/properties/getAll` — danh sách khách sạn public.
   6. `GET /api/properties/admin/getAll` — danh sách gồm inactive; admin.
   7. `GET /api/properties/:city` — khách sạn theo thành phố.
   8. `GET /api/properties/:city/:slug` — chi tiết theo city + slug.
   9. `POST /api/properties/create` — tạo property; admin.
   10. `PUT /api/properties/update/:id` — sửa property; admin.
   11. `DELETE /api/properties/delete/:id` — xóa property; admin.
   12. `PATCH /api/properties/upload/local/:id` — ảnh chính local; admin.
   13. `PATCH /api/properties/upload/cloud/:id` — ảnh chính Cloudinary; admin.
   14. `PATCH /api/properties/upload/gallery/cloud/:id` — tối đa 10 ảnh gallery; admin.
   15. Code router: `backend/stayz_api/src/routes/properties.router.js`.

4. **Rooms**

   1. `GET /api/room/getAll` — danh sách room public.
   2. `GET /api/room/admin/getAll` — toàn bộ room; admin.
   3. `GET /api/room/:propertyId` — phòng của khách sạn, nhận filter ngày/khách.
   4. `POST /api/room/create` — tạo phòng; admin.
   5. `PUT /api/room/update/:id` — sửa phòng; admin.
   6. `DELETE /api/room/delete/:id` — xóa phòng; admin.
   7. `PATCH /api/room/upload/cloud/:id` — ảnh chính; admin.
   8. `PATCH /api/room/upload/gallery/cloud/:id` — gallery; admin.
   9. Code router: `backend/stayz_api/src/routes/room.router.js`.

5. **Bookings**

   1. Tất cả endpoint nhóm này đi qua `protect` và `adminAudit`.
   2. `GET /api/booking/getAll` — danh sách booking; service kiểm tra quyền.
   3. `GET /api/booking/user/:userId` — booking của user; ownership/admin.
   4. `GET /api/booking/:bookingId/cancellation-quote` — dự tính hoàn tiền.
   5. `POST /api/booking/create` — tạo booking pending.
   6. `PUT /api/booking/update/:bookingId` — cập nhật booking theo điều kiện.
   7. `DELETE /api/booking/delete/:bookingId` — xóa nếu chưa có ràng buộc payment/review.
   8. `PATCH /api/booking/:bookingId/status` — chuyển trạng thái.
   9. `PATCH /api/booking/:bookingId/attendance` — check-in/no-show; admin.
   10. `GET /api/booking/admin/check-in/:code` — tra check-in code; admin.
   11. Code router: `backend/stayz_api/src/routes/booking.router.js`.

6. **Payments**

   1. `POST /api/payment/webhook` — PayOS webhook public; xác minh bởi PayOS SDK.
   2. `GET /api/payment/return` — URL PayOS redirect khi thành công.
   3. `GET /api/payment/cancel` — URL PayOS redirect khi hủy.
   4. `POST /api/payment/create/:bookingId` — tạo/reuse payment link; JWT.
   5. `GET /api/payment/getAll` — danh sách payment; admin.
   6. `POST /api/payment/admin/:paymentId/cancel` — admin hủy payment.
   7. `GET /api/payment/booking/:bookingId` — trạng thái payment của booking.
   8. `POST /api/payment/cancel/:bookingId` — user hủy link pending.
   9. Code router: `backend/stayz_api/src/routes/payment.router.js`.

7. **Reviews**

   1. `GET /api/review/getAll?propertyId=...` — danh sách review public.
   2. `POST /api/review/create` — tạo review; JWT.
   3. `PUT /api/review/update/:id` — sửa review; JWT + ownership.
   4. `DELETE /api/review/delete/:id` — xóa review; JWT + audit.
   5. Code router: `backend/stayz_api/src/routes/review.router.js`.

8. **Favorites**

   1. Toàn bộ endpoint yêu cầu JWT.
   2. `GET /api/favorites` — favorites của user hiện tại.
   3. `GET /api/favorites/check/:propertyId` — kiểm tra đã favorite.
   4. `POST /api/favorites/:propertyId` — thêm favorite.
   5. `DELETE /api/favorites/:propertyId` — bỏ favorite.
   6. Code router: `backend/stayz_api/src/routes/favorites.router.js`.

9. **Notifications**

   1. Toàn bộ endpoint yêu cầu JWT.
   2. `GET /api/notifications` — notification của user.
   3. `PATCH /api/notifications/read-all` — đánh dấu tất cả đã đọc.
   4. `PATCH /api/notifications/:id/read` — đọc một notification.
   5. `DELETE /api/notifications/:id` — xóa notification.
   6. Code router: `backend/stayz_api/src/routes/notifications.router.js`.

10. **Chat và AI**

   1. `POST /api/chat/conversations` — lấy hoặc tạo conversation.
   2. `GET /api/chat/conversations` — conversation của user.
   3. `GET /api/chat/conversations/:conversationId/messages` — lịch sử message.
   4. `POST /api/chat/conversations/:conversationId/messages` — gửi message.
   5. `PATCH /api/chat/conversations/:conversationId/read` — đánh dấu đã đọc.
   6. `POST /api/ai/chat` — gửi yêu cầu AI; JWT.
   7. Code router: `backend/stayz_api/src/routes/chat.router.js` và `backend/stayz_api/src/routes/ai.router.js`.

## 5. Luồng xử lý code có ví dụ và đường dẫn

1. **Luồng tìm kiếm khách sạn**

   1. Người dùng nhập tại `SearchPage`.
   2. `_onSearchChanged` hủy timer cũ và debounce 1 giây.
   3. `_applyFilters` gọi `ApiStayzRepository.searchHotelSummaries`.
   4. Repository tạo query và gọi `GET /properties/search`.
   5. `properties.router.js` chuyển request tới controller.
   6. Controller gọi `properties.service.js`.
   7. Service lọc property active, enrich giá/phòng/rating rồi trả kết quả.
   8. `FutureBuilder` render loading/error/empty/data.

   ```dart
   // lib/shared/repositories/stayz_repository.dart:345
   Future<List<HotelSummary>> searchHotelSummaries(SearchFilters filters) async {
     final uri = Uri(
       path: '/properties/search',
       queryParameters: query,
     );
     final rows = await _list(uri.toString());
     return rows.map(_hotelSummaryFromMap).toList();
   }
   ```

   Các file kiểm tra từ thư mục gốc:

   1. `lib/features/search/presentation/pages/search_page.dart`
   2. `lib/shared/repositories/stayz_repository.dart`
   3. `lib/services/api_service.dart`
   4. `backend/stayz_api/src/routes/properties.router.js`
   5. `backend/stayz_api/src/controllers/properties.controller.js`
   6. `backend/stayz_api/src/services/properties.service.js`
   7. `backend/stayz_api/src/models/properties.model.js`

2. **Luồng tạo booking**

   1. `PaymentCheckoutPage` nhận `BookingDraft`.
   2. Frontend chọn payment plan và tính số hiển thị.
   3. Repository gửi `POST /booking/create` với Bearer token.
   4. `bookingController.create` gắn user từ JWT, không tin `user_id` tùy ý.
   5. `bookingService.create` xác minh room/property/ngày/sức chứa.
   6. Service dùng Redlock và kiểm tra booking giao nhau.
   7. Backend tính giá từ room trong DB.
   8. Tạo booking `pending`, hạn 15 phút và check-in code.
   9. Tạo notification chờ thanh toán.

   ```dart
   // lib/features/booking/presentation/pages/payment_checkout_page.dart:48
   final summary = await ApiStayzRepository.instance.createBooking(
     payableDraft,
   );
   ```

   ```javascript
   // backend/stayz_api/src/routes/booking.router.js:15
   bookingRouter.post("/create", bookingController.create);
   ```

   ```javascript
   // backend/stayz_api/src/services/booking.service.js:254
   const lockKey =
     `lock:room:${room._id}:${checkInDate.toISOString()}:${checkOutDate.toISOString()}`;
   lock = await acquireBookingLock(lockKey);
   ```

   Các file kiểm tra:

   1. `lib/features/booking/presentation/pages/booking_schedule_page.dart`
   2. `lib/features/booking/presentation/pages/payment_checkout_page.dart`
   3. `lib/shared/models/booking_flow_models.dart`
   4. `lib/shared/repositories/stayz_repository.dart`
   5. `backend/stayz_api/src/routes/booking.router.js`
   6. `backend/stayz_api/src/controllers/booking.controller.js`
   7. `backend/stayz_api/src/services/booking.service.js`
   8. `backend/stayz_api/src/models/bookings.model.js`

3. **Luồng tạo và xác nhận thanh toán**

   1. Sau khi booking được tạo, Flutter gọi `POST /payment/create/:bookingId`.
   2. Backend khóa payment theo booking trong 60 giây.
   3. Backend tính lại quote và tìm payment pending có thể reuse.
   4. PayOS trả checkout URL và QR.
   5. `PaymentQrPage` poll `GET /payment/booking/:bookingId` mỗi 3 giây.
   6. PayOS gọi `POST /payment/webhook`.
   7. Backend verify webhook và đối chiếu amount.
   8. Backend cập nhật `Payment=PAID`, `Booking=confirmed`.
   9. Lần poll tiếp theo nhận `PAID` và Flutter chuyển tới confirmation.

   ```dart
   // lib/features/booking/presentation/pages/payment_qr_page.dart:73
   void _startPolling() {
     if (_poller?.isActive == true || _expired || _navigating) return;
     _poller = Timer.periodic(
       const Duration(seconds: 3),
       (_) => _refreshStatus(showFailure: false),
     );
   }
   ```

   ```javascript
   // backend/stayz_api/src/services/payment.service.js:219
   if (verifiedData.code === "00") {
     if (Number(verifiedData.amount) !== Number(payment.amount)) {
       throw new BadRequestException("So tien webhook khong khop giao dich");
     }
     payment.status = "PAID";
     await payment.save();
   }
   ```

   Các file kiểm tra:

   1. `lib/features/booking/presentation/pages/payment_checkout_page.dart`
   2. `lib/features/booking/presentation/pages/payment_qr_page.dart`
   3. `lib/shared/data/payment_policy.dart`
   4. `backend/stayz_api/src/routes/payment.router.js`
   5. `backend/stayz_api/src/controllers/payment.controller.js`
   6. `backend/stayz_api/src/services/payment.service.js`
   7. `backend/stayz_api/src/utils/paymentQuote.util.js`
   8. `backend/stayz_api/src/models/payments.model.js`

4. **Luồng hủy booking**

   1. Flutter gọi `GET /booking/:id/cancellation-quote`.
   2. Backend kiểm tra booking tồn tại, ownership và trạng thái.
   3. Backend tính tỷ lệ theo số giờ trước check-in và số đã trả.
   4. Người dùng xác nhận hủy.
   5. Flutter gọi `PATCH /booking/:id/status` với `cancelled`.
   6. Backend chỉ cho guest hủy booking của chính họ.
   7. Backend ghi refund amount/rate/status và notification.

   File kiểm tra:

   1. `lib/features/booking_management/presentation/widgets/cancel_booking_dialog.dart`
   2. `lib/shared/repositories/stayz_repository.dart:595`
   3. `backend/stayz_api/src/services/booking.service.js:46`
   4. `backend/stayz_api/src/services/booking.service.js:338`

5. **Luồng review**

   1. Flutter tải review theo `propertyId`.
   2. User hoàn tất booking mở form rating/comment.
   3. Repository gọi `POST /review/create`.
   4. Service xác minh booking, user, property và review trùng.
   5. Rating phải từ 1 đến 5.
   6. Review được lưu rồi danh sách được reload.

   File kiểm tra:

   1. `lib/features/detail/presentation/pages/room_detail_page.dart:106`
   2. `lib/shared/repositories/stayz_repository.dart:654`
   3. `backend/stayz_api/src/routes/review.router.js`
   4. `backend/stayz_api/src/controllers/review.controller.js`
   5. `backend/stayz_api/src/services/review.service.js:30`

6. **Luồng admin check-in**

   1. Admin quét QR hoặc nhập mã.
   2. Flutter chuẩn hóa mã rồi gọi `GET /booking/admin/check-in/:code`.
   3. Backend yêu cầu role admin và mã hex đúng 8 ký tự.
   4. Admin cập nhật attendance bằng `PATCH /booking/:id/attendance`.
   5. Chỉ booking confirmed và ngày hiện tại nằm trong kỳ lưu trú mới được check-in.
   6. Sau checkout, checked-in chuyển completed; no-show chuyển cancelled, refund 0.

   File kiểm tra:

   1. `lib/features/admin/presentation/pages/admin_check_in_page.dart`
   2. `lib/features/admin/data/admin_repository.dart:72`
   3. `backend/stayz_api/src/routes/booking.router.js:19`
   4. `backend/stayz_api/src/services/booking.service.js:449`
   5. `backend/stayz_api/src/services/booking.service.js:498`

## 6. Cách kiểm tra nhanh từ thư mục gốc

1. Tìm endpoint:

   ```powershell
   rg -n "router\.(get|post|put|patch|delete)" backend/stayz_api/src/routes
   ```

2. Truy vết endpoint booking create:

   ```powershell
   rg -n "bookingRouter.post|create: async" backend/stayz_api/src/routes/booking.router.js backend/stayz_api/src/controllers/booking.controller.js backend/stayz_api/src/services/booking.service.js
   ```

3. Tìm nơi Flutter gọi API:

   ```powershell
   rg -n "api\.(get|post|put|patch|delete)|ApiStayzRepository" lib
   ```

4. Kiểm tra debounce và polling:

   ```powershell
   rg -n "Timer|_debounce|_poller|Duration" lib/features/search lib/features/booking
   ```

5. Kiểm tra route màn hình:

   ```powershell
   rg -n "static const|pushNamed|pushReplacementNamed" lib/app/routes lib/features
   ```

## 7. Luồng khởi động và xác thực

```text
main
 → nạp locale + theme
 → MaterialApp(initialRoute: /auth-gate)
 → gọi health check không chặn UI
 → đã xem onboarding?
    ├─ chưa → Onboarding
    └─ rồi → session hợp lệ?
              ├─ có → Home
              └─ không → Login
```

`AuthGatePage` đặt timeout 12 giây cho việc đọc trạng thái. Auth API gồm đăng ký, OTP đăng ký, login, quên mật khẩu, xác minh mã, đặt lại mật khẩu và Google OAuth. Access token/user id/name/role được lưu bằng tầng storage; API riêng tư gửi `Authorization: Bearer`.

Điểm kiểm duyệt:

- Không coi “có token” là đủ nếu dữ liệu token/user không hợp lệ.
- Route admin phải qua `AdminAccessGate` và backend vẫn phải kiểm tra role.
- Deep link Google chỉ hoàn tất session khi callback đúng định dạng.
- Logout phải xóa session và điều hướng loại bỏ stack cũ.

## 8. Luồng tìm kiếm và khám phá

```text
Home/Search input
 → cập nhật keyword + suggestion ngay
 → hủy timer cũ
 → debounce 1 giây
 → SearchFilters
 → GET /properties/search
 → backend lọc property đang active
 → enrich room price/capacity + review rating
 → sắp xếp kết quả
 → render FutureBuilder
```

Cơ chế đang dùng:

- `SearchPage` dùng `Timer` debounce **1 giây**; submit bàn phím chạy ngay và hủy timer.
- Suggestions dựng từ nguồn city/hotel đã tải.
- Mỗi lần lọc tạo `Future<List<HotelSummary>>` mới.
- Filter gồm keyword, city, type, tiện nghi, preferred, gần biển, khoảng giá, số khách và loại phòng.
- Backend chỉ lấy property active, enrich bằng aggregation room/review, sau đó lọc giá/capacity/type và chấm điểm keyword.
- Property list/featured/city/slug được cache Redis; mutation property làm invalidation cache.
- Favorite dùng optimistic UI: đổi icon trước, gọi API sau, rollback nếu lỗi.

Điểm kiểm duyệt:

- Hủy debounce ở `dispose`.
- Không dùng kết quả request cũ ghi đè filter mới.
- Keyword phải trim/encode; giá và guest phải được backend xác minh lại.
- Hiển thị rõ sold-out/available rooms; không cho kết quả UI trở thành cam kết tồn phòng.

## 9. Luồng màn hình đặt phòng

```text
Home/Search
 → Hotel detail
 → Room selection
 → Room detail (tùy chọn)
 → Booking schedule
 → Payment checkout
 → Payment QR
 → Booking confirmation
 → Upcoming booking detail / My bookings
```

Chi tiết:

1. `HotelSummary` được truyền bằng route arguments tới chi tiết.
2. Chọn phòng gọi `/room/:hotelId` với ngày ở để lấy availability.
3. `RoomSelectionArgs`/`BookingDraft` mang hotel, room, số khách/phòng, ngày.
4. Schedule kiểm tra check-out sau check-in, số khách/phòng rồi tạo draft hoàn chỉnh.
5. Checkout cho chọn `deposit_30` hoặc `full_100`; frontend hiển thị quote nhưng backend tính lại.
6. Frontend tạo booking pending rồi tạo PayOS payment.
7. QR page poll trạng thái mỗi **3 giây**, cập nhật countdown mỗi **1 giây**, ngừng poll khi paid/expired/rời màn hình.
8. Khi backend báo `PAID`, app lấy booking mới và tới confirmation.

## 10. Nghiệp vụ booking — nguồn sự thật ở backend

Khi tạo booking, `booking.service.js`:

- Bắt buộc user/property/room/check-in/check-out.
- Xác minh room thuộc property.
- Check-in không được ở quá khứ theo múi giờ `Asia/Ho_Chi_Minh`.
- Check-out phải sau check-in.
- Số phòng tối thiểu 1, số khách không vượt `capacity × rooms_count`.
- Tính số đêm và tổng tiền từ giá room trong DB, không tin giá client.
- Khóa theo `room + check-in + check-out` bằng Redlock tối đa 5 giây.
- Tìm booking giao nhau theo công thức `existing.check_in < new.check_out` và `existing.check_out > new.check_in`.
- Tính tồn từ booking `confirmed` và `pending` chưa hết hạn.
- Luôn tạo trạng thái `pending`, `payment_status=pending`, hạn thanh toán 15 phút.
- Tạo check-in code 8 ký tự hex và notification “awaiting payment”.
- Luôn release lock trong `finally`.

State machine:

```text
pending ── webhook paid ──> confirmed
   │                          │
   └──── expire/cancel ──> cancelled
                             
confirmed + checked_in + qua checkout ──> completed
confirmed + no_show + qua checkout ─────> cancelled (refund 0)
```

Ràng buộc:

- Guest chỉ được tự chuyển booking của mình sang `cancelled`.
- Không confirm booking chưa `payment_status=paid`.
- Không đưa `confirmed` quay lại `pending`.
- Không đổi booking đã `cancelled`/`completed`.
- Chỉ admin cập nhật attendance.
- Chỉ check-in trong khoảng ngày lưu trú và booking phải `confirmed`.
- Booking đã trả tiền không được sửa các trường phá vỡ hợp đồng tiền/phòng/ngày.
- Không xóa booking nếu đã có payment/review hoặc đã paid.

## 11. Nghiệp vụ thanh toán

```text
create booking pending
 → POST /payment/create/:bookingId
 → lock payment theo booking (60 giây)
 → backend tính quote
 → tái sử dụng payment pending còn hạn nếu cùng số tiền
 → PayOS tạo link/QR, hạn 15 phút
 → client hiển thị/poll
 → PayOS webhook
 → verify chữ ký + đối chiếu orderCode/số tiền
 → Payment=PAID
 → Booking=confirmed, payment_status=paid
 → notification
```

- Gói cọc: thanh toán 30%, 70% còn lại tại khách sạn.
- Gói toàn bộ: áp dụng quote theo `paymentQuote.util.js` (không nhân bản công thức ở màn hình khác).
- Một payment link cũ pending nhưng hết hạn/sai số tiền sẽ bị hủy trước khi tạo mới.
- Client không được tự set `PAID`.
- Webhook xử lý lặp an toàn: payment đã `PAID` thì trả lại, không ghi nhận hai lần.

## 12. Hủy booking và hoàn tiền

Frontend phải gọi cancellation quote trước khi người dùng xác nhận. Backend tính trên `amount_paid`:

- Trước check-in từ 168 giờ: hoàn 100%.
- Dưới 168 giờ nhưng vẫn trước check-in: full payment hoàn 70%, deposit hoàn 50%.
- Đến/sau thời điểm check-in: hoàn 0%.
- Xử lý hoàn tiền hiện ghi nhận là `manual`.

Không cho hủy booking đã cancelled/completed. Sau hủy phải lưu reason, refund amount/rate/status và phát notification tương ứng.

## 13. Review, favorite, notification, admin

### Review

- Review bắt buộc user/property/booking.
- Booking phải tồn tại, thuộc user/property phù hợp và đủ điều kiện nghiệp vụ.
- Mỗi user chỉ review một lần cho một booking.
- Rating từ 1 đến 5.
- Chỉ chủ review được sửa; chủ hoặc admin được xóa.

### Favorite

- Endpoint riêng tư `/favorites`.
- Add/remove theo hotel id; UI có optimistic update và rollback.
- Trạng thái yêu thích được nạp lại ở Home/Search/Detail khi cần.

### Notification

- Sinh tự động khi booking chờ thanh toán, paid/deposit, đổi trạng thái, completed/no-show.
- Người dùng có thể đọc một, đọc tất cả, xóa một hoặc xóa nhiều.
- Khi mở notification có `referenceId`, app điều hướng tới booking/search phù hợp.
- Badge unread do `NotificationsController` quản lý.

### Admin

- `AdminAccessGate` ở client chỉ là UX; quyền thật nằm ở middleware backend.
- Dashboard tải users/properties/rooms/bookings/reviews/payments song song và giữ lỗi riêng theo từng nguồn.
- Admin CRUD dữ liệu, cập nhật trạng thái/attendance, quét check-in code, kiểm duyệt review, đối soát/hủy payment.
- Check-in code phải đúng 8 ký tự hex; chỉ admin tra cứu.

## 14. Ma trận truy vết code

| Luồng | Flutter | Backend |
|---|---|---|
| Bootstrap/auth gate | `lib/main.dart`, `lib/app/app.dart`, `auth_gate_page.dart` | `/health`, auth/users routes |
| Login/register/reset | `lib/services/auth_service.dart`, `features/auth` | `users.router.js`, `users.service.js`, `auth.router.js` |
| Home/search/filter | `home_page.dart`, `search_page.dart`, `filter_page.dart` | `properties.router.js`, `properties.service.js` |
| Hotel/room | `features/detail`, `room_selection_real_page.dart` | `room.router.js`, `room.service.js` |
| Booking | `features/booking`, `booking_flow_models.dart` | `booking.router.js`, `booking.service.js`, `bookings.model.js` |
| Payment | `payment_checkout_page.dart`, `payment_qr_page.dart` | `payment.router.js`, `payment.service.js`, `paymentQuote.util.js` |
| Trips/cancel/check-in | `features/booking_management` | booking controller/service |
| Review | detail/review pages, repository | `review.router.js`, `review.service.js` |
| Favorite | home/search/detail/favorites | `favorites.router.js`, `favorites.service.js` |
| Notification | notifications page/controller | `notifications.router.js`, `notifications.service.js` |
| Admin | `features/admin` | admin middleware + feature routes/services |
| AI chat | `features/chat/ai_chat_sheet.dart` | `ai.router.js`, `ai.service.js`, chat service/models |

## 15. Checklist trước khi sửa một luồng

- [ ] Xác định entry screen, route arguments và destination.
- [ ] Xác định repository/service/endpoint thật.
- [ ] Xác định actor: guest, authenticated user hay admin.
- [ ] Ghi rõ precondition và state transition.
- [ ] Kiểm tra ownership và role ở backend.
- [ ] Kiểm tra double tap, request race, timeout, offline và retry.
- [ ] Kiểm tra empty/loading/error/success states.
- [ ] Kiểm tra cache invalidation hoặc optimistic rollback.
- [ ] Kiểm tra tiền được backend tính lại và webhook là nguồn xác nhận.
- [ ] Kiểm tra ngày theo timezone nghiệp vụ.
- [ ] Kiểm tra locale, theme, responsive, semantics và focus.
- [ ] Kiểm tra side effects: notification, payment, refund, review, cache.

## 16. Mẫu prompt triển khai tính năng

```text
Hãy bám sát kiến trúc StayZ hiện tại và triển khai [TÍNH NĂNG].

Trước khi sửa:
1. Truy vết màn hình → route arguments → repository/service → endpoint → controller → service → model.
2. Nêu actor, precondition, state transition, lỗi và side effect.
3. Chỉ ra quy tắc nghiệp vụ đang có cần tái sử dụng.

Khi triển khai:
- Không gọi API trực tiếp từ widget.
- Backend xác minh quyền, giá, ngày, tồn phòng và trạng thái.
- Chống double submit/race condition.
- Có loading/empty/error/success, mounted guard, locale VI/EN, light/dark và responsive.
- Không xác nhận payment từ client; dùng kết quả webhook.
- Không phá named routes hoặc route arguments hiện hữu.

Sau khi triển khai:
- Liệt kê file thay đổi.
- Mô tả luồng trước/sau.
- Nêu rủi ro còn lại và cách kiểm thử thủ công.
```

## 17. Các điểm cần theo dõi khi phát triển tiếp

1. State management phân tán theo màn hình có thể làm trùng request và khó đồng bộ Home/Search/Favorites/Bookings.
2. Search debounce chưa có request cancellation/token chống response cũ về sau response mới.
3. Hoàn tiền đang là quy trình manual; cần job/đối soát nếu đưa production.
4. Booking expiration/auto settle đang gắn với các lần gọi service; production nên có scheduled job độc lập.
5. Named route arguments là object runtime; cần chuẩn hóa typed navigation nếu số luồng tăng.
6. Error text backend còn có chuỗi kỹ thuật/không dấu; nên chuẩn hóa error code + mapping locale.
7. Các thao tác thanh toán và booking cần observability/audit xuyên suốt bằng booking id/order code.
