import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

enum BookingManageTab { upcoming, completed, cancelled }

class BookingManageHeader extends StatelessWidget {
  const BookingManageHeader({
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
        color: const Color(0xFFFBF7F4),
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.65)),
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
                        fontSize: 29 * responsive.scale,
                        fontWeight: FontWeight.w700,
                      ),
                      children: const [
                        TextSpan(text: 'Stay'),
                        TextSpan(text: 'Z', style: TextStyle(color: AppTheme.accent)),
                      ],
                    ),
                  )
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.accentDark,
                      fontSize: 27 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          SizedBox(
            width: 44 * responsive.scale,
            child: trailing ?? Icon(Icons.more_vert, color: AppTheme.accentDark, size: 28 * responsive.scale),
          ),
        ],
      ),
    );
  }
}

class BookingManageTabs extends StatelessWidget {
  const BookingManageTabs({
    required this.activeTab,
    required this.upcomingRoute,
    required this.completedRoute,
    required this.cancelledRoute,
    super.key,
  });

  final BookingManageTab activeTab;
  final String upcomingRoute;
  final String completedRoute;
  final String cancelledRoute;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.75))),
      ),
      child: Row(
        children: [
          _BookingTab(
            label: 'Sap toi',
            active: activeTab == BookingManageTab.upcoming,
            routeName: upcomingRoute,
          ),
          _BookingTab(
            label: 'Da hoan thanh',
            active: activeTab == BookingManageTab.completed,
            routeName: completedRoute,
          ),
          _BookingTab(
            label: 'Da huy',
            active: activeTab == BookingManageTab.cancelled,
            routeName: cancelledRoute,
          ),
        ],
      ),
    );
  }
}

class _BookingTab extends StatelessWidget {
  const _BookingTab({
    required this.label,
    required this.routeName,
    this.active = false,
  });

  final String label;
  final String routeName;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Expanded(
      child: InkWell(
        onTap: active ? null : () => Navigator.of(context).pushReplacementNamed(routeName),
        child: Container(
          height: 72 * responsive.scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppTheme.accentDark : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? AppTheme.accentDark : AppTheme.neutral500,
              fontSize: 16 * responsive.scale,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class BookingStatusPill extends StatelessWidget {
  const BookingStatusPill({
    required this.label,
    required this.color,
    this.textColor,
    super.key,
  });

  final String label;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * responsive.widthScale,
        vertical: 8 * responsive.scale,
      ),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor ?? AppTheme.accentDark,
          fontSize: 12 * responsive.scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class UpcomingBookingCard extends StatelessWidget {
  const UpcomingBookingCard({
    required this.name,
    required this.location,
    required this.code,
    required this.checkIn,
    required this.checkOut,
    required this.colors,
    required this.onDetail,
    required this.onCancel,
    super.key,
  });

  final String name;
  final String location;
  final String code;
  final String checkIn;
  final String checkOut;
  final List<Color> colors;
  final VoidCallback onDetail;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 88 * responsive.scale,
                height: 88 * responsive.scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: colors),
                ),
              ),
              SizedBox(width: 20 * responsive.widthScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 22 * responsive.scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8 * responsive.scale),
                    Text(
                      location,
                      style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 16 * responsive.scale),
                    ),
                  ],
                ),
              ),
              const BookingStatusPill(label: 'Sap toi', color: Color(0xFFFFE0DE)),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: const Color(0xFFD9B8B8)),
          Row(
            children: [
              Expanded(child: _MetaBlock(label: 'Nhan phong', value: checkIn)),
              Expanded(child: _MetaBlock(label: 'Tra phong', value: checkOut)),
            ],
          ),
          Divider(height: 34 * responsive.scale, color: const Color(0xFFD9B8B8)),
          Align(
            alignment: Alignment.centerLeft,
            child: _MetaBlock(label: 'Ma dat phong', value: code, large: true),
          ),
          SizedBox(height: 28 * responsive.scale),
          Row(
            children: [
              Expanded(child: BookingSoftButton(label: 'Xem chi tiet', onTap: onDetail)),
              SizedBox(width: 18 * responsive.widthScale),
              Expanded(child: BookingOutlineButton(label: 'Huy dat phong', onTap: onCancel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.label,
    required this.value,
    this.large = false,
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
            color: const Color(0xFF5A3F3F),
            fontSize: 12 * responsive.scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 10 * responsive.scale),
        Text(
          value,
          style: TextStyle(
            color: large ? AppTheme.accentDark : AppTheme.ink,
            fontSize: (large ? 25 : 18) * responsive.scale,
            fontWeight: FontWeight.w900,
            letterSpacing: large ? 1 : 0,
          ),
        ),
      ],
    );
  }
}

class BookingSoftButton extends StatelessWidget {
  const BookingSoftButton({
    required this.label,
    this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      height: 54 * responsive.scale,
      child: FilledButton(
        onPressed: onTap ?? () {},
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF4ECE6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppTheme.accentDark, fontSize: 16 * responsive.scale, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class BookingOutlineButton extends StatelessWidget {
  const BookingOutlineButton({
    required this.label,
    this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      height: 54 * responsive.scale,
      child: OutlinedButton(
        onPressed: onTap ?? () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFC5C3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppTheme.accentDark, fontSize: 16 * responsive.scale, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class HistoryBookingCard extends StatelessWidget {
  const HistoryBookingCard({
    required this.name,
    required this.date,
    required this.price,
    required this.colors,
    required this.onPrimary,
    this.primaryLabel = 'Danh gia ngay',
    this.secondaryLabel = 'Dat lai',
    super.key,
  });

  final String name;
  final String date;
  final String price;
  final List<Color> colors;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(18 * responsive.scale),
            child: Row(
              children: [
                Container(
                  width: 96 * responsive.scale,
                  height: 96 * responsive.scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(colors: colors),
                  ),
                ),
                SizedBox(width: 18 * responsive.widthScale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BookingStatusPill(
                        label: 'Da hoan thanh',
                        color: Color(0xFFBDF4D4),
                        textColor: Color(0xFF096A43),
                      ),
                      SizedBox(height: 12 * responsive.scale),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.ink, fontSize: 18 * responsive.scale, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 10 * responsive.scale),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: const Color(0xFF5A3F3F), size: 17 * responsive.scale),
                          SizedBox(width: 10 * responsive.widthScale),
                          Expanded(
                            child: Text(date, style: TextStyle(color: const Color(0xFF5A3F3F), fontSize: 18 * responsive.scale)),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * responsive.scale),
                      Text(
                        price,
                        style: TextStyle(
                          color: AppTheme.accentDark,
                          fontSize: 19 * responsive.scale,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.neutral200),
          Padding(
            padding: EdgeInsets.all(16 * responsive.scale),
            child: Row(
              children: [
                Expanded(child: _FilledAction(label: primaryLabel, onTap: onPrimary)),
                SizedBox(width: 14 * responsive.widthScale),
                Expanded(child: BookingOutlineButton(label: secondaryLabel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  const _FilledAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SizedBox(
      height: 54 * responsive.scale,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 16 * responsive.scale, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class BookingDetailPanel extends StatelessWidget {
  const BookingDetailPanel({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppTheme.neutral500,
              fontSize: 12 * responsive.scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          SizedBox(height: 18 * responsive.scale),
          ...children,
        ],
      ),
    );
  }
}

class DetailLine extends StatelessWidget {
  const DetailLine({
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9 * responsive.scale),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: total ? AppTheme.accentDark : const Color(0xFF5A3F3F),
                fontSize: (total ? 18 : 16) * responsive.scale,
                fontWeight: total ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: total ? AppTheme.accentDark : AppTheme.ink,
              fontSize: (total ? 20 : 16) * responsive.scale,
              fontWeight: FontWeight.w900,
              letterSpacing: total ? 1 : 0,
            ),
          ),
        ],
      ),
    );
  }
}
