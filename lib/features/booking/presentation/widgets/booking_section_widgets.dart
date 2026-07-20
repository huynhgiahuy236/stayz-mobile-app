import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class BookingTopBar extends StatelessWidget {
  const BookingTopBar({
    required this.title,
    this.trailing,
    this.onBack,
    this.fallbackRoute,
    super.key,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;
  final String? fallbackRoute;

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
            onPressed: () {
              if (onBack != null) {
                onBack!();
                return;
              }
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else if (fallbackRoute != null) {
                navigator.pushReplacementNamed(fallbackRoute!);
              }
            },
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
      height: AppTheme.pageActionHeight,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * responsive.scale,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 12 * responsive.widthScale),
              Icon(icon, color: Colors.white, size: 22 * responsive.scale),
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
    required this.onDetails,
    required this.canBook,
    this.imageUrl,
    this.roomMeta = const <String>[],
    this.amenityLabels = const <String>[],
    this.note,
    super.key,
  });

  final String name;
  final String price;
  final String badge;
  final Color badgeColor;
  final List<Color> colors;
  final VoidCallback onBook;
  final VoidCallback onDetails;
  final bool canBook;
  final String? imageUrl;
  final List<String> roomMeta;
  final List<String> amenityLabels;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoomImageBanner(
            imageUrl: imageUrl,
            colors: colors,
            height: 136 * responsive.scale,
          ),
          Padding(
            padding: EdgeInsets.all(14 * responsive.scale),
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
                        vertical: 5 * responsive.scale,
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
                SizedBox(height: 10 * responsive.scale),
                Wrap(
                  spacing: 8 * responsive.widthScale,
                  runSpacing: 8 * responsive.scale,
                  children: roomMeta
                      .map((label) => _RoomMeta(label: label))
                      .toList(),
                ),
                SizedBox(height: 10 * responsive.scale),
                if (amenityLabels.isNotEmpty)
                  Wrap(
                    spacing: 8 * responsive.widthScale,
                    runSpacing: 8 * responsive.scale,
                    children: amenityLabels
                        .take(3)
                        .map((label) => _AmenityChip(label: label))
                        .toList(),
                  ),
                SizedBox(
                  height: amenityLabels.isEmpty ? 0 : 10 * responsive.scale,
                ),
                Divider(
                  height: 28 * responsive.scale,
                  color: AppTheme.neutral200,
                ),
                Text.rich(
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
                        text: tr(' / đêm', ' / night'),
                        style: TextStyle(
                          color: AppTheme.neutral800,
                          fontSize: 11 * responsive.scale,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: onDetails,
                          child: Text(tr('Chi tiáº¿t phÃ²ng', 'Room details')),
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * responsive.widthScale),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: canBook ? onBook : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.controlRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            canBook
                                ? tr('Đặt ngay', 'Book now')
                                : tr('Hết phòng', 'Sold out'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15 * responsive.scale,
                              fontWeight: FontWeight.w800,
                            ),
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

class _RoomImageBanner extends StatelessWidget {
  const _RoomImageBanner({
    required this.imageUrl,
    required this.colors,
    required this.height,
  });

  final String? imageUrl;
  final List<Color> colors;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? '';
    if (url.isNotEmpty) {
      return StayZNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: height,
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: Icon(Icons.hotel_outlined, color: Colors.white70, size: 42),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});

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
        color: AppTheme.successSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.success,
          fontSize: 11 * responsive.scale,
          fontWeight: FontWeight.w600,
        ),
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
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.muted,
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
        border: Border.all(
          color: active ? AppTheme.accentDark : AppTheme.neutral200,
        ),
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
