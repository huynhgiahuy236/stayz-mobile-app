import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/detail/presentation/widgets/detail_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class HotelInfoFormPage extends StatelessWidget {
  const HotelInfoFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.profile),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                16 * responsive.scale,
                responsive.horizontalPadding,
                18 * responsive.scale,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.55)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    color: AppTheme.accentDark,
                  ),
                  SizedBox(width: 8 * responsive.widthScale),
                  Expanded(
                    child: Text(
                      'Trung tam ho tro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 30 * responsive.scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: AppTheme.neutral500, size: 28 * responsive.scale),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  32 * responsive.scale,
                  responsive.horizontalPadding,
                  42 * responsive.scale,
                ),
                children: [
                  Container(
                    height: 64 * responsive.scale,
                    padding: EdgeInsets.symmetric(horizontal: 20 * responsive.widthScale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutral200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: const Color(0xFF5A3F3F), size: 24 * responsive.scale),
                        SizedBox(width: 16 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            'Tim kiem giai phap...',
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 18 * responsive.scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 54 * responsive.scale),
                  const DetailSectionTitle(title: 'Cau hoi thuong gap'),
                  SizedBox(height: 24 * responsive.scale),
                  const _FaqTile(
                    title: 'Lam the nao de huy phong?',
                    body: 'Ban co the huy phong trong muc "Dat phong" va xem dieu kien huy truoc khi xac nhan.',
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  const _FaqTile(
                    title: 'Chinh sach hoan tien',
                    body: 'Tien se duoc hoan tra vao phuong thuc thanh toan ban da su dung.',
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  const _FaqTile(
                    title: 'Thay doi thoi gian luu tru',
                    body: 'De thay doi thoi gian, vui long lien he khach san hoac bo phan ho tro.',
                  ),
                  SizedBox(height: 56 * responsive.scale),
                  const DetailSectionTitle(title: 'Lien he voi chung toi'),
                  SizedBox(height: 24 * responsive.scale),
                  Row(
                    children: [
                      const Expanded(
                        child: SupportActionCard(
                          icon: Icons.phone_outlined,
                          title: 'HOTLINE',
                          value: '1900 1234',
                          color: Color(0xFFFF8F98),
                        ),
                      ),
                      SizedBox(width: 20 * responsive.widthScale),
                      const Expanded(
                        child: SupportActionCard(
                          icon: Icons.chat_bubble_outline,
                          title: 'TRUC\nTUYEN',
                          value: 'Chat ngay',
                          color: Color(0xFFFFC76B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 54 * responsive.scale),
                  Container(
                    padding: EdgeInsets.all(28 * responsive.scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0DEDA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neutral200.withValues(alpha: 0.8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gui phan hoi cho chung toi',
                                style: TextStyle(
                                  color: AppTheme.accentDark,
                                  fontSize: 17 * responsive.scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 14 * responsive.scale),
                              Text(
                                'Y kien cua ban giup chung toi cai thien dich vu tot hon moi ngay.',
                                style: TextStyle(
                                  color: const Color(0xFF6B5348),
                                  fontSize: 18 * responsive.scale,
                                  height: 1.55,
                                ),
                              ),
                              SizedBox(height: 28 * responsive.scale),
                              SizedBox(
                                height: 52 * responsive.scale,
                                child: FilledButton(
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Cảm ơn bạn, StayZ đã ghi nhận phản hồi.')),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.accentDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: Text(
                                    'VIET PHAN HOI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16 * responsive.scale,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12 * responsive.widthScale),
                        Icon(
                          Icons.rate_review_outlined,
                          color: AppTheme.accentDark.withValues(alpha: 0.22),
                          size: 42 * responsive.scale,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 56 * responsive.scale),
                  const DetailSectionTitle(title: 'Phap ly'),
                  SizedBox(height: 26 * responsive.scale),
                  const _LegalTile(label: 'Dieu khoan su dung'),
                  const _LegalTile(label: 'Chinh sach bao mat'),
                  SizedBox(height: 54 * responsive.scale),
                  Icon(
                    Icons.local_florist_outlined,
                    color: AppTheme.neutral200.withValues(alpha: 0.72),
                    size: 56 * responsive.scale,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      constraints: BoxConstraints(minHeight: 82 * responsive.scale),
      padding: EdgeInsets.symmetric(
        horizontal: 18 * responsive.widthScale,
        vertical: 14 * responsive.scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 17 * responsive.scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: AppTheme.ink, size: 24 * responsive.scale),
            ],
          ),
          SizedBox(height: 10 * responsive.scale),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.neutral500,
              fontSize: 14 * responsive.scale,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      height: 64 * responsive.scale,
      padding: EdgeInsets.symmetric(horizontal: 0 * responsive.widthScale),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.35)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF5A3F3F),
                fontSize: 17 * responsive.scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.neutral500, size: 26 * responsive.scale),
        ],
      ),
    );
  }
}
