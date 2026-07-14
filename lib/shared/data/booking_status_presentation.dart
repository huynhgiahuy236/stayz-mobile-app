import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:flutter/material.dart';

class BookingStatusPresentation {
  const BookingStatusPresentation({
    required this.label,
    required this.background,
    required this.foreground,
    required this.description,
  });

  final String label;
  final Color background;
  final Color foreground;
  final String description;
}

BookingStatusPresentation bookingStatusPresentation(Booking booking) {
  if (booking.normalizedStatus == 'cancelled') {
    return BookingStatusPresentation(
      label: booking.cancellationReason == 'no_show'
          ? tr('Đã hủy – Không đến nhận phòng', 'Cancelled – No-show')
          : tr('Đã hủy', 'Cancelled'),
      background: AppTheme.notificationDangerBorder.withValues(alpha: 0.28),
      foreground: AppTheme.notificationDangerText,
      description: booking.cancellationReason == 'no_show'
          ? tr(
              'Khách không đến nhận phòng; booking đã hủy và không hoàn tiền.',
              'The guest did not check in; the booking was cancelled with no refund.',
            )
          : tr(
              'Booking đã hủy. Xem chi tiết để biết số tiền được hoàn.',
              'The booking was cancelled. See details for the refund amount.',
            ),
    );
  }
  if (booking.normalizedStatus == 'completed') {
    return BookingStatusPresentation(
      label: tr('Chuyến đi đã hoàn tất', 'Trip completed'),
      background: AppTheme.notificationSuccessBorder.withValues(alpha: 0.3),
      foreground: AppTheme.notificationSuccessText,
      description: tr(
        'Khách đã lưu trú và chuyến đi đã kết thúc.',
        'The guest checked in and the stay has ended.',
      ),
    );
  }
  if (booking.isPaymentExpired) {
    return BookingStatusPresentation(
      label: tr('Thanh toán đã hết hạn', 'Payment expired'),
      background: AppTheme.notificationDangerBorder.withValues(alpha: 0.28),
      foreground: AppTheme.notificationDangerText,
      description: tr(
        'Thời hạn thanh toán đã kết thúc; cần tạo lại thanh toán.',
        'The payment window expired; payment must be created again.',
      ),
    );
  }
  if (booking.isPaymentPending) {
    return BookingStatusPresentation(
      label: booking.isDepositPayment
          ? tr('Chờ thanh toán cọc 30%', 'Awaiting 30% deposit')
          : tr('Chờ thanh toán toàn bộ', 'Awaiting full payment'),
      background: AppTheme.notificationPendingBorder.withValues(alpha: 0.3),
      foreground: AppTheme.notificationPendingText,
      description: booking.isDepositPayment
          ? tr(
              'Cần thanh toán cọc 30% để giữ phòng.',
              'Pay the 30% deposit to hold the room.',
            )
          : tr(
              'Cần thanh toán đủ để xác nhận đặt phòng.',
              'Full payment is required to confirm the booking.',
            ),
    );
  }
  if (booking.attendanceStatus == 'checked_in') {
    return BookingStatusPresentation(
      label: tr('Đã nhận phòng', 'Checked in'),
      background: AppTheme.notificationConfirmedBorder.withValues(alpha: 0.32),
      foreground: AppTheme.notificationConfirmedText,
      description: tr(
        'Admin đã xác nhận khách có đến nhận phòng.',
        'An admin confirmed that the guest checked in.',
      ),
    );
  }
  if (booking.attendanceStatus == 'no_show') {
    return BookingStatusPresentation(
      label: tr('Không đến nhận phòng', 'No-show'),
      background: AppTheme.notificationDangerBorder.withValues(alpha: 0.3),
      foreground: AppTheme.notificationDangerText,
      description: tr(
        'Admin ghi nhận khách không đến; booking sẽ hủy sau checkout.',
        'An admin recorded a no-show; the booking will be cancelled after checkout.',
      ),
    );
  }
  if (booking.isDepositPayment && booking.hasRecordedPayment) {
    return BookingStatusPresentation(
      label: tr('Đã đặt cọc 30%', '30% deposit paid'),
      background: AppTheme.depositBorder.withValues(alpha: 0.32),
      foreground: AppTheme.depositText,
      description: tr(
        'Đã thanh toán 30%; 70% còn lại thanh toán tại khách sạn.',
        '30% has been paid; the remaining 70% is due at the property.',
      ),
    );
  }
  if (booking.hasRecordedPayment) {
    return BookingStatusPresentation(
      label: tr('Đã thanh toán toàn bộ', 'Paid in full'),
      background: AppTheme.notificationSuccessBorder.withValues(alpha: 0.3),
      foreground: AppTheme.notificationSuccessText,
      description: tr(
        'Booking đã được thanh toán đầy đủ 100%.',
        'The booking has been paid in full.',
      ),
    );
  }
  return BookingStatusPresentation(
    label: tr('Đã xác nhận – Chờ nhận phòng', 'Confirmed – Awaiting check-in'),
    background: Colors.white,
    foreground: AppTheme.ink,
    description: tr(
      'Đặt phòng đã xác nhận và đang chờ ngày nhận phòng.',
      'The booking is confirmed and awaiting check-in.',
    ),
  );
}

String bookingAttendanceLabel(Booking booking) =>
    switch (booking.attendanceStatus) {
      'checked_in' => tr('Đã nhận phòng', 'Checked in'),
      'no_show' => tr('Không đến nhận phòng', 'No-show'),
      _ => tr(
        'Chờ admin xác nhận nhận phòng',
        'Awaiting check-in confirmation',
      ),
    };
