const payOS = require("../config/payos.config");
const { BadRequestException } = require("../helpers/error.helper");
const bookingModel = require("../models/bookings.model");
const paymentsModel = require("../models/payments.model");
const { PAYOS_RETURN_URL, PAYOS_CANCEL_URL } = require("../constants/app.constant");

const paymentService = {
  // Tạo liên kết thanh toán PayOS từ một Booking
  createPaymentLink: async (bookingId, userId) => {
    if (!payOS) {
      throw new BadRequestException("Cổng thanh toán PayOS hiện chưa được cấu hình key.");
    }

    const booking = await bookingModel.findById(bookingId).populate("room_id property_id");
    if (!booking) {
      throw new BadRequestException("Booking không tồn tại");
    }

    // Đảm bảo chỉ user chủ booking mới thanh toán được
    if (booking.user_id.toString() !== userId.toString()) {
      throw new BadRequestException("Bạn không được phép thanh toán cho booking này");
    }

    if (booking.status === "confirmed" || booking.status === "completed") {
      throw new BadRequestException("Booking này đã được thanh toán rồi");
    }

    // Tạo mã đơn hàng ngẫu nhiên duy nhất (PayOS yêu cầu định dạng số)
    const orderCode = Number(String(Date.now()).slice(-6) + Math.floor(1000 + Math.random() * 9000));

    const description = `Thanh toán Booking StayZ`;
    // Tạo request data theo chuẩn PayOS
    const requestData = {
      orderCode,
      amount: booking.total_price,
      description: description.substring(0, 25), // PayOS giới hạn 25 ký tự không dấu
      cancelUrl: PAYOS_CANCEL_URL || "http://localhost:5173/payment/cancel",
      returnUrl: PAYOS_RETURN_URL || "http://localhost:5173/payment/success",
    };

    const paymentLinkRes = await payOS.createPaymentLink(requestData);

    // Lưu thông tin thanh toán vào DB
    const payment = await paymentsModel.create({
      booking_id: bookingId,
      user_id: userId,
      order_code: orderCode,
      amount: booking.total_price,
      payment_link_id: paymentLinkRes.paymentLinkId,
      checkout_url: paymentLinkRes.checkoutUrl,
      status: "pending",
    });

    return payment;
  },

  // Xử lý callback/webhook khi PayOS xác nhận đã nhận thanh toán thành công
  handleWebhook: async (webhookBody) => {
    if (!payOS) return null;

    // Xác thực webhook từ PayOS gửi đến
    const verifiedData = payOS.verifyPaymentWebhookData(webhookBody);

    const { orderCode, success } = verifiedData;

    // Tìm giao dịch thanh toán
    const payment = await paymentsModel.findOne({ order_code: orderCode });
    if (!payment) {
      throw new BadRequestException("Giao dịch thanh toán không tồn tại");
    }

    if (success) {
      // 1. Cập nhật trạng thái Payment là PAID
      payment.status = "PAID";
      await payment.save();

      // 2. Cập nhật trạng thái Booking là confirmed
      await bookingModel.findByIdAndUpdate(payment.booking_id, {
        status: "confirmed",
      });
    } else {
      // 1. Cập nhật trạng thái Payment là CANCELLED
      payment.status = "CANCELLED";
      await payment.save();
    }

    return payment;
  },

  // Lấy chi tiết thông tin thanh toán cho booking
  getPaymentByBooking: async (bookingId) => {
    return await paymentsModel.findOne({ booking_id: bookingId });
  },

  // Hủy thanh toán / Link thanh toán
  cancelPaymentLink: async (bookingId, userId) => {
    const payment = await paymentsModel.findOne({ booking_id: bookingId, user_id: userId });
    if (!payment) {
      throw new BadRequestException("Không tìm thấy giao dịch thanh toán của booking này");
    }

    if (payment.status !== "pending") {
      throw new BadRequestException(`Không thể hủy giao dịch ở trạng thái: ${payment.status}`);
    }

    if (payOS) {
      try {
        await payOS.cancelPaymentLink(payment.payment_link_id);
      } catch (err) {
        console.warn("PayOS SDK cancel link error:", err.message);
      }
    }

    payment.status = "CANCELLED";
    await payment.save();

    return payment;
  },
};

module.exports = paymentService;
