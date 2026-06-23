import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../room_selection/room_selection_page.dart';
import 'widgets/room_detail_app_bar.dart';
import 'widgets/room_detail_container.dart';
import 'widgets/room_detail_text.dart';

class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    const hotel = stayZHotel;

    return Scaffold(
      backgroundColor: StayZColors.background,
      body: CustomScrollView(
        slivers: [
          const RoomDetailAppBar(hotel: hotel),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 112),
            sliver: SliverList.list(
              children: [
                _HotelHeader(hotel: hotel),
                const SizedBox(height: 20),
                _HostCard(hotel: hotel),
                const SizedBox(height: 32),
                SectionTitle('Tiện nghi nổi bật'),
                const SizedBox(height: 12),
                AmenityGrid(items: hotel.amenities),
                const SizedBox(height: 32),
                _DescriptionSection(hotel: hotel),
                const SizedBox(height: 32),
                _ReviewSection(hotel: hotel),
                const SizedBox(height: 32),
                const _PolicySection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBookingBar(
        onBook: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoomSelectionPage()),
          );
        },
      ),
    );
  }
}

class _HotelHeader extends StatelessWidget {
  const _HotelHeader({required this.hotel});

  final StayZHotel hotel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoomDetailText(
          text: hotel.name,
          size: 22,
          weight: FontWeight.w400,
          height: 1.3,
          role: StayZTextRole.display,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RoomDetailText(
              text: hotel.subtitle,
              color: StayZColors.muted,
              size: 13,
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.star, color: StayZColors.gold, size: 16),
            const SizedBox(width: 4),
            RoomDetailText(
              text: '${hotel.rating} (${hotel.reviewCount} đánh giá)',
              size: 13,
              color: StayZColors.muted,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(LucideIcons.mapPin, size: 18, color: StayZColors.muted),
            SizedBox(width: 6),
            RoomDetailText(
              text: 'Xem trên bản đồ ->',
              size: 13,
              decoration: TextDecoration.underline,
            ),
          ],
        ),
      ],
    );
  }
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.hotel});

  final StayZHotel hotel;

  @override
  Widget build(BuildContext context) {
    return StayZCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          StayZNetworkImage(
            url: hotel.hostImage,
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoomDetailText(
                  text: 'Khách sạn Ana Mandara',
                  size: 14,
                  weight: FontWeight.w500,
                ),
                RoomDetailText(
                  text: 'Hoạt động từ 2012',
                  color: StayZColors.muted,
                  size: 12,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.messageSquare, size: 16),
              label: const Text('LIÊN HỆ'),
              style: FilledButton.styleFrom(
                backgroundColor: StayZColors.orange,
                foregroundColor: StayZColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.hotel});

  final StayZHotel hotel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Mô tả'),
        const SizedBox(height: 12),
        RoomDetailText(
          text: hotel.description,
          size: 15,
          height: 1.6,
          color: StayZColors.n700,
        ),
        const SizedBox(height: 8),
        const RoomDetailText(
          text: 'Đọc thêm',
          color: StayZColors.orange,
          size: 12,
          weight: FontWeight.w500,
          letterSpacing: 0.7,
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.hotel});

  final StayZHotel hotel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(
          'Đánh giá khách hàng',
          trailing: '${hotel.rating} (${hotel.reviewCount})',
        ),
        const SizedBox(height: 12),
        StayZCard(
          borderColor: StayZColors.divider,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              StayZNetworkImage(
                url:
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=160&q=80',
                width: 36,
                height: 36,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoomDetailText(
                      text: 'Minh Tú',
                      size: 13,
                      weight: FontWeight.w500,
                    ),
                    SizedBox(height: 2),
                    RoomDetailText(
                      text: '★★★★★',
                      color: StayZColors.gold,
                      size: 11,
                      letterSpacing: 1,
                    ),
                    SizedBox(height: 8),
                    RoomDetailText(
                      text:
                          '"Không gian cực kỳ yên tĩnh và sang trọng. Nhân viên phục vụ rất chu đáo. Chắc chắn sẽ quay lại!"',
                      size: 13,
                      height: 1.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Chính sách'),
        SizedBox(height: 18),
        _PolicyRow(
          icon: LucideIcons.clock,
          title: 'Giờ nhận phòng',
          subtitle: 'Check-in 14:00 · Check-out 12:00',
        ),
        SizedBox(height: 18),
        _PolicyRow(
          icon: LucideIcons.shieldCheck,
          title: 'Hủy miễn phí',
          subtitle: 'Hoàn trả 100% khi hủy trước 48 giờ nhận phòng.',
          accent: StayZColors.orange,
        ),
      ],
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accent = StayZColors.muted,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoomDetailText(
                text: title,
                size: 14,
                weight: FontWeight.w500,
                color: accent,
              ),
              const SizedBox(height: 3),
              RoomDetailText(text: subtitle, size: 13, height: 1.5),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
  const _BottomBookingBar({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        28,
        12,
        28,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: StayZColors.white,
        border: Border(top: BorderSide(color: StayZColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoomDetailText(
                  text: 'TỪ',
                  color: StayZColors.muted,
                  size: 10,
                  weight: FontWeight.w500,
                  letterSpacing: 1,
                ),
                SizedBox(height: 4),
                RoomDetailText(
                  text: '₫3.4M',
                  color: StayZColors.orange,
                  size: 16,
                  role: StayZTextRole.mono,
                  height: 1,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onBook,
              style: FilledButton.styleFrom(
                backgroundColor: StayZColors.orange,
                foregroundColor: StayZColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('CHỌN PHÒNG'),
            ),
          ),
        ],
      ),
    );
  }
}
