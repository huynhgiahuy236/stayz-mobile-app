const jwt = require("jsonwebtoken");
const { SECRET } = require("../constants/app.constant");
const { UnauthorizedError } = require("../helpers/error.helper");
const redis = require("../config/redis.config");

const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const accessToken = authHeader?.startsWith("Bearer ")
      ? authHeader.split(" ")[1]
      : null;

    if (!accessToken) {
      throw new UnauthorizedError("Vui lòng cung cấp token để tiếp tục");
    }

    // Kiểm tra token có bị blacklist (đã logout) chưa
    const isBlacklisted = await redis.get(`blacklist:${accessToken}`);
    if (isBlacklisted) {
      throw new UnauthorizedError("Token đã bị thu hồi. Vui lòng đăng nhập lại");
    }

    const decoded = jwt.verify(accessToken, SECRET);

    req.user = {
      userId: decoded.userId,
      role: decoded.role_user,
    };

    next();
  } catch (error) {
    next(error);
  }
};

module.exports = protect;
