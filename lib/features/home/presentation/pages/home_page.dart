import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/chat/ai_chat_sheet.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_alert.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

/// Cac lua chon nhanh duoi o tim kiem. Moi chip anh xa sang mot bo loc that
/// tren du lieu backend, khong con la chip trang tri.
enum HomeQuickFilter {
  all(icon: Icons.apps_rounded),
  preferred(icon: Icons.diamond_rounded),
  family(icon: Icons.family_restroom_rounded),
  beach(icon: Icons.beach_access_rounded),
  budget(icon: Icons.savings_rounded);

  const HomeQuickFilter({required this.icon});

  final IconData icon;

  String get label {
    switch (this) {
      case HomeQuickFilter.all:
        return tr('Tất cả', 'All');
      case HomeQuickFilter.preferred:
        return tr('Cao cấp', 'Premium');
      case HomeQuickFilter.family:
        return tr('Gia đình', 'Family');
      case HomeQuickFilter.beach:
        return tr('Biển', 'Beach');
      case HomeQuickFilter.budget:
        return tr('Tiết kiệm', 'Budget');
    }
  }

  SearchFilters apply(SearchFilters base) {
    switch (this) {
      case HomeQuickFilter.all:
        return const SearchFilters();
      case HomeQuickFilter.preferred:
        return base.copyWith(isPreferred: true);
      case HomeQuickFilter.family:
        return base.copyWith(amenities: const ['family_room']);
      case HomeQuickFilter.beach:
        return base.copyWith(nearBeach: true);
      case HomeQuickFilter.budget:
        return base.copyWith(maxPrice: 1500000);
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Future duoc giu lai thay vi tao moi trong build(): truoc day moi lan bam
  // nut tim la tai lai toan bo danh sach khach san.
  late Future<List<HotelSummary>> _hotelsFuture;
  Future<BookingSummary?>? _upcomingFuture;

  Set<String> _favoriteIds = const <String>{};
  bool _loadedFavorites = false;
  Object? _favoritesError;
  HomeQuickFilter _selectedQuickFilter = HomeQuickFilter.all;

  @override
  void initState() {
    super.initState();
    _hotelsFuture = ApiStayzRepository.instance.getHotelSummaries();
    _upcomingFuture = _loadUpcomingBooking();
    _loadFavorites();
  }

  Future<void> _refresh() async {
    final hotels = ApiStayzRepository.instance.getHotelSummaries();
    setState(() {
      _hotelsFuture = hotels;
      _upcomingFuture = _loadUpcomingBooking();
    });
    await hotels;
    await _loadFavorites();
  }

  /// Chuyen di sap toi THAT cua nguoi dung. Truoc day the nay bia ra mot
  /// chuyen di tu khach san dau danh sach voi ngay cung '12 - 14/07'.
  Future<BookingSummary?> _loadUpcomingBooking() async {
    final bookings = await ApiStayzRepository.instance.getBookingSummaries();
    final upcoming =
        bookings.where((item) => item.booking.isUpcoming).toList()..sort(
          (a, b) => a.booking.checkInDate.compareTo(b.booking.checkInDate),
        );
    return upcoming.firstOrNull;
  }

  Future<void> _loadFavorites() async {
    if (mounted) {
      setState(() {
        _loadedFavorites = false;
        _favoritesError = null;
      });
    }
    try {
      final ids = await ApiStayzRepository.instance.getFavoriteHotelIds();
      if (mounted) {
        setState(() {
          _favoriteIds = ids;
          _loadedFavorites = true;
          _favoritesError = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadedFavorites = true;
          _favoritesError = error;
        });
      }
    }
  }

  void _retryUpcoming() {
    setState(() => _upcomingFuture = _loadUpcomingBooking());
  }

  Future<void> _toggleFavorite(HotelSummary summary) async {
    final hotelId = summary.hotel.id;
    final wasFavorite = _favoriteIds.contains(hotelId);
    setState(() {
      final next = {..._favoriteIds};
      wasFavorite ? next.remove(hotelId) : next.add(hotelId);
      _favoriteIds = next;
    });

    try {
      if (wasFavorite) {
        await ApiStayzRepository.instance.removeFavorite(hotelId);
      } else {
        await ApiStayzRepository.instance.addFavorite(hotelId);
      }
      if (!mounted) return;
      StayzAlert.show(
        context,
        type: wasFavorite ? StayzAlertType.info : StayzAlertType.success,
        message: wasFavorite
            ? tr('Đã bỏ khỏi yêu thích.', 'Removed from saved.')
            : tr('Đã thêm vào yêu thích.', 'Added to saved.'),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        final rollback = {..._favoriteIds};
        wasFavorite ? rollback.add(hotelId) : rollback.remove(hotelId);
        _favoriteIds = rollback;
      });
      StayzAlert.show(
        context,
        type: StayzAlertType.error,
        message: error.isUnauthorized
            ? tr(
                'Vui lòng đăng nhập để lưu yêu thích.',
                'Please sign in to save favorites.',
              )
            : error.message,
      );
    }
  }

  Future<void> _openFilters() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.filter, arguments: const SearchFilters());
    if (result is SearchFilters && mounted) {
      Navigator.of(context).pushNamed(AppRoutes.search, arguments: result);
    }
  }

  Future<void> _openSearchWith(
    SearchFilters filters, {
    HomeQuickFilter? quickFilter,
  }) async {
    if (quickFilter != null) setState(() => _selectedQuickFilter = quickFilter);
    await Navigator.of(context).pushNamed(AppRoutes.search, arguments: filters);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.home),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAiChatSheet(context),
        backgroundColor: AppTheme.accentDark,
        foregroundColor: Colors.white,
        tooltip: tr('Trợ lý StayZ AI', 'StayZ AI Assistant'),
        child: const Icon(Icons.auto_awesome_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<HotelSummary>>(
          future: _hotelsFuture,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final hotels = snapshot.data ?? const <HotelSummary>[];

            // Truoc day loi mang bi nuot: man hinh im lang hien du lieu du phong.
            if (snapshot.hasError && !loading) {
              return StayzErrorView(error: snapshot.error, onRetry: _refresh);
            }

            final featured = hotels
                .where((item) => item.hotel.status == 'featured')
                .toList();
            // Carousel "noi bat" hien nhieu hon (toi 8).
            final topPicks = (featured.isNotEmpty ? featured : hotels)
                .take(8)
                .toList();
            // "Goi y khac" hien tat ca khach san con lai, khong gioi han 3 nhu truoc.
            final topIds = topPicks.map((item) => item.hotel.id).toSet();
            final nearby = hotels
                .where((item) => !topIds.contains(item.hotel.id))
                .toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
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
                        featured: topPicks.firstOrNull,
                        loading: loading,
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
                      child: SearchBox(
                        onTap: () => _openSearchWith(const SearchFilters()),
                        onFilterTap: _openFilters,
                      ),
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
                        height: 48 * responsive.scale,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: HomeQuickFilter.values.length,
                          padding: EdgeInsets.only(
                            right: responsive.horizontalPadding,
                          ),
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final filter = HomeQuickFilter.values[index];
                            return Center(
                              child: FilterPill(
                                label: filter.label,
                                icon: filter.icon,
                                active: _selectedQuickFilter == filter,
                                onTap: () => _openSearchWith(
                                  filter.apply(const SearchFilters()),
                                  quickFilter: filter,
                                ),
                              ),
                            );
                          },
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
                        title: tr('Khách sạn nổi bật', 'Featured hotels'),
                        action: tr('Xem tất cả', 'See all'),
                        onAction: () => _openSearchWith(
                          const SearchFilters(isPreferred: true),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 304 * responsive.scale,
                      child: loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                            )
                          : topPicks.isEmpty
                          ? StayzEmptyView(
                              icon: Icons.hotel_outlined,
                              title: tr(
                                'Chưa có khách sạn nào',
                                'No hotels yet',
                              ),
                              message: tr(
                                'Dữ liệu khách sạn hiện đang trống.',
                                'No hotel data available.',
                              ),
                              compact: true,
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.horizontalPadding,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: topPicks.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) =>
                                  _hotelCard(topPicks[index], index),
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FutureBuilder<BookingSummary?>(
                      future: _upcomingFuture,
                      builder: (context, bookingSnapshot) {
                        if (bookingSnapshot.hasError) {
                          return SizedBox(
                            height: 190 * responsive.scale,
                            child: StayzErrorView(
                              error: bookingSnapshot.error,
                              onRetry: _retryUpcoming,
                              compact: true,
                            ),
                          );
                        }
                        final upcoming = bookingSnapshot.data;
                        // Khong co chuyen di that thi khong hien muc nay.
                        if (upcoming == null) return const SizedBox.shrink();

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                responsive.horizontalPadding,
                                30 * responsive.scale,
                                responsive.horizontalPadding,
                                14 * responsive.scale,
                              ),
                              child: SectionLabel(
                                title: tr(
                                  upcoming.booking.isPaymentPending
                                      ? 'Đặt phòng chờ thanh toán'
                                      : 'Lịch trình tiếp theo',
                                  upcoming.booking.isPaymentPending
                                      ? 'Booking awaiting payment'
                                      : 'Your next trip',
                                ),
                                action: tr('Quản lý', 'Manage'),
                                onAction: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.myBookings),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: responsive.horizontalPadding,
                              ),
                              child: BookingPreviewCard(
                                name: upcoming.hotel.name,
                                location: upcoming.city.name,
                                date:
                                    '${StayzFormatters.shortDate(upcoming.booking.checkInDate)} - ${StayzFormatters.shortDate(upcoming.booking.checkOutDate)}',
                                total: StayzFormatters.compactVnd(
                                  upcoming.booking.totalAmount,
                                ),
                                status: upcoming.booking.isPaymentExpired
                                    ? tr('Đã hết hạn', 'Expired')
                                    : upcoming.booking.isPaymentPending
                                        ? tr('Chờ thanh toán', 'Pending payment')
                                        : tr('Sắp đến', 'Upcoming'),
                                imageUrl:
                                    upcoming.room.imageUrls.firstOrNull ??
                                    upcoming.hotel.imageUrls.firstOrNull,
                                colors: _homeHotelColors[1],
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.upcomingBookingDetail,
                                  arguments: BookingSummaryArgs(
                                    summary: upcoming,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (_loadedFavorites && _favoritesError != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          responsive.horizontalPadding,
                          18 * responsive.scale,
                          responsive.horizontalPadding,
                          0,
                        ),
                        child: Semantics(
                          liveRegion: true,
                          child: Material(
                            color: AppTheme.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              leading: const Icon(
                                Icons.favorite_border_rounded,
                                color: AppTheme.danger,
                              ),
                              title: Text(
                                tr(
                                  'Không tải được trạng thái yêu thích.',
                                  'Could not load saved status.',
                                ),
                              ),
                              trailing: TextButton(
                                onPressed: _loadFavorites,
                                child: Text(tr('Thử lại', 'Retry')),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (nearby.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          responsive.horizontalPadding,
                          30 * responsive.scale,
                          responsive.horizontalPadding,
                          14 * responsive.scale,
                        ),
                        child: SectionLabel(
                          title: tr('Gợi ý khác cho bạn', 'More for you'),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: nearby.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.fromLTRB(
                          responsive.horizontalPadding,
                          index == 0 ? 0 : 14 * responsive.scale,
                          responsive.horizontalPadding,
                          0,
                        ),
                        child: _hotelCard(
                          nearby[index],
                          index + 2,
                          fullWidth: true,
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: SizedBox(height: 28 * responsive.scale),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _hotelCard(HotelSummary summary, int index, {bool fullWidth = false}) {
    return HotelCard(
      fullWidth: fullWidth,
      name: summary.hotel.name,
      location: fullWidth
          ? '${summary.city.name}, ${summary.city.region}'
          : summary.city.name,
      price: summary.hasPrice
          ? '${StayzFormatters.compactVnd(summary.lowestPrice)}${tr(' / đêm', ' / night')}'
          : tr('Chưa có phòng', 'No rooms'),
      imageUrl: summary.hotel.imageUrls.firstOrNull,
      isFavorite: _loadedFavorites && _favoriteIds.contains(summary.hotel.id),
      onFavoriteTap: () => _toggleFavorite(summary),
      rating: summary.rating,
      reviewCount: summary.reviewCount,
      colors: _homeHotelColors[index % _homeHotelColors.length],
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.hotelDetail, arguments: summary),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.featured, required this.loading});

  final HotelSummary? featured;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * responsive.widthScale,
              vertical: 6 * responsive.scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tr('ĐẶT PHÒNG NHANH', 'QUICK BOOKING'),
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
            tr(
              'Tìm phòng đẹp,\nđặt lịch gọn trong vài chạm.',
              'Find great stays,\nbook in a few taps.',
            ),
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
                ? tr(
                    'Đang tải gợi ý tốt nhất cho bạn...',
                    'Loading the best picks for you...',
                  )
                : featured == null
                ? tr(
                    'Hãy tìm nơi lưu trú phù hợp với bạn.',
                    'Find a stay that suits you.',
                  )
                : tr(
                    'Gợi ý hôm nay: ${featured!.hotel.name}',
                    'Today\'s pick: ${featured!.hotel.name}',
                  ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.search,
                    arguments: const SearchFilters(),
                  ),
                  icon: const Icon(Icons.search_rounded),
                  label: Text(tr('Tìm phòng', 'Search stays')),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 12 * responsive.widthScale),
              IconButton.filledTonal(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.favorites),
                icon: const Icon(Icons.favorite_rounded),
                tooltip: tr('Khách sạn yêu thích', 'Favorite hotels'),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                  minimumSize: Size(
                    52 * responsive.scale,
                    52 * responsive.scale,
                  ),
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
