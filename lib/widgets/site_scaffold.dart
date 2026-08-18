import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      toolbarHeight: 72,
      titleSpacing: 0,
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
          const SizedBox(width: 8),
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

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/'),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          SsBrand.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.route,
    required this.active,
  });
  final String label;
  final String route;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => context.go(route),
        style: TextButton.styleFrom(
          foregroundColor: active ? SsColors.ink : SsColors.inkMuted,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
            decoration: active ? TextDecoration.underline : null,
            decorationThickness: 1.2,
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
          IconButton(
            tooltip: tooltip,
            icon: Icon(icon, size: 20),
            onPressed: onTap,
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
