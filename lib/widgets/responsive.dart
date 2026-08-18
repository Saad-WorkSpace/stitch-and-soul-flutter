import 'package:flutter/material.dart';

import '../app/tokens.dart';

/// A simple responsive layout helper: the layout builder receives the
/// current device bucket.
class SsResponsive extends StatelessWidget {
  const SsResponsive({super.key, required this.builder});

  final Widget Function(BuildContext context, SsDevice device) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final SsDevice device;
        if (w < SsBreakpoints.phone) {
          device = SsDevice.phone;
        } else if (w < SsBreakpoints.tablet) {
          device = SsDevice.tablet;
        } else if (w < SsBreakpoints.desktop) {
          device = SsDevice.desktop;
        } else {
          device = SsDevice.wide;
        }
        return builder(context, device);
      },
    );
  }
}

/// A flex child that expands only when its parent is using a bounded row.
/// This prevents the common `Expanded`-inside-a-scrollable-column exception
/// when a responsive `Flex` switches from horizontal to vertical.
class SsFlexItem extends StatelessWidget {
  const SsFlexItem({
    super.key,
    required this.expand,
    required this.child,
    this.flex = 1,
  });

  final bool expand;
  final int flex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return expand ? Expanded(flex: flex, child: child) : child;
  }
}

/// Constrains a child to the page max-width and applies page padding.
class SsPageScaffold extends StatelessWidget {
  const SsPageScaffold({super.key, required this.child, this.device});

  final Widget child;
  final SsDevice? device;

  @override
  Widget build(BuildContext context) {
    return SsResponsive(
      builder: (context, d) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: pageMaxWidth(d)),
            child: Padding(padding: pagePadding(d), child: child),
          ),
        );
      },
    );
  }
}
