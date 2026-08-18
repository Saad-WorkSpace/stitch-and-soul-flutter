import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/motion.dart';
import '../../app/tokens.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/product_card.dart';
import '../../widgets/responsive.dart';
import '../../widgets/site_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(productRepositoryProvider);
    final featured = repo.featured();
    final bestsellers = repo.bestsellers();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const _Hero(),
          SsPageScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: SsSpace.xxl),
                const SsSectionHeading(
                  eyebrow: 'New this season',
                  title: 'Featured pieces',
                  subtitle:
                      'A small, considered edit — built to last, and made to be lived in.',
                ),
                const SizedBox(height: SsSpace.lg),
                _ProductGrid(products: featured, columns: 3),
                const SizedBox(height: SsSpace.xxxl),
                const _MtmExplainer(),
                const SizedBox(height: SsSpace.xxxl),
                const SsSectionHeading(
                  eyebrow: 'Most loved',
                  title: 'Bestsellers',
                ),
                const SizedBox(height: SsSpace.lg),
                _ProductGrid(products: bestsellers, columns: 4),
                const SizedBox(height: SsSpace.xxxl),
                const _CraftsmanshipSnippet(),
                const SizedBox(height: SsSpace.xxxl),
                const _Testimonials(),
                const SizedBox(height: SsSpace.xxxl),
              ],
            ),
          ),
          const SiteFooter(),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SsColors.divider)),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: -120,
            right: -120,
            child: SsAnimatedOrb(color: SsColors.claySoft, size: 600),
          ),
          const Positioned(
            bottom: -160,
            left: -80,
            child: SsAnimatedOrb(color: SsColors.sageSoft, size: 460),
          ),
          SsPageScaffold(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SsSpace.xxxl),
              child: SsResponsive(
                builder: (context, device) {
                  final isWide =
                      device == SsDevice.desktop || device == SsDevice.wide;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SsFlexItem(
                        expand: isWide,
                        flex: 3,
                        child: SsStaggeredReveal(
                          children: <Widget>[
                            const _Eyebrow('A one-person atelier'),
                            const SizedBox(height: SsSpace.md),
                            Text(
                              'Garments, made slowly,\nfor the long table.',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.w400,
                                    height: 1.04,
                                  ),
                            ),
                            const SizedBox(height: SsSpace.lg),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: const Text(
                                'Stitch & Soul is a small atelier in the European '
                                'tradition — ready-to-wear pieces and made-to-measure '
                                'commissions, cut and sewn by hand, one at a time.',
                                style: TextStyle(
                                  color: SsColors.inkMuted,
                                  height: 1.6,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: SsSpace.xl),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () => context.go('/shop'),
                                  child: const Text('SHOP THE COLLECTION'),
                                ),
                                OutlinedButton(
                                  onPressed: () => context.go('/services'),
                                  child: const Text('MADE TO MEASURE'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isWide) const SizedBox(width: SsSpace.xxl),
                      if (isWide)
                        const Expanded(flex: 2, child: _HeroCollage()),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCollage extends StatelessWidget {
  const _HeroCollage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 4 / 5,
          child: SsImagePlaceholder(
            label: 'Atelier · Look 01',
            seed: 7,
            radius: SsRadii.md,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: SsImagePlaceholder(
                  label: 'Detail · Hem',
                  seed: 3,
                  radius: SsRadii.md,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: SsImagePlaceholder(
                  label: 'Detail · Buttons',
                  seed: 5,
                  radius: SsRadii.md,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(width: 28, height: 1, color: SsColors.ink),
        const SizedBox(width: 12),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: SsColors.inkMuted,
            fontSize: 11,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, this.columns = 3});
  final List<Product> products;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // For narrow widths we collapse to 2 columns; very narrow to 1.
        final cols = c.maxWidth < 520 ? 1 : (c.maxWidth < 900 ? 2 : columns);
        final cardWidth = (c.maxWidth - (cols - 1) * 24) / cols;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            mainAxisExtent: cardWidth + 118,
          ),
          itemBuilder: (context, i) => ProductCard(product: products[i]),
        );
      },
    );
  }
}

class _MtmExplainer extends StatelessWidget {
  const _MtmExplainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SsSpace.xxl),
      decoration: BoxDecoration(
        color: SsColors.surface,
        borderRadius: BorderRadius.circular(SsRadii.lg),
        border: Border.all(color: SsColors.divider),
      ),
      child: SsResponsive(
        builder: (context, device) {
          final isWide = device != SsDevice.phone;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SsFlexItem(
                expand: isWide,
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'MADE TO MEASURE',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A garment, made for one.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Every commission begins with a short conversation, a guided '
                      'measurement, and a fitting. We cut a paper pattern from your '
                      'numbers, then baste and fit before finishing the garment by hand.',
                      style: TextStyle(
                        color: SsColors.inkMuted,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/services'),
                      child: const Text('START A COMMISSION'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: isWide ? SsSpace.xxl : 0,
                height: isWide ? 0 : SsSpace.xl,
              ),
              SsFlexItem(
                expand: isWide,
                flex: 4,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _TimelineRow(
                      step: '01',
                      title: 'Consultation',
                      body:
                          'A 20-minute call about the piece you have in mind.',
                    ),
                    _TimelineRow(
                      step: '02',
                      title: 'Measurements',
                      body: 'A guided form, or a fitting at the atelier.',
                    ),
                    _TimelineRow(
                      step: '03',
                      title: 'Pattern & muslin',
                      body: 'We draft, then baste a first version in cotton.',
                    ),
                    _TimelineRow(
                      step: '04',
                      title: 'Final garment',
                      body: 'Cut, sewn, and finished by hand. 3–6 weeks.',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.title,
    required this.body,
  });
  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(
              step,
              style: const TextStyle(
                color: SsColors.inkMuted,
                fontSize: 12,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: SsColors.inkMuted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CraftsmanshipSnippet extends StatelessWidget {
  const _CraftsmanshipSnippet();

  @override
  Widget build(BuildContext context) {
    return SsResponsive(
      builder: (context, device) {
        final isWide = device != SsDevice.phone;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SsFlexItem(
              expand: isWide,
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'THE ATELIER',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Slow, honest, and a little stubborn.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We work in small batches, in natural fibers, with a short list '
                    'of trusted mills. A garment takes the time it takes — and is '
                    'worth the wait.',
                    style: TextStyle(
                      color: SsColors.inkMuted,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.go('/story'),
                    child: const Text('READ OUR STORY'),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: isWide ? SsSpace.xxl : 0,
              height: isWide ? 0 : SsSpace.xl,
            ),
            SsFlexItem(
              expand: isWide,
              flex: 5,
              child: const AspectRatio(
                aspectRatio: 4 / 3,
                child: SsImagePlaceholder(
                  label: 'Atelier · Bench',
                  seed: 11,
                  radius: SsRadii.md,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Testimonials extends StatefulWidget {
  const _Testimonials();

  @override
  State<_Testimonials> createState() => _TestimonialsState();
}

class _TestimonialsState extends State<_Testimonials> {
  final _quotes = const <(String, String, String)>[
    (
      'The linen dress arrived and I have not taken it off.',
      'Maya · made-to-measure commission',
      'A summer in Provence',
    ),
    (
      'A shirt that finally fits my shoulders.',
      'Theo · ready-to-wear',
      'Two years on, still wearing it',
    ),
    (
      'Communication throughout was honest and the fit is perfect.',
      'Lena · alteration + commission',
      'A wedding and a winter coat',
    ),
  ];
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final reduced = prefersReducedMotion(context);
    return MouseRegion(
      onEnter: (_) => _paused = true,
      onExit: (_) => _paused = false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SsSectionHeading(
            eyebrow: 'Notes from clients',
            title: 'A few kind words',
          ),
          const SizedBox(height: SsSpace.lg),
          Container(
            padding: const EdgeInsets.all(SsSpace.xxl),
            decoration: BoxDecoration(
              color: SsColors.surface,
              border: Border.all(color: SsColors.divider),
              borderRadius: BorderRadius.circular(SsRadii.lg),
            ),
            child: AnimatedSwitcher(
              duration: SsDurations.medium,
              child: Column(
                key: ValueKey<int>(_i),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '“${_quotes[_i].$1}”',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _quotes[_i].$2,
                    style: const TextStyle(color: SsColors.ink, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _quotes[_i].$3,
                    style: const TextStyle(
                      color: SsColors.inkMuted,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              for (int i = 0; i < _quotes.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _i ? SsColors.ink : SsColors.divider,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Previous',
                onPressed: () => setState(
                  () => _i = (_i - 1 + _quotes.length) % _quotes.length,
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
              ),
              IconButton(
                tooltip: 'Next',
                onPressed: () => setState(() => _i = (_i + 1) % _quotes.length),
                icon: const Icon(Icons.arrow_forward, size: 18),
              ),
            ],
          ),
          if (reduced) const SizedBox.shrink(),
        ],
      ),
    );
  }

  bool _paused = false;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    _rotationTimer = Timer(const Duration(seconds: 7), () {
      if (!mounted) return;
      if (!_paused) {
        setState(() => _i = (_i + 1) % _quotes.length);
      }
      _schedule();
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }
}
