import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'room_detail_container.dart';
import 'room_detail_text.dart';

class RoomDetailAppBar extends StatelessWidget {
  const RoomDetailAppBar({super.key, required this.hotel});

  final StayZHotel hotel;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: StayZColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: _CircleButton(
        icon: LucideIcons.arrowLeft,
        onTap: () => Navigator.maybePop(context),
      ),
      actions: const [
        _CircleButton(icon: LucideIcons.share2),
        SizedBox(width: 10),
        _CircleButton(icon: LucideIcons.heart, iconColor: StayZColors.orange),
        SizedBox(width: 14),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            StayZNetworkImage(url: hotel.heroImage, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0x661A1612),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: RoomDetailText(
                      text: 'HOTEL DETAIL',
                      color: StayZColors.background,
                      size: 10,
                      weight: FontWeight.w500,
                      letterSpacing: 1.4,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: StayZColors.ink.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const RoomDetailText(
                      text: '1 / 5',
                      color: StayZColors.background,
                      size: 12,
                      weight: FontWeight.w500,
                      height: 1,
                    ),
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    this.onTap,
    this.iconColor = StayZColors.ink,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: StayZColors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: StayZColors.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
