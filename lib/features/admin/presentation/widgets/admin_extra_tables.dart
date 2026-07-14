import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_shell.dart';
import 'package:capstone_mobile/features/admin/presentation/widgets/admin_tables.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminReviewsTable extends StatelessWidget {
  const AdminReviewsTable({
    required this.reviews,
    required this.onDelete,
    super.key,
  });
  final List<AdminReview> reviews;
  final ValueChanged<AdminReview> onDelete;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return AdminEmptyState(
        icon: Icons.rate_review_outlined,
        title: tr('Không tìm thấy đánh giá', 'No reviews found'),
      );
    }
    return TableShell(
      child: AdminDataTable(
        columns: [
          tr('Người đánh giá', 'Reviewer'),
          tr('Cơ sở lưu trú', 'Property'),
          tr('Điểm', 'Rating'),
          tr('Nội dung', 'Comment'),
          tr('Ngày tạo', 'Created'),
          tr('Thao tác', 'Actions'),
        ],
        rows: [
          for (final review in reviews)
            DataRow(
              cells: [
                DataCell(CellText(review.userName)),
                DataCell(CellText(review.hotelTitle)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppTheme.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${review.rating}',
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(CellText(review.comment)),
                DataCell(Text(StayzFormatters.shortDate(review.createdAt))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SmallAction(
                        icon: Icons.delete_outline_rounded,
                        tooltip: tr('Xoá', 'Delete'),
                        color: AppTheme.danger,
                        onTap: () => onDelete(review),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AdminPaymentsTable extends StatelessWidget {
  const AdminPaymentsTable({
    required this.payments,
    required this.onCancel,
    super.key,
  });
  final List<AdminPayment> payments;
  final ValueChanged<AdminPayment> onCancel;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return AdminEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: tr('Không tìm thấy giao dịch', 'No transactions found'),
      );
    }
    return TableShell(
      child: AdminDataTable(
        columns: [
          tr('Mã đơn PayOS', 'PayOS order'),
          tr('Khách hàng', 'Customer'),
          tr('Cơ sở lưu trú', 'Property'),
          tr('Số tiền', 'Amount'),
          tr('Trạng thái', 'Status'),
          tr('Ngày tạo', 'Created'),
          tr('Thao tác', 'Actions'),
        ],
        rows: [
          for (final payment in payments)
            DataRow(
              cells: [
                DataCell(
                  Text(
                    '#${payment.orderCode}',
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                DataCell(CellText(payment.userName)),
                DataCell(CellText(payment.hotelTitle)),
                DataCell(
                  Text(
                    StayzFormatters.fullVnd(payment.amount),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(StatusPill(status: payment.status.toLowerCase())),
                DataCell(Text(StayzFormatters.shortDate(payment.createdAt))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SmallAction(
                        icon: Icons.open_in_new_rounded,
                        tooltip: tr('Mở liên kết PayOS', 'Open PayOS link'),
                        enabled: payment.checkoutUrl.isNotEmpty,
                        onTap: () => launchUrl(
                          Uri.parse(payment.checkoutUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _SmallAction(
                        icon: Icons.cancel_outlined,
                        tooltip: tr('Huỷ giao dịch', 'Cancel transaction'),
                        enabled: payment.status.toLowerCase() == 'pending',
                        color: AppTheme.danger,
                        onTap: () => onCancel(payment),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
    this.enabled = true,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  final bool enabled;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 33,
    height: 33,
    child: IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      color: color ?? AppTheme.muted,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
