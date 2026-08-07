import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

enum StayzAlertType { success, info, warning, error }

/// Alert tuy chinh cho khach hang: mot banner truot tu tren xuong, tu an sau
/// vai giay. KHAC voi muc Thong bao (danh sach luu lai) - day chi la thong bao
/// tuc thoi de khach biet ket qua thao tac vua roi.
class StayzAlert {
  const StayzAlert._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    StayzAlertType type = StayzAlertType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _AlertBanner(
        title: title,
        message: message,
        type: type,
        duration: duration,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _AlertBanner extends StatefulWidget {
  const _AlertBanner({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.title,
  });

  final String? title;
  final String message;
  final StayzAlertType type;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<_AlertBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onDismissed();
      return;
    }
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ({Color bg, Color fg, IconData icon}) get _style {
    switch (widget.type) {
      case StayzAlertType.success:
        return (bg: AppTheme.success, fg: Colors.white, icon: Icons.check_circle_rounded);
      case StayzAlertType.info:
        return (bg: AppTheme.primary, fg: Colors.white, icon: Icons.info_rounded);
      case StayzAlertType.warning:
        return (bg: AppTheme.gold, fg: Colors.white, icon: Icons.warning_amber_rounded);
      case StayzAlertType.error:
        return (bg: AppTheme.danger, fg: Colors.white, icon: Icons.error_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topInset + 10,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _slide,
        child: Semantics(
          liveRegion: true,
          container: true,
          button: true,
          label: [widget.title, widget.message].whereType<String>().join('. '),
          hint: context.l10n.text('Chạm hai lần để đóng', 'Double tap to dismiss'),
          onTap: _dismiss,
          child: ExcludeSemantics(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismiss,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: s.bg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(s.icon, color: s.fg, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.title != null) ...[
                              Text(
                                widget.title!,
                                style: TextStyle(
                                  color: s.fg,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: s.fg.withValues(alpha: 0.95),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
