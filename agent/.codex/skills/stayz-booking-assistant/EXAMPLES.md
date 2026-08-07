# Vietnamese Examples

All payloads are conceptual and must be mapped to current source before implementation.

## 1. Destination, guests, amenity, duration

- User: “Phòng ở Vũng Tàu, 2 người lớn, có hồ bơi, 3 ngày 2 đêm.”
- Intent: destination=Vũng Tàu; adults=2; amenities=[outdoor_pool]; stayDays=3; stayNights=2.
- Missing: checkIn, exact checkOut; children and rooms remain unknown/default-suggested.
- Response: “Bạn cần phòng ở Vũng Tàu cho 2 người lớn, có hồ bơi, ở 2 đêm. Bạn muốn nhận phòng ngày nào?”
- Next: ask check-in. Payload: none.

## 2. Exact dates

- User: “Vũng Tàu từ 20/08/2026 đến 22/08/2026, 2 người.”
- Intent: destination=Vũng Tàu; checkIn=2026-08-20; checkOut=2026-08-22; stayNights=2; adults=2.
- Missing: rooms may be suggested as 1 and confirmed in UI.
- Response: summarize, search real inventory, show up to five grounded results.
- Next: select property/room.
- Payload: `{destination:"vung-tau",checkIn:"2026-08-20",checkOut:"2026-08-22",adults:2,rooms:1}`.

## 3. Missing check-in

- User: “Cho mình phòng 2 đêm tuần sau.”
- Intent: stayNights=2; “tuần sau” ambiguous.
- Missing: destination, exact checkIn.
- Response: “Bạn muốn ở khu vực nào và nhận phòng ngày cụ thể nào trong tuần sau?”
- Next: clarify; no navigation.

## 4. Budget

- User: “Đà Nẵng dưới 1.500.000 đồng một đêm, 2 khách.”
- Intent: destination=Đà Nẵng; budgetMax=1500000; currency=VND; budget basis=per-night; adults=2.
- Missing: dates.
- Response: ask check-in before confirming availability; price-only browsing may be offered with availability unknown.

## 5. No matching result

- User: “Vũng Tàu, 8 khách, 1 phòng, có hồ bơi, tối đa 500 nghìn.”
- Intent: all stated values are hard unless user says otherwise.
- Response: “Không có phòng thực tế đáp ứng đồng thời 8 khách, 1 phòng, hồ bơi và mức 500.000đ. Bạn muốn tăng số phòng hay điều chỉnh ngân sách?”
- Next: relax one user-approved constraint; never invent results.

## 6. Guest count changes

- Prior: adults=2, Vũng Tàu, 2 nights.
- User: “Đổi thành 3 người lớn và 1 trẻ em.”
- Intent update: adults=3; children=1; preserve location/duration.
- Response: confirm update and revalidate capacity/availability.

## 7. Destination changes

- Prior: Đà Lạt, dates confirmed.
- User: “Chuyển sang Đà Nẵng nhé.”
- Intent update: replace destination only; preserve dates and guests.
- Response: rerun real search; explain if other preferences no longer match.

## 8. User chooses a recommendation

- User: “Chọn khách sạn thứ 2.”
- Intent: set hotelId only from result 2's real ID; preserve prior criteria.
- Response: “Mình sẽ mở danh sách phòng của khách sạn này với thông tin đã chọn để bạn kiểm tra và chỉnh sửa.”
- Next: navigate to `/room-selection`.
- Payload: `{hotelId:"<real-id>",checkIn:"2026-08-20",checkOut:"2026-08-22",adults:2,children:0,rooms:1,source:"ai_booking_assistant"}`.

## 9. Ambiguous date

- User: “Đi thứ sáu tới.”
- Missing: exact date and possibly destination.
- Response: “Bạn muốn nói thứ Sáu ngày 17/07/2026 phải không?” Use the actual current locale date at runtime; never hard-code this example's date.

## 10. Conflicting requirements

- User: “Nhận 20/8, trả 22/8 nhưng ở 3 đêm.”
- Conflict: dates imply 2 nights; stated duration is 3 nights.
- Response: “20–22/8 là 2 đêm. Bạn muốn trả ngày 22/8 hay ở đủ 3 đêm đến 23/8?”
- Next: await explicit resolution; no search requiring exact dates and no navigation.

