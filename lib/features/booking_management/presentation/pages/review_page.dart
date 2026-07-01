import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      body: SafeArea(
        child: Column(
          children: [
            const BookingManageHeader(title: 'Danh gia', trailing: SizedBox.shrink()),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  54 * responsive.scale,
                  responsive.horizontalPadding,
                  34 * responsive.scale,
                ),
                children: [
                  Container(
                    padding: EdgeInsets.all(18 * responsive.scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutral200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 90 * responsive.scale,
                          height: 90 * responsive.scale,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(colors: [Color(0xFF4D2C19), Color(0xFFB89252)]),
                          ),
                        ),
                        SizedBox(width: 22 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            'Amanoi Resort Ninh Thuan\nVinh Hy, Ninh Hai, Ninh Thuan, Viet Nam',
                            style: TextStyle(color: AppTheme.ink, fontSize: 21 * responsive.scale, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 72 * responsive.scale),
                  Text(
                    'TRAI NGHIEM CUA BAN THE NAO?',
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 18 * responsive.scale,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      5,
                      (_) => Icon(Icons.star_border, color: const Color(0xFFD9B8B8), size: 42 * responsive.scale),
                    ),
                  ),
                  SizedBox(height: 82 * responsive.scale),
                  Text(
                    'VIET NHAN XET CUA BAN',
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 18 * responsive.scale,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  Container(
                    height: 190 * responsive.scale,
                    padding: EdgeInsets.all(20 * responsive.scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutral200),
                    ),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Chia se cam nhan cua ban ve ky nghi nay...',
                      style: TextStyle(color: const Color(0xFFD9B8B8), fontSize: 20 * responsive.scale, height: 1.45),
                    ),
                  ),
                  SizedBox(height: 54 * responsive.scale),
                  Text(
                    'THEM HINH ANH',
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 18 * responsive.scale,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 22 * responsive.scale),
                  Row(
                    children: [
                      const _PhotoSlot(icon: true),
                      SizedBox(width: 16 * responsive.widthScale),
                      const _PhotoSlot(),
                      SizedBox(width: 16 * responsive.widthScale),
                      const _PhotoSlot(),
                      SizedBox(width: 16 * responsive.widthScale),
                      const _PhotoSlot(),
                    ],
                  ),
                  SizedBox(height: 66 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Gui danh gia', style: TextStyle(color: Colors.white, fontSize: 20 * responsive.scale)),
                    ),
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  Text(
                    'Danh gia cua ban giup cong dong StayZ tot hon moi ngay.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.neutral500,
                      fontSize: 18 * responsive.scale,
                      fontStyle: FontStyle.italic,
                      height: 1.45,
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

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({this.icon = false});

  final bool icon;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Expanded(
      child: Container(
        height: 76 * responsive.scale,
        decoration: BoxDecoration(
          color: AppTheme.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE7D8D2),
            style: BorderStyle.solid,
          ),
        ),
        child: icon ? Icon(Icons.add_a_photo_outlined, color: const Color(0xFF5A3F3F), size: 28 * responsive.scale) : null,
      ),
    );
  }
}
