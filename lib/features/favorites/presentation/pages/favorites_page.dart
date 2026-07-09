import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/favorites/presentation/widgets/favorites_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<HotelSummary>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = ApiStayzRepository.instance.getFavoriteHotelSummaries();
  }

  Future<void> _removeFavorite(HotelSummary summary) async {
    try {
      await ApiStayzRepository.instance.removeFavorite(summary.hotel.id);
      if (!mounted) return;
      setState(() {
        _favoritesFuture = ApiStayzRepository.instance.getFavoriteHotelSummaries();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da bo khoi yeu thich.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long dang nhap de cap nhat yeu thich.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.saved),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StayZScreenHeader(
              title: 'Danh sách đã lưu',
              subtitle: 'Đã lưu',
              trailing: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primarySoft, foregroundColor: AppTheme.primary),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                0,
                responsive.horizontalPadding,
                16 * responsive.scale,
              ),
              child: _SavedHero(responsive: responsive),
            ),
            Expanded(
              child: FutureBuilder<List<HotelSummary>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  final hotels = snapshot.data ?? const <HotelSummary>[];

                  if (hotels.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  if (hotels.isEmpty) {
                    return _EmptySavedState(responsive: responsive);
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      0,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: hotels.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16 * responsive.scale),
                    itemBuilder: (context, index) {
                      final summary = hotels[index];
                      return FavoriteHotelCard(
                        name: summary.hotel.name,
                        location: '${summary.city.name}, ${summary.city.region}',
                        price: StayzFormatters.compactVnd(summary.lowestPrice),
                        rating: summary.rating.toStringAsFixed(1),
                        imageUrl: summary.hotel.imageUrls.firstOrNull,
                        colors: _favoriteColors[index % _favoriteColors.length],
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.roomDetail,
                          arguments: summary,
                        ),
                        onBook: () => Navigator.of(context).pushNamed(
                          AppRoutes.roomSelection,
                          arguments: RoomSelectionArgs(hotel: summary),
                        ),
                        onFavoriteTap: () => _removeFavorite(summary),
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

class _SavedHero extends StatelessWidget {
  const _SavedHero({required this.responsive});

  final HomeResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 52 * responsive.scale,
            height: 52 * responsive.scale,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white),
          ),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bộ sưu tập cho chuyến đi', style: TextStyle(color: AppTheme.ink, fontSize: 16 * responsive.scale, fontWeight: FontWeight.w900)),
                SizedBox(height: 5 * responsive.scale),
                Text('Chạm vào khách sạn để xem phòng và đặt lịch.', style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState({required this.responsive});

  final HomeResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded, color: AppTheme.primary, size: 52 * responsive.scale),
            SizedBox(height: 16 * responsive.scale),
            Text('Chưa có nơi lưu', style: TextStyle(color: AppTheme.ink, fontSize: 22 * responsive.scale, fontWeight: FontWeight.w900)),
            SizedBox(height: 8 * responsive.scale),
            Text('Khám phá khách sạn và lưu lại lựa chọn phù hợp.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 14 * responsive.scale)),
            SizedBox(height: 18 * responsive.scale),
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
              child: const Text('Tìm khách sạn'),
            ),
          ],
        ),
      ),
    );
  }
}

const _favoriteColors = [
  [Color(0xFFEAF7FF), Color(0xFF1D8BD1)],
  [Color(0xFFDDEEFF), Color(0xFF0A4E83)],
  [Color(0xFFF8FCFF), Color(0xFF3A95D8)],
  [Color(0xFFC6E4F7), Color(0xFF2378C9)],
  [Color(0xFFE0F0FB), Color(0xFF135D95)],
];
