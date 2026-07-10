import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/services/api_service.dart';
import 'package:capstone_mobile/services/auth_service.dart';
import 'package:capstone_mobile/shared/data/stayz_formatters.dart';
import 'package:capstone_mobile/shared/models/booking_flow_models.dart';
import 'package:capstone_mobile/shared/models/stayz_models.dart';
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
      initialMessage: 'Hoi AI ve khach san ${summary.hotel.name}',
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
      initialMessage: 'Nho AI chon phong phu hop tai ${hotel.hotel.name}',
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
  const AiChatMessage({required this.content, required this.fromUser});

  final String content;
  final bool fromUser;
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
      content: 'Minh co the goi y khach san, chon phong, tinh gia va kiem tra phong trong tu du lieu StayZ.',
      fromUser: false,
    ),
  ];
  String? _conversationId;
  bool _sending = false;

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
        throw StateError('Vui long dang nhap de luu lich su chat AI.');
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
        throw StateError('Phan hoi AI khong hop le.');
      }

      setState(() {
        _conversationId = data['conversationId']?.toString();
        _messages.add(
          AiChatMessage(
            content: data['reply']?.toString() ?? 'AI chua co cau tra loi.',
            fromUser: false,
          ),
        );
      });
    } catch (error) {
      setState(() {
        _messages.add(
          AiChatMessage(
            content: 'Chua the goi AI luc nay. ${error.toString()}',
            fromUser: false,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _sending = false);
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
                  const Expanded(
                    child: Text(
                      'StayZ AI',
                      style: TextStyle(
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
                    return const _AiBubble(
                      message: AiChatMessage(content: 'Dang doc du lieu va tra loi...', fromUser: false),
                    );
                  }
                  return _AiBubble(message: _messages[index]);
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
                        hintText: 'Hoi ve khach san, phong, gia...',
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

class _ContextChips extends StatelessWidget {
  const _ContextChips({required this.aiContext});

  final AiChatContext aiContext;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (aiContext.guests != null) '${aiContext.guests} khach',
      if (aiContext.checkIn != null && aiContext.checkOut != null)
        '${StayzFormatters.shortDate(aiContext.checkIn!)} - ${StayzFormatters.shortDate(aiContext.checkOut!)}',
      if (aiContext.propertyId != null) 'co propertyId',
      if (aiContext.roomId != null) 'co roomId',
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
