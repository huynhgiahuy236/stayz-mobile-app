import 'package:flutter/material.dart';

enum StayZTextRole { display, body, mono }

class RoomDetailText extends StatelessWidget {
  const RoomDetailText({
    super.key,
    required this.text,
    this.size = 13,
    this.color = const Color(0xFF1A1612),
    this.weight = FontWeight.w400,
    this.height = 1.5,
    this.letterSpacing,
    this.decoration,
    this.maxLines,
    this.overflow,
    this.align,
    this.role = StayZTextRole.body,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final double height;
  final double? letterSpacing;
  final TextDecoration? decoration;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? align;
  final StayZTextRole role;

  @override
  Widget build(BuildContext context) {
    final fontFamily = switch (role) {
      StayZTextRole.display => 'Noto Serif JP',
      StayZTextRole.mono => 'DM Mono',
      StayZTextRole.body => 'Inter',
    };

    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: fontFamily,
        color: color,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RoomDetailText(
            text: text,
            size: 18,
            weight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        if (trailing != null)
          RoomDetailText(
            text: trailing!,
            color: const Color(0xFF7A6E60),
            size: 12,
          ),
      ],
    );
  }
}
