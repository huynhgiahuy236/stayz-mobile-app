import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            IgnorePointer(
              child: Opacity(
                opacity: 0.32,
                child: Transform.scale(
                  scale: 1.02,
                  child: const HomePage(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.84,
                ),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  20 * responsive.scale,
                  responsive.horizontalPadding,
                  28 * responsive.scale,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 58 * responsive.widthScale,
                          height: 6 * responsive.scale,
                          decoration: BoxDecoration(
                            color: AppTheme.neutral200,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      SizedBox(height: 42 * responsive.scale),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Bo loc',
                              style: TextStyle(
                                color: AppTheme.ink,
                                fontSize: 28 * responsive.scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            'Dat lai',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 16 * responsive.scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 56 * responsive.scale),
                      _FilterTitle(label: 'Khoang gia'),
                      SizedBox(height: 34 * responsive.scale),
                      const _PriceRangeVisual(),
                      SizedBox(height: 34 * responsive.scale),
                      Row(
                        children: [
                          Text(
                            'd0',
                            style: TextStyle(
                              color: AppTheme.neutral500,
                              fontSize: 13 * responsive.scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'd10M+',
                            style: TextStyle(
                              color: AppTheme.neutral500,
                              fontSize: 13 * responsive.scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 58 * responsive.scale),
                      _FilterTitle(label: 'Loai khach san'),
                      SizedBox(height: 24 * responsive.scale),
                      Wrap(
                        spacing: 12 * responsive.widthScale,
                        runSpacing: 14 * responsive.scale,
                        children: const [
                          _ChoiceChip(label: 'Boutique', active: true),
                          _ChoiceChip(label: 'Resort', active: true),
                          _ChoiceChip(label: 'Villa'),
                          _ChoiceChip(label: 'Hostel'),
                          _ChoiceChip(label: 'Business'),
                        ],
                      ),
                      SizedBox(height: 58 * responsive.scale),
                      _FilterTitle(label: 'Tien ich'),
                      SizedBox(height: 20 * responsive.scale),
                      const _AmenityRow(icon: Icons.pool_outlined, label: 'Ho boi', active: true),
                      const _AmenityRow(icon: Icons.wifi, label: 'Wifi', active: true),
                      const _AmenityRow(icon: Icons.local_parking_outlined, label: 'Bai do xe'),
                      const _AmenityRow(icon: Icons.local_cafe_outlined, label: 'Bua sang'),
                      const _AmenityRow(icon: Icons.spa_outlined, label: 'Spa'),
                      SizedBox(height: 32 * responsive.scale),
                      PrimarySearchButton(
                        label: 'Xem 18 ket qua',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        fontSize: 22 * responsive.scale,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PriceRangeVisual extends StatelessWidget {
  const _PriceRangeVisual();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Column(
      children: [
        SizedBox(
          height: 40 * responsive.scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 5 * responsive.scale,
                decoration: BoxDecoration(
                  color: AppTheme.neutral200.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Positioned(
                left: 72 * responsive.widthScale,
                right: 230 * responsive.widthScale,
                child: Container(
                  height: 5 * responsive.scale,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(left: 44 * responsive.widthScale, child: const _RangeThumb()),
              Positioned(left: 202 * responsive.widthScale, child: const _RangeThumb()),
            ],
          ),
        ),
        SizedBox(height: 28 * responsive.scale),
        Text(
          'd500K  -  d5M',
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 28 * responsive.scale,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _RangeThumb extends StatelessWidget {
  const _RangeThumb();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      width: 44 * responsive.scale,
      height: 44 * responsive.scale,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD9B8B8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 48 * responsive.scale,
      padding: EdgeInsets.symmetric(horizontal: 22 * responsive.widthScale),
      decoration: BoxDecoration(
        color: active ? AppTheme.accent : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? AppTheme.accent : AppTheme.neutral200),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.neutral800,
            fontSize: 17 * responsive.scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * responsive.scale),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5B3D3A), size: 28 * responsive.scale),
          SizedBox(width: 22 * responsive.widthScale),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 21 * responsive.scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 30 * responsive.scale,
            height: 30 * responsive.scale,
            decoration: BoxDecoration(
              color: active ? AppTheme.accent : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: active ? AppTheme.accent : const Color(0xFFD9B8B8)),
            ),
            child: active
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 22 * responsive.scale,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
