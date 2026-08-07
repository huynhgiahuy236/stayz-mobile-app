# Navigation Contract

This is conceptual documentation only. Do not implement or introduce a duplicate booking flow.

## Existing flow

**Source-confirmed:** `/search` -> `/room-detail` or `/room-selection` -> `/booking-schedule` -> `/payment-checkout` -> `/booking-confirmation`.

The best target depends on selection state:

- Property selected, room not selected: target `/room-selection` with `RoomSelectionArgs`.
- Property and room selected with valid dates: target `/booking-schedule` with a validated `BookingDraft` only after current constructors/contracts are rechecked.
- Search criteria only: target `/search` with `SearchFilters`; note that dates and guests are not represented in `SearchFilters` today.

## Conceptual payload

```json
{
  "hotelId": null,
  "roomId": null,
  "destination": "Vũng Tàu",
  "checkIn": null,
  "checkOut": null,
  "adults": 2,
  "children": null,
  "rooms": 1,
  "amenities": ["outdoor_pool"],
  "source": "ai_booking_assistant"
}
```

Mappings: `hotelId -> Hotel.id/property_id`, `roomId -> Room.id/room_id`, dates and guest counts -> `RoomSelectionArgs`/`BookingDraft`, rooms -> `roomCount/rooms_count`. `source` has no confirmed project field.

## Contract requirements

- Validate that IDs came from current API results.
- Require authentication before protected AI history and booking creation; never bypass `AuthGate`/`AuthService`.
- Allow every prefilled date, guest count, room count and optional preference to be edited.
- Recheck capacity, availability and price before entering checkout and again before submission where supported.
- On missing dates, open a screen that can collect them; do not construct an invalid `BookingDraft`.
- Back navigation should return to the recommendation context without creating duplicate booking stacks.
- Restore current intent after temporary auth only if supported; otherwise explain that it must be re-entered.
- On stale inventory, show a grounded failure and return to room/recommendation selection.
- On route or argument mismatch, fail safely; do not fall through to booking creation.

## Implemented adapter (Source-confirmed 2026-07-10)

`/ai/chat` returns a machine-readable `suggestions` array (`{ property, room }`). The Flutter chat sheet (`lib/features/chat/ai_chat_sheet.dart`) renders each suggestion as a grounded card and, on selection, revalidates the property ID against `ApiStayzRepository.getHotelSummaries()` before pushing `/room-selection` with an editable `RoomSelectionArgs` (dates/guests from chat context, room count suggested as 1). Stale IDs produce a grounded in-chat failure instead of navigation. The chat sheet remains below the pushed route, so back returns to the recommendation context.

## Unconfirmed contract items

- Deep-link entry route for the assistant.
- Cross-route restoration of conversation state after re-authentication.
- Analytics source attribution for `ai_booking_assistant`.

