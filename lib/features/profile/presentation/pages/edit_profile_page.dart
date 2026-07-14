import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
  final _dateOfBirth = TextEditingController();
  late Future<StayzUser?> _profile;
  String _gender = '';
  bool _saving = false;
  bool _uploadingAvatar = false;
  String _avatarUrl = '';

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
      _dateOfBirth.text = user.dateOfBirth.split('T').first;
      _avatarUrl = user.avatarUrl;
    }
    return user;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _dateOfBirth.dispose();
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
        dateOfBirth: _dateOfBirth.text,
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

  Future<void> _pickAvatar() async {
    if (_uploadingAvatar) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = result?.files.singleOrNull;
    if (file == null || file.bytes == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final url = await ApiStayzRepository.instance.uploadProfileAvatar(
        bytes: file.bytes!,
        filename: file.name,
      );
      if (!mounted) return;
      setState(() => _avatarUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Đã cập nhật ảnh đại diện.', 'Avatar updated.'))),
      );
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _pickDateOfBirth() async {
    final initial = DateTime.tryParse(_dateOfBirth.text) ?? DateTime(2000);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      _dateOfBirth.text = selected.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
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
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 58,
                                backgroundColor: AppTheme.neutral200,
                                backgroundImage: _avatarUrl.isEmpty ? null : NetworkImage(_avatarUrl),
                                child: _avatarUrl.isEmpty ? const Icon(Icons.person, size: 58, color: AppTheme.accentDark) : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: IconButton.filled(
                                  onPressed: _uploadingAvatar ? null : _pickAvatar,
                                  tooltip: tr('Tải ảnh đại diện', 'Upload avatar'),
                                  icon: _uploadingAvatar
                                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Icon(Icons.photo_camera_outlined),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
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
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _dateOfBirth,
                          readOnly: true,
                          onTap: _pickDateOfBirth,
                          decoration: InputDecoration(
                            labelText: tr('Ngày sinh', 'Date of birth'),
                            suffixIcon: const Icon(Icons.calendar_month_outlined),
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
