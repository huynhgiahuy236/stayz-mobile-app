const {
  ConflictException,
  BadRequestException,
  UnauthorizedError,
} = require("../helpers/error.helper");
const usersModel = require("../models/users.model");

const bcrypt = require("bcrypt");
const crypto = require("crypto");
const cloudinary = require("../config/cloudinary.config");
const streamifier = require("streamifier");
const { sendPasswordResetCodeEmail, sendRegisterCodeEmail } = require("../config/mailer.config");
const { generateAuthTokens, generateAccessToken, verifyRefreshToken, verifyAccessToken } = require("../utils/token.util");
const redis = require("../config/redis.config");
// buildResetCodeHash dung SECRET nhung truoc day khong he import bien nay,
// nen ca luong OTP se nem ReferenceError neu duoc goi toi.
const { SECRET } = require("../constants/app.constant");

const RESET_CODE_EXPIRES_IN_MINUTES = 10;

const buildResetCodeHash = (email, code) => {
  return crypto
    .createHash("sha256")
    .update(`${email}:${code}:${SECRET}`)
    .digest("hex");
};

/**
 * Xac thuc ma OTP dat lai mat khau.
 * Nem loi neu thieu tham so, ma het han hoac ma sai.
 * Tra ve email da chuan hoa de ham goi dung tiep.
 */
const assertResetCode = async (email, code) => {
  if (!email?.trim() || !code?.toString().trim()) {
    throw new BadRequestException("Thiếu email hoặc mã xác thực");
  }

  const normalizedEmail = email.trim().toLowerCase();
  const normalizedCode = code.toString().trim();

  const storedHash = await redis.get(`otp:${normalizedEmail}`);
  if (!storedHash) {
    throw new BadRequestException("Mã xác thực không hợp lệ hoặc đã hết hạn");
  }

  const incomingHash = buildResetCodeHash(normalizedEmail, normalizedCode);

  // So sanh theo thoi gian hang so de khong ro ri thong tin qua do tre.
  const stored = Buffer.from(storedHash, "utf8");
  const incoming = Buffer.from(incomingHash, "utf8");
  const matches =
    stored.length === incoming.length && crypto.timingSafeEqual(stored, incoming);

  if (!matches) {
    throw new BadRequestException("Mã xác thực không đúng");
  }

  return { normalizedEmail, normalizedCode };
};

const assertRegisterCode = async (email, code) => {
  if (!email?.trim() || !code?.toString().trim()) {
    throw new BadRequestException("Thieu email hoac ma xac thuc dang ky");
  }

  const normalizedEmail = email.trim().toLowerCase();
  const normalizedCode = code.toString().trim();
  const storedHash = await redis.get(`register-otp:${normalizedEmail}`);
  if (!storedHash) {
    throw new BadRequestException("Ma xac thuc dang ky khong hop le hoac da het han");
  }

  const incomingHash = buildResetCodeHash(normalizedEmail, normalizedCode);
  const stored = Buffer.from(storedHash, "utf8");
  const incoming = Buffer.from(incomingHash, "utf8");
  const matches =
    stored.length === incoming.length && crypto.timingSafeEqual(stored, incoming);

  if (!matches) {
    throw new BadRequestException("Ma xac thuc dang ky khong dung");
  }

  return { normalizedEmail, normalizedCode };
};

const createResetCode = () => {
  return String(Math.floor(100000 + Math.random() * 900000));
};

const clearResetPasswordData = (user) => {
  user.reset_password = {
    code_hash: "",
    expires_at: null,
    requested_at: null,
  };
};

const getCookieValue = (cookieHeader, cookieName) => {
  if (!cookieHeader) return ""; 

  const cookies = cookieHeader.split(";").map((item) => item.trim());
  const targetCookie = cookies.find((item) =>
    item.startsWith(`${cookieName}=`),
  );

  if (!targetCookie) return "";

  return decodeURIComponent(targetCookie.slice(cookieName.length + 1));
};

const sanitizeUser = (userDoc) => {
  if (!userDoc) return userDoc;

  const user = userDoc.toObject ? userDoc.toObject() : { ...userDoc };
  delete user.password;

  return user;
};

const userService = {
  getAll: async () => {
    const users = await usersModel.find();
    if (users.length === 0) {
      throw new BadRequestException("Khong co user nao");
    }
    return users.map((user) => sanitizeUser(user));
  },
  getById: async (id) => {
    const user = await usersModel.findById(id);
    if (!user) {
      throw new BadRequestException("Khong tim thay user nay");
    }
    return sanitizeUser(user);
  },
  delete: async (id) => {
    const result = await usersModel.findByIdAndDelete(id);
    if (!result) {
      throw new BadRequestException("Khong tim thay user nay de xoa");
    }
    return result;
  },
  update: async (id, data) => {
    const user = await usersModel.findById(id);
    if (!user) {
      throw new BadRequestException("Khong tim thay user nay");
    }

    const {
      full_name,
      phone_number = "",
      gender = "",
      home_address = "",
      role,
      password,
      avatar,
    } = data;

    user.full_name = full_name ?? user.full_name;
    user.phone_number = phone_number;
    user.gender = gender;
    user.home_address = home_address;
    if (role && ["admin", "user"].includes(role)) {
      user.role = role;
    }
    if (password?.trim()) {
      if (String(password).trim().length < 6) {
        throw new BadRequestException("Mat khau phai co it nhat 6 ky tu");
      }

      user.password = await bcrypt.hash(String(password).trim(), 10);
    }
    if (avatar) {
      user.avatar = avatar;
    }

    await user.save();
    return sanitizeUser(user);
  },
  create: async (data) => {
    const {
      email,
      password,
      full_name,
      phone_number = "",
      gender = "",
      home_address = "",
      role = "user",
      avatar = {
        url: "",
        public_id: "",
      },
      register_code,
    } = data;

    if (!email?.trim() || !password || !full_name?.trim()) {
      throw new BadRequestException("Thieu email, mat khau hoac ho ten");
    }
    if (String(password).length < 6) {
      throw new BadRequestException("Mat khau phai co it nhat 6 ky tu");
    }

    const normalizedEmail = email.trim().toLowerCase();
    const { normalizedEmail: verifiedEmail } = await assertRegisterCode(normalizedEmail, register_code);

    const existing = await usersModel.findOne({ email: normalizedEmail });
    if (existing) {
      throw new ConflictException("Email da ton tai");
    }
    const hasedPassword = await bcrypt.hash(password, 10);
    const safeRole = ["admin", "user"].includes(role) ? role : "user";

    const user = await usersModel.create({
      email: verifiedEmail,
      password: hasedPassword,
      full_name,
      phone_number,
      gender,
      home_address,
      avatar,
      role: safeRole,
    });
    await redis.del(`register-otp:${verifiedEmail}`);
    return sanitizeUser(user);
  },

  requestRegisterOtp: async (email) => {
    if (!email?.trim()) {
      throw new BadRequestException("Vui long nhap email");
    }

    const normalizedEmail = email.trim().toLowerCase();
    const existing = await usersModel.findOne({ email: normalizedEmail });
    if (existing) {
      throw new ConflictException("Email da ton tai");
    }

    const code = createResetCode();
    const hash = buildResetCodeHash(normalizedEmail, code);
    const ttlSeconds = RESET_CODE_EXPIRES_IN_MINUTES * 60;
    await redis.setex(`register-otp:${normalizedEmail}`, ttlSeconds, hash);

    try {
      await sendRegisterCodeEmail({ to: normalizedEmail, code });
    } catch (error) {
      if (process.env.NODE_ENV !== "production") {
        console.warn(`[REGISTER OTP] Khong gui duoc email toi ${normalizedEmail}. Ma dang ky: ${code}`);
      } else {
        console.error("Gui email OTP dang ky that bai:", error.message);
      }
      await redis.del(`register-otp:${normalizedEmail}`);
      throw new BadRequestException("Khong the gui email OTP. Vui long thu lai sau");
    }

    return {
      email: normalizedEmail,
      expires_in_minutes: RESET_CODE_EXPIRES_IN_MINUTES,
    };
  },

  verifyRegisterOtp: async ({ email, code }) => {
    const { normalizedEmail } = await assertRegisterCode(email, code);
    return {
      email: normalizedEmail,
      verified: true,
    };
  },

  login: async (data) => {
    const { email, password } = data;
    if (!email || !password) {
      throw new BadRequestException("Thieu email hoac mat khau");
    }
    const user = await usersModel.findOne({ email: email });
    if (!user) {
      throw new UnauthorizedError("Email khong ton tai");
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new UnauthorizedError("Sai mat khau");
    }
    const { accessToken, refreshToken } = generateAuthTokens(user);
    return {
      accessToken,
      refreshToken,
      user: sanitizeUser(user),
    };
  },
  refreshAccessToken: async (req) => {
    const refreshToken = getCookieValue(req.headers.cookie, "refreshToken");

    if (!refreshToken) {
      throw new UnauthorizedError("Khong tim thay refresh token");
    }

    let decoded;
    try {
      decoded = verifyRefreshToken(refreshToken);
    } catch (error) {
      throw new UnauthorizedError("Refresh token khong hop le hoac da het han");
    }

    const user = await usersModel.findById(decoded.userId);
    if (!user) {
      throw new UnauthorizedError("Nguoi dung khong ton tai");
    }

    return {
      accessToken: generateAccessToken(user),
      user: sanitizeUser(user),
    };
  },
  logout: async (req) => {
    try {
      const authHeader = req.headers.authorization;
      const accessToken = authHeader?.startsWith("Bearer ")
        ? authHeader.split(" ")[1]
        : null;

      if (accessToken) {
        const decoded = verifyAccessToken(accessToken);
        const now = Math.floor(Date.now() / 1000);
        const ttl = decoded.exp - now;

        if (ttl > 0) {
          // Đưa token vào blacklist cho đến khi nó tự hết hạn
          await redis.setex(`blacklist:${accessToken}`, ttl, "1");
        }
      }
    } catch {
      // Token không hợp lệ hoặc đã hết hạn → không cần blacklist
    }

    return { loggedOut: true };
  },
  requestPasswordReset: async (email) => {
    if (!email?.trim()) {
      throw new BadRequestException("Vui lòng nhập email");
    }

    const normalizedEmail = email.trim().toLowerCase();
    const user = await usersModel.findOne({ email: normalizedEmail });

    if (!user) {
      // Không tiết lộ email có tồn tại hay không (bảo mật)
      return {
        email: normalizedEmail,
        expires_in_minutes: RESET_CODE_EXPIRES_IN_MINUTES,
      };
    }

    const code = createResetCode();
    const hash = buildResetCodeHash(normalizedEmail, code);
    const ttlSeconds = RESET_CODE_EXPIRES_IN_MINUTES * 60;

    // Lưu OTP vào Redis với TTL tự động hết hạn (không cần cron cleanup)
    await redis.setex(`otp:${normalizedEmail}`, ttlSeconds, hash);

    try {
      await sendPasswordResetCodeEmail({ to: normalizedEmail, code });
    } catch (error) {
      // SMTP hong khong duoc lam sap ca luong quen mat khau. O moi truong
      // phat trien, in ma ra console de con thu duoc. Tuyet doi khong tra
      // ma ve cho client - do la lo hong chiem tai khoan.
      if (process.env.NODE_ENV !== "production") {
        console.warn(`[OTP] Khong gui duoc email toi ${normalizedEmail}. Ma dat lai mat khau: ${code}`);
      } else {
        console.error("Gui email OTP that bai:", error.message);
      }
      await redis.del(`otp:${normalizedEmail}`);
      throw new BadRequestException("Khong the gui email OTP. Vui long thu lai sau");
    }

    return {
      email: normalizedEmail,
      expires_in_minutes: RESET_CODE_EXPIRES_IN_MINUTES,
    };
  },
  // Doi chieu ma OTP nguoi dung nhap voi hash luu trong Redis.
  // Khong xoa ma o buoc nay: nguoi dung con phai nhap mat khau moi.
  verifyPasswordResetCode: async ({ email, code }) => {
    const { normalizedEmail } = await assertResetCode(email, code);

    return {
      email: normalizedEmail,
      verified: true,
    };
  },

  // Doi mat khau. BAT BUOC kem ma OTP hop le - truoc day ham nay chi can
  // email la ghi de duoc mat khau cua bat ky ai.
  resetPasswordWithCode: async ({ email, code, newPassword }) => {
    if (!newPassword) {
      throw new BadRequestException("Vui lòng nhập mật khẩu mới");
    }
    if (String(newPassword).length < 6) {
      throw new BadRequestException("Mật khẩu mới phải có ít nhất 6 ký tự");
    }

    const { normalizedEmail } = await assertResetCode(email, code);

    const user = await usersModel.findOne({ email: normalizedEmail });
    if (!user) {
      throw new BadRequestException("Người dùng không tồn tại");
    }

    user.password = await bcrypt.hash(newPassword, 10);
    clearResetPasswordData(user);
    await user.save();

    // Ma chi dung duoc mot lan.
    await redis.del(`otp:${normalizedEmail}`);

    return {
      email: normalizedEmail,
      passwordUpdated: true,
    };
  },

  uploadLocal: async (req) => {
    const file = req.file;
    if (!file) {
      throw new BadRequestException("Vui long gui hinh anh bang key avatar");
    }

    const userId = req.user?.userId;
    if (!userId) {
      throw new UnauthorizedError("Token khong hop le");
    }
    const user = await usersModel.findById(userId);
    if (!user) {
      throw new BadRequestException("Khong tim thay user");
    }

    user.avatar = { url: `/images/${file.filename}`, public_id: "" };
    await user.save();

    return { filename: file.filename, imgUrl: `/images/${file.filename}` };
  },

  uploadCloud: async (req) => {
    const file = req.file;
    if (!file) {
      throw new BadRequestException(
        "Vui long gui hinh anh bang key avatar (form-data)",
      );
    }

    const userId = req.params?.id || req.user?.userId;
    if (!userId) {
      throw new UnauthorizedError("Token khong hop le");
    }

    const user = await usersModel.findById(userId);
    if (!user) {
      throw new BadRequestException("Khong tim thay user");
    }

    if (user.avatar?.public_id) {
      await cloudinary.uploader.destroy(user.avatar.public_id);
    }

    const result = await new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        { folder: "avatars", resource_type: "image" },
        (error, uploaded) => {
          if (error) return reject(error);
          resolve(uploaded);
        },
      );

      streamifier.createReadStream(file.buffer).pipe(uploadStream);
    });

    user.avatar = {
      url: result.secure_url,
      public_id: result.public_id,
    };
    await user.save();

    return {
      avatar: user.avatar,
    };
  },
};

module.exports = userService;
