import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/chat/ai_chat_sheet.dart';
import 'package:capstone_mobile/features/detail/presentation/widgets/detail_section_widgets.dart';
import 'package:capstone_mobile/features/home/presentation/widgets/home_section_widgets.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/data/stayz_taxonomy.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:capstone_mobile/shared/widgets/location_map_card.dart';
import 'package:capstone_mobile/shared/widgets/stayz_alert.dart';
import 'package:capstone_mobile/shared/widgets/stayz_network_image.dart';
import 'package:capstone_mobile/shared/widgets/stayz_state_views.dart';
import 'package:flutter/material.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({super.key});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  HotelSummary? _summary;
  bool _isFavorite = false;
  bool _descriptionExpanded = false;
  int _galleryIndex = 0;
  bool _initialized = false;

  Future<List<Review>>? _reviewsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    _summary = args is HotelSummary ? args : null;

    if (_summary != null) {
      // Tai mot lan trong vong doi, khong goi lai trong build().
      _reviewsFuture = ApiStayzRepository.instance.getReviewsByHotelId(_summary!.hotel.id);
      _loadFavoriteState(_summary!.hotel.id);
    }
  }

  Future<void> _loadFavoriteState(String hotelId) async {
    try {
      final ids = await ApiStayzRepository.instance.getFavoriteHotelIds();
      if (mounted) setState(() => _isFavorite = ids.contains(hotelId));
    } catch (_) {
      // Chua dang nhap: mac dinh chua yeu thich.
    }
  }

  Future<void> _toggleFavorite() async {
    final summary = _summary;
    if (summary == null) return;

    final wasFavorite = _isFavorite;
    setState(() => _isFavorite = !wasFavorite);

    try {
      if (wasFavorite) {
        await ApiStayzRepository.instance.removeFavorite(summary.hotel.id);
      } else {
        await ApiStayzRepository.instance.addFavorite(summary.hotel.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wasFavorite ? tr('Đã bỏ khỏi yêu thích.', 'Removed from saved.') : tr('Đã thêm vào yêu thích.', 'Added to saved.'))),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isFavorite = wasFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.isUnauthorized ? tr('Vui lòng đăng nhập để lưu yêu thích.', 'Please sign in to save favorites.') : error.message)),
      );
    }
  }

  /// Viet danh gia THAT, luu vao DB. Chi cho phep khi nguoi dung co don da
  /// hoan tat tai khach san nay (backend cung kiem tra lai dieu kien nay).
  Future<void> _writeReview(HotelSummary summary) async {
    List<BookingSummary> bookings;
    try {
      bookings = await ApiStayzRepository.instance.getBookingSummaries();
    } on ApiException catch (error) {
      if (!mounted) return;
      StayzAlert.show(
        context,
        type: StayzAlertType.error,
        message: error.isUnauthorized ? tr('Vui lòng đăng nhập để đánh giá.', 'Please sign in to review.') : error.message,
      );
      return;
    }

    final completed = bookings
        .where((b) => b.hotel.id == summary.hotel.id && b.booking.normalizedStatus == 'completed')
        .toList();
    if (completed.isEmpty) {
      if (!mounted) return;
      StayzAlert.show(
        context,
        type: StayzAlertType.warning,
        message: tr('Bạn cần hoàn tất một chuyến ở đây mới đánh giá được.', 'You can review only after completing a stay here.'),
      );
      return;
    }

    final booking = completed.first;
    final input = await showModalBottomSheet<_ReviewInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewComposerSheet(hotelName: summary.hotel.name),
    );
    if (input == null || !mounted) return;

    try {
      await ApiStayzRepository.instance.submitReview(
        propertyId: summary.hotel.id,
        bookingId: booking.booking.id,
        rating: input.rating,
        comment: input.comment,
      );
      if (!mounted) return;
      // Tai lai danh sach danh gia de thay danh gia vua gui.
      setState(() => _reviewsFuture = ApiStayzRepository.instance.getReviewsByHotelId(summary.hotel.id));
      StayzAlert.show(context, type: StayzAlertType.success, message: tr('Cảm ơn bạn đã đánh giá!', 'Thanks for your review!'));
    } on ApiException catch (error) {
      if (!mounted) return;
      StayzAlert.show(context, type: StayzAlertType.error, message: error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);
    final summary = _summary;

    // Mo man nay ma khong co du lieu khach san la mot loi, khong phai
    // co hoi de hien mot khach san bia dat.
    if (summary == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(title: Text(tr('Chi tiết khách sạn', 'Hotel details'))),
        body: StayzEmptyView(
          icon: Icons.hotel_outlined,
          title: tr('Thiếu thông tin khách sạn', 'Missing hotel info'),
          message: tr('Không nhận được dữ liệu khách sạn. Hãy quay lại và chọn từ danh sách.', 'No hotel data received. Please go back and pick from the list.'),
          actionLabel: tr('Về trang chủ', 'Go home'),
          onAction: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
        ),
      );
    }

    final hotel = summary.hotel;
    final images = hotel.imageUrls;
    final amenities = hotel.amenityIds;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: DetailBottomBookingBar(summary: summary),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280 * responsive.scale,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.ink,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: DetailCircleButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).maybePop()),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: DetailCircleButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  onTap: _toggleFavorite,
                  semanticLabel: _isFavorite ? tr('Bỏ khỏi yêu thích', 'Remove from saved') : tr('Thêm vào yêu thích', 'Add to saved'),
                ),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HotelGallery(
                images: images,
                index: _galleryIndex,
                onIndexChanged: (value) => setState(() => _galleryIndex = value),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              responsive.horizontalPadding,
              18 * responsive.scale,
              responsive.horizontalPadding,
              24 * responsive.scale,
            ),
            sliver: SliverList.list(
              children: [
                _HotelHeaderCard(summary: summary),
                SizedBox(height: 28 * responsive.scale),

                DetailSectionTitle(title: tr('Giới thiệu', 'About')),
                SizedBox(height: 12 * responsive.scale),
                if (hotel.description.isEmpty)
                  Text(
                    tr('Chưa có mô tả cho nơi lưu trú này.', 'No description for this stay yet.'),
                    style: TextStyle(color: AppTheme.muted, fontSize: 13.5 * responsive.scale),
                  )
                else ...[
                  Text(
                    hotel.description,
                    maxLines: _descriptionExpanded ? null : 4,
                    overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.ink, fontSize: 14 * responsive.scale, height: 1.7),
                  ),
                  if (hotel.description.length > 160)
                    Align(
                      alignment: Alignment.centerLeft,
                      // Truoc day day la mot Text tinh voi chu 'v' thua, khong bam duoc.
                      child: TextButton.icon(
                        onPressed: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                        icon: Icon(_descriptionExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18),
                        label: Text(_descriptionExpanded ? tr('Thu gọn', 'Collapse') : tr('Xem thêm', 'See more')),
                      ),
                    ),
                ],

                SizedBox(height: 20 * responsive.scale),
                SizedBox(
                  width: double.infinity,
                  height: 48 * responsive.scale,
                  child: FilledButton.icon(
                    onPressed: () => showAiChatSheet(context, aiContext: AiChatContext.forHotel(summary)),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(tr('Hỏi AI về khách sạn này', 'Ask AI about this hotel')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accentDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                SizedBox(height: 34 * responsive.scale),
                DetailSectionTitle(title: tr('Tiện ích', 'Amenities')),
                SizedBox(height: 14 * responsive.scale),
                // Doc tu `hotel.amenityIds` that, thay vi 6 tien ich cung
                // (Ho boi / Wifi / Spa / Gym) hien cho moi khach san.
                if (amenities.isEmpty)
                  Text(
                    tr('Khách sạn chưa cập nhật tiện ích.', 'No amenities listed yet.'),
                    style: TextStyle(color: AppTheme.muted, fontSize: 13.5 * responsive.scale),
                  )
                else
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12 * responsive.widthScale,
                    mainAxisSpacing: 12 * responsive.scale,
                    childAspectRatio: 3.2,
                    children: [
                      for (final slug in amenities)
                        AmenityTile(
                          icon: StayzTaxonomy.amenityTerm(slug).icon ?? Icons.check_circle_outline_rounded,
                          label: StayzTaxonomy.amenityTerm(slug).label,
                        ),
                    ],
                  ),

                SizedBox(height: 34 * responsive.scale),
                _ReviewsSection(
                  summary: summary,
                  reviewsFuture: _reviewsFuture,
                  onWriteReview: () => _writeReview(summary),
                ),

                SizedBox(height: 34 * responsive.scale),
                DetailSectionTitle(title: tr('Vị trí', 'Location')),
                SizedBox(height: 14 * responsive.scale),
                // Bam vao ban do de mo Google Maps. Khong co toa do thi mac dinh IUH.
                LocationMapCard(
                  latitude: hotel.latitude,
                  longitude: hotel.longitude,
                  address: hotel.address,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bang anh that cua khach san, vuot ngang duoc.
/// Truoc day day la mot gradient co dinh cong 4 o mau gia va bo dem '+12',
/// trong khi `hotel.imageUrls` co anh that nhung khong duoc dung o dau ca.
class _HotelGallery extends StatefulWidget {
  const _HotelGallery({required this.images, required this.index, required this.onIndexChanged});

  final List<String> images;
  final int index;
  final ValueChanged<int> onIndexChanged;

  @override
  State<_HotelGallery> createState() => _HotelGalleryState();
}

class _HotelGalleryState extends State<_HotelGallery> {
  late final PageController _controller = PageController(initialPage: widget.index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        color: AppTheme.ink,
        child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 42)),
      );
    }

    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          onPageChanged: widget.onIndexChanged,
          itemBuilder: (context, index) => StayZNetworkImage(
            imageUrl: widget.images[index],
            width: size.width,
            height: 280,
            semanticLabel: tr('Ảnh khách sạn ${index + 1}', 'Hotel photo ${index + 1}'),
          ),
        ),
        // Lam toi phan tren de nut back va nut tim luon doc duoc tren moi anh.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent, Colors.black.withValues(alpha: 0.20)],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == widget.index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == widget.index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HotelHeaderCard extends StatelessWidget {
  const _HotelHeaderCard({required this.summary});

  final HotelSummary summary;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return Container(
      padding: EdgeInsets.all(18 * responsive.scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.hotel.name,
            style: TextStyle(color: AppTheme.ink, fontSize: 21 * responsive.scale, fontWeight: FontWeight.w800, height: 1.25),
          ),
          SizedBox(height: 10 * responsive.scale),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 16 * responsive.scale),
              SizedBox(width: 5 * responsive.widthScale),
              Expanded(
                child: Text(
                  '${summary.city.name}, ${summary.city.region}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.muted, fontSize: 12.5 * responsive.scale),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * responsive.scale),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Sao ve dung theo diem, khong con la 5 ngoi sao rong bat chap.
              if (summary.hasRating)
                _RatingRow(rating: summary.rating!, reviewCount: summary.reviewCount)
              else
                Text(
                  tr('Chưa có đánh giá', 'No rating'),
                  style: TextStyle(color: AppTheme.muted, fontSize: 12.5 * responsive.scale),
                ),
              _Pill(
                label: summary.isSoldOut ? tr('Hết phòng', 'Sold out') : tr('${summary.availableRooms} phòng trống', '${summary.availableRooms} rooms left'),
                color: summary.isSoldOut ? AppTheme.danger : AppTheme.success,
              ),
            ],
          ),
          Divider(height: 26 * responsive.scale, color: AppTheme.line),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: tr('từ ', 'from '), style: TextStyle(color: AppTheme.muted, fontSize: 12 * responsive.scale)),
                TextSpan(
                  text: summary.hasPrice ? StayzFormatters.fullVnd(summary.lowestPrice) : tr('Liên hệ', 'Contact'),
                  style: TextStyle(color: AppTheme.accent, fontSize: 20 * responsive.scale, fontWeight: FontWeight.w900),
                ),
                if (summary.hasPrice)
                  TextSpan(text: tr(' / đêm', ' / night'), style: TextStyle(color: AppTheme.muted, fontSize: 12 * responsive.scale)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tr('Đánh giá ${rating.toStringAsFixed(1)} trên 5 từ $reviewCount lượt', 'Rating ${rating.toStringAsFixed(1)} out of 5 from $reviewCount reviews'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i
                  ? Icons.star_rounded
                  : rating >= i - 0.5
                      ? Icons.star_half_rounded
                      : Icons.star_border_rounded,
              color: AppTheme.gold,
              size: 17,
            ),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(color: AppTheme.ink, fontSize: 13.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 4),
          Text('($reviewCount)', style: const TextStyle(color: AppTheme.muted, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.color = AppTheme.primary});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.summary, required this.reviewsFuture, required this.onWriteReview});

  final HotelSummary summary;
  final Future<List<Review>>? reviewsFuture;
  final VoidCallback onWriteReview;

  @override
  Widget build(BuildContext context) {
    final responsive = HomeResponsive.of(context);

    return FutureBuilder<List<Review>>(
      future: reviewsFuture,
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <Review>[];
        final loading = snapshot.connectionState == ConnectionState.waiting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailSectionTitle(
              title: tr('Đánh giá', 'Reviews'),
              // Khong bao gio hien "4.7 /5 (0)": khong co review thi khong co diem.
              trailing: reviews.isEmpty
                  ? null
                  : Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: (reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length).toStringAsFixed(1),
                            style: TextStyle(color: AppTheme.ink, fontSize: 26 * responsive.scale, fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: ' /5 (${reviews.length})',
                            style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 12 * responsive.scale),
            // Nut viet danh gia: kiem tra dieu kien (co don da hoan tat) khi bam.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onWriteReview,
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: Text(tr('Viết đánh giá', 'Write a review')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  minimumSize: const Size(0, 46),
                ),
              ),
            ),
            SizedBox(height: 14 * responsive.scale),
            if (loading)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              Text(
                tr('Không tải được đánh giá.', 'Could not load reviews.'),
                style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale),
              )
            else if (reviews.isEmpty)
              Text(
                tr('Chưa có đánh giá nào cho nơi lưu trú này.', 'No reviews yet.'),
                style: TextStyle(color: AppTheme.muted, fontSize: 13 * responsive.scale),
              )
            else
              ...reviews.take(5).map(
                    (review) => Padding(
                      padding: EdgeInsets.only(bottom: 12 * responsive.scale),
                      child: ReviewCard(
                        name: review.userName.isEmpty ? tr('Khách StayZ', 'StayZ guest') : review.userName,
                        date: StayzFormatters.shortDate(review.createdAt),
                        body: review.comment,
                        rating: review.rating,
                        colors: const [Color(0xFFDDEEFF), Color(0xFF0A4E83)],
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}


/// Ket qua tu man soan danh gia.
class _ReviewInput {
  const _ReviewInput({required this.rating, required this.comment});
  final int rating;
  final String comment;
}

/// Bang soan danh gia: chon so sao (1-5) + nhap nhan xet.
class _ReviewComposerSheet extends StatefulWidget {
  const _ReviewComposerSheet({required this.hotelName});

  final String hotelName;

  @override
  State<_ReviewComposerSheet> createState() => _ReviewComposerSheetState();
}

class _ReviewComposerSheetState extends State<_ReviewComposerSheet> {
  final _controller = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _controller.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Vui lòng nhập nhận xét.', 'Please enter a comment.'))),
      );
      return;
    }
    Navigator.of(context).pop(_ReviewInput(rating: _rating, comment: comment));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: AppTheme.line, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr('Đánh giá ${widget.hotelName}', 'Review ${widget.hotelName}'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.ink, fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => _rating = i),
                      icon: Icon(
                        i <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: AppTheme.gold,
                        size: 38,
                      ),
                      tooltip: tr('$i sao', '$i star'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: tr('Chia sẻ trải nghiệm của bạn...', 'Share your experience...'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: Text(tr('Gửi đánh giá', 'Submit review')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
