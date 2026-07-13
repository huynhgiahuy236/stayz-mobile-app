import 'dart:async';
import 'dart:ui' as ui;

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key});

  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage>
    with WidgetsBindingObserver {
  final _qrKey = GlobalKey();
  PayOSPaymentArgs? _args;
  Timer? _poller;
  Timer? _clock;
  bool _initialized = false;
  bool _opening = false;
  bool _sharing = false;
  bool _checking = false;
  String _status = 'pending';

  DateTime? get _expiresAt => _args?.expiresAt;

  Duration get _remaining {
    final expiresAt = _expiresAt;
    if (expiresAt == null) return Duration.zero;
    final value = expiresAt.difference(DateTime.now());
    return value.isNegative ? Duration.zero : value;
  }

  bool get _expired =>
      _status != 'PAID' && _expiresAt != null && _remaining == Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    final value = ModalRoute.of(context)?.settings.arguments;
    _args = value is PayOSPaymentArgs ? value : null;
    if (_args != null) {
      _poller = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _refreshStatus(),
      );
      _clock = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_expired && _status == 'pending') _status = 'EXPIRED';
        });
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus(showFailure: false);
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    _clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _openBankApp() async {
    final args = _args;
    if (args == null || _opening || _expired) return;
    setState(() => _opening = true);
    final uri = Uri.tryParse(args.checkoutUrl);
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage(
        tr(
          'Không mở được ứng dụng ngân hàng. Bạn vẫn có thể lưu hoặc quét mã QR.',
          'Could not open a banking app. You can still save or scan the QR code.',
        ),
      );
    }
    if (mounted) setState(() => _opening = false);
  }

  Future<void> _shareQr() async {
    final args = _args;
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (args == null || boundary == null || _sharing) return;
    setState(() => _sharing = true);
    try {
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not encode QR image.');
      await Share.shareXFiles(
        [
          XFile.fromData(
            data.buffer.asUint8List(),
            mimeType: 'image/png',
            name: 'stayz-vietqr.png',
          ),
        ],
        text: tr(
          'Thanh toán StayZ ${StayzFormatters.fullVnd(args.amount)}. Nội dung: ${args.transferDescription}',
          'StayZ payment ${StayzFormatters.fullVnd(args.amount)}. Reference: ${args.transferDescription}',
        ),
      );
    } catch (_) {
      if (mounted)
        _showMessage(
          tr(
            'Không thể chia sẻ mã QR lúc này.',
            'Could not share the QR code right now.',
          ),
        );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _refreshStatus({bool showFailure = true}) async {
    final args = _args;
    if (args == null || _status == 'PAID' || _checking) return;
    if (mounted) setState(() => _checking = true);
    try {
      final payment = await ApiStayzRepository.instance.getPayOSPayment(
        args.summary.booking.id,
      );
      final next = payment?['status']?.toString() ?? 'pending';
      if (!mounted) return;
      setState(() => _status = next);
      if (next == 'PAID') {
        _poller?.cancel();
        final bookings = await ApiStayzRepository.instance
            .getBookingSummaries();
        final updated =
            bookings
                .where((item) => item.booking.id == args.summary.booking.id)
                .firstOrNull ??
            args.summary;
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.bookingConfirmation,
          arguments: BookingSummaryArgs(summary: updated),
        );
      }
    } catch (_) {
      if (mounted && showFailure)
        _showMessage(
          tr(
            'Chưa thể kiểm tra trạng thái. StayZ sẽ tiếp tục thử lại.',
            'Could not check yet. StayZ will keep trying.',
          ),
        );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<bool> _confirmLeavePayment() async {
    if (_status == 'PAID' || _status == 'CANCELLED' || _expired) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              tr('Thanh toán chưa hoàn tất', 'Payment not completed'),
            ),
            content: Text(
              tr(
                'Booking vẫn được giữ ở trạng thái chờ thanh toán. Bạn có thể tiếp tục thanh toán trong mục Đặt phòng trước khi mã hết hạn.',
                'Your booking will remain pending. You can continue payment from Trips before the code expires.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(tr('Ở lại', 'Stay')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(tr('Thanh toán sau', 'Pay later')),
              ),
            ],
          ),
        ) ??
        false;
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
          message: tr(
            'Vui lòng quay lại và tạo thanh toán mới.',
            'Please go back and create a new payment.',
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeavePayment() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(
          child: Column(
            children: [
            BookingTopBar(
              title: tr('Thanh toán PayOS', 'PayOS payment'),
              fallbackRoute: AppRoutes.home,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/payos.jpg',
                      width: 132,
                      height: 54,
                      fit: BoxFit.contain,
                      semanticLabel: 'PayOS',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    tr('Quét VietQR để thanh toán', 'Scan VietQR to pay'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      'Mã được tạo riêng cho booking này và tự hết hạn theo PayOS.',
                      'This code is generated for this booking and expires with PayOS.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.muted, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  _PaymentExpiryBanner(
                    remaining: _remaining,
                    expired: _expired,
                  ),
                  const SizedBox(height: 18),
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.line),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        children: [
                          if (args.qrImageUrl.isNotEmpty)
                            Image.network(
                              args.qrImageUrl,
                              width: 270,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.qr_code_2_rounded,
                                size: 180,
                                color: AppTheme.muted,
                              ),
                            )
                          else
                            QrImageView(
                              data: args.qrCode,
                              version: QrVersions.auto,
                              size: 230,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppTheme.ink,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppTheme.ink,
                              ),
                            ),
                          const SizedBox(height: 14),
                          Text(
                            StayzFormatters.fullVnd(args.amount),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.accent,
                            ),
                          ),
                          if (args.transferDescription.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              args.transferDescription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (args.accountName.isNotEmpty ||
                      args.accountNumber.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _BankInfo(args: args),
                  ],
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _opening || _expired ? null : _openBankApp,
                    icon: const Icon(Icons.account_balance_rounded),
                    label: Text(
                      _opening
                          ? tr('Đang mở...', 'Opening...')
                          : tr('Mở trang thanh toán', 'Open payment page'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _sharing || _expired ? null : _shareQr,
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(
                      _sharing
                          ? tr('Đang chuẩn bị...', 'Preparing...')
                          : tr('Lưu / chia sẻ mã QR', 'Save / share QR'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _checking ? null : _refreshStatus,
                    icon: const Icon(Icons.sync_rounded),
                    label: Text(
                      _checking
                          ? tr('Đang kiểm tra...', 'Checking...')
                          : tr('Kiểm tra thanh toán', 'Check payment'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _expired
                        ? tr(
                            'Mã thanh toán đã hết hạn. Hãy quay lại mục Đặt phòng để tạo mã mới.',
                            'This payment code has expired. Return to Trips to create a new one.',
                          )
                        : _status == 'CANCELLED'
                        ? tr(
                            'Giao dịch đã bị hủy.',
                            'The payment was cancelled.',
                          )
                        : tr(
                            'StayZ chỉ xác nhận sau khi webhook PayOS báo đã thanh toán.',
                            'StayZ confirms only after a valid PayOS webhook reports payment.',
                          ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _status == 'CANCELLED' || _expired
                          ? AppTheme.danger
                          : AppTheme.muted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankInfo extends StatelessWidget {
  const _BankInfo({required this.args});
  final PayOSPaymentArgs args;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          if (args.accountName.isNotEmpty)
            _line(tr('Chủ tài khoản', 'Account name'), args.accountName),
          if (args.accountNumber.isNotEmpty)
            _line(tr('Số tài khoản', 'Account number'), args.accountNumber),
          if (args.bankBin.isNotEmpty) _line('BIN', args.bankBin),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppTheme.muted)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PaymentExpiryBanner extends StatelessWidget {
  const _PaymentExpiryBanner({required this.remaining, required this.expired});

  final Duration remaining;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Semantics(
      liveRegion: true,
      label: expired
          ? tr('Mã thanh toán đã hết hạn', 'Payment code expired')
          : tr(
              'Còn $minutes phút $seconds giây',
              '$minutes minutes $seconds seconds remaining',
            ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: expired
              ? AppTheme.danger.withValues(alpha: 0.10)
              : const Color(0xFFFFE8B0).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              expired ? Icons.timer_off_outlined : Icons.timer_outlined,
              color: expired ? AppTheme.danger : AppTheme.ink,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                expired
                    ? tr('Mã thanh toán đã hết hạn', 'Payment code expired')
                    : tr(
                        'Thời gian còn lại: $minutes:$seconds',
                        'Time remaining: $minutes:$seconds',
                      ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: expired ? AppTheme.danger : AppTheme.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
