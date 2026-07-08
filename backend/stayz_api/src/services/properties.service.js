const { BadRequestException } = require("../helpers/error.helper");
const propertiesModel = require("../models/properties.model");
const cloudinary = require("../config/cloudinary.config");
const streamifier = require("streamifier");
const redis = require("../config/redis.config");

const CACHE_TTL = 300; // 5 phút

const propertiesService = {
  getAll: async () => {
    const cacheKey = "properties:all";
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const data = await propertiesModel
      .find()
      .populate("user_id", "full_name email avatar role");

    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(data));
    return data;
  },
  getFeatured: async () => {
    const cacheKey = "properties:featured";
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const data = await propertiesModel
      .find({ is_preferred: true })
      .populate("user_id", "full_name email avatar role");

    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(data));
    return data;
  },
  getBySlug: async (slug, city) => {
    const cacheKey = `properties:slug:${slug}:${city}`;
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const data = await propertiesModel
      .findOne({ slug: slug, city: city })
      .populate("user_id", "full_name email avatar role");

    if (data) await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(data));
    return data;
  },
  getCity: async (city) => {
    const cacheKey = `properties:city:${city}`;
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const data = await propertiesModel
      .find({ city: city })
      .populate("user_id", "full_name email avatar role");

    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(data));
    return data;
  },
  /**
   * Tìm kiếm nâng cao với bộ lọc đa tiêu chí
   * @param {object} filters - { keyword, city, type, minPrice, maxPrice, amenities[], isPreferred, page, limit }
   */
  search: async (filters = {}) => {
    const {
      keyword,
      city,
      type,
      minPrice,
      maxPrice,
      amenities,    // mảng tên tiện ích: ["free_wifi", "outdoor_pool", ...]
      isPreferred,
      page = 1,
      limit = 10,
    } = filters;

    const query = {};

    // Tìm kiếm theo từ khóa trong title và address
    if (keyword?.trim()) {
      const regex = new RegExp(keyword.trim(), "i");
      query.$or = [{ title: regex }, { address: regex }];
    }

    // Lọc theo thành phố
    if (city) query.city = city;

    // Lọc theo loại hình (hotel, resort,...)
    if (type) query.type = type;

    // Lọc theo khoảng giá (base_price)
    if (minPrice || maxPrice) {
      query.base_price = {};
      if (minPrice) query.base_price.$gte = Number(minPrice);
      if (maxPrice) query.base_price.$lte = Number(maxPrice);
    }

    // Lọc theo tiện ích (chỉ lấy property có TẤT CẢ tiện ích được yêu cầu)
    if (amenities && amenities.length > 0) {
      const amenityList = Array.isArray(amenities) ? amenities : [amenities];
      amenityList.forEach((amenity) => {
        query[`amenities.${amenity}`] = true;
      });
    }

    // Lọc property nổi bật
    if (isPreferred === "true" || isPreferred === true) {
      query.is_preferred = true;
    }

    const skip = (Number(page) - 1) * Number(limit);

    const [data, total] = await Promise.all([
      propertiesModel
        .find(query)
        .populate("user_id", "full_name email avatar role")
        .sort({ is_preferred: -1, createdAt: -1 }) // nổi bật lên đầu
        .skip(skip)
        .limit(Number(limit)),
      propertiesModel.countDocuments(query),
    ]);

    return {
      data,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        totalPages: Math.ceil(total / Number(limit)),
      },
    };
  },
  create: async (data) => {
    const {
      title,
      slug,
      address,
      city,
      country,
      latitude,
      longitude,
      type,
      base_price,
      description,
      amenities,
      main_image_url,
      main_image_public_id,
      gallery_images,
      is_preferred,
      max_stay_days,
      user_id,
    } = data;
    const properties = await propertiesModel.create({
      title: title,
      slug: slug,
      address: address,
      city: city,
      country: country,
      latitude: Number(latitude) || 0,
      longitude: Number(longitude) || 0,
      type: type,
      base_price: base_price,
      description: description,
      amenities: amenities,
      main_image_url: main_image_url,
      main_image_public_id: main_image_public_id,
      gallery_images: gallery_images,
      is_preferred: is_preferred,
      max_stay_days: max_stay_days,
      user_id: user_id,
    });

    // Xóa cache sau khi tạo mới
    await redis.del("properties:all");
    if (city) await redis.del(`properties:city:${city}`);

    return properties;
  },
  update: async (id, data) => {
    const properties = await propertiesModel.findByIdAndUpdate(id, data, {
      new: true,
      runValidators: true,
    });

    // Xóa toàn bộ cache liên quan
    await redis.del("properties:all");
    if (properties?.city) await redis.del(`properties:city:${properties.city}`);
    if (properties?.slug) await redis.del(`properties:slug:${properties.slug}:${properties.city}`);

    return properties;
  },
  delete: async (id) => {
    const properties = await propertiesModel.findById(id);
    const result = await propertiesModel.findByIdAndDelete(id);

    // Xóa cache sau khi xóa
    await redis.del("properties:all");
    if (properties?.city) await redis.del(`properties:city:${properties.city}`);
    if (properties?.slug) await redis.del(`properties:slug:${properties.slug}:${properties.city}`);

    return result;
  },
  uploadMainImageLocal: async (id, file) => {
    if (!file) {
      throw new BadRequestException("Vui long gui file bang key image");
    }

    const properties = await propertiesModel.findById(id);
    if (!properties) {
      throw new BadRequestException("Khong tim thay property");
    }

    properties.main_image_url = `/images/properties/${id}/main/${file.filename}`;
    properties.main_image_public_id = "";
    await properties.save();

    // Invalidate cache
    await redis.del("properties:all");
    await redis.del(`properties:city:${properties.city}`);
    await redis.del(`properties:slug:${properties.slug}:${properties.city}`);

    return properties;
  },
  uploadMainImageCloud: async (id, file) => {
    if (!file) {
      throw new BadRequestException("Vui long gui file bang key image");
    }

    const properties = await propertiesModel.findById(id);
    if (!properties) {
      throw new BadRequestException("Khong tim thay property");
    }

    if (properties.main_image_public_id) {
      await cloudinary.uploader.destroy(properties.main_image_public_id);
    }

    const uploaded = await new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        { folder: `properties/${id}/main`, resource_type: "image" },
        (error, result) => {
          if (error) return reject(error);
          resolve(result);
        },
      );

      streamifier.createReadStream(file.buffer).pipe(uploadStream);
    });

    properties.main_image_url = uploaded.secure_url;
    properties.main_image_public_id = uploaded.public_id;
    await properties.save();

    // Invalidate cache
    await redis.del("properties:all");
    await redis.del(`properties:city:${properties.city}`);
    await redis.del(`properties:slug:${properties.slug}:${properties.city}`);

    return properties;
  },
  uploadGalleryCloud: async (id, files) => {
    if (!files || files.length === 0) {
      throw new BadRequestException("Vui long gui file bang key images");
    }

    const properties = await propertiesModel.findById(id);
    if (!properties) {
      throw new BadRequestException("Khong tim thay property");
    }

    const uploadedFiles = await Promise.all(
      files.map(
        (file) =>
          new Promise((resolve, reject) => {
            const uploadStream = cloudinary.uploader.upload_stream(
              { folder: `properties/${id}/gallery`, resource_type: "image" },
              (error, result) => {
                if (error) return reject(error);
                resolve({
                  url: result.secure_url,
                  public_id: result.public_id,
                });
              },
            );

            streamifier.createReadStream(file.buffer).pipe(uploadStream);
          }),
      ),
    );

    properties.gallery_images = [
      ...(properties.gallery_images || []),
      ...uploadedFiles,
    ];
    await properties.save();

    // Invalidate cache
    await redis.del("properties:all");
    await redis.del(`properties:city:${properties.city}`);
    await redis.del(`properties:slug:${properties.slug}:${properties.city}`);

    return properties;
  },
};
module.exports = propertiesService;
