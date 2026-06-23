import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../booking_confirm/booking_confirm_page.dart';
import '../room_detail/widgets/room_detail_container.dart';
import '../room_detail/widgets/room_detail_text.dart';

class RoomSelectionPage extends StatelessWidget {
  const RoomSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    const hotel = stayZHotel;

    return Scaffold(
      backgroundColor: StayZColors.background,
      appBar: AppBar(
        backgroundColor: StayZColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft, color: StayZColors.ink),
        ),
        title: const Column(
          children: [
            RoomDetailText(
              text: 'Chọn phòng',
              size: 22,
              weight: FontWeight.w400,
              role: StayZTextRole.display,
            ),
            RoomDetailText(
              text: 'ROOM SELECTION',
              color: StayZColors.muted,
              size: 10,
              weight: FontWeight.w500,
              letterSpacing: 1.1,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 112),
        children: [
          const StayZBadge(
            text: 'Còn 2 phòng giá tốt',
            color: StayZColors.warning,
            background: StayZColors.warningSoft,
          ),
          const SizedBox(height: 16),
          RoomDetailText(text: hotel.name, size: 18, weight: FontWeight.w500),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(
                LucideIcons.calendarDays,
                size: 16,
                color: StayZColors.muted,
              ),
              SizedBox(width: 6),
              RoomDetailText(
                text: '12 Th08 - 14 Th08 · 2 khách',
                color: StayZColors.muted,
                size: 12,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...hotel.rooms.map(
            (room) => RoomOptionCard(
              room: room,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingConfirmPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const StayZCard(
            color: StayZColors.orangeSoft,
            borderColor: StayZColors.orangeSoft,
            child: Row(
              children: [
                Icon(LucideIcons.info, color: StayZColors.orange, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: RoomDetailText(
                    text:
                        'Giá đã bao gồm thuế và phí cơ bản. Chính sách hủy tùy theo từng hạng phòng.',
                    color: StayZColors.orangeDark,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          28,
          12,
          28,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: const BoxDecoration(
          color: StayZColors.white,
          border: Border(
            top: BorderSide(color: StayZColors.divider, width: 0.5),
          ),
        ),
        child: SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingConfirmPage()),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: StayZColors.orange,
              foregroundColor: StayZColors.background,
            ),
            child: const Text('TIẾP TỤC ĐẶT PHÒNG'),
          ),
        ),
      ),
    );
  }
}
