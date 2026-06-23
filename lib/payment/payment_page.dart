import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../booking_success/booking_success_page.dart';
import '../room_detail/widgets/room_detail_container.dart';
import '../room_detail/widgets/room_detail_text.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StayZColors.background,
      appBar: AppBar(
        backgroundColor: StayZColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 96,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft, color: StayZColors.ink),
          label: const Text(
            'Quay lại',
            style: TextStyle(color: StayZColors.ink),
          ),
        ),
        title: const Column(
          children: [
            RoomDetailText(
              text: 'Thanh toán',
              size: 20,
              weight: FontWeight.w500,
            ),
            RoomDetailText(
              text: 'BƯỚC 2/3',
              color: StayZColors.muted,
              size: 12,
              weight: FontWeight.w700,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 118),
        children: const [
          _TotalCard(),
          SizedBox(height: 28),
          RoomDetailText(
            text: 'Phương thức thanh toán',
            size: 18,
            weight: FontWeight.w500,
          ),
          SizedBox(height: 16),
          _PaymentMethod(
            title: 'Thẻ Visa/Mastercard',
            subtitle: '**** 4521 (Mặc định)',
            icon: LucideIcons.creditCard,
            selected: true,
          ),
          _PaymentMethod(
            title: 'Chuyển khoản QR',
            subtitle: 'Nhận mã QR thanh toán nhanh',
            icon: LucideIcons.qrCode,
          ),
          _PaymentMethod(
            title: 'Ví điện tử',
            subtitle: 'MoMo, ZaloPay, ShopeePay',
            icon: LucideIcons.walletCards,
            wallet: true,
          ),
          _PaymentMethod(
            title: 'Thanh toán tại chỗ',
            subtitle: 'Thanh toán khi nhận phòng',
            icon: LucideIcons.banknote,
          ),
          SizedBox(height: 22),
          Divider(),
          SizedBox(height: 18),
          _SecurityNotice(),
          SizedBox(height: 20),
          _AgreeTerms(),
        ],
      ),
      bottomNavigationBar: _PaymentBottomBar(
        onPay: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BookingSuccessPage()),
            (route) => route.isFirst,
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: StayZColors.orange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: StayZColors.orange.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoomDetailText(
                  text: 'Tổng cộng',
                  color: StayZColors.background,
                  size: 13,
                  weight: FontWeight.w500,
                ),
                RoomDetailText(
                  text: '6.782.000đ',
                  color: StayZColors.background,
                  size: 28,
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: StayZColors.background.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.receiptText,
              color: StayZColors.background,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.selected = false,
    this.wallet = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: StayZColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? StayZColors.orange : StayZColors.border,
          width: selected ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            selected ? LucideIcons.circleDot : LucideIcons.circle,
            color: selected ? StayZColors.orange : StayZColors.muted,
            size: 26,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoomDetailText(text: title, size: 16, weight: FontWeight.w500),
                const SizedBox(height: 3),
                RoomDetailText(
                  text: subtitle,
                  color: StayZColors.muted,
                  size: 13,
                ),
              ],
            ),
          ),
          if (wallet)
            const Row(
              children: [
                _WalletBadge(text: 'Mo', color: Color(0xFFC0007A)),
                SizedBox(width: 4),
                _WalletBadge(text: 'Za', color: Color(0xFF168CE5)),
              ],
            )
          else
            Icon(icon, color: StayZColors.muted, size: 28),
        ],
      ),
    );
  }
}

class _WalletBadge extends StatelessWidget {
  const _WalletBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: RoomDetailText(
        text: text,
        color: StayZColors.white,
        size: 11,
        weight: FontWeight.w500,
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.shieldCheck, color: StayZColors.n800, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: RoomDetailText(
              text:
                  'Giao dịch của bạn được bảo mật hoàn toàn với chứng chỉ SSL 256-bit. StayZ không lưu trữ thông tin thẻ CVV của bạn.',
              size: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreeTerms extends StatelessWidget {
  const _AgreeTerms();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(LucideIcons.square, color: StayZColors.border, size: 26),
        SizedBox(width: 12),
        Expanded(
          child: RoomDetailText(
            text:
                'Tôi đã đọc và đồng ý với Điều khoản sử dụng và Chính sách hoàn tiền của StayZ.',
            color: StayZColors.muted,
            size: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PaymentBottomBar extends StatelessWidget {
  const _PaymentBottomBar({required this.onPay});

  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: const BoxDecoration(color: StayZColors.white),
      child: SizedBox(
        height: 56,
        child: FilledButton(
          onPressed: onPay,
          style: FilledButton.styleFrom(
            backgroundColor: StayZColors.orange,
            foregroundColor: StayZColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Thanh toán ngay 6.782.000đ  ->',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
