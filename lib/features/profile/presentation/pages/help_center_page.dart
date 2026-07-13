import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(tr('Trung tâm hỗ trợ', 'Help center'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Semantics(
              header: true,
              child: Text(
                tr('Bạn cần hỗ trợ gì?', 'How can we help?'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'Chọn đúng khu vực để xem hoặc xử lý thông tin trong StayZ.',
                'Choose an area to review or manage it in StayZ.',
              ),
              style: const TextStyle(color: AppTheme.muted, height: 1.5),
            ),
            const SizedBox(height: 24),
            ProfileMenuCard(
              children: [
                ProfileMenuTile(
                  icon: Icons.calendar_month_outlined,
                  label: tr('Quản lý đặt phòng', 'Manage bookings'),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.myBookings),
                ),
                const Divider(height: 1, indent: 72),
                ProfileMenuTile(
                  icon: Icons.payments_outlined,
                  label: tr('Thanh toán và VietQR', 'Payment and VietQR'),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.paymentMethods),
                ),
                const Divider(height: 1, indent: 72),
                ProfileMenuTile(
                  icon: Icons.lock_reset_rounded,
                  label: tr('Khôi phục mật khẩu', 'Recover password'),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _HelpNote(
              icon: Icons.schedule_rounded,
              title: tr('VietQR có thời hạn', 'VietQR expires'),
              body: tr(
                'Mã thanh toán có hiệu lực 15 phút. Booking vẫn nằm trong mục Chuyến đi khi đang chờ thanh toán.',
                'The payment code is valid for 15 minutes. Pending bookings remain available in Trips.',
              ),
            ),
            const SizedBox(height: 12),
            _HelpNote(
              icon: Icons.cancel_outlined,
              title: tr('Hủy đặt phòng', 'Cancel a booking'),
              body: tr(
                'Mức hoàn tiền được hiển thị trước khi bạn xác nhận hủy.',
                'The estimated refund is shown before you confirm cancellation.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpNote extends StatelessWidget {
  const _HelpNote({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primary, semanticLabel: title),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(body, style: const TextStyle(color: AppTheme.muted, height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
