import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
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
                'CHÀO BUỔI SÁNG',
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
                    TextSpan(text: 'Bạn muốn nghỉ ngơi ở '),
                    TextSpan(
                      text: 'đâu',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(text: '\nhôm nay?'),
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
                    FilterPill(label: 'Tất cả', active: true),
                    SizedBox(width: 14),
                    FilterPill(label: 'Gần đây'),
                    SizedBox(width: 14),
                    FilterPill(label: 'Cao cấp'),
                  ],
                ),
              ),
              SizedBox(height: 46 * responsive.scale),
              const SectionLabel(title: 'Nổi bật', action: 'Xem tất cả'),
              SizedBox(height: 20 * responsive.scale),
              SizedBox(
                height: 294 * responsive.scale,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    HotelCard(
                      name: 'The Mist Retreat',
                      location: 'Đà Lạt',
                      price: '₫1.2M / đêm',
                      colors: [Color(0xFF405F59), Color(0xFF0F1917)],
                    ),
                    SizedBox(width: 18),
                    HotelCard(
                      name: 'Lantern House',
                      location: 'Hội An',
                      price: '₫890K / đêm',
                      colors: [Color(0xFFC98232), Color(0xFF4C1B14)],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48 * responsive.scale),
              const SectionLabel(title: 'Gần bạn'),
              SizedBox(height: 20 * responsive.scale),
              Wrap(
                spacing: 18 * responsive.widthScale,
                runSpacing: 18 * responsive.scale,
                children: const [
                  HotelCard(
                    compact: true,
                    name: 'Urban Zen Hotel',
                    location: 'Quận 1, TP. HCM',
                    price: '₫1.5M',
                    colors: [Color(0xFF8D7159), Color(0xFF19110C)],
                  ),
                  HotelCard(
                    compact: true,
                    name: 'The Silk Path',
                    location: 'Thảo Điền, Q2',
                    price: '₫2.1M',
                    colors: [Color(0xFFC9A36B), Color(0xFF362116)],
                  ),
                  HotelCard(
                    compact: true,
                    name: 'Minimal Loft',
                    location: 'Bình Thạnh',
                    price: '₫950K',
                    colors: [Color(0xFF5D7D8F), Color(0xFF151E24)],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
