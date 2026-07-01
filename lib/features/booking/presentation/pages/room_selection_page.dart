import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class RoomSelectionPage extends StatelessWidget {
  const RoomSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      bottomNavigationBar: const StayZBottomNav(activeTab: HomeTab.search),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(
              title: 'Chon phong',
              trailing: Icon(Icons.tune, color: AppTheme.accentDark, size: 24 * responsive.scale),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  30 * responsive.scale,
                  responsive.horizontalPadding,
                  24 * responsive.scale,
                ),
                children: [
                  const _StaySummaryCard(),
                  SizedBox(height: 42 * responsive.scale),
                  FutureBuilder<List<HotelSummary>>(
                    future: MockStayzRepository.instance.getHotelSummaries(),
                    builder: (context, hotelSnapshot) {
                      final hotelId = hotelSnapshot.data?.firstOrNull?.hotel.id;

                      if (hotelId == null) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                      }

                      return FutureBuilder<List<Room>>(
                        future: MockStayzRepository.instance.getRoomsByHotelId(hotelId),
                        builder: (context, roomSnapshot) {
                          final rooms = roomSnapshot.data ?? const <Room>[];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${rooms.length} LOAI PHONG',
                                style: TextStyle(
                                  color: AppTheme.neutral500,
                                  fontSize: 12 * responsive.scale,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 18 * responsive.scale),
                              for (var i = 0; i < rooms.length; i++) ...[
                                RoomOptionCard(
                                  name: rooms[i].name,
                                  price: StayzFormatters.fullVnd(rooms[i].pricePerNight),
                                  badge: rooms[i].availableUnits <= 2 ? 'Sap het' : 'Con ${rooms[i].availableUnits} phong',
                                  note: rooms[i].availableUnits <= 2 ? 'Con ${rooms[i].availableUnits} phong' : null,
                                  badgeColor: rooms[i].availableUnits <= 2 ? const Color(0xFFC06B00) : const Color(0xFF007044),
                                  colors: _roomColors[i % _roomColors.length],
                                  onBook: () => Navigator.of(context).pushNamed(AppRoutes.bookingSchedule),
                                ),
                                if (i != rooms.length - 1) SizedBox(height: 20 * responsive.scale),
                              ],
                            ],
                          );
                        },
                      );
                    },
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

const _roomColors = [
  [Color(0xFF28341C), Color(0xFFB7D27A)],
  [Color(0xFF3D2514), Color(0xFFF0B36D)],
  [Color(0xFF4B4C42), Color(0xFFD9D1C2)],
];

class _StaySummaryCard extends StatelessWidget {
  const _StaySummaryCard();

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, color: AppTheme.accentDark, size: 20 * responsive.scale),
          SizedBox(width: 14 * responsive.widthScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: _DateText(title: 'Thu Sau, 12\nthg 7')),
                    Text('->', style: TextStyle(fontSize: 16 * responsive.scale)),
                    const Expanded(child: _DateText(title: 'Chu Nhat,\n14 thg 7')),
                  ],
                ),
                SizedBox(height: 12 * responsive.scale),
                Text(
                  '2 nguoi lon, 1 phong',
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 12 * responsive.scale),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * responsive.widthScale),
          Column(
            children: [
              CircleAvatar(
                radius: 25 * responsive.scale,
                backgroundColor: AppTheme.neutral200.withValues(alpha: 0.5),
                child: Text(
                  '2\ndem',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 14 * responsive.scale),
                ),
              ),
              SizedBox(height: 8 * responsive.scale),
              Text(
                'Thay doi',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11 * responsive.scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateText extends StatelessWidget {
  const _DateText({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppTheme.ink, fontSize: 15 * responsive.scale, height: 1.35),
    );
  }
}
