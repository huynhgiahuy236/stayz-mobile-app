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

const safeCommands = new Set([
  "del",
  "expire",
  "get",
  "incr",
  "lpush",
  "lrange",
  "ltrim",
  "set",
  "setex",
]);

const safeRedis = new Proxy(redis, {
  get(target, prop) {
    const value = target[prop];
    if (typeof value !== "function") return value;

    if (!safeCommands.has(prop)) {
      return value.bind(target);
    }

    return async (...args) => {
      try {
        return await value.apply(target, args);
      } catch (err) {
        console.warn(`Redis ${prop} skipped:`, err.message);
        if (prop === "incr") return 1;
        return null;
      }
    };
  },
});

module.exports = safeRedis;
