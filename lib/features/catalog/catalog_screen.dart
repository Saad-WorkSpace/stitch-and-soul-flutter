import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tokens.dart';
import '../../data/catalog_filter.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/cart_notifier.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/product_card.dart';
import '../../widgets/responsive.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.initialCategory});

  /// Optional category slug to preselect (drives the URL).
  final String? initialCategory;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    if (initial != null) {
      final cat = ProductCategory.values
          .where((c) => c.slug == initial)
          .cast<ProductCategory?>()
          .firstWhere((c) => c != null, orElse: () => null);
      if (cat != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final cur = ref.read(catalogFilterProvider).query;
          ref
              .read(catalogFilterProvider.notifier)
              .set(cur.copyWith(category: cat));
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(catalogFilterProvider);
    final results = ref.watch(filteredProductsProvider);
    final repo = ref.watch(productRepositoryProvider);
    final all = repo.all();

    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            SsSectionHeading(
              eyebrow: 'The collection',
              title: filter.query.category?.label ?? 'All garments',
              subtitle: '${results.length} pieces · made with intention',
              trailing: _SortDropdown(
                value: filter.query.sort,
                onChanged: (s) {
                  ref
                      .read(catalogFilterProvider.notifier)
                      .set(filter.query.copyWith(sort: s));
                },
              ),
            ),
            const SizedBox(height: SsSpace.lg),
            _SearchField(
              controller: _searchCtrl,
              onChanged: (v) {
                ref
                    .read(catalogFilterProvider.notifier)
                    .set(filter.query.copyWith(query: v));
              },
              onClear: () {
                _searchCtrl.clear();
                ref
                    .read(catalogFilterProvider.notifier)
                    .set(filter.query.copyWith(query: ''));
              },
            ),
            const SizedBox(height: SsSpace.md),
            _FilterRow(all: all, current: filter.query),
            const SizedBox(height: SsSpace.lg),
            if (results.isEmpty)
              const _EmptyResults()
            else
              _ResultsGrid(results: results),
            const SizedBox(height: SsSpace.xxl),
          ],
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});
  final SortOption value;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: SsColors.surface,
        border: Border.all(color: SsColors.divider),
        borderRadius: BorderRadius.circular(SsRadii.pill),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: value,
          icon: const Icon(Icons.expand_more, size: 18),
          style: const TextStyle(
            color: SsColors.ink,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (s) {
            if (s != null) onChanged(s);
          },
          items: SortOption.values
              .map(
                (s) => DropdownMenuItem<SortOption>(
                  value: s,
                  child: Text(s.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 18),
        hintText: 'Search by name, fabric, or detail',
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              ),
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.all, required this.current});
  final List<Product> all;
  final CatalogQuery current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(catalogFilterProvider.notifier);
    final maxPrice = computePriceMax(all);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          // Category chips
          SsChip(
            label: 'ALL',
            selected: current.category == null,
            onTap: () => notifier.set(current.copyWith(category: null)),
          ),
          const SizedBox(width: 8),
          for (final c in ProductCategory.values) ...<Widget>[
            SsChip(
              label: c.label.toUpperCase(),
              selected: current.category == c,
              onTap: () => notifier.set(current.copyWith(category: c)),
            ),
            const SizedBox(width: 8),
          ],
          const SizedBox(width: 12),
          _PriceDropdown(
            value: current.maxPrice,
            max: maxPrice,
            onChanged: (v) => notifier.set(current.copyWith(maxPrice: v)),
          ),
          const SizedBox(width: 12),
          SsChip(
            label: 'IN STOCK',
            selected: current.inStockOnly,
            onTap: () => notifier.set(
              current.copyWith(inStockOnly: !current.inStockOnly),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceDropdown extends StatelessWidget {
  const _PriceDropdown({
    required this.value,
    required this.max,
    required this.onChanged,
  });
  final double? value;
  final double max;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = <String, double?>{
      'Any price': null,
      'Under \$150': 150,
      'Under \$250': 250,
      'Under \$400': 400,
      'All pieces': max,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: SsColors.surface,
        border: Border.all(color: SsColors.divider),
        borderRadius: BorderRadius.circular(SsRadii.pill),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double?>(
          value: value,
          icon: const Icon(Icons.expand_more, size: 18),
          style: const TextStyle(
            color: SsColors.ink,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (v) => onChanged(v),
          items: labels.entries
              .map(
                (e) => DropdownMenuItem<double?>(
                  value: e.value,
                  child: Text(e.key),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.results});
  final List<Product> results;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth < 520
            ? 1
            : (c.maxWidth < 900 ? 2 : (c.maxWidth < 1280 ? 3 : 4));
        final cardWidth = (c.maxWidth - (cols - 1) * 24) / cols;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            mainAxisExtent: cardWidth + 118,
          ),
          itemBuilder: (context, i) => ProductCard(product: results[i]),
        );
      },
    );
  }
}

class _EmptyResults extends ConsumerWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SsSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'No matches',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a broader search or clear the filters.',
            style: TextStyle(color: SsColors.inkMuted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              ref.read(catalogFilterProvider.notifier).clear();
            },
            child: const Text('CLEAR FILTERS'),
          ),
        ],
      ),
    );
  }
}
