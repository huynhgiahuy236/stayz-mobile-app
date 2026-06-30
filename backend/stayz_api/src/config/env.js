require('dotenv').config();

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 5000,
  mongodbUri: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/stayz',
  jwtSecret: process.env.JWT_SECRET || 'change_me',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  uploadDriver: process.env.UPLOAD_DRIVER || 'local',
};

module.exports = { env };
