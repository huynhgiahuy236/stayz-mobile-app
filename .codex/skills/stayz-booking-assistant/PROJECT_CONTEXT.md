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

- **Source-confirmed** — `ApiStayzRepository` implements hotel search, room lookup by property and optional dates, booking creation/status update, favorites, and reviews. File: `lib/shared/repositories/stayz_repository.dart`.
- **Source-confirmed** — Search calls `GET /properties/search`; room lookup calls `GET /room/:hotelId` with optional `checkIn/checkOut`; booking creation calls `POST /booking/create`.
- **Source-confirmed** — `ApiService` supports GET, POST, DELETE and PATCH using `STAYZ_API_BASE_URL`. File: `lib/services/api_service.dart`.
- **Source-confirmed** — `AuthService` supplies access token and user ID. File: `lib/services/auth_service.dart`.

## Relevant screens and routes

- **Source-confirmed** — Search results: `SearchPage`, route `/search`. File: `lib/features/search/presentation/pages/search_page.dart`.
- **Source-confirmed** — Room detail: `RoomDetailPage`, route `/room-detail`. File: `lib/features/detail/presentation/pages/room_detail_page.dart`.
- **Source-confirmed** — Room selection: `RealRoomSelectionPage`, route `/room-selection`. File: `lib/features/booking/presentation/pages/room_selection_real_page.dart`.
- **Source-confirmed** — Booking detail/schedule: `BookingSchedulePage`, route `/booking-schedule`. File: `lib/features/booking/presentation/pages/booking_schedule_page.dart`.
- **Source-confirmed** — Payment review: `PaymentCheckoutPage`, route `/payment-checkout`. File: `lib/features/booking/presentation/pages/payment_checkout_page.dart`.
- **Source-confirmed** — Completion: `BookingConfirmationPage`, route `/booking-confirmation`.
- **Source-confirmed** — AI UI currently exists as `AiChatSheet` and posts to `/ai/chat` with optional context. File: `lib/features/chat/ai_chat_sheet.dart`.

## Backend and database fields

- **Source-confirmed** — Property fields include `_id`, `title`, `city`, `address`, `latitude`, `longitude`, `type`, `base_price`, `amenities`, image fields, `is_preferred`, and `max_stay_days`. File: `backend/stayz_api/src/models/properties.model.js`.
- **Source-confirmed** — Property amenities include `outdoor_pool`, `free_wifi`, `airport_shuttle`, `non_smoking_room`, `room_service`, `restaurant`, `free_parking`, `family_room`, `bar`, and `breakfast`.
- **Source-confirmed** — Room fields include `_id`, `property_id`, `name`, `room_type`, `price`, `original_price`, `discount_percent`, `capacity`, `quantity`, `bed_info`, `area`, `view`, `badges`, `amenities`, images, and `is_active`. File: `backend/stayz_api/src/models/rooms.model.js`.
- **Source-confirmed** — Booking fields include `user_id`, `property_id`, `room_id`, `check_in`, `check_out`, `guests`, `rooms_count`, `nights`, `price_per_night`, `total_price`, `status`, and `payment_status`. File: `backend/stayz_api/src/models/bookings.model.js`.
- **Source-confirmed** — Booking convention is night-based: check-out must be after check-in, `nights >= 1`, and totals are derived from nights. Files: booking model/service and `booking_flow_models.dart`.

## AI integration snapshot

- **Source-confirmed** — Protected backend endpoint `POST /ai/chat` exists. Files: `backend/stayz_api/src/routes/ai.router.js`, `rootRouter.router.js`, and `ai.controller.js`.
- **Source-confirmed** — `.env.example` declares `OPENAI_API_KEY` and `OPENAI_MODEL`; configured runtime values are not verified.
- **Potentially relevant** — `backend/stayz_api/src/services/ai.service.js` already queries real properties, rooms, reviews and overlapping bookings. Its exact output contract must be reviewed before extending navigation recommendations.
- **Not confirmed** — Structured recommendation cards or a stable machine-readable booking-intent response contract from `/ai/chat`.
- **Not confirmed** — Analytics, privacy retention policy, permanent conversation memory, deep-link contract, and automated end-to-end test coverage.

