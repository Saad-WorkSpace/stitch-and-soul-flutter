import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/cart_notifier.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoCtrl = TextEditingController();
  String? _promoError;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final repo = ref.watch(productRepositoryProvider);
    final totals = cart.totals(repo);

    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            const _Heading(),
            const SizedBox(height: SsSpace.xl),
            if (cart.isEmpty)
              const _EmptyCart()
            else
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
                        flex: 6,
                        child: _Lines(cart: cart, repo: repo),
                      ),
                      SizedBox(
                        width: isWide ? SsSpace.xxl : 0,
                        height: isWide ? 0 : SsSpace.xl,
                      ),
                      SsFlexItem(
                        expand: isWide,
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _PromoBox(
                              controller: _promoCtrl,
                              error: _promoError,
                              applied: cart.appliedPromo,
                              onApply: () {
                                final err = cart.applyPromo(_promoCtrl.text);
                                setState(() => _promoError = err);
                              },
                              onClear: () {
                                cart.clearPromo();
                                _promoCtrl.clear();
                                setState(() => _promoError = null);
                              },
                            ),
                            const SizedBox(height: 16),
                            _Summary(totals: totals),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.go('/checkout'),
                                child: const Text('CONTINUE TO CHECKOUT'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.go('/shop'),
                              child: const Text('CONTINUE SHOPPING'),
                            ),
                          ],
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
}

class _Heading extends StatelessWidget {
  const _Heading();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('YOUR BAG', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text('Cart', style: Theme.of(context).textTheme.displaySmall),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SsSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Your bag is empty.',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Begin with a piece from the collection, or save a few favorites to come back to.',
            style: TextStyle(color: SsColors.inkMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () => context.go('/shop'),
                child: const Text('BROWSE THE COLLECTION'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => context.go('/favorites'),
                child: const Text('VIEW FAVORITES'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Lines extends ConsumerWidget {
  const _Lines({required this.cart, required this.repo});
  final CartNotifier cart;
  final ProductRepository repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        for (final l in cart.lines) ...<Widget>[
          _LineRow(line: l, repo: repo),
          const Divider(color: SsColors.divider, height: 32),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed:
                cart.lines.isEmpty ? null : () => _confirmClear(context, ref),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('CLEAR CART'),
          ),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SsColors.ivory,
        title: const Text('Clear the bag?'),
        content: const Text('This will remove all items from your cart.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}

class _LineRow extends ConsumerWidget {
  const _LineRow({required this.line, required this.repo});
  final CartLine line;
  final ProductRepository repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = repo.all().firstWhere(
          (p) => p.id == line.productId,
          orElse: () => _missing,
        );
    if (identical(p, _missing)) return const SizedBox.shrink();
    final unit = p.priceUSD * (line.madeToMeasure ? 1.25 : 1.0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 96,
          child: SsImagePlaceholder(
            label: p.galleryLabels.first,
            seed: p.id.hashCode,
            aspectRatio: 1,
            radius: SsRadii.sm,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      p.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '\$${(unit * line.quantity).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                p.tagline,
                style: const TextStyle(color: SsColors.inkMuted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  _MetaChip(label: 'Size · ${line.size}'),
                  _MetaChip(label: 'Color · ${line.colorName}'),
                  if (line.madeToMeasure)
                    const _MetaChip(label: 'Made to measure', filled: true),
                ],
              ),
              if (line.measurements != null) ...<Widget>[
                const SizedBox(height: 8),
                _MeasurementsSummary(profile: line.measurements!),
              ],
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  _QtyStepper(
                    value: line.quantity,
                    onChanged: (q) => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(line.lineId!, q),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(cartProvider.notifier)
                        .removeLine(line.lineId!),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('REMOVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static final Product _missing = Product(
    id: '__missing__',
    slug: '__missing__',
    name: 'Unknown',
    category: ProductCategory.tops,
    tagline: '',
    description: '',
    priceUSD: 0,
    sizes: const <SizeOption>[],
    colors: const <ColorOption>[],
    fabricTags: const <String>[],
    care: '',
    leadTimeDays: 0,
    mtmLeadTimeDays: 0,
    mtmAvailable: false,
    stock: 0,
    galleryLabels: const <String>[],
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class _MeasurementsSummary extends StatelessWidget {
  const _MeasurementsSummary({required this.profile});
  final MeasurementProfile profile;
  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (profile.bustCm != null) {
      parts.add('Bust ${profile.displayString(profile.bustCm)}');
    }
    if (profile.waistCm != null) {
      parts.add('Waist ${profile.displayString(profile.waistCm)}');
    }
    if (profile.hipsCm != null) {
      parts.add('Hips ${profile.displayString(profile.hipsCm)}');
    }
    if (profile.shoulderCm != null) {
      parts.add('Shoulder ${profile.displayString(profile.shoulderCm)}');
    }
    if (profile.sleeveCm != null) {
      parts.add('Sleeve ${profile.displayString(profile.sleeveCm)}');
    }
    if (profile.inseamCm != null) {
      parts.add('Inseam ${profile.displayString(profile.inseamCm)}');
    }
    if (profile.heightCm != null) {
      parts.add('Height ${profile.displayString(profile.heightCm)}');
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SsColors.surface,
        borderRadius: BorderRadius.circular(SsRadii.sm),
        border: Border.all(color: SsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Measurements · ${profile.fit.label} fit',
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
              color: SsColors.inkMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            parts.isEmpty
                ? 'No body measurements recorded.'
                : parts.join(' · '),
            style: const TextStyle(fontSize: 12, color: SsColors.ink),
          ),
          if ((profile.notes ?? '').isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Notes: ${profile.notes}',
              style: const TextStyle(fontSize: 12, color: SsColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, this.filled = false});
  final String label;
  final bool filled;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? SsColors.ink : SsColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: filled ? SsColors.ink : SsColors.divider),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? SsColors.ivory : SsColors.ink,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SsRadii.sm),
        border: Border.all(color: SsColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: 'Decrease',
            visualDensity: VisualDensity.compact,
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 14),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Increase',
            visualDensity: VisualDensity.compact,
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add, size: 14),
          ),
        ],
      ),
    );
  }
}

class _PromoBox extends StatelessWidget {
  const _PromoBox({
    required this.controller,
    required this.error,
    required this.applied,
    required this.onApply,
    required this.onClear,
  });
  final TextEditingController controller;
  final String? error;
  final String? applied;
  final VoidCallback onApply;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'PROMO CODE',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
            color: SsColors.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Try WELCOME10 or ATELIER15',
                  isDense: true,
                  errorText: error,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: applied == null ? onApply : onClear,
              child: Text(applied == null ? 'APPLY' : 'REMOVE'),
            ),
          ],
        ),
        if (applied != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Applied · $applied',
            style: const TextStyle(color: SsColors.success, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.totals});
  final CartTotals totals;
  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v == 0 ? 'Free' : '\$${v.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SsColors.surface,
        borderRadius: BorderRadius.circular(SsRadii.md),
        border: Border.all(color: SsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SumRow(label: 'Subtotal', value: fmt(totals.subtotal)),
          const SizedBox(height: 8),
          if (totals.discount > 0) ...<Widget>[
            _SumRow(
              label: 'Discount',
              value: '- ${fmt(totals.discount)}',
              muted: true,
            ),
            const SizedBox(height: 8),
          ],
          _SumRow(label: 'Shipping (estimated)', value: fmt(totals.shipping)),
          const SizedBox(height: 8),
          _SumRow(label: 'Tax (estimated)', value: fmt(totals.tax)),
          const Divider(color: SsColors.divider, height: 24),
          _SumRow(label: 'Total', value: fmt(totals.total), emphasized: true),
        ],
      ),
    );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: emphasized ? 15 : 13,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: emphasized ? 16 : 13,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
