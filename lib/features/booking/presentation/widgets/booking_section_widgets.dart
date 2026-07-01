import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class BookingTopBar extends StatelessWidget {
  const BookingTopBar({
    required this.title,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        14 * responsive.scale,
        responsive.horizontalPadding,
        16 * responsive.scale,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.accentDark,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 18 * responsive.scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 48 * responsive.scale,
            child: trailing ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class BookingPrimaryButton extends StatelessWidget {
  const BookingPrimaryButton({
    required this.label,
    this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: FilledButton(
        onPressed: onTap ?? () {},
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * responsive.scale,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 12 * responsive.widthScale),
              Icon(icon, color: Colors.white, size: 28 * responsive.scale),
            ],
          ],
        ),
      ),
    );
  }
}

class RoomOptionCard extends StatelessWidget {
  const RoomOptionCard({
    required this.name,
    required this.price,
    required this.badge,
    required this.badgeColor,
    required this.colors,
    required this.onBook,
    this.note,
    super.key,
  });

  final String name;
  final String price;
  final String badge;
  final Color badgeColor;
  final List<Color> colors;
  final VoidCallback onBook;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 166 * responsive.scale,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18 * responsive.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 17 * responsive.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * responsive.widthScale,
                        vertical: 7 * responsive.scale,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11 * responsive.scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (note != null) ...[
                  SizedBox(height: 4 * responsive.scale),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      note!,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10 * responsive.scale,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 14 * responsive.scale),
                Wrap(
                  spacing: 8 * responsive.widthScale,
                  runSpacing: 8 * responsive.scale,
                  children: const [
                    _RoomMeta(label: '2 nguoi'),
                    _RoomMeta(label: '25m2'),
                    _RoomMeta(label: 'Giuong doi'),
                  ],
                ),
                SizedBox(height: 16 * responsive.scale),
                Row(
                  children: [
                    Icons.tv_outlined,
                    Icons.ac_unit,
                    Icons.bathtub_outlined,
                    Icons.wifi,
                  ]
                      .map(
                        (icon) => Padding(
                          padding: EdgeInsets.only(right: 22 * responsive.widthScale),
                          child: Icon(icon, color: const Color(0xFF6B5348), size: 18 * responsive.scale),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 16 * responsive.scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * responsive.widthScale,
                    vertical: 7 * responsive.scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DD),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '✓ Bao gom bua sang',
                    style: TextStyle(
                      color: const Color(0xFF3F6D25),
                      fontSize: 12 * responsive.scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(height: 42 * responsive.scale, color: AppTheme.neutral200),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: price,
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 18 * responsive.scale,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: ' /dem',
                              style: TextStyle(
                                color: AppTheme.neutral800,
                                fontSize: 11 * responsive.scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 126 * responsive.widthScale,
                      height: 52 * responsive.scale,
                      child: FilledButton(
                        onPressed: onBook,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                        child: Text(
                          'Dat ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15 * responsive.scale,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomMeta extends StatelessWidget {
  const _RoomMeta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11 * responsive.widthScale,
        vertical: 6 * responsive.scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5BFC0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFFC79291),
          fontSize: 11 * responsive.scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class CheckoutField extends StatelessWidget {
  const CheckoutField({
    required this.label,
    required this.value,
    this.large = false,
    super.key,
  });

  final String label;
  final String value;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppTheme.neutral500,
            fontSize: 10 * responsive.scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10 * responsive.scale),
        Container(
          height: large ? 104 * responsive.scale : 54 * responsive.scale,
          padding: EdgeInsets.symmetric(horizontal: 18 * responsive.widthScale),
          alignment: large ? Alignment.topLeft : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.neutral200),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: large ? 18 * responsive.scale : 0),
            child: Text(
              value,
              maxLines: large ? 3 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: large ? const Color(0xFF697386) : AppTheme.ink,
                fontSize: 16 * responsive.scale,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    required this.icon,
    required this.label,
    this.active = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 62 * responsive.scale,
      padding: EdgeInsets.symmetric(horizontal: 18 * responsive.widthScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? AppTheme.accentDark : AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentDark, size: 24 * responsive.scale),
          SizedBox(width: 18 * responsive.widthScale),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 15 * responsive.scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            active ? Icons.radio_button_checked : Icons.radio_button_off,
            color: active ? AppTheme.accentDark : AppTheme.neutral200,
            size: 22 * responsive.scale,
          ),
        ],
      ),
    );
  }
}

class PriceLine extends StatelessWidget {
  const PriceLine({
    required this.label,
    required this.value,
    this.total = false,
    super.key,
  });

  final String label;
  final String value;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.ink,
              fontSize: (total ? 16 : 14) * responsive.scale,
              fontWeight: total ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: total ? AppTheme.accentDark : AppTheme.ink,
            fontSize: (total ? 20 : 13) * responsive.scale,
            fontWeight: total ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: total ? 1 : 0,
          ),
        ),
      ],
    );
  }
}
