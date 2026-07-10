const express = require("express");
const userController = require("../controllers/users.controller");

const protect = require("../middlewares/protect.middleware");
const uploadLocalMiddleware = require("../middlewares/uploadLocal.middleware");
const uploadCloud = require("../middlewares/uploadCloud.middleware");
const { rateLimiter } = require("../middlewares/rateLimit.middleware");
const userRouter = express.Router();

userRouter.get("/getAll", userController.getAll);
userRouter.get("/getById/:id", userController.getById);
userRouter.delete("/delete/:id", userController.delete);
userRouter.patch("/update/:id", userController.update);
// Rate limit: đăng ký tối đa 5 lần / 15 phút, chặn spam tạo tài khoản
userRouter.post("/create", rateLimiter(5, 900), userController.create);

// Rate limit: login tối đa 5 lần / 60 giây
userRouter.post("/login", rateLimiter(5, 60), userController.login);
userRouter.post("/refresh-token", userController.refreshAccessToken);
userRouter.post("/logout", userController.logout);

// Rate limit: reset password tối đa 3 lần / 15 phút
userRouter.post("/request-password-reset", rateLimiter(3, 900), userController.requestPasswordReset);
// Mã OTP chỉ có 6 chữ số: không giới hạn thì dò hết trong vài phút.
userRouter.post("/verify-reset-code", rateLimiter(5, 900), userController.verifyPasswordResetCode);
userRouter.post("/reset-password", rateLimiter(3, 900), userController.resetPasswordWithCode);

userRouter.patch(
  "/avatar/local",
  protect,
  uploadLocalMiddleware.single("avatar"),
  userController.uploadLocal,
);
userRouter.patch(
  "/avatar/cloud",
  protect,
  uploadCloud.single("avatar"),
  userController.uploadCloud,
);
userRouter.patch(
  "/avatar/cloud/:id",
  protect,
  uploadCloud.single("avatar"),
  userController.uploadCloud,
);
module.exports = userRouter;
