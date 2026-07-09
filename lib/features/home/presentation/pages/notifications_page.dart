import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.profile),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                18 * responsive.scale,
                responsive.horizontalPadding,
                22 * responsive.scale,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42 * responsive.scale,
                    height: 42 * responsive.scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.neutral200.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.accentDark,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * responsive.widthScale),
                  Expanded(
                    child: Text(
                      'Thông báo',
                      style: textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Noto Serif JP',
                        color: AppTheme.accentDark,
                        fontSize: 30 * responsive.scale,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã đánh dấu tất cả thông báo là đã đọc.')),
                    ),
                    icon: Icon(
                      Icons.done_all_rounded,
                      color: AppTheme.accentDark,
                      size: 22 * responsive.scale,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8 * responsive.scale),
                      side: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.neutral200.withValues(alpha: 0.7), height: 1),
            SizedBox(height: 34 * responsive.scale),
            SizedBox(
              height: 42 * responsive.scale,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                children: const [
                  FilterPill(label: 'Tất cả', active: true),
                  SizedBox(width: 14),
                  FilterPill(label: 'Ưu đãi'),
                  SizedBox(width: 14),
                  FilterPill(label: 'Chuyến đi'),
                  SizedBox(width: 14),
                  FilterPill(label: 'Cập nhật'),
                ],
              ),
            ),
            SizedBox(height: 34 * responsive.scale),
            Expanded(
              child: FutureBuilder<List<StayzNotification>>(
                future: ApiStayzRepository.instance.getNotifications(),
                builder: (context, snapshot) {
                  final notifications = snapshot.data ?? const <StayzNotification>[];

                  if (notifications.isEmpty && snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      responsive.horizontalPadding,
                      0,
                      responsive.horizontalPadding,
                      24 * responsive.scale,
                    ),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 18 * responsive.scale),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final iconData = _notificationIcon(notification.type);

                      return NotificationCard(
                        icon: iconData.$1,
                        iconColor: iconData.$2,
                        title: notification.title,
                        body: notification.message,
                        time: _notificationTime(notification.createdAt),
                        unread: notification.status == 'unread',
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

(IconData, Color) _notificationIcon(String type) {
  return switch (type) {
    'bookingConfirmed' => (Icons.event_available_outlined, AppTheme.accent),
    'paymentPending' => (Icons.payments_outlined, const Color(0xFFC08A18)),
    'refundCompleted' => (Icons.payments_outlined, const Color(0xFF3B9F6B)),
    'reviewReminder' => (Icons.rate_review_outlined, const Color(0xFF8B7A73)),
    _ => (Icons.notifications_none_outlined, AppTheme.neutral500),
  };
}

String _notificationTime(DateTime createdAt) {
  final age = DateTime.now().difference(createdAt);
  if (age.inDays > 0) return '${age.inDays} ngày trước';
  if (age.inHours > 0) return '${age.inHours} giờ trước';
  return 'Vừa xong';
}
