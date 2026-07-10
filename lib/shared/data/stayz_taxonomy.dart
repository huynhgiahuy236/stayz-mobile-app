import 'package:flutter/material.dart';

/// Nguon duy nhat anh xa gia tri enum trong database sang nhan tieng Viet.
///
/// Truoc day moi man hinh tu bay ra danh sach cua rieng no: man Filter co 4 tien
/// ich tieng Anh, man chi tiet hardcode 6 tien ich khong lien quan toi du lieu,
/// man chon phong lai co tu dien rieng. Gio tat ca doc tu day.
class StayzTerm {
  const StayzTerm({required this.slug, required this.label, this.icon});

  final String slug;
  final String label;
  final IconData? icon;
}

class StayzTaxonomy {
  const StayzTaxonomy._();

  /// Khop enum `city` trong `properties.model.js`.
  static const cities = <StayzTerm>[
    StayzTerm(slug: 'ha-noi', label: 'Hà Nội'),
    StayzTerm(slug: 'da-nang', label: 'Đà Nẵng'),
    StayzTerm(slug: 'da-lat', label: 'Đà Lạt'),
    StayzTerm(slug: 'ho-chi-minh', label: 'TP.HCM'),
    StayzTerm(slug: 'vung-tau', label: 'Vũng Tàu'),
  ];

  /// Khop enum `type` trong `properties.model.js`.
  static const propertyTypes = <StayzTerm>[
    StayzTerm(slug: 'hotel', label: 'Khách sạn', icon: Icons.apartment_rounded),
    StayzTerm(slug: 'resort', label: 'Resort', icon: Icons.beach_access_rounded),
    StayzTerm(slug: 'villa', label: 'Biệt thự', icon: Icons.villa_rounded),
    StayzTerm(slug: 'apartment', label: 'Căn hộ', icon: Icons.house_rounded),
    StayzTerm(slug: 'business', label: 'Công tác', icon: Icons.business_center_rounded),
    StayzTerm(slug: 'hostel', label: 'Hostel', icon: Icons.bed_rounded),
  ];

  /// Khop enum `room_type` trong `rooms.model.js`.
  static const roomTypes = <StayzTerm>[
    StayzTerm(slug: 'standard_room', label: 'Tiêu chuẩn'),
    StayzTerm(slug: 'deluxe_room', label: 'Deluxe'),
    StayzTerm(slug: 'suite', label: 'Suite'),
  ];

  /// Khop 10 khoa trong `properties.model.js -> amenities`.
  static const propertyAmenities = <StayzTerm>[
    StayzTerm(slug: 'free_wifi', label: 'Wifi miễn phí', icon: Icons.wifi_rounded),
    StayzTerm(slug: 'outdoor_pool', label: 'Hồ bơi', icon: Icons.pool_rounded),
    StayzTerm(slug: 'breakfast', label: 'Bữa sáng', icon: Icons.free_breakfast_rounded),
    StayzTerm(slug: 'free_parking', label: 'Đỗ xe miễn phí', icon: Icons.local_parking_rounded),
    StayzTerm(slug: 'family_room', label: 'Phòng gia đình', icon: Icons.family_restroom_rounded),
    StayzTerm(slug: 'restaurant', label: 'Nhà hàng', icon: Icons.restaurant_rounded),
    StayzTerm(slug: 'airport_shuttle', label: 'Đưa đón sân bay', icon: Icons.airport_shuttle_rounded),
    StayzTerm(slug: 'room_service', label: 'Phục vụ phòng', icon: Icons.room_service_rounded),
    StayzTerm(slug: 'bar', label: 'Quầy bar', icon: Icons.local_bar_rounded),
    StayzTerm(slug: 'non_smoking_room', label: 'Không hút thuốc', icon: Icons.smoke_free_rounded),
  ];

  /// Khop `rooms.model.js -> amenities` va `-> badges`.
  static const roomAmenities = <StayzTerm>[
    StayzTerm(slug: 'air_conditioning', label: 'Điều hòa', icon: Icons.ac_unit_rounded),
    StayzTerm(slug: 'private_bathroom', label: 'Phòng tắm riêng', icon: Icons.bathtub_rounded),
    StayzTerm(slug: 'balcony', label: 'Ban công', icon: Icons.balcony_rounded),
    StayzTerm(slug: 'terrace', label: 'Sân hiên', icon: Icons.deck_rounded),
    StayzTerm(slug: 'garden_view', label: 'View vườn', icon: Icons.park_rounded),
    StayzTerm(slug: 'courtyard_view', label: 'View sân trong', icon: Icons.yard_rounded),
    StayzTerm(slug: 'free_wifi', label: 'Wifi', icon: Icons.wifi_rounded),
    StayzTerm(slug: 'electric_kettle', label: 'Ấm đun nước', icon: Icons.coffee_rounded),
    StayzTerm(slug: 'hair_dryer', label: 'Máy sấy tóc', icon: Icons.dry_rounded),
    StayzTerm(slug: 'wardrobe', label: 'Tủ quần áo', icon: Icons.checkroom_rounded),
    StayzTerm(slug: 'sitting_area', label: 'Khu tiếp khách', icon: Icons.weekend_rounded),
    StayzTerm(slug: 'slippers', label: 'Dép đi trong phòng', icon: Icons.spa_rounded),
    StayzTerm(slug: 'towels', label: 'Khăn tắm', icon: Icons.dry_cleaning_rounded),
    StayzTerm(slug: 'shower', label: 'Vòi sen', icon: Icons.shower_rounded),
    StayzTerm(slug: 'toiletries', label: 'Đồ vệ sinh cá nhân', icon: Icons.soap_rounded),
    StayzTerm(slug: 'socket_near_bed', label: 'Ổ cắm cạnh giường', icon: Icons.power_rounded),
    StayzTerm(slug: 'fan', label: 'Quạt', icon: Icons.mode_fan_off_rounded),
    StayzTerm(slug: 'private_entrance', label: 'Lối vào riêng', icon: Icons.door_front_door_rounded),
    StayzTerm(slug: 'clothes_rack', label: 'Giá treo đồ', icon: Icons.checkroom_rounded),
    StayzTerm(slug: 'toilet', label: 'Toilet', icon: Icons.wc_rounded),
    StayzTerm(slug: 'toilet_paper', label: 'Giấy vệ sinh', icon: Icons.inventory_2_rounded),
  ];

  static const bookingStatuses = <String, String>{
    'pending': 'Chờ xác nhận',
    'confirmed': 'Đã xác nhận',
    'completed': 'Đã hoàn tất',
    'cancelled': 'Đã hủy',
  };

  static const paymentStatuses = <String, String>{
    'pending': 'Chưa thanh toán',
    'paid': 'Đã thanh toán',
    'failed': 'Thanh toán thất bại',
    'refunded': 'Đã hoàn tiền',
  };

  static StayzTerm? _find(List<StayzTerm> terms, String slug) {
    for (final term in terms) {
      if (term.slug == slug) return term;
    }
    return null;
  }

  static String cityLabel(String slug) => _find(cities, slug)?.label ?? slug;
  static String propertyTypeLabel(String slug) => _find(propertyTypes, slug)?.label ?? slug;
  static String roomTypeLabel(String slug) => _find(roomTypes, slug)?.label ?? slug;

  /// Tra ve nhan + icon cho mot khoa tien ich, ke ca khi backend them khoa moi
  /// ma app chua biet: khi do hien lai chinh khoa do thay vi bo qua im lang.
  static StayzTerm amenityTerm(String slug) =>
      _find(propertyAmenities, slug) ??
      _find(roomAmenities, slug) ??
      StayzTerm(slug: slug, label: slug.replaceAll('_', ' '), icon: Icons.check_circle_outline_rounded);

  static String bookingStatusLabel(String status) => bookingStatuses[status] ?? status;
  static String paymentStatusLabel(String status) => paymentStatuses[status] ?? status;
}
