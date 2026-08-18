import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            const SsSectionHeading(
              eyebrow: 'The atelier',
              title: 'A small studio, run by one.',
              subtitle: 'Where the work happens, and why.',
            ),
            const SizedBox(height: SsSpace.xl),
            SsResponsive(
              builder: (context, device) {
                final isWide =
                    device == SsDevice.desktop || device == SsDevice.wide;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SsFlexItem(
                      expand: isWide,
                      flex: 5,
                      child: const AspectRatio(
                        aspectRatio: 4 / 5,
                        child: SsImagePlaceholder(
                          label: 'The atelier',
                          seed: 21,
                          radius: SsRadii.md,
                        ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _StoryParagraph(
                            text:
                                'Stitch & Soul began in a small room above a print shop, '
                                'with a single used sewing machine and a stack of fabric '
                                'samples from a mill that no longer exists.',
                          ),
                          SizedBox(height: 14),
                          _StoryParagraph(
                            text:
                                'We work the way the European ateliers worked a century '
                                'ago: one garment at a time, with a paper pattern cut from '
                                'your measurements, a muslin fitted and adjusted, and a '
                                'final piece sewn and finished by hand.',
                          ),
                          SizedBox(height: 14),
                          _StoryParagraph(
                            text:
                                'It is slower. It is, candidly, more expensive. It is also '
                                'the only way we know how to make something that earns its '
                                'place in your wardrobe.',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: SsSpace.xxxl),
            const SsSectionHeading(
              eyebrow: 'Process',
              title: 'How a piece comes to life',
            ),
            const SizedBox(height: SsSpace.lg),
            const _ProcessCards(),
            const SizedBox(height: SsSpace.xxxl),
            const _Materials(),
            const SizedBox(height: SsSpace.xxxl),
            const _VisitCta(),
            const SizedBox(height: SsSpace.xxl),
          ],
        ),
      ),
    );
  }
}

class _StoryParagraph extends StatelessWidget {
  const _StoryParagraph({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.7, color: SsColors.ink),
    );
  }
}

class _ProcessCards extends StatelessWidget {
  const _ProcessCards();
  @override
  Widget build(BuildContext context) {
    final cards = <(String, String, String, IconData)>[
      (
        'Paper',
        'A pattern, drafted from your measurements.',
        'Each commission begins on paper.',
        Icons.draw,
      ),
      (
        'Muslin',
        'A first version in cotton, fitted and adjusted.',
        'Fit before fabric.',
        Icons.checkroom,
      ),
      (
        'Cut',
        'The chosen fabric, cut by hand.',
        'A single panel at a time.',
        Icons.content_cut,
      ),
      (
        'Sew',
        'Seams stitched, hems rolled, buttons attached.',
        'Finished by hand.',
        Icons.handyman_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 700 ? 2 : 4;
        return GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            for (final c in cards)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SsColors.surface,
                  borderRadius: BorderRadius.circular(SsRadii.md),
                  border: Border.all(color: SsColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(c.$4, color: SsColors.ink, size: 20),
                    const Spacer(),
                    Text(c.$1, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      c.$2,
                      style: const TextStyle(
                        color: SsColors.inkMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.$3,
                      style: const TextStyle(
                        color: SsColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Materials extends StatelessWidget {
  const _Materials();
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
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'MATERIALS',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What we work with, and why.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Natural fibers, short supply chains, and a tight list of mills '
                    'we trust. We buy in small batches and order ahead, so the fabrics '
                    'we use are the ones we believe in.',
                    style: TextStyle(
                      color: SsColors.inkMuted,
                      height: 1.6,
                      fontSize: 15,
                    ),
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
              child: const Column(
                children: <Widget>[
                  _MaterialRow(
                    name: 'European linen',
                    detail: 'Belgium & Italy · mid- to heavyweight',
                  ),
                  Divider(color: SsColors.divider, height: 32),
                  _MaterialRow(
                    name: 'British waxed cotton',
                    detail: 'Halley Stevensons · for outerwear',
                  ),
                  Divider(color: SsColors.divider, height: 32),
                  _MaterialRow(
                    name: 'Italian merino',
                    detail: 'Zegna Baruffa · for knitwear',
                  ),
                  Divider(color: SsColors.divider, height: 32),
                  _MaterialRow(
                    name: 'Sandwashed silk',
                    detail: 'Como, Italy · for slip & camisole',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.name, required this.detail});
  final String name;
  final String detail;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          detail,
          style: const TextStyle(color: SsColors.inkMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _VisitCta extends StatelessWidget {
  const _VisitCta();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SsSpace.xxl),
      decoration: BoxDecoration(
        color: SsColors.surfaceMuted,
        borderRadius: BorderRadius.circular(SsRadii.lg),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'VISIT',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Come by the atelier.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fittings are by appointment. The atelier is in a quiet '
                      'street above a print shop, with the door painted a deep ink.',
                      style: TextStyle(
                        color: SsColors.inkMuted,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWide) const SizedBox(width: SsSpace.xxl),
              Padding(
                padding: EdgeInsets.only(top: isWide ? 0 : 16),
                child: ElevatedButton(
                  onPressed: () => context.go('/contact'),
                  child: const Text('GET IN TOUCH'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
