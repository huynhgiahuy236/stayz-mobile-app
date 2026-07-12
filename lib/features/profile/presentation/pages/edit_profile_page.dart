import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  late Future<StayzUser?> _profile;
  String _gender = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _profile = _load();
  }

  Future<StayzUser?> _load() async {
    final user = await ApiStayzRepository.instance.getProfile();
    if (user != null) {
      _name.text = user.fullName;
      _phone.text = user.phone;
      _address.text = user.homeAddress;
      _gender = user.gender;
    }
    return user;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await ApiStayzRepository.instance.updateProfile(
        fullName: _name.text,
        phone: _phone.text,
        gender: _gender,
        homeAddress: _address.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Đã cập nhật hồ sơ.', 'Profile updated.'))),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(title: tr('Chỉnh sửa hồ sơ', 'Edit profile')),
            Expanded(
              child: FutureBuilder<StayzUser?>(
                future: _profile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return StayzErrorView(
                      error: snapshot.error,
                      onRetry: () => setState(() {
                        _profile = _load();
                      }),
                    );
                  }
                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: tr('Họ và tên', 'Full name'),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? tr(
                                  'Vui lòng nhập họ tên.',
                                  'Full name is required.',
                                )
                              : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: tr('Số điện thoại', 'Phone number'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _gender.isEmpty ? null : _gender,
                          decoration: InputDecoration(
                            labelText: tr('Giới tính', 'Gender'),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text(tr('Nam', 'Male')),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text(tr('Nữ', 'Female')),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text(tr('Khác', 'Other')),
                            ),
                          ],
                          onChanged: (value) => _gender = value ?? '',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _address,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: tr('Địa chỉ', 'Address'),
                          ),
                        ),
                        const SizedBox(height: 36),
                        ProfilePrimaryButton(
                          label: _saving
                              ? tr('Đang lưu...', 'Saving...')
                              : tr('Lưu thay đổi', 'Save changes'),
                          onTap: _saving ? null : _save,
                        ),
                      ],
                    ),
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
