const { responseSuccess } = require("../helpers/response.helper");
const { ForbiddenException } = require("../helpers/error.helper");
const bookingService = require("../services/booking.service");

const isAdmin = (req) => req.user?.role === "admin";

const bookingController = {
  getAll: async (req, res, next) => {
    try {
      // Danh sach toan he thong chi danh cho admin. Nguoi dung thuong
      // chi duoc thay booking cua chinh minh.
      const data = isAdmin(req)
        ? await bookingService.getAll()
        : await bookingService.getByUserId(req.user.userId);
      const response = responseSuccess(data, "Lấy danh sách booking thành công", 200);
      res.status(response.code).json(response);
    } catch (err) {
      next(err);
    }
  },
  getByUserId: async (req, res, next) => {
    const userId = req.params.userId;
    try {
      if (!isAdmin(req) && userId !== req.user.userId) {
        throw new ForbiddenException("Bạn không thể xem booking của người dùng khác");
      }
      const data = await bookingService.getByUserId(userId);
      const response = responseSuccess(data, "Lấy Booking thành công", 200);
      res.status(response.code).json(response);
    } catch (err) {
      next(err);
    }
  },
  create: async (req, res, next) => {
    try {
      // user_id luon lay tu token, khong bao gio tu body.
      const newBooking = { ...req.body, user_id: req.user.userId };
      const data = await bookingService.create(newBooking);
      const response = responseSuccess(data, "Tạo booking thành công", 200);
      res.status(response.code).json(response);
    } catch (err) {
      next(err);
    }
  },
  update: async (req, res, next) => {
    const bookingId = req.params.bookingId;
    const payload = req.body;
    try {
      const data = await bookingService.update(bookingId, payload, req.user);
      const response = responseSuccess(data, "Cập nhật Booking thành công", 200);
      res.status(response.code).json(response);
    } catch (err) {
      next(err);
    }
  },
  delete: async (req, res, next) => {
    const bookingId = req.params.bookingId;
    try {
      const data = await bookingService.delete(bookingId, req.user);
      const response = responseSuccess(data, "Xóa booking thành công", 200);
      res.status(response.code).json(response);
    } catch (err) {
      next(err);
    }
  },
  updateStatus: async (req, res, next) => {
    const bookingId = req.params.bookingId;
    const { status, refund_amount, refund_rate } = req.body;

    try {
      const data = await bookingService.updateStatus(bookingId, status, req.user, {
        refund_amount,
        refund_rate,
      });
      const response = responseSuccess(
        data,
        "Cập nhật trạng thái booking thành công",
        200,
      );
      res.status(response.code).json(response);
    } catch (err) {
      next(err);
    }
  },
};

module.exports = bookingController;
