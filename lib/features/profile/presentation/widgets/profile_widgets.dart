import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.title,
    this.brand = false,
    this.trailing,
    super.key,
  });

  final String title;
  final bool brand;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        14 * responsive.scale,
        responsive.horizontalPadding,
        16 * responsive.scale,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.accentDark,
          ),
          SizedBox(width: 10 * responsive.widthScale),
          Expanded(
            child: brand
                ? RichText(
                    text: TextSpan(
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.ink,
                        fontSize: 28 * responsive.scale,
                        fontWeight: FontWeight.w700,
                      ),
                      children: const [
                        TextSpan(text: 'Stay'),
                        TextSpan(
                          text: 'Z',
                          style: TextStyle(color: AppTheme.accent),
                        ),
                      ],
                    ),
                  )
                : Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 24 * responsive.scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          SizedBox(
            width: 42 * responsive.scale,
            child: trailing ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppTheme.muted,
        fontSize: 13 * responsive.scale,
        letterSpacing: 4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.danger = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final color = danger ? const Color(0xFFD00000) : AppTheme.accentDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 18 * responsive.widthScale,
          vertical: 18 * responsive.scale,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 27 * responsive.scale),
            SizedBox(width: 22 * responsive.widthScale),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: danger ? color : AppTheme.ink,
                  fontSize: 19 * responsive.scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.neutral500,
                  size: 28 * responsive.scale,
                ),
          ],
        ),
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  const ProfileInputField({
    required this.label,
    required this.value,
    this.trailing,
    this.error,
    this.large = false,
    super.key,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final String? error;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(label: label),
        SizedBox(height: 12 * responsive.scale),
        Container(
          height: large ? 108 * responsive.scale : 58 * responsive.scale,
          padding: EdgeInsets.symmetric(horizontal: 18 * responsive.widthScale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFD00000)
                  : const Color(0xFF5C6778),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: large ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 17 * responsive.scale,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 10 * responsive.scale),
          Text(
            error!,
            style: TextStyle(
              color: const Color(0xFFD00000),
              fontSize: 14 * responsive.scale,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class ProfilePrimaryButton extends StatelessWidget {
  const ProfilePrimaryButton({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: 62 * responsive.scale,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 19 * responsive.scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class PaymentAccountTile extends StatelessWidget {
  const PaymentAccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.defaultBadge = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool defaultBadge;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 58 * responsive.scale,
            height: 58 * responsive.scale,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF1EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD9B8B8)),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentDark,
              size: 28 * responsive.scale,
            ),
          ),
          SizedBox(width: 20 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 20 * responsive.scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6 * responsive.scale),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 16 * responsive.scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (defaultBadge)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14 * responsive.widthScale,
                vertical: 10 * responsive.scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF1E7E3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD9B8B8)),
              ),
              child: Text(
                tr('MẶC ĐỊNH', 'DEFAULT'),
                style: TextStyle(
                  color: AppTheme.neutral500,
                  fontSize: 13 * responsive.scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          SizedBox(width: 14 * responsive.widthScale),
          Icon(
            Icons.chevron_right,
            color: AppTheme.neutral500,
            size: 30 * responsive.scale,
          ),
        ],
      ),
    );
  }
}
