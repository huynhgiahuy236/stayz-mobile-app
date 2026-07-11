import 'dart:async';

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key});

  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage> {
  PayOSPaymentArgs? _args;
  Timer? _poller;
  bool _initialized = false;
  bool _opening = false;
  String _status = 'pending';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final value = ModalRoute.of(context)?.settings.arguments;
    _args = value is PayOSPaymentArgs ? value : null;
    if (_args != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openPayOS());
      _poller = Timer.periodic(const Duration(seconds: 3), (_) => _refreshStatus());
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _openPayOS() async {
    final args = _args;
    if (args == null || _opening) return;
    _opening = true;
    final uri = Uri.tryParse(args.checkoutUrl);
    final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Không mở được trang thanh toán PayOS.', 'Could not open PayOS checkout.'))));
    }
    _opening = false;
  }

  Future<void> _refreshStatus() async {
    final args = _args;
    if (args == null || _status == 'PAID') return;
    try {
      final payment = await ApiStayzRepository.instance.getPayOSPayment(args.summary.booking.id);
      final next = payment?['status']?.toString() ?? 'pending';
      if (!mounted) return;
      setState(() => _status = next);
      if (next == 'PAID') {
        _poller?.cancel();
        final bookings = await ApiStayzRepository.instance.getBookingSummaries();
        final updated = bookings.where((item) => item.booking.id == args.summary.booking.id).firstOrNull ?? args.summary;
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.bookingConfirmation, arguments: BookingSummaryArgs(summary: updated));
      }
    } catch (_) {
      // Poll tiep; loi mang tam thoi khong duoc danh dau thanh toan that bai.
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('Thanh toán', 'Payment'))),
        body: StayzEmptyView(
          icon: Icons.payment_outlined,
          title: tr('Thiếu thông tin thanh toán', 'Missing payment details'),
          message: tr('Vui lòng quay lại và tạo thanh toán mới.', 'Please go back and create a new payment.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            BookingTopBar(title: tr('Thanh toán PayOS', 'PayOS payment'), fallbackRoute: AppRoutes.home),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 96, color: AppTheme.primary),
                    const SizedBox(height: 24),
                    Text(StayzFormatters.fullVnd(args.amount), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.accent)),
                    const SizedBox(height: 12),
                    Text(
                      _status == 'CANCELLED'
                          ? tr('Giao dịch đã bị hủy.', 'The payment was cancelled.')
                          : tr('Đang chờ webhook PayOS xác nhận thanh toán...', 'Waiting for the PayOS webhook to confirm payment...'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _openPayOS,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(tr('Mở trang thanh toán PayOS', 'Open PayOS checkout')),
                    ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _refreshStatus, child: Text(tr('Kiểm tra trạng thái', 'Check status'))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
