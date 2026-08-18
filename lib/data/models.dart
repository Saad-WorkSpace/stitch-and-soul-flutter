import 'package:flutter/foundation.dart';

/// All product / cart / measurement models live here. They are simple
/// immutable Dart classes; no codegen required.

enum ProductCategory {
  dresses,
  tops,
  bottoms,
  outerwear,
  occasionwear;

  String get slug => name;

  String get label {
    switch (this) {
      case ProductCategory.dresses:
        return 'Dresses';
      case ProductCategory.tops:
        return 'Tops';
      case ProductCategory.bottoms:
        return 'Bottoms';
      case ProductCategory.outerwear:
        return 'Outerwear';
      case ProductCategory.occasionwear:
        return 'Occasionwear';
    }
  }
}

@immutable
class SizeOption {
  const SizeOption(this.label, {this.inStock = true});
  final String label;
  final bool inStock;
}

@immutable
class ColorOption {
  const ColorOption(this.name, this.hex);
  final String name;

  /// ARGB int. Default 0 means "unspecified".
  final int hex;
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.tagline,
    required this.description,
    required this.priceUSD,
    required this.sizes,
    required this.colors,
    required this.fabricTags,
    required this.care,
    required this.leadTimeDays,
    required this.mtmLeadTimeDays,
    required this.mtmAvailable,
    required this.stock,
    required this.galleryLabels,
    required this.createdAt,
    this.featured = false,
    this.bestseller = false,
  });

  final String id;
  final String slug;
  final String name;
  final ProductCategory category;
  final String tagline;
  final String description;
  final double priceUSD;
  final List<SizeOption> sizes;
  final List<ColorOption> colors;
  final List<String> fabricTags;
  final String care;
  final int leadTimeDays;
  final int mtmLeadTimeDays;
  final bool mtmAvailable;

  /// Approximate stock units for ready-to-wear; -1 means made-to-order only.
  final int stock;

  final List<String> galleryLabels;
  final DateTime createdAt;
  final bool featured;
  final bool bestseller;

  bool get inStock => stock > 0;
  bool get madeToOrderOnly => stock <= 0;

  String get shipEstimate {
    if (madeToOrderOnly) {
      return 'Made to order · $mtmLeadTimeDays day lead time';
    }
    return 'Ships in $leadTimeDays days';
  }
}

enum SortOption {
  featured,
  priceAsc,
  priceDesc,
  newest;

  String get label {
    switch (this) {
      case SortOption.featured:
        return 'Featured';
      case SortOption.priceAsc:
        return 'Price · Low to high';
      case SortOption.priceDesc:
        return 'Price · High to low';
      case SortOption.newest:
        return 'Newest';
    }
  }
}

@immutable
class CatalogQuery {
  const CatalogQuery({
    this.query = '',
    this.category,
    this.size,
    this.color,
    this.fabric,
    this.maxPrice,
    this.inStockOnly = false,
    this.sort = SortOption.featured,
  });

  final String query;
  final ProductCategory? category;
  final String? size;
  final String? color;
  final String? fabric;
  final double? maxPrice;
  final bool inStockOnly;
  final SortOption sort;

  CatalogQuery copyWith({
    String? query,
    Object? category = _sentinel,
    Object? size = _sentinel,
    Object? color = _sentinel,
    Object? fabric = _sentinel,
    Object? maxPrice = _sentinel,
    bool? inStockOnly,
    SortOption? sort,
  }) {
    return CatalogQuery(
      query: query ?? this.query,
      category:
          category == _sentinel ? this.category : category as ProductCategory?,
      size: size == _sentinel ? this.size : size as String?,
      color: color == _sentinel ? this.color : color as String?,
      fabric: fabric == _sentinel ? this.fabric : fabric as String?,
      maxPrice: maxPrice == _sentinel ? this.maxPrice : maxPrice as double?,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sort: sort ?? this.sort,
    );
  }

  static const Object _sentinel = Object();
}

enum UnitSystem { cm, inches }

extension UnitSystemX on UnitSystem {
  String get label => this == UnitSystem.cm ? 'cm' : 'in';
  String get longLabel => this == UnitSystem.cm ? 'Centimeters' : 'Inches';
}

enum FitPreference { slim, standard, relaxed }

extension FitPreferenceX on FitPreference {
  String get label {
    switch (this) {
      case FitPreference.slim:
        return 'Slim';
      case FitPreference.standard:
        return 'Standard';
      case FitPreference.relaxed:
        return 'Relaxed';
    }
  }
}

@immutable
class MeasurementProfile {
  const MeasurementProfile({
    required this.units,
    this.bustCm,
    this.waistCm,
    this.hipsCm,
    this.shoulderCm,
    this.sleeveCm,
    this.inseamCm,
    this.heightCm,
    this.fit = FitPreference.standard,
    this.notes,
  });

  final UnitSystem units;
  final double? bustCm;
  final double? waistCm;
  final double? hipsCm;
  final double? shoulderCm;
  final double? sleeveCm;
  final double? inseamCm;
  final double? heightCm;
  final FitPreference fit;
  final String? notes;

  double? display(double? cm) {
    if (cm == null) return null;
    return units == UnitSystem.cm ? cm : cm / 2.54;
  }

  /// Display a measurement as a string in the chosen unit.
  String? displayString(double? cm) {
    final v = display(cm);
    if (v == null) return null;
    return '${v.toStringAsFixed(units == UnitSystem.cm ? 1 : 2)} ${units.label}';
  }

  MeasurementProfile copyWith({
    UnitSystem? units,
    double? bustCm,
    double? waistCm,
    double? hipsCm,
    double? shoulderCm,
    double? sleeveCm,
    double? inseamCm,
    double? heightCm,
    FitPreference? fit,
    String? notes,
  }) {
    return MeasurementProfile(
      units: units ?? this.units,
      bustCm: bustCm ?? this.bustCm,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      shoulderCm: shoulderCm ?? this.shoulderCm,
      sleeveCm: sleeveCm ?? this.sleeveCm,
      inseamCm: inseamCm ?? this.inseamCm,
      heightCm: heightCm ?? this.heightCm,
      fit: fit ?? this.fit,
      notes: notes ?? this.notes,
    );
  }
}

@immutable
class CartLine {
  const CartLine({
    required this.productId,
    required this.size,
    required this.colorName,
    required this.quantity,
    this.madeToMeasure = false,
    this.measurements,
    this.notes,
    this.lineId,
  });

  /// Stable identity for the line. Auto-generated by CartNotifier if null.
  final String? lineId;
  final String productId;
  final String size;
  final String colorName;
  final int quantity;
  final bool madeToMeasure;
  final MeasurementProfile? measurements;
  final String? notes;

  CartLine copyWith({int? quantity, String? notes}) {
    return CartLine(
      lineId: lineId,
      productId: productId,
      size: size,
      colorName: colorName,
      quantity: quantity ?? this.quantity,
      madeToMeasure: madeToMeasure,
      measurements: measurements,
      notes: notes ?? this.notes,
    );
  }
}

@immutable
class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
}
