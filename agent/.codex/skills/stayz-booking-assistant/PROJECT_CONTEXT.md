# Project Context

Snapshot: 2026-07-10. Reverify before implementation.

## Architecture and state

- **Source-confirmed** — Flutter app entry uses `MaterialApp`, `initialRoute: AppRoutes.authGate`, and `AppRoutes.routes`. File: `lib/app/app.dart`; class: `StayZApp`.
- **Source-confirmed** — Navigation uses Flutter named routes and `Navigator.pushNamed`, `pushReplacementNamed`, and `pushNamedAndRemoveUntil`. File: `lib/app/routes/app_routes.dart`; class: `AppRoutes`.
- **Source-confirmed** — Inspected feature screens use local `StatefulWidget`/`setState` plus singleton services/repository. No Provider, Riverpod, Bloc, Cubit, or GoRouter dependency was found in `pubspec.yaml`. This describes inspected code, not a formal architecture guarantee.
- **Source-confirmed** — Primary layers are `lib/features`, `lib/shared/models`, `lib/shared/repositories`, and `lib/services`; backend is `backend/stayz_api/src` with routes/controllers/services/models.

## Relevant Flutter models

- **Source-confirmed** — `Hotel`, `Room`, `Booking`, `BookingGuests`, `HotelSummary`, and `BookingSummary`. File: `lib/shared/models/stayz_models.dart`.
- **Source-confirmed** — `RoomSelectionArgs` contains `hotel`, optional `checkInDate/checkOutDate`, `adults`, `children`, and `roomCount`. File: `lib/shared/models/booking_flow_models.dart`.
- **Source-confirmed** — `BookingDraft` contains required hotel, room and dates plus adults, children, roomCount, specialRequest, paymentMethod, and datesLocked. It calculates `nights` with `StayzFormatters.nightsBetween`. Same file.
- **Source-confirmed** — Search uses `SearchFilters(keyword, city, type, maxPrice, amenities, isPreferred)`. File: `lib/shared/repositories/stayz_repository.dart`; class: `SearchFilters`.
- **Not confirmed** — A dedicated persistent AI booking-intent model does not appear in the inspected Flutter model files.

## Repository and services

- **Source-confirmed** — `ApiStayzRepository` implements hotel search, room lookup by property and optional dates, booking creation/status update, favorites, reviews, and notifications. File: `lib/shared/repositories/stayz_repository.dart`.
- **Source-confirmed** — Search calls `GET /properties/search`; room lookup calls `GET /room/:hotelId` with optional `checkIn/checkOut`; booking creation calls `POST /booking/create`.
- **Source-confirmed** — `GET /properties/getAll` and `GET /properties/search` now return each property enriched with `rating` (real review average, `null` when no reviews), `review_count`, `min_price`, `max_price`, `max_capacity`, `available_rooms`, and `room_types`. The client no longer fetches `/room/getAll` to join prices, and `HotelSummary.rating` is nullable.
- **Source-confirmed** — `GET /properties/search` accepts `keyword` (accent-insensitive, typo-tolerant via `src/helpers/search.helper.js`), `city`, `nearBeach`, `type`, `roomType`, `minPrice`/`maxPrice` (compared against the lowest **room** price, not `base_price`), `guests`, `amenities`, `isPreferred`.
- **Source-confirmed** — All `/booking` routes require a Bearer token; `user_id` is derived from the token, ownership is enforced on status change/update/delete, and only `pending`/`confirmed` may be set at creation time.
- **Source-confirmed** — Password reset requires a valid OTP: `POST /users/request-password-reset` → `POST /users/verify-reset-code` → `POST /users/reset-password` with `{email, code, newPassword}`.
- **Source-confirmed** — `ApiService` supports GET, POST, DELETE and PATCH using `STAYZ_API_BASE_URL`, with an 8s connect / 20s request timeout, and throws `ApiException` carrying a user-facing Vietnamese message. File: `lib/services/api_service.dart`.
- **Source-confirmed** — `AuthService` supplies access token and user ID, checks JWT expiry, and clears `BookingCache` on login/logout. File: `lib/services/auth_service.dart`.
- **Source-confirmed** — Property images are hosted by the backend at `/images/properties/<slug>/<file>` (`server.js` serves `src/images` statically) and resolved by `ApiService.resolveAssetUrl`.

## Relevant screens and routes

- **Source-confirmed** — Search results: `SearchPage`, route `/search`. File: `lib/features/search/presentation/pages/search_page.dart`.
- **Source-confirmed** — Room detail: `RoomDetailPage`, route `/room-detail`. File: `lib/features/detail/presentation/pages/room_detail_page.dart`.
- **Source-confirmed** — Room selection: `RealRoomSelectionPage`, route `/room-selection`. File: `lib/features/booking/presentation/pages/room_selection_real_page.dart`.
- **Source-confirmed** — Booking detail/schedule: `BookingSchedulePage`, route `/booking-schedule`. File: `lib/features/booking/presentation/pages/booking_schedule_page.dart`.
- **Source-confirmed** — Payment review: `PaymentCheckoutPage`, route `/payment-checkout`. File: `lib/features/booking/presentation/pages/payment_checkout_page.dart`.
- **Source-confirmed** — Completion: `BookingConfirmationPage`, route `/booking-confirmation`.
- **Source-confirmed** — AI UI exists as a modal sheet (`showAiChatSheet`/`_AiChatSheet`) that posts to `/ai/chat` with optional context, renders returned `suggestions` as grounded recommendation cards, and navigates to `/room-selection` with an editable `RoomSelectionArgs` prefill after revalidating the property ID against current repository data. File: `lib/features/chat/ai_chat_sheet.dart`. Entry points: home page, room detail, room selection.

## Backend and database fields

- **Source-confirmed** — Property fields include `_id`, `title`, `city`, `address`, `latitude`, `longitude`, `type`, `base_price`, `amenities`, image fields, `is_preferred`, and `max_stay_days`. File: `backend/stayz_api/src/models/properties.model.js`.
- **Source-confirmed** — Property amenities include `outdoor_pool`, `free_wifi`, `airport_shuttle`, `non_smoking_room`, `room_service`, `restaurant`, `free_parking`, `family_room`, `bar`, and `breakfast`.
- **Source-confirmed** — Room fields include `_id`, `property_id`, `name`, `room_type`, `price`, `original_price`, `discount_percent`, `capacity`, `quantity`, `bed_info`, `area`, `view`, `badges`, `amenities`, images, and `is_active`. File: `backend/stayz_api/src/models/rooms.model.js`.
- **Source-confirmed** — Booking fields include `user_id`, `property_id`, `room_id`, `check_in`, `check_out`, `guests`, `rooms_count`, `nights`, `price_per_night`, `total_price`, `status`, and `payment_status`. File: `backend/stayz_api/src/models/bookings.model.js`.
- **Source-confirmed** — Booking convention is night-based: check-out must be after check-in, `nights >= 1`, and totals are derived from nights. Files: booking model/service and `booking_flow_models.dart`.

## AI integration snapshot

- **Source-confirmed** — Protected backend endpoint `POST /ai/chat` exists. Files: `backend/stayz_api/src/routes/ai.router.js`, `rootRouter.router.js`, and `ai.controller.js`.
- **Source-confirmed** — `.env.example` declares `OPENAI_API_KEY` and `OPENAI_MODEL`; configured runtime values are not verified.
- **Source-confirmed** — `backend/stayz_api/src/services/ai.service.js` queries real properties, rooms, reviews and overlapping bookings, and returns a structured JSON contract: `{ success, reply, conversationId, intent, suggestions }`. `reply` is natural language; `suggestions` is up to 3 grounded `{ property, room }` objects where `property` includes `id/title/city/address/base_price/amenities/rating (real review average or null)/review_count` and `room` includes `id/name/room_type/price_per_night/capacity/available_rooms (null when dates missing)/total_price/amenities/badges`.
- **Source-confirmed** — Conversation persistence exists: `conversations.model.js` and `messages.model.js` store history, `conversationId` round-trips, and an assistant user (`ai-assistant@stayz.local`) is auto-created. A separate `/chat` router also exists (`chat.router.js`), distinct from `/ai`.
- **Not confirmed** — Analytics, privacy retention policy, deep-link contract, and automated end-to-end test coverage.

