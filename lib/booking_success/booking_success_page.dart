import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../room_detail/room_detail_page.dart';
import '../room_detail/widgets/room_detail_container.dart';
import '../room_detail/widgets/room_detail_text.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StayZColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 54, 28, 32),
          children: [
            const _SuccessHeader(),
            const SizedBox(height: 34),
            const _BookingTicket(),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomDetailPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(LucideIcons.house),
                label: const Text('Về Trang chủ'),
                style: FilledButton.styleFrom(
                  backgroundColor: StayZColors.orange,
                  foregroundColor: StayZColors.background,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.download),
                    label: const Text('Tải phiếu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StayZColors.ink,
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(
                        color: StayZColors.border,
                        width: 0.5,
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.calendarPlus),
                    label: const Text('Thêm Lịch'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StayZColors.ink,
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(
                        color: StayZColors.border,
                        width: 0.5,
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: StayZColors.orange,
          child: Icon(
            LucideIcons.check,
            color: StayZColors.background,
            size: 44,
          ),
        ),
        SizedBox(height: 26),
        RoomDetailText(
          text: 'Đặt phòng thành công!',
          size: 24,
          weight: FontWeight.w500,
          align: TextAlign.center,
        ),
        SizedBox(height: 8),
        RoomDetailText(
          text: 'Mã xác nhận: STZ-20250620-8841',
          color: StayZColors.muted,
          size: 15,
          weight: FontWeight.w500,
          align: TextAlign.center,
        ),
      ],
    );
  }
}

class _BookingTicket extends StatelessWidget {
  const _BookingTicket();

  @override
  Widget build(BuildContext context) {
    return StayZCard(
      padding: EdgeInsets.zero,
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StayZNetworkImage(
            url:
                'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=900&q=80',
            height: 176,
            width: double.infinity,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RoomDetailText(
                  text: 'Ana Mandara Cam Ranh',
                  size: 19,
                  weight: FontWeight.w500,
                ),
                const SizedBox(height: 7),
                const Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 17,
                      color: StayZColors.muted,
                    ),
                    SizedBox(width: 4),
                    RoomDetailText(
                      text: 'Bán đảo Cam Ranh, Khánh Hòa',
                      color: StayZColors.muted,
                      size: 13,
                    ),
                  ],
                ),
                const Divider(height: 34),
                const Row(
                  children: [
                    Expanded(
                      child: _TicketInfo(
                        label: 'NHẬN PHÒNG',
                        value: '20 Th6, 2025',
                      ),
                    ),
                    Expanded(
                      child: _TicketInfo(
                        label: 'TRẢ PHÒNG',
                        value: '22 Th6, 2025',
                        alignRight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: _TicketInfo(
                        label: 'SỐ KHÁCH',
                        value: '2 Người lớn',
                      ),
                    ),
                    Expanded(
                      child: _TicketInfo(
                        label: 'TRẠNG THÁI',
                        value: 'ĐÃ THANH TOÁN',
                        alignRight: true,
                        valueColor: StayZColors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 34),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RoomDetailText(
                            text: 'Tổng thanh toán',
                            color: StayZColors.muted,
                            size: 14,
                          ),
                          SizedBox(height: 4),
                          RoomDetailText(
                            text: '6.782.000đ',
                            color: StayZColors.orange,
                            size: 26,
                            weight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 94,
                      height: 94,
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: StayZColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: StayZColors.border),
                      ),
                      child: Container(
                        color: const Color(0xFF243447),
                        child: const Icon(
                          LucideIcons.qrCode,
                          color: StayZColors.white,
                          size: 54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketInfo extends StatelessWidget {
  const _TicketInfo({
    required this.label,
    required this.value,
    this.alignRight = false,
    this.valueColor = StayZColors.ink,
  });

  final String label;
  final String value;
  final bool alignRight;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        RoomDetailText(
          text: label,
          color: StayZColors.muted,
          size: 11,
          weight: FontWeight.w500,
        ),
        const SizedBox(height: 4),
        RoomDetailText(
          text: value,
          color: valueColor,
          size: 15,
          weight: FontWeight.w500,
        ),
      ],
    );
  }
}
