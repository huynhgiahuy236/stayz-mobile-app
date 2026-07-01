import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      body: SafeArea(
        child: Column(
          children: [
            const ProfileHeader(title: 'Thong tin ca nhan'),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsive.horizontalPadding),
                children: [
                  SizedBox(height: 28 * responsive.scale),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(radius: 60 * responsive.scale, backgroundColor: const Color(0xFFD8CCDF)),
                            Positioned(
                              right: 0,
                              bottom: 6 * responsive.scale,
                              child: CircleAvatar(
                                radius: 21 * responsive.scale,
                                backgroundColor: AppTheme.accentDark,
                                child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20 * responsive.scale),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 22 * responsive.scale),
                        const ProfileSectionLabel(label: 'Anh dai dien'),
                      ],
                    ),
                  ),
                  SizedBox(height: 54 * responsive.scale),
                  const ProfileInputField(label: 'Ho va ten', value: 'Nguyen Minh Anh'),
                  SizedBox(height: 30 * responsive.scale),
                  const ProfileInputField(
                    label: 'Email',
                    value: 'minhanh.nguyen@example',
                    error: 'Dia chi email khong hop le. Vui long kiem tra lai.',
                  ),
                  SizedBox(height: 30 * responsive.scale),
                  const ProfileInputField(label: 'So dien thoai', value: '090 123 4567'),
                  SizedBox(height: 30 * responsive.scale),
                  ProfileInputField(
                    label: 'Ngay sinh',
                    value: '05/15/1995',
                    trailing: Icon(Icons.calendar_today_outlined, color: const Color(0xFF5A3F3F), size: 22 * responsive.scale),
                  ),
                  SizedBox(height: 30 * responsive.scale),
                  const ProfileSectionLabel(label: 'Gioi tinh'),
                  SizedBox(height: 12 * responsive.scale),
                  Container(
                    height: 54 * responsive.scale,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E7E3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.neutral200),
                    ),
                    child: Row(
                      children: const [
                        _GenderSegment(label: 'Nam', active: true),
                        _GenderSegment(label: 'Nu'),
                        _GenderSegment(label: 'Khac'),
                      ],
                    ),
                  ),
                  SizedBox(height: 40 * responsive.scale),
                  const ProfileInputField(
                    label: 'Dia chi thuong tru',
                    value: '123 Duong Le Loi, Quan 1, TP. Ho Chi Minh',
                    large: true,
                  ),
                  SizedBox(height: 70 * responsive.scale),
                  const ProfilePrimaryButton(label: 'Luu thay doi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderSegment extends StatelessWidget {
  const _GenderSegment({
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accentDark : const Color(0xFF5A3F3F),
            fontSize: 16 * responsive.scale,
          ),
        ),
      ),
    );
  }
}
