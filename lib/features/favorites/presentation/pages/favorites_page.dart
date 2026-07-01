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
                color: const Color(0xFFFBF7F4),
                border: Border(
                  bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.55)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu, color: AppTheme.accentDark, size: 28 * responsive.scale),
                  Expanded(
                    child: Text(
                      'Yeu thich',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 22 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 20 * responsive.scale,
                    backgroundColor: const Color(0xFFD8C5B7),
                    child: Icon(Icons.person, color: AppTheme.accentDark, size: 22 * responsive.scale),
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

                  return GridView.count(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      42 * responsive.scale,
                      responsive.horizontalPadding,
                      28 * responsive.scale,
                    ),
                    crossAxisCount: 2,
                    crossAxisSpacing: 22 * responsive.widthScale,
                    mainAxisSpacing: 22 * responsive.scale,
                    childAspectRatio: 0.43,
                    children: [
                      for (var i = 0; i < hotels.length; i++)
                        FavoriteHotelCard(
                          name: hotels[i].hotel.name,
                          location: hotels[i].city.name,
                          price: StayzFormatters.compactVnd(hotels[i].lowestPrice),
                          rating: hotels[i].rating.toStringAsFixed(1),
                          colors: _favoriteColors[i % _favoriteColors.length],
                        ),
                    ],
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
