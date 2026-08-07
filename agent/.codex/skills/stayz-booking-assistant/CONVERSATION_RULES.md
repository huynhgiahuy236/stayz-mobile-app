# Conversation Rules

## State updates

1. Never ask for a value already provided and still valid.
2. Replace an older value when the user supplies a newer conflicting value.
3. Preserve non-conflicting criteria across turns within the active supported conversation scope.
4. Track provenance per value: `explicit`, `inferred`, or `default-suggested`.
5. Ask only for missing information required for the next operation.
6. Keep a compact current-intent summary after material changes.
7. Confirm ambiguous relative dates, locale-dependent dates, and conflicts between dates and duration.
8. Never convert “3 ngày 2 đêm” into exact dates without check-in.
9. Do not claim permanent memory. Do not carry preferences beyond the conversation/session contract actually supported.
10. If history is unavailable, state that context was not retained and ask only for essentials.

## Question priority

Ask in this order when necessary: destination -> check-in -> check-out or nights -> total guests -> rooms. Amenities and budget are optional unless the user makes them hard constraints.

## Multi-turn examples

### Duration without date

User: “Phòng ở Vũng Tàu, 2 người lớn, có hồ bơi, 3 ngày 2 đêm.”

State: destination=Vũng Tàu explicit; adults=2 explicit; outdoor_pool explicit; stayDays=3/stayNights=2 explicit; dates missing.

Assistant: “Bạn cần Vũng Tàu cho 2 người lớn, ưu tiên hồ bơi, ở 2 đêm. Bạn muốn nhận phòng ngày nào?”

### User correction

User: “Thực ra 3 người lớn.”

Update adults from 2 to 3; preserve destination, amenity and duration. Do not ask destination again.

Assistant: “Đã cập nhật thành 3 người lớn. Bạn muốn nhận phòng ngày nào?”

### Conflicting dates

User: “Nhận 20/8, trả 22/8, nhưng ở 3 đêm.”

Do not choose silently. Ask: “Ngày 20–22/8 là 2 đêm, khác với yêu cầu 3 đêm. Bạn muốn trả phòng 22/8 hay ở đủ 3 đêm đến 23/8?”

