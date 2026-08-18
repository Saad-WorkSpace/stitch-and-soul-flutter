import 'package:flutter/material.dart';

import 'brand.dart';
import 'tokens.dart';

/// Lightweight splash used during the first frame. Most state has already
/// been hydrated by `main()` before we get here, so this only renders
/// briefly while the engine warms up.
class SsBootstrap extends StatelessWidget {
  const SsBootstrap({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(color: SsColors.ivory, child: child);
  }
}

/// The brand mark used in the splash and any loading states.
class SsBrandMark extends StatelessWidget {
  const SsBrandMark({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      SsBrand.name,
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: size,
        letterSpacing: 1.2,
        color: SsColors.ink,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
