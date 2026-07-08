import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.profile),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            18 * responsive.scale,
            responsive.horizontalPadding,
            24 * responsive.scale,
          ),
          children: [
            const StayZLogoRow(),
            SizedBox(height: 22 * responsive.scale),
            _ProfileHero(responsive: responsive),
            SizedBox(height: 18 * responsive.scale),
            Row(
              children: const [
                Expanded(child: _Stat(value: '5', label: 'Chuyến đi')),
                SizedBox(width: 10),
                Expanded(child: _Stat(value: '12', label: 'Đã lưu')),
                SizedBox(width: 10),
                Expanded(child: _Stat(value: '4.9', label: 'Đánh giá')),
              ],
            ),
            SizedBox(height: 26 * responsive.scale),
            const ProfileSectionLabel(label: 'Tài khoản'),
            SizedBox(height: 12 * responsive.scale),
            ProfileMenuCard(
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Thông tin cá nhân',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.profileForm),
                ),
                const Divider(height: 1, indent: 72, endIndent: 20),
                const ProfileMenuTile(icon: Icons.lock_outline_rounded, label: 'Đổi mật khẩu'),
                const Divider(height: 1, indent: 72, endIndent: 20),
                ProfileMenuTile(
                  icon: Icons.credit_card_rounded,
                  label: 'Phương thức thanh toán',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.paymentMethods),
                ),
              ],
            ),
            SizedBox(height: 24 * responsive.scale),
            const ProfileSectionLabel(label: 'Ứng dụng'),
            SizedBox(height: 12 * responsive.scale),
            ProfileMenuCard(
              children: [
                ProfileMenuTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Thông báo',
                  trailing: Switch(value: true, onChanged: (_) {}, activeColor: Colors.white, activeTrackColor: AppTheme.primary),
                ),
                const Divider(height: 1, indent: 72, endIndent: 20),
                const ProfileMenuTile(icon: Icons.language_rounded, label: 'Ngôn ngữ', trailing: Text('Tiếng Việt')),
                const Divider(height: 1, indent: 72, endIndent: 20),
                const ProfileMenuTile(icon: Icons.help_outline_rounded, label: 'Trung tâm hỗ trợ'),
              ],
            ),
            SizedBox(height: 18 * responsive.scale),
            const ProfileMenuCard(
              children: [
                ProfileMenuTile(icon: Icons.logout_rounded, label: 'Đăng xuất', danger: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.responsive});

  final HomeResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 38 * responsive.scale,
                backgroundColor: AppTheme.primary,
                child: Text('NH', style: TextStyle(color: Colors.white, fontSize: 22 * responsive.scale, fontWeight: FontWeight.w900)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 13 * responsive.scale,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.edit_rounded, color: AppTheme.primary, size: 15 * responsive.scale),
                ),
              ),
            ],
          ),
          SizedBox(width: 16 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nguyen Huy', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 21 * responsive.scale, fontWeight: FontWeight.w900)),
                SizedBox(height: 5 * responsive.scale),
                Text('huy@email.com', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 13 * responsive.scale, fontWeight: FontWeight.w600)),
                SizedBox(height: 12 * responsive.scale),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Chỉnh hồ sơ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
                    minimumSize: Size(0, 42 * responsive.scale),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: AppTheme.ink, fontSize: 20 * responsive.scale, fontWeight: FontWeight.w900)),
          SizedBox(height: 5 * responsive.scale),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppTheme.muted, fontSize: 12 * responsive.scale, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
