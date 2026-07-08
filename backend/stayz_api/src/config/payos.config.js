const { PayOS } = require("@payos/node");
const {
  PAYOS_CLIENT_ID,
  PAYOS_API_KEY,
  PAYOS_CHECKSUM_KEY,
} = require("../constants/app.constant");

let payOS;

if (PAYOS_CLIENT_ID && PAYOS_API_KEY && PAYOS_CHECKSUM_KEY) {
  payOS = new PayOS(PAYOS_CLIENT_ID, PAYOS_API_KEY, PAYOS_CHECKSUM_KEY);
  console.log("✅ PayOS SDK Initialized");
} else {
  console.warn("⚠️ PayOS keys are missing in env constants. PayOS payment flow may not work.");
}

module.exports = payOS;
