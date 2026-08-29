import 'package:flutter/material.dart';

import '../app/motion.dart';
import '../app/tokens.dart';

/// A React Bits-inspired reflective surface for feature imagery.
///
/// Pointer movement gently tilts the card and moves an iridescent spotlight
/// across it. Touch devices keep the quiet resting treatment, while reduced
/// motion disables the tilt entirely.
class SsHolographicCard extends StatefulWidget {
  const SsHolographicCard({
    super.key,
    required this.child,
    this.radius = SsRadii.lg,
  });

  final Widget child;
  final double radius;

  @override
  State<SsHolographicCard> createState() => _SsHolographicCardState();
}

class _SsHolographicCardState extends State<SsHolographicCard> {
  final GlobalKey _cardKey = GlobalKey();
  bool _hovered = false;
  Offset _pointer = const Offset(0.5, 0.5);

  void _updatePointer(PointerEvent event) {
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || box.size.isEmpty) return;
    setState(() {
      _pointer = Offset(
        (event.localPosition.dx / box.size.width).clamp(0.0, 1.0),
        (event.localPosition.dy / box.size.height).clamp(0.0, 1.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduced = prefersReducedMotion(context);
    final horizontal = _hovered ? (_pointer.dx - 0.5) * 2 : 0.0;
    final vertical = _hovered ? (_pointer.dy - 0.5) * 2 : 0.0;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateX(reduced ? 0 : -vertical * 0.045)
      ..rotateY(reduced ? 0 : horizontal * 0.055);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (event) {
        if (reduced) return;
        setState(() => _hovered = true);
        _updatePointer(event);
      },
      onHover: reduced ? null : _updatePointer,
      onExit: (_) {
        if (reduced) return;
        setState(() {
          _hovered = false;
          _pointer = const Offset(0.5, 0.5);
        });
      },
      child: AnimatedScale(
        scale: _hovered && !reduced ? 1.012 : 1,
        duration: SsDurations.short,
        curve: SsCurves.emphasized,
        child: AnimatedContainer(
          key: _cardKey,
          duration: SsDurations.short,
          curve: SsCurves.emphasized,
          transform: transform,
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFE9AFC1).withValues(alpha: 0.8)
                  : SsColors.surface.withValues(alpha: 0.78),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (_hovered ? const Color(0xFFA8C5A0) : SsColors.ink)
                    .withValues(alpha: _hovered ? 0.22 : 0.10),
                blurRadius: _hovered ? 34 : 18,
                spreadRadius: _hovered ? 2 : 0,
                offset: Offset(-horizontal * 7, 14 + vertical * 4),
              ),
              if (_hovered)
                BoxShadow(
                  color: const Color(0xFFF2B7C8).withValues(alpha: 0.22),
                  blurRadius: 42,
                  offset: Offset(horizontal * 10, -vertical * 8),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius - 1),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                widget.child,
                IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _hovered ? 0.34 : 0.10,
                    duration: SsDurations.short,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1 + horizontal, -1 + vertical),
                          end: Alignment(1 + horizontal, 1 + vertical),
                          colors: const <Color>[
                            Color(0xFFC4D5BC),
                            Color(0xFFF7FAF4),
                            Color(0xFFF2B7C8),
                            Color(0xFFF8DCE4),
                            Color(0xFF9FB99A),
                          ],
                          stops: const <double>[0, 0.24, 0.5, 0.74, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(horizontal, vertical),
                        radius: 0.72,
                        colors: <Color>[
                          Colors.white.withValues(
                            alpha: _hovered ? 0.36 : 0.10,
                          ),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.radius - 1),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: _hovered ? 0.58 : 0.22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A bright magnetic CTA inspired by React Bits' Magnet and Glare Hover.
class SsMagneticButton extends StatefulWidget {
  const SsMagneticButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool secondary;

  @override
  State<SsMagneticButton> createState() => _SsMagneticButtonState();
}

class _SsMagneticButtonState extends State<SsMagneticButton> {
  final GlobalKey _buttonKey = GlobalKey();
  bool _hovered = false;
  bool _pressed = false;
  Offset _magneticOffset = Offset.zero;

  void _updateMagnet(PointerEvent event) {
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || box.size.isEmpty) return;
    final x = event.localPosition.dx / box.size.width - 0.5;
    final y = event.localPosition.dy / box.size.height - 0.5;
    setState(() => _magneticOffset = Offset(x * 9, y * 7));
  }

  @override
  Widget build(BuildContext context) {
    final reduced = prefersReducedMotion(context);
    final isSecondary = widget.secondary;
    final foreground = isSecondary ? SsColors.ink : Colors.white;
    final gradient = isSecondary
        ? LinearGradient(
            colors: _hovered
                ? const <Color>[Color(0xFFFBE7ED), Color(0xFFEDC3CF)]
                : const <Color>[SsColors.surface, Color(0xFFF3F7F0)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hovered
                ? const <Color>[Color(0xFF94A98E), Color(0xFF748970)]
                : const <Color>[Color(0xFF849A7E), Color(0xFF667B62)],
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        setState(() => _hovered = true);
        if (!reduced) _updateMagnet(event);
      },
      onHover: reduced ? null : _updateMagnet,
      onExit: (_) => setState(() {
        _hovered = false;
        _magneticOffset = Offset.zero;
      }),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : (_hovered && !reduced ? 1.025 : 1),
        duration: SsDurations.micro,
        curve: SsCurves.emphasized,
        child: AnimatedContainer(
          key: _buttonKey,
          duration: SsDurations.micro,
          curve: SsCurves.emphasized,
          transform: Matrix4.translationValues(
            reduced ? 0 : _magneticOffset.dx,
            reduced ? 0 : _magneticOffset.dy,
            0,
          ),
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(SsRadii.pill),
            border: Border.all(
              color: isSecondary
                  ? (_hovered ? SsColors.clay : SsColors.ink)
                  : const Color(0xFF52644F),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (isSecondary ? SsColors.clay : SsColors.clay)
                    .withValues(alpha: _hovered ? 0.26 : 0.14),
                blurRadius: _hovered ? 22 : 12,
                offset: Offset(0, _hovered ? 9 : 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedAlign(
                    alignment: _hovered
                        ? const Alignment(1.8, 0)
                        : const Alignment(-1.8, 0),
                    duration: const Duration(milliseconds: 620),
                    curve: SsCurves.emphasized,
                    child: Transform.rotate(
                      angle: -0.28,
                      child: Container(
                        width: 42,
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  onHighlightChanged: (value) {
                    setState(() => _pressed = value);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 12,
                            letterSpacing: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedSlide(
                          offset:
                              _hovered ? const Offset(0.18, 0) : Offset.zero,
                          duration: SsDurations.short,
                          curve: SsCurves.emphasized,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: foreground,
                            size: 17,
                          ),
                        ),
                      ],
                    ),
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
