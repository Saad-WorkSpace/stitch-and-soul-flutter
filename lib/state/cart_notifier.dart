import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_filter.dart';
import '../data/models.dart';
import '../data/repositories.dart';

/// Cart state. Lines are stored as a list; we don't deduplicate across
/// lines so a product with different sizes or colors is two separate
/// lines (this matches how a custom atelier would quote and ship).
class CartNotifier extends ChangeNotifier {
  final List<CartLine> _lines = <CartLine>[];
  String? _appliedPromo;
  static const double shippingFlat = 12.0;
  static const double freeShippingThreshold = 350.0;
  static const double taxRate = 0.08;

  /// Demo promo codes. Stored in code rather than config to make the
  /// surface area obvious.
  static const Map<String, _Promo> _promos = <String, _Promo>{
    'WELCOME10': _Promo(
      kind: _PromoKind.percent,
      amount: 0.10,
      label: '10% off',
    ),
    'ATELIER15': _Promo(
      kind: _PromoKind.percent,
      amount: 0.15,
      label: '15% off + free ship',
    ),
    'FREESHIP': _Promo(
      kind: _PromoKind.shipping,
      amount: 1.0,
      label: 'Free shipping',
    ),
  };

  List<CartLine> get lines => List.unmodifiable(_lines);
  int get itemCount => _lines.fold(0, (n, l) => n + l.quantity);
  String? get appliedPromo => _appliedPromo;
  bool get isEmpty => _lines.isEmpty;

  String? applyPromo(String code) {
    final upper = code.trim().toUpperCase();
    if (_promos.containsKey(upper)) {
      _appliedPromo = upper;
      notifyListeners();
      return null;
    }
    return 'We don\'t recognize that code.';
  }

  void clearPromo() {
    _appliedPromo = null;
    notifyListeners();
  }

  void addLine(CartLine line) {
    _lines.add(
      line.lineId == null
          ? CartLine(
              productId: line.productId,
              size: line.size,
              colorName: line.colorName,
              quantity: line.quantity,
              madeToMeasure: line.madeToMeasure,
              measurements: line.measurements,
              notes: line.notes,
              lineId: 'ln-${DateTime.now().microsecondsSinceEpoch}',
            )
          : line,
    );
    notifyListeners();
  }

  void updateQuantity(String lineId, int qty) {
    final i = _lines.indexWhere((l) => l.lineId == lineId);
    if (i < 0) return;
    if (qty <= 0) {
      _lines.removeAt(i);
    } else {
      _lines[i] = _lines[i].copyWith(quantity: qty);
    }
    notifyListeners();
  }

  void removeLine(String lineId) {
    _lines.removeWhere((l) => l.lineId == lineId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _appliedPromo = null;
    notifyListeners();
  }

  /// Computes totals using the repository (for unit prices).
  CartTotals totals(ProductRepository repo) {
    double subtotal = 0;
    for (final l in _lines) {
      final p = repo.all().firstWhere(
            (p) => p.id == l.productId,
            orElse: () => _missingProduct,
          );
      if (identical(p, _missingProduct)) continue;
      // Made-to-measure adds 25% to the unit price.
      final unit = p.priceUSD * (l.madeToMeasure ? 1.25 : 1.0);
      subtotal += unit * l.quantity;
    }

    final promo = _appliedPromo != null ? _promos[_appliedPromo!] : null;
    final discount = promo != null && promo.kind == _PromoKind.percent
        ? subtotal * promo.amount
        : 0.0;

    final shipping = (promo != null && promo.kind == _PromoKind.shipping) ||
            (subtotal - discount) >= freeShippingThreshold
        ? 0.0
        : shippingFlat;
    final tax = (subtotal - discount) * taxRate;
    final total = subtotal - discount + shipping + tax;
    return CartTotals(
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
    );
  }

  static final Product _missingProduct = Product(
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

enum _PromoKind { percent, shipping }

@immutable
class _Promo {
  const _Promo({required this.kind, required this.amount, required this.label});
  final _PromoKind kind;
  final double amount;
  final String label;
}

final cartProvider = ChangeNotifierProvider<CartNotifier>((ref) {
  return CartNotifier();
});

/// Catalog query state.
class CatalogFilterNotifier extends ChangeNotifier {
  CatalogFilterNotifier([CatalogQuery initial = const CatalogQuery()])
      : _query = initial;

  CatalogQuery _query;
  CatalogQuery get query => _query;

  void set(CatalogQuery next) {
    _query = next;
    notifyListeners();
  }

  void clear() {
    _query = const CatalogQuery();
    notifyListeners();
  }
}

final catalogFilterProvider = ChangeNotifierProvider<CatalogFilterNotifier>((
  ref,
) {
  return CatalogFilterNotifier();
});

/// Filtered products derived from the filter + the repository.
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  final filter = ref.watch(catalogFilterProvider);
  return applyCatalogQuery(repo.all(), filter.query);
});
