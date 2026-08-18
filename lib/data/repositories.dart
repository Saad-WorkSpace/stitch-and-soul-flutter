import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog_filter.dart';
import 'mock_catalog.dart';
import 'models.dart';

/// Product repository: in-memory list, with a sync API. Designed to be
/// replaced by a real backend in Phase 2.
abstract class ProductRepository {
  List<Product> all();
  Product? bySlug(String slug);
  List<Product> related(Product p, {int limit = 4});
  List<Product> featured();
  List<Product> bestsellers({int limit = 4});
}

class InMemoryProductRepository implements ProductRepository {
  InMemoryProductRepository(this._all);
  final List<Product> _all;

  @override
  List<Product> all() => List.unmodifiable(_all);

  @override
  Product? bySlug(String slug) {
    for (final p in _all) {
      if (p.slug == slug) return p;
    }
    return null;
  }

  @override
  List<Product> related(Product p, {int limit = 4}) =>
      relatedProducts(p, _all, limit: limit);

  @override
  List<Product> featured() => featuredProducts(_all);

  @override
  List<Product> bestsellers({int limit = 4}) =>
      bestsellerProducts(_all, limit: limit);
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return InMemoryProductRepository(kMockProducts);
});

/// Favorites: stored in SharedPreferences as a comma-separated list of
/// product ids. Safe to use on web via the shared_preferences web shim.
class FavoritesRepository {
  FavoritesRepository(this._prefs) : _ids = _load(_prefs);

  final SharedPreferences _prefs;
  final Set<String> _ids;

  static const _key = 'ss.favorites.v1';

  static Set<String> _load(SharedPreferences p) {
    final raw = p.getStringList(_key) ?? const <String>[];
    return raw.toSet();
  }

  Set<String> get ids => _ids;

  bool isFavorite(String productId) => _ids.contains(productId);

  Future<void> toggle(String productId) async {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    await _persist();
  }

  Future<void> clear() async {
    _ids.clear();
    await _persist();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(_key, _ids.toList()..sort());
  }
}

/// Favorites is provided as an async-notifier-style ChangeNotifier for
/// simplicity. We avoid Riverpod code generation.
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  throw UnimplementedError(
    'Override in main() once SharedPreferences is ready.',
  );
});

class FavoritesNotifier extends ChangeNotifier {
  FavoritesNotifier(this._repo);

  final FavoritesRepository _repo;

  Set<String> get ids => _repo.ids;
  bool isFavorite(String id) => _repo.isFavorite(id);

  Future<void> toggle(String id) async {
    await _repo.toggle(id);
    notifyListeners();
  }
}

final favoritesProvider = ChangeNotifierProvider<FavoritesNotifier>((ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});

/// Measurement profile persistence: only persisted if the user consented
/// in the wizard.
class MeasurementsRepository {
  MeasurementsRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'ss.measurements.v1';

  MeasurementProfile? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    // Stored as a simple key=value pipe-separated string for portability.
    final map = <String, String>{};
    for (final pair in raw.split('|')) {
      final kv = pair.split('=');
      if (kv.length == 2) map[kv[0]] = kv[1];
    }
    double? d(String k) => double.tryParse(map[k] ?? '');
    return MeasurementProfile(
      units: <String>{'in', 'inches'}.contains(map['units'])
          ? UnitSystem.inches
          : UnitSystem.cm,
      bustCm: d('bust'),
      waistCm: d('waist'),
      hipsCm: d('hips'),
      shoulderCm: d('shoulder'),
      sleeveCm: d('sleeve'),
      inseamCm: d('inseam'),
      heightCm: d('height'),
      fit: switch (map['fit']) {
        'slim' => FitPreference.slim,
        'relaxed' => FitPreference.relaxed,
        _ => FitPreference.standard,
      },
      notes: map['notes'],
    );
  }

  Future<void> save(MeasurementProfile profile) async {
    final pairs = <String>[
      'units=${profile.units == UnitSystem.cm ? 'cm' : 'in'}',
      if (profile.bustCm != null) 'bust=${profile.bustCm}',
      if (profile.waistCm != null) 'waist=${profile.waistCm}',
      if (profile.hipsCm != null) 'hips=${profile.hipsCm}',
      if (profile.shoulderCm != null) 'shoulder=${profile.shoulderCm}',
      if (profile.sleeveCm != null) 'sleeve=${profile.sleeveCm}',
      if (profile.inseamCm != null) 'inseam=${profile.inseamCm}',
      if (profile.heightCm != null) 'height=${profile.heightCm}',
      'fit=${profile.fit.name}',
      if (profile.notes != null) 'notes=${profile.notes}',
    ];
    await _prefs.setString(_key, pairs.join('|'));
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}

final measurementsRepositoryProvider = Provider<MeasurementsRepository>((ref) {
  throw UnimplementedError(
    'Override in main() once SharedPreferences is ready.',
  );
});
