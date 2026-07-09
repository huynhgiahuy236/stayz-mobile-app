import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/detail/presentation/widgets/detail_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({super.key});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  bool _isFavorite = false;
  bool _favoriteLoaded = false;
  bool _favoriteLoading = false;
  String? _loadedHotelId;

  Future<void> _loadFavoriteState(String hotelId) async {
    if (_loadedHotelId == hotelId && (_favoriteLoaded || _favoriteLoading)) return;
    _loadedHotelId = hotelId;
    _favoriteLoading = true;
    try {
      final ids = await ApiStayzRepository.instance.getFavoriteHotelIds();
      if (!mounted || _loadedHotelId != hotelId) return;
      setState(() {
        _isFavorite = ids.contains(hotelId);
        _favoriteLoaded = true;
        _favoriteLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _favoriteLoaded = true;
          _favoriteLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(HotelSummary? summary) async {
    if (summary == null) return;
    final hotelId = summary.hotel.id;
    final wasFavorite = _isFavorite;
    setState(() => _isFavorite = !wasFavorite);

    try {
      if (wasFavorite) {
        await ApiStayzRepository.instance.removeFavorite(hotelId);
      } else {
        await ApiStayzRepository.instance.addFavorite(hotelId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wasFavorite ? 'Da bo khoi yeu thich.' : 'Da them vao yeu thich.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFavorite = wasFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long dang nhap de cap nhat yeu thich.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final summary = ModalRoute.of(context)?.settings.arguments as HotelSummary?;
    final hotel = summary?.hotel;
    if (hotel != null) {
      _loadFavoriteState(hotel.id);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: DetailBottomBookingBar(summary: summary),
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
                              DetailCircleButton(
                                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                                onTap: () => _toggleFavorite(summary),
                              ),
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
                    child: _HotelSummaryCard(summary: summary),
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
                    const DetailSectionTitle(title: 'Giới thiệu'),
                    SizedBox(height: 18 * responsive.scale),
                    Text(
                      hotel?.description ??
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
                    const DetailSectionTitle(title: 'Tiện ích nổi bật'),
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
                    _ReviewsSection(summary: summary, textTheme: textTheme),
                    SizedBox(height: 48 * responsive.scale),
                    const DetailSectionTitle(title: 'Vị trí'),
                    SizedBox(height: 20 * responsive.scale),
                    _MapLocationCard(hotel: hotel),
                    SizedBox(height: 18 * responsive.scale),
                    Text(
                      hotel?.address ?? '1 Tran Phu, Phuong 3, Thanh pho Da Lat, Lam Dong, Viet Nam',
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

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.summary, required this.textTheme});

  final HotelSummary? summary;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    if (summary == null) {
      return const DetailSectionTitle(title: 'Danh gia');
    }

    return FutureBuilder<List<Review>>(
      future: ApiStayzRepository.instance.getReviewsByHotelId(summary!.hotel.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <Review>[];
        final average = reviews.isEmpty
            ? summary!.rating
            : reviews.map((review) => review.rating).reduce((a, b) => a + b) / reviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailSectionTitle(
              title: 'Danh gia',
              trailing: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: average.toStringAsFixed(1),
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.ink,
                        fontSize: 36 * responsive.scale,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: ' /5 (${reviews.length})',
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
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (reviews.isEmpty)
              Text(
                'Chua co danh gia nao cho noi luu tru nay.',
                style: TextStyle(color: AppTheme.neutral500, fontSize: 13 * responsive.scale),
              )
            else
              ...reviews.take(5).map(
                    (review) => Padding(
                      padding: EdgeInsets.only(bottom: 16 * responsive.scale),
                      child: ReviewCard(
                        name: 'StayZ guest',
                        date: StayzFormatters.shortDate(review.createdAt),
                        body: review.comment,
                        rating: review.rating,
                        colors: const [Color(0xFFE9C5A4), Color(0xFF283F33)],
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

class _MapLocationCard extends StatelessWidget {
  const _MapLocationCard({required this.hotel});

  final Hotel? hotel;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final hasLocation = hotel != null && (hotel!.latitude != 0 || hotel!.longitude != 0);

    return Container(
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
              hasLocation ? '${hotel!.latitude.toStringAsFixed(5)}, ${hotel!.longitude.toStringAsFixed(5)}' : 'Chua co toa do ban do',
              style: TextStyle(
                color: AppTheme.accentDark,
                fontSize: 12 * responsive.scale,
                fontWeight: FontWeight.w600,
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
  const _HotelSummaryCard({required this.summary});

  final HotelSummary? summary;

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
            summary?.hotel.name ?? 'Da Lat Palace Heritage\nHotel',
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
                  summary == null ? '1 Tran Phu, Da Lat, Lam Dong' : '${summary!.city.name}, ${summary!.city.region}',
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
                  '(${summary?.availableRooms ?? 324} phòng trống)',
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
                  summary?.city.region ?? 'Trung\ntam',
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
                  text: summary == null ? '₫1.800.000' : StayzFormatters.fullVnd(summary!.lowestPrice),
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
