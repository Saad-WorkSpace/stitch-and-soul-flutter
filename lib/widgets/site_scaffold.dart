import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/motion.dart';
import '../app/tokens.dart';
import '../app/brand.dart';
import '../state/cart_notifier.dart';
import '../data/repositories.dart';
import 'responsive.dart';

class SiteScaffold extends ConsumerWidget {
  const SiteScaffold({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final fav = ref.watch(favoritesProvider);
    return Scaffold(
      backgroundColor: SsColors.ivory,
      drawer: location.startsWith('/checkout') ? null : const _MobileDrawer(),
      appBar: _buildAppBar(context, ref, cart.itemCount, fav.ids.length),
      body: child,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    int cartCount,
    int favCount,
  ) {
    final isCompact = MediaQuery.sizeOf(context).width < SsBreakpoints.tablet;
    final showMenu = isCompact && !location.startsWith('/checkout');
    return AppBar(
      backgroundColor: SsColors.ivory,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 84,
      titleSpacing: showMenu ? 0 : 24,
      automaticallyImplyLeading: false,
      leading: showMenu
          ? Builder(
              builder: (ctx) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: IconButton(
                  tooltip: 'Open menu',
                  icon: const Icon(Icons.menu, size: 22),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            )
          : null,
      title: const _BrandLogo(),
      actions: <Widget>[
        if (!isCompact) ...<Widget>[
          _PillNavigation(location: location),
          const SizedBox(width: 12),
        ],
        _IconAction(
          tooltip: 'Favorites',
          icon: Icons.favorite_outline,
          route: '/favorites',
          badge: favCount,
          onTap: () => context.go('/favorites'),
        ),
        _IconAction(
          tooltip: 'Cart',
          icon: Icons.shopping_bag_outlined,
          route: '/cart',
          badge: cartCount,
          onTap: () => context.go('/cart'),
        ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: SsColors.divider),
      ),
    );
  }
}

class _BrandLogo extends StatefulWidget {
  const _BrandLogo();

  @override
  State<_BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<_BrandLogo> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduced = prefersReducedMotion(context);
    return Semantics(
      label: 'ÉLISE, home',
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Tooltip(
          message: SsBrand.name,
          waitDuration: const Duration(milliseconds: 700),
          child: InkWell(
            onTap: () => context.go('/'),
            borderRadius: BorderRadius.circular(SsRadii.pill),
            child: AnimatedContainer(
              duration: reduced ? Duration.zero : SsDurations.short,
              curve: SsCurves.emphasized,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _hovered
                    ? SsColors.surface
                    : SsColors.ivory.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(SsRadii.pill),
                boxShadow: <BoxShadow>[
                  if (_hovered)
                    BoxShadow(
                      color: SsColors.clay.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    width: 42,
                    height: 42,
                    child: CustomPaint(painter: _EliseMarkPainter()),
                  ),
                  ClipRect(
                    child: AnimatedSize(
                      duration: reduced ? Duration.zero : SsDurations.medium,
                      curve: SsCurves.emphasized,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: _hovered ? 126 : 0,
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1 : 0,
                          duration: reduced ? Duration.zero : SsDurations.short,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 12),
                            child: Transform.translate(
                              offset: Offset(_hovered ? 0 : -10, 0),
                              child: Text(
                                SsBrand.name,
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.35,
                                    ),
                              ),
                            ),
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
      ),
    );
  }
}

class _EliseMarkPainter extends CustomPainter {
  const _EliseMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF354437), Color(0xFF172019)],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(14)),
      background,
    );

    final monogram = TextPainter(
      text: const TextSpan(
        text: 'É',
        style: TextStyle(
          color: Color(0xFFF7F8F3),
          fontFamily: 'serif',
          fontSize: 28,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    monogram.paint(
      canvas,
      Offset(
        (size.width - monogram.width) / 2,
        (size.height - monogram.height) / 2 + 1,
      ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.78),
      3,
      Paint()..color = const Color(0xFFF2B7C8),
    );
  }

  @override
  bool shouldRepaint(covariant _EliseMarkPainter oldDelegate) => false;
}

class _PillNavigation extends StatelessWidget {
  const _PillNavigation({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(SsRadii.pill),
        border: Border.all(color: SsColors.claySoft.withValues(alpha: 0.78)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SsColors.clay.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _NavLink(
            label: 'Shop',
            route: '/shop',
            active: location.startsWith('/shop'),
          ),
          _NavLink(
            label: 'Services',
            route: '/services',
            active: location == '/services',
          ),
          _NavLink(
            label: 'Story',
            route: '/story',
            active: location == '/story',
          ),
          _NavLink(
            label: 'Contact',
            route: '/contact',
            active: location == '/contact',
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.route,
    required this.active,
  });
  final String label;
  final String route;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final emphasized = widget.active || _hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        selected: widget.active,
        button: true,
        child: InkWell(
          onTap: () => context.go(widget.route),
          borderRadius: BorderRadius.circular(SsRadii.pill),
          child: AnimatedContainer(
            duration: SsDurations.short,
            curve: SsCurves.emphasized,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
            decoration: BoxDecoration(
              color: widget.active
                  ? SsColors.clay
                  : (_hovered ? const Color(0xFFE6EFE2) : Colors.transparent),
              borderRadius: BorderRadius.circular(SsRadii.pill),
              boxShadow: <BoxShadow>[
                if (widget.active)
                  BoxShadow(
                    color: SsColors.clay.withValues(alpha: 0.26),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: AnimatedDefaultTextStyle(
              duration: SsDurations.short,
              style: TextStyle(
                color: widget.active ? Colors.white : SsColors.ink,
                fontSize: 12,
                letterSpacing: 1.15,
                fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.tooltip,
    required this.icon,
    required this.route,
    required this.onTap,
    this.badge = 0,
  });

  final String tooltip;
  final IconData icon;
  final String route;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$tooltip${badge > 0 ? ', $badge items' : ''}',
      button: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: route == '/favorites'
                    ? const Color(0xFFFBE7ED)
                    : const Color(0xFFEAF1E6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: route == '/favorites'
                      ? SsColors.rose.withValues(alpha: 0.45)
                      : SsColors.clay.withValues(alpha: 0.42),
                ),
              ),
              child: IconButton(
                tooltip: tooltip,
                style: IconButton.styleFrom(
                  foregroundColor: SsColors.ink,
                  hoverColor: Colors.white.withValues(alpha: 0.7),
                  minimumSize: const Size(42, 42),
                ),
                icon: Icon(icon, size: 20),
                onPressed: onTap,
              ),
            ),
          ),
          if (badge > 0)
            Positioned(
              top: 8,
              right: 6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: SsColors.ink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge > 9 ? '9+' : '$badge',
                  style: const TextStyle(
                    color: SsColors.ivory,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileDrawer extends ConsumerWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: SsColors.ivory,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
              child: Text(
                SsBrand.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            for (final entry in const <_NavEntry>[
              _NavEntry('Home', '/'),
              _NavEntry('Shop', '/shop'),
              _NavEntry('Services', '/services'),
              _NavEntry('Story', '/story'),
              _NavEntry('Contact', '/contact'),
              _NavEntry('Favorites', '/favorites'),
              _NavEntry('Cart', '/cart'),
            ])
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(
                  entry.label,
                  style: const TextStyle(fontSize: 16, letterSpacing: 0.4),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(entry.route);
                },
              ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'A one-person atelier.\nMade with intention.',
              style: TextStyle(color: SsColors.inkMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavEntry {
  const _NavEntry(this.label, this.route);
  final String label;
  final String route;
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SsColors.surfaceMuted,
        border: Border(top: BorderSide(color: SsColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: SsResponsive(
        builder: (context, device) {
          final cols = device == SsDevice.phone ? 1 : 4;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: <Widget>[
                  SizedBox(
                    width: cols == 1
                        ? double.infinity
                        : (MediaQuery.sizeOf(context).width - 48) / cols - 18,
                    child: const _FooterBrand(),
                  ),
                  SizedBox(
                    width: cols == 1
                        ? double.infinity
                        : (MediaQuery.sizeOf(context).width - 48) / cols - 18,
                    child: const _FooterColumn(
                      title: 'Shop',
                      links: <(String, String)>[
                        ('All garments', '/shop'),
                        ('Made to measure', '/services'),
                        ('Alterations', '/services'),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: cols == 1
                        ? double.infinity
                        : (MediaQuery.sizeOf(context).width - 48) / cols - 18,
                    child: const _FooterColumn(
                      title: 'Atelier',
                      links: <(String, String)>[
                        ('Our story', '/story'),
                        ('Process', '/story'),
                        ('Contact', '/contact'),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: cols == 1
                        ? double.infinity
                        : (MediaQuery.sizeOf(context).width - 48) / cols - 18,
                    child: const _Newsletter(),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Divider(color: SsColors.divider),
              const SizedBox(height: 16),
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 24,
                runSpacing: 8,
                children: <Widget>[
                  Text(
                    SsBrand.copyright,
                    style: TextStyle(color: SsColors.inkMuted, fontSize: 12),
                  ),
                  Text(
                    'Demo store · No real transactions',
                    style: TextStyle(color: SsColors.inkMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          SsBrand.name,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontFamily: 'serif', fontSize: 22),
        ),
        const SizedBox(height: 8),
        const Text(
          'A one-person atelier in the\nEuropean tradition. Cut, sewn, and\nfinished by hand.',
          style: TextStyle(color: SsColors.inkMuted, height: 1.5, fontSize: 13),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});
  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: SsColors.inkMuted,
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        for (final l in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => GoRouter.of(context).go(l.$2),
              child: Text(
                l.$1,
                style: const TextStyle(fontSize: 14, color: SsColors.ink),
              ),
            ),
          ),
      ],
    );
  }
}

class _Newsletter extends StatefulWidget {
  const _Newsletter();

  @override
  State<_Newsletter> createState() => _NewsletterState();
}

class _NewsletterState extends State<_Newsletter> {
  final _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'LETTER',
          style: TextStyle(
            color: SsColors.inkMuted,
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'A short letter, once a month — process notes, new pieces, the occasional sale.',
          style: TextStyle(color: SsColors.ink, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 12),
        if (_submitted)
          const Text(
            'Thank you — please check your inbox.',
            style: TextStyle(color: SsColors.success, fontSize: 13),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final field = TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  isDense: true,
                ),
              );
              final button = ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isEmpty) return;
                  setState(() => _submitted = true);
                },
                child: const Text('SUBSCRIBE'),
              );

              if (constraints.maxWidth < 280) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    field,
                    const SizedBox(height: 8),
                    button,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: field),
                  const SizedBox(width: 8),
                  button,
                ],
              );
            },
          ),
        const SizedBox(height: 6),
        const Text(
          'Demo only — no email is collected or sent.',
          style: TextStyle(color: SsColors.inkMuted, fontSize: 11),
        ),
      ],
    );
  }
}
