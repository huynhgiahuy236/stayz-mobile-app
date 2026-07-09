require("dotenv").config();

const bcrypt = require("bcrypt");
const mongoose = require("mongoose");

const User = require("./src/models/users.model");
const Property = require("./src/models/properties.model");
const Room = require("./src/models/rooms.model");
const Booking = require("./src/models/bookings.model");
const Favorite = require("./src/models/favorites.model");
const Review = require("./src/models/reviews.model");
const Notification = require("./src/models/notifications.model");
const { DATABASE_URL } = require("./src/constants/app.constant");

const hotels = [
  {
    title: "Hotel de l'Opera Hanoi - MGallery",
    slug: "hotel-de-lopera-hanoi-mgallery",
    address: "29 Trang Tien, Hoan Kiem, Ha Noi",
    city: "ha-noi",
    country: "Viet Nam",
    latitude: 21.0246,
    longitude: 105.8574,
    base_price: 3200000,
    description: "Khach san boutique phong cach nha hat Phap gan Ho Guom va Nha hat Lon Ha Noi.",
    is_preferred: true,
    imageUrls: [
      "https://www.ahstatic.com/photos/7832_ho_00_p_1024x768.jpg",
      "https://www.ahstatic.com/photos/7832_ho_01_p_1024x768.jpg",
    ],
    rooms: [
      ["L'Opera Deluxe King", "deluxe_room", 3200000, 3600000, 11, 2, 8, "1 king bed", 32, "City view"],
      ["Grand Suite", "suite", 6200000, 7000000, 12, 3, 3, "1 king bed", 56, "Opera House view"],
    ],
  },
  {
    title: "InterContinental Danang Sun Peninsula Resort",
    slug: "intercontinental-danang-sun-peninsula-resort",
    address: "Bai Bac, Son Tra Peninsula, Da Nang",
    city: "da-nang",
    country: "Viet Nam",
    latitude: 16.1236,
    longitude: 108.3068,
    base_price: 7800000,
    description: "Khu nghi duong bien cao cap tren ban dao Son Tra voi tam nhin huong bien.",
    is_preferred: true,
    imageUrls: [
      "https://cdn-anleb.nitrocdn.com/tCRkDCsbycMpcUNHfNUFRoXsIImxjOzf/assets/images/optimized/rev-b0c6ddc/www.danang.intercontinental.com/wp-content/uploads/2024/02/Intercontinental-Danang-6901.jpg",
      "https://cdn-anleb.nitrocdn.com/tCRkDCsbycMpcUNHfNUFRoXsIImxjOzf/assets/images/optimized/rev-b0c6ddc/www.danang.intercontinental.com/wp-content/uploads/2022/10/Bai-Bac-Bay-Villa-aerial-2-scaled.jpg",
    ],
    rooms: [
      ["Son Tra Classic Room", "standard_room", 7800000, 8500000, 8, 2, 6, "1 king bed", 50, "Garden view"],
      ["Ocean View Suite", "suite", 14500000, 16000000, 9, 3, 2, "1 king bed", 80, "Ocean view"],
    ],
  },
  {
    title: "Hotel Colline Dalat",
    slug: "hotel-colline-dalat",
    address: "10 Phan Boi Chau, Ward 1, Da Lat",
    city: "da-lat",
    country: "Viet Nam",
    latitude: 11.9442,
    longitude: 108.4382,
    base_price: 1800000,
    description: "Khach san trung tam Da Lat, gan cho dem va Ho Xuan Huong.",
    is_preferred: true,
    imageUrls: [
      "https://hotelcolline.com/storage/hotel-colline.jpg",
      "https://hotelcolline.com/storage/slider/1.jpg",
    ],
    rooms: [
      ["Superior City View", "standard_room", 1800000, 2100000, 10, 2, 12, "1 queen bed", 26, "City view"],
      ["Deluxe Family Room", "deluxe_room", 2600000, 3000000, 13, 4, 5, "2 queen beds", 38, "City view"],
    ],
  },
  {
    title: "The Reverie Saigon",
    slug: "the-reverie-saigon",
    address: "22-36 Nguyen Hue Boulevard, District 1, Ho Chi Minh City",
    city: "ho-chi-minh",
    country: "Viet Nam",
    latitude: 10.7733,
    longitude: 106.7041,
    base_price: 5600000,
    description: "Khach san sang trong tai trung tam Nguyen Hue voi tam nhin song Sai Gon.",
    is_preferred: true,
    imageUrls: [
      "https://www.thereveriesaigon.com/wp-content/uploads/2026/02/Hotel-Lobby-4-2000x1334.jpg",
      "https://www.thereveriesaigon.com/wp-content/uploads/2023/02/The-Reverie-Saigon-The-Spa-Swimming-Pool-Daytime-I-1.jpg",
    ],
    rooms: [
      ["Deluxe Room", "deluxe_room", 5600000, 6200000, 10, 2, 10, "1 king bed", 43, "City view"],
      ["Panorama Suite", "suite", 11200000, 12600000, 11, 3, 4, "1 king bed", 68, "River view"],
    ],
  },
  {
    title: "Pullman Vung Tau",
    slug: "pullman-vung-tau",
    address: "15 Thi Sach, Thang Tam Ward, Vung Tau",
    city: "vung-tau",
    country: "Viet Nam",
    latitude: 10.3506,
    longitude: 107.0965,
    base_price: 2400000,
    description: "Khach san hien dai gan bai Sau Vung Tau, phu hop ky nghi bien va chuyen di gia dinh.",
    is_preferred: false,
    imageUrls: [
      "https://www.ahstatic.com/photos/7133_ho_00_p_1024x768.jpg",
      "https://www.ahstatic.com/photos/7133_ho_01_p_1024x768.jpg",
    ],
    rooms: [
      ["Superior King", "standard_room", 2400000, 2800000, 10, 2, 9, "1 king bed", 40, "City view"],
      ["Executive Suite", "suite", 5200000, 6000000, 13, 3, 3, "1 king bed", 72, "Sea view"],
    ],
  },
];

const propertyAmenities = {
  outdoor_pool: true,
  free_wifi: true,
  airport_shuttle: true,
  non_smoking_room: true,
  room_service: true,
  restaurant: true,
  free_parking: true,
  family_room: true,
  bar: true,
  breakfast: true,
};

const roomAmenities = {
  toiletries: true,
  shower: true,
  toilet: true,
  towels: true,
  socket_near_bed: true,
  sitting_area: true,
  private_entrance: false,
  slippers: true,
  hair_dryer: true,
  fan: false,
  electric_kettle: true,
  wardrobe: true,
  clothes_rack: true,
  toilet_paper: true,
};

function buildRoom(propertyId, row, imageUrls = []) {
  const [name, roomType, price, originalPrice, discount, capacity, quantity, bedInfo, area, view] = row;
  return {
    property_id: propertyId,
    name,
    room_type: roomType,
    description: `${name} co ${bedInfo}, dien tich ${area}m2, tam nhin ${view}.`,
    price,
    original_price: originalPrice,
    discount_percent: discount,
    capacity,
    quantity,
    bed_info: bedInfo,
    area,
    view,
    main_image_url: imageUrls[0] || "",
    main_image_public_id: "",
    gallery_images: imageUrls.map((url) => ({ url, public_id: "" })),
    is_active: true,
    badges: {
      balcony: view.toLowerCase().includes("ocean") || view.toLowerCase().includes("sea"),
      air_conditioning: true,
      private_bathroom: true,
      terrace: roomType === "suite",
      free_wifi: true,
      garden_view: view.toLowerCase().includes("garden"),
      courtyard_view: view.toLowerCase().includes("city"),
    },
    amenities: roomAmenities,
  };
}

async function main() {
  if (!DATABASE_URL) {
    throw new Error("Missing DATABASE_URL in backend/stayz_api/.env");
  }

  await mongoose.connect(DATABASE_URL);

  const user = await User.findOneAndUpdate(
    { email: "guest@stayz.vn" },
    {
      email: "guest@stayz.vn",
      password: await bcrypt.hash("Stayz@123", 10),
      full_name: "StayZ Guest",
      phone_number: "0901234567",
      gender: "other",
      home_address: "Ho Chi Minh City, Viet Nam",
      role: "user",
    },
    { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true },
  );

  const properties = [];
  for (const hotel of hotels) {
    const { rooms, imageUrls, ...propertyData } = hotel;
    const property = await Property.findOneAndUpdate(
      { slug: hotel.slug },
      {
        ...propertyData,
        type: "hotel",
        amenities: propertyAmenities,
        main_image_url: imageUrls[0],
        main_image_public_id: "",
        gallery_images: imageUrls.map((url) => ({ url, public_id: "" })),
        max_stay_days: 30,
        user_id: user._id,
      },
      { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true },
    );

    properties.push(property);

    for (const row of rooms) {
      const room = buildRoom(property._id, row, imageUrls);
      await Room.findOneAndUpdate(
        { property_id: property._id, name: room.name },
        room,
        { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true },
      );
    }

    await Review.findOneAndUpdate(
      { user_id: user._id, property_id: property._id },
      {
        user_id: user._id,
        property_id: property._id,
        rating: property.is_preferred ? 5 : 4,
        comment: `${property.title} co vi tri tot, phong on va phu hop dat phong tren StayZ.`,
      },
      { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true },
    );
  }

  for (const property of properties.slice(0, 3)) {
    await Favorite.findOneAndUpdate(
      { user_id: user._id, property_id: property._id },
      { user_id: user._id, property_id: property._id },
      { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true },
    );
  }

  const firstProperty = properties[0];
  const firstRoom = await Room.findOne({ property_id: firstProperty._id });
  if (firstRoom) {
    const checkIn = new Date();
    checkIn.setDate(checkIn.getDate() + 14);
    checkIn.setHours(14, 0, 0, 0);

    const checkOut = new Date(checkIn);
    checkOut.setDate(checkOut.getDate() + 2);
    checkOut.setHours(12, 0, 0, 0);

    await Booking.findOneAndUpdate(
      { user_id: user._id, property_id: firstProperty._id, room_id: firstRoom._id },
      {
        user_id: user._id,
        property_id: firstProperty._id,
        room_id: firstRoom._id,
        check_in: checkIn,
        check_out: checkOut,
        guests: 2,
        rooms_count: 1,
        nights: 2,
        price_per_night: firstRoom.price,
        total_price: firstRoom.price * 2,
        status: "confirmed",
      },
      { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true },
    );
  }

  await Notification.findOneAndUpdate(
    { user_id: user._id, title: "StayZ da nap du lieu khach san that" },
    {
      user_id: user._id,
      type: "system",
      title: "StayZ da nap du lieu khach san that",
      body: "Property, Room, Booking, Favorite va Review da san sang trong MongoDB Compass.",
      ref_id: null,
      ref_type: null,
      is_read: false,
    },
    { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true },
  );

  console.log(`Seeded ${properties.length} real hotels.`);
  console.log("Demo account: guest@stayz.vn / Stayz@123");

  await mongoose.disconnect();
}

main().catch(async (error) => {
  console.error(error);
  await mongoose.disconnect();
  process.exit(1);
});
