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
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.profile),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ProfileHeader(
              title: 'StayZ',
              brand: true,
              trailing: Icon(Icons.account_circle_outlined, color: AppTheme.accentDark),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  SizedBox(height: 44 * responsive.scale),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 58 * responsive.scale,
                          backgroundColor: AppTheme.ink,
                          child: Text(
                            'NH',
                            style: TextStyle(color: Colors.white, fontSize: 28 * responsive.scale),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 8 * responsive.scale,
                          child: CircleAvatar(
                            radius: 17 * responsive.scale,
                            backgroundColor: AppTheme.accent,
                            child: Icon(Icons.edit, color: Colors.white, size: 18 * responsive.scale),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 26 * responsive.scale),
                  Text('Nguyen Huy', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.ink, fontSize: 28 * responsive.scale)),
                  SizedBox(height: 6 * responsive.scale),
                  Text('huy@email.com', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.neutral500, fontSize: 17 * responsive.scale)),
                  SizedBox(height: 48 * responsive.scale),
                  Row(
                    children: const [
                      Expanded(child: _Stat(value: '5', label: 'CHUYEN DI')),
                      Expanded(child: _Stat(value: '12', label: 'DA LUU')),
                      Expanded(child: _Stat(value: '4.9 ★', label: 'DANH GIA')),
                    ],
                  ),
                  SizedBox(height: 62 * responsive.scale),
                  const ProfileSectionLabel(label: 'Tai khoan'),
                  SizedBox(height: 20 * responsive.scale),
                  ProfileMenuCard(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.person_outline,
                        label: 'Thong tin ca nhan',
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.profileForm),
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 24),
                      const ProfileMenuTile(icon: Icons.lock_outline, label: 'Doi mat khau'),
                      const Divider(height: 1, indent: 72, endIndent: 24),
                      ProfileMenuTile(
                        icon: Icons.credit_card,
                        label: 'Phuong thuc thanh toan',
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.paymentMethods),
                      ),
                    ],
                  ),
                  SizedBox(height: 44 * responsive.scale),
                  const ProfileSectionLabel(label: 'Cai dat'),
                  SizedBox(height: 20 * responsive.scale),
                  ProfileMenuCard(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.notifications_none_outlined,
                        label: 'Thong bao',
                        trailing: Switch(value: true, onChanged: (_) {}, activeColor: Colors.white, activeTrackColor: AppTheme.accent),
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 24),
                      const ProfileMenuTile(icon: Icons.language, label: 'Ngon ngu', trailing: Text('Tieng Viet')),
                    ],
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  const ProfileMenuCard(
                    children: [
                      ProfileMenuTile(icon: Icons.help_outline, label: 'Trung tam ho tro'),
                    ],
                  ),
                  SizedBox(height: 22 * responsive.scale),
                  const ProfileMenuCard(
                    children: [
                      ProfileMenuTile(icon: Icons.logout, label: 'Dang xuat', danger: true),
                    ],
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

    return Column(
      children: [
        Text(value, style: TextStyle(color: AppTheme.ink, fontSize: 24 * responsive.scale, fontWeight: FontWeight.w800)),
        SizedBox(height: 8 * responsive.scale),
        Text(label, style: TextStyle(color: AppTheme.neutral500, fontSize: 13 * responsive.scale, letterSpacing: 1.4)),
      ],
    );
  }
}
