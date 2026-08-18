import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/tokens.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import 'app_widgets.dart';

/// A reusable product card. Two visual modes: `grid` (default) and
/// `editorial` (used on the home for featured collections).
class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.variant = ProductCardVariant.grid,
  });

  final Product product;
  final ProductCardVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(favoritesProvider);
    final isFav = fav.isFavorite(product.id);
    final card = SsHoverCard(
      onTap: () => context.go('/product/${product.slug}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio:
                    variant == ProductCardVariant.editorial ? 4 / 5 : 1,
                child: SsImagePlaceholder(
                  label: product.galleryLabels.join(' · '),
                  seed: product.id.hashCode,
                  radius: 0,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _Heart(
                  isFavorite: isFav,
                  onTap: () =>
                      ref.read(favoritesProvider.notifier).toggle(product.id),
                ),
              ),
              if (product.madeToOrderOnly)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SsColors.ivory,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SsColors.ink),
                    ),
                    child: const Text(
                      'MADE TO ORDER',
                      style: TextStyle(
                        color: SsColors.ink,
                        fontSize: 9,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SsColors.inkMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Text(
                      '\$${product.priceUSD.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        product.shipEstimate,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: SsColors.inkMuted,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return card;
  }
}

class _Heart extends StatelessWidget {
  const _Heart({required this.isFavorite, required this.onTap});
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      button: true,
      child: Material(
        color: SsColors.ivory,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(isFavorite),
                size: 18,
                color: isFavorite ? SsColors.clay : SsColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ProductCardVariant { grid, editorial }
