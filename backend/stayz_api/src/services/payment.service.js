const payOS = require("../config/payos.config");
const { BadRequestException } = require("../helpers/error.helper");
const bookingModel = require("../models/bookings.model");
const paymentsModel = require("../models/payments.model");
const { PAYOS_RETURN_URL, PAYOS_CANCEL_URL } = require("../constants/app.constant");
const { calculatePaymentQuote } = require("../utils/paymentQuote.util");

const paymentService = {
  getAll: async () =>
    paymentsModel
      .find()
      .populate("user_id", "full_name email")
      .populate({
        path: "booking_id",
        populate: [
          { path: "property_id", select: "title" },
          { path: "room_id", select: "name" },
        ],
      })
      .sort({ createdAt: -1 }),
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

    const existingPayment = await paymentsModel.findOne({ booking_id: bookingId });
    if (existingPayment) {
      if (!existingPayment.qr_code && existingPayment.payment_link_id) {
        const current = await payOS.paymentRequests.get(existingPayment.payment_link_id);
        existingPayment.qr_code = current.qrCode;
        existingPayment.bank_bin = current.bin;
        existingPayment.account_number = current.accountNumber;
        existingPayment.account_name = current.accountName;
        existingPayment.transfer_description = current.description;
        existingPayment.currency = current.currency || "VND";
        await existingPayment.save();
      }
      return existingPayment;
    }

    // Tạo mã đơn hàng ngẫu nhiên duy nhất (PayOS yêu cầu định dạng số)
    const orderCode = Number(String(Date.now()).slice(-6) + Math.floor(1000 + Math.random() * 9000));

    const paymentQuote = calculatePaymentQuote(booking.payment_plan, booking.total_price);
    const description = `Thanh toan StayZ`;
    // Tạo request data theo chuẩn PayOS
    const requestData = {
      orderCode,
      amount: paymentQuote.payNow,
      description: description.substring(0, 25), // PayOS giới hạn 25 ký tự không dấu
      cancelUrl: PAYOS_CANCEL_URL || "http://localhost:5173/payment/cancel",
      returnUrl: PAYOS_RETURN_URL || "http://localhost:5173/payment/success",
      expiredAt: Math.floor(Date.now() / 1000) + 15 * 60,
    };

    const paymentLinkRes = await payOS.paymentRequests.create(requestData);

    // Lưu thông tin thanh toán vào DB
    const payment = await paymentsModel.create({
      booking_id: bookingId,
      user_id: userId,
      order_code: orderCode,
      amount: paymentQuote.payNow,
      payment_link_id: paymentLinkRes.paymentLinkId,
      checkout_url: paymentLinkRes.checkoutUrl,
      qr_code: paymentLinkRes.qrCode,
      bank_bin: paymentLinkRes.bin,
      account_number: paymentLinkRes.accountNumber,
      account_name: paymentLinkRes.accountName,
      transfer_description: paymentLinkRes.description,
      currency: paymentLinkRes.currency || "VND",
      status: "pending",
    });

    return payment;
  },

  // Xử lý callback/webhook khi PayOS xác nhận đã nhận thanh toán thành công
  handleWebhook: async (webhookBody) => {
    if (!payOS) return null;

    // Xác thực webhook từ PayOS gửi đến
    const verifiedData = await payOS.webhooks.verify(webhookBody);

    const { orderCode } = verifiedData;

    // Tìm giao dịch thanh toán
    const payment = await paymentsModel.findOne({ order_code: orderCode });
    if (!payment) {
      return null;
    }

    if (verifiedData.code === "00") {
      if (Number(verifiedData.amount) !== Number(payment.amount)) {
        throw new BadRequestException("So tien webhook khong khop giao dich");
      }
      if (payment.status === "PAID") return payment;
      // 1. Cập nhật trạng thái Payment là PAID
      payment.status = "PAID";
      await payment.save();

      // 2. Cập nhật trạng thái Booking là confirmed
      const booking = await bookingModel.findById(payment.booking_id);
      const paymentQuote = calculatePaymentQuote(booking?.payment_plan, booking?.total_price);
      await bookingModel.findByIdAndUpdate(payment.booking_id, {
        status: "confirmed",
        payment_status: "paid",
        amount_paid: payment.amount,
        remaining_at_hotel: paymentQuote.remaining,
        payment_expires_at: null,
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
        await payOS.paymentRequests.cancel(payment.payment_link_id, "Cancelled by StayZ user");
      } catch (err) {
        console.warn("PayOS SDK cancel link error:", err.message);
      }
    }

    payment.status = "CANCELLED";
    await payment.save();

    return payment;
  },
  cancelPaymentByAdmin: async (paymentId) => {
    const payment = await paymentsModel.findById(paymentId);
    if (!payment) throw new BadRequestException("Không tìm thấy giao dịch");
    if (payment.status !== "pending") {
      throw new BadRequestException("Chỉ có thể huỷ giao dịch đang chờ thanh toán");
    }
    if (payOS && payment.payment_link_id) {
      try {
        await payOS.paymentRequests.cancel(payment.payment_link_id, "Cancelled by StayZ admin");
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
