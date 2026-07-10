/// Chinh sach thanh toan & hoan tien (mo phong - fake).
///
/// Toan bo la ham thuan de de kiem tra. Dung chung cho man chon phuong an,
/// man QR gia, va hop thoai huy don.
enum PaymentPlan {
  /// Dat coc 30%, con 70% tra tai khach san.
  deposit30,

  /// Tra 100% ngay, duoc giam 10%.
  full100,
}

class PaymentQuote {
  const PaymentQuote({
    required this.plan,
    required this.base,
    required this.discount,
    required this.payNow,
    required this.remaining,
  });

  final PaymentPlan plan;

  /// Gia goc (gia phong x so dem x so phong).
  final num base;

  /// So tien duoc giam (chi co o phuong an tra 100%).
  final num discount;

  /// So tien tra ngay bay gio.
  final num payNow;

  /// So tien con lai tra tai khach san (chi coc 30% moi con).
  final num remaining;
}

class PaymentPolicy {
  const PaymentPolicy._();

  static const int _sevenDaysHours = 168;
  static const int _fortyEightHours = 48;

  /// Tinh so tien phai tra theo phuong an.
  static PaymentQuote quote(PaymentPlan plan, num base) {
    if (plan == PaymentPlan.full100) {
      final discount = (base * 0.10).round();
      return PaymentQuote(plan: plan, base: base, discount: discount, payNow: base - discount, remaining: 0);
    }
    final payNow = (base * 0.30).round();
    return PaymentQuote(plan: plan, base: base, discount: 0, payNow: payNow, remaining: base - payNow);
  }

  /// Ti le hoan (%) theo ma tran: tinh theo so gio tu bay gio den check-in.
  ///
  /// - >= 7 ngay: 100% (ca hai phuong an)
  /// - 48h den duoi 7 ngay: coc 70% / full 90%
  /// - trong vong 48h: coc 50% / full 70%
  /// - da toi/qua check-in (khong den nhan phong): 0%
  static int refundRatePercent(PaymentPlan plan, DateTime checkIn, DateTime now) {
    if (!checkIn.isAfter(now)) return 0; // no-show
    final hours = checkIn.difference(now).inHours;
    final isFull = plan == PaymentPlan.full100;
    if (hours >= _sevenDaysHours) return 100;
    if (hours >= _fortyEightHours) return isFull ? 90 : 70;
    return isFull ? 70 : 50;
  }

  /// So tien hoan = so da thanh toan x ti le.
  static num refundAmount(PaymentPlan plan, num amountPaid, DateTime checkIn, DateTime now) {
    return (amountPaid * refundRatePercent(plan, checkIn, now) / 100).round();
  }

  // --- Anh xa slug (luu xuong backend) ---

  static String slug(PaymentPlan plan) => plan == PaymentPlan.full100 ? 'full_100' : 'deposit_30';

  static PaymentPlan fromSlug(String? value) => value == 'full_100' ? PaymentPlan.full100 : PaymentPlan.deposit30;

  static String planLabel(PaymentPlan plan) => plan == PaymentPlan.full100 ? 'Trả trước 100%' : 'Đặt cọc 30%';

  /// Cac dong chinh sach hien duoi moi phuong an.
  static List<String> policyLines(PaymentPlan plan) {
    if (plan == PaymentPlan.full100) {
      return const [
        'Giảm 10% khi thanh toán toàn bộ.',
        'Hoàn 100% nếu hủy trước 7 ngày.',
        'Hoàn 90% nếu hủy trong khoảng 48 giờ – dưới 7 ngày.',
        'Hoàn 70% nếu hủy trong vòng 48 giờ trước nhận phòng.',
        'Không hoàn nếu không đến nhận phòng.',
      ];
    }
    return const [
      'Thanh toán trước 30%, phần còn lại trả tại khách sạn.',
      'Hoàn 100% nếu hủy trước 7 ngày.',
      'Hoàn 70% nếu hủy trong khoảng 48 giờ – dưới 7 ngày.',
      'Hoàn 50% nếu hủy trong vòng 48 giờ trước nhận phòng.',
      'Không hoàn nếu không đến nhận phòng.',
    ];
  }

  static const String refundDisclaimer =
      'Tiền hoàn (nếu có) sẽ được xử lý về phương thức thanh toán ban đầu theo thời gian quy định của cổng thanh toán/ngân hàng.';
}
