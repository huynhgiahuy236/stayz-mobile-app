const Redis = require("ioredis");

const redis = new Redis(process.env.REDIS_URL || "redis://127.0.0.1:6379", {
  lazyConnect: false,
  retryStrategy(times) {
    // Tự reconnect, tối đa 3 lần, mỗi lần cách 500ms
    if (times > 3) return null;
    return Math.min(times * 500, 2000);
  },
});

redis.on("connect", () => {
  console.log("✅ Redis connected");
});

redis.on("error", (err) => {
  console.error("❌ Redis error:", err.message);
});

module.exports = redis;
