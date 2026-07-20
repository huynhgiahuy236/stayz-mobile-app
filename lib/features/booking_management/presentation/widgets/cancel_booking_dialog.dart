import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

/// Hoi lai truoc khi huy don, hien ro so tien hoan theo ma tran.
///
/// Truoc day bam "Hủy lịch" la dieu huong thang sang man ket qua roi goi API
/// huy ngay - lenh huy bay di TRUOC khi nguoi dung kip nhin thay gi.
Future<bool> confirmCancelBooking(
  BuildContext context,
  BookingSummary summary,
) async {
  late final CancellationQuote quote;
  try {
    quote = await ApiStayzRepository.instance.getCancellationQuote(
      summary.booking.id,
    );
  } on ApiException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
    return false;
  }
  if (!context.mounted) return false;
  final rate = quote.refundRate;
  final refund = quote.refundAmount;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppTheme.danger,
        size: 32,
      ),
      title: Text(tr('Hủy đặt phòng?', 'Cancel booking?')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(
              'Bạn sắp hủy đơn tại ${summary.hotel.name}.',
              'You are about to cancel your booking at ${summary.hotel.name}.',
            ),
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (refund > 0 ? AppTheme.success : AppTheme.danger)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        refund > 0
                            ? tr(
                                'Hoàn tiền dự kiến ($rate%)',
                                'Estimated refund ($rate%)',
                              )
                            : tr('Không hoàn tiền', 'Non-refundable'),
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      StayzFormatters.fullVnd(refund),
                      style: TextStyle(
                        color: refund > 0 ? AppTheme.success : AppTheme.danger,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tr(
                    'Thao tác này không thể hoàn tác. Nếu có khoản hoàn, yêu cầu sẽ được xử lý thủ công.',
                    'This action cannot be undone. Any refund request will be processed manually.',
                  ),
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(tr('Giữ đơn', 'Keep booking')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.danger,
            minimumSize: const Size(0, 44),
          ),
          child: Text(tr('Hủy đơn', 'Cancel booking')),
        ),
      ],
    ),
  );

  return result ?? false;
}
