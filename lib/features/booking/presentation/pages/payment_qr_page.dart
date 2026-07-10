import 'dart:async';
import 'dart:math' as math;

import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking/presentation/widgets/booking_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/payment_policy.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

/// Man QR thanh toan MO PHONG.
///
/// Hien QR (gia, khong quet duoc) + so tien + noi dung, dem nguoc 10 giay roi
/// tu dong bao "thanh toan thanh cong" va tao booking. Khong co nut huy trong
/// luc dem, dung yeu cau cua nguoi dung.
class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key});

  static const _accountName = 'Huỳnh Gia Huy';
  static const _accountAlias = 'HUYNHGIAHUY';
  static const _bankBranch = 'VietinBank CN HOI AN - HOI SO';
  static const _countdownSeconds = 10;

  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage> {
  BookingDraft? _draft;
  bool _initialized = false;

  int _secondsLeft = PaymentQrPage._countdownSeconds;
  Timer? _timer;
  bool _paying = false;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    _draft = args is BookingDraft ? args : null;
    if (_draft != null) _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        _completePayment();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  /// Sau 10s: coi nhu da nhan duoc tien (gia) -> tao booking that -> man xac nhan.
  Future<void> _completePayment() async {
    if (_paying || _done) return;
    setState(() => _paying = true);

    final draft = _draft!;
    try {
      final summary = await ApiStayzRepository.instance.createBooking(draft);
      if (!mounted) return;
      _done = true;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.bookingConfirmation,
        arguments: summary == null ? draft : BookingSummaryArgs(summary: summary),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final draft = _draft;

    if (draft == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(title: const Text('Thanh toán')),
        body: StayzEmptyView(
          icon: Icons.qr_code_2_rounded,
          title: 'Thiếu thông tin thanh toán',
          message: 'Hãy chọn lại phương án thanh toán.',
          actionLabel: 'Về trang chủ',
          onAction: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        ),
      );
    }

    final amount = draft.amountPaid ?? draft.totalAmount;
    final transferContent = 'STAYZ ${draft.hotel.hotel.name.split(' ').first.toUpperCase()}';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingTopBar(title: 'Thanh toán', fallbackRoute: AppRoutes.home),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  8 * responsive.scale,
                  responsive.horizontalPadding,
                  28 * responsive.scale,
                ),
                children: [
                  // So tien can chuyen
                  Text(
                    StayzFormatters.fullVnd(amount),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.accent, fontSize: 30 * responsive.scale, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4 * responsive.scale),
                  Text(
                    PaymentPolicy.planLabel(PaymentPolicy.fromSlug(draft.paymentPlan)),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 20 * responsive.scale),

                  // The QR kieu VietQR
                  _QrCard(
                    accountName: PaymentQrPage._accountName,
                    alias: PaymentQrPage._accountAlias,
                    branch: PaymentQrPage._bankBranch,
                    seed: transferContent.hashCode ^ amount.toInt(),
                  ),

                  SizedBox(height: 18 * responsive.scale),
                  _InfoRow(label: 'Nội dung chuyển khoản', value: transferContent),
                  _InfoRow(label: 'Số tiền', value: StayzFormatters.fullVnd(amount)),
                  if (draft.remainingAtHotel != null && draft.remainingAtHotel! > 0)
                    _InfoRow(label: 'Trả tại khách sạn', value: StayzFormatters.fullVnd(draft.remainingAtHotel!)),

                  SizedBox(height: 24 * responsive.scale),

                  // Trang thai cho / dang xu ly
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * responsive.scale, vertical: 16 * responsive.scale),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySoft.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppTheme.primary),
                        ),
                        SizedBox(width: 14 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            _paying
                                ? 'Đã nhận thanh toán, đang tạo đơn...'
                                : 'Đang chờ thanh toán... tự xác nhận sau $_secondsLeft giây',
                            style: TextStyle(color: AppTheme.primaryDark, fontSize: 13.5 * responsive.scale, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * responsive.scale),
                  Text(
                    'Mở app ngân hàng và quét mã để chuyển khoản. Đây là thanh toán mô phỏng cho mục đích demo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted, fontSize: 12 * responsive.scale, height: 1.5),
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

class _QrCard extends StatelessWidget {
  const _QrCard({required this.accountName, required this.alias, required this.branch, required this.seed});

  final String accountName;
  final String alias;
  final String branch;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.line),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            // Hang logo gia lap (VietinBank · napas247 · VietQR)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _BankTag(text: 'VietinBank', color: Color(0xFF0072BC)),
                _BankTag(text: 'napas247', color: Color(0xFFE2231A)),
                _BankTag(text: 'VietQR', color: Color(0xFF00844B)),
              ],
            ),
            const SizedBox(height: 16),
            // Ma QR gia
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.line),
              ),
              child: SizedBox(
                width: 190,
                height: 190,
                child: CustomPaint(painter: _FakeQrPainter(seed: seed)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              accountName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.3),
            ),
            const SizedBox(height: 4),
            Text('Alias $alias', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              branch,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankTag extends StatelessWidget {
  const _BankTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: -0.3),
    );
  }
}

/// Ve mot hoa tiet giong ma QR (khong ma hoa gi that) de trong giong that.
class _FakeQrPainter extends CustomPainter {
  const _FakeQrPainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const modules = 25;
    final cell = size.width / modules;
    final paint = Paint()..color = AppTheme.ink;
    final rng = math.Random(seed);

    bool isFinder(int r, int c) {
      bool inBox(int r0, int c0) => r >= r0 && r < r0 + 7 && c >= c0 && c < c0 + 7;
      return inBox(0, 0) || inBox(0, modules - 7) || inBox(modules - 7, 0);
    }

    void drawFinder(double x, double y) {
      final outer = Paint()..color = AppTheme.ink;
      canvas.drawRect(Rect.fromLTWH(x, y, cell * 7, cell * 7), outer);
      canvas.drawRect(Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3), outer);
    }

    // Cac o ngau nhien (tru vung 3 finder pattern)
    for (var r = 0; r < modules; r++) {
      for (var c = 0; c < modules; c++) {
        if (isFinder(r, c)) continue;
        if (rng.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), paint);
        }
      }
    }

    // 3 o dinh huong goc
    drawFinder(0, 0);
    drawFinder((modules - 7) * cell, 0);
    drawFinder(0, (modules - 7) * cell);
  }

  @override
  bool shouldRepaint(covariant _FakeQrPainter oldDelegate) => oldDelegate.seed != seed;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 13))),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(color: AppTheme.ink, fontSize: 13.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
