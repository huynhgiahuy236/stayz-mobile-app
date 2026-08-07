import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

/// Man hinh "khong co ket qua" dang toan trang.
///
/// Man tim kiem da xu ly trang thai rong ngay tai cho bang `StayzEmptyView`,
/// nen trang nay chi con dung khi can hien toan man. Ca hai nut deu co
/// dich den that - truoc day chung roi vao `onTap ?? () {}` nen bam khong co gi.
class EmptySearchPage extends StatelessWidget {
  const EmptySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchStateScaffold(
      icon: Icons.search_off_rounded,
      title: tr('Không tìm thấy kết quả', 'No results found'),
      body: tr('Không có khách sạn nào khớp với tiêu chí của bạn. Hãy thử bỏ bớt bộ lọc hoặc đổi từ khoá.', 'No hotels match your criteria. Try removing a filter or changing your search.'),
      primaryLabel: tr('Đổi bộ lọc', 'Change filters'),
      onPrimary: () => Navigator.of(context).pushNamed(AppRoutes.filter, arguments: const SearchFilters()),
      secondaryLabel: tr('Về trang chủ', 'Back to home'),
      onSecondary: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
    );
  }
}
