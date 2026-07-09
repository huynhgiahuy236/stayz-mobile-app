import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/booking_management/presentation/widgets/booking_management_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
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
    if (summary.booking.status != 'completed') {
      _showMessage('Chi co the danh gia booking da hoan thanh.');
      return;
    }
    if (_rating < 1) {
      _showMessage('Vui long chon so sao.');
      return;
    }
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      _showMessage('Vui long nhap noi dung danh gia.');
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
      _showMessage('Da gui danh gia.');
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.completedBookings, (route) => false);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final args = ModalRoute.of(context)?.settings.arguments as BookingSummaryArgs?;
    final summary = args?.summary;
    final canReview = summary?.booking.status == 'completed';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F4),
      body: SafeArea(
        child: Column(
          children: [
            const BookingManageHeader(title: 'Danh gia', trailing: SizedBox.shrink()),
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
                            gradient: const LinearGradient(colors: [Color(0xFF4D2C19), Color(0xFFB89252)]),
                          ),
                        ),
                        SizedBox(width: 22 * responsive.widthScale),
                        Expanded(
                          child: Text(
                            summary == null
                                ? 'Khong co booking de danh gia'
                                : '${summary.hotel.name}\n${summary.city.name}, ${summary.city.region}',
                            style: TextStyle(color: AppTheme.ink, fontSize: 21 * responsive.scale, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 46 * responsive.scale),
                  if (!canReview)
                    _InfoBox(
                      message: summary == null
                          ? 'Hay mo man danh gia tu mot booking da hoan thanh.'
                          : 'Booking nay chua hoan thanh nen chua the danh gia.',
                    ),
                  SizedBox(height: canReview ? 0 : 28 * responsive.scale),
                  Text(
                    'TRAI NGHIEM CUA BAN THE NAO?',
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
                      fontSize: 18 * responsive.scale,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 34 * responsive.scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        onPressed: canReview ? () => setState(() => _rating = index + 1) : null,
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating ? const Color(0xFFFFB020) : const Color(0xFFD9B8B8),
                          size: 42 * responsive.scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 58 * responsive.scale),
                  Text(
                    'VIET NHAN XET CUA BAN',
                    style: TextStyle(
                      color: const Color(0xFF5A3F3F),
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
                      hintText: 'Chia se cam nhan cua ban ve ky nghi nay...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.neutral200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.neutral200),
                      ),
                    ),
                  ),
                  SizedBox(height: 54 * responsive.scale),
                  SizedBox(
                    height: 58 * responsive.scale,
                    child: FilledButton(
                      onPressed: canReview && !_isSubmitting ? () => _submit(args) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _isSubmitting ? 'Dang gui...' : 'Gui danh gia',
                        style: TextStyle(color: Colors.white, fontSize: 20 * responsive.scale),
                      ),
                    ),
                  ),
                  SizedBox(height: 28 * responsive.scale),
                  Text(
                    'Danh gia chi duoc luu khi booking da hoan thanh.',
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
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFC46B)),
      ),
      child: Text(
        message,
        style: TextStyle(color: const Color(0xFF6B4B00), fontSize: 15 * responsive.scale, height: 1.4),
      ),
    );
  }
}
