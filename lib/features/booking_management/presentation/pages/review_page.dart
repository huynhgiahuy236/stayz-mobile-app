import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(BookingSummaryArgs? args) async {
    final summary = args?.summary;
    if (summary == null) return;
    if (!summary.booking.isCompleted) {
      _showMessage(
        tr(
          'Chỉ có thể đánh giá booking đã hoàn thành.',
          'Only completed bookings can be reviewed.',
        ),
      );
      return;
    }
    if (_rating < 1) {
      _showMessage(tr('Vui lòng chọn số sao.', 'Please select a star rating.'));
      return;
    }
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      _showMessage(
        tr('Vui lòng nhập nội dung đánh giá.', 'Please enter your review.'),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiStayzRepository.instance.submitReview(
        propertyId: summary.hotel.id,
        bookingId: summary.booking.id,
        rating: _rating,
        comment: comment,
      );
      if (!mounted) return;
      _showMessage(tr('Đã gửi đánh giá.', 'Review submitted.'));
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.completedBookings, (route) => false);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;
    final canReview = summary?.booking.isCompleted == true;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            BookingManageHeader(
              title: tr('Đánh giá', 'Review'),
              trailing: const SizedBox.shrink(),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  responsive.horizontalPadding,
                  54 * responsive.scale,
                  responsive.horizontalPadding,
                  34 * responsive.scale,
                ),
                children: [
                  Container(
                    padding: EdgeInsets.all(18 * responsive.scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutral200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 90 * responsive.scale,
                          height: 90 * responsive.scale,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryDark, AppTheme.primary],
                            ),
                          ),
                        ),
                        SizedBox(width: 22 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            summary == null
                                ? tr(
                                    'Không có booking để đánh giá',
                                    'No booking to review',
                                  )
                                : '${summary.hotel.name}\n${summary.city.name}, ${summary.city.region}',
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 21 * responsive.scale,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  if (!canReview)
                    _InfoBox(
                      message: summary == null
                          ? tr(
                              'Hãy mở màn đánh giá từ một booking đã hoàn thành.',
                              'Open this page from a completed booking.',
                            )
                          : tr(
                              'Booking này chưa hoàn thành nên chưa thể đánh giá.',
                              'This booking is not complete and cannot be reviewed yet.',
                            ),
                    ),
                  SizedBox(height: canReview ? 0 : 20 * responsive.scale),
                  Text(
                    tr(
                      'TRẢI NGHIỆM CỦA BẠN THẾ NÀO?',
                      'HOW WAS YOUR EXPERIENCE?',
                    ),
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 18 * responsive.scale,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 24 * responsive.scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        onPressed: canReview
                            ? () => setState(() => _rating = index + 1)
                            : null,
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating
                              ? AppTheme.gold
                              : AppTheme.line,
                          size: 42 * responsive.scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32 * responsive.scale),
                  Text(
                    tr('VIẾT NHẬN XÉT CỦA BẠN', 'WRITE YOUR REVIEW'),
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 18 * responsive.scale,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 18 * responsive.scale),
                  TextField(
                    controller: _commentController,
                    enabled: canReview && !_isSubmitting,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: tr(
                        'Chia sẻ cảm nhận của bạn về kỳ nghỉ này...',
                        'Share your thoughts about this stay...',
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.neutral200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.neutral200,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: canReview && !_isSubmitting
                          ? () => _submit(args)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isSubmitting
                            ? tr('Đang gửi...', 'Submitting...')
                            : tr('Gửi đánh giá', 'Submit review'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20 * responsive.scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20 * responsive.scale),
                  Text(
                    tr(
                      'Đánh giá chỉ được lưu khi booking đã hoàn thành.',
                      'Reviews are accepted only for completed bookings.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.neutral500,
                      fontSize: 18 * responsive.scale,
                      fontStyle: FontStyle.italic,
                      height: 1.45,
                    ),
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

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(16 * responsive.scale),
      decoration: BoxDecoration(
        color: AppTheme.warningSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.notificationPendingBorder),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppTheme.warning,
          fontSize: 15 * responsive.scale,
          height: 1.4,
        ),
      ),
    );
  }
}
