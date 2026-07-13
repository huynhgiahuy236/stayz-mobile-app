import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class RoomTypeDetailPage extends StatelessWidget {
  const RoomTypeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final value = ModalRoute.of(context)?.settings.arguments;
    if (value is! BookingDraft) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('Chi tiết phòng', 'Room details'))),
        body: StayzEmptyView(
          icon: Icons.bed_outlined,
          title: tr('Thiếu thông tin phòng', 'Missing room information'),
          message: tr(
            'Vui lòng quay lại và chọn một phòng.',
            'Please go back and select a room.',
          ),
        ),
      );
    }

    final draft = value;
    final room = draft.room;
    final canBook = room.availableUnits > 0 && room.status != 'inactive';
    final capacity = room.capacityAdults + room.capacityChildren;
    final imageUrl = room.imageUrls.firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            12,
            responsive.horizontalPadding,
            16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.line)),
          ),
          child: SizedBox(
            height: AppTheme.pageActionHeight,
            child: FilledButton(
              onPressed: canBook
                  ? () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.bookingSchedule, arguments: draft)
                  : null,
              child: Text(
                canBook
                    ? tr('Chọn phòng này', 'Select this room')
                    : tr('Hết phòng', 'Sold out'),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(title: tr('Chi tiết phòng', 'Room details')),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  16,
                  responsive.horizontalPadding,
                  32,
                ),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    child: AspectRatio(
                      aspectRatio: AppTheme.cardImageAspectRatio,
                      child: imageUrl == null
                          ? const ColoredBox(
                              color: AppTheme.primarySoft,
                              child: Icon(
                                Icons.bed_rounded,
                                size: 72,
                                color: AppTheme.primary,
                              ),
                            )
                          : StayZNetworkImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              semanticLabel: room.name,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    room.name,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    draft.hotel.hotel.name,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    StayzFormatters.fullVnd(room.pricePerNight),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.people_outline,
                        label: tr('$capacity khách', '$capacity guests'),
                      ),
                      _InfoChip(
                        icon: Icons.square_foot_outlined,
                        // l10n-ignore: SI area unit is language invariant.
                        label: '${room.sizeSqm}m²',
                      ),
                      _InfoChip(icon: Icons.bed_outlined, label: room.bedType),
                      _InfoChip(
                        icon: Icons.meeting_room_outlined,
                        label: StayzTaxonomy.roomTypeLabel(room.roomType),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr('Giới thiệu phòng', 'About this room'),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    room.localizedDescription.isEmpty
                        ? tr(
                            'Phòng chưa có mô tả chi tiết.',
                            'No detailed room description yet.',
                          )
                        : room.localizedDescription,
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr('Tiện ích trong phòng', 'Room amenities'),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (room.amenityIds.isEmpty)
                    Text(
                      tr('Chưa cập nhật tiện ích.', 'No amenities listed yet.'),
                      style: const TextStyle(color: AppTheme.muted),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: room.amenityIds
                          .map(
                            (item) => Chip(
                              label: Text(
                                StayzTaxonomy.amenityTerm(item).label,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  _PolicyCard(availableUnits: room.availableUnits),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.line),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.availableUnits});
  final int availableUnits;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.primarySoft.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      border: Border.all(color: AppTheme.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.verified_outlined, color: AppTheme.success),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tr(
              'Còn $availableUnits phòng. Chính sách thanh toán và hủy được hiển thị ở bước xác nhận.',
              '$availableUnits rooms left. Payment and cancellation policies appear at confirmation.',
            ),
            style: const TextStyle(color: AppTheme.ink, height: 1.4),
          ),
        ),
      ],
    ),
  );
}
