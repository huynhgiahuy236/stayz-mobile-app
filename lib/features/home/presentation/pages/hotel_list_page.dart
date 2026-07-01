import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class HotelListPage extends StatelessWidget {
  const HotelListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF1EE),
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.bookings),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                26 * responsive.scale,
                responsive.horizontalPadding,
                26 * responsive.scale,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chuyến đi của tôi',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 32 * responsive.scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 22 * responsive.scale,
                    backgroundColor: const Color(0xFFD8C5B7),
                    child: const Icon(Icons.person, color: AppTheme.accentDark),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.neutral200.withValues(alpha: 0.8), height: 1),
            SizedBox(
              height: 76 * responsive.scale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _BookingTab(label: 'Sắp tới', active: true),
                  _BookingTab(label: 'Đã hoàn thành'),
                  _BookingTab(label: 'Đã hủy'),
                ],
              ),
            ),
            Divider(color: AppTheme.neutral200.withValues(alpha: 0.6), height: 1),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  const BookingPreviewCard(
                    name: 'The Mist Retreat',
                    location: 'Phường 10, Đà Lạt',
                    date: '11 Th10 - 14 Th10, 2024',
                    total: '₫3.520.000',
                    colors: [Color(0xFF314B4A), Color(0xFF0F1514)],
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  const BookingPreviewCard(
                    name: 'Silk Path Heritage',
                    location: 'Cẩm Phô, Hội An',
                    date: '02 Th11 - 05 Th11, 2024',
                    total: '₫5.180.000',
                    colors: [Color(0xFFC18B35), Color(0xFF314321)],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTab extends StatelessWidget {
  const _BookingTab({
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accentDark : const Color(0xFF5A3F3F),
            fontSize: 16 * responsive.scale,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        SizedBox(height: 10 * responsive.scale),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: active ? AppTheme.accent : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
