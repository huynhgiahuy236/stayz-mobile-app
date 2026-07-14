# NỘI DUNG TỔNG HỢP BÁO CÁO ĐỒ ÁN STAYZ

> Bản nháp rút gọn để kiểm tra trước khi đưa vào Word. Nội dung được tổng hợp từ source hiện tại của project StayZ. Các vị trí `[CHÈN HÌNH]`, `[ĐIỀN KẾT QUẢ]` cần được nhóm bổ sung sau khi chụp màn hình hoặc chạy kiểm thử thực tế.

## CHƯƠNG 1. MỞ ĐẦU

### 1.1. Lý do chọn đề tài

Cùng với sự phát triển của du lịch và thói quen sử dụng thiết bị di động, nhu cầu tìm kiếm và đặt nơi lưu trú trực tuyến ngày càng phổ biến. Người dùng mong muốn có thể tra cứu khách sạn, xem phòng, so sánh giá, kiểm tra tiện nghi và hoàn tất đặt phòng trên cùng một ứng dụng. Ở phía quản trị, hệ thống cần hỗ trợ quản lý người dùng, cơ sở lưu trú, phòng, đơn đặt phòng, giao dịch và đánh giá một cách tập trung.

Từ nhu cầu đó, nhóm thực hiện đề tài **“Xây dựng ứng dụng di động đặt phòng khách sạn trực tuyến StayZ”**. Ứng dụng hướng đến việc xây dựng một quy trình đặt phòng tương đối đầy đủ, từ đăng ký tài khoản, tìm kiếm nơi lưu trú, lựa chọn phòng, tạo đơn, thanh toán trực tuyến cho đến theo dõi và quản lý trạng thái đơn. Bên cạnh các chức năng dành cho khách hàng, hệ thống còn cung cấp khu vực quản trị và trợ lý AI hỗ trợ tìm kiếm khách sạn dựa trên dữ liệu đang lưu trong hệ thống.

### 1.2. Mục tiêu đề tài

Mục tiêu tổng quát của đề tài là xây dựng một ứng dụng đặt phòng khách sạn theo mô hình Client–Server, trong đó ứng dụng Flutter giao tiếp với Backend API để truy xuất và cập nhật dữ liệu MongoDB.

Các mục tiêu cụ thể gồm:

- Xây dựng ứng dụng di động bằng Flutter và Dart với giao diện rõ ràng, hỗ trợ tiếng Việt và tiếng Anh.
- Xây dựng Backend bằng Node.js và Express.js, tổ chức mã nguồn theo các lớp route, controller, service và model.
- Sử dụng MongoDB và Mongoose để lưu trữ, kiểm tra và liên kết dữ liệu.
- Hỗ trợ đăng ký, xác minh OTP, đăng nhập, đăng nhập Google, làm mới token, đăng xuất, quên mật khẩu và cập nhật hồ sơ.
- Hỗ trợ tìm kiếm khách sạn theo thành phố, giá, tiện nghi và các điều kiện liên quan.
- Hỗ trợ xem chi tiết khách sạn, phòng, lựa chọn ngày ở, số khách và số phòng.
- Xây dựng quy trình tạo booking, kiểm tra số phòng khả dụng và hạn chế đặt trùng trong cùng khoảng thời gian.
- Tích hợp PayOS để tạo yêu cầu thanh toán, mã QR, nhận webhook và cập nhật trạng thái giao dịch.
- Hỗ trợ quản lý booking, hủy booking, ghi nhận mức hoàn tiền, đánh giá, yêu thích và thông báo.
- Xây dựng khu vực Admin để quản lý người dùng, khách sạn, phòng, booking, review và payment.
- Tích hợp trợ lý AI hỗ trợ tìm kiếm và đề xuất khách sạn dựa trên dữ liệu thật của StayZ.

### 1.3. Phạm vi đề tài

Đề tài tập trung vào hai nhóm người sử dụng là **User** và **Admin**.

Đối với User, hệ thống cung cấp các chức năng chính: quản lý tài khoản và hồ sơ cá nhân; tìm kiếm, lọc và xem thông tin khách sạn; xem loại phòng; thêm khách sạn vào danh sách yêu thích; tạo và theo dõi booking; thanh toán qua PayOS; hủy booking; xem thông báo; gửi đánh giá sau khi hoàn thành chuyến đi; và sử dụng trợ lý AI để tìm lựa chọn phù hợp.

Đối với Admin, hệ thống hỗ trợ xem dữ liệu tổng quan và quản lý người dùng, khách sạn, phòng, booking, review và giao dịch. Các thao tác thay đổi dữ liệu quản trị được bảo vệ bằng JWT và middleware kiểm tra quyền Admin.

Đề tài triển khai quy trình thanh toán thông qua PayOS. Việc vận hành thanh toán thực tế phụ thuộc vào cấu hình tài khoản PayOS, địa chỉ webhook và môi trường triển khai. Chức năng hoàn tiền trong trạng thái hiện tại chủ yếu ghi nhận số tiền, tỷ lệ và trạng thái xử lý; chưa khẳng định đã tự động hoàn tiền qua cổng thanh toán.

### 1.4. Đối tượng và phương pháp thực hiện

Đối tượng nghiên cứu của đề tài gồm quy trình tìm kiếm nơi lưu trú, quản lý số lượng phòng theo thời gian, tạo booking, thanh toán trực tuyến và quản trị dữ liệu khách sạn. Về công nghệ, đề tài sử dụng Flutter, Dart, Node.js, Express.js, MongoDB, Mongoose, JWT, Redis, PayOS và một số dịch vụ tích hợp khác.

Nhóm thực hiện đề tài theo các bước: khảo sát chức năng của ứng dụng đặt phòng; phân tích yêu cầu và tác nhân; thiết kế luồng nghiệp vụ, giao diện và cơ sở dữ liệu; xây dựng API; kết nối Flutter với Backend; sau đó kiểm tra các luồng chính trên thiết bị hoặc trình giả lập.

## CHƯƠNG 2. CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ

### 2.1. Mô hình ứng dụng đặt phòng trực tuyến

Ứng dụng đặt phòng trực tuyến là hệ thống cho phép người dùng tìm kiếm nơi lưu trú, xem thông tin, chọn phòng và tạo booking qua Internet. Một hệ thống hoàn chỉnh cần quản lý đồng thời thông tin người dùng, cơ sở lưu trú, phòng, giá, số lượng phòng, khoảng thời gian nhận và trả phòng, trạng thái booking và giao dịch thanh toán.

StayZ được xây dựng theo mô hình Client–Server. Flutter Client chịu trách nhiệm hiển thị giao diện, thu thập dữ liệu và gửi yêu cầu HTTP. Backend tiếp nhận yêu cầu, xác thực người dùng, thực hiện nghiệp vụ, truy vấn MongoDB và trả dữ liệu JSON về ứng dụng.

### 2.2. Flutter và Dart

Flutter là bộ công cụ phát triển giao diện đa nền tảng, sử dụng ngôn ngữ Dart. Trong StayZ, Flutter được dùng để xây dựng các màn hình onboarding, xác thực, trang chủ, tìm kiếm, chi tiết khách sạn, lựa chọn phòng, thanh toán, quản lý booking, hồ sơ, thông báo và khu vực Admin.

Mã nguồn Flutter được tổ chức theo hướng feature-first. Mỗi nhóm chức năng nằm trong một thư mục riêng dưới `lib/features`, trong khi thành phần dùng chung được đặt trong `lib/shared`, cấu hình ứng dụng nằm trong `lib/app`, và các lớp gọi API hoặc lưu trạng thái xác thực nằm trong `lib/services`. Cách tổ chức này giúp giới hạn phạm vi thay đổi và hỗ trợ tái sử dụng widget, model và repository.

### 2.3. Node.js, Express.js và REST API

Node.js cung cấp môi trường chạy JavaScript phía máy chủ. Express.js được sử dụng để định nghĩa route, middleware và xử lý request/response. Backend StayZ được chia thành các thành phần chính:

- `routes`: khai báo đường dẫn API và middleware bảo vệ.
- `controllers`: tiếp nhận request, gọi service và trả response.
- `services`: xử lý nghiệp vụ và truy vấn dữ liệu.
- `models`: định nghĩa Mongoose schema.
- `middlewares`: xác thực JWT, phân quyền, giới hạn request và xử lý upload.
- `config`, `helpers`, `utils`: cấu hình dịch vụ và các hàm hỗ trợ.

Các API trao đổi dữ liệu JSON qua HTTP. Những route chứa thông tin cá nhân, booking, yêu thích, thông báo, chat và AI yêu cầu access token. Các route quản trị còn kiểm tra thêm quyền `admin`.

### 2.4. MongoDB và Mongoose

MongoDB là cơ sở dữ liệu NoSQL lưu dữ liệu theo document. Mongoose được sử dụng để định nghĩa cấu trúc, kiểu dữ liệu, giá trị mặc định, enum, index và quan hệ tham chiếu bằng ObjectId.

Các model quan trọng của StayZ gồm User, Property, Room, Booking, Payment, Review, Favorite, Notification, Conversation và Message. Dữ liệu khách sạn trong source được gọi là **Property**, không sử dụng collection `hotels`. Các quan hệ chính được biểu diễn bằng những trường như `user_id`, `property_id`, `room_id`, `booking_id` và `conversation_id`.

### 2.5. Xác thực và bảo vệ hệ thống

StayZ sử dụng JSON Web Token để xác thực request. Sau khi đăng nhập, Client lưu thông tin xác thực và đính kèm Bearer token khi gọi các API được bảo vệ. Backend còn cung cấp refresh token và logout để quản lý phiên đăng nhập.

Mật khẩu được băm bằng bcrypt trước khi lưu. Các chức năng đăng ký, đăng nhập và đặt lại mật khẩu được giới hạn số lần request bằng rate limiter. Hệ thống hỗ trợ OTP qua email và đăng nhập Google thông qua Passport OAuth 2.0. Quyền truy cập quản trị được kiểm tra bằng role `admin`; hệ thống hiện không có role Vendor.

### 2.6. Các dịch vụ tích hợp

PayOS được sử dụng để tạo yêu cầu thanh toán, đường dẫn checkout, mã QR và nhận kết quả qua webhook. Redis kết hợp Redlock được dùng trong quy trình tạo booking nhằm khóa tạm theo phòng và khoảng ngày, giảm nguy cơ nhiều request đồng thời giữ vượt quá số lượng phòng.

Cloudinary và Multer hỗ trợ tải ảnh đại diện, ảnh khách sạn và thư viện ảnh phòng. Nodemailer phục vụ gửi OTP và thông tin đặt lại mật khẩu. Socket.io và các collection Conversation, Message hỗ trợ phần chat. Trợ lý AI gọi OpenAI khi có cấu hình phù hợp; nếu dịch vụ AI không khả dụng, Backend tạo phản hồi dự phòng từ dữ liệu MongoDB thay vì tự tạo khách sạn hoặc giá không có trong hệ thống.

## CHƯƠNG 3. PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG

### 3.1. Phân tích yêu cầu chức năng

Hệ thống có hai tác nhân nghiệp vụ chính:

- **User:** đăng ký, đăng nhập, quản lý hồ sơ, tìm kiếm khách sạn, xem phòng, lưu yêu thích, đặt phòng, thanh toán, quản lý booking, xem thông báo, đánh giá và sử dụng AI hỗ trợ tìm kiếm.
- **Admin:** truy cập dashboard và quản lý người dùng, khách sạn, phòng, booking, đánh giá và giao dịch.

Các hệ thống bên ngoài gồm dịch vụ email, Google OAuth, Cloudinary, Redis, PayOS và OpenAI. Đây là thành phần tích hợp kỹ thuật, không phải vai trò người dùng của StayZ.

### 3.2. Yêu cầu phi chức năng

- Giao diện cần hiển thị tốt trên nhiều kích thước màn hình di động và bảo đảm các thao tác chính dễ nhận biết.
- API trả dữ liệu JSON thống nhất và thông báo lỗi đủ rõ để Client xử lý.
- Dữ liệu cá nhân và booking phải được bảo vệ bằng JWT; chức năng Admin phải kiểm tra quyền.
- Mật khẩu không lưu ở dạng văn bản thuần; OTP và các route nhạy cảm cần giới hạn tần suất request.
- Hệ thống phải kiểm tra ngày ở, sức chứa và số lượng phòng trước khi tạo booking.
- Truy vấn tìm kiếm và đề xuất AI chỉ được sử dụng dữ liệu thật trong MongoDB.
- Khi dịch vụ ngoài gặp lỗi, ứng dụng cần hiển thị trạng thái lỗi hoặc phương án thay thế phù hợp, không tạo dữ liệu giả làm kết quả thật.

### 3.3. Use Case tổng quát

`[CHÈN HÌNH 3.1: USE CASE TỔNG QUÁT CỦA STAYZ]`

Use Case tổng quát được chia thành các nhóm: tài khoản và hồ sơ; tìm kiếm và khám phá; đặt phòng và thanh toán; booking của người dùng; và quản trị hệ thống. Các dịch vụ PayOS, OpenAI, Cloudinary và email được biểu diễn như hệ thống ngoài tương tác với các chức năng tương ứng.

Để báo cáo ngắn gọn, các Use Case quản lý tài khoản, quản lý khách sạn/phòng và quản lý booking có thể trình bày ở phụ lục. Phần nội dung chính tập trung vào luồng tìm kiếm, đặt phòng và thanh toán vì đây là nghiệp vụ trung tâm của đề tài.

### 3.4. Đặc tả các Use Case cốt lõi

#### 3.4.1. Đăng nhập

- **Tác nhân:** User hoặc Admin.
- **Tiền điều kiện:** Tài khoản đã tồn tại và chưa bị mất quyền truy cập.
- **Luồng chính:** Người dùng nhập email, mật khẩu; Client gửi request đến Backend; Backend kiểm tra tài khoản và mật khẩu; nếu hợp lệ, hệ thống trả thông tin người dùng và token; Client lưu phiên đăng nhập và chuyển đến giao diện phù hợp.
- **Ngoại lệ:** Thiếu thông tin, sai mật khẩu, tài khoản không tồn tại hoặc vượt giới hạn request. Người dùng cũng có thể bắt đầu đăng nhập Google và quay lại ứng dụng qua deep link sau khi OAuth thành công.

#### 3.4.2. Tìm kiếm và chọn phòng

- **Tác nhân:** User.
- **Tiền điều kiện:** Dữ liệu khách sạn và phòng đã có trong MongoDB.
- **Luồng chính:** Người dùng nhập thành phố, ngày nhận/trả phòng, số khách và bộ lọc; Client gọi API tìm kiếm; Backend truy vấn Property và Room; kết quả được trả về để hiển thị dưới dạng danh sách; người dùng chọn khách sạn và phòng phù hợp.
- **Ngoại lệ:** Không có kết quả, ngày không hợp lệ, phòng không hoạt động, sức chứa không đủ hoặc không còn đủ số lượng phòng trong khoảng ngày đã chọn.

#### 3.4.3. Đặt phòng và thanh toán

- **Tác nhân:** User; hệ thống ngoài PayOS.
- **Tiền điều kiện:** User đã đăng nhập, đã chọn phòng, ngày ở, số khách, số phòng và phương án thanh toán.
- **Luồng chính:** Client gửi `POST /booking/create` kèm JWT; Backend kiểm tra ngày, sức chứa và số phòng; hệ thống khóa tạm tài nguyên bằng Redis/Redlock; truy vấn các booking đang giữ chỗ hoặc đã xác nhận bị trùng thời gian; nếu còn đủ phòng, Backend tính số đêm, giá và tạo booking trạng thái `pending`; sau đó Client gọi `POST /payment/create/:bookingId`; Backend tạo payment request qua PayOS và trả thông tin checkout/QR; PayOS gửi webhook; Backend xác minh kết quả và cập nhật Payment thành `PAID`, Booking thành `confirmed` và `payment_status` thành `paid`.
- **Ngoại lệ:** Ngày hoặc số lượng không hợp lệ, hết phòng, booking không thuộc người dùng, payment hết hạn, PayOS trả lỗi hoặc giao dịch bị hủy.

`[CHÈN HÌNH 3.2: SEQUENCE DIAGRAM ĐẶT PHÒNG VÀ THANH TOÁN PAYOS]`

### 3.5. Kiến trúc tổng thể

Kiến trúc StayZ gồm các thành phần chính:

1. **Flutter Client:** hiển thị giao diện, quản lý dữ liệu nhập và gọi API.
2. **Express API:** xác thực request, điều phối controller và service.
3. **MongoDB:** lưu dữ liệu nghiệp vụ.
4. **Redis/Redlock:** hỗ trợ khóa đồng thời khi tạo booking.
5. **Dịch vụ ngoài:** PayOS, Cloudinary, Google OAuth, email và OpenAI.

Luồng dữ liệu thông thường là: người dùng thao tác trên Flutter → ApiService gửi request → route và middleware xử lý quyền → controller gọi service → service truy vấn model hoặc dịch vụ ngoài → Backend trả JSON → Flutter chuyển dữ liệu thành model và cập nhật giao diện.

### 3.6. Thiết kế cơ sở dữ liệu

Các collection chính được tóm tắt như sau:

| Collection/Model | Trường tiêu biểu | Mục đích |
|---|---|---|
| `users` / User | `email`, `password`, `full_name`, `phone_number`, `avatar`, `role` | Tài khoản và hồ sơ |
| `properties` / Property | `title`, `slug`, `city`, `base_price`, `amenities`, `main_image_url`, `gallery_images` | Cơ sở lưu trú |
| `rooms` / Room | `property_id`, `name`, `room_type`, `price`, `capacity`, `quantity`, `is_active` | Loại phòng và số lượng |
| `bookings` / Booking | `user_id`, `property_id`, `room_id`, `check_in`, `check_out`, `rooms_count`, `total_price`, `status`, `payment_status` | Đơn đặt phòng |
| `payments` / Payment | `booking_id`, `user_id`, `order_code`, `amount`, `status`, `checkout_url`, `qr_code` | Giao dịch PayOS |
| `reviews` / Review | `user_id`, `property_id`, `booking_id`, `rating`, `comment` | Đánh giá sau chuyến đi |
| `favorites` / Favorite | `user_id`, `property_id` | Danh sách yêu thích |
| `notifications` / Notification | `user_id`, `type`, `title`, `body`, `is_read` | Thông báo người dùng |
| `conversations` / Conversation | `participants`, `last_message`, `last_message_at` | Cuộc hội thoại |
| `messages` / Message | `conversation_id`, `sender_id`, `content`, `is_read` | Tin nhắn |

Quan hệ dữ liệu chính:

- Một User có thể tạo nhiều Booking, Favorite, Review và Notification.
- Một Property có nhiều Room, Booking, Review và Favorite.
- Một Room có thể xuất hiện trong nhiều Booking ở các khoảng thời gian khác nhau.
- Một Booking thuộc một User, một Property và một Room; Booking có thể liên kết với Payment và Review.
- Một Conversation có nhiều Message và danh sách người tham gia.

Việc kiểm tra phòng trống không dựa trên một biến `isAvailable` cố định. Backend lấy `quantity` của Room và trừ tổng `rooms_count` của các booking hợp lệ bị trùng khoảng ngày. Cách này phù hợp với mô hình một loại phòng có nhiều phòng vật lý giống nhau.

### 3.7. Thiết kế giao diện

Giao diện được chia theo hành trình người dùng: onboarding và xác thực; trang chủ và tìm kiếm; chi tiết khách sạn/phòng; tạo booking; thanh toán; quản lý booking; hồ sơ và thông báo. Khu vực Admin sử dụng các bảng và biểu mẫu để quản lý dữ liệu.

Ứng dụng sử dụng route tập trung trong `AppRoutes`, các widget dùng chung và helper responsive. Nội dung có hỗ trợ tiếng Việt và tiếng Anh thông qua các hàm dịch trong ứng dụng. Khi đưa vào báo cáo, nên chọn một số màn hình đại diện thay vì chụp toàn bộ giao diện.

## CHƯƠNG 4. PHÁT TRIỂN ỨNG DỤNG

### 4.1. Môi trường và cấu trúc mã nguồn

Frontend sử dụng Flutter/Dart. Backend sử dụng Node.js, Express.js và MongoDB. Trong quá trình phát triển, Backend có thể chạy cục bộ và Flutter kết nối qua địa chỉ phù hợp với trình giả lập hoặc thiết bị thật. Các giá trị nhạy cảm như chuỗi kết nối MongoDB, JWT secret, PayOS, Cloudinary, email và OpenAI được cấu hình bằng biến môi trường, không trình bày giá trị thật trong báo cáo.

Backend StayZ đã được triển khai trên nền tảng Render tại địa chỉ `https://stayz-api.onrender.com`. Ứng dụng Flutter sử dụng REST API production với đường dẫn cơ sở `https://stayz-api.onrender.com/api`. Tại thời điểm kiểm tra, endpoint health check và API danh sách khách sạn đều phản hồi thành công; Backend kết nối được MongoDB, Redis và cấu hình PayOS.

Các feature Flutter hiện có bao gồm auth, onboarding, home, search, detail, booking, booking management, favorites, profile, notification, review, chat và admin. Dữ liệu thật được truy xuất qua `ApiStayzRepository` và `ApiService`; không nên mô tả ứng dụng là chỉ dùng mock data.

### 4.2. Phát triển các chức năng phía Client

#### 4.2.1. Xác thực và hồ sơ

Các màn hình đăng ký và đăng nhập sử dụng form kiểm tra dữ liệu đầu vào. Hệ thống hỗ trợ OTP đăng ký, đăng nhập bằng email/mật khẩu, Google OAuth, quên mật khẩu và đặt lại mật khẩu. Sau khi xác thực, token và thông tin role được lưu để phục vụ các request tiếp theo. Hồ sơ cho phép cập nhật họ tên, số điện thoại, giới tính, địa chỉ và ảnh đại diện.

#### 4.2.2. Trang chủ, tìm kiếm và chi tiết

Trang chủ hiển thị thanh tìm kiếm, địa điểm và khách sạn nổi bật. Người dùng có thể tìm theo thành phố, khoảng giá và tiện nghi. API tìm kiếm sử dụng dữ liệu Property và Room, hỗ trợ chuỗi tìm kiếm đã chuẩn hóa để cải thiện tìm kiếm tiếng Việt không dấu.

Trang chi tiết hiển thị thông tin cơ sở lưu trú, hình ảnh, địa chỉ, tiện nghi, giá cơ bản, đánh giá và danh sách phòng. Người dùng chọn ngày, số khách, số phòng và loại phòng trước khi chuyển sang quy trình booking.

#### 4.2.3. Booking và thanh toán

Client tạo `BookingDraft` từ thông tin người dùng đã chọn và gửi lên Backend. Backend là nơi kiểm tra cuối cùng về ngày ở, sức chứa, số lượng phòng và giá. Booking mới được tạo ở trạng thái chờ thanh toán và có thời hạn thanh toán.

Tại bước thanh toán, người dùng có thể chọn phương án thanh toán theo chính sách của ứng dụng. Backend tạo yêu cầu PayOS và trả dữ liệu QR hoặc checkout URL. Client hiển thị mã thanh toán, theo dõi trạng thái giao dịch và cập nhật giao diện khi booking được xác nhận.

#### 4.2.4. Quản lý booking và chức năng bổ sung

Danh sách booking được phân theo trạng thái sắp tới, hoàn thành và đã hủy. Người dùng có thể xem chi tiết, tiếp tục thanh toán đối với booking còn hợp lệ, hủy booking theo chính sách và gửi đánh giá sau khi hoàn thành.

Các chức năng bổ sung gồm thêm/xóa khách sạn yêu thích, xem và đánh dấu thông báo, đổi ngôn ngữ, quản lý phương thức thanh toán ở mức giao diện, và mở trợ lý AI tìm khách sạn.

### 4.3. Phát triển Backend và API

Backend khai báo các nhóm API sau:

| Nhóm route | Chức năng chính |
|---|---|
| `/users`, `/auth` | Tài khoản, OTP, đăng nhập, refresh token, Google OAuth, hồ sơ, avatar |
| `/properties` | Danh sách, tìm kiếm, nổi bật, CRUD khách sạn, upload ảnh |
| `/room` | Danh sách phòng, phòng theo khách sạn, CRUD và upload ảnh |
| `/booking` | Danh sách, tạo, cập nhật, xóa và thay đổi trạng thái booking |
| `/payment` | Tạo thanh toán, lấy trạng thái, hủy giao dịch, webhook PayOS |
| `/review` | Xem, tạo, sửa và xóa đánh giá |
| `/favorites` | Xem, kiểm tra, thêm và xóa yêu thích |
| `/notifications` | Xem, đánh dấu đã đọc và xóa thông báo |
| `/chat` | Hội thoại và tin nhắn |
| `/ai` | Trợ lý tìm kiếm dựa trên dữ liệu StayZ |

Các API quản trị khách sạn, phòng, người dùng và payment được bảo vệ bởi `protect` và `adminOnly`. Những route booking cũng yêu cầu đăng nhập để tránh truy cập hoặc thay đổi booking của người khác.

### 4.4. Trợ lý AI

Flutter gửi nội dung trò chuyện đến `POST /ai/chat` kèm JWT. Backend phân tích ý định, thành phố, khoảng giá, tiện nghi, ngày ở và số khách. Sau đó hệ thống truy vấn Property, Room, Review và Booking để tạo context. Kết quả gợi ý được giới hạn và chỉ chứa dữ liệu tìm thấy trong MongoDB.

Nếu có OpenAI API key, Backend gửi context đã kiểm soát đến mô hình để tạo câu trả lời tự nhiên. Nếu OpenAI bị lỗi, hết thời gian chờ hoặc chưa cấu hình, hệ thống dùng hàm fallback để trả lời từ dữ liệu thật. Khi người dùng chưa cung cấp ngày nhận/trả phòng, AI không được khẳng định chắc chắn còn phòng.

### 4.5. Kiểm thử hệ thống

Phần này chỉ ghi kết quả sau khi nhóm đã chạy kiểm thử. Không nên khẳng định toàn bộ hệ thống ổn định nếu chưa có bằng chứng.

Bảng kiểm thử đề xuất:

| Mã | Chức năng | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|
| TC01 | Đăng ký và xác minh OTP | Tạo được tài khoản hợp lệ | `[ĐIỀN PASS/FAIL]` |
| TC02 | Đăng nhập | Trả token và chuyển đúng giao diện | `[ĐIỀN PASS/FAIL]` |
| TC03 | Tìm kiếm khách sạn | Trả dữ liệu đúng bộ lọc | `[ĐIỀN PASS/FAIL]` |
| TC04 | Tạo booking | Kiểm tra ngày, sức chứa và số phòng | `[ĐIỀN PASS/FAIL]` |
| TC05 | Tạo thanh toán PayOS | Hiển thị QR/checkout hợp lệ | `[ĐIỀN PASS/FAIL]` |
| TC06 | Webhook thanh toán | Cập nhật Payment và Booking | `[ĐIỀN PASS/FAIL]` |
| TC07 | Hủy booking | Cập nhật trạng thái và thông tin hoàn tiền | `[ĐIỀN PASS/FAIL]` |
| TC08 | Chức năng Admin | Chỉ Admin thao tác được | `[ĐIỀN PASS/FAIL]` |
| TC09 | AI tìm khách sạn | Chỉ gợi ý dữ liệu có trong hệ thống | `[ĐIỀN PASS/FAIL]` |

`[CHÈN ẢNH POSTMAN HOẶC KẾT QUẢ KIỂM THỬ TIÊU BIỂU]`

### 4.6. Hình ảnh kết quả

Để tiết kiệm số trang, nên ghép hai hoặc ba ảnh trên một trang và chỉ chọn các màn hình đại diện:

1. Đăng nhập/đăng ký.
2. Trang chủ và tìm kiếm.
3. Chi tiết khách sạn và lựa chọn phòng.
4. Xác nhận booking và QR PayOS.
5. Danh sách booking.
6. Dashboard Admin.
7. Trợ lý AI.

## CHƯƠNG 5. KẾT QUẢ, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN

### 5.1. Kết quả đạt được

Đề tài đã xây dựng được hệ thống StayZ theo mô hình Client–Server với các kết quả chính:

- Ứng dụng Flutter có các luồng xác thực, tìm kiếm, xem khách sạn/phòng, booking, thanh toán và quản lý lịch sử.
- Backend Express kết nối MongoDB và cung cấp API cho ứng dụng.
- Backend đã được triển khai trên Render và ứng dụng Flutter được cấu hình sử dụng API production.
- Hệ thống sử dụng JWT, bcrypt, rate limiter và middleware phân quyền.
- Quy trình booking kiểm tra số phòng theo khoảng ngày và sử dụng Redis/Redlock để hỗ trợ xử lý đồng thời.
- PayOS được tích hợp để tạo giao dịch, QR, nhận webhook và cập nhật trạng thái.
- Admin có thể quản lý người dùng, khách sạn, phòng, booking, review và payment.
- Ứng dụng có yêu thích, đánh giá, thông báo, chat và trợ lý AI dựa trên dữ liệu StayZ.

### 5.2. Đánh giá hệ thống

Hệ thống đã thể hiện được luồng nghiệp vụ chính của một ứng dụng đặt phòng khách sạn và có sự liên kết giữa giao diện, API, cơ sở dữ liệu và dịch vụ thanh toán. Việc tổ chức Flutter theo feature và Backend theo route/controller/service/model giúp mã nguồn dễ theo dõi hơn so với việc đặt toàn bộ màn hình hoặc nghiệp vụ trong một thư mục chung.

Các cơ chế JWT, phân quyền Admin, rate limiter, Redis lock và kiểm tra quyền sở hữu dữ liệu giúp hệ thống có nền tảng an toàn hơn. Tuy nhiên, mức độ ổn định cuối cùng chỉ nên được kết luận sau khi có kết quả kiểm thử đầy đủ trên Backend, trình giả lập và thiết bị thật.

### 5.3. Hạn chế

- Backend chưa có bộ automated test hoàn chỉnh; script test hiện chưa thực thi test nghiệp vụ.
- Chưa có đủ bằng chứng kiểm thử trên iOS và nhiều kích thước thiết bị.
- Thanh toán phụ thuộc cấu hình PayOS, webhook và môi trường triển khai.
- Hoàn tiền chưa được xác nhận là tự động chuyển tiền qua PayOS; hệ thống hiện có các trường ghi nhận quá trình xử lý.
- Các dịch vụ Cloudinary, email, Redis và OpenAI phụ thuộc vào kết nối mạng và biến môi trường.
- AI mới tập trung hỗ trợ tìm kiếm/đề xuất; chưa tự động hoàn tất booking thay người dùng và vẫn yêu cầu người dùng xác nhận qua luồng đặt phòng hiện có.
- Chưa có số liệu kiểm thử tải, hiệu năng và đánh giá bảo mật chuyên sâu.

### 5.4. Hướng phát triển

- Bổ sung unit test, integration test và kiểm thử API tự động cho Backend.
- Kiểm thử và tối ưu giao diện trên nhiều thiết bị Android/iOS.
- Hoàn thiện quy trình hoàn tiền và đối soát giao dịch PayOS.
- Bổ sung giám sát lỗi, logging và cảnh báo trong môi trường triển khai.
- Mở rộng AI để hiểu yêu cầu đặt phòng tốt hơn nhưng vẫn yêu cầu người dùng xác nhận trước khi tạo booking.
- Nâng cấp thông báo thời gian thực và chức năng chat hỗ trợ khách hàng.
- Bổ sung thống kê doanh thu, tỷ lệ lấp đầy phòng và báo cáo quản trị.

## GHI CHÚ KHI ĐƯA VÀO WORD

- Không đưa các giá trị thật trong file `.env` vào báo cáo hoặc ảnh chụp.
- Chỉ giữ ba sơ đồ chính trong nội dung; chuyển sơ đồ phụ xuống phụ lục nếu cần.
- Chương 2 nên giữ ngắn, tránh viết lại lý thuyết chung dài dòng.
- Chương 3 cần dùng đúng `properties`, `property_id`, `room_id`, `user_id`, `booking_id` và các field snake_case trong source.
- Chương 4.5 phải điền kết quả kiểm thử thật trước khi nộp.
- Với font Times New Roman 13, giãn dòng 1.3–1.5 và lề báo cáo thông thường, nội dung này cần tiếp tục dàn trang cùng hình ảnh để kiểm soát mục tiêu khoảng 17 trang.
