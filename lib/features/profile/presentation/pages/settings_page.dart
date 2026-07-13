import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _profileRevision = 0;
  late final Future<bool> _isAdminFuture = AuthService.instance
      .userRole()
      .then((role) => role == 'admin')
      .catchError((_) => false);

  Future<void> _pickLanguage(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      tr('Chọn ngôn ngữ', 'Choose language'),
                      style: const TextStyle(color: AppTheme.ink, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              _LanguageOption(
                flag: AppLocale.flagFor(AppLanguage.vi),
                label: 'Tiếng Việt',
                selected: AppLocale.instance.language == AppLanguage.vi,
                onTap: () async {
                  await AppLocale.instance.setLanguage(AppLanguage.vi);
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                },
              ),
              _LanguageOption(
                flag: AppLocale.flagFor(AppLanguage.en),
                label: 'English',
                selected: AppLocale.instance.language == AppLanguage.en,
                onTap: () async {
                  await AppLocale.instance.setLanguage(AppLanguage.en);
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

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
            _ProfileHeroReal(
              key: ValueKey(_profileRevision),
              responsive: responsive,
            ),
            SizedBox(height: 18 * responsive.scale),
            const _ProfileStats(),
            SizedBox(height: 26 * responsive.scale),
            ProfileSectionLabel(label: tr('Tài khoản', 'Account')),
            SizedBox(height: 12 * responsive.scale),
            ProfileMenuCard(
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  label: tr('Thông tin cá nhân', 'Personal information'),
                  onTap: () async {
                    await Navigator.of(context).pushNamed(AppRoutes.profileForm);
                    if (mounted) setState(() => _profileRevision++);
                  },
                ),
                const Divider(height: 1, indent: 72, endIndent: 20),
                ProfileMenuTile(
                  icon: Icons.lock_outline_rounded,
                  label: tr('Đổi mật khẩu', 'Change password'),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                ),
                const Divider(height: 1, indent: 72, endIndent: 20),
                ProfileMenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: tr('Phương thức thanh toán', 'Payment methods'),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.paymentMethods),
                ),
              ],
            ),
            FutureBuilder<bool>(
              future: _isAdminFuture,
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24 * responsive.scale),
                    ProfileSectionLabel(
                      label: tr('Quản trị', 'Administration'),
                    ),
                    SizedBox(height: 12 * responsive.scale),
                    ProfileMenuCard(
                      children: [
                        ProfileMenuTile(
                          icon: Icons.admin_panel_settings_outlined,
                          label: tr('Trung tâm quản trị', 'Admin center'),
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.admin,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 24 * responsive.scale),
            ProfileSectionLabel(label: tr('Ứng dụng', 'App')),
            SizedBox(height: 12 * responsive.scale),
            ProfileMenuCard(
              children: [
                ProfileMenuTile(
                  icon: Icons.language_rounded,
                  label: tr('Ngôn ngữ', 'Language'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${AppLocale.instance.flag} ${AppLocale.instance.label}',
                        style: const TextStyle(color: AppTheme.muted, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
                    ],
                  ),
                  onTap: () => _pickLanguage(context),
                ),
                const Divider(height: 1, indent: 72, endIndent: 20),
                ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  label: tr('Trung tâm hỗ trợ', 'Help center'),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpCenter),
                ),
              ],
            ),
            SizedBox(height: 18 * responsive.scale),
            ProfileMenuCard(
              children: [
                ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  label: tr('Đăng xuất', 'Log out'),
                  danger: true,
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    await AuthService.instance.logout();
                    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.flag, required this.label, required this.selected, required this.onTap});

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Semantics(
        label: tr('Cờ của ngôn ngữ $label', '$label language flag'),
        child: ExcludeSemantics(child: Text(flag, style: const TextStyle(fontSize: 24))),
      ),
      title: Text(label, style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w700)),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary) : null,
      onTap: onTap,
    );
  }
}

/// So chuyen di va so khach san da luu la SO THAT tu API.
/// Truoc day day la 3 hang so gia: "5 / 12 / 4.9".
class _ProfileStats extends StatefulWidget {
  const _ProfileStats();

  @override
  State<_ProfileStats> createState() => _ProfileStatsState();
}

class _ProfileStatsState extends State<_ProfileStats> {
  late Future<List<int>> _future = _load();

  Future<List<int>> _load() async {
    final values = await Future.wait<int>([
      ApiStayzRepository.instance
          .getBookingSummaries()
          .then((items) => items.length),
      ApiStayzRepository.instance
          .getFavoriteHotelIds()
          .then((items) => items.length),
    ]);
    return values;
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 150,
            child: StayzErrorView(
              error: snapshot.error,
              onRetry: _retry,
              compact: true,
            ),
          );
        }
        final trips = snapshot.data?[0];
        final saved = snapshot.data?[1];
        return Row(
          children: [
            Expanded(child: _Stat(value: trips?.toString() ?? '–', label: tr('Chuyến đi', 'Trips'))),
            const SizedBox(width: 10),
            Expanded(child: _Stat(value: saved?.toString() ?? '–', label: tr('Đã lưu', 'Saved'))),
          ],
        );
      },
    );
  }
}

class _ProfileHeroReal extends StatefulWidget {
  const _ProfileHeroReal({required this.responsive, super.key});

  final HomeResponsive responsive;

  @override
  State<_ProfileHeroReal> createState() => _ProfileHeroRealState();
}

class _ProfileHeroRealState extends State<_ProfileHeroReal> {
  late Future<StayzUser?> _future = ApiStayzRepository.instance.getProfile();

  void _retry() {
    setState(() => _future = ApiStayzRepository.instance.getProfile());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StayzUser?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 190,
            child: StayzErrorView(
              error: snapshot.error,
              onRetry: _retry,
              compact: true,
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 160,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return SizedBox(
            height: 190,
            child: StayzErrorView(
              error: StateError('Profile data is unavailable.'),
              onRetry: _retry,
              compact: true,
            ),
          );
        }
        final displayName = user.fullName;
        final email = user.email;
        final initials = _initials(displayName);

        return Container(
          padding: EdgeInsets.all(18 * widget.responsive.scale),
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 38 * widget.responsive.scale,
                    backgroundColor: AppTheme.primary,
                    child: Text(initials, style: TextStyle(color: Colors.white, fontSize: 22 * widget.responsive.scale, fontWeight: FontWeight.w900)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 13 * widget.responsive.scale,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit_rounded, color: AppTheme.primary, size: 15 * widget.responsive.scale),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16 * widget.responsive.widthScale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 21 * widget.responsive.scale, fontWeight: FontWeight.w900)),
                    SizedBox(height: 5 * widget.responsive.scale),
                    Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 13 * widget.responsive.scale, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12 * widget.responsive.scale),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(AppRoutes.editProfile);
                        if (mounted) _retry();
                      },
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text(tr('Chỉnh hồ sơ', 'Edit profile')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
                        minimumSize: Size(0, 48 * widget.responsive.scale),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'SZ';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts.last[0] : '';
    return (first + second).toUpperCase();
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
