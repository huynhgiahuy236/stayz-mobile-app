import 'package:capstone_mobile/app/routes/app_routes.dart';
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
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StayZScreenHeader(
              title: 'Tìm nơi lưu trú',
              subtitle: 'Tìm kiếm',
              trailing: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.filter),
                icon: const Icon(Icons.tune_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primarySoft,
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: _SearchInputCard(responsive: responsive),
            ),
            SizedBox(height: 14 * responsive.scale),
            SizedBox(
              height: 42 * responsive.scale,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                children: const [
                  FilterPill(label: '12 - 14/07', active: true, icon: Icons.calendar_month_rounded),
                  SizedBox(width: 10),
                  FilterPill(label: '2 khách', icon: Icons.group_rounded),
                  SizedBox(width: 10),
                  FilterPill(label: 'Dưới 2 triệu', icon: Icons.payments_rounded),
                  SizedBox(width: 10),
                  FilterPill(label: '4 sao+', icon: Icons.star_rounded),
                ],
              ),
            ),
            SizedBox(height: 16 * responsive.scale),
            Expanded(
              child: FutureBuilder<List<HotelSummary>>(
                future: MockStayzRepository.instance.getHotelSummaries(),
                builder: (context, snapshot) {
                  final hotels = snapshot.data ?? const <HotelSummary>[];

                  if (hotels.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      0,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: hotels.length + 1,
                    separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 16 * responsive.scale : 18 * responsive.scale),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ResultToolbar(count: hotels.length);
                      }

                      final hotelIndex = index - 1;
                      final summary = hotels[hotelIndex];
                      return SearchHotelCard(
                        name: summary.hotel.name,
                        location: '${summary.city.name}, ${summary.city.region}',
                        price: StayzFormatters.fullVnd(summary.lowestPrice),
                        reviewCount: (96 + hotelIndex * 31).toString(),
                        badge: summary.availableRooms <= 2 ? 'Còn ${summary.availableRooms} phòng' : 'Đề xuất',
                        favorite: hotelIndex == 0,
                        imageUrl: summary.hotel.imageUrls.firstOrNull,
                        colors: _searchHotelColors[hotelIndex % _searchHotelColors.length],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInputCard extends StatelessWidget {
  const _SearchInputCard({required this.responsive});

  final HomeResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.line),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44 * responsive.scale,
            height: 44 * responsive.scale,
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 22 * responsive.scale),
          ),
          SizedBox(width: 12 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Điểm đến', style: TextStyle(color: AppTheme.muted, fontSize: 12 * responsive.scale, fontWeight: FontWeight.w700)),
                SizedBox(height: 3 * responsive.scale),
                Text('Đà Nẵng, Việt Nam', style: TextStyle(color: AppTheme.ink, fontSize: 16 * responsive.scale, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.filter),
            child: const Text('Đổi'),
          ),
        ],
      ),
    );
  }
}

class _ResultToolbar extends StatelessWidget {
  const _ResultToolbar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            '$count khách sạn phù hợp',
            style: TextStyle(color: AppTheme.ink, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          padding: EdgeInsets.all(4 * responsive.scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            children: const [
              _SegmentButton(label: 'List', active: true, icon: Icons.view_agenda_rounded),
              _SegmentButton(label: 'Map', icon: Icons.map_rounded),
            ],
          ),
        ),
      ],
    );
  }
}

const _searchHotelColors = [
  [Color(0xFFEAF7FF), Color(0xFF1D8BD1)],
  [Color(0xFFDDEEFF), Color(0xFF0A4E83)],
  [Color(0xFFF8FCFF), Color(0xFF3A95D8)],
  [Color(0xFFC6E4F7), Color(0xFF2378C9)],
  [Color(0xFFE0F0FB), Color(0xFF135D95)],
];

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: 10 * responsive.widthScale, vertical: 8 * responsive.scale),
      decoration: BoxDecoration(
        color: active ? AppTheme.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? Colors.white : AppTheme.muted, size: 16 * responsive.scale),
          SizedBox(width: 5 * responsive.widthScale),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppTheme.muted,
              fontSize: 12 * responsive.scale,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
