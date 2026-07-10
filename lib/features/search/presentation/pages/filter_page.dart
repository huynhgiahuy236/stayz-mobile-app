import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

/// Gioi han thanh truot khop voi khoang gia phong that trong du lieu
/// (thap nhat 320.000d o hostel, cao nhat 21.000.000d o villa bien).
const _minPriceBound = 300000.0;
const _maxPriceBound = 22000000.0;

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late SearchFilters _filters;
  RangeValues? _priceRange;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    _filters = args is SearchFilters ? args : const SearchFilters();

    // `null` nghia la nguoi dung chua dat gioi han gia nao. Truoc day man nay
    // luon gui maxPrice = 5.000.000d ke ca khi khong ai cham vao thanh truot.
    if (_filters.minPrice != null || _filters.maxPrice != null) {
      _priceRange = RangeValues(
        (_filters.minPrice ?? _minPriceBound).toDouble().clamp(_minPriceBound, _maxPriceBound),
        (_filters.maxPrice ?? _maxPriceBound).toDouble().clamp(_minPriceBound, _maxPriceBound),
      );
    }
    _initialized = true;
  }

  void _toggleAmenity(String value) {
    final next = Set<String>.of(_filters.amenities);
    next.contains(value) ? next.remove(value) : next.add(value);
    setState(() => _filters = _filters.copyWith(amenities: next.toList()));
  }

  void _reset() {
    setState(() {
      _filters = SearchFilters(keyword: _filters.keyword);
      _priceRange = null;
    });
  }

  void _apply() {
    final range = _priceRange;
    final result = range == null
        ? _filters.copyWith(clearPrice: true)
        : _filters.copyWith(
            minPrice: range.start <= _minPriceBound ? null : range.start.round(),
            maxPrice: range.end >= _maxPriceBound ? null : range.end.round(),
          );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final range = _priceRange;
    final activeCount = _filters.activeCount + (range == null ? 0 : 1);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.86),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(activeCount: activeCount, onReset: _reset),
                const Divider(height: 1, color: AppTheme.line),
                Flexible(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    children: [
                      _SectionTitle(tr('Thành phố', 'City')),
                      _ChipRow(
                        options: [
                          _Option(label: tr('Tất cả', 'All'), selected: _filters.city == null, onTap: () => setState(() => _filters = _filters.copyWith(clearCity: true))),
                          for (final city in StayzTaxonomy.cities)
                            _Option(
                              label: city.label,
                              selected: _filters.city == city.slug,
                              onTap: () => setState(() => _filters = _filters.copyWith(city: city.slug)),
                            ),
                        ],
                      ),

                      _SectionTitle(tr('Loại hình', 'Type')),
                      _ChipRow(
                        options: [
                          _Option(label: tr('Tất cả', 'All'), selected: _filters.type == null, onTap: () => setState(() => _filters = _filters.copyWith(clearType: true))),
                          for (final type in StayzTaxonomy.propertyTypes)
                            _Option(
                              label: type.label,
                              icon: type.icon,
                              selected: _filters.type == type.slug,
                              onTap: () => setState(() => _filters = _filters.copyWith(type: type.slug)),
                            ),
                        ],
                      ),

                      _SectionTitle(tr('Hạng phòng', 'Room class')),
                      _ChipRow(
                        options: [
                          _Option(label: tr('Tất cả', 'All'), selected: _filters.roomType == null, onTap: () => setState(() => _filters = _filters.copyWith(clearRoomType: true))),
                          for (final room in StayzTaxonomy.roomTypes)
                            _Option(
                              label: room.label,
                              selected: _filters.roomType == room.slug,
                              onTap: () => setState(() => _filters = _filters.copyWith(roomType: room.slug)),
                            ),
                        ],
                      ),

                      _SectionTitle(
                        tr('Giá mỗi đêm', 'Price / night'),
                        trailing: range == null
                            ? tr('Không giới hạn', 'No limit')
                            : '${StayzFormatters.compactVnd(range.start.round())} – ${StayzFormatters.compactVnd(range.end.round())}',
                      ),
                      RangeSlider(
                        min: _minPriceBound,
                        max: _maxPriceBound,
                        divisions: 43,
                        values: range ?? const RangeValues(_minPriceBound, _maxPriceBound),
                        activeColor: AppTheme.primary,
                        inactiveColor: AppTheme.line,
                        labels: RangeLabels(
                          StayzFormatters.compactVnd((range?.start ?? _minPriceBound).round()),
                          StayzFormatters.compactVnd((range?.end ?? _maxPriceBound).round()),
                        ),
                        onChanged: (value) => setState(() => _priceRange = value),
                      ),
                      if (range != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _priceRange = null),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: Text(tr('Bỏ giới hạn giá', 'Remove price limit')),
                          ),
                        ),

                      _SectionTitle(tr('Số khách mỗi phòng', 'Guests per room')),
                      _ChipRow(
                        options: [
                          _Option(label: tr('Bất kỳ', 'Any'), selected: _filters.guests == null, onTap: () => setState(() => _filters = _filters.copyWith(clearGuests: true))),
                          for (final guests in const [2, 3, 4, 6])
                            _Option(
                              label: tr('$guests khách+', '$guests guests+'),
                              selected: _filters.guests == guests,
                              onTap: () => setState(() => _filters = _filters.copyWith(guests: guests)),
                            ),
                        ],
                      ),

                      _SectionTitle(tr('Tiện ích', 'Amenities')),
                      _ChipRow(
                        options: [
                          for (final amenity in StayzTaxonomy.propertyAmenities)
                            _Option(
                              label: amenity.label,
                              icon: amenity.icon,
                              selected: _filters.amenities.contains(amenity.slug),
                              onTap: () => _toggleAmenity(amenity.slug),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      _ToggleTile(
                        label: tr('Chỉ khách sạn nổi bật', 'Featured only'),
                        value: _filters.isPreferred,
                        onChanged: (value) => setState(() => _filters = _filters.copyWith(isPreferred: value)),
                      ),
                      _ToggleTile(
                        label: tr('Gần biển (Đà Nẵng, Vũng Tàu)', 'Near beach (Da Nang, Vung Tau)'),
                        value: _filters.nearBeach,
                        onChanged: (value) => setState(() => _filters = _filters.copyWith(nearBeach: value)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _apply,
                      child: Text(activeCount == 0 ? tr('Xem tất cả khách sạn', 'Show all hotels') : tr('Áp dụng $activeCount bộ lọc', 'Apply $activeCount filters')),
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.activeCount, required this.onReset});

  final int activeCount;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: tr('Quay lại', 'Back'),
            color: AppTheme.ink,
          ),
          Expanded(
            child: Text(
              tr('Bộ lọc', 'Filters'),
              style: const TextStyle(color: AppTheme.ink, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          if (activeCount > 0)
            TextButton(
              onPressed: onReset,
              child: Text(tr('Đặt lại', 'Reset')),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label, {this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.ink, fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }
}

class _Option {
  const _Option({required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
}

/// Chip gon giong hang chip ngoai trang chu, thay cho FilterChip mac dinh
/// von cao va nhieu vien.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.options});

  final List<_Option> options;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          Semantics(
            button: true,
            selected: option.selected,
            label: option.label,
            child: Material(
              color: option.selected ? AppTheme.ink : Colors.white,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: option.onTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: option.selected ? AppTheme.ink : AppTheme.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Icon(option.icon, size: 16, color: option.selected ? Colors.white : AppTheme.primary),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        option.label,
                        style: TextStyle(
                          color: option.selected ? Colors.white : AppTheme.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: const TextStyle(color: AppTheme.ink, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
