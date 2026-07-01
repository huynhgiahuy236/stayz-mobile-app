import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:flutter/material.dart';

class OfflineErrorPage extends StatelessWidget {
  const OfflineErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return SearchStateScaffold(
      showHeader: false,
      icon: Icons.cloud_off_outlined,
      title: 'Khong co ket noi Internet',
      body: 'Vui long kiem tra lai ket noi mang cua ban de tiep tuc trai nghiem.',
      primaryLabel: 'Thu lai',
      secondaryLabel: 'CAI DAT MANG',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.neutral500.withValues(alpha: 0.6),
            size: 18 * responsive.scale,
          ),
          SizedBox(width: 10 * responsive.widthScale),
          Flexible(
            child: Text(
              'Ma loi: ERR_DISCONNECTED_STAYZ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.neutral500.withValues(alpha: 0.6),
                fontSize: 17 * responsive.scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
