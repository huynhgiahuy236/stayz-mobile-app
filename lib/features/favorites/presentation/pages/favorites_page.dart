import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/favorites/presentation/widgets/favorites_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.saved),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                18 * responsive.scale,
                responsive.horizontalPadding,
                20 * responsive.scale,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cream,
                border: Border(
                  bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.55)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.menu_rounded, color: AppTheme.accentDark, size: 26 * responsive.scale),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8 * responsive.scale),
                      side: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.6)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Yêu thích',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Noto Serif JP',
                        color: AppTheme.accentDark,
                        fontSize: 26 * responsive.scale,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 42 * responsive.scale,
                    height: 42 * responsive.scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppTheme.neutral200.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.accentDark,
                        size: 22 * responsive.scale,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<HotelSummary>>(
                future: MockStayzRepository.instance.getFavoriteHotelSummaries(),
                builder: (context, snapshot) {
                  final hotels = snapshot.data ?? const <HotelSummary>[];

                  if (hotels.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                      vertical: 24 * responsive.scale,
                    ),
                    itemCount: hotels.length,
                    separatorBuilder: (_, __) => SizedBox(height: 20 * responsive.scale),
                    itemBuilder: (context, index) {
                      return FavoriteHotelCard(
                        name: hotels[index].hotel.name,
                        location: hotels[index].city.name,
                        price: StayzFormatters.compactVnd(hotels[index].lowestPrice),
                        rating: hotels[index].rating.toStringAsFixed(1),
                        imageUrl: hotels[index].hotel.imageUrls.firstOrNull,
                        colors: _favoriteColors[index % _favoriteColors.length],
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

const _favoriteColors = [
  [Color(0xFF4A311F), Color(0xFFD6C291)],
  [Color(0xFF285D45), Color(0xFFE58A1A)],
  [Color(0xFF302217), Color(0xFF728A5B)],
  [Color(0xFF4E473D), Color(0xFFE5C9A0)],
  [Color(0xFF96F0F7), Color(0xFF007CA0)],
];
