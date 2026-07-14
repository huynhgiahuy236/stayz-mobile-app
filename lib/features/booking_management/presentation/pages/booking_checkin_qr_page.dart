import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingCheckInQrPage extends StatelessWidget {
  const BookingCheckInQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final code = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(tr('Mã QR nhận phòng', 'Check-in QR code'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(
                    'Đưa mã này cho lễ tân hoặc admin StayZ',
                    'Show this code to the property or StayZ admin',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                QrImageView(
                  data: 'STAYZ-CHECKIN:$code',
                  size: 250,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  code,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'Có thể nhập mã này thủ công nếu không quét được QR.',
                    'Enter this code manually if the QR cannot be scanned.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
