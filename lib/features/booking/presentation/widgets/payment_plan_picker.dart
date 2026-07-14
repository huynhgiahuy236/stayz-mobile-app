import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/data/payment_policy.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

Future<PaymentPlan?> showPaymentPlanPicker(
  BuildContext context, {
  required num totalAmount,
  String? currentPlan,
}) {
  return showModalBottomSheet<PaymentPlan>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Chọn số tiền muốn thanh toán', 'Choose how much to pay'),
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr(
                'Mã PayOS cũ sẽ được thay thế nếu bạn đổi phương án.',
                'The previous PayOS code will be replaced if you change the option.',
              ),
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 18),
            for (final plan in PaymentPlan.values) ...[
              _PaymentPlanChoice(
                plan: plan,
                totalAmount: totalAmount,
                selected: PaymentPolicy.slug(plan) == currentPlan,
                onTap: () => Navigator.of(context).pop(plan),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    ),
  );
}

class _PaymentPlanChoice extends StatelessWidget {
  const _PaymentPlanChoice({
    required this.plan,
    required this.totalAmount,
    required this.selected,
    required this.onTap,
  });

  final PaymentPlan plan;
  final num totalAmount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final quote = PaymentPolicy.quote(plan, totalAmount);
    final deposit = plan == PaymentPlan.deposit30;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: deposit ? AppTheme.depositBorder : AppTheme.success,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: deposit ? AppTheme.depositText : AppTheme.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PaymentPolicy.planLabel(plan),
                      style: TextStyle(
                        color: deposit
                            ? AppTheme.depositText
                            : AppTheme.success,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (quote.remaining > 0)
                      Text(
                        tr(
                          'Còn ${StayzFormatters.fullVnd(quote.remaining)} trả tại khách sạn',
                          '${StayzFormatters.fullVnd(quote.remaining)} due at the property',
                        ),
                        style: const TextStyle(color: AppTheme.muted),
                      )
                    else
                      Text(
                        tr('Đã áp dụng giảm 10%', '10% discount applied'),
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                  ],
                ),
              ),
              Text(
                StayzFormatters.fullVnd(quote.payNow),
                style: TextStyle(
                  color: deposit ? AppTheme.depositText : AppTheme.success,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
