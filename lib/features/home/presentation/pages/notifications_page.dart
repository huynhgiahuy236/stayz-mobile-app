import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF1EE),
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
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppTheme.accentDark,
                  ),
                  SizedBox(width: 8 * responsive.widthScale),
                  Expanded(
                    child: Text(
                      'Thông báo',
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 33 * responsive.scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.done_all,
                    color: AppTheme.accentDark,
                    size: 27 * responsive.scale,
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  0,
                  responsive.horizontalPadding,
                  24 * responsive.scale,
                ),
                children: [
                  const NotificationCard(
                    icon: Icons.event_available_outlined,
                    iconColor: AppTheme.accent,
                    title: 'Đặt phòng thành công',
                    body:
                        'Yêu cầu đặt phòng tại Silk Path Grand Sapa của bạn đã được xác nhận. Chúc bạn một chuyến đi vui vẻ!',
                    time: '2 giờ trước',
                    unread: true,
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  const NotificationCard(
                    icon: Icons.local_offer_outlined,
                    iconColor: Color(0xFFC08A18),
                    title: 'Ưu đãi độc quyền cho bạn',
                    body:
                        'Giảm ngay 20% cho các kỳ nghỉ dưỡng tại Hội An trong tháng tới. Khám phá ngay!',
                    time: '5 giờ trước',
                    unread: true,
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  const NotificationCard(
                    icon: Icons.payments_outlined,
                    iconColor: Color(0xFF3B9F6B),
                    title: 'Thanh toán hoàn tất',
                    body:
                        'Giao dịch #STZ-2024 của bạn đã được xử lý thành công. Cảm ơn bạn đã tin dùng StayZ.',
                    time: 'Hôm qua',
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  const NotificationCard(
                    icon: Icons.rate_review_outlined,
                    iconColor: Color(0xFF8B7A73),
                    title: 'Chia sẻ cảm nhận của bạn',
                    body:
                        'Bạn thấy kỳ nghỉ tại Maison Vy như thế nào? Hãy dành 1 phút để đánh giá nhé.',
                    time: '2 ngày trước',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
