import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/detail/presentation/widgets/detail_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelInfoFormPage extends StatefulWidget {
  const HotelInfoFormPage({super.key});

  @override
  State<HotelInfoFormPage> createState() => _HotelInfoFormPageState();
}

class _HotelInfoFormPageState extends State<HotelInfoFormPage> {
  static const _supportPhone = '0372212378';
  String _query = '';

  Future<void> _openContact(Uri uri, String fallbackMessage) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(fallbackMessage)));
    }
  }

  Future<void> _callSupport() => _openContact(
    Uri(scheme: 'tel', path: _supportPhone),
    tr(
      'Không thể mở cuộc gọi. Vui lòng gọi $_supportPhone.',
      'Could not open the phone app. Please call $_supportPhone.',
    ),
  );

  Future<void> _openZalo() => _openContact(
    Uri.parse('https://zalo.me/$_supportPhone'),
    tr(
      'Không thể mở Zalo. Vui lòng tìm số $_supportPhone trên Zalo.',
      'Could not open Zalo. Please search for $_supportPhone.',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final articles = <_HelpArticle>[
      _HelpArticle(
        title: tr('Làm thế nào để hủy phòng?', 'How do I cancel a booking?'),
        summary: tr(
          'Mở chuyến đi, chọn đơn và kiểm tra điều kiện trước khi xác nhận.',
          'Open Trips, select the booking, and review the terms first.',
        ),
        steps: [
          tr(
            'Vào mục Lịch đặt ở thanh điều hướng.',
            'Open Trips from the navigation bar.',
          ),
          tr(
            'Chọn đơn sắp tới bạn muốn hủy.',
            'Select the upcoming booking you want to cancel.',
          ),
          tr(
            'Mở chi tiết và chọn Hủy đặt phòng.',
            'Open its details and choose Cancel booking.',
          ),
          tr(
            'Đọc số tiền hoàn dự kiến rồi tự xác nhận hủy.',
            'Review the estimated refund, then confirm the cancellation yourself.',
          ),
        ],
      ),
      _HelpArticle(
        title: tr('Chính sách hoàn tiền', 'Refund policy'),
        summary: tr(
          'Khoản hoàn phụ thuộc trạng thái thanh toán và thời điểm hủy.',
          'Refunds depend on payment status and cancellation time.',
        ),
        steps: [
          tr(
            'StayZ hiển thị số tiền hoàn dự kiến trước khi bạn xác nhận hủy.',
            'StayZ shows the estimated refund before cancellation confirmation.',
          ),
          tr(
            'Không đóng ứng dụng khi yêu cầu đang được xử lý.',
            'Keep the app open while the request is being processed.',
          ),
          tr(
            'Nếu trạng thái chưa cập nhật, gửi mã đặt phòng qua Zalo hỗ trợ.',
            'If the status is not updated, send the booking code to Zalo support.',
          ),
        ],
      ),
      _HelpArticle(
        title: tr('Thay đổi thời gian lưu trú', 'Change stay dates'),
        summary: tr(
          'Ngày lưu trú không sửa trực tiếp trên đơn đã tạo.',
          'Stay dates cannot be edited directly on an existing booking.',
        ),
        steps: [
          tr(
            'Mở chi tiết đơn để lấy mã đặt phòng và tên khách sạn.',
            'Open booking details to get the booking code and hotel name.',
          ),
          tr(
            'Liên hệ Zalo hỗ trợ và gửi ngày nhận, trả phòng mong muốn.',
            'Contact Zalo support with your requested check-in and check-out dates.',
          ),
          tr(
            'Chỉ thay đổi sau khi khách sạn xác nhận còn phòng và giá mới.',
            'Only change after the hotel confirms availability and the updated price.',
          ),
        ],
      ),
      _HelpArticle(
        title: tr('Thanh toán bằng VietQR', 'Pay with VietQR'),
        summary: tr(
          'Mã QR có hiệu lực 15 phút và cần thanh toán đúng số tiền.',
          'The QR code is valid for 15 minutes and requires the exact amount.',
        ),
        steps: [
          tr(
            'Quét mã bằng ứng dụng ngân hàng hỗ trợ VietQR.',
            'Scan the code with a VietQR-supported banking app.',
          ),
          tr(
            'Giữ nguyên nội dung chuyển khoản và thanh toán đúng số tiền.',
            'Keep the transfer reference and pay the exact amount.',
          ),
          tr(
            'Quay lại StayZ để kiểm tra trạng thái thanh toán.',
            'Return to StayZ and check the payment status.',
          ),
        ],
      ),
      _HelpArticle(
        title: tr('Không nhận được mã OTP', 'OTP code not received'),
        summary: tr(
          'Kiểm tra email, thư rác và chờ trước khi yêu cầu mã mới.',
          'Check your inbox and spam folder before requesting a new code.',
        ),
        steps: [
          tr(
            'Kiểm tra đúng địa chỉ email đã nhập.',
            'Verify the email address you entered.',
          ),
          tr(
            'Kiểm tra mục Spam hoặc Thư rác.',
            'Check the Spam or Junk folder.',
          ),
          tr(
            'Nếu vẫn không có mã, liên hệ Zalo và không gửi mật khẩu.',
            'If no code arrives, contact Zalo and never send your password.',
          ),
        ],
      ),
      _HelpArticle(
        title: tr(
          'Liên hệ khách sạn khi nhận phòng',
          'Contact the hotel at check-in',
        ),
        summary: tr(
          'Chuẩn bị mã đặt phòng và thông tin người đặt để được hỗ trợ.',
          'Have the booking code and guest details ready for support.',
        ),
        steps: [
          tr(
            'Mở đơn đã xác nhận trong mục Lịch đặt.',
            'Open the confirmed booking in Trips.',
          ),
          tr(
            'Xuất trình mã đặt phòng hoặc mã check-in tại quầy.',
            'Show the booking or check-in code at reception.',
          ),
          tr(
            'Nếu khách sạn chưa thấy đơn, liên hệ ngay Zalo StayZ.',
            'If the hotel cannot find it, contact StayZ on Zalo immediately.',
          ),
        ],
      ),
    ];
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleArticles = articles
        .where(
          (article) =>
              normalizedQuery.isEmpty ||
              '${article.title} ${article.summary} ${article.steps.join(' ')}'
                  .toLowerCase()
                  .contains(normalizedQuery),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: AppTheme.surface,
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
                  bottom: BorderSide(
                    color: AppTheme.neutral200.withValues(alpha: 0.55),
                  ),
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
                      tr('Trung tâm hỗ trợ', 'Help center'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accentDark,
                        fontSize: 30 * responsive.scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: AppTheme.neutral500,
                    size: 28 * responsive.scale,
                  ),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * responsive.widthScale,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutral200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppTheme.ink,
                          size: 24 * responsive.scale,
                        ),
                        SizedBox(width: 16 * responsive.widthScale),
                        Expanded(
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: tr(
                                'Tìm kiếm bài hướng dẫn...',
                                'Search help articles...',
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 18 * responsive.scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  DetailSectionTitle(
                    title: tr(
                      'Câu hỏi thường gặp',
                      'Frequently asked questions',
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  if (visibleArticles.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 24 * responsive.scale,
                      ),
                      child: Text(
                        tr(
                          'Không tìm thấy bài hướng dẫn phù hợp.',
                          'No matching help article was found.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    )
                  else
                    for (
                      var index = 0;
                      index < visibleArticles.length;
                      index++
                    ) ...[
                      _FaqTile(article: visibleArticles[index]),
                      if (index != visibleArticles.length - 1)
                        SizedBox(height: 12 * responsive.scale),
                    ],
                  SizedBox(height: 32 * responsive.scale),
                  DetailSectionTitle(
                    title: tr('Liên hệ với chúng tôi', 'Contact us'),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _callSupport,
                          child: const SupportActionCard(
                            icon: Icons.phone_outlined,
                            title: 'HOTLINE',
                            value: _supportPhone,
                            color: Color(0xFFFF8F98),
                          ),
                        ),
                      ),
                      SizedBox(width: 20 * responsive.widthScale),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openZalo,
                          child: SupportActionCard(
                            icon: Icons.chat_bubble_outline,
                            title: 'ZALO',
                            value: _supportPhone,
                            color: const Color(0xFFFFC76B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32 * responsive.scale),
                  Container(
                    padding: EdgeInsets.all(28 * responsive.scale),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.neutral200.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr(
                                  'Gửi phản hồi cho chúng tôi',
                                  'Send us feedback',
                                ),
                                style: TextStyle(
                                  color: AppTheme.accentDark,
                                  fontSize: 17 * responsive.scale,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 14 * responsive.scale),
                              Text(
                                tr(
                                  'Ý kiến của bạn giúp chúng tôi cải thiện dịch vụ tốt hơn mỗi ngày.',
                                  'Your feedback helps us improve StayZ.',
                                ),
                                style: TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 18 * responsive.scale,
                                  height: 1.55,
                                ),
                              ),
                              SizedBox(height: 28 * responsive.scale),
                              SizedBox(
                                height: 52 * responsive.scale,
                                child: FilledButton(
                                  onPressed: _openZalo,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.accentDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: Text(
                                    tr('GỬI QUA ZALO', 'SEND VIA ZALO'),
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
                  SizedBox(height: 32 * responsive.scale),
                  DetailSectionTitle(title: tr('Pháp lý', 'Legal')),
                  SizedBox(height: 26 * responsive.scale),
                  _LegalTile(label: tr('Điều khoản sử dụng', 'Terms of use')),
                  _LegalTile(label: tr('Chính sách bảo mật', 'Privacy policy')),
                  SizedBox(height: 32 * responsive.scale),
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
  const _FaqTile({required this.article});

  final _HelpArticle article;

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
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: 18 * responsive.widthScale,
          vertical: 4 * responsive.scale,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          18 * responsive.widthScale,
          0,
          18 * responsive.widthScale,
          18 * responsive.scale,
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: AppTheme.accentDark,
        collapsedIconColor: AppTheme.ink,
        title: Text(
          article.title,
          style: TextStyle(
            color: AppTheme.ink,
            fontSize: 17 * responsive.scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8 * responsive.scale),
          child: Text(
            article.summary,
            style: TextStyle(
              color: AppTheme.neutral500,
              fontSize: 14 * responsive.scale,
              height: 1.4,
            ),
          ),
        ),
        children: [
          const Divider(height: 1),
          SizedBox(height: 14 * responsive.scale),
          for (var index = 0; index < article.steps.length; index++)
            Padding(
              padding: EdgeInsets.only(bottom: 10 * responsive.scale),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24 * responsive.scale,
                    height: 24 * responsive.scale,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentDark,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * responsive.widthScale),
                  Expanded(
                    child: Text(
                      article.steps[index],
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 14 * responsive.scale,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HelpArticle {
  const _HelpArticle({
    required this.title,
    required this.summary,
    required this.steps,
  });

  final String title;
  final String summary;
  final List<String> steps;
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
          bottom: BorderSide(
            color: AppTheme.neutral200.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 17 * responsive.scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppTheme.neutral500,
            size: 26 * responsive.scale,
          ),
        ],
      ),
    );
  }
}
