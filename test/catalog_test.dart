import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_and_soul/data/catalog_filter.dart';
import 'package:stitch_and_soul/data/mock_catalog.dart';
import 'package:stitch_and_soul/data/models.dart';

void main() {
  group('catalog filtering', () {
    test('contains at least ten products across all five categories', () {
      expect(kMockProducts.length, greaterThanOrEqualTo(10));
      final byCategory = <ProductCategory>{};
      for (final p in kMockProducts) {
        byCategory.add(p.category);
      }
      expect(byCategory, containsAll(ProductCategory.values));
    });

    test('returns all products for an empty query (default sort)', () {
      final out = applyCatalogQuery(kMockProducts, const CatalogQuery());
      expect(out.length, kMockProducts.length);
    });

    test('filters by category', () {
      final out = applyCatalogQuery(
        kMockProducts,
        const CatalogQuery(category: ProductCategory.dresses),
      );
      expect(out, isNotEmpty);
      for (final p in out) {
        expect(p.category, ProductCategory.dresses);
      }
    });

    test('search matches description and fabric', () {
      final byName = applyCatalogQuery(
        kMockProducts,
        const CatalogQuery(query: 'Linen'),
      );
      expect(byName, isNotEmpty);

      final byFabric = applyCatalogQuery(
        kMockProducts,
        const CatalogQuery(query: 'wool'),
      );
      expect(byFabric, isNotEmpty);
      for (final p in byFabric) {
        final matches =
            p.fabricTags.any((t) => t.toLowerCase().contains('wool')) ||
                p.name.toLowerCase().contains('wool') ||
                p.description.toLowerCase().contains('wool') ||
                p.tagline.toLowerCase().contains('wool');
        expect(matches, isTrue);
      }
    });

    test('in-stock filter excludes made-to-order', () {
      final out = applyCatalogQuery(
        kMockProducts,
        const CatalogQuery(inStockOnly: true),
      );
      for (final p in out) {
        expect(p.inStock, isTrue);
      }
    });

    test('sort by price ascending', () {
      final out = applyCatalogQuery(
        kMockProducts,
        const CatalogQuery(sort: SortOption.priceAsc),
      );
      for (int i = 1; i < out.length; i++) {
        expect(out[i - 1].priceUSD, lessThanOrEqualTo(out[i].priceUSD));
      }
    });

    test('related products excludes the source and respects the limit', () {
      final source = kMockProducts.firstWhere(
        (p) => p.category == ProductCategory.tops,
      );
      final related = relatedProducts(source, kMockProducts, limit: 2);
      expect(related.length, lessThanOrEqualTo(2));
      expect(related.any((p) => p.id == source.id), isFalse);
    });

    test('related and bestseller limits are safe when larger than results', () {
      final source = kMockProducts.first;
      expect(
        () => relatedProducts(source, kMockProducts, limit: 999),
        returnsNormally,
      );
      expect(
        () => bestsellerProducts(kMockProducts, limit: 999),
        returnsNormally,
      );
    });
  });
}
