# StayZ API Cookbook

## 1. Quy ước

1. Base URL:

   ```text
   https://stayz-api.onrender.com/api
   ```

2. API cần đăng nhập:

   ```http
   Authorization: Bearer <ACCESS_TOKEN>
   Content-Type: application/json; charset=utf-8
   ```

3. Chuỗi xử lý chung:

   ```text
   Flutter Page
   → AuthService / ApiStayzRepository / AdminRepository
   → ApiService
   → Express Router
   → protect/admin/upload middleware
   → Controller
   → Service
   → Mongoose/Redis/PayOS/Cloudinary
   → response.metaData
   → Flutter model/state
   ```

4. Các ví dụ dùng biến:

   ```text
   <TOKEN>, <USER_ID>, <PROPERTY_ID>, <ROOM_ID>, <BOOKING_ID>,
   <PAYMENT_ID>, <REVIEW_ID>, <CONVERSATION_ID>
   ```

## 2. Ví dụ đầy đủ: đăng nhập

1. Request:

   ```http
   POST /api/users/login
   Content-Type: application/json
   ```

   ```json
   {
     "email": "guest@stayz.vn",
     "password": "StayZ@123"
   }
   ```

2. Flutter gọi service:

   ```dart
   // lib/features/auth/presentation/pages/login_page.dart:112
   Future<void> _login() async {
     final email = _emailController.text.trim();
     final password = _passwordController.text;
     final emailError = AuthValidators.email(email);
     final passwordError = AuthValidators.requiredPassword(password);
     setState(() {
       _emailError = emailError;
       _passwordError = passwordError;
     });
     if (emailError != null) {
       _showMessage(emailError);
       return;
     }
     if (passwordError != null) {
       _showMessage(passwordError);
       return;
     }
     setState(() => _isLoading = true);
     try {
       await AuthService.instance.login(email: email, password: password);
       if (!mounted) return;
       Navigator.of(context).pushNamedAndRemoveUntil(
         AppRoutes.home,
         (route) => false,
       );
     } on ApiException catch (error) {
       if (mounted) _showMessage(error.message);
     } finally {
       if (mounted) setState(() => _isLoading = false);
     }
   }
   ```

3. `AuthService` tạo body và lưu session:

   ```dart
   // lib/services/auth_service.dart:149
   Future<void> login({
     required String email,
     required String password,
   }) async {
     final data = await api.post(
       '/users/login',
       body: {
         'email': email.trim().toLowerCase(),
         'password': password,
       },
     );
     if (data is! Map<String, dynamic>) {
       throw const ApiException('Invalid sign-in response.');
     }
     final token = data['accessToken']?.toString() ?? '';
     final user = data['user'];
     if (token.isEmpty || user is! Map<String, dynamic>) {
       throw const ApiException('Sign-in failed.');
     }
     BookingCache.clear();
     final prefs = await SharedPreferences.getInstance();
     await _secureStorage.write(key: _accessTokenKey, value: token);
     await prefs.setString(_userIdKey, user['_id']?.toString() ?? '');
     await prefs.setString(_userEmailKey, user['email']?.toString() ?? '');
     await prefs.setString(_userNameKey, user['full_name']?.toString() ?? '');
     await prefs.setString(_userRoleKey, user['role']?.toString() ?? 'user');
   }
   ```

4. Router áp dụng rate limit:

   ```javascript
   // backend/stayz_api/src/routes/users.router.js:22
   userRouter.post("/login", rateLimiter(5, 60), userController.login);
   ```

5. Controller:

   ```javascript
   // backend/stayz_api/src/controllers/users.controller.js:98
   login: async (req, res, next) => {
     const user = req.body;
     try {
       const data = await userService.login(user);
       res.cookie(
         "refreshToken",
         data.refreshToken,
         buildRefreshCookieOptions(),
       );
       const response = responseSuccess(
         { accessToken: data.accessToken, user: data.user },
         "Dang nhap thanh cong",
         200,
       );
       res.status(response.code).json(response);
     } catch (err) {
       next(err);
     }
   }
   ```

6. Service xử lý:

   ```javascript
   // backend/stayz_api/src/services/users.service.js:443
   login: async (data) => {
     const { email, password } = data;
     if (!email || !password) {
       throw new BadRequestException("Thieu email hoac mat khau");
     }
     const user = await usersModel.findOne({ email });
     if (!user || user.is_active === false) {
       throw new UnauthorizedError("Email khong ton tai");
     }
     const isMatch = await bcrypt.compare(password, user.password);
     if (!isMatch) {
       throw new UnauthorizedError("Sai mat khau");
     }
     const { accessToken, refreshToken } = generateAuthTokens(user);
     return {
       accessToken,
       refreshToken,
       user: sanitizeUser(user),
     };
   }
   ```

7. Model:

   1. `backend/stayz_api/src/models/users.model.js`
   2. Email unique.
   3. Role chỉ `admin|user`.
   4. `is_active` quyết định tài khoản có được sử dụng.

## 3. Users và authentication

1. `GET /users/admin/audit?limit=50`

   1. Quyền: Bearer admin.
   2. Body: không có.
   3. Code gọi:

      ```dart
      api.get('/users/admin/audit?limit=50', bearerToken: token);
      ```

   4. Xử lý: `users.router.js:12` → `users.controller.js:getAdminAudit` → admin audit model.

2. `GET /users/getAll`

   1. Quyền: Bearer admin.
   2. Body: không có.
   3. Code: `api.get('/users/getAll', bearerToken: token)`.
   4. Xử lý: `users.router.js:13` → `users.controller.js:getAll` → `users.service.js:getAll`.

3. `GET /users/getById/:id`

   1. Quyền: chính user hoặc admin.
   2. Body: không có.
   3. Code: `api.get('/users/getById/$userId', bearerToken: token)`.
   4. Xử lý: controller so `req.user.userId` với `:id`, sau đó `userService.getById`.

4. `DELETE /users/delete/:id`

   1. Quyền: admin.
   2. Body: không có.
   3. Code: `api.delete('/users/delete/$id', bearerToken: token)`.
   4. Xử lý: `users.controller.js:delete` → `users.service.js:delete`.

5. `PATCH /users/update/:id`

   1. Quyền: chủ tài khoản hoặc admin; user thường không được tự nâng role.
   2. Body mẫu:

      ```json
      {
        "full_name": "Nguyễn Văn An",
        "phone_number": "0901234567",
        "gender": "male",
        "home_address": "Đà Nẵng",
        "date_of_birth": "1998-06-20"
      }
      ```

   3. Admin có thể thêm:

      ```json
      {
        "role": "admin",
        "is_active": true
      }
      ```

   4. Code: `ApiStayzRepository.updateProfile` tại `lib/shared/repositories/stayz_repository.dart:246`.
   5. Xử lý: `users.controller.js:update` lọc field theo role → `users.service.js:update`.

6. `POST /users/create`

   1. Quyền: public; rate limit 5/15 phút.
   2. Body:

      ```json
      {
        "full_name": "Nguyễn Văn An",
        "email": "an@example.com",
        "password": "StayZ@123",
        "phone_number": "0901234567",
        "register_code": "123456"
      }
      ```

   3. Code: `AuthService.register` tại `lib/services/auth_service.dart:113`.
   4. Xử lý: router → `users.controller.js:create` → `users.service.js:create` → hash password → User model.

7. `POST /users/admin/create`

   1. Quyền: admin.
   2. Body:

      ```json
      {
        "full_name": "StayZ Operator",
        "email": "operator@stayz.vn",
        "password": "StayZ@123",
        "phone_number": "0901000000",
        "gender": "other",
        "home_address": "Hồ Chí Minh",
        "role": "admin",
        "date_of_birth": "1995-01-01",
        "is_active": true
      }
      ```

   3. Code: `AdminRepository.saveUser` tại `lib/features/admin/data/admin_repository.dart:136`.
   4. Xử lý: `users.controller.js:createByAdmin` → `users.service.js:createByAdmin`.

8. `POST /users/login`

   1. Body và toàn bộ flow: xem [Mục 2](#2-ví-dụ-đầy-đủ-đăng-nhập).

9. `POST /users/refresh-token`

   1. Body JSON: không có; refresh token được backend đọc từ cookie/request theo `users.service.js`.
   2. Code HTTP:

      ```javascript
      fetch(`${baseUrl}/users/refresh-token`, {
        method: "POST",
        credentials: "include"
      });
      ```

   3. Xử lý: `users.controller.js:refreshAccessToken` → verify/rotate token.

10. `POST /users/logout`

    1. Body JSON: không có.
    2. Code: `AuthService.logout` tại `lib/services/auth_service.dart:279`.
    3. Xử lý: backend thu hồi/blacklist token; Flutter xóa secure storage.

11. `POST /users/request-register-otp`

    1. Body:

       ```json
       {"email": "an@example.com"}
       ```

    2. Code: `AuthService.requestRegisterOtp` tại `lib/services/auth_service.dart:132`.
    3. Xử lý: tạo OTP hash + expiry, gửi mail, không lưu OTP thô.

12. `POST /users/verify-register-otp`

    1. Body:

       ```json
       {"email": "an@example.com", "code": "123456"}
       ```

    2. Code: `AuthService.verifyRegisterOtp` tại `lib/services/auth_service.dart:139`.
    3. Xử lý: so hash, kiểm tra hết hạn và trạng thái đã dùng.

13. `POST /users/request-password-reset`

    1. Body: `{"email":"an@example.com"}`.
    2. Code: `lib/services/auth_service.dart:245`.
    3. Xử lý: tạo reset code hash + expiry và gửi email.

14. `POST /users/verify-reset-code`

    1. Body: `{"email":"an@example.com","code":"123456"}`.
    2. Code: `lib/services/auth_service.dart:253`.
    3. Xử lý: `users.service.js:assertResetCode`.

15. `POST /users/reset-password`

    1. Body:

       ```json
       {
         "email": "an@example.com",
         "code": "123456",
         "password": "NewStayZ@123"
       }
       ```

    2. Code: `lib/services/auth_service.dart:264`.
    3. Xử lý: validate code → hash password mới → xóa reset code.

16. `PATCH /users/avatar/local`

    1. Body: không dùng JSON.
    2. Multipart field: `avatar=<binary>`.
    3. Xử lý: `uploadLocalMiddleware` → `users.controller.js:uploadLocal` → `users.service.js:uploadLocal`.

17. `PATCH /users/avatar/cloud`

    1. Body: multipart `avatar=<binary>`.
    2. Code: `ApiStayzRepository.uploadProfileAvatar` tại `stayz_repository.dart:287`.
    3. Xử lý: upload middleware → Cloudinary → lưu `avatar.url/public_id`.

18. `PATCH /users/avatar/cloud/:id`

    1. Quyền: admin audit.
    2. Body: multipart `avatar=<binary>`.
    3. Code: `AdminRepository.uploadUserAvatar` tại `admin_repository.dart:237`.

19. `GET /auth/google`

    1. Body: không có.
    2. Code: `AuthService.googleLoginUri` tại `lib/services/auth_service.dart:192`.
    3. Xử lý: Passport chuyển hướng sang Google.

20. `GET /auth/google/callback`

    1. Body: Google OAuth callback query, app không tự tạo.
    2. Xử lý: Passport verify → `authController.googleCallback` → `authService.loginGoogle` → deep link `login-success`.

## 4. Properties và rooms

1. Các endpoint đọc property:

   1. `GET /properties/getAll` — body: không có.
   2. `GET /properties/admin/getAll` — body: không có; admin.
   3. `GET /properties/featured` — body: không có.
   4. `GET /properties/:city` — ví dụ `/properties/da-nang`.
   5. `GET /properties/:city/:slug` — ví dụ `/properties/da-nang/furama-resort-danang`.
   6. Code Flutter: `ApiStayzRepository.getHotelSummaries`.
   7. Xử lý: `properties.router.js` → controller tương ứng → `properties.service.js`; list/featured/city/slug dùng Redis cache.

2. `GET /properties/search`

   1. Body: không có; dùng query.
   2. Ví dụ:

      ```text
      /properties/search?keyword=biển&city=da-nang&minPrice=500000&maxPrice=3000000&guests=2&isPreferred=true
      ```

   3. Code: `ApiStayzRepository.searchHotelSummaries` tại `stayz_repository.dart:345`.
   4. Xử lý: `properties.controller.js:search` → `properties.service.js:search` → filter/enrich/rank.

3. Search history:

   1. `GET /properties/search/history` — body: không có; JWT.
   2. `DELETE /properties/search/history` — body: không có; JWT.
   3. Xử lý: controller đọc/ghi Redis key `search:history:<userId>`.

4. `POST /properties/create` và `PUT /properties/update/:id`

   1. Quyền: admin.
   2. Body:

      ```json
      {
        "title": "StayZ Riverside",
        "slug": "stayz-riverside",
        "address": "10 Bạch Đằng",
        "city": "da-nang",
        "country": "Vietnam",
        "latitude": 16.0678,
        "longitude": 108.2208,
        "type": "hotel",
        "base_price": 1200000,
        "description": "Khách sạn ven sông",
        "description_en": "Riverside hotel",
        "main_image_url": "",
        "is_preferred": true,
        "is_active": true,
        "max_stay_days": 30
      }
      ```

   3. Code: `AdminRepository.saveHotel` tại `admin_repository.dart:88`.
   4. Xử lý: controller → `properties.service.js:create|update` → rebuild search index → save → invalidate Redis.

5. `DELETE /properties/delete/:id`

   1. Body: không có.
   2. Code: `AdminRepository.deleteHotel`.
   3. Xử lý: từ chối nếu còn room/booking/review/favorite → xóa Cloudinary assets → invalidate cache.

6. Upload property:

   1. `PATCH /properties/upload/local/:id` — multipart field `image`.
   2. `PATCH /properties/upload/cloud/:id` — multipart field `image`.
   3. `PATCH /properties/upload/gallery/cloud/:id` — multipart nhiều field `images`, tối đa 10.
   4. JSON body: không có.
   5. Xử lý: upload middleware → controller → service → lưu URL/public id → invalidate cache.

7. Room reads:

   1. `GET /room/getAll` — query tùy chọn `checkIn`, `checkOut`.
   2. `GET /room/admin/getAll` — admin, gồm inactive.
   3. `GET /room/:propertyId?checkIn=2026-08-10&checkOut=2026-08-12`.
   4. Body: không có.
   5. Code: `ApiStayzRepository.getRoomsByHotelId` tại `stayz_repository.dart:487`.
   6. Xử lý: `room.service.js:attachAvailability` trừ booking giao nhau.

8. `POST /room/create` và `PUT /room/update/:id`

   1. Quyền: admin.
   2. Body:

      ```json
      {
        "property_id": "<PROPERTY_ID>",
        "name": "Deluxe River View",
        "room_type": "deluxe_room",
        "description": "Phòng nhìn ra sông",
        "description_en": "River-view room",
        "original_price": 1800000,
        "discount_percent": 10,
        "capacity": 2,
        "quantity": 8,
        "bed_info": "1 giường king",
        "area": 38,
        "view": "river",
        "main_image_url": "",
        "is_active": true
      }
      ```

   3. Code: `AdminRepository.saveRoom` tại `admin_repository.dart:112`.
   4. Xử lý: service tính `price` từ original price/discount và clear room/property cache.

9. `DELETE /room/delete/:id`

   1. Body: không có.
   2. Code: `AdminRepository.deleteRoom`.
   3. Xử lý: service kiểm tra ràng buộc booking rồi xóa assets/data.

10. Upload room:

    1. `PATCH /room/upload/cloud/:id` — multipart `image`.
    2. `PATCH /room/upload/gallery/cloud/:id` — multipart `images`, tối đa 10.
    3. JSON body: không có.

## 5. Bookings và payments

1. Booking reads:

   1. `GET /booking/getAll` — admin thấy tất cả; user chỉ dữ liệu được controller/service cho phép.
   2. `GET /booking/user/:userId` — body: không có; owner/admin.
   3. Code: `ApiStayzRepository.getBookingSummaries` tại `stayz_repository.dart:516`.

2. `POST /booking/create`

   1. Body:

      ```json
      {
        "property_id": "<PROPERTY_ID>",
        "room_id": "<ROOM_ID>",
        "check_in": "2026-08-10T00:00:00.000",
        "check_out": "2026-08-12T00:00:00.000",
        "guests": 2,
        "rooms_count": 1,
        "payment_plan": "deposit_30"
      }
      ```

   2. Không gửi `total_price`, `price_per_night`, `payment_status=paid` để làm nguồn sự thật.
   3. Code: `ApiStayzRepository.createBooking` tại `stayz_repository.dart:541`.
   4. Xử lý: `booking.controller.js:create` lấy user từ JWT → `booking.service.js:create` validate → Redlock → availability → server price → pending 15 phút.

3. `PUT /booking/update/:bookingId`

   1. Body mẫu:

      ```json
      {
        "check_in": "2026-08-11T00:00:00.000",
        "check_out": "2026-08-13T00:00:00.000",
        "guests": 2,
        "rooms_count": 1
      }
      ```

   2. Xử lý: ownership; không sửa booking terminal; user không được phá hợp đồng đã paid; kiểm tra lại room/date/capacity/availability.

4. `DELETE /booking/delete/:bookingId`

   1. Body: không có.
   2. Xử lý: owner/admin; từ chối nếu có payment/review hoặc đã paid.

5. `GET /booking/:bookingId/cancellation-quote`

   1. Body: không có.
   2. Code: `ApiStayzRepository.getCancellationQuote`.
   3. Response nghiệp vụ gồm `refund_amount`, `refund_rate`, `hours_before_check_in`, `processing`.

6. `PATCH /booking/:bookingId/status`

   1. Body:

      ```json
      {"status": "cancelled"}
      ```

   2. Guest chỉ được gửi `cancelled`; confirm đến từ payment webhook; completed thuộc hệ thống/admin.
   3. Code: `ApiStayzRepository.updateBookingStatus`.

7. `PATCH /booking/:bookingId/attendance`

   1. Quyền: admin.
   2. Body:

      ```json
      {
        "attendance_status": "checked_in",
        "note": "Đã xác minh CCCD"
      }
      ```

   3. Giá trị: `pending|checked_in|no_show`.
   4. Code: `AdminRepository.updateBookingAttendance`.

8. `GET /booking/admin/check-in/:code`

   1. Body: không có.
   2. Code phải là 8 ký tự hex, ví dụ `A1B2C3D4`.
   3. Code Flutter: `AdminRepository.findBookingByCheckInCode`.

9. `POST /payment/create/:bookingId`

   1. Body:

      ```json
      {"payment_plan": "deposit_30"}
      ```

   2. Hoặc `{"payment_plan":"full_100"}`.
   3. Code: `ApiStayzRepository.createPayOSPayment`.
   4. Xử lý: payment Redlock → ownership → server quote → reuse/cancel link cũ → PayOS create → save Payment.

10. `GET /payment/booking/:bookingId`

    1. Body: không có.
    2. Code: `ApiStayzRepository.getPayOSPayment`.
    3. Flutter poll endpoint này mỗi 3 giây tại `payment_qr_page.dart:73`.

11. `POST /payment/cancel/:bookingId`

    1. Body JSON: không có.
    2. Xử lý: ownership → chỉ payment pending → cancel PayOS → update payment/booking.

12. `POST /payment/webhook`

    1. Public vì PayOS gọi trực tiếp.
    2. Body: payload nguyên bản do PayOS ký; không tự chế payload trong app.
    3. Ví dụ hình dạng tối giản:

       ```json
       {
         "code": "00",
         "desc": "success",
         "success": true,
         "data": {
           "orderCode": 123456789,
           "amount": 360000
         },
         "signature": "<PAYOS_SIGNATURE>"
       }
       ```

    4. Xử lý: `payment.service.js:handleWebhook` dùng `payOS.webhooks.verify` → amount match → Payment PAID → Booking confirmed → notification.

13. Payment admin và redirect:

    1. `GET /payment/getAll` — body không có; admin.
    2. `POST /payment/admin/:paymentId/cancel` — body không có; admin.
    3. `GET /payment/return` — query PayOS; body không có.
    4. `GET /payment/cancel` — query PayOS; body không có.

## 6. Review, favorites và notifications

1. `GET /review/getAll?propertyId=<PROPERTY_ID>`

   1. Body: không có.
   2. Code: `ApiStayzRepository.getReviewsByHotelId`.

2. `POST /review/create`

   1. Body:

      ```json
      {
        "property_id": "<PROPERTY_ID>",
        "booking_id": "<BOOKING_ID>",
        "rating": 5,
        "comment": "Phòng sạch và nhân viên thân thiện."
      }
      ```

   2. `user_id` được controller lấy từ JWT.
   3. Code: `ApiStayzRepository.submitReview`.
   4. Xử lý: booking/user/property match → không trùng booking+user → rating 1–5 → create.

3. `PUT /review/update/:id`

   1. Body: `{"rating":4,"comment":"Nội dung đã cập nhật"}`.
   2. Xử lý: chỉ chủ review được sửa.

4. `DELETE /review/delete/:id`

   1. Body: không có.
   2. Xử lý: chủ review hoặc admin.

5. Favorites:

   1. `GET /favorites` — body không có.
   2. `GET /favorites/check/:propertyId` — body không có.
   3. `POST /favorites/:propertyId` — body không có.
   4. `DELETE /favorites/:propertyId` — body không có.
   5. Code: `stayz_repository.dart:453-483`.
   6. Xử lý: user lấy từ JWT, service kiểm tra property và tránh duplicate.

6. Notifications:

   1. `GET /notifications?page=1&limit=20` — body không có.
   2. `PATCH /notifications/read-all` — body không có.
   3. `PATCH /notifications/:id/read` — body không có.
   4. `DELETE /notifications/:id` — body không có.
   5. Code: `stayz_repository.dart:675-712`.
   6. Xử lý: mọi query/update/delete đều ràng buộc `req.user.userId`.

## 7. Chat và AI

1. `POST /chat/conversations`

   1. Body:

      ```json
      {"targetId": "<USER_ID>"}
      ```

   2. Xử lý: `chat.controller.js:getOrCreateConversation` → `chat.service.js`.

2. `GET /chat/conversations`

   1. Body: không có.
   2. Trả conversation mà user hiện tại là participant.

3. `GET /chat/conversations/:conversationId/messages?page=1&limit=30`

   1. Body: không có.
   2. Xử lý: phân trang message của conversation.

4. `POST /chat/conversations/:conversationId/messages`

   1. Body:

      ```json
      {"content": "Tôi muốn hỏi về giờ nhận phòng."}
      ```

   2. Xử lý: controller lấy sender từ JWT → `chatService.saveMessage` → Socket.IO phát realtime.

5. `PATCH /chat/conversations/:conversationId/read`

   1. Body: không có.
   2. Xử lý: đánh dấu message của phía còn lại đã đọc.

6. `POST /ai/chat`

   1. Body mẫu:

      ```json
      {
        "message": "Tìm khách sạn ở Đà Nẵng cho 2 người từ 10/08 đến 12/08",
        "conversationId": "<CONVERSATION_ID>"
      }
      ```

   2. Code Flutter: `lib/features/chat/ai_chat_sheet.dart`.
   3. Xử lý: `ai.controller.js` gắn `userId` từ JWT → `ai.service.js` dựng context từ property/room/availability → gọi AI provider → lưu conversation/messages.

## 8. Cách xem code xử lý đầy đủ

1. Một endpoint không nằm trong một file duy nhất. Để đọc “đầy đủ”, đi theo thứ tự:

   ```text
   src/routes/<feature>.router.js
   → src/controllers/<feature>.controller.js
   → src/services/<feature>.service.js
   → src/models/<feature>.model.js
   ```

2. Ví dụ login:

   ```powershell
   rg -n "login" backend/stayz_api/src/routes/users.router.js backend/stayz_api/src/controllers/users.controller.js backend/stayz_api/src/services/users.service.js
   ```

3. Ví dụ booking:

   ```powershell
   rg -n "create|updateStatus|updateAttendance" backend/stayz_api/src/routes/booking.router.js backend/stayz_api/src/controllers/booking.controller.js backend/stayz_api/src/services/booking.service.js
   ```

4. Liệt kê toàn bộ endpoint thực tế:

   ```powershell
   rg -n "router\.(get|post|put|patch|delete)" backend/stayz_api/src/routes
   ```

5. Lưu ý: cookbook mô tả payload theo code hiện tại. Luôn xem service/model trước khi thay đổi field, vì business validation nằm ở service chứ không chỉ ở router.
