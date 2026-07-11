const http = require("http");
const dns = require("node:dns");
const express = require("express");
const cors = require("cors");
const app = express();
const mongoose = require("mongoose");
const rootRouter = require("./src/routes/rootRouter.router");
const {
  DATABASE_URL,
  PAYOS_API_KEY,
  PAYOS_CHECKSUM_KEY,
  PAYOS_CLIENT_ID,
} = require("./src/constants/app.constant");
const { handleError } = require("./src/helpers/error.helper");
const passport = require("passport");
const { initSocket } = require("./src/config/socket.config");

require("./src/config/passport.config");

const PORT = process.env.PORT || 3000;
const allowedOrigins = new Set([
  process.env.CLIENT_URL,
  "http://localhost:5173",
  "http://127.0.0.1:5173",
  "http://localhost:3000",
].filter(Boolean));

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.has(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error(`CORS blocked for origin: ${origin}`));
    },
    credentials: true,
  }),
);

app.use(express.json());
app.use(passport.initialize());

let isMongoConnecting = false;
let lastMongoError = null;
let lastMongoAttemptAt = null;

app.get("/health", (_req, res) => {
  const connected = mongoose.connection.readyState === 1;
  const body = {
    status: connected ? "ok" : "starting",
    database: connected ? "connected" : "disconnected",
    mongo_ready_state: mongoose.connection.readyState,
    payos: {
      client_id: Boolean(PAYOS_CLIENT_ID),
      api_key: Boolean(PAYOS_API_KEY),
      checksum_key: Boolean(PAYOS_CHECKSUM_KEY),
      checksum_key_length: PAYOS_CHECKSUM_KEY?.length || 0,
    },
  };

  if (!connected) {
    body.mongo_error = lastMongoError;
    body.last_mongo_attempt_at = lastMongoAttemptAt;
  }

  res.status(connected ? 200 : 503).json(body);
});

if (!DATABASE_URL?.startsWith("mongodb://") && !DATABASE_URL?.startsWith("mongodb+srv://")) {
  throw new Error(
    "DATABASE_URL must start with mongodb:// or mongodb+srv://",
  );
}

// Some local routers refuse the SRV DNS lookup used by MongoDB Atlas.
// Public resolvers can be overridden with MONGODB_DNS_SERVERS in .env.
if (DATABASE_URL.startsWith("mongodb+srv://")) {
  const dnsServers = (process.env.MONGODB_DNS_SERVERS || "1.1.1.1,8.8.8.8")
    .split(",")
    .map((server) => server.trim())
    .filter(Boolean);
  dns.setServers(dnsServers);
}

const imageStaticOptions = {
  maxAge: "7d",
  immutable: true,
};

app.use("/images", express.static("src/images", imageStaticOptions));
app.use("/api/images", express.static("src/images", imageStaticOptions));
app.use("/", rootRouter);
app.use("/api", rootRouter);
app.use(handleError);

// Create HTTP server instead of listening directly with express
const server = http.createServer(app);

// Initialize Socket.io on the server
initSocket(server);

async function connectMongoWithRetry() {
  if (isMongoConnecting || mongoose.connection.readyState === 1) return;

  isMongoConnecting = true;
  lastMongoAttemptAt = new Date().toISOString();
  try {
    await mongoose.connect(DATABASE_URL, { serverSelectionTimeoutMS: 10000 });
    lastMongoError = null;
    console.log("MongoDB connected");
  } catch (error) {
    lastMongoError = error.message;
    console.error("MongoDB connection failed:", error.message);
    setTimeout(connectMongoWithRetry, 10000);
  } finally {
    isMongoConnecting = false;
  }
}

mongoose.connection.on("disconnected", () => {
  console.warn("MongoDB disconnected. Retrying connection...");
  setTimeout(connectMongoWithRetry, 10000);
});

server.listen(PORT, () => {
  console.log(`StayZ API online at http://localhost:${PORT}`);
  connectMongoWithRetry();
});
