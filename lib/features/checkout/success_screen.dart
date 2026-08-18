import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = GoRouterState.of(context).uri.queryParameters['order'] ??
        'SS-DEMO-0000';
    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            const SsSectionHeading(
              eyebrow: 'Order received',
              title: 'Thank you.',
              subtitle:
                  'A confirmation note would normally land in your inbox.',
            ),
            const SizedBox(height: SsSpace.xl),
            Container(
              padding: const EdgeInsets.all(SsSpace.xl),
              decoration: BoxDecoration(
                color: SsColors.surface,
                border: Border.all(color: SsColors.divider),
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
                              'ORDER',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(fontFamily: 'serif'),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Demo receipt — no order has been placed, no payment has been taken.',
                              style: TextStyle(
                                color: SsColors.inkMuted,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isWide) const SizedBox(width: SsSpace.xl),
                      Padding(
                        padding: EdgeInsets.only(top: isWide ? 0 : 16),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _Row(
                              label: 'Estimated ship',
                              value: '3 – 7 business days',
                            ),
                            _Row(
                              label: 'Atelier',
                              value: '14 Rue des Tisserands, Studio 3',
                            ),
                            _Row(
                              label: 'Contact',
                              value: 'hello@stitchandsoul.demo',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: SsSpace.xl),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('BACK TO HOME'),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/shop'),
                  child: const Text('CONTINUE BROWSING'),
                ),
              ],
            ),
            const SizedBox(height: SsSpace.xxl),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: SsColors.inkMuted,
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
