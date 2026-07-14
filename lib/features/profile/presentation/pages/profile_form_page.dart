import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  late Future<StayzUser?> _profile = ApiStayzRepository.instance.getProfile();

  void _reload() =>
      setState(() => _profile = ApiStayzRepository.instance.getProfile());

  Future<void> _openEdit() async {
    await Navigator.of(context).pushNamed(AppRoutes.editProfile);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(
              title: tr('Thông tin cá nhân', 'Personal information'),
            ),
            Expanded(
              child: FutureBuilder<StayzUser?>(
                future: _profile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  if (snapshot.hasError)
                    return StayzErrorView(
                      error: snapshot.error,
                      onRetry: _reload,
                    );
                  final user = snapshot.data;
                  if (user == null) {
                    return StayzEmptyView(
                      icon: Icons.person_off_outlined,
                      title: tr('Không tìm thấy hồ sơ', 'Profile not found'),
                      message: tr(
                        'Vui lòng đăng nhập lại.',
                        'Please sign in again.',
                      ),
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.all(responsive.horizontalPadding),
                    children: [
                      SizedBox(height: 28 * responsive.scale),
                      CircleAvatar(
                        radius: 58 * responsive.scale,
                        backgroundColor: AppTheme.neutral200,
                        backgroundImage: user.avatarUrl.isNotEmpty
                            ? NetworkImage(user.avatarUrl)
                            : null,
                        child: user.avatarUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 58 * responsive.scale,
                                color: AppTheme.accentDark,
                              )
                            : null,
                      ),
                      SizedBox(height: 34 * responsive.scale),
                      ProfileInputField(
                        label: tr('Họ và tên', 'Full name'),
                        value: user.fullName,
                      ),
                      SizedBox(height: 24 * responsive.scale),
                      ProfileInputField(label: 'Email', value: user.email),
                      SizedBox(height: 24 * responsive.scale),
                      ProfileInputField(
                        label: tr('Số điện thoại', 'Phone number'),
                        value: user.phone.isEmpty
                            ? tr('Chưa cập nhật', 'Not provided')
                            : user.phone,
                      ),
                      SizedBox(height: 24 * responsive.scale),
                      ProfileInputField(
                        label: tr('Giới tính', 'Gender'),
                        value: _genderLabel(user.gender),
                      ),
                      SizedBox(height: 24 * responsive.scale),
                      ProfileInputField(
                        label: tr('Địa chỉ', 'Address'),
                        value: user.homeAddress.isEmpty
                            ? tr('Chưa cập nhật', 'Not provided')
                            : user.homeAddress,
                        large: true,
                      ),
                      SizedBox(height: 24 * responsive.scale),
                      ProfileInputField(
                        label: tr('Ngày sinh', 'Date of birth'),
                        value: user.dateOfBirth.isEmpty
                            ? tr('Chưa cập nhật', 'Not provided')
                            : user.dateOfBirth.split('T').first,
                      ),
                      SizedBox(height: 36 * responsive.scale),
                      ProfilePrimaryButton(
                        label: tr('Chỉnh sửa hồ sơ', 'Edit profile'),
                        onTap: _openEdit,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _genderLabel(String value) => switch (value) {
    'male' => tr('Nam', 'Male'),
    'female' => tr('Nữ', 'Female'),
    'other' => tr('Khác', 'Other'),
    _ => tr('Chưa cập nhật', 'Not provided'),
  };
}
