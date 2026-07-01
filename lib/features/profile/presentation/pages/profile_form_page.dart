import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';

class ProfileFormPage extends StatelessWidget {
  const ProfileFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          18 * responsive.scale,
          responsive.horizontalPadding,
          24 * responsive.scale,
        ),
        child: SafeArea(top: false, child: const ProfilePrimaryButton(label: 'Luu thay doi')),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ProfileHeader(title: 'Thong tin ca nhan'),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  SizedBox(height: 32 * responsive.scale),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 82 * responsive.scale,
                          backgroundColor: AppTheme.neutral200,
                          child: Icon(Icons.person, color: AppTheme.accentDark, size: 76 * responsive.scale),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 10 * responsive.scale,
                          child: CircleAvatar(
                            radius: 28 * responsive.scale,
                            backgroundColor: AppTheme.accentDark,
                            child: Icon(Icons.edit, color: Colors.white, size: 25 * responsive.scale),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 58 * responsive.scale),
                  const ProfileInputField(label: 'Ho va ten', value: 'Nguyen Huy'),
                  SizedBox(height: 34 * responsive.scale),
                  const ProfileInputField(label: 'Email', value: 'huy@email.com'),
                  SizedBox(height: 34 * responsive.scale),
                  const ProfileInputField(label: 'So dien thoai', value: '+84 901 234 567'),
                  SizedBox(height: 34 * responsive.scale),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileInputField(
                          label: 'Ngay sinh',
                          value: 'DD/MM/YYYY',
                          trailing: Icon(Icons.calendar_today_outlined, color: const Color(0xFF5A3F3F), size: 22 * responsive.scale),
                        ),
                      ),
                      SizedBox(width: 18 * responsive.widthScale),
                      Expanded(
                        child: ProfileInputField(
                          label: 'Gioi tinh',
                          value: 'Nam',
                          trailing: Icon(Icons.keyboard_arrow_down, color: AppTheme.neutral500, size: 24 * responsive.scale),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 66 * responsive.scale),
                  Divider(color: AppTheme.neutral200),
                  SizedBox(height: 62 * responsive.scale),
                  const ProfileMenuCard(
                    children: [
                      ProfileMenuTile(icon: Icons.shield_outlined, label: 'Mat khau & Bao mat'),
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
