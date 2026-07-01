import 'package:capstone_mobile/features/search/presentation/widgets/search_section_widgets.dart';
import 'package:flutter/material.dart';

class EmptySearchPage extends StatelessWidget {
  const EmptySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchStateScaffold(
      icon: Icons.search,
      title: 'Khong tim thay ket qua',
      body: 'Chung toi khong tim thay khach san nao khop voi tieu chi cua ban. Thu thay doi bo loc nhe.',
      primaryLabel: 'Thay doi bo loc',
      secondaryLabel: 'Quay lai',
    );
  }
}
