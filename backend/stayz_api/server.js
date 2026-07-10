const http = require("http");
const express = require("express");
const cors = require("cors");
const app = express();
const mongoose = require("mongoose");
const rootRouter = require("./src/routes/rootRouter.router");
const { DATABASE_URL } = require("./src/constants/app.constant");
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

mongoose.connect(DATABASE_URL);

mongoose.connection.on("connected", () => {
  console.log("MongoDB connected");
});

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

server.listen(PORT, () => {
  console.log(`StayZ API online at http://localhost:${PORT}`);
});
