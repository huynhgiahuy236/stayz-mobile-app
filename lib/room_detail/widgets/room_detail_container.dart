import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'room_detail_text.dart';

class StayZColors {
  static const background = Color(0xFFF5F0E8);
  static const ink = Color(0xFF1A1612);
  static const white = Color(0xFFFFFFFF);
  static const orange = Color(0xFF8B3A3A);
  static const orangeLight = Color(0xFFC4736A);
  static const orangeDark = Color(0xFF5C2020);
  static const orangeSoft = Color(0xFFFAF0EE);
  static const muted = Color(0xFF7A6E60);
  static const softMuted = Color(0xFFA69E92);
  static const border = Color(0xFFD4C9B5);
  static const divider = Color(0xFFEAE4D8);
  static const n700 = Color(0xFF3D3530);
  static const n800 = Color(0xFF2C2820);
  static const gold = Color(0xFFC4963A);
  static const goldSoft = Color(0xFFFAF3E0);
  static const green = Color(0xFF3B6D11);
  static const greenSoft = Color(0xFFEAF3DE);
  static const warning = Color(0xFFBA7517);
  static const warningSoft = Color(0xFFFAEEDA);
  static const error = Color(0xFFA32D2D);
}

class StayZHotel {
  const StayZHotel({
    required this.name,
    required this.subtitle,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.heroImage,
    required this.hostImage,
    required this.rooms,
    required this.amenities,
    required this.description,
  });

  final String name;
  final String subtitle;
  final String location;
  final double rating;
  final int reviewCount;
  final String heroImage;
  final String hostImage;
  final List<StayZRoomOption> rooms;
  final List<AmenityItem> amenities;
  final String description;
}

class StayZRoomOption {
  const StayZRoomOption({
    required this.name,
    required this.meta,
    required this.price,
    required this.image,
    required this.tags,
    this.best = false,
  });

  final String name;
  final String meta;
  final int price;
  final String image;
  final List<String> tags;
  final bool best;
}

class AmenityItem {
  const AmenityItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const stayZHotel = StayZHotel(
  name: 'Ana Mandara Villas Đà Lạt',
  subtitle: 'Resort 5 sao',
  location: 'Đường Lê Lai, Phường 5, Đà Lạt',
  rating: 4.9,
  reviewCount: 124,
  heroImage:
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=85',
  hostImage:
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=240&q=80',
  description:
      'Trải nghiệm sự tinh tế vượt thời gian tại Ana Mandara Villas Đà Lạt. Tọa lạc trên sườn đồi thơ mộng, khu nghỉ dưỡng là quần thể biệt thự mang kiến trúc Pháp cổ, bao quanh bởi rừng thông và khu vườn yên tĩnh.',
  amenities: [
    AmenityItem(icon: LucideIcons.wifi, label: 'Wifi'),
    AmenityItem(icon: LucideIcons.wind, label: 'Điều hòa'),
    AmenityItem(icon: LucideIcons.car, label: 'Đỗ xe'),
    AmenityItem(icon: LucideIcons.coffee, label: 'Ăn sáng'),
    AmenityItem(icon: LucideIcons.waves, label: 'Hồ bơi'),
    AmenityItem(icon: LucideIcons.flower2, label: 'Spa'),
  ],
  rooms: [
    StayZRoomOption(
      name: 'Deluxe Garden View',
      meta: '1 giường đôi · 32m² · Hướng vườn',
      price: 3400000,
      best: true,
      tags: ['Bữa sáng', 'Miễn phí hủy', 'Còn 2 phòng'],
      image:
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=500&q=80',
    ),
    StayZRoomOption(
      name: 'Suite Mountain View',
      meta: '1 giường King · 48m² · Hướng núi',
      price: 5200000,
      tags: ['Bồn tắm', 'Ban công', 'Trà chiều'],
      image:
          'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=500&q=80',
    ),
  ],
);

class StayZCard extends StatelessWidget {
  const StayZCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = StayZColors.border,
    this.color = StayZColors.white,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StayZNetworkImage extends StatelessWidget {
  const StayZNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _ImagePlaceholder(width: width, height: height);
      },
      errorBuilder: (_, _, _) =>
          _ImagePlaceholder(width: width, height: height, showIcon: true),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.width, this.height, this.showIcon = false});

  final double? width;
  final double? height;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: StayZColors.divider,
        borderRadius: BorderRadius.circular(10),
      ),
      child: showIcon
          ? const Icon(LucideIcons.image, color: StayZColors.muted, size: 28)
          : const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }
}

class StayZBadge extends StatelessWidget {
  const StayZBadge({
    super.key,
    required this.text,
    this.color = StayZColors.orange,
    this.background = StayZColors.orangeSoft,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: RoomDetailText(
        text: text,
        color: color,
        size: 10,
        weight: FontWeight.w500,
        letterSpacing: 0.8,
        height: 1,
      ),
    );
  }
}

class AmenityGrid extends StatelessWidget {
  const AmenityGrid({super.key, required this.items});

  final List<AmenityItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.26,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: StayZColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StayZColors.divider, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: StayZColors.orange, size: 22),
              const SizedBox(height: 9),
              RoomDetailText(
                text: item.label,
                size: 12,
                weight: FontWeight.w400,
                height: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoomOptionCard extends StatelessWidget {
  const RoomOptionCard({super.key, required this.room, this.onTap});

  final StayZRoomOption room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: StayZColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: room.best ? StayZColors.orange : StayZColors.border,
            width: room.best ? 1.5 : 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StayZNetworkImage(
                    url: room.image,
                    width: 96,
                    height: 104,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RoomDetailText(
                          text: room.name,
                          size: 15,
                          weight: FontWeight.w500,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        RoomDetailText(
                          text: room.meta,
                          color: StayZColors.muted,
                          size: 12,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: room.tags
                              .map(
                                (tag) => StayZBadge(
                                  text: tag,
                                  color: StayZColors.muted,
                                  background: StayZColors.background,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        RoomDetailText(
                          text: formatVND(room.price),
                          color: StayZColors.orange,
                          size: 16,
                          role: StayZTextRole.mono,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (room.best)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: const BoxDecoration(
                    color: StayZColors.orange,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const RoomDetailText(
                    text: 'TỐT NHẤT',
                    color: StayZColors.background,
                    size: 10,
                    weight: FontWeight.w500,
                    letterSpacing: 0.8,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String formatVND(int value) {
  final text = value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '₫$text';
}
