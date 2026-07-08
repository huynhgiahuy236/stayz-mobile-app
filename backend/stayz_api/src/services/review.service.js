const reviewsModel = require("../models/reviews.model");

const reviewService = {
  getAll: async (propertyId) => {
    const query = {};
    if (propertyId) {
      query.property_id = propertyId;
    }
    return await reviewsModel
      .find(query)
      .populate("user_id", "avatar full_name email role")
      .populate("property_id", "title slug city user_id");
  },
  create: async (data) => {
    const { user_id, property_id, rating, comment } = data;
    const review = await reviewsModel.create({
      user_id: user_id,
      property_id: property_id,
      rating: rating,
      comment: comment,
    });
    return review;
  },
  update: async (id, data) => {
    const { rating, comment } = data;
    const review = await reviewsModel.findById(id);
    if (!review) return null;

    review.rating = rating;
    review.comment = comment;
    await review.save();

    return await reviewsModel
      .findById(id)
      .populate("user_id", "avatar full_name email role")
      .populate("property_id", "title slug city user_id");
  },
  delete: async (id) => {
    return await reviewsModel.findByIdAndDelete(id);
  },
};
module.exports = reviewService;
