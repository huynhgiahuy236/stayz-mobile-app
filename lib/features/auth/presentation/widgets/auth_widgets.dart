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
      body: SafeArea(
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
              icon: const Icon(Icons.arrow_back),
              color: AppTheme.accentDark,
              iconSize: 30 * responsive.scale,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(
                width: 44 * responsive.scale,
                height: 44 * responsive.scale,
              ),
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

class AuthField extends StatelessWidget {
  const AuthField({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.prefix,
    this.keyboardType,
    super.key,
  });

  final String label;
  final String hint;
  final bool obscure;
  final Widget? prefix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5A3F3F),
            fontSize: 14 * responsive.scale,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: 10 * responsive.scale),
        SizedBox(
          height: 56 * responsive.scale,
          child: TextField(
            obscureText: obscure,
            keyboardType: keyboardType,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.ink,
              fontSize: 17 * responsive.scale,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFD8BDBD),
                fontSize: 17 * responsive.scale,
              ),
              prefixIcon: prefix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(left: 18 * responsive.scale),
                      child: prefix,
                    ),
              prefixIconConstraints: prefix == null
                  ? null
                  : BoxConstraints(
                      minWidth: 74 * responsive.scale,
                      minHeight: 0,
                    ),
              suffixIcon: obscure
                  ? Icon(
                      Icons.visibility_outlined,
                      color: const Color(0xFF5A3F3F),
                      size: 25 * responsive.scale,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18 * responsive.scale,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.neutral200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.accent),
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
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final responsive = AuthResponsive.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 58 * responsive.scale,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: AppTheme.cream,
            fontSize: 18 * responsive.scale,
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
