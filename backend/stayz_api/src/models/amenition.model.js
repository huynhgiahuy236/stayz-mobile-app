const { default: mongoose } = require("mongoose");

const amenitionSchema = new mongoose.Schema({
  property_id: mongoose.Schema.Types.ObjectId,
});
