import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
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
                  FutureBuilder<List<HotelSummary>>(
                    future: MockStayzRepository.instance.getHotelSummaries(),
                    builder: (context, snapshot) {
                      final hotels = snapshot.data ?? const <HotelSummary>[];

                      if (hotels.isEmpty && snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${hotels.length} khach san dang co',
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
                          for (var i = 0; i < hotels.length; i++) ...[
                            SearchHotelCard(
                              name: hotels[i].hotel.name,
                              location: hotels[i].city.name,
                              price: StayzFormatters.fullVnd(hotels[i].lowestPrice),
                              reviewCount: (80 + (i * 47)).toString(),
                              badge: hotels[i].availableRooms <= 2 ? 'Con ${hotels[i].availableRooms} phong' : null,
                              favorite: i == 0,
                              colors: _searchHotelColors[i % _searchHotelColors.length],
                            ),
                            if (i != hotels.length - 1) SizedBox(height: 28 * responsive.scale),
                          ],
                        ],
                      );
                    },
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

const _searchHotelColors = [
  [Color(0xFFE8EEE9), Color(0xFF657E6B)],
  [Color(0xFF7A8D66), Color(0xFF1F2F26)],
  [Color(0xFFD7ECF5), Color(0xFF5F8C9B)],
  [Color(0xFF80512E), Color(0xFF32170B)],
  [Color(0xFFC6A668), Color(0xFF2C2720)],
];

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
