import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthResponsive {
  const AuthResponsive._({
    required this.widthScale,
    required this.heightScale,
    required this.scale,
    required this.horizontalPadding,
    required this.isCompact,
  });

  factory AuthResponsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width.clamp(360.0, 430.0).toDouble();
    final widthScale = (width / 390).clamp(0.92, 1.10).toDouble();
    final heightScale = (size.height / 844).clamp(0.72, 1.0).toDouble();

    return AuthResponsive._(
      widthScale: widthScale,
      heightScale: heightScale,
      scale: widthScale < heightScale ? widthScale : heightScale,
      horizontalPadding: 28 * widthScale,
      isCompact: size.height < 760,
    );
  }

  final double widthScale;
  final double heightScale;
  final double scale;
  final double horizontalPadding;
  final bool isCompact;
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.bottomIndicator = true,
    super.key,
  });

  final Widget child;
  final bool bottomIndicator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFFFAF6F0),
              AppTheme.cream,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: child),
              if (bottomIndicator)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: AuthHomeIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScrollBody extends StatelessWidget {
  const AuthScrollBody({
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.bottomPadding = 40,
    super.key,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        38 * responsive.scale,
        responsive.horizontalPadding,
        bottomPadding * responsive.scale,
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    this.centered = false,
    this.large = false,
    super.key,
  });

  final bool centered;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;
    final logo = RichText(
      text: TextSpan(
        style: textTheme.headlineMedium?.copyWith(
          color: AppTheme.ink,
          fontSize: (large ? 38 : 30) * responsive.scale,
          fontWeight: FontWeight.w400,
          height: 1,
        ),
        children: const [
          TextSpan(text: 'Stay'),
          TextSpan(
            text: 'Z',
            style: TextStyle(color: AppTheme.accent),
          ),
        ],
      ),
    );

    return centered ? Center(child: logo) : logo;
  }
}

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({
    this.title,
    this.showLogo = true,
    super.key,
  });

  final String? title;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.horizontalPadding,
        20 * responsive.scale,
        responsive.horizontalPadding,
        0,
      ),
      child: SizedBox(
        height: 54 * responsive.scale,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.8),
                  border: Border.all(
                    color: AppTheme.neutral200.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppTheme.accentDark,
                  size: 20 * responsive.scale,
                ),
              ),
              padding: EdgeInsets.zero,
              tooltip: 'Quay lại',
              // 48dp la nguong toi thieu tren Android; 44dp truoc day chua dat.
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            ),
            if (title != null) ...[
              SizedBox(width: 18 * responsive.widthScale),
              Expanded(
                child: Text(
                  title!,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppTheme.ink,
                    fontSize: 25 * responsive.scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            if (showLogo)
              AuthLogo(
                centered: false,
                large: title == null,
              ),
          ],
        ),
      ),
    );
  }
}

class AuthTitleBlock extends StatelessWidget {
  const AuthTitleBlock({
    required this.title,
    this.subtitle,
    this.centered = false,
    this.accentTitle = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool centered;
  final bool accentTitle;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: textTheme.displayLarge?.copyWith(
            color: accentTitle ? AppTheme.accent : AppTheme.ink,
            fontSize: (centered ? 33 : 36) * responsive.scale,
            fontWeight: FontWeight.w400,
            height: 1.16,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 14 * responsive.scale),
          Text(
            subtitle!,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.neutral500,
              fontSize: 17 * responsive.scale,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthField extends StatefulWidget {
  const AuthField({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.prefix,
    this.keyboardType,
    this.controller,
    this.textInputAction,
    super.key,
  });

  final String label;
  final String hint;
  final bool obscure;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppTheme.neutral500,
            fontSize: 13 * responsive.scale,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 10 * responsive.scale),
        SizedBox(
          height: 56 * responsive.scale,
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.ink,
              fontSize: 16 * responsive.scale,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutral500.withValues(alpha: 0.4),
                fontSize: 16 * responsive.scale,
              ),
              prefixIcon: widget.prefix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(left: 18 * responsive.scale),
                      child: widget.prefix,
                    ),
              prefixIconConstraints: widget.prefix == null
                  ? null
                  : BoxConstraints(
                      minWidth: 74 * responsive.scale,
                      minHeight: 0,
                    ),
              suffixIcon: widget.obscure
                  ? IconButton(
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                      icon: Icon(
                        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.neutral500,
                        size: 22 * responsive.scale,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18 * responsive.scale,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.neutral200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  final String label;

  /// `null` = vo hieu hoa that su. Truoc day cac man truyen `() {}` khi dang tai,
  /// nen nut van sang mau day du va van bam duoc nhung khong lam gi ca.
  final VoidCallback? onPressed;

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 56 * responsive.scale,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.cream,
          disabledBackgroundColor: AppTheme.accent.withValues(alpha: 0.42),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12 * responsive.scale),
                  Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 17 * responsive.scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: AppTheme.cream,
                  fontSize: 17 * responsive.scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class AuthInlineLink extends StatelessWidget {
  const AuthInlineLink({
    required this.text,
    required this.actionText,
    required this.onTap,
    super.key,
  });

  final String text;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutral500,
              fontSize: 15 * responsive.scale,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionText,
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.accent,
                fontSize: 15 * responsive.scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.neutral200)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18 * responsive.widthScale),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutral500,
              fontSize: 14 * responsive.scale,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.neutral200)),
      ],
    );
  }
}

class AuthHomeIndicator extends StatelessWidget {
  const AuthHomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 74,
        height: 2,
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class AuthCheckbox extends StatefulWidget {
  const AuthCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<AuthCheckbox> createState() => _AuthCheckboxState();
}

class _AuthCheckboxState extends State<AuthCheckbox> {
  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 22 * responsive.scale,
        height: 22 * responsive.scale,
        decoration: BoxDecoration(
          color: widget.value ? AppTheme.accent : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.value ? AppTheme.accent : AppTheme.neutral200,
            width: 1.5,
          ),
        ),
        child: widget.value
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 15 * responsive.scale,
              )
            : null,
      ),
    );
  }
}

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({required this.size, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;
    final center = Offset(w / 2, h / 2);

    final red = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final yellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final green = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double rOuter = r;
    final double rInner = r * 0.55;
    final rectOuter = Rect.fromCircle(center: center, radius: rOuter);
    final rectInner = Rect.fromCircle(center: center, radius: rInner);

    final pathRed = Path();
    pathRed.moveTo(center.dx, center.dy);
    pathRed.arcTo(rectOuter, -1.92, -1.57, false);
    pathRed.close();

    final pathYellow = Path();
    pathYellow.moveTo(center.dx, center.dy);
    pathYellow.arcTo(rectOuter, -3.49, -1.57, false);
    pathYellow.close();

    final pathGreen = Path();
    pathGreen.moveTo(center.dx, center.dy);
    pathGreen.arcTo(rectOuter, 0.78, 1.96, false);
    pathGreen.close();

    final pathBlue = Path();
    pathBlue.moveTo(center.dx, center.dy);
    pathBlue.arcTo(rectOuter, -0.78, 1.56, false);
    pathBlue.close();

    final pathInner = Path()..addOval(rectInner);

    canvas.drawPath(Path.combine(PathOperation.difference, pathRed, pathInner), red);
    canvas.drawPath(Path.combine(PathOperation.difference, pathYellow, pathInner), yellow);
    canvas.drawPath(Path.combine(PathOperation.difference, pathGreen, pathInner), green);

    final barRect = Rect.fromLTRB(center.dx, center.dy - w / 10, center.dx + rOuter, center.dy + w / 10);
    final pathBlueWithBar = Path.combine(PathOperation.union, pathBlue, Path()..addRect(barRect));
    final pathBlueFinal = Path.combine(PathOperation.difference, pathBlueWithBar, pathInner);

    canvas.drawPath(pathBlueFinal, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

