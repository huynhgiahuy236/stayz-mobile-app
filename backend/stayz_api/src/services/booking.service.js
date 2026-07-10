const { BadRequestException } = require("../helpers/error.helper");
const bookingModel = require("../models/bookings.model");
const roomsModel = require("../models/rooms.model");
const redis = require("../config/redis.config");
const { default: Redlock } = require("redlock");
const notificationsService = require("./notifications.service");

const redlock = new Redlock([redis], {
  retryCount: 3,       // thử lại 3 lần nếu lock đang bị giữ
  retryDelay: 200,     // chờ 200ms giữa mỗi lần thử
  retryJitter: 50,     // jitter ngẫu nhiên để tránh thundering herd
});

const activeStatus = ["pending", "confirmed"];
const allStatus = ["pending", "confirmed", "completed", "cancelled"];
const EDIT_LOCK_HOURS = 24;

const parseDate = (value, label) => {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    throw new BadRequestException(`${label} khong hop le`);
  }
  return date;
};

const calculateNights = (checkIn, checkOut) => {
  const millisecondsPerDay = 1000 * 60 * 60 * 24;
  const rawNights = Math.ceil((checkOut - checkIn) / millisecondsPerDay);
  return Math.max(1, rawNights);
};

const getStartOfToday = () => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return today;
};

const populateBooking = (query) =>
  query
    .populate("user_id", "full_name email avatar role")
    .populate({
      path: "property_id",
      populate: {
        path: "user_id",
        select: "full_name email avatar role",
      },
    })
    .populate("room_id");

const autoCompleteExpiredBookings = async (userId = null) => {
  const now = new Date();
  const query = {
    status: { $in: ["pending", "confirmed"] },
    check_out: { $lt: now },
  };
  if (userId) query.user_id = userId;
  await bookingModel.updateMany(query, { $set: { status: "completed" } });
};

const getOverlappingBookedRooms = async ({
  roomId,
  checkIn,
  checkOut,
  excludeBookingId = null,
}) => {
  const query = {
    room_id: roomId,
    status: { $in: activeStatus },
    check_in: { $lt: checkOut },
    check_out: { $gt: checkIn },
  };

  if (excludeBookingId) {
    query._id = { $ne: excludeBookingId };
  }

  const overlappingBookings = await bookingModel.find(query).select("rooms_count");

  return overlappingBookings.reduce(
    (total, booking) => total + (Number(booking.rooms_count) || 0),
    0,
  );
};

const validateDateRange = (checkIn, checkOut) => {
  const today = getStartOfToday();
  const normalizedCheckIn = new Date(checkIn);
  normalizedCheckIn.setHours(0, 0, 0, 0);

  if (normalizedCheckIn < today) {
    throw new BadRequestException("Ngay check_in khong duoc nho hon ngay hien tai");
  }

  if (checkOut <= checkIn) {
    throw new BadRequestException("Ngay check_out phai lon hon check_in");
  }
};

const acquireBookingLock = async (lockKey) => {
  try {
    return await redlock.acquire([lockKey], 5000);
  } catch (err) {
    console.warn("Booking lock skipped:", err.message);
    return null;
  }
};

const bookingService = {
  getAll: async () => {
    await autoCompleteExpiredBookings();
    return await populateBooking(bookingModel.find());
  },
  getByUserId: async (userId) => {
    await autoCompleteExpiredBookings(userId);
    return await populateBooking(bookingModel.find({ user_id: userId }));
  },
  create: async (data) => {
    const { user_id, property_id, room_id, check_in, check_out } = data;
    if (!user_id || !property_id || !room_id || !check_in || !check_out) {
      throw new BadRequestException("Thieu thong tin bat buoc khi dat phong");
    }

    const room = await roomsModel.findById(room_id);
    if (!room) {
      throw new BadRequestException("Phong khong ton tai");
    }

    if (
      property_id &&
      room.property_id?.toString() !== property_id.toString()
    ) {
      throw new BadRequestException("Phong khong thuoc cho nghi da chon");
    }

    const roomsCount = Number(data.rooms_count) || 1;
    if (roomsCount < 1) {
      throw new BadRequestException("So luong phong khong hop le");
    }

    const checkInDate = parseDate(check_in, "Ngay check_in");
    const checkOutDate = parseDate(check_out, "Ngay check_out");
    validateDateRange(checkInDate, checkOutDate);

    // Distributed Lock: chỉ 1 request xử lý tại một thời điểm cho cùng phòng + ngày
    const lockKey = `lock:room:${room._id}:${checkInDate.toISOString()}:${checkOutDate.toISOString()}`;
    let lock;
    try {
      lock = await acquireBookingLock(lockKey); // giữ lock tối đa 5 giây
    } catch {
      throw new BadRequestException("Hệ thống đang xử lý yêu cầu khác cho phòng này. Vui lòng thử lại.");
    }

    try {
      const bookedRooms = await getOverlappingBookedRooms({
        roomId: room._id,
        checkIn: checkInDate,
        checkOut: checkOutDate,
      });
      const availableRooms = (Number(room.quantity) || 0) - bookedRooms;

      if (availableRooms < roomsCount) {
        throw new BadRequestException("So luong phong khong du");
      }

      const nights = calculateNights(checkInDate, checkOutDate);
      const pricePerNight = Number(room.price) || 0;
      const totalPrice = pricePerNight * nights * roomsCount;
      const maxGuests = (Number(room.capacity) || 1) * roomsCount;

      const requestGuests = Number(data.guests);
      const guests =
        Number.isFinite(requestGuests) && requestGuests > 0
          ? requestGuests
          : maxGuests;

      if (guests > maxGuests) {
        throw new BadRequestException("So khach vuot qua suc chua phong");
      }

      const status = allStatus.includes(data.status) ? data.status : "pending";

      const booking = await bookingModel.create({
        user_id,
        property_id,
        room_id,
        check_in: checkInDate,
        check_out: checkOutDate,
        guests,
        rooms_count: roomsCount,
        nights: nights,
        price_per_night: pricePerNight,
        total_price: totalPrice,
        status,
        payment_status: status === "confirmed" ? "paid" : "pending",
      });

      return await populateBooking(bookingModel.findById(booking._id));
    } finally {
      // Luôn giải phóng lock dù thành công hay lỗi
      if (lock) await lock.release();
    }
  },
  updateStatus: async (bookingId, status) => {
    const booking = await bookingModel.findById(bookingId);

    if (!booking) {
      throw new BadRequestException("Booking khong ton tai");
    }

    const room = await roomsModel.findById(booking.room_id);

    if (!room) {
      throw new BadRequestException("Phong khong ton tai");
    }

    if (!allStatus.includes(status)) {
      throw new BadRequestException("Trang thai booking khong hop le");
    }

    if (!activeStatus.includes(booking.status) && activeStatus.includes(status)) {
      const bookedRooms = await getOverlappingBookedRooms({
        roomId: room._id,
        checkIn: booking.check_in,
        checkOut: booking.check_out,
        excludeBookingId: booking._id,
      });
      const availableRooms = (Number(room.quantity) || 0) - bookedRooms;

      if (availableRooms < booking.rooms_count) {
        throw new BadRequestException("So luong phong khong du");
      }
    }

    booking.status = status;
    await booking.save();

    // Tự động tạo thông báo cho user khi trạng thái booking thay đổi
    const statusMessages = {
      confirmed: { title: "Booking đã được xác nhận! 🎉", body: `Booking #${booking._id} của bạn đã được xác nhận thành công.` },
      completed:  { title: "Chúc bạn có chuyến đi vui vẻ! ✈️", body: `Booking #${booking._id} đã hoàn thành. Hãy để lại đánh giá của bạn nhé!` },
      cancelled:  { title: "Booking đã bị hủy", body: `Booking #${booking._id} đã bị hủy.` },
      pending:    { title: "Booking đang chờ xác nhận ⏳", body: `Booking #${booking._id} đang được xử lý.` },
    };
    const msg = statusMessages[status];
    if (msg) {
      notificationsService.createInternal({
        userId: booking.user_id,
        type: "booking_status",
        title: msg.title,
        body: msg.body,
        refId: booking._id,
        refType: "Booking",
      }).catch(() => {}); // fire-and-forget, không block response
    }

    return await populateBooking(bookingModel.findById(booking._id));
  },
  update: async (bookingId, data) => {
    const booking = await bookingModel.findById(bookingId);

    if (!booking) {
      throw new BadRequestException("Booking khong ton tai");
    }

    const now = new Date();
    const editDeadline = new Date(booking.check_in);
    editDeadline.setHours(editDeadline.getHours() - EDIT_LOCK_HOURS);
    if (now > editDeadline) {
      throw new BadRequestException("Chi duoc chinh sua booking truoc check-in it nhat 24 gio");
    }

    const nextRoomId = data.room_id || booking.room_id.toString();
    const nextRoomsCount = Number(data.rooms_count ?? booking.rooms_count);
    const nextStatus = data.status || booking.status;
    if (!allStatus.includes(nextStatus)) {
      throw new BadRequestException("Trang thai booking khong hop le");
    }

    const currentRoom = await roomsModel.findById(booking.room_id);
    const nextRoom = await roomsModel.findById(nextRoomId);

    if (!currentRoom || !nextRoom) {
      throw new BadRequestException("Phong khong ton tai");
    }

    if (nextRoomsCount < 1) {
      throw new BadRequestException("So luong phong khong hop le");
    }

    const nextPropertyId = data.property_id || booking.property_id;
    if (
      nextPropertyId &&
      nextRoom.property_id?.toString() !== nextPropertyId.toString()
    ) {
      throw new BadRequestException("Phong khong thuoc cho nghi da chon");
    }

    const nextCheckIn = parseDate(data.check_in || booking.check_in, "Ngay check_in");
    const nextCheckOut = parseDate(
      data.check_out || booking.check_out,
      "Ngay check_out",
    );
    validateDateRange(nextCheckIn, nextCheckOut);

    if (activeStatus.includes(nextStatus)) {
      const bookedRooms = await getOverlappingBookedRooms({
        roomId: nextRoom._id,
        checkIn: nextCheckIn,
        checkOut: nextCheckOut,
        excludeBookingId: booking._id,
      });
      const availableRooms = (Number(nextRoom.quantity) || 0) - bookedRooms;

      if (availableRooms < nextRoomsCount) {
        throw new BadRequestException("So luong phong khong du");
      }
    }

    const nights = calculateNights(nextCheckIn, nextCheckOut);
    const pricePerNight = Number(nextRoom.price) || 0;
    const totalPrice = pricePerNight * nights * nextRoomsCount;
    const maxGuests = (Number(nextRoom.capacity) || 1) * nextRoomsCount;

    const requestedGuests = Number(data.guests ?? booking.guests);
    const guests =
      Number.isFinite(requestedGuests) && requestedGuests > 0
        ? requestedGuests
        : maxGuests;

    if (guests > maxGuests) {
      throw new BadRequestException("So khach vuot qua suc chua phong");
    }

    booking.user_id = data.user_id || booking.user_id;
    booking.property_id = nextPropertyId;
    booking.room_id = nextRoomId;
    booking.check_in = nextCheckIn;
    booking.check_out = nextCheckOut;
    booking.guests = guests;
    booking.rooms_count = nextRoomsCount;
    booking.nights = nights;
    booking.price_per_night = pricePerNight;
    booking.total_price = totalPrice;
    booking.status = nextStatus;

    await booking.save();

    return await populateBooking(bookingModel.findById(bookingId));
  },
  delete: async (bookingId) => {
    const booking = await bookingModel.findById(bookingId);

    if (!booking) {
      throw new BadRequestException("Booking khong ton tai");
    }

    return await bookingModel.findByIdAndDelete(bookingId);
  },
};

module.exports = bookingService;
