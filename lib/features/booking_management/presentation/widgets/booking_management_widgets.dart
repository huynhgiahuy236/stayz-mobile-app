import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

enum BookingManageTab { upcoming, completed, cancelled }

/// Anh dai dien khach san cho cac the booking. Hien anh that neu co,
/// khong thi ve gradient + icon.
class BookingThumb extends StatelessWidget {
  const BookingThumb({
    required this.imageUrl,
    required this.colors,
    required this.size,
    this.radius = 16,
    super.key,
  });

  final String? imageUrl;
  final List<Color> colors;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? StayZNetworkImage(imageUrl: imageUrl!, width: size, height: size)
            : DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
                child: const Center(child: Icon(Icons.hotel_rounded, color: Colors.white)),
              ),
      ),
    );
  }
}

/// Header dung chung cho ca ba tab: Sap toi, Hoan tat, Da huy.
///
/// Truoc day moi man tu dat header rieng - "Chuyến đi của tôi", "Đặt phòng của
/// tôi" va "StayZ" - nen chuyen tab la tieu de nhay lung tung.
class BookingsScreenHeader extends StatelessWidget {
  const BookingsScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return StayZScreenHeader(
      title: tr('Chuyến đi của tôi', 'My trips'),
      subtitle: tr('Lịch đặt', 'Bookings'),
      trailing: IconButton.filledTonal(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
        icon: const Icon(Icons.add_rounded),
        tooltip: tr('Tìm phòng mới', 'Find a stay'),
        style: IconButton.styleFrom(
          backgroundColor: AppTheme.primarySoft,
          foregroundColor: AppTheme.primary,
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }
}

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
                    fontSize: 24 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          SizedBox(
            width: 72 * responsive.widthScale,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: Container(
        padding: EdgeInsets.all(4 * responsive.scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.line),
        ),
        child: Row(
          children: [
            _BookingTab(
            label: tr('Sắp tới', 'Upcoming'),
            active: activeTab == BookingManageTab.upcoming,
            routeName: upcomingRoute,
          ),
          _BookingTab(
            label: tr('Hoàn tất', 'Completed'),
            active: activeTab == BookingManageTab.completed,
            routeName: completedRoute,
          ),
          _BookingTab(
            label: tr('Đã hủy', 'Cancelled'),
            active: activeTab == BookingManageTab.cancelled,
            routeName: cancelledRoute,
          ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44 * responsive.scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppTheme.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? Colors.white : AppTheme.muted,
              fontSize: 13 * responsive.scale,
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
    this.onPay,
    this.pendingPayment = false,
    this.paymentExpired = false,
    this.paymentBusy = false,
    this.imageUrl,
    this.statusLabel,
    this.statusColor,
    this.statusTextColor,
    this.detailLabel,
    this.secondaryLabel,
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
  final VoidCallback? onPay;
  final bool pendingPayment;
  final bool paymentExpired;
  final bool paymentBusy;
  final String? imageUrl;
  final String? statusLabel;
  final Color? statusColor;
  final Color? statusTextColor;
  final String? detailLabel;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Anh full-width, ten khach san nam DUOI anh (giong the ngoai home),
          // pill trang thai noi goc phai tren anh (giong the cancelled).
          SizedBox(
            height: 160 * responsive.scale,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) => (imageUrl == null || imageUrl!.isEmpty)
                        ? CustomPaint(painter: LuxuryArchitecturalPainter(colors: colors))
                        : StayZNetworkImage(imageUrl: imageUrl!, width: constraints.maxWidth, height: 160 * responsive.scale),
                  ),
                ),
                Positioned(
                  top: 12 * responsive.scale,
                  right: 12 * responsive.widthScale,
                  child: BookingStatusPill(
                    label: statusLabel ?? (paymentExpired
                        ? tr('Đã hết hạn', 'Payment expired')
                        : pendingPayment
                        ? tr('Chờ thanh toán', 'Pending payment')
                        : tr('Sắp tới', 'Upcoming')),
                    color: statusColor ?? (paymentExpired
                        ? AppTheme.danger.withValues(alpha: 0.14)
                        : pendingPayment
                        ? const Color(0xFFFFE8B0)
                        : AppTheme.primarySoft),
                    textColor: statusTextColor ?? (paymentExpired ? AppTheme.danger : null),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16 * responsive.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.ink, fontSize: 19 * responsive.scale, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6 * responsive.scale),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppTheme.muted, size: 16 * responsive.scale),
                    SizedBox(width: 5 * responsive.widthScale),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.muted, fontSize: 13.5 * responsive.scale),
                      ),
                    ),
                  ],
                ),
                Divider(height: 26 * responsive.scale, color: AppTheme.line),
                Row(
                  children: [
                    Expanded(child: _MetaBlock(label: tr('Nhận phòng', 'Check-in'), value: checkIn)),
                    Expanded(child: _MetaBlock(label: tr('Trả phòng', 'Check-out'), value: checkOut)),
                    Expanded(child: _MetaBlock(label: tr('Mã đặt phòng', 'Code'), value: code)),
                  ],
                ),
                SizedBox(height: 18 * responsive.scale),
                Row(
                  children: [
                    Expanded(child: BookingSoftButton(label: detailLabel ?? tr('Chi tiết', 'Details'), onTap: onDetail)),
                    SizedBox(width: 10 * responsive.widthScale),
                    Expanded(
                      child: pendingPayment && onPay != null
                          ? BookingSoftButton(
                              label: paymentBusy
                                  ? tr('Đang tạo mã...', 'Creating...')
                                  : paymentExpired
                                  ? tr('Tạo mã mới', 'New payment code')
                                  : tr('Thanh toán', 'Pay now'),
                              onTap: paymentBusy ? null : onPay!,
                            )
                          : BookingOutlineButton(label: secondaryLabel ?? tr('Hủy lịch', 'Cancel'), onTap: onCancel),
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

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: 10.5 * responsive.scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 6 * responsive.scale),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 14 * responsive.scale,
            fontWeight: FontWeight.w900,
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
        // Khong co handler thi disable han, thay vi bam roi khong co gi xay ra.
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primarySoft,
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
        // Khong co handler thi disable han, thay vi bam roi khong co gi xay ra.
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.danger),
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
    this.onSecondary,
    this.imageUrl,
    this.primaryLabel,
    this.secondaryLabel,
    super.key,
  });

  final String name;
  final String date;
  final String price;
  final List<Color> colors;
  final String? imageUrl;
  final VoidCallback onPrimary;

  /// Thieu callback thi nut phu se bi vo hieu hoa.
  final VoidCallback? onSecondary;
  final String? primaryLabel;
  final String? secondaryLabel;

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
                BookingThumb(imageUrl: imageUrl, colors: colors, size: 112 * responsive.scale, radius: 12),
                SizedBox(width: 18 * responsive.widthScale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingStatusPill(
                        label: tr('Đã hoàn thành', 'Completed'),
                        color: const Color(0xFFBDF4D4),
                        textColor: const Color(0xFF096A43),
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
                Expanded(child: _FilledAction(label: primaryLabel ?? tr('Đánh giá ngay', 'Review now'), onTap: onPrimary)),
                SizedBox(width: 14 * responsive.widthScale),
                Expanded(child: BookingOutlineButton(label: secondaryLabel ?? tr('Đặt lại', 'Rebook'), onTap: onSecondary)),
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
