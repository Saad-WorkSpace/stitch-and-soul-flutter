import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';
import '../../data/repositories.dart';
import '../../widgets/product_card.dart';
import '../../widgets/responsive.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(favoritesProvider);
    final repo = ref.watch(productRepositoryProvider);
    final products = repo.all().where((p) => fav.isFavorite(p.id)).toList();

    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            const _Heading(),
            const SizedBox(height: SsSpace.xl),
            if (products.isEmpty)
              const _EmptyFavorites()
            else
              LayoutBuilder(
                builder: (context, c) {
                  final cols =
                      c.maxWidth < 600 ? 2 : (c.maxWidth < 1000 ? 3 : 4);
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
                    itemBuilder: (context, i) =>
                        ProductCard(product: products[i]),
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
        Text('SAVED', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text('Favorites', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        const Text(
          'Pieces you want to come back to. Tap a heart to remove.',
          style: TextStyle(color: SsColors.inkMuted, fontSize: 15),
        ),
      ],
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SsSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Nothing saved yet.',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart on any product to save it for later.',
            style: TextStyle(color: SsColors.inkMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/shop'),
            child: const Text('BROWSE THE COLLECTION'),
          ),
        ],
      ),
    );
  }
}
