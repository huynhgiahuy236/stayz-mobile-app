import 'package:flutter/material.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';

/// Nguon duy nhat anh xa gia tri enum trong database sang nhan tieng Viet.
///
/// Truoc day moi man hinh tu bay ra danh sach cua rieng no: man Filter co 4 tien
/// ich tieng Anh, man chi tiet hardcode 6 tien ich khong lien quan toi du lieu,
/// man chon phong lai co tu dien rieng. Gio tat ca doc tu day.
class StayzTerm {
  const StayzTerm({required this.slug, required String label, this.enLabel, this.icon}) : _label = label;

  final String slug;
  final String _label;
  final String? enLabel;
  final IconData? icon;

  String get label => AppLocale.instance.isVietnamese ? _label : (enLabel ?? slug.replaceAll('_', ' '));
}

class StayzTaxonomy {
  const StayzTaxonomy._();

  /// Khop enum `city` trong `properties.model.js`.
  static const cities = <StayzTerm>[
    StayzTerm(slug: 'ha-noi', label: 'Hà Nội', enLabel: 'Hanoi'),
    StayzTerm(slug: 'da-nang', label: 'Đà Nẵng', enLabel: 'Da Nang'),
    StayzTerm(slug: 'da-lat', label: 'Đà Lạt', enLabel: 'Da Lat'),
    StayzTerm(slug: 'ho-chi-minh', label: 'TP.HCM', enLabel: 'Ho Chi Minh City'),
    StayzTerm(slug: 'vung-tau', label: 'Vũng Tàu', enLabel: 'Vung Tau'),
  ];

  /// Khop enum `type` trong `properties.model.js`.
  static const propertyTypes = <StayzTerm>[
    StayzTerm(slug: 'hotel', label: 'Khách sạn', enLabel: 'Hotel', icon: Icons.apartment_rounded),
    StayzTerm(slug: 'resort', label: 'Resort', enLabel: 'Resort', icon: Icons.beach_access_rounded),
    StayzTerm(slug: 'villa', label: 'Biệt thự', enLabel: 'Villa', icon: Icons.villa_rounded),
    StayzTerm(slug: 'apartment', label: 'Căn hộ', enLabel: 'Apartment', icon: Icons.house_rounded),
    StayzTerm(slug: 'business', label: 'Công tác', enLabel: 'Business', icon: Icons.business_center_rounded),
    StayzTerm(slug: 'hostel', label: 'Hostel', enLabel: 'Hostel', icon: Icons.bed_rounded),
  ];

  /// Khop enum `room_type` trong `rooms.model.js`.
  static const roomTypes = <StayzTerm>[
    StayzTerm(slug: 'standard_room', label: 'Tiêu chuẩn', enLabel: 'Standard'),
    StayzTerm(slug: 'deluxe_room', label: 'Deluxe', enLabel: 'Deluxe'),
    StayzTerm(slug: 'suite', label: 'Suite', enLabel: 'Suite'),
  ];

  /// Khop 10 khoa trong `properties.model.js -> amenities`.
  static const propertyAmenities = <StayzTerm>[
    StayzTerm(slug: 'free_wifi', label: 'Wifi miễn phí', enLabel: 'Free Wi-Fi', icon: Icons.wifi_rounded),
    StayzTerm(slug: 'outdoor_pool', label: 'Hồ bơi', enLabel: 'Outdoor pool', icon: Icons.pool_rounded),
    StayzTerm(slug: 'breakfast', label: 'Bữa sáng', enLabel: 'Breakfast', icon: Icons.free_breakfast_rounded),
    StayzTerm(slug: 'free_parking', label: 'Đỗ xe miễn phí', enLabel: 'Free parking', icon: Icons.local_parking_rounded),
    StayzTerm(slug: 'family_room', label: 'Phòng gia đình', enLabel: 'Family room', icon: Icons.family_restroom_rounded),
    StayzTerm(slug: 'restaurant', label: 'Nhà hàng', enLabel: 'Restaurant', icon: Icons.restaurant_rounded),
    StayzTerm(slug: 'airport_shuttle', label: 'Đưa đón sân bay', enLabel: 'Airport shuttle', icon: Icons.airport_shuttle_rounded),
    StayzTerm(slug: 'room_service', label: 'Phục vụ phòng', enLabel: 'Room service', icon: Icons.room_service_rounded),
    StayzTerm(slug: 'bar', label: 'Quầy bar', enLabel: 'Bar', icon: Icons.local_bar_rounded),
    StayzTerm(slug: 'non_smoking_room', label: 'Không hút thuốc', enLabel: 'Non-smoking room', icon: Icons.smoke_free_rounded),
  ];

  /// Khop `rooms.model.js -> amenities` va `-> badges`.
  static const roomAmenities = <StayzTerm>[
    StayzTerm(slug: 'air_conditioning', label: 'Điều hòa', enLabel: 'Air conditioning', icon: Icons.ac_unit_rounded),
    StayzTerm(slug: 'private_bathroom', label: 'Phòng tắm riêng', enLabel: 'Private bathroom', icon: Icons.bathtub_rounded),
    StayzTerm(slug: 'balcony', label: 'Ban công', enLabel: 'Balcony', icon: Icons.balcony_rounded),
    StayzTerm(slug: 'terrace', label: 'Sân hiên', enLabel: 'Terrace', icon: Icons.deck_rounded),
    StayzTerm(slug: 'garden_view', label: 'View vườn', enLabel: 'Garden view', icon: Icons.park_rounded),
    StayzTerm(slug: 'courtyard_view', label: 'View sân trong', enLabel: 'Courtyard view', icon: Icons.yard_rounded),
    StayzTerm(slug: 'free_wifi', label: 'Wifi', enLabel: 'Wi-Fi', icon: Icons.wifi_rounded),
    StayzTerm(slug: 'electric_kettle', label: 'Ấm đun nước', enLabel: 'Electric kettle', icon: Icons.coffee_rounded),
    StayzTerm(slug: 'hair_dryer', label: 'Máy sấy tóc', enLabel: 'Hair dryer', icon: Icons.dry_rounded),
    StayzTerm(slug: 'wardrobe', label: 'Tủ quần áo', enLabel: 'Wardrobe', icon: Icons.checkroom_rounded),
    StayzTerm(slug: 'sitting_area', label: 'Khu tiếp khách', enLabel: 'Sitting area', icon: Icons.weekend_rounded),
    StayzTerm(slug: 'slippers', label: 'Dép đi trong phòng', enLabel: 'Slippers', icon: Icons.spa_rounded),
    StayzTerm(slug: 'towels', label: 'Khăn tắm', enLabel: 'Towels', icon: Icons.dry_cleaning_rounded),
    StayzTerm(slug: 'shower', label: 'Vòi sen', enLabel: 'Shower', icon: Icons.shower_rounded),
    StayzTerm(slug: 'toiletries', label: 'Đồ vệ sinh cá nhân', enLabel: 'Toiletries', icon: Icons.soap_rounded),
    StayzTerm(slug: 'socket_near_bed', label: 'Ổ cắm cạnh giường', enLabel: 'Socket near the bed', icon: Icons.power_rounded),
    StayzTerm(slug: 'fan', label: 'Quạt', enLabel: 'Fan', icon: Icons.mode_fan_off_rounded),
    StayzTerm(slug: 'private_entrance', label: 'Lối vào riêng', enLabel: 'Private entrance', icon: Icons.door_front_door_rounded),
    StayzTerm(slug: 'clothes_rack', label: 'Giá treo đồ', enLabel: 'Clothes rack', icon: Icons.checkroom_rounded),
    StayzTerm(slug: 'toilet', label: 'Toilet', enLabel: 'Toilet', icon: Icons.wc_rounded),
    StayzTerm(slug: 'toilet_paper', label: 'Giấy vệ sinh', enLabel: 'Toilet paper', icon: Icons.inventory_2_rounded),
  ];

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

  static String bookingStatusLabel(String status) => switch (status) {
    'pending' => tr('Chờ xác nhận', 'Pending confirmation'),
    'confirmed' => tr('Đã xác nhận', 'Confirmed'),
    'completed' => tr('Đã hoàn tất', 'Completed'),
    'cancelled' => tr('Đã hủy', 'Cancelled'),
    _ => status,
  };
  static String paymentStatusLabel(String status) => switch (status) {
    'pending' => tr('Chưa thanh toán', 'Pending payment'),
    'paid' => tr('Đã thanh toán', 'Paid'),
    'failed' => tr('Thanh toán thất bại', 'Payment failed'),
    'refunded' => tr('Đã hoàn tiền', 'Refunded'),
    _ => status,
  };
}
