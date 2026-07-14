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
  final _scrollController = ScrollController();
  SearchFilters _filters = const SearchFilters();
  Future<List<HotelSummary>>? _hotelsFuture;
  Set<String> _favoriteIds = const <String>{};
  List<HotelSummary> _suggestionSource = const <HotelSummary>[];
  List<_SearchSuggestion> _suggestions = const <_SearchSuggestion>[];
  Timer? _debounce;
  bool _initialized = false;
  int _searchRequestId = 0;
  String _searchResultKey = 'initial';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadSuggestionSource();
  }

  Future<void> _loadSuggestionSource() async {
    try {
      final hotels = await ApiStayzRepository.instance.getHotelSummaries();
      if (!mounted) return;
      setState(() {
        _suggestionSource = hotels;
        _suggestions = _buildSuggestions(_searchController.text);
      });
    } catch (_) {
      // Suggestions are optional; normal API search still remains available.
    }
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
    _scrollController.dispose();
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
    final requestId = ++_searchRequestId;
    final filters = _filters;
    final resultKey = filters
        .toQuery()
        .entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    final request = ApiStayzRepository.instance.searchHotelSummaries(filters).then((
      hotels,
    ) {
      // Response cua lan tim cu den sau thi bo qua, khong duoc ghi de ket qua moi.
      if (requestId != _searchRequestId) return const <HotelSummary>[];
      return hotels;
    });
    setState(() {
      _searchResultKey = '$requestId:$resultKey';
      _hotelsFuture = request;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _applyFilters(SearchFilters filters, {bool syncTextField = true}) {
    if (syncTextField && filters.keyword != _searchController.text) {
      _searchController.text = filters.keyword;
    }
    _filters = filters;
    _runSearch();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    // Ghi keyword vao state ngay, tranh timer dung lai gia tri filter cu.
    _filters = _filters.copyWith(keyword: value.trim());
    setState(() => _suggestions = _buildSuggestions(value));
    _debounce = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      _applyFilters(
        _filters.copyWith(keyword: _searchController.text.trim()),
        syncTextField: false,
      );
    });
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    final keyword = value.trim();
    setState(() => _suggestions = const <_SearchSuggestion>[]);
    _applyFilters(_filters.copyWith(keyword: keyword), syncTextField: false);
    FocusScope.of(context).unfocus();
  }

  void _selectSuggestion(_SearchSuggestion suggestion) {
    _searchController.text = suggestion.keyword;
    _searchController.selection = TextSelection.collapsed(
      offset: suggestion.keyword.length,
    );
    _submitSearch(suggestion.keyword);
  }

  List<_SearchSuggestion> _buildSuggestions(String input) {
    final query = _normalizeSearchText(input);
    if (query.isEmpty || _suggestionSource.isEmpty) {
      return const <_SearchSuggestion>[];
    }

    final candidates = <_SearchSuggestion>[];
    final seenCities = <String>{};
    for (final summary in _suggestionSource) {
      final cityKey = _normalizeSearchText(summary.city.name);
      if (seenCities.add(cityKey)) {
        candidates.add(
          _SearchSuggestion(
            keyword: summary.city.name,
            label: summary.city.name,
            subtitle: summary.city.region,
            searchTerms: _citySearchAliases(summary.hotel.cityId),
            icon: Icons.location_city_rounded,
          ),
        );
      }
      candidates.add(
        _SearchSuggestion(
          keyword: summary.hotel.name,
          label: summary.hotel.name,
          subtitle: '${summary.city.name}, ${summary.city.region}',
          searchTerms: _citySearchAliases(summary.hotel.cityId),
          icon: Icons.hotel_rounded,
        ),
      );
    }

    for (final candidate in candidates) {
      candidate.score = _suggestionScore(query, candidate);
    }
    candidates.sort((a, b) {
      final score = a.score.compareTo(b.score);
      return score != 0 ? score : a.label.compareTo(b.label);
    });
    return candidates.take(6).toList(growable: false);
  }

  int _suggestionScore(String query, _SearchSuggestion suggestion) {
    final label = _normalizeSearchText(suggestion.label);
    final subtitle = _normalizeSearchText(suggestion.subtitle);
    final searchTerms = _normalizeSearchText(suggestion.searchTerms);
    if (label.startsWith(query)) return 0;
    if (searchTerms.split(' ').contains(query)) return 5;
    if (label.split(' ').any((word) => word.startsWith(query))) return 10;
    final labelIndex = label.indexOf(query);
    if (labelIndex >= 0) return 20 + labelIndex;
    if (subtitle.contains(query)) return 40 + subtitle.indexOf(query);
    if (searchTerms.contains(query)) return 45 + searchTerms.indexOf(query);

    // A small typo still gets a useful nearest suggestion. Even for a very
    // different input, candidates are ranked instead of showing an empty box.
    final words = <String>[...label.split(' '), ...subtitle.split(' ')];
    final distance = words
        .map((word) => _editDistance(query, word))
        .fold<int>(999, (best, value) => value < best ? value : best);
    return 100 + distance;
  }

  int _editDistance(String left, String right) {
    var previous = List<int>.generate(right.length + 1, (index) => index);
    for (var i = 1; i <= left.length; i++) {
      final current = <int>[i];
      for (var j = 1; j <= right.length; j++) {
        final replace = previous[j - 1] +
            (left.codeUnitAt(i - 1) == right.codeUnitAt(j - 1) ? 0 : 1);
        final insert = current[j - 1] + 1;
        final delete = previous[j] + 1;
        current.add([replace, insert, delete].reduce((a, b) => a < b ? a : b));
      }
      previous = current;
    }
    return previous.last;
  }

  Future<void> _openFilter() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.filter, arguments: _filters);
    if (result is SearchFilters && mounted) _applyFilters(result);
  }

  void _clearAllFilters() {
    _debounce?.cancel();
    _searchController.clear();
    _suggestions = const <_SearchSuggestion>[];
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
        SnackBar(
          content: Text(
            wasFavorite
                ? tr('Đã bỏ khỏi yêu thích.', 'Removed from saved.')
                : tr('Đã thêm vào yêu thích.', 'Added to saved.'),
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        final next = Set<String>.of(_favoriteIds);
        wasFavorite
            ? next.add(summary.hotel.id)
            : next.remove(summary.hotel.id);
        _favoriteIds = next;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.isUnauthorized
                ? tr(
                    'Vui lòng đăng nhập để lưu yêu thích.',
                    'Please sign in to save favorites.',
                  )
                : error.message,
          ),
        ),
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
              onSubmitted: _submitSearch,
              onFilter: _openFilter,
              onClear: () {
                _debounce?.cancel();
                _searchController.clear();
                _suggestions = const <_SearchSuggestion>[];
                _applyFilters(
                  _filters.copyWith(keyword: ''),
                  syncTextField: false,
                );
              },
              activeFilterCount: activeCount,
            ),
            if (_suggestions.isNotEmpty)
              _SuggestionPanel(
                suggestions: _suggestions,
                onSelected: _selectSuggestion,
              ),
            _QuickChips(filters: _filters, onChanged: _applyFilters),
            Expanded(
              child: FutureBuilder<List<HotelSummary>>(
                key: ValueKey(_searchResultKey),
                future: _hotelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }

                  // Loi mang va "khong co ket qua" phai trong khac nhau.
                  if (snapshot.hasError) {
                    return StayzErrorView(
                      error: snapshot.error,
                      onRetry: _runSearch,
                    );
                  }

                  // Chan response cu/khong loc bi render sau khi keyword da doi.
                  // Day la lop bao ve UI ngoai viec loc trong repository.
                  final currentKeyword = _normalizeSearchText(_filters.keyword);
                  final hotels = (snapshot.data ?? const <HotelSummary>[])
                      .where(
                        (summary) =>
                            currentKeyword.isEmpty ||
                            _matchesCurrentKeyword(summary, currentKeyword),
                      )
                      .toList(growable: false);
                  if (hotels.isEmpty) {
                    return StayzEmptyView(
                      icon: Icons.search_off_rounded,
                      title: tr(
                        'Không tìm thấy khách sạn phù hợp',
                        'No matching hotels',
                      ),
                      message: activeCount > 0 || _filters.keyword.isNotEmpty
                          ? tr(
                              'Hãy thử bỏ bớt điều kiện lọc hoặc dùng từ khoá khác.',
                              'Try removing some filters or using a different keyword.',
                            )
                          : tr(
                              'Hiện chưa có khách sạn nào trong dữ liệu.',
                              'No hotels available yet.',
                            ),
                      actionLabel:
                          activeCount > 0 || _filters.keyword.isNotEmpty
                          ? tr('Xoá bộ lọc', 'Clear filters')
                          : null,
                      onAction: activeCount > 0 || _filters.keyword.isNotEmpty
                          ? _clearAllFilters
                          : null,
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      4,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: hotels.length + 1,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: 14 * responsive.scale),
                    itemBuilder: (context, index) {
                      if (index == 0) return _ResultCount(count: hotels.length);

                      final summary = hotels[index - 1];
                      final soldOut = summary.isSoldOut;

                      return SearchHotelCard(
                        key: ValueKey('search-hotel-${summary.hotel.id}'),
                        name: summary.hotel.name,
                        location:
                            '${summary.city.name}, ${summary.city.region}',
                        price: summary.hasPrice
                            ? StayzFormatters.fullVnd(summary.lowestPrice)
                            : tr('Liên hệ', 'Contact'),
                        rating: summary.rating,
                        reviewCount: summary.reviewCount,
                        amenities: summary.hotel.amenityIds,
                        badge: soldOut
                            ? tr('Hết phòng', 'Sold out')
                            : summary.availableRooms <= 3
                            ? tr(
                                'Chỉ còn ${summary.availableRooms} phòng',
                                'Only ${summary.availableRooms} rooms left',
                              )
                            : summary.hotel.status == 'featured'
                            ? tr('Nổi bật', 'Featured')
                            : null,
                        badgeIsWarning: soldOut || summary.availableRooms <= 3,
                        favorite: _favoriteIds.contains(summary.hotel.id),
                        imageUrl: summary.hotel.imageUrls.firstOrNull,
                        colors:
                            _searchHotelColors[(index - 1) %
                                _searchHotelColors.length],
                        onFavoriteTap: () => _toggleFavorite(summary),
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.hotelDetail, arguments: summary),
                        onRoomsTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.roomSelection,
                          arguments: RoomSelectionArgs(
                            hotel: summary,
                            adults: _filters.guests ?? 2,
                          ),
                        ),
                        onBookNow: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.hotelDetail, arguments: summary),
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

  bool _matchesCurrentKeyword(HotelSummary summary, String keyword) {
    final text = _normalizeSearchText(
      [
        summary.hotel.name,
        summary.hotel.address,
        summary.city.name,
        summary.city.region,
        _citySearchAliases(summary.hotel.cityId),
      ].join(' '),
    );
    return text.contains(keyword);
  }

  String _citySearchAliases(String cityId) => switch (cityId) {
    'ho-chi-minh' => 'HCM TPHCM TP HCM Sai Gon Saigon Ho Chi Minh',
    'ha-noi' => 'HN Ha Noi Hanoi',
    'da-nang' => 'DN Da Nang Danang',
    'da-lat' => 'DL Da Lat Dalat Lam Dong',
    'vung-tau' => 'VT Vung Tau',
    _ => '',
  };

  String _normalizeSearchText(String value) {
    const accented =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const plain =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = value.toLowerCase();
    for (var i = 0; i < accented.length; i++) {
      result = result.replaceAll(accented[i], plain[i]);
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _SearchSuggestion {
  _SearchSuggestion({
    required this.keyword,
    required this.label,
    required this.subtitle,
    this.searchTerms = '',
    required this.icon,
  });

  final String keyword;
  final String label;
  final String subtitle;
  final String searchTerms;
  final IconData icon;
  int score = 0;
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({
    required this.suggestions,
    required this.onSelected,
  });

  final List<_SearchSuggestion> suggestions;
  final ValueChanged<_SearchSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Container(
      margin: EdgeInsets.fromLTRB(
        52 * responsive.widthScale,
        0,
        responsive.horizontalPadding,
        8 * responsive.scale,
      ),
      constraints: BoxConstraints(maxHeight: 220 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: true,
            leading: Icon(suggestion.icon, color: AppTheme.primary),
            title: Text(
              suggestion.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              suggestion.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.north_west_rounded, size: 18),
            onTap: () => onSelected(suggestion),
          );
        },
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
      padding: EdgeInsets.fromLTRB(
        4 * responsive.widthScale,
        8 * responsive.scale,
        responsive.horizontalPadding,
        10 * responsive.scale,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: tr('Quay lại', 'Back'),
            color: AppTheme.ink,
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 60 * responsive.scale),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * responsive.widthScale,
                vertical: 10 * responsive.scale,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => onSubmitted(controller.text.trim()),
                    tooltip: tr('Tìm kiếm', 'Search'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: 36 * responsive.scale,
                      height: 40 * responsive.scale,
                    ),
                    icon: Icon(
                      Icons.search_rounded,
                      size: 24 * responsive.scale,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(width: 6 * responsive.widthScale),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontSize: 15 * responsive.scale,
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: tr('Bạn muốn đi đâu?', 'Where to?'),
                        hintStyle: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 15 * responsive.scale,
                          fontWeight: FontWeight.w700,
                        ),
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
                          padding: EdgeInsets.only(
                            right: 6 * responsive.widthScale,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppTheme.muted,
                          ),
                        ),
                      );
                    },
                  ),
                  // Nut loc dat trong hop, giong het nut tune cua SearchBox trang chu,
                  // them badge dem so dieu kien dang bat.
                  Semantics(
                    button: true,
                    label: activeFilterCount > 0
                        ? tr(
                            'Bộ lọc, đang bật $activeFilterCount điều kiện',
                            'Filters, $activeFilterCount active',
                          )
                        : tr('Bộ lọc', 'Filters'),
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
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 19 * responsive.scale,
                          ),
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
    const quickAmenities = {
      'outdoor_pool',
      'breakfast',
      'family_room',
      'free_parking',
    };
    final hasQuickFilter =
        filters.isPreferred ||
        filters.nearBeach ||
        filters.maxPrice == 2000000 ||
        filters.amenities.any(quickAmenities.contains);

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
            label: tr('Tất cả', 'All'),
            icon: Icons.apps_rounded,
            active: !hasQuickFilter,
            onTap: () => onChanged(
              SearchFilters(
                keyword: filters.keyword,
                city: filters.city,
                type: filters.type,
                roomType: filters.roomType,
                minPrice: filters.minPrice,
                maxPrice: filters.maxPrice == 2000000 ? null : filters.maxPrice,
                guests: filters.guests,
                amenities: filters.amenities
                    .where((slug) => !quickAmenities.contains(slug))
                    .toList(growable: false),
              ),
            ),
          ),
          _chip(
            label: tr('Cao cấp', 'Premium'),
            icon: Icons.diamond_rounded,
            active: filters.isPreferred,
            onTap: () =>
                onChanged(filters.copyWith(isPreferred: !filters.isPreferred)),
          ),
          _chip(
            label: tr('Gần biển', 'Near beach'),
            icon: Icons.beach_access_rounded,
            active: filters.nearBeach,
            onTap: () =>
                onChanged(filters.copyWith(nearBeach: !filters.nearBeach)),
          ),
          _chip(
            label: tr('Dưới 2tr', 'Under 2M'),
            icon: Icons.payments_rounded,
            active: filters.maxPrice == 2000000,
            onTap: () => onChanged(
              filters.maxPrice == 2000000
                  ? filters.copyWith(clearPrice: true)
                  : filters.copyWith(maxPrice: 2000000),
            ),
          ),
          for (final slug in const [
            'outdoor_pool',
            'breakfast',
            'family_room',
            'free_parking',
          ])
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

  Widget _chip({
    required String label,
    IconData? icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: FilterPill(
          label: label,
          icon: icon,
          active: active,
          onTap: onTap,
        ),
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
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
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
