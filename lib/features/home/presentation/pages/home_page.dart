import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.home),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<HotelSummary>>(
          future: MockStayzRepository.instance.getHotelSummaries(),
          builder: (context, snapshot) {
            final hotels = snapshot.data ?? const <HotelSummary>[];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      18 * responsive.scale,
                      responsive.horizontalPadding,
                      0,
                    ),
                    child: const StayZLogoRow(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      26 * responsive.scale,
                      responsive.horizontalPadding,
                      0,
                    ),
                    child: _HomeHero(
                      featured: hotels.isEmpty ? null : hotels.first,
                      loading: hotels.isEmpty && snapshot.connectionState != ConnectionState.done,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      22 * responsive.scale,
                      responsive.horizontalPadding,
                      0,
                    ),
                    child: const SearchBox(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      18 * responsive.scale,
                      0,
                      0,
                    ),
                    child: SizedBox(
                      height: 42 * responsive.scale,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        children: const [
                          FilterPill(label: 'Gần bạn', active: true, icon: Icons.near_me_rounded),
                          SizedBox(width: 10),
                          FilterPill(label: 'Cao cấp', icon: Icons.diamond_rounded),
                          SizedBox(width: 10),
                          FilterPill(label: 'Gia đình', icon: Icons.family_restroom_rounded),
                          SizedBox(width: 10),
                          FilterPill(label: 'Biển', icon: Icons.beach_access_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      30 * responsive.scale,
                      responsive.horizontalPadding,
                      14 * responsive.scale,
                    ),
                    child: SectionLabel(
                      title: 'Khách sạn nổi bật',
                      action: 'Xem tất cả',
                      onAction: () => Navigator.of(context).pushNamed(AppRoutes.search),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 286 * responsive.scale,
                    child: hotels.isEmpty && snapshot.connectionState != ConnectionState.done
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                            scrollDirection: Axis.horizontal,
                            itemCount: hotels.take(4).length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final summary = hotels[index];
                              return HotelCard(
                                name: summary.hotel.name,
                                location: summary.city.name,
                                price: '${StayzFormatters.compactVnd(summary.lowestPrice)} / đêm',
                                imageUrl: summary.hotel.imageUrls.firstOrNull,
                                colors: _homeHotelColors[index % _homeHotelColors.length],
                              );
                            },
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      30 * responsive.scale,
                      responsive.horizontalPadding,
                      14 * responsive.scale,
                    ),
                    child: SectionLabel(
                      title: 'Lịch trình tiếp theo',
                      action: 'Quản lý',
                      onAction: () => Navigator.of(context).pushNamed(AppRoutes.myBookings),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                    child: BookingPreviewCard(
                      name: hotels.isEmpty ? 'StayZ Grand' : hotels.first.hotel.name,
                      location: hotels.isEmpty ? 'Da Nang' : hotels.first.city.name,
                      date: '12 - 14/07',
                      total: hotels.isEmpty ? '2.4M' : StayzFormatters.compactVnd(hotels.first.lowestPrice * 2),
                      colors: _homeHotelColors[1],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      30 * responsive.scale,
                      responsive.horizontalPadding,
                      14 * responsive.scale,
                    ),
                    child: const SectionLabel(title: 'Gợi ý gần bạn'),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final nearbyHotels = hotels.skip(2).take(3).toList();
                      final summary = nearbyHotels[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          responsive.horizontalPadding,
                          index == 0 ? 0 : 14 * responsive.scale,
                          responsive.horizontalPadding,
                          0,
                        ),
                        child: HotelCard(
                          fullWidth: true,
                          name: summary.hotel.name,
                          location: '${summary.city.name}, ${summary.city.region}',
                          price: '${StayzFormatters.compactVnd(summary.lowestPrice)} / đêm',
                          imageUrl: summary.hotel.imageUrls.firstOrNull,
                          colors: _homeHotelColors[(index + 2) % _homeHotelColors.length],
                        ),
                      );
                    },
                    childCount: hotels.skip(2).take(3).length,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 28 * responsive.scale)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.featured,
    required this.loading,
  });

  final HotelSummary? featured;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * responsive.widthScale, vertical: 6 * responsive.scale),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'BOOKING FLOW',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11 * responsive.scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
          SizedBox(height: 16 * responsive.scale),
          Text(
            'Tìm phòng đẹp,\nđặt lịch gọn trong vài chạm.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28 * responsive.scale,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          SizedBox(height: 16 * responsive.scale),
          Text(
            loading
                ? 'Đang tải gợi ý tốt nhất cho bạn...'
                : 'Gợi ý hôm nay: ${featured?.hotel.name ?? 'StayZ Collection'}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14 * responsive.scale,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 18 * responsive.scale),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Tìm phòng'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                ),
              ),
              SizedBox(width: 12 * responsive.widthScale),
              IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.favorites),
                icon: const Icon(Icons.favorite_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                  minimumSize: Size(52 * responsive.scale, 52 * responsive.scale),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _homeHotelColors = [
  [Color(0xFFEAF7FF), Color(0xFF1D8BD1)],
  [Color(0xFFDDEEFF), Color(0xFF0A4E83)],
  [Color(0xFFF8FCFF), Color(0xFF3A95D8)],
  [Color(0xFFC6E4F7), Color(0xFF2378C9)],
  [Color(0xFFE0F0FB), Color(0xFF135D95)],
];
