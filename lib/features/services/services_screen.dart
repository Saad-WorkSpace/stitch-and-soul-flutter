import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: SsSpace.lg),
            SsSectionHeading(
              eyebrow: 'Tailoring, with you in mind',
              title: 'Services',
              subtitle:
                  'Three ways to work with us — from a single measurement to a full commission.',
            ),
            SizedBox(height: SsSpace.xl),
            _ServiceGrid(),
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
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  @override
  Widget build(BuildContext context) {
    final services = <_Service>[
      _Service(
        title: 'Made to measure',
        kicker: 'A garment, made for one',
        body:
            'A full commission, from consultation to finished garment. Cut and '
            'sewn to your measurements with a fitting at the muslin stage.',
        price: 'From \$${(280 * 1.25).toStringAsFixed(0)}',
        eta: '3 – 6 weeks',
        cta: 'Start a commission',
        onTap: () => context.go('/measurements/new'),
      ),
      _Service(
        title: 'Alterations',
        kicker: 'Refit what you already love',
        body: 'Hem, take-in, let-out, sleeve length, and restyling. Bring an '
            'existing garment back to the atelier for an assessment.',
        price: 'From \$45',
        eta: '1 – 2 weeks',
        cta: 'Book a fitting',
        onTap: () => context.go('/contact'),
      ),
      _Service(
        title: 'Consultation',
        kicker: 'A short call to start',
        body: 'A 20-minute video call to talk through a piece, a project, or a '
            'gift. Honest advice, no obligation.',
        price: 'Complimentary',
        eta: 'Within a week',
        cta: 'Schedule a call',
        onTap: () => context.go('/contact'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 700 ? 1 : 3;
        return GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: cols == 1 ? 1.4 : 0.95,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[for (final s in services) _ServiceCard(s: s)],
        );
      },
    );
  }
}

class _Service {
  const _Service({
    required this.title,
    required this.kicker,
    required this.body,
    required this.price,
    required this.eta,
    required this.cta,
    required this.onTap,
  });
  final String title;
  final String kicker;
  final String body;
  final String price;
  final String eta;
  final String cta;
  final VoidCallback onTap;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.s});
  final _Service s;

  @override
  Widget build(BuildContext context) {
    return SsHoverCard(
      onTap: s.onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            s.kicker.toUpperCase(),
            style: const TextStyle(
              color: SsColors.inkMuted,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(s.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              s.body,
              style: const TextStyle(
                color: SsColors.inkMuted,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                s.price,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                s.eta,
                style: const TextStyle(color: SsColors.inkMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: s.onTap, child: Text(s.cta.toUpperCase())),
        ],
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
