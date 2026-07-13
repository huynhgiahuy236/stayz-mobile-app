import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

/// Man hinh mat ket noi dang toan trang.
///
/// Cac man danh sach da hien loi ngay tai cho bang `StayzErrorView`, nen trang
/// nay dung cho truong hop can chan toan bo. Nut khong con la trang tri.
class OfflineErrorPage extends StatelessWidget {
  const OfflineErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SearchStateScaffold(
      showHeader: false,
      icon: Icons.cloud_off_outlined,
      title: tr('Không có kết nối Internet', 'No Internet connection'),
      body: tr('Vui lòng kiểm tra lại kết nối mạng của bạn rồi thử lại.', 'Check your network connection and try again.'),
      primaryLabel: tr('Thử lại', 'Try again'),
      // Quay lai man truoc de no tu tai lai; neu khong con gi de quay lai thi ve trang chu.
      onPrimary: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        }
      },
      secondaryLabel: tr('Về trang chủ', 'Back to home'),
      onSecondary: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: AppTheme.muted, size: 16 * responsive.scale),
          SizedBox(width: 8 * responsive.widthScale),
          Flexible(
            child: Text(
          tr('Mã lỗi: ERR_DISCONNECTED_STAYZ', 'Error code: ERR_DISCONNECTED_STAYZ'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Truoc day chu nay o alpha 0.6 tren nen kem, khong dat chuan tuong phan.
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 13 * responsive.scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
