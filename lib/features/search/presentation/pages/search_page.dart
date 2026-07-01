import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                24 * responsive.widthScale,
                12 * responsive.scale,
                24 * responsive.widthScale,
                18 * responsive.scale,
              ),
              child: const SearchHeader(),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  0,
                  responsive.horizontalPadding,
                  28 * responsive.scale,
                ),
                children: [
                  SizedBox(
                    height: 42 * responsive.scale,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        FilterPill(label: '12 - 14 thang 7'),
                        SizedBox(width: 10),
                        FilterPill(label: '2 nguoi'),
                      ],
                    ),
                  ),
                  SizedBox(height: 22 * responsive.scale),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '18 khach san tai Da Lat',
                          style: TextStyle(
                            color: AppTheme.neutral500,
                            fontSize: 14 * responsive.scale,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5 * responsive.scale),
                        decoration: BoxDecoration(
                          color: AppTheme.neutral200.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _SegmentButton(label: 'Danh sach', active: true),
                            _SegmentButton(label: 'Ban do'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * responsive.scale),
                  const SearchHotelCard(
                    name: 'Da Lat Palace Heritage Hotel',
                    location: 'Phuong 1, Da Lat',
                    price: 'd1.800.000',
                    reviewCount: '128',
                    badge: 'Con 2 phong',
                    favorite: true,
                    colors: [Color(0xFFE8EEE9), Color(0xFF657E6B)],
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  const SearchHotelCard(
                    name: 'Ana Mandara Villas Dalat Resort & Spa',
                    location: 'Phuong 3, Da Lat',
                    price: 'd2.200.000',
                    reviewCount: '456',
                    colors: [Color(0xFF7A8D66), Color(0xFF1F2F26)],
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  const SearchHotelCard(
                    name: 'Villa Dalat - Pine View Retreat',
                    location: 'Phuong 10, Da Lat',
                    price: 'd950.000',
                    reviewCount: '82',
                    badge: 'Gia tot',
                    colors: [Color(0xFFD7ECF5), Color(0xFF5F8C9B)],
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

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * responsive.widthScale,
        vertical: 7 * responsive.scale,
      ),
      decoration: BoxDecoration(
        color: active ? AppTheme.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppTheme.neutral500,
          fontSize: 12 * responsive.scale,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
