import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../payment/payment_page.dart';
import '../room_detail/widgets/room_detail_container.dart';
import '../room_detail/widgets/room_detail_text.dart';

class BookingConfirmPage extends StatelessWidget {
  const BookingConfirmPage({super.key});

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
              text: 'Xác nhận đặt phòng',
              size: 17,
              weight: FontWeight.w500,
            ),
            RoomDetailText(
              text: 'BƯỚC 1/3',
              color: StayZColors.muted,
              size: 11,
              weight: FontWeight.w700,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 110),
        children: const [
          _HotelSummaryCard(),
          SizedBox(height: 22),
          _ContactSection(),
          SizedBox(height: 22),
          _SpecialRequestSection(),
          SizedBox(height: 22),
          _CouponSection(),
          SizedBox(height: 22),
          _PriceDetailSection(),
          SizedBox(height: 20),
          _NoticeBox(),
        ],
      ),
      bottomNavigationBar: _ConfirmBottomBar(
        onContinue: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaymentPage()),
          );
        },
      ),
    );
  }
}

class _HotelSummaryCard extends StatelessWidget {
  const _HotelSummaryCard();

  @override
  Widget build(BuildContext context) {
    return StayZCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              StayZNetworkImage(
                url: stayZHotel.rooms.first.image,
                width: 84,
                height: 84,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoomDetailText(
                      text: 'Ana Mandara Cam Ranh',
                      size: 16,
                      weight: FontWeight.w500,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 15,
                          color: StayZColors.muted,
                        ),
                        SizedBox(width: 3),
                        Expanded(
                          child: RoomDetailText(
                            text: 'Bãi Dài, Cam Ranh, Khánh Hòa',
                            color: StayZColors.muted,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    RoomDetailText(
                      text: 'Phòng Deluxe Hướng Biển',
                      size: 13,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          const Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  label: 'NGÀY NHẬN & TRẢ',
                  value: '12 Th08 - 14 Th08',
                  icon: LucideIcons.calendarDays,
                ),
              ),
              Expanded(
                child: _MiniInfo(
                  label: 'KHÁCH & PHÒNG',
                  value: '2 Người, 1 Phòng',
                  icon: LucideIcons.userRound,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: StayZColors.orange, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoomDetailText(
                text: label,
                color: StayZColors.muted,
                size: 10,
                weight: FontWeight.w500,
              ),
              const SizedBox(height: 4),
              RoomDetailText(text: value, size: 13, weight: FontWeight.w500),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormTitle(icon: LucideIcons.idCard, title: 'Thông tin liên hệ'),
        SizedBox(height: 12),
        StayZCard(
          child: Column(
            children: [
              _FieldLine(label: 'HỌ VÀ TÊN', value: 'Nguyễn Thành'),
              SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _FieldLine(
                      label: 'SỐ ĐIỆN THOẠI',
                      value: '0901 234 567',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _FieldLine(
                      label: 'EMAIL',
                      value: 'thanh.nguyen@gmail.com',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpecialRequestSection extends StatelessWidget {
  const _SpecialRequestSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormTitle(icon: LucideIcons.listChecks, title: 'Yêu cầu đặc biệt'),
        SizedBox(height: 12),
        StayZCard(
          child: SizedBox(
            height: 72,
            child: Align(
              alignment: Alignment.topLeft,
              child: RoomDetailText(
                text: 'Ví dụ: Phòng không hút thuốc, tầng cao, check-in sớm...',
                color: StayZColors.muted,
                size: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CouponSection extends StatelessWidget {
  const _CouponSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormTitle(icon: LucideIcons.ticketPercent, title: 'Mã giảm giá'),
        const SizedBox(height: 12),
        StayZCard(
          borderColor: StayZColors.orange.withValues(alpha: 0.38),
          child: const Row(
            children: [
              Icon(LucideIcons.circleCheck, color: StayZColors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoomDetailText(
                      text: 'STAYZ20',
                      color: StayZColors.orange,
                      size: 13,
                      weight: FontWeight.w500,
                    ),
                    RoomDetailText(
                      text: 'Đã áp dụng giảm 10%',
                      color: StayZColors.muted,
                      size: 12,
                    ),
                  ],
                ),
              ),
              RoomDetailText(
                text: '-680.000đ',
                color: StayZColors.orange,
                size: 13,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceDetailSection extends StatelessWidget {
  const _PriceDetailSection();

  @override
  Widget build(BuildContext context) {
    return const StayZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoomDetailText(
            text: 'Chi tiết thanh toán',
            size: 15,
            weight: FontWeight.w500,
          ),
          SizedBox(height: 16),
          _PriceRow(label: 'Giá phòng (2 đêm)', value: '6.800.000đ'),
          _PriceRow(
            label: 'Mã giảm giá',
            value: '-680.000đ',
            accent: StayZColors.orange,
          ),
          _PriceRow(label: 'Thuế VAT (10%)', value: '612.000đ'),
          _PriceRow(label: 'Phí dịch vụ', value: '50.000đ'),
          Divider(height: 26),
          _PriceRow(
            label: 'Tổng cộng',
            value: '6.782.000đ',
            big: true,
            accent: StayZColors.orange,
          ),
        ],
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StayZColors.greenSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, color: StayZColors.green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: RoomDetailText(
              text:
                  'Hủy phòng miễn phí trước ngày 10 tháng 08. Sau thời gian này, phí hủy phòng sẽ được tính theo chính sách của khách sạn.',
              color: Color(0xFF166534),
              size: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormTitle extends StatelessWidget {
  const _FormTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 21),
        const SizedBox(width: 10),
        RoomDetailText(text: title, size: 16, weight: FontWeight.w500),
      ],
    );
  }
}

class _FieldLine extends StatelessWidget {
  const _FieldLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoomDetailText(
          text: label,
          color: StayZColors.muted,
          size: 10,
          weight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        RoomDetailText(text: value, size: 13),
        const SizedBox(height: 8),
        Container(height: 1, color: StayZColors.border),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.accent = StayZColors.ink,
    this.big = false,
  });

  final String label;
  final String value;
  final Color accent;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Expanded(
            child: RoomDetailText(
              text: label,
              size: big ? 15 : 13,
              weight: big ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          RoomDetailText(
            text: value,
            color: accent,
            size: big ? 22 : 13,
            weight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class _ConfirmBottomBar extends StatelessWidget {
  const _ConfirmBottomBar({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        28,
        12,
        28,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(color: StayZColors.white),
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: StayZColors.orange,
            foregroundColor: StayZColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Tiếp tục   ->   Thanh toán',
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
