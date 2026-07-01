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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.home),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            28 * responsive.scale,
            responsive.horizontalPadding,
            28 * responsive.scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StayZLogoRow(),
              SizedBox(height: 34 * responsive.scale),
              Text(
                'CHAO BUOI SANG',
                style: TextStyle(
                  color: const Color(0xFF5A3F3F),
                  fontSize: 11 * responsive.scale,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8 * responsive.scale),
              RichText(
                text: TextSpan(
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppTheme.ink,
                    fontSize: 26 * responsive.scale,
                    height: 1.18,
                  ),
                  children: const [
                    TextSpan(text: 'Ban muon nghi ngoi o '),
                    TextSpan(
                      text: 'dau',
                      style: TextStyle(color: AppTheme.accent, fontStyle: FontStyle.italic),
                    ),
                    TextSpan(text: '\nhom nay?'),
                  ],
                ),
              ),
              SizedBox(height: 34 * responsive.scale),
              const SearchBox(),
              SizedBox(height: 32 * responsive.scale),
              SizedBox(
                height: 46 * responsive.scale,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    FilterPill(label: 'Tat ca', active: true),
                    SizedBox(width: 14),
                    FilterPill(label: 'Gan day'),
                    SizedBox(width: 14),
                    FilterPill(label: 'Cao cap'),
                  ],
                ),
              ),
              SizedBox(height: 46 * responsive.scale),
              const SectionLabel(title: 'Noi bat', action: 'Xem tat ca'),
              SizedBox(height: 20 * responsive.scale),
              SizedBox(
                height: 294 * responsive.scale,
                child: FutureBuilder<List<HotelSummary>>(
                  future: MockStayzRepository.instance.getHotelSummaries(),
                  builder: (context, snapshot) {
                    final hotels = (snapshot.data ?? const <HotelSummary>[]).take(3).toList();

                    if (hotels.isEmpty && snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                    }

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hotels.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 18),
                      itemBuilder: (context, index) {
                        final summary = hotels[index];
                        return HotelCard(
                          name: summary.hotel.name,
                          location: summary.city.name,
                          price: '${StayzFormatters.compactVnd(summary.lowestPrice)} / dem',
                          colors: _homeHotelColors[index % _homeHotelColors.length],
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 48 * responsive.scale),
              const SectionLabel(title: 'Gan ban'),
              SizedBox(height: 20 * responsive.scale),
              FutureBuilder<List<HotelSummary>>(
                future: MockStayzRepository.instance.getHotelSummaries(),
                builder: (context, snapshot) {
                  final hotels = (snapshot.data ?? const <HotelSummary>[]).skip(2).take(3).toList();

                  return Wrap(
                    spacing: 18 * responsive.widthScale,
                    runSpacing: 18 * responsive.scale,
                    children: [
                      for (var i = 0; i < hotels.length; i++)
                        HotelCard(
                          compact: true,
                          name: hotels[i].hotel.name,
                          location: hotels[i].city.name,
                          price: StayzFormatters.compactVnd(hotels[i].lowestPrice),
                          colors: _homeHotelColors[(i + 2) % _homeHotelColors.length],
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _homeHotelColors = [
  [Color(0xFF405F59), Color(0xFF0F1917)],
  [Color(0xFFC98232), Color(0xFF4C1B14)],
  [Color(0xFF8D7159), Color(0xFF19110C)],
  [Color(0xFFC9A36B), Color(0xFF362116)],
  [Color(0xFF5D7D8F), Color(0xFF151E24)],
];
