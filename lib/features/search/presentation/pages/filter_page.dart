import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late SearchFilters _filters;
  double _maxPrice = 5000000;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    _filters = args is SearchFilters ? args : const SearchFilters();
    _maxPrice = (_filters.maxPrice ?? 5000000).toDouble().clamp(500000, 10000000).toDouble();
    _initialized = true;
  }

  void _toggleAmenity(String value) {
    final next = Set<String>.of(_filters.amenities);
    next.contains(value) ? next.remove(value) : next.add(value);
    setState(() => _filters = _filters.copyWith(amenities: next.toList()));
  }

  void _apply() {
    Navigator.of(context).pop(_filters.copyWith(maxPrice: _maxPrice.round()));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.78),
            padding: EdgeInsets.fromLTRB(
              responsive.horizontalPadding,
              12 * responsive.scale,
              responsive.horizontalPadding,
              24 * responsive.scale,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Filters',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 22 * responsive.scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _filters = const SearchFilters();
                        _maxPrice = 5000000;
                      }),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _FilterTitle(label: 'Max price'),
                      SizedBox(height: 8 * responsive.scale),
                      Text(
                        StayzFormatters.fullVnd(_maxPrice.round()),
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 24 * responsive.scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Slider(
                        min: 500000,
                        max: 10000000,
                        divisions: 19,
                        value: _maxPrice,
                        label: StayzFormatters.compactVnd(_maxPrice.round()),
                        onChanged: (value) => setState(() => _maxPrice = value),
                      ),
                      SizedBox(height: 18 * responsive.scale),
                      _FilterTitle(label: 'City'),
                      SizedBox(height: 10 * responsive.scale),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoiceButton(label: 'All', active: _filters.city == null, onTap: () => setState(() => _filters = _filters.copyWith(clearCity: true))),
                          _ChoiceButton(label: 'Da Nang', active: _filters.city == 'da-nang', onTap: () => setState(() => _filters = _filters.copyWith(city: 'da-nang'))),
                          _ChoiceButton(label: 'Da Lat', active: _filters.city == 'da-lat', onTap: () => setState(() => _filters = _filters.copyWith(city: 'da-lat'))),
                          _ChoiceButton(label: 'Ha Noi', active: _filters.city == 'ha-noi', onTap: () => setState(() => _filters = _filters.copyWith(city: 'ha-noi'))),
                        ],
                      ),
                      SizedBox(height: 18 * responsive.scale),
                      _FilterTitle(label: 'Type'),
                      SizedBox(height: 10 * responsive.scale),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoiceButton(label: 'Hotel', active: _filters.type == 'hotel', onTap: () => setState(() => _filters = _filters.copyWith(type: 'hotel'))),
                          _ChoiceButton(label: 'Resort', active: _filters.type == 'resort', onTap: () => setState(() => _filters = _filters.copyWith(type: 'resort'))),
                          _ChoiceButton(label: 'Villa', active: _filters.type == 'villa', onTap: () => setState(() => _filters = _filters.copyWith(type: 'villa'))),
                          _ChoiceButton(label: 'Clear', active: _filters.type == null, onTap: () => setState(() => _filters = _filters.copyWith(clearType: true))),
                        ],
                      ),
                      SizedBox(height: 18 * responsive.scale),
                      _FilterTitle(label: 'Amenities'),
                      SizedBox(height: 10 * responsive.scale),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoiceButton(label: 'Wifi', active: _filters.amenities.contains('free_wifi'), onTap: () => _toggleAmenity('free_wifi')),
                          _ChoiceButton(label: 'Pool', active: _filters.amenities.contains('outdoor_pool'), onTap: () => _toggleAmenity('outdoor_pool')),
                          _ChoiceButton(label: 'Parking', active: _filters.amenities.contains('free_parking'), onTap: () => _toggleAmenity('free_parking')),
                          _ChoiceButton(label: 'Breakfast', active: _filters.amenities.contains('breakfast'), onTap: () => _toggleAmenity('breakfast')),
                        ],
                      ),
                      SizedBox(height: 18 * responsive.scale),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Featured only'),
                        value: _filters.isPreferred,
                        activeColor: AppTheme.primary,
                        onChanged: (value) => setState(() => _filters = _filters.copyWith(isPreferred: value)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 52 * responsive.scale,
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTitle extends StatelessWidget {
  const _FilterTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Text(
      label,
      style: TextStyle(
        color: AppTheme.ink,
        fontSize: 16 * responsive.scale,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primarySoft,
      checkmarkColor: AppTheme.primary,
      side: BorderSide(color: active ? AppTheme.primary : AppTheme.line),
    );
  }
}
