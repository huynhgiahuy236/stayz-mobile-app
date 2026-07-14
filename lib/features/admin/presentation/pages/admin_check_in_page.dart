import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/admin/data/admin_repository.dart';
import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/widgets/stayz_brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminCheckInPage extends StatefulWidget {
  const AdminCheckInPage({super.key});
  @override
  State<AdminCheckInPage> createState() => _AdminCheckInPageState();
}

class _AdminCheckInPageState extends State<AdminCheckInPage> {
  final _repository = const AdminRepository();
  final _codeController = TextEditingController();
  final _scannerController = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
  );
  AdminBooking? _booking;
  bool _scanning = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _lookup([String? scannedValue]) async {
    if (_busy) return;
    final value = (scannedValue ?? _codeController.text).trim();
    if (value.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final booking = await _repository.findBookingByCheckInCode(value);
      if (!mounted) return;
      _codeController.text = booking.checkInCode;
      setState(() {
        _booking = booking;
        _scanning = false;
      });
      await _scannerController.stop();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleScanner() async {
    if (_busy) return;
    if (_scanning) {
      await _scannerController.stop();
      if (mounted) setState(() => _scanning = false);
      return;
    }

    setState(() {
      _scanning = true;
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _scannerController.start();
      } on MobileScannerException catch (error) {
        if (!mounted) return;
        setState(() {
          _scanning = false;
          _error = tr(
            'Không mở được camera quét QR: ${error.errorCode.name}.',
            'Could not start the QR camera: ${error.errorCode.name}.',
          );
        });
      }
    });
  }

  Future<void> _confirmCheckIn() async {
    final booking = _booking;
    if (booking == null || _busy) return;
    setState(() => _busy = true);
    try {
      await _repository.updateBookingAttendance(booking.id, 'checked_in');
      final refreshed = await _repository.findBookingByCheckInCode(
        booking.checkInCode,
      );
      if (!mounted) return;
      setState(() => _booking = refreshed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Đã xác nhận khách nhận phòng.', 'Guest check-in confirmed.'),
          ),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const StayZBrandLogo(size: 34, borderRadius: 10),
            const SizedBox(width: 10),
            Expanded(child: Text(tr('Xác nhận nhận phòng', 'Confirm check-in'))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: tr('Mã nhận phòng', 'Check-in code'),
              hintText: 'A1B2C3D4',
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              suffixIcon: IconButton(
                onPressed: _busy ? null : _lookup,
                icon: const Icon(Icons.search),
              ),
            ),
            onSubmitted: _busy ? null : _lookup,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _toggleScanner,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(
              _scanning
                  ? tr('Đóng camera', 'Close camera')
                  : tr('Quét mã QR', 'Scan QR code'),
            ),
          ),
          if (_scanning) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 300,
                child: MobileScanner(
                  controller: _scannerController,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        tr(
                          'Không thể dùng camera. Hãy cấp quyền Camera hoặc nhập mã thủ công.',
                          'Camera unavailable. Allow camera access or enter the code manually.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                    ),
                  ),
                  onDetect: (capture) {
                    if (capture.barcodes.isEmpty) return;
                    final value = capture.barcodes.first.rawValue;
                    if (value != null) _lookup(value);
                  },
                ),
              ),
            ),
          ],
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (booking != null) ...[
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.hotelTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${tr('Khách', 'Guest')}: ${booking.guestName}'),
                    Text('${tr('Phòng', 'Room')}: ${booking.roomName}'),
                    Text(
                      '${tr('Mã', 'Code')}: ${booking.checkInCode}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '${tr('Trạng thái nhận phòng', 'Check-in status')}: ${booking.attendanceStatus}',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            booking.attendanceStatus == 'checked_in' || _busy
                            ? null
                            : _confirmCheckIn,
                        icon: const Icon(Icons.how_to_reg_rounded),
                        label: Text(
                          booking.attendanceStatus == 'checked_in'
                              ? tr('Đã nhận phòng', 'Checked in')
                              : tr(
                                  'Xác nhận đã nhận phòng',
                                  'Confirm check-in',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
