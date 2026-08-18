import 'package:flutter/material.dart';

import '../app/motion.dart';
import '../app/tokens.dart';

/// A generous, accessible image placeholder. We never want a broken image
/// icon in this app — instead, a styled block that hints at the product.
class SsImagePlaceholder extends StatelessWidget {
  const SsImagePlaceholder({
    super.key,
    required this.label,
    this.aspectRatio = 1.0,
    this.seed = 0,
    this.radius = SsRadii.md,
  });

  final String label;
  final double aspectRatio;
  final int seed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = SsColors
        .placeholderPalette[seed.abs() % SsColors.placeholderPalette.length];
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          color: color,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Subtle diagonal weave to suggest a textile grain.
              CustomPaint(painter: _WeavePainter(color)),
              Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: SsColors.ink,
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeavePainter extends CustomPainter {
  _WeavePainter(this.base);
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.0;
    const step = 8.0;
    for (double x = -size.height; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _WeavePainter old) => old.base != base;
}

/// A subtle, animated gradient orb used on hero sections.
class SsAnimatedOrb extends StatefulWidget {
  const SsAnimatedOrb({
    super.key,
    this.color = SsColors.claySoft,
    this.size = 480,
  });
  final Color color;
  final double size;

  @override
  State<SsAnimatedOrb> createState() => _SsAnimatedOrbState();
}

class _SsAnimatedOrbState extends State<SsAnimatedOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return _Orb(color: widget.color, size: widget.size, t: 0);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          _Orb(color: widget.color, size: widget.size, t: _controller.value),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size, required this.t});
  final Color color;
  final double size;
  final double t;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                color.withValues(alpha: 0.85),
                color.withValues(alpha: 0.0),
              ],
              stops: const <double>[0.0, 0.7],
            ),
          ),
          child: Transform.translate(
            offset: Offset(20 * (t - 0.5), 14 * (t - 0.5)),
            child: Transform.scale(scale: 1.0 + 0.06 * (t - 0.5).abs()),
          ),
        ),
      ),
    );
  }
}

/// Hover-lift card used across the app. Hover only fires on platforms
/// that report a pointer (web/desktop), so on mobile this is just a card.
class SsHoverCard extends StatefulWidget {
  const SsHoverCard({super.key, required this.child, this.onTap, this.padding});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  State<SsHoverCard> createState() => _SsHoverCardState();
}

class _SsHoverCardState extends State<SsHoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduced = prefersReducedMotion(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SsDurations.short,
          curve: SsCurves.entrance,
          transform: reduced || !_hovered
              ? (Matrix4.identity())
              : Matrix4.translationValues(0, -4, 0),
          decoration: BoxDecoration(
            color: SsColors.surface,
            borderRadius: BorderRadius.circular(SsRadii.md),
            border: Border.all(
              color: _hovered
                  ? SsColors.ink.withValues(alpha: 0.18)
                  : SsColors.divider,
            ),
            boxShadow: <BoxShadow>[
              if (_hovered && !reduced)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

/// An accessible chip used for filters and category nav.
class SsChip extends StatelessWidget {
  const SsChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SsRadii.pill),
        child: AnimatedContainer(
          duration: SsDurations.short,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? SsColors.ink : SsColors.surface,
            borderRadius: BorderRadius.circular(SsRadii.pill),
            border: Border.all(
              color: selected ? SsColors.ink : SsColors.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (leading != null) ...<Widget>[
                IconTheme(
                  data: IconThemeData(
                    color: selected ? SsColors.ivory : SsColors.ink,
                    size: 14,
                  ),
                  child: leading!,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? SsColors.ivory : SsColors.ink,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section heading with eyebrow text.
class SsSectionHeading extends StatelessWidget {
  const SsSectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: SsColors.inkMuted,
                  fontSize: 11,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: SsColors.inkMuted),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A subtle horizontal rule with a centered label.
class SsDivider extends StatelessWidget {
  const SsDivider({super.key, this.label});
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const Divider(color: SsColors.divider, height: 1);
    }
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: SsColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label!,
            style: const TextStyle(
              color: SsColors.inkMuted,
              fontSize: 11,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const Expanded(child: Divider(color: SsColors.divider)),
      ],
    );
  }
}
