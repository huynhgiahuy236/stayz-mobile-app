const express = require("express");

const bookingController = require("../controllers/booking.controller");
const protect = require("../middlewares/protect.middleware");
const bookingRouter = express.Router();

// Truoc day nhom route nay khong co protect va tin user_id gui tu client,
// nen bat ky ai cung xem/huy duoc booking cua nguoi khac.
bookingRouter.use(protect);

bookingRouter.get("/getAll", bookingController.getAll);
bookingRouter.get("/user/:userId", bookingController.getByUserId);
bookingRouter.post("/create", bookingController.create);
bookingRouter.put("/update/:bookingId", bookingController.update);
bookingRouter.delete("/delete/:bookingId", bookingController.delete);
bookingRouter.patch("/:bookingId/status", bookingController.updateStatus);

module.exports = bookingRouter;
