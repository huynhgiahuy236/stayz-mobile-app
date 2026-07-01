import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/detail/presentation/widgets/detail_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: const DetailBottomBookingBar(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 294 * responsive.scale,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF223A34), Color(0xFFB79A6D)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.08),
                                  Colors.black.withValues(alpha: 0.36),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: responsive.horizontalPadding,
                          top: 16 * responsive.scale,
                          child: DetailCircleButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        Positioned(
                          right: responsive.horizontalPadding,
                          top: 16 * responsive.scale,
                          child: Row(
                            children: [
                              const DetailCircleButton(icon: Icons.favorite_border),
                              SizedBox(width: 12 * responsive.widthScale),
                              const DetailCircleButton(icon: Icons.share_outlined),
                            ],
                          ),
                        ),
                        Positioned(
                          left: responsive.horizontalPadding,
                          right: responsive.horizontalPadding,
                          bottom: 18 * responsive.scale,
                          child: Row(
                            children: [
                              const _GalleryThumb(colors: [Color(0xFF5D3C29), Color(0xFFE8C089)]),
                              SizedBox(width: 9 * responsive.widthScale),
                              const _GalleryThumb(colors: [Color(0xFF75553A), Color(0xFFF2D7A0)]),
                              SizedBox(width: 9 * responsive.widthScale),
                              const _GalleryThumb(colors: [Color(0xFF78916F), Color(0xFFEAD7B0)]),
                              SizedBox(width: 9 * responsive.widthScale),
                              const _GalleryThumb(
                                colors: [Color(0xFF332720), Color(0xFF8A6C4D)],
                                label: '+12',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: responsive.horizontalPadding,
                    right: responsive.horizontalPadding,
                    top: 260 * responsive.scale,
                    child: const _HotelSummaryCard(),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                236 * responsive.scale,
                responsive.horizontalPadding,
                28 * responsive.scale,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const DetailSectionTitle(title: 'Gioi thieu'),
                    SizedBox(height: 18 * responsive.scale),
                    Text(
                      'Da Lat Palace la mot trong nhung khach san lau doi nhat Da Lat, mang kien truc Phap co dien day sang trong. Toa lac tai vi tri dac dia nhin ra Ho Xuan Huong, khach san mang den khong gian nghi duong tinh lang, dam hoi tho di san van hoa giua long thanh pho ngan hoa...',
                      style: TextStyle(
                        color: const Color(0xFF4F403B),
                        fontSize: 14 * responsive.scale,
                        height: 1.75,
                      ),
                    ),
                    SizedBox(height: 12 * responsive.scale),
                    Text(
                      'Xem them  v',
                      style: TextStyle(
                        color: AppTheme.accentDark,
                        fontSize: 13 * responsive.scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 48 * responsive.scale),
                    const DetailSectionTitle(title: 'Tien ich noi bat'),
                    SizedBox(height: 20 * responsive.scale),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14 * responsive.widthScale,
                      mainAxisSpacing: 14 * responsive.scale,
                      childAspectRatio: 2.6,
                      children: const [
                        AmenityTile(icon: Icons.pool_outlined, label: 'Ho boi'),
                        AmenityTile(icon: Icons.wifi, label: 'Wifi mien phi'),
                        AmenityTile(icon: Icons.local_parking_outlined, label: 'Bai do xe'),
                        AmenityTile(icon: Icons.restaurant_outlined, label: 'Nha hang'),
                        AmenityTile(icon: Icons.spa_outlined, label: 'Spa'),
                        AmenityTile(icon: Icons.fitness_center, label: 'Phong gym'),
                      ],
                    ),
                    SizedBox(height: 48 * responsive.scale),
                    DetailSectionTitle(
                      title: 'Danh gia',
                      trailing: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '4.8',
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppTheme.ink,
                                fontSize: 36 * responsive.scale,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: ' /5',
                              style: TextStyle(
                                color: AppTheme.ink,
                                fontSize: 13 * responsive.scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * responsive.scale),
                    const ReviewCard(
                      name: 'Minh Anh',
                      date: '12 Thang 10, 2023',
                      body:
                          '"Trai nghiem tuyet voi. Khong gian co kinh va dich vu rat chuyen nghiep. Rat dang gia de thu khi den Da Lat."',
                      colors: [Color(0xFFE9C5A4), Color(0xFF283F33)],
                    ),
                    SizedBox(height: 16 * responsive.scale),
                    const ReviewCard(
                      name: 'Hoang Nam',
                      date: '05 Thang 10, 2023',
                      body:
                          '"Kien truc rat dep, phong oc sach se va sang trong. Tuy nhien bua sang hoi it mon truyen thong."',
                      colors: [Color(0xFFC1D6C8), Color(0xFF23483E)],
                    ),
                    SizedBox(height: 48 * responsive.scale),
                    const DetailSectionTitle(title: 'Vi tri'),
                    SizedBox(height: 20 * responsive.scale),
                    Container(
                      height: 142 * responsive.scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4E9E4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.neutral200),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: AppTheme.accent.withValues(alpha: 0.42),
                              size: 42 * responsive.scale,
                            ),
                            SizedBox(height: 10 * responsive.scale),
                            Text(
                              'Xem tren ban do',
                              style: TextStyle(
                                color: AppTheme.accentDark,
                                fontSize: 12 * responsive.scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * responsive.scale),
                    Text(
                      '1 Tran Phu, Phuong 3, Thanh pho Da Lat, Lam Dong, Viet Nam',
                      style: TextStyle(
                        color: const Color(0xFF4F403B),
                        fontSize: 13 * responsive.scale,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 24 * responsive.scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.colors,
    this.label,
  });

  final List<Color> colors;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Expanded(
      child: Container(
        height: 52 * responsive.scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          gradient: LinearGradient(colors: colors),
        ),
        child: label == null
            ? null
            : Center(
                child: Text(
                  label!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * responsive.scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
      ),
    );
  }
}

class _HotelSummaryCard extends StatelessWidget {
  const _HotelSummaryCard();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(24 * responsive.scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Da Lat Palace Heritage\nHotel',
            style: textTheme.titleLarge?.copyWith(
              color: AppTheme.ink,
              fontSize: 23 * responsive.scale,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16 * responsive.scale),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppTheme.accentDark, size: 17 * responsive.scale),
              SizedBox(width: 6 * responsive.widthScale),
              Expanded(
                child: Text(
                  '1 Tran Phu, Da Lat, Lam Dong',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF5A3F3F),
                    fontSize: 12 * responsive.scale,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * responsive.scale),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  Icons.star_border,
                  color: const Color(0xFF8E5F1B),
                  size: 15 * responsive.scale,
                ),
              ),
              SizedBox(width: 6 * responsive.widthScale),
              Text(
                '4.8',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 14 * responsive.scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 7 * responsive.widthScale),
              Expanded(
                child: Text(
                  '(324 danh gia)',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 11 * responsive.scale,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18 * responsive.widthScale,
                  vertical: 9 * responsive.scale,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.neutral200.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Trung\ntam',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF5A3F3F),
                    fontSize: 11 * responsive.scale,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 30 * responsive.scale, color: AppTheme.neutral200),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'tu ',
                  style: TextStyle(
                    color: AppTheme.neutral500,
                    fontSize: 12 * responsive.scale,
                  ),
                ),
                TextSpan(
                  text: 'd1.800.000',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 21 * responsive.scale,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                TextSpan(
                  text: ' /dem',
                  style: TextStyle(
                    color: AppTheme.neutral800,
                    fontSize: 12 * responsive.scale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
