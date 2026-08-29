import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/motion.dart';
import '../../app/tokens.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _ServicesPricingSection(),
          SsPageScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: SsSpace.xxxl),
                SsSectionHeading(
                  eyebrow: 'How it works',
                  title: 'A transparent process',
                ),
                SizedBox(height: SsSpace.lg),
                _ProcessTimeline(),
                SizedBox(height: SsSpace.xxxl),
                _ConsultationCta(),
                SizedBox(height: SsSpace.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesPricingSection extends StatelessWidget {
  const _ServicesPricingSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF172019),
      child: SsPageScaffold(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SsSpace.xxxl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tailoring, shaped around you.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: SsColors.ivory,
                          fontFamily: 'sans-serif',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.2,
                          height: 1.02,
                        ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 610),
                    child: const Text(
                      'Three clear ways to work with the atelier — from a first '
                      'conversation to a garment made entirely for you.',
                      style: TextStyle(
                        color: Color(0xFFB9B8B0),
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (compact) ...<Widget>[
                    const _MotionSectionLabel(),
                    const SizedBox(height: SsSpace.xl),
                    heading,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          width: 255,
                          child: _MotionSectionLabel(),
                        ),
                        const SizedBox(width: SsSpace.xl),
                        Expanded(child: heading),
                        const _AtelierPlusMark(),
                      ],
                    ),
                  const SizedBox(height: SsSpace.xxl),
                  const _ServiceGrid(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MotionSectionLabel extends StatelessWidget {
  const _MotionSectionLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Text(
          '01',
          style: TextStyle(
            color: SsColors.claySoft,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'SERVICES',
          style: TextStyle(
            color: Color(0xFFAAA9A2),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

class _AtelierPlusMark extends StatelessWidget {
  const _AtelierPlusMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(color: SsColors.claySoft),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            color: SsColors.clay,
            alignment: Alignment.center,
            child: const Icon(Icons.content_cut, size: 17, color: SsColors.ink),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '+',
                style: TextStyle(
                  color: SsColors.claySoft,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  @override
  Widget build(BuildContext context) {
    final services = <_Service>[
      _Service(
        index: '01',
        tag: 'RECOMMENDED',
        title: 'Made to measure',
        description:
            'A full commission, from consultation to finished garment. Cut and '
            'sewn to your measurements with a fitting at the muslin stage.',
        price: r'$350',
        priceNote: 'FROM · 3–6 WEEKS',
        features: <String>[
          'Private design consultation',
          'Guided measurement profile',
          'Muslin fitting and adjustment',
          'Hand-finished final garment',
        ],
        cta: 'Start a commission',
        featured: true,
        onTap: () => context.go('/measurements/new'),
      ),
      _Service(
        index: '02',
        tag: 'REFIT & RESTYLE',
        title: 'Alterations',
        description:
            'Hem, take-in, let-out, sleeve length, and restyling. Bring an '
            'existing garment back to the atelier for an assessment.',
        price: r'$45',
        priceNote: 'FROM · 1–2 WEEKS',
        features: <String>[
          'In-person garment assessment',
          'Hem, take-in and let-out',
          'Sleeve and fit adjustments',
          'Thoughtful restyling guidance',
        ],
        cta: 'Book a fitting',
        featured: false,
        onTap: () => context.go('/contact'),
      ),
      _Service(
        index: '03',
        tag: 'START HERE',
        title: 'Consultation',
        description:
            'A 20-minute video call to talk through a piece, a project, or a '
            'gift. Honest advice, no obligation.',
        price: r'$0',
        priceNote: 'COMPLIMENTARY · WITHIN A WEEK',
        features: <String>[
          'Private 20-minute video call',
          'Fabric and silhouette guidance',
          'Clear scope and timing advice',
          'No pressure or obligation',
        ],
        cta: 'Schedule a call',
        featured: false,
        onTap: () => context.go('/contact'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 820;
        return ClipRRect(
          borderRadius: BorderRadius.circular(SsRadii.lg),
          child: compact
              ? Column(
                  children: <Widget>[
                    for (final service in services)
                      SizedBox(
                        height: 530,
                        child: _ServiceCard(service: service),
                      ),
                  ],
                )
              : SizedBox(
                  height: 620,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final service in services)
                        Expanded(child: _ServiceCard(service: service)),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _Service {
  const _Service({
    required this.index,
    required this.tag,
    required this.title,
    required this.description,
    required this.price,
    required this.priceNote,
    required this.features,
    required this.cta,
    required this.featured,
    required this.onTap,
  });
  final String index;
  final String tag;
  final String title;
  final String description;
  final String price;
  final String priceNote;
  final List<String> features;
  final String cta;
  final bool featured;
  final VoidCallback onTap;
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.service});
  final _Service service;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final foreground = service.featured ? SsColors.ink : SsColors.ivory;
    final muted = service.featured
        ? SsColors.ink.withValues(alpha: 0.70)
        : const Color(0xFFB9B8B0);
    final background = service.featured
        ? (_hovered ? const Color(0xFF91A68B) : const Color(0xFF7F947A))
        : (_hovered ? const Color(0xFF2B3A2E) : const Color(0xFF1D2920));

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: SsDurations.short,
        curve: SsCurves.emphasized,
        color: background,
        padding: const EdgeInsets.all(34),
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            color: _hovered
                ? SsColors.claySoft.withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  service.index,
                  style: TextStyle(
                    color: service.featured ? SsColors.ink : SsColors.claySoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const Spacer(),
                Text(
                  service.tag,
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 52),
            Text(
              service.title,
              style: TextStyle(
                color: foreground,
                fontFamily: 'sans-serif',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.description,
              style: TextStyle(color: muted, fontSize: 13, height: 1.52),
            ),
            const SizedBox(height: 34),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 12,
              runSpacing: 6,
              children: <Widget>[
                Text(
                  service.price,
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'sans-serif',
                    fontSize: 56,
                    height: 0.92,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    service.priceNote,
                    style: TextStyle(
                      color: muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Divider(color: foreground.withValues(alpha: 0.20)),
            const SizedBox(height: 18),
            for (final feature in service.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '+',
                      style: TextStyle(
                        color:
                            service.featured ? SsColors.ink : SsColors.claySoft,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            _ServiceAction(
              label: service.cta,
              onTap: service.onTap,
              featured: service.featured,
              hovered: _hovered,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceAction extends StatelessWidget {
  const _ServiceAction({
    required this.label,
    required this.onTap,
    required this.featured,
    required this.hovered,
  });

  final String label;
  final VoidCallback onTap;
  final bool featured;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final background = featured ? SsColors.ink : SsColors.clay;
    final foreground = featured ? SsColors.ivory : SsColors.ink;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: foreground,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.45,
                    ),
                  ),
                ),
                AnimatedSlide(
                  offset: hovered ? const Offset(0.22, 0) : Offset.zero,
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
    );
  }
}

class _ProcessTimeline extends StatelessWidget {
  const _ProcessTimeline();
  @override
  Widget build(BuildContext context) {
    final steps = <(String, String, String)>[
      (
        '01',
        'Consultation',
        'A short call about the piece, your needs, and a timeline.',
      ),
      (
        '02',
        'Measurements',
        'A guided form here, or a fitting at the atelier.',
      ),
      (
        '03',
        'Muslin & fitting',
        'We baste the garment in cotton, then fit and adjust.',
      ),
      (
        '04',
        'Final garment',
        'Cut and sewn in the chosen fabric, finished by hand.',
      ),
      (
        '05',
        'Care & check-in',
        'We follow up after the first wash, six months in.',
      ),
    ];
    return Column(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 56,
                  child: Text(
                    steps[i].$1,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      color: SsColors.inkMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        steps[i].$2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i].$3,
                        style: const TextStyle(
                          color: SsColors.inkMuted,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConsultationCta extends StatelessWidget {
  const _ConsultationCta();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SsSpace.xxl),
      decoration: BoxDecoration(
        color: SsColors.ink,
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
                      'A short call is the best place to start.',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: SsColors.ivory,
                                fontFamily: 'serif',
                              ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Twenty minutes, no obligation. We will talk about the piece, '
                      'fabric, and timing — and tell you honestly whether we are the '
                      'right fit for what you have in mind.',
                      style: TextStyle(
                        color: SsColors.ivory,
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
                child: OutlinedButton(
                  onPressed: () => context.go('/contact'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SsColors.ivory),
                    foregroundColor: SsColors.ivory,
                  ),
                  child: const Text('BOOK A CONSULTATION'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
