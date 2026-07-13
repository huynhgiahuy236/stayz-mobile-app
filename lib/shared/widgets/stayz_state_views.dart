import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/services/api_service.dart' show ApiException;
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

/// Trang thai rong / loi / dang tai dung chung cho moi man hinh.
///
/// Truoc day khi tim kiem tra ve 0 ket qua va khi API loi, giao dien hien
/// giong het nhau ("0 stays found" tren nen trang), nen nguoi dung khong
/// phan biet duoc "khong co gi" voi "khong tai duoc".

class StayzEmptyView extends StatelessWidget {
  const StayzEmptyView({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Ban gon de nhet vua vao mot dai ngang trong danh sach.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: icon,
      iconColor: AppTheme.muted,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      compact: compact,
    );
  }
}

class StayzErrorView extends StatelessWidget {
  const StayzErrorView({
    required this.error,
    this.onRetry,
    this.compact = false,
    super.key,
  });

  final Object? error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final apiError = error is ApiException ? error as ApiException : null;
    final offline = apiError?.isOffline ?? false;

    return _StateScaffold(
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      iconColor: AppTheme.danger,
      title: offline
          ? context.l10n.text('Không có kết nối', 'No connection')
          : context.l10n.text('Không tải được dữ liệu', 'Could not load data'),
      // Chi hien thong diep da duoc dich; khong bao gio in nguyen exception.
      message:
          apiError?.message ??
          context.l10n.text(
            'Đã có lỗi xảy ra. Vui lòng thử lại.',
            'Something went wrong. Please try again.',
          ),
      actionLabel: onRetry == null
          ? null
          : context.l10n.text('Thử lại', 'Try again'),
      onAction: onRetry,
      compact: compact,
    );
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.compact,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final bool compact;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    // Cuon duoc: o man hinh nho hoac khi nguoi dung phong to chu,
    // noi dung can cuon thay vi tran khoi khung.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Semantics(
          liveRegion: true,
          container: true,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : 0,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: compact ? 16 : 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Container(
                      width: compact ? 56 : 84,
                      height: compact ? 56 : 84,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: compact ? 28 : 40, color: iconColor),
                    ),
                    SizedBox(height: compact ? 12 : 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: compact ? 15 : 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: compact ? 13 : 14,
                        height: 1.5,
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      SizedBox(height: compact ? 14 : 22),
                      FilledButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(actionLabel!),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          minimumSize: const Size(140, 48),
                        ),
                      ),
                    ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
