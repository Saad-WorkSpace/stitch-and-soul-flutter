import 'package:flutter/widgets.dart';

/// Centralized motion timings and curves. We deliberately keep durations
/// short so motion reinforces hierarchy rather than slows the user down.
class SsDurations {
  SsDurations._();

  static const Duration micro = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 380);
  static const Duration long = Duration(milliseconds: 600);

  /// Used for staggered text reveals on hero / headlines.
  static const Duration staggerStep = Duration(milliseconds: 70);
}

class SsCurves {
  SsCurves._();

  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve overshoot = Curves.easeOutBack;
}

/// Returns true when the user (or platform) has asked for reduced motion.
bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// A safe AnimatedBuilder wrapper that skips animation entirely when
/// reduced motion is preferred.
class SsAnimatedVisibility extends StatelessWidget {
  const SsAnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = SsDurations.medium,
    this.curve = SsCurves.entrance,
    this.beginOffset = const Offset(0, 0.02),
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return Visibility(visible: visible, maintainState: true, child: child);
    }
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: SsCurves.exit,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: Visibility(
        key: ValueKey<bool>(visible),
        visible: visible,
        maintainState: true,
        child: child,
      ),
    );
  }
}

/// A staggered text reveal: each child fades + lifts in sequence.
/// No external controller — uses one Tween on the parent's animation
/// to drive per-line progress.
class SsStaggeredReveal extends StatelessWidget {
  const SsStaggeredReveal({
    super.key,
    required this.children,
    this.stagger = SsDurations.staggerStep,
    this.duration = SsDurations.medium,
    this.beginOffset = const Offset(0, 0.06),
  });

  final List<Widget> children;
  final Duration stagger;
  final Duration duration;
  final Offset beginOffset;

  @override
  Widget build(BuildContext context) {
    final reduced = prefersReducedMotion(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < children.length; i++)
          reduced
              ? children[i]
              : _StaggeredLine(
                  index: i,
                  stagger: stagger,
                  duration: duration,
                  beginOffset: beginOffset,
                  child: children[i],
                ),
      ],
    );
  }
}

class _StaggeredLine extends StatefulWidget {
  const _StaggeredLine({
    required this.index,
    required this.stagger,
    required this.duration,
    required this.beginOffset,
    required this.child,
  });

  final int index;
  final Duration stagger;
  final Duration duration;
  final Offset beginOffset;
  final Widget child;

  @override
  State<_StaggeredLine> createState() => _StaggeredLineState();
}

class _StaggeredLineState extends State<_StaggeredLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.stagger * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = CurvedAnimation(
          parent: _controller,
          curve: SsCurves.entrance,
        );
        return Opacity(
          opacity: t.value,
          child: Transform.translate(
            offset: Offset(
              widget.beginOffset.dx * (1 - t.value),
              widget.beginOffset.dy * (1 - t.value),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
