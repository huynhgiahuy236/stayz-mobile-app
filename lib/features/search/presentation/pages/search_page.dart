import 'dart:async';

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is SearchFilters) {
      _filters = args;
      _searchController.text = args.keyword;
    }
    _hotelsFuture = ApiStayzRepository.instance.searchHotelSummaries(_filters);
    _initialized = true;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final ids = await ApiStayzRepository.instance.getFavoriteHotelIds();
    if (mounted) setState(() => _favoriteIds = ids);
  }

  void _applyFilters(SearchFilters filters) {
    setState(() {
      _filters = filters;
      _searchController.text = filters.keyword;
      _hotelsFuture = ApiStayzRepository.instance.searchHotelSummaries(_filters);
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      _applyFilters(_filters.copyWith(keyword: value));
    });
  }

  Future<void> _openFilter() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.filter, arguments: _filters);
    if (result is SearchFilters) _applyFilters(result);
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
        SnackBar(content: Text(wasFavorite ? 'Da bo khoi yeu thich.' : 'Da them vao yeu thich.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final next = Set<String>.of(_favoriteIds);
        wasFavorite ? next.add(summary.hotel.id) : next.remove(summary.hotel.id);
        _favoriteIds = next;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long dang nhap de cap nhat yeu thich.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StayZScreenHeader(
              title: 'Find stays',
              subtitle: 'Search',
              trailing: IconButton.filledTonal(
                onPressed: _openFilter,
                icon: const Icon(Icons.tune_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primarySoft,
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: _SearchInputCard(
                responsive: responsive,
                controller: _searchController,
                onChanged: _onSearchChanged,
                onFilter: _openFilter,
              ),
            ),
            SizedBox(height: 14 * responsive.scale),
            SizedBox(
              height: 42 * responsive.scale,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                children: [
                  _FilterActionPill(
                    label: 'Featured',
                    icon: Icons.star_rounded,
                    active: _filters.isPreferred,
                    onTap: () => _applyFilters(_filters.copyWith(isPreferred: !_filters.isPreferred)),
                  ),
                  const SizedBox(width: 10),
                  _FilterActionPill(
                    label: 'Under 2M',
                    icon: Icons.payments_rounded,
                    active: _filters.maxPrice == 2000000,
                    onTap: () => _applyFilters(
                      _filters.maxPrice == 2000000
                          ? _filters.copyWith(clearMaxPrice: true)
                          : _filters.copyWith(maxPrice: 2000000),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FilterActionPill(
                    label: 'Wifi',
                    icon: Icons.wifi,
                    active: _filters.amenities.contains('free_wifi'),
                    onTap: () {
                      final next = Set<String>.of(_filters.amenities);
                      next.contains('free_wifi') ? next.remove('free_wifi') : next.add('free_wifi');
                      _applyFilters(_filters.copyWith(amenities: next.toList()));
                    },
                  ),
                  const SizedBox(width: 10),
                  _FilterActionPill(
                    label: 'Da Nang',
                    icon: Icons.location_city_rounded,
                    active: _filters.city == 'da-nang',
                    onTap: () => _applyFilters(
                      _filters.city == 'da-nang'
                          ? _filters.copyWith(clearCity: true)
                          : _filters.copyWith(city: 'da-nang'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16 * responsive.scale),
            Expanded(
              child: FutureBuilder<List<HotelSummary>>(
                future: _hotelsFuture,
                builder: (context, snapshot) {
                  final hotels = snapshot.data ?? const <HotelSummary>[];

                  if (hotels.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      0,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: hotels.length + 1,
                    separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 16 * responsive.scale : 18 * responsive.scale),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ResultToolbar(count: hotels.length);
                      }
                      final hotelIndex = index - 1;
                      final summary = hotels[hotelIndex];
                      return SearchHotelCard(
                        name: summary.hotel.name,
                        location: '${summary.city.name}, ${summary.city.region}',
                        price: StayzFormatters.fullVnd(summary.lowestPrice),
                        reviewCount: (96 + hotelIndex * 31).toString(),
                        badge: summary.availableRooms <= 2 ? 'Only ${summary.availableRooms} rooms' : 'Recommended',
                        favorite: _favoriteIds.contains(summary.hotel.id),
                        imageUrl: summary.hotel.imageUrls.firstOrNull,
                        colors: _searchHotelColors[hotelIndex % _searchHotelColors.length],
                        onFavoriteTap: () => _toggleFavorite(summary),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.roomDetail,
                          arguments: summary,
                        ),
                        onRoomsTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.roomSelection,
                          arguments: RoomSelectionArgs(hotel: summary),
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

class _SearchInputCard extends StatelessWidget {
  const _SearchInputCard({
    required this.responsive,
    required this.controller,
    required this.onChanged,
    required this.onFilter,
  });

  final HomeResponsive responsive;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppTheme.primary, size: 24 * responsive.scale),
          SizedBox(width: 10 * responsive.widthScale),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Search hotel or address',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: onFilter,
            icon: const Icon(Icons.tune_rounded),
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _FilterActionPill extends StatelessWidget {
  const _FilterActionPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: FilterPill(label: label, icon: icon, active: active),
    );
  }
}

class _ResultToolbar extends StatelessWidget {
  const _ResultToolbar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            '$count stays found',
            style: TextStyle(color: AppTheme.ink, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.view_agenda_rounded),
          color: AppTheme.primary,
        ),
      ],
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
