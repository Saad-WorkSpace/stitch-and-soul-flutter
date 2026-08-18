import 'models.dart';

/// Pure functions for filtering the mock catalog. Kept separate from
/// Riverpod so they're trivial to unit test.
List<Product> applyCatalogQuery(List<Product> all, CatalogQuery q) {
  Iterable<Product> results = all;

  if (q.query.trim().isNotEmpty) {
    final needle = q.query.trim().toLowerCase();
    results = results.where((p) {
      return p.name.toLowerCase().contains(needle) ||
          p.tagline.toLowerCase().contains(needle) ||
          p.description.toLowerCase().contains(needle) ||
          p.fabricTags.any((t) => t.toLowerCase().contains(needle));
    });
  }

  if (q.category != null) {
    results = results.where((p) => p.category == q.category);
  }

  if (q.size != null) {
    results = results.where((p) => p.sizes.any((s) => s.label == q.size));
  }

  if (q.color != null) {
    results = results.where((p) => p.colors.any((c) => c.name == q.color));
  }

  if (q.fabric != null) {
    results = results.where((p) => p.fabricTags.contains(q.fabric));
  }

  if (q.maxPrice != null) {
    results = results.where((p) => p.priceUSD <= q.maxPrice!);
  }

  if (q.inStockOnly) {
    results = results.where((p) => p.inStock);
  }

  final list = results.toList(growable: false);
  list.sort((a, b) => _compareBySort(a, b, q.sort));
  return list;
}

int _compareBySort(Product a, Product b, SortOption s) {
  switch (s) {
    case SortOption.featured:
      // Featured first, then bestsellers, then newest.
      if (a.featured != b.featured) return a.featured ? -1 : 1;
      if (a.bestseller != b.bestseller) return a.bestseller ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    case SortOption.priceAsc:
      return a.priceUSD.compareTo(b.priceUSD);
    case SortOption.priceDesc:
      return b.priceUSD.compareTo(a.priceUSD);
    case SortOption.newest:
      return b.createdAt.compareTo(a.createdAt);
  }
}

List<Product> relatedProducts(
  Product source,
  List<Product> all, {
  int limit = 4,
}) {
  final sorted = all
      .where((p) => p.id != source.id && p.category == source.category)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final safeLimit =
      limit < 0 ? 0 : (limit > sorted.length ? sorted.length : limit);
  return sorted.take(safeLimit).toList(growable: false);
}

List<Product> featuredProducts(List<Product> all) {
  return all.where((p) => p.featured).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

List<Product> bestsellerProducts(List<Product> all, {int limit = 4}) {
  final sorted = all.where((p) => p.bestseller).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final safeLimit =
      limit < 0 ? 0 : (limit > sorted.length ? sorted.length : limit);
  return sorted.take(safeLimit).toList(growable: false);
}

double computePriceMax(List<Product> all) {
  if (all.isEmpty) return 1000;
  return all.map((p) => p.priceUSD).reduce((a, b) => a > b ? a : b);
}

Set<String> availableSizes(List<Product> all) =>
    all.expand((p) => p.sizes.map((s) => s.label)).toSet();

Set<String> availableColors(List<Product> all) =>
    all.expand((p) => p.colors.map((c) => c.name)).toSet();

Set<String> availableFabrics(List<Product> all) =>
    all.expand((p) => p.fabricTags).toSet();
