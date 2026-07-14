const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    type: {
      type: String,
      enum: ["booking_status", "promotion", "system"],
      default: "system",
    },
    title: {
      type: String,
      required: true,
    },
    body: {
      type: String,
      required: true,
    },
    title_en: { type: String, default: "" },
    body_en: { type: String, default: "" },
    // Dữ liệu tham chiếu đến booking hoặc property liên quan
    ref_id: {
      type: mongoose.Schema.Types.ObjectId,
      default: null,
    },
    ref_type: {
      type: String,
      enum: ["Booking", "Property", null],
      default: null,
    },
    is_read: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Notification", notificationSchema);
