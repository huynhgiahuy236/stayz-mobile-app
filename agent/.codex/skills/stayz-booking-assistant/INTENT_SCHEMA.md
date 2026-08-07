# Booking Intent Schema

Use this conceptual schema for conversation state. It is documentation, not an implemented DTO. `Explicit` values come from the user; `Inferred` values must be shown and confirmed when consequential.

| Field | Type | Req. to recommend | Meaning and validation | Inference / confirmation | StayZ mapping |
|---|---|---:|---|---|---|
| destination | string? | Usually | City or area; normalize accents and aliases without changing meaning | Alias inference allowed; confirm ambiguous place | `Property.city`, `Property.address`; `SearchFilters.city/keyword` — Source-confirmed |
| hotelId | string? | No | Selected property identifier | Never invent; set only from returned data | `property_id`, `Hotel.id` — Source-confirmed |
| roomId | string? | No | Selected room identifier | Never infer before a room is selected | `room_id`, `Room.id` — Source-confirmed |
| checkIn | ISO date? | For availability | Must be a valid non-past date under backend rules | Never derive from duration; confirm relative/ambiguous date | `check_in`, `RoomSelectionArgs.checkInDate` — Source-confirmed |
| checkOut | ISO date? | For availability | Must be later than checkIn | May derive from confirmed checkIn + stayNights; show result | `check_out`, `RoomSelectionArgs.checkOutDate` — Source-confirmed |
| stayDays | integer? | No | User-described calendar-day duration | Preserve wording; do not treat as exact date | No direct field — Not confirmed |
| stayNights | integer? | For derivation | Positive count of charged nights | May parse “2 đêm”; confirm conflicts | `BookingDraft.nights`, booking `nights` — Source-confirmed |
| adults | integer? | Yes | Adult guests, >=1 for typical request | Use only explicit/context value; confirm default before transaction | Flutter split field; backend combines into `guests` — Partially mapped |
| children | integer? | No | Child guests, >=0 | Unknown is not automatically zero unless UI default is disclosed | Flutter `children`; backend combines into `guests` — Source-confirmed |
| infants | integer? | No | Infant count, >=0 | Never merge silently into children | Not confirmed |
| rooms | integer? | For capacity | Requested room count, >=1 | A suggested default of 1 must be editable | `roomCount`, `rooms_count` — Source-confirmed |
| budgetMin | number? | No | Minimum preferred price, >=0 | Never infer | Search supports no min in Flutter filter — Not confirmed end-to-end |
| budgetMax | number? | No | Maximum total or nightly budget; clarify basis | Never infer currency/basis | `SearchFilters.maxPrice`, API `maxPrice` — Source-confirmed for maximum |
| currency | string? | No | ISO-like currency code | Default VND may be suggested from current app; disclose | Flutter/API adapters use `VND` — Source-confirmed |
| amenities | string[] | No | Requested property/room amenities | Normalize synonyms; preserve unknown items | Property/room `amenities`; search amenities — Source-confirmed |
| roomType | string? | No | Standard/deluxe/suite preference | Map only to supported enum | `Room.room_type` — Source-confirmed |
| bedType | string? | No | Bed arrangement | Do not infer from room type | `Room.bed_info` — Source-confirmed |
| view | string? | No | Desired room view | Normalize only after matching known values | `Room.view` — Source-confirmed |
| rating | number? | No | Minimum rating preference | Do not fabricate; current source contains a synthetic summary rating risk | Reliable persisted mapping — Not confirmed |
| cancellationPreference | string? | No | Flexible/non-refundable preference | Requires explicit choice for paid/non-refundable conditions | Not confirmed |
| breakfastPreference | boolean? | No | Breakfast required/preferred | May map only at property level | `Property.amenities.breakfast` — Source-confirmed |
| specialRequests | string[] | No | Free-form needs | Preserve verbatim; do not promise fulfillment | Flutter `BookingDraft.specialRequest`; backend booking persistence — Not confirmed |

## Derived values

- Derive `checkOut = checkIn + stayNights` only after `checkIn` is explicit or confirmed.
- Treat “3 ngày 2 đêm” as `stayDays=3`, `stayNights=2`, with both exact dates missing.
- Validate total guests against `Room.capacity * rooms`; Flutter currently represents adult/child capacity separately after adapting one backend capacity value.
- Revalidate mapping and semantics at implementation time; do not serialize this conceptual schema directly without a confirmed DTO.

