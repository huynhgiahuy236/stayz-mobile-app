# Recommendation Rules

Use only records returned by current StayZ APIs/repositories. Return at most five results.

## Constraint classes

- **Hard constraints:** selected property/room ID, destination when stated as mandatory, valid dates, actual availability, guest capacity, room count, active inventory, explicit maximum budget, and explicit must-have amenity.
- **Soft preferences:** preferred property type, rating, view, breakfast, cancellation flexibility, popularity, and amenities phrased as preferences.
- **Unknown criteria:** fields absent from the conversation. Do not filter or score them.
- **Relaxable filters:** only user-approved soft preferences or hard constraints the user explicitly allows to relax.

## Filtering order

1. Validate dates and guest/room counts.
2. Filter active properties/rooms and destination.
3. Recheck overlapping bookings for the requested range.
4. Enforce capacity and room quantity.
5. Enforce hard amenities and budget.
6. Rank survivors by destination precision, availability confidence, capacity fit, requested amenities, budget fit, real review evidence, and remaining soft preferences.

## Grounding rules

- **Resolved 2026-07-10** — the constant `HotelSummary.rating: 4.7` is gone. The backend now aggregates real review scores and returns `rating` (`null` when a property has no reviews) plus `review_count`. Never display a rating when `rating` is `null`; show "chưa có đánh giá" instead.
- Treat availability as unknown when exact dates are missing.
- Display the returned/current price basis clearly (for example, per night). Recheck before booking review.
- Do not claim distance unless coordinates and a confirmed distance calculation are available.
- Do not claim cancellation or breakfast terms without corresponding real fields.

## Result format

For each result include real IDs internally, property/room name, returned price and basis, capacity, availability confidence, matched criteria, unmet/unknown criteria, and one short reason such as: “Khớp Vũng Tàu, đủ chỗ cho 2 khách và có hồ bơi; cần ngày nhận phòng để xác nhận còn phòng.”

If there are no matches, say which hard constraints removed results and offer one relaxation at a time. Never fabricate a fallback hotel.

