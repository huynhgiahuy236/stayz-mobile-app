import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class AdminAccessGate extends StatefulWidget {
  const AdminAccessGate({required this.builder, super.key});

  final WidgetBuilder builder;

  @override
  State<AdminAccessGate> createState() => _AdminAccessGateState();
}

class _AdminAccessGateState extends State<AdminAccessGate> {
  late final Future<bool> _access = AuthService.instance.hasCurrentAdminAccess();

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _access,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(
          backgroundColor: AppTheme.surface,
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.data == true) return widget.builder(context);
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(title: Text(tr('Không có quyền', 'Access denied'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_outlined, size: 56),
                const SizedBox(height: 16),
                Text(
                  tr(
                    'Tài khoản hiện tại không có quyền quản trị.',
                    'The current account does not have administrator access.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    '/settings',
                    (route) => false,
                  ),
                  child: Text(tr('Về trang Tôi', 'Back to profile')),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
