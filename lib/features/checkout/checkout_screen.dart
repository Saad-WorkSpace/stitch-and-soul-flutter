import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/cart_notifier.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _city = TextEditingController();
  final _region = TextEditingController();
  final _postal = TextEditingController();
  String _fulfillment = 'ship';
  bool _giftWrap = false;
  String? _giftMessage;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address1.dispose();
    _address2.dispose();
    _city.dispose();
    _region.dispose();
    _postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final repo = ref.watch(productRepositoryProvider);
    final totals = cart.totals(repo);

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Your bag is empty.',
                style: TextStyle(fontFamily: 'serif', fontSize: 22),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a piece to checkout.',
                style: TextStyle(color: SsColors.inkMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/shop'),
                child: const Text('BROWSE THE COLLECTION'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            SsSectionHeading(
              eyebrow: 'Checkout',
              title: _stepTitle(),
              subtitle: 'Demo only — nothing is charged or stored.',
            ),
            const SizedBox(height: SsSpace.lg),
            _StepBar(step: _step),
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
                      flex: 7,
                      child: _stepBody(cart, repo, totals),
                    ),
                    SizedBox(
                      width: isWide ? SsSpace.xxl : 0,
                      height: isWide ? 0 : SsSpace.xl,
                    ),
                    SsFlexItem(
                      expand: isWide,
                      flex: 5,
                      child: _OrderSummary(
                        cart: cart,
                        repo: repo,
                        totals: totals,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: SsSpace.xxl),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Contact';
      case 1:
        return 'Delivery';
      case 2:
        return 'Review & place';
    }
    return 'Checkout';
  }

  Widget _stepBody(
    CartNotifier cart,
    ProductRepository repo,
    CartTotals totals,
  ) {
    switch (_step) {
      case 0:
        return _ContactStep(
          formKey: _formKey,
          name: _name,
          email: _email,
          phone: _phone,
          onBack: () => context.go('/cart'),
          onNext: () {
            if (_formKey.currentState?.validate() ?? false) {
              setState(() => _step = 1);
            }
          },
        );
      case 1:
        return _DeliveryStep(
          formKey: _formKey,
          fulfillment: _fulfillment,
          giftWrap: _giftWrap,
          giftMessage: _giftMessage,
          address1: _address1,
          address2: _address2,
          city: _city,
          region: _region,
          postal: _postal,
          onFulfillmentChanged: (v) => setState(() => _fulfillment = v),
          onGiftChanged: (v) => setState(() => _giftWrap = v),
          onMessageChanged: (v) => setState(() => _giftMessage = v),
          onBack: () => setState(() => _step = 0),
          onNext: () {
            if (_fulfillment == 'pickup' ||
                (_formKey.currentState?.validate() ?? false)) {
              setState(() => _step = 2);
            }
          },
        );
      case 2:
        return _ReviewStepCard(
          cart: cart,
          repo: repo,
          totals: totals,
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          fulfillment: _fulfillment,
          address1: _address1.text,
          address2: _address2.text,
          city: _city.text,
          region: _region.text,
          postal: _postal.text,
          giftWrap: _giftWrap,
          giftMessage: _giftMessage,
          onBack: () => setState(() => _step = 1),
          onPlace: () {
            final id = _generateOrderId();
            ref.read(cartProvider.notifier).clear();
            context.go('/checkout/success?order=$id');
          },
        );
    }
    return const SizedBox.shrink();
  }
}

String _generateOrderId() {
  final now = DateTime.now();
  final ymd =
      '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  final r = now.microsecondsSinceEpoch
      .remainder(9999)
      .abs()
      .toString()
      .padLeft(4, '0');
  return 'SS-$ymd-$r';
}

// ── Stepper bar ──────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});
  final int step;
  @override
  Widget build(BuildContext context) {
    const labels = ['Contact', 'Delivery', 'Review'];
    return Row(
      children: <Widget>[
        for (int i = 0; i < labels.length; i++) ...<Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 2,
                  color: i <= step ? SsColors.ink : SsColors.divider,
                ),
                const SizedBox(height: 6),
                Text(
                  '${(i + 1).toString().padLeft(2, '0')} ${labels[i]}',
                  style: TextStyle(
                    color: i == step ? SsColors.ink : SsColors.inkMuted,
                    fontSize: 12,
                    fontWeight: i == step ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (i < labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

// ── Steps ────────────────────────────────────────────────────────────────

class _ContactStep extends StatelessWidget {
  const _ContactStep({
    required this.formKey,
    required this.name,
    required this.email,
    required this.phone,
    required this.onNext,
    required this.onBack,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final VoidCallback onNext;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'How can we reach you?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please share your name.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please share an email.';
              if (!v.contains('@') || !v.contains('.')) {
                return 'That email looks off.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              OutlinedButton(
                onPressed: onBack,
                child: const Text('BACK TO BAG'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: onNext, child: const Text('CONTINUE')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({
    required this.formKey,
    required this.fulfillment,
    required this.giftWrap,
    required this.giftMessage,
    required this.address1,
    required this.address2,
    required this.city,
    required this.region,
    required this.postal,
    required this.onFulfillmentChanged,
    required this.onGiftChanged,
    required this.onMessageChanged,
    required this.onNext,
    required this.onBack,
  });
  final GlobalKey<FormState> formKey;
  final String fulfillment;
  final bool giftWrap;
  final String? giftMessage;
  final TextEditingController address1;
  final TextEditingController address2;
  final TextEditingController city;
  final TextEditingController region;
  final TextEditingController postal;
  final ValueChanged<String> onFulfillmentChanged;
  final ValueChanged<bool> onGiftChanged;
  final ValueChanged<String> onMessageChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'How would you like it?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          for (final opt in const <(String, String, String)>[
            (
              'ship',
              'Ship',
              'Tracked, signature on delivery. 3 – 7 business days.',
            ),
            (
              'pickup',
              'Atelier pickup',
              'Collect from the studio by appointment.',
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onFulfillmentChanged(opt.$1),
                borderRadius: BorderRadius.circular(SsRadii.sm),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        fulfillment == opt.$1 ? SsColors.ink : SsColors.surface,
                    border: Border.all(
                      color: fulfillment == opt.$1
                          ? SsColors.ink
                          : SsColors.divider,
                    ),
                    borderRadius: BorderRadius.circular(SsRadii.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        fulfillment == opt.$1
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: fulfillment == opt.$1
                            ? SsColors.ivory
                            : SsColors.ink,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              opt.$2,
                              style: TextStyle(
                                color: fulfillment == opt.$1
                                    ? SsColors.ivory
                                    : SsColors.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              opt.$3,
                              style: TextStyle(
                                color: fulfillment == opt.$1
                                    ? SsColors.ivory.withValues(alpha: 0.75)
                                    : SsColors.inkMuted,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (fulfillment == 'ship') ...<Widget>[
            const SizedBox(height: 16),
            TextFormField(
              controller: address1,
              decoration: const InputDecoration(labelText: 'Address line 1'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please add a street address.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: address2,
              decoration: const InputDecoration(
                labelText: 'Address line 2 (optional)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: city,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required.' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: region,
                    decoration: const InputDecoration(
                      labelText: 'State / region',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required.' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: postal,
                    decoration: const InputDecoration(labelText: 'Postal code'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required.' : null,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          InkWell(
            onTap: () => onGiftChanged(!giftWrap),
            borderRadius: BorderRadius.circular(SsRadii.sm),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SsColors.surface,
                border: Border.all(color: SsColors.divider),
                borderRadius: BorderRadius.circular(SsRadii.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    giftWrap ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 20,
                    color: giftWrap ? SsColors.ink : SsColors.inkMuted,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Add gift wrapping',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'A short note on kraft paper, with a hand-tied ribbon.',
                          style: TextStyle(
                            color: SsColors.inkMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (giftWrap) ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              onChanged: onMessageChanged,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'A short note (optional)',
                alignLabelWithHint: true,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              OutlinedButton(onPressed: onBack, child: const Text('BACK')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onNext,
                child: const Text('REVIEW ORDER'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewStepCard extends StatelessWidget {
  const _ReviewStepCard({
    required this.cart,
    required this.repo,
    required this.totals,
    required this.name,
    required this.email,
    required this.phone,
    required this.fulfillment,
    required this.address1,
    required this.address2,
    required this.city,
    required this.region,
    required this.postal,
    required this.giftWrap,
    required this.giftMessage,
    required this.onBack,
    required this.onPlace,
  });
  final CartNotifier cart;
  final ProductRepository repo;
  final CartTotals totals;
  final String name;
  final String email;
  final String phone;
  final String fulfillment;
  final String address1;
  final String address2;
  final String city;
  final String region;
  final String postal;
  final bool giftWrap;
  final String? giftMessage;
  final VoidCallback onBack;
  final VoidCallback onPlace;
  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v == 0 ? 'Free' : '\$${v.toStringAsFixed(2)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Please confirm.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _ReviewCard(
          title: 'CONTACT',
          rows: <(String, String)>[
            ('Name', name.isEmpty ? '—' : name),
            ('Email', email.isEmpty ? '—' : email),
            ('Phone', phone.isEmpty ? '—' : phone),
          ],
        ),
        const SizedBox(height: 12),
        _ReviewCard(
          title: fulfillment == 'ship' ? 'SHIP TO' : 'PICKUP',
          rows: fulfillment == 'ship'
              ? <(String, String)>[
                  (
                    'Address',
                    <String>[
                      address1,
                      if (address2.isNotEmpty) address2,
                      '$city, $region $postal',
                    ].where((s) => s.isNotEmpty).join('\n'),
                  ),
                ]
              : <(String, String)>[
                  ('Atelier', '14 Rue des Tisserands, Studio 3'),
                ],
        ),
        if (giftWrap) ...<Widget>[
          const SizedBox(height: 12),
          _ReviewCard(
            title: 'GIFT',
            rows: <(String, String)>[
              ('Wrapping', 'Yes'),
              if ((giftMessage ?? '').isNotEmpty) ('Note', giftMessage!),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _ReviewCard(
          title: 'PAYMENT',
          rows: <(String, String)>[
            ('Method', 'Demo card · no charge'),
            ('Total', fmt(totals.total)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SsColors.surfaceMuted,
            borderRadius: BorderRadius.circular(SsRadii.sm),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.lock_outline, size: 16, color: SsColors.inkMuted),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No real card data is collected. This is a demo checkout — the order is mocked.',
                  style: TextStyle(
                    color: SsColors.inkMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            OutlinedButton(onPressed: onBack, child: const Text('BACK')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onPlace,
              child: Text('PLACE DEMO ORDER · ${fmt(totals.total)}'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SsColors.surface,
        border: Border.all(color: SsColors.divider),
        borderRadius: BorderRadius.circular(SsRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: SsColors.inkMuted,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (final r in rows) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 90,
                  child: Text(
                    r.$1,
                    style: const TextStyle(
                      color: SsColors.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    r.$2,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.cart,
    required this.repo,
    required this.totals,
  });
  final CartNotifier cart;
  final ProductRepository repo;
  final CartTotals totals;
  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v == 0 ? 'Free' : '\$${v.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SsColors.surface,
        border: Border.all(color: SsColors.divider),
        borderRadius: BorderRadius.circular(SsRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('YOUR ORDER', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          for (final l in cart.lines) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${l.quantity}× ${_name(l.productId)}',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  fmt(_price(l) * l.quantity),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          const Divider(color: SsColors.divider, height: 24),
          _SumRow(label: 'Subtotal', value: fmt(totals.subtotal)),
          if (totals.discount > 0)
            _SumRow(
              label: 'Discount',
              value: '- ${fmt(totals.discount)}',
              muted: true,
            ),
          _SumRow(label: 'Shipping', value: fmt(totals.shipping)),
          _SumRow(label: 'Tax', value: fmt(totals.tax)),
          const Divider(color: SsColors.divider, height: 24),
          _SumRow(label: 'Total', value: fmt(totals.total), emphasized: true),
        ],
      ),
    );
  }

  String _name(String id) {
    for (final p in repo.all()) {
      if (p.id == id) return p.name;
    }
    return 'Item';
  }

  double _price(CartLine l) {
    for (final p in repo.all()) {
      if (p.id == l.productId) {
        return p.priceUSD * (l.madeToMeasure ? 1.25 : 1.0);
      }
    }
    return 0;
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.muted = false,
  });
  final String label;
  final String value;
  final bool emphasized;
  final bool muted;
  @override
  Widget build(BuildContext context) {
    final color = muted ? SsColors.inkMuted : SsColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: emphasized ? 14 : 12,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: emphasized ? 15 : 12,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
