import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/motion.dart';
import '../../app/tokens.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/cart_notifier.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/product_card.dart';
import '../../widgets/responsive.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.slug});
  final String slug;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  String? _size;
  String? _color;
  int _qty = 1;
  bool _madeToMeasure = false;
  int _activeImage = 0;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(productRepositoryProvider);
    final product = repo.bySlug(widget.slug);

    if (product == null) {
      return const Center(child: Text('Product not found.'));
    }

    final p = product;

    // Default selections to first available option.
    _size ??=
        p.sizes.firstWhere((s) => s.inStock, orElse: () => p.sizes.first).label;
    _color ??= p.colors.first.name;

    final related = repo.related(p);
    final fav = ref.watch(favoritesProvider);
    final isFav = fav.isFavorite(p.id);

    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            _Breadcrumb(category: p.category.label, name: p.name),
            const SizedBox(height: SsSpace.lg),
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
                      child: _Gallery(
                        product: p,
                        active: _activeImage,
                        onSelect: (i) => setState(() => _activeImage = i),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? SsSpace.xxl : 0,
                      height: isWide ? 0 : SsSpace.xl,
                    ),
                    SsFlexItem(
                      expand: isWide,
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _EyebrowText(p.category.label.toUpperCase()),
                          const SizedBox(height: 8),
                          Text(
                            p.name,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.tagline,
                            style: const TextStyle(
                              color: SsColors.inkMuted,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '\$${p.priceUSD.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (p.mtmAvailable)
                            Text(
                              'or from \$${(p.priceUSD * 1.25).toStringAsFixed(0)} made-to-measure',
                              style: const TextStyle(
                                color: SsColors.inkMuted,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(height: 8),
                          _AvailabilityPill(product: p),
                          const SizedBox(height: 24),
                          _ColorPicker(
                            options: p.colors,
                            selected: _color!,
                            onChanged: (c) => setState(() => _color = c),
                          ),
                          const SizedBox(height: 20),
                          _SizePicker(
                            options: p.sizes,
                            selected: _size!,
                            onChanged: (s) => setState(() => _size = s),
                          ),
                          const SizedBox(height: 20),
                          if (p.mtmAvailable) ...<Widget>[
                            _MtmToggle(
                              value: _madeToMeasure,
                              onChanged: (v) =>
                                  setState(() => _madeToMeasure = v),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Row(
                            children: <Widget>[
                              _QuantityStepper(
                                value: _qty,
                                onChanged: (v) => setState(() => _qty = v),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PrimaryCta(
                                  product: p,
                                  size: _size!,
                                  color: _color!,
                                  quantity: _qty,
                                  madeToMeasure: _madeToMeasure,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              OutlinedButton.icon(
                                onPressed: () => ref
                                    .read(favoritesProvider.notifier)
                                    .toggle(p.id),
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 16,
                                  color: isFav ? SsColors.clay : SsColors.ink,
                                ),
                                label: Text(isFav ? 'SAVED' : 'SAVE'),
                              ),
                              const SizedBox(width: 12),
                              if (p.mtmAvailable)
                                OutlinedButton(
                                  onPressed: () => context.go(
                                    '/measurements/new?product=${p.slug}',
                                  ),
                                  child: const Text('START A COMMISSION'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _Description(product: p),
                          const SizedBox(height: 16),
                          _CareInfo(product: p),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: SsSpace.xxxl),
            if (related.isNotEmpty) ...<Widget>[
              const SsSectionHeading(
                eyebrow: 'You might also like',
                title: 'Related pieces',
              ),
              const SizedBox(height: SsSpace.lg),
              LayoutBuilder(
                builder: (context, c) {
                  final cols =
                      c.maxWidth < 600 ? 2 : (c.maxWidth < 1000 ? 3 : 4);
                  final cardWidth = (c.maxWidth - (cols - 1) * 24) / cols;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: related.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      mainAxisExtent: cardWidth + 118,
                    ),
                    itemBuilder: (context, i) =>
                        ProductCard(product: related[i]),
                  );
                },
              ),
            ],
            const SizedBox(height: SsSpace.xxl),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.category, required this.name});
  final String category;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () => context.go('/'),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              'Home',
              style: TextStyle(
                color: SsColors.inkMuted,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const Text(
          ' / ',
          style: TextStyle(color: SsColors.inkMuted, fontSize: 12),
        ),
        InkWell(
          onTap: () => context.go('/shop'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              category,
              style: const TextStyle(
                color: SsColors.inkMuted,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const Text(
          ' / ',
          style: TextStyle(color: SsColors.inkMuted, fontSize: 12),
        ),
        Text(
          name,
          style: const TextStyle(
            color: SsColors.ink,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EyebrowText extends StatelessWidget {
  const _EyebrowText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: SsColors.inkMuted,
        fontSize: 11,
        letterSpacing: 2.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.product,
    required this.active,
    required this.onSelect,
  });
  final Product product;
  final int active;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey.keyLabel == 'Arrow Right') {
            onSelect((active + 1) % product.galleryLabels.length);
            return KeyEventResult.handled;
          } else if (event.logicalKey.keyLabel == 'Arrow Left') {
            onSelect(
              (active - 1 + product.galleryLabels.length) %
                  product.galleryLabels.length,
            );
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: SsImagePlaceholder(
              key: ValueKey<int>(active),
              label: product.galleryLabels[active],
              seed: product.id.hashCode + active,
              aspectRatio: 1,
              radius: SsRadii.md,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              for (int i = 0; i < product.galleryLabels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(SsRadii.sm),
                        border: Border.all(
                          color: i == active ? SsColors.ink : SsColors.divider,
                          width: i == active ? 1.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(SsRadii.sm - 1),
                        child: SsImagePlaceholder(
                          label: '${i + 1}',
                          seed: product.id.hashCode + i * 7,
                          radius: 0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;
    final color = inStock ? SsColors.success : SsColors.inkMuted;
    final text = inStock
        ? product.shipEstimate
        : 'Made to order · ${product.mtmLeadTimeDays} day lead';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SsColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.options,
    required this.selected,
    required this.onChanged,
  });
  final List<ColorOption> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'COLOR',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w600,
                color: SsColors.inkMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '· $selected',
              style: const TextStyle(fontSize: 12, color: SsColors.ink),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: <Widget>[
            for (final c in options)
              Semantics(
                label: 'Color: ${c.name}',
                selected: c.name == selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(c.name),
                  child: AnimatedContainer(
                    duration: SsDurations.short,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(c.hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: c.name == selected
                            ? SsColors.ink
                            : SsColors.divider,
                        width: c.name == selected ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SizePicker extends StatelessWidget {
  const _SizePicker({
    required this.options,
    required this.selected,
    required this.onChanged,
  });
  final List<SizeOption> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'SIZE',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
            color: SsColors.inkMuted,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final s in options)
              Semantics(
                label: 'Size ${s.label}${s.inStock ? '' : ', out of stock'}',
                selected: s.label == selected,
                button: true,
                child: InkWell(
                  onTap: s.inStock ? () => onChanged(s.label) : null,
                  borderRadius: BorderRadius.circular(SsRadii.sm),
                  child: AnimatedContainer(
                    duration: SsDurations.short,
                    constraints: const BoxConstraints(
                      minWidth: 56,
                      minHeight: 44,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          s.label == selected ? SsColors.ink : SsColors.surface,
                      borderRadius: BorderRadius.circular(SsRadii.sm),
                      border: Border.all(
                        color: s.label == selected
                            ? SsColors.ink
                            : (s.inStock
                                ? SsColors.divider
                                : SsColors.divider.withValues(alpha: 0.4)),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s.label,
                      style: TextStyle(
                        color: s.label == selected
                            ? SsColors.ivory
                            : (s.inStock ? SsColors.ink : SsColors.inkMuted),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        decoration:
                            s.inStock ? null : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MtmToggle extends StatelessWidget {
  const _MtmToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(SsRadii.sm),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? SsColors.ink : SsColors.surface,
          borderRadius: BorderRadius.circular(SsRadii.sm),
          border: Border.all(color: value ? SsColors.ink : SsColors.divider),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? SsColors.ivory : SsColors.ink,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Make this for me (made-to-measure)',
                    style: TextStyle(
                      color: value ? SsColors.ivory : SsColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add 25% · we will reach out to confirm measurements',
                    style: TextStyle(
                      color: value
                          ? SsColors.ivory.withValues(alpha: 0.7)
                          : SsColors.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});
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
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 16),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Increase',
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add, size: 16),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCta extends ConsumerWidget {
  const _PrimaryCta({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    required this.madeToMeasure,
  });

  final Product product;
  final String size;
  final String color;
  final int quantity;
  final bool madeToMeasure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canBuy = product.inStock || product.mtmAvailable;
    return ElevatedButton(
      onPressed: canBuy
          ? () {
              ref.read(cartProvider.notifier).addLine(
                    CartLine(
                      productId: product.id,
                      size: size,
                      colorName: color,
                      quantity: quantity,
                      madeToMeasure: madeToMeasure,
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: SsColors.ink,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(milliseconds: 1500),
                  content: Text(
                    'Added to cart · $size · $color',
                    style: const TextStyle(color: SsColors.ivory, fontSize: 13),
                  ),
                ),
              );
            }
          : null,
      child: Text(
        product.madeToOrderOnly && madeToMeasure
            ? 'ADD TO CART — MTO'
            : 'ADD TO CART',
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _EyebrowText('THE DETAIL'),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: const TextStyle(height: 1.65, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            for (final f in product.fabricTags)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SsColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  f,
                  style: const TextStyle(fontSize: 11, letterSpacing: 0.6),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CareInfo extends StatelessWidget {
  const _CareInfo({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SsColors.surface,
        borderRadius: BorderRadius.circular(SsRadii.sm),
        border: Border.all(color: SsColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.eco_outlined, size: 18, color: SsColors.inkMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'CARE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w600,
                    color: SsColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.care,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
