const roomModel = require("../models/rooms.model");
const redis = require("../config/redis.config");

const calculatePrice = (originalPrice, discountPercent) => {
  const safeOriginalPrice = Number(originalPrice) || 0;
  const safeDiscountPercent = Number(discountPercent) || 0;

  const finalPrice = safeOriginalPrice * (1 - safeDiscountPercent / 100);
  return Math.round(finalPrice);
};

const normalizeGallery = (galleryImages) => {
  if (!Array.isArray(galleryImages)) return [];
  return galleryImages
    .map((item) => {
      if (typeof item === "string") return { url: item, public_id: "" };
      return {
        url: item?.url || "",
        public_id: item?.public_id || "",
      };
    })
    .filter((item) => item.url);
};

const clearRoomCache = async (propertyId) => {
  try {
    await redis.del("rooms:all");
    if (propertyId) await redis.del(`rooms:property:${propertyId}`);
  } catch (err) {
    console.warn("Room cache delete skipped:", err.message);
  }
};

const roomService = {
  getAll: async () => {
    return await roomModel.find({ is_active: { $ne: false } }).populate("property_id");
  },

  getByPropertyId: async (propertyId) => {
    return await roomModel.find({ property_id: propertyId, is_active: { $ne: false } }).populate("property_id");
  },

  getById: async (id) => {
    return await roomModel.findById(id).populate("property_id");
  },

  create: async (data) => {
    const {
      property_id,
      name,
      room_type,
      description,
      original_price,
      discount_percent,
      capacity,
      quantity,
      bed_info,
      area,
      view,
      badges,
      amenities,
      main_image_url,
      gallery_images,
      is_active,
    } = data;

    const finalPrice = calculatePrice(original_price, discount_percent);

    const room = await roomModel.create({
      property_id,
      name,
      room_type,
      description,
      price: finalPrice,
      original_price: Number(original_price) || 0,
      discount_percent: Number(discount_percent) || 0,
      capacity: Number(capacity) || 1,
      quantity: Number(quantity) || 1,
      bed_info,
      area: Number(area) || 0,
      view,
      badges,
      amenities,
      main_image_url: main_image_url || "",
      gallery_images: normalizeGallery(gallery_images),
      is_active: is_active !== false,
    });

    await clearRoomCache(property_id);

    return room;
  },

  update: async (id, data) => {
    const nextData = { ...data };

    if (nextData.price_per_night != null && nextData.price == null) {
      nextData.price = Number(nextData.price_per_night) || 0;
    } else if (nextData.original_price != null || nextData.discount_percent != null) {
      const originalPrice = Number(nextData.original_price) || 0;
      const discountPercent = Number(nextData.discount_percent) || 0;
      nextData.price = calculatePrice(originalPrice, discountPercent);
      nextData.original_price = originalPrice;
      nextData.discount_percent = discountPercent;
    }

    if (nextData.available_rooms != null && nextData.quantity == null) {
      nextData.quantity = nextData.available_rooms;
    }
    if (nextData.gallery_images != null) {
      nextData.gallery_images = normalizeGallery(nextData.gallery_images);
    }
    if (nextData.capacity != null) nextData.capacity = Number(nextData.capacity) || 1;
    if (nextData.quantity != null) nextData.quantity = Number(nextData.quantity) || 1;
    if (nextData.area != null) nextData.area = Number(nextData.area) || 0;

    const room = await roomModel.findByIdAndUpdate(id, nextData, {
      new: true,
      runValidators: true,
    });

    await clearRoomCache(room?.property_id);

    return room;
  },

  delete: async (id) => {
    const room = await roomModel.findById(id);
    const result = await roomModel.findByIdAndDelete(id);

    await clearRoomCache(room?.property_id);

    return result;
  },
};

module.exports = roomService;
