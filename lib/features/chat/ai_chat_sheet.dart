import 'package:capstone_mobile/app/routes/app_routes.dart';
import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
import 'package:capstone_mobile/shared/repositories/stayz_repository.dart';
import 'package:flutter/material.dart';

class AiChatContext {
  const AiChatContext({
    this.propertyId,
    this.roomId,
    this.initialMessage,
    this.checkIn,
    this.checkOut,
    this.guests,
  });

  factory AiChatContext.forHotel(HotelSummary summary) {
    return AiChatContext(
      propertyId: summary.hotel.id,
      initialMessage: 'Hỏi AI về khách sạn ${summary.hotel.name}',
    );
  }

  factory AiChatContext.forRoom({
    required HotelSummary hotel,
    required Room room,
    RoomSelectionArgs? args,
  }) {
    final guests = args == null ? null : args.adults + args.children;
    return AiChatContext(
      propertyId: hotel.hotel.id,
      roomId: room.id,
      checkIn: args?.checkInDate,
      checkOut: args?.checkOutDate,
      guests: guests,
      initialMessage: 'Nhờ AI chọn phòng phù hợp tại ${hotel.hotel.name}',
    );
  }

  final String? propertyId;
  final String? roomId;
  final String? initialMessage;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;
}

class AiChatMessage {
  const AiChatMessage({
    required this.content,
    required this.fromUser,
    this.suggestions = const <AiSuggestion>[],
  });

  final String content;
  final bool fromUser;
  final List<AiSuggestion> suggestions;
}

/// Mot goi y that tu `/ai/chat`: chi giu dung du lieu backend tra ve,
/// khong tu suy dien gia, rating hay tinh trang phong.
class AiSuggestion {
  const AiSuggestion({
    required this.propertyId,
    required this.propertyTitle,
    required this.citySlug,
    this.roomId,
    this.roomName,
    this.pricePerNight,
    this.totalPrice,
    this.capacity,
    this.availableRooms,
    this.rating,
    this.reviewCount = 0,
  });

  final String propertyId;
  final String propertyTitle;
  final String citySlug;
  final String? roomId;
  final String? roomName;
  final num? pricePerNight;
  final num? totalPrice;
  final int? capacity;

  /// null = backend chua the xac nhan (thieu ngay nhan/tra phong).
  final int? availableRooms;

  /// Diem trung binh tu review that; null khi chua co review.
  final double? rating;
  final int reviewCount;

  static AiSuggestion? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final property = json['property'];
    final room = json['room'];
    if (property is! Map<String, dynamic>) return null;

    final propertyId = property['id']?.toString() ?? '';
    final title = property['title']?.toString() ?? '';
    if (propertyId.isEmpty || title.isEmpty) return null;

    num? asNum(dynamic value) => value is num ? value : num.tryParse(value?.toString() ?? '');
    int? asInt(dynamic value) => value is num ? value.round() : int.tryParse(value?.toString() ?? '');

    final roomMap = room is Map<String, dynamic> ? room : const <String, dynamic>{};
    return AiSuggestion(
      propertyId: propertyId,
      propertyTitle: title,
      citySlug: property['city']?.toString() ?? '',
      roomId: roomMap['id']?.toString(),
      roomName: roomMap['name']?.toString(),
      pricePerNight: asNum(roomMap['price_per_night']) ?? asNum(property['base_price']),
      totalPrice: asNum(roomMap['total_price']),
      capacity: asInt(roomMap['capacity']),
      availableRooms: roomMap['available_rooms'] == null ? null : asInt(roomMap['available_rooms']),
      rating: asNum(property['rating'])?.toDouble(),
      reviewCount: asInt(property['review_count']) ?? 0,
    );
  }

  static List<AiSuggestion> listFrom(dynamic value) {
    if (value is! List) return const <AiSuggestion>[];
    return value.map(tryParse).whereType<AiSuggestion>().toList(growable: false);
  }
}

Future<void> showAiChatSheet(
  BuildContext context, {
  AiChatContext aiContext = const AiChatContext(),
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AiChatSheet(aiContext: aiContext),
  );
}

class _AiChatSheet extends StatefulWidget {
  const _AiChatSheet({required this.aiContext});

  final AiChatContext aiContext;

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final _controller = TextEditingController();
  final _messages = <AiChatMessage>[
    const AiChatMessage(
      content: 'Mình có thể gợi ý khách sạn, chọn phòng, tính giá và kiểm tra phòng trống từ dữ liệu StayZ.',
      fromUser: false,
    ),
  ];
  String? _conversationId;
  bool _sending = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    final initialMessage = widget.aiContext.initialMessage;
    if (initialMessage != null && initialMessage.isNotEmpty) {
      _controller.text = initialMessage;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.add(AiChatMessage(content: text, fromUser: true));
      _controller.clear();
    });

    try {
      final token = await AuthService.instance.accessToken();
      if (token == null) {
        throw const ApiException('Vui lòng đăng nhập để lưu lịch sử chat AI.', statusCode: 401);
      }

      final data = await const ApiService().post(
        '/ai/chat',
        bearerToken: token,
        body: {
          'message': text,
          if (widget.aiContext.checkIn != null) 'checkIn': widget.aiContext.checkIn!.toIso8601String(),
          if (widget.aiContext.checkOut != null) 'checkOut': widget.aiContext.checkOut!.toIso8601String(),
          if (widget.aiContext.guests != null) 'guests': widget.aiContext.guests,
          if (widget.aiContext.propertyId != null) 'propertyId': widget.aiContext.propertyId,
          if (widget.aiContext.roomId != null) 'roomId': widget.aiContext.roomId,
          if (_conversationId != null) 'conversationId': _conversationId,
        },
      );

      if (data is! Map<String, dynamic>) {
        throw const ApiException('Phản hồi AI không hợp lệ.');
      }

      setState(() {
        _conversationId = data['conversationId']?.toString();
        _messages.add(
          AiChatMessage(
            content: data['reply']?.toString() ?? 'AI chưa có câu trả lời.',
            fromUser: false,
            suggestions: AiSuggestion.listFrom(data['suggestions']),
          ),
        );
      });
    } catch (error) {
      setState(() {
        _messages.add(
          AiChatMessage(
            content: 'Chưa thể gọi AI lúc này. ${_msg(error)}',
            fromUser: false,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Thong diep loi than thien: ApiException da co san message tieng Viet,
  /// cac loi khac thi bao chung chung thay vi in nguyen exception.
  String _msg(Object error) => error is ApiException ? error.message : tr('Vui lòng thử lại.', 'Please try again.');

  Future<void> _openRoomSelection(AiSuggestion suggestion) async {
    if (_navigating) return;
    setState(() => _navigating = true);

    try {
      // Xac thuc lai ID voi du lieu hien tai truoc khi dieu huong,
      // tranh mo booking flow tu goi y da cu (stale).
      final summaries = await ApiStayzRepository.instance.getHotelSummaries();
      final summary = summaries.where((item) => item.hotel.id == suggestion.propertyId).firstOrNull;

      if (!mounted) return;
      if (summary == null) {
        setState(() {
          _messages.add(
            AiChatMessage(
              content:
                  'Khách sạn "${suggestion.propertyTitle}" không còn trong dữ liệu hiện tại. Bạn thử hỏi lại để mình gợi ý lựa chọn khác nhé.',
              fromUser: false,
            ),
          );
        });
        return;
      }

      await Navigator.of(context).pushNamed(
        AppRoutes.roomSelection,
        arguments: RoomSelectionArgs(
          hotel: summary,
          checkInDate: widget.aiContext.checkIn,
          checkOutDate: widget.aiContext.checkOut,
          adults: widget.aiContext.guests ?? 2,
          children: 0,
          roomCount: 1,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          AiChatMessage(
            content: 'Chưa thể mở danh sách phòng lúc này. ${_msg(error)}',
            fromUser: false,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _navigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height * 0.82;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFCF8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 10),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.accentDark,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.auto_awesome_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
              tr('StayZ AI', 'StayZ AI'),
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_sending && index == _messages.length) {
                    return _AiBubble(
          message: AiChatMessage(content: tr('Đang đọc dữ liệu và trả lời...', 'Reading the data and preparing an answer...'), fromUser: false),
                    );
                  }
                  final message = _messages[index];
                  if (message.suggestions.isEmpty) {
                    return _AiBubble(message: message);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AiBubble(message: message),
                      for (final suggestion in message.suggestions)
                        _SuggestionCard(
                          suggestion: suggestion,
                          enabled: !_navigating,
                          onSelect: () => _openRoomSelection(suggestion),
                        ),
                    ],
                  );
                },
              ),
            ),
            _ContextChips(aiContext: widget.aiContext),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                    hintText: tr('Hỏi về khách sạn, phòng, giá...', 'Ask about hotels, rooms, prices...'),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: FilledButton(
                      onPressed: _sending ? null : _send,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentDark,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.send_rounded),
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

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.fromUser ? AppTheme.accentDark : Colors.white;
    final textColor = message.fromUser ? Colors.white : AppTheme.ink;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: message.fromUser ? null : Border.all(color: AppTheme.line),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.45),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.enabled,
    required this.onSelect,
  });

  final AiSuggestion suggestion;
  final bool enabled;
  final VoidCallback onSelect;

  static const _cityNames = <String, String>{
    'da-lat': 'Da Lat',
    'da-nang': 'Da Nang',
    'ha-noi': 'Ha Noi',
    'ho-chi-minh': 'TP Hồ Chí Minh',
    'vung-tau': 'Vung Tau',
  };

  String get _availabilityText {
    final available = suggestion.availableRooms;
    if (available == null) return 'Chưa xác nhận còn phòng (thiếu ngày nhận/trả phòng)';
    if (available <= 0) return 'Hết phòng theo ngày đã chọn';
    return 'Còn khoảng $available phòng theo ngày đã chọn';
  }

  @override
  Widget build(BuildContext context) {
    final city = _cityNames[suggestion.citySlug] ?? suggestion.citySlug;
    final details = <String>[
      if (suggestion.roomName != null && suggestion.roomName!.isNotEmpty) 'Phòng ${suggestion.roomName}',
      if (suggestion.capacity != null) 'Tối đa ${suggestion.capacity} khách',
      if (suggestion.totalPrice != null) 'Tổng ${StayzFormatters.fullVnd(suggestion.totalPrice!)}',
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion.propertyTitle,
              style: const TextStyle(color: AppTheme.ink, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 15, color: AppTheme.accentDark),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    city.isEmpty ? tr('Việt Nam', 'Vietnam') : city,
                    style: const TextStyle(color: AppTheme.ink, fontSize: 13),
                  ),
                ),
                if (suggestion.rating != null) ...[
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF5A623)),
                  const SizedBox(width: 2),
                  Text(
                    '${suggestion.rating!.toStringAsFixed(1)} (${suggestion.reviewCount})',
                    style: const TextStyle(color: AppTheme.ink, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                details.join(' • '),
                style: const TextStyle(color: AppTheme.ink, fontSize: 13, height: 1.4),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              _availabilityText,
              style: TextStyle(
                color: suggestion.availableRooms == null ? AppTheme.ink : AppTheme.accentDark,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (suggestion.pricePerNight != null)
                  Expanded(
                    child: Text(
                    tr('${StayzFormatters.fullVnd(suggestion.pricePerNight!)}/đêm', '${StayzFormatters.fullVnd(suggestion.pricePerNight!)}/night'),
                      style: const TextStyle(color: AppTheme.accentDark, fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  )
                else
                  const Spacer(),
                FilledButton(
                  onPressed: enabled ? onSelect : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentDark,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
              child: Text(tr('Chọn phòng', 'Select room')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextChips extends StatelessWidget {
  const _ContextChips({required this.aiContext});

  final AiChatContext aiContext;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (aiContext.guests != null) '${aiContext.guests} khách',
      if (aiContext.checkIn != null && aiContext.checkOut != null)
        '${StayzFormatters.shortDate(aiContext.checkIn!)} - ${StayzFormatters.shortDate(aiContext.checkOut!)}',
      if (aiContext.propertyId != null) 'có khách sạn',
      if (aiContext.roomId != null) 'có phòng',
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Chip(
            label: Text(chips[index]),
            visualDensity: VisualDensity.compact,
            backgroundColor: AppTheme.neutral200.withValues(alpha: 0.45),
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}
