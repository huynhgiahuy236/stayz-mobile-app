import 'dart:async';

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  SearchFilters _filters = const SearchFilters();
  Future<List<HotelSummary>>? _hotelsFuture;
  Set<String> _favoriteIds = const <String>{};
  Timer? _debounce;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is SearchFilters) {
      _filters = args;
      _searchController.text = args.keyword;
    }
    // Gan thang, KHONG goi setState o day: didChangeDependencies chay trong
    // luc dung widget, setState luc nay nem "called during build".
    _hotelsFuture = ApiStayzRepository.instance.searchHotelSummaries(_filters);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await ApiStayzRepository.instance.getFavoriteHotelIds();
      if (mounted) setState(() => _favoriteIds = ids);
    } catch (_) {
      // Chua dang nhap: khong co yeu thich, khong can bao loi.
    }
  }

  void _runSearch() {
    setState(() => _hotelsFuture = ApiStayzRepository.instance.searchHotelSummaries(_filters));
  }

  void _applyFilters(SearchFilters filters, {bool syncTextField = true}) {
    if (syncTextField && filters.keyword != _searchController.text) {
      _searchController.text = filters.keyword;
    }
    _filters = filters;
    _runSearch();
  }

  /// 2 giay la qua lau, nguoi dung tuong o tim kiem bi treo.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _applyFilters(_filters.copyWith(keyword: value), syncTextField: false);
    });
  }

  Future<void> _openFilter() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.filter, arguments: _filters);
    if (result is SearchFilters && mounted) _applyFilters(result);
  }

  void _clearAllFilters() {
    _searchController.clear();
    _applyFilters(const SearchFilters());
  }

  Future<void> _toggleFavorite(HotelSummary summary) async {
    final wasFavorite = _favoriteIds.contains(summary.hotel.id);
    setState(() {
      final next = Set<String>.of(_favoriteIds);
      wasFavorite ? next.remove(summary.hotel.id) : next.add(summary.hotel.id);
      _favoriteIds = next;
    });

    try {
      if (wasFavorite) {
        await ApiStayzRepository.instance.removeFavorite(summary.hotel.id);
      } else {
        await ApiStayzRepository.instance.addFavorite(summary.hotel.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wasFavorite ? tr('Đã bỏ khỏi yêu thích.', 'Removed from saved.') : tr('Đã thêm vào yêu thích.', 'Added to saved.'))),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        final next = Set<String>.of(_favoriteIds);
        wasFavorite ? next.add(summary.hotel.id) : next.remove(summary.hotel.id);
        _favoriteIds = next;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.isUnauthorized ? tr('Vui lòng đăng nhập để lưu yêu thích.', 'Please sign in to save favorites.') : error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final activeCount = _filters.activeCount;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (value) => _applyFilters(_filters.copyWith(keyword: value), syncTextField: false),
              onFilter: _openFilter,
              onClear: () {
                _searchController.clear();
                _applyFilters(_filters.copyWith(keyword: ''), syncTextField: false);
              },
              activeFilterCount: activeCount,
            ),
            _QuickChips(
              filters: _filters,
              onChanged: _applyFilters,
            ),
            Expanded(
              child: FutureBuilder<List<HotelSummary>>(
                future: _hotelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  // Loi mang va "khong co ket qua" phai trong khac nhau.
                  if (snapshot.hasError) {
                    return StayzErrorView(error: snapshot.error, onRetry: _runSearch);
                  }

                  final hotels = snapshot.data ?? const <HotelSummary>[];
                  if (hotels.isEmpty) {
                    return StayzEmptyView(
                      icon: Icons.search_off_rounded,
                      title: tr('Không tìm thấy khách sạn phù hợp', 'No matching hotels'),
                      message: activeCount > 0 || _filters.keyword.isNotEmpty
                          ? tr('Hãy thử bỏ bớt điều kiện lọc hoặc dùng từ khoá khác.', 'Try removing some filters or using a different keyword.')
                          : tr('Hiện chưa có khách sạn nào trong dữ liệu.', 'No hotels available yet.'),
                      actionLabel: activeCount > 0 || _filters.keyword.isNotEmpty ? tr('Xoá bộ lọc', 'Clear filters') : null,
                      onAction: activeCount > 0 || _filters.keyword.isNotEmpty ? _clearAllFilters : null,
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      4,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: hotels.length + 1,
                    separatorBuilder: (_, _) => SizedBox(height: 14 * responsive.scale),
                    itemBuilder: (context, index) {
                      if (index == 0) return _ResultCount(count: hotels.length);

                      final summary = hotels[index - 1];
                      final soldOut = summary.isSoldOut;

                      return SearchHotelCard(
                        name: summary.hotel.name,
                        location: '${summary.city.name}, ${summary.city.region}',
                        price: summary.hasPrice ? StayzFormatters.fullVnd(summary.lowestPrice) : tr('Liên hệ', 'Contact'),
                        rating: summary.rating,
                        reviewCount: summary.reviewCount,
                        amenities: summary.hotel.amenityIds,
                        badge: soldOut
                            ? tr('Hết phòng', 'Sold out')
                            : summary.availableRooms <= 3
                                ? tr('Chỉ còn ${summary.availableRooms} phòng', 'Only ${summary.availableRooms} rooms left')
                                : summary.hotel.status == 'featured'
                                    ? tr('Nổi bật', 'Featured')
                                    : null,
                        badgeIsWarning: soldOut || summary.availableRooms <= 3,
                        favorite: _favoriteIds.contains(summary.hotel.id),
                        imageUrl: summary.hotel.imageUrls.firstOrNull,
                        colors: _searchHotelColors[(index - 1) % _searchHotelColors.length],
                        onFavoriteTap: () => _toggleFavorite(summary),
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.roomDetail, arguments: summary),
                        onRoomsTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.roomSelection,
                          arguments: RoomSelectionArgs(hotel: summary, adults: _filters.guests ?? 2),
                        ),
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

/// Thanh tim kiem theo dung form cua `SearchBox` ngoai trang chu: hop bo tron
/// 20, bong mem, icon tim kiem mau primary, va nut loc la o vuong bo goc mau
/// toi nam ben trong hop. Nut back nam ngoai ben trai.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onFilter,
    required this.onClear,
    required this.activeFilterCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilter;
  final VoidCallback onClear;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(4 * responsive.widthScale, 8 * responsive.scale, responsive.horizontalPadding, 10 * responsive.scale),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: tr('Quay lại', 'Back'),
            color: AppTheme.ink,
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 60 * responsive.scale),
              padding: EdgeInsets.symmetric(horizontal: 16 * responsive.widthScale, vertical: 10 * responsive.scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 24 * responsive.scale, color: AppTheme.primary),
                  SizedBox(width: 12 * responsive.widthScale),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(fontSize: 15 * responsive.scale, color: AppTheme.ink, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: tr('Bạn muốn đi đâu?', 'Where to?'),
                        hintStyle: TextStyle(color: AppTheme.muted, fontSize: 15 * responsive.scale, fontWeight: FontWeight.w700),
                        // Tat het cac vien: theme co focusedBorder xanh, neu khong
                        // ghi de thi luc bam vao go se hien vien quanh chu.
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return InkResponse(
                        onTap: onClear,
                        radius: 18,
                        child: Padding(
                          padding: EdgeInsets.only(right: 6 * responsive.widthScale),
                          child: const Icon(Icons.close_rounded, size: 18, color: AppTheme.muted),
                        ),
                      );
                    },
                  ),
                  // Nut loc dat trong hop, giong het nut tune cua SearchBox trang chu,
                  // them badge dem so dieu kien dang bat.
                  Semantics(
                    button: true,
                    label: activeFilterCount > 0 ? tr('Bộ lọc, đang bật $activeFilterCount điều kiện', 'Filters, $activeFilterCount active') : tr('Bộ lọc', 'Filters'),
                    child: GestureDetector(
                      onTap: onFilter,
                      child: Badge(
                        isLabelVisible: activeFilterCount > 0,
                        label: Text('$activeFilterCount'),
                        backgroundColor: AppTheme.primary,
                        child: Container(
                          width: 40 * responsive.scale,
                          height: 40 * responsive.scale,
                          decoration: BoxDecoration(
                            color: AppTheme.ink,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.tune_rounded, color: Colors.white, size: 19 * responsive.scale),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip nhanh, cung ngon ngu voi chip ngoai trang chu.
class _QuickChips extends StatelessWidget {
  const _QuickChips({required this.filters, required this.onChanged});

  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    void toggleAmenity(String slug) {
      final next = Set<String>.of(filters.amenities);
      next.contains(slug) ? next.remove(slug) : next.add(slug);
      onChanged(filters.copyWith(amenities: next.toList()));
    }

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        children: [
          _chip(
            label: tr('Nổi bật', 'Featured'),
            icon: Icons.star_rounded,
            active: filters.isPreferred,
            onTap: () => onChanged(filters.copyWith(isPreferred: !filters.isPreferred)),
          ),
          _chip(
            label: tr('Gần biển', 'Near beach'),
            icon: Icons.beach_access_rounded,
            active: filters.nearBeach,
            onTap: () => onChanged(filters.copyWith(nearBeach: !filters.nearBeach)),
          ),
          _chip(
            label: tr('Dưới 2tr', 'Under 2M'),
            icon: Icons.payments_rounded,
            active: filters.maxPrice == 2000000,
            onTap: () => onChanged(
              filters.maxPrice == 2000000 ? filters.copyWith(clearPrice: true) : filters.copyWith(maxPrice: 2000000),
            ),
          ),
          for (final slug in const ['outdoor_pool', 'breakfast', 'family_room', 'free_parking'])
            _chip(
              label: StayzTaxonomy.amenityTerm(slug).label,
              icon: StayzTaxonomy.amenityTerm(slug).icon,
              active: filters.amenities.contains(slug),
              onTap: () => toggleAmenity(slug),
            ),
        ],
      ),
    );
  }

  Widget _chip({required String label, IconData? icon, required bool active, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: FilterPill(label: label, icon: icon, active: active, onTap: onTap),
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 6),
      child: Text(
        tr('Tìm thấy $count khách sạn', 'Found $count hotels'),
        style: const TextStyle(color: AppTheme.muted, fontSize: 13, fontWeight: FontWeight.w700),
      ),
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
