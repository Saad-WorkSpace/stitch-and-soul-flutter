import 'models.dart';

/// The static, in-memory mock catalog. Twelve garments across five
/// categories, with consistent storytelling, care, and lead time. Prices
/// are in USD; the catalog is the only source of truth for product copy.
final List<Product> kMockProducts = <Product>[
  // ── Dresses ───────────────────────────────────────────────────────────
  Product(
    id: 'dress-ivory-linen',
    slug: 'ivory-linen-day-dress',
    name: 'Ivory Linen Day Dress',
    category: ProductCategory.dresses,
    tagline: 'A weightless everyday dress in heavyweight linen.',
    description: 'Cut from a single panel of European linen and finished with '
        'a hand-rolled hem. A relaxed A-line with a soft gathered waist '
        'and a tied back that lets the silhouette breathe.',
    priceUSD: 248,
    sizes: const <SizeOption>[
      SizeOption('XS'),
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
      SizeOption('XL'),
    ],
    colors: const <ColorOption>[
      ColorOption('Ivory', 0xFFEDE6D8),
      ColorOption('Clay', 0xFFB4724B),
      ColorOption('Ink', 0xFF1B1A17),
    ],
    fabricTags: const <String>['Linen', 'European'],
    care: 'Cold hand wash. Line dry. Iron on low while slightly damp.',
    leadTimeDays: 4,
    mtmLeadTimeDays: 21,
    mtmAvailable: true,
    stock: 6,
    galleryLabels: const <String>['Ivory', 'Linen', 'Day dress'],
    createdAt: _d(2026, 1, 14),
    featured: true,
    bestseller: true,
  ),
  Product(
    id: 'dress-midnight-slip',
    slug: 'midnight-slip-dress',
    name: 'Midnight Slip Dress',
    category: ProductCategory.dresses,
    tagline: 'Bias-cut silk that falls where it should.',
    description:
        'A bias-cut silk slip that skims without clinging. French seams '
        'throughout, adjustable straps, and a discreet side slit. '
        'Designed to be worn on its own or under a cardigan.',
    priceUSD: 385,
    sizes: const <SizeOption>[
      SizeOption('XS', inStock: false),
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
      SizeOption('XL'),
    ],
    colors: const <ColorOption>[
      ColorOption('Midnight', 0xFF1F2330),
      ColorOption('Bordeaux', 0xFF6A2A33),
      ColorOption('Pearl', 0xFFE9DBC6),
    ],
    fabricTags: const <String>['Silk', 'Bias-cut'],
    care: 'Dry clean only. Store on a padded hanger.',
    leadTimeDays: 5,
    mtmLeadTimeDays: 28,
    mtmAvailable: true,
    stock: 4,
    galleryLabels: const <String>['Midnight', 'Slip', 'Bias'],
    createdAt: _d(2026, 3, 2),
    featured: true,
  ),
  Product(
    id: 'dress-sage-wrap',
    slug: 'sage-wrap-dress',
    name: 'Sage Wrap Dress',
    category: ProductCategory.dresses,
    tagline: 'A tied waist, a generous hem, and just enough sleeve.',
    description:
        'Inspired by a 1970s pattern we found in a Berlin flea market. '
        'A soft wrap bodice, three-quarter sleeves, and a hem that '
        'swings when you walk. Falls just below the knee.',
    priceUSD: 295,
    sizes: const <SizeOption>[
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
    ],
    colors: const <ColorOption>[
      ColorOption('Sage', 0xFF7A8C73),
      ColorOption('Rust', 0xFFB4724B),
    ],
    fabricTags: const <String>['Viscose', 'Crepe'],
    care: 'Cool wash inside out. Hang to dry. Iron on reverse.',
    leadTimeDays: 6,
    mtmLeadTimeDays: 21,
    mtmAvailable: true,
    stock: 3,
    galleryLabels: const <String>['Sage', 'Wrap', 'Crepe'],
    createdAt: _d(2026, 2, 10),
    bestseller: true,
  ),

  // ── Tops ──────────────────────────────────────────────────────────────
  Product(
    id: 'top-essex-shirt',
    slug: 'essex-cotton-shirt',
    name: 'Essex Cotton Shirt',
    category: ProductCategory.tops,
    tagline: 'A button-down with a softer collar.',
    description:
        'Our everyday shirt in midweight cotton poplin. A spread collar '
        'that lies flat under a sweater, mother-of-pearl buttons, and a '
        'shirt-tail hem that looks tucked or untucked.',
    priceUSD: 165,
    sizes: const <SizeOption>[
      SizeOption('XS'),
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
      SizeOption('XL'),
    ],
    colors: const <ColorOption>[
      ColorOption('White', 0xFFFBF7F1),
      ColorOption('Sky', 0xFFB7C2D8),
      ColorOption('Ink', 0xFF1B1A17),
    ],
    fabricTags: const <String>['Cotton', 'Poplin'],
    care: 'Machine wash cold. Tumble dry low or hang to dry.',
    leadTimeDays: 3,
    mtmLeadTimeDays: 18,
    mtmAvailable: true,
    stock: 12,
    galleryLabels: const <String>['White', 'Poplin', 'Shirt'],
    createdAt: _d(2026, 1, 5),
    bestseller: true,
  ),
  Product(
    id: 'top-linen-camp',
    slug: 'linen-camp-shirt',
    name: 'Linen Camp Shirt',
    category: ProductCategory.tops,
    tagline: 'Boxy, breezy, ready for a long lunch.',
    description:
        'A loose camp-collared shirt in 100% European linen, with a single '
        'patch pocket and coconut buttons. The kind of shirt that gets '
        'better with every wash.',
    priceUSD: 145,
    sizes: const <SizeOption>[
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
      SizeOption('XL'),
    ],
    colors: const <ColorOption>[
      ColorOption('Sand', 0xFFD9C2A6),
      ColorOption('Sage', 0xFF7A8C73),
      ColorOption('Ink', 0xFF1B1A17),
    ],
    fabricTags: const <String>['Linen'],
    care: 'Cold wash. Line dry. Iron on high while damp.',
    leadTimeDays: 3,
    mtmLeadTimeDays: 18,
    mtmAvailable: true,
    stock: 8,
    galleryLabels: const <String>['Sand', 'Linen', 'Camp'],
    createdAt: _d(2026, 4, 9),
    featured: true,
  ),
  Product(
    id: 'top-silk-camisole',
    slug: 'silk-camisole',
    name: 'Silk Camisole',
    category: ProductCategory.tops,
    tagline: 'The honest basics, in honest silk.',
    description: 'A clean-line camisole in sandwashed silk. Adjustable straps, '
        'a curved hem, and a bias body that drapes without clinging. '
        'Wear it alone in summer, layered in winter.',
    priceUSD: 125,
    sizes: const <SizeOption>[
      SizeOption('XS'),
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
    ],
    colors: const <ColorOption>[
      ColorOption('Pearl', 0xFFE9DBC6),
      ColorOption('Bordeaux', 0xFF6A2A33),
      ColorOption('Ink', 0xFF1B1A17),
    ],
    fabricTags: const <String>['Silk'],
    care: 'Hand wash cold. Roll in a towel. Lay flat to dry.',
    leadTimeDays: 4,
    mtmLeadTimeDays: 18,
    mtmAvailable: true,
    stock: 9,
    galleryLabels: const <String>['Pearl', 'Silk', 'Camisole'],
    createdAt: _d(2026, 2, 22),
  ),

  // ── Bottoms ───────────────────────────────────────────────────────────
  Product(
    id: 'bottom-tailored-trouser',
    slug: 'tailored-trouser',
    name: 'Tailored Trouser',
    category: ProductCategory.bottoms,
    tagline: 'A clean line from hip to hem.',
    description:
        'A high-rise trouser with a single forward pleat, side adjusters, '
        'and a slightly tapered leg. Cut from a midweight wool that holds '
        'its press without feeling stiff.',
    priceUSD: 285,
    sizes: const <SizeOption>[
      SizeOption('24'),
      SizeOption('26'),
      SizeOption('28'),
      SizeOption('30'),
      SizeOption('32'),
    ],
    colors: const <ColorOption>[
      ColorOption('Ink', 0xFF1B1A17),
      ColorOption('Stone', 0xFF8A8478),
      ColorOption('Clay', 0xFFB4724B),
    ],
    fabricTags: const <String>['Wool', 'Tailoring'],
    care: 'Dry clean only. Press on low with a pressing cloth.',
    leadTimeDays: 7,
    mtmLeadTimeDays: 28,
    mtmAvailable: true,
    stock: 5,
    galleryLabels: const <String>['Ink', 'Wool', 'Trouser'],
    createdAt: _d(2026, 1, 28),
    featured: true,
    bestseller: true,
  ),
  Product(
    id: 'bottom-wide-leg-linen',
    slug: 'wide-leg-linen-trouser',
    name: 'Wide-Leg Linen Trouser',
    category: ProductCategory.bottoms,
    tagline: 'A drawstring waist and a generous leg.',
    description:
        'Cut from a softly laundered linen, with a flat front, drawstring '
        'waist, slash pockets, and a wide straight leg. The kind of trouser '
        'that earns its place in your summer case.',
    priceUSD: 195,
    sizes: const <SizeOption>[
      SizeOption('XS'),
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
    ],
    colors: const <ColorOption>[
      ColorOption('Sand', 0xFFD9C2A6),
      ColorOption('White', 0xFFFBF7F1),
      ColorOption('Sage', 0xFF7A8C73),
    ],
    fabricTags: const <String>['Linen'],
    care: 'Machine wash cold. Hang to dry. Iron on high while damp.',
    leadTimeDays: 4,
    mtmLeadTimeDays: 18,
    mtmAvailable: true,
    stock: 7,
    galleryLabels: const <String>['Sand', 'Linen', 'Wide leg'],
    createdAt: _d(2026, 3, 19),
  ),
  Product(
    id: 'bottom-pleated-skirt',
    slug: 'pleated-midi-skirt',
    name: 'Pleated Midi Skirt',
    category: ProductCategory.bottoms,
    tagline: 'Knife pleats that swing.',
    description:
        'A midi-length knife-pleated skirt in a soft wool blend. Set on a '
        'contoured waistband, fully lined, and finished with a discreet '
        'back zip.',
    priceUSD: 215,
    sizes: const <SizeOption>[
      SizeOption('XS'),
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
    ],
    colors: const <ColorOption>[
      ColorOption('Ink', 0xFF1B1A17),
      ColorOption('Bordeaux', 0xFF6A2A33),
      ColorOption('Pearl', 0xFFE9DBC6),
    ],
    fabricTags: const <String>['Wool blend'],
    care: 'Dry clean recommended. Spot clean where possible.',
    leadTimeDays: 6,
    mtmLeadTimeDays: 24,
    mtmAvailable: true,
    stock: 4,
    galleryLabels: const <String>['Ink', 'Pleat', 'Midi'],
    createdAt: _d(2026, 2, 4),
  ),

  // ── Outerwear ─────────────────────────────────────────────────────────
  Product(
    id: 'outer-barn-coat',
    slug: 'waxed-cotton-barn-coat',
    name: 'Waxed Cotton Barn Coat',
    category: ProductCategory.outerwear,
    tagline: 'Weathered before you put it on.',
    description:
        'A traditional four-pocket barn coat in British-milled waxed cotton. '
        'Corozo buttons, a corduroy collar, and a flannel lining. Built to '
        'soften and fade with years of wear.',
    priceUSD: 485,
    sizes: const <SizeOption>[
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
      SizeOption('XL'),
    ],
    colors: const <ColorOption>[
      ColorOption('Tan', 0xFFB4724B),
      ColorOption('Olive', 0xFF6B7350),
    ],
    fabricTags: const <String>['Waxed cotton'],
    care: 'Spot clean only. Reproof annually with a wax dressing.',
    leadTimeDays: 10,
    mtmLeadTimeDays: 35,
    mtmAvailable: true,
    stock: 3,
    galleryLabels: const <String>['Tan', 'Waxed', 'Barn'],
    createdAt: _d(2026, 1, 20),
    featured: true,
  ),
  Product(
    id: 'outer-merino-cardigan',
    slug: 'merino-shawl-cardigan',
    name: 'Merino Shawl Cardigan',
    category: ProductCategory.outerwear,
    tagline: 'A shawl collar and a generous cut.',
    description:
        'Knitted in Italy from a heavy merino, with a deep shawl collar, '
        'patch pockets, and a wrap belt. A clean layer over a shirt, '
        'a coat on a cool evening.',
    priceUSD: 345,
    sizes: const <SizeOption>[
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
    ],
    colors: const <ColorOption>[
      ColorOption('Stone', 0xFF8A8478),
      ColorOption('Ink', 0xFF1B1A17),
      ColorOption('Rust', 0xFFB4724B),
    ],
    fabricTags: const <String>['Merino', 'Knit'],
    care: 'Hand wash cold. Lay flat to dry. Store folded.',
    leadTimeDays: 5,
    mtmLeadTimeDays: 28,
    mtmAvailable: true,
    stock: 6,
    galleryLabels: const <String>['Stone', 'Merino', 'Shawl'],
    createdAt: _d(2026, 3, 12),
    bestseller: true,
  ),

  // ── Occasionwear ──────────────────────────────────────────────────────
  Product(
    id: 'occasion-evening-gown',
    slug: 'hand-pleated-evening-gown',
    name: 'Hand-Pleated Evening Gown',
    category: ProductCategory.occasionwear,
    tagline: 'A floor-length gown in hand-set pleats.',
    description:
        'A bias-cut gown in silk crepe, with a hand-pleated bodice, a low '
        'back, and a sweeping hem. Made to order from a single panel of '
        'fabric, finished by hand in the atelier.',
    priceUSD: 1280,
    sizes: const <SizeOption>[
      SizeOption('XS', inStock: false),
      SizeOption('S', inStock: false),
      SizeOption('M', inStock: false),
      SizeOption('L', inStock: false),
    ],
    colors: const <ColorOption>[
      ColorOption('Bordeaux', 0xFF6A2A33),
      ColorOption('Midnight', 0xFF1F2330),
      ColorOption('Pearl', 0xFFE9DBC6),
    ],
    fabricTags: const <String>['Silk crepe'],
    care: 'Professional cleaning only.',
    leadTimeDays: 0,
    mtmLeadTimeDays: 60,
    mtmAvailable: true,
    stock: 0,
    galleryLabels: const <String>['Bordeaux', 'Gown', 'Pleated'],
    createdAt: _d(2026, 4, 1),
    featured: true,
  ),
  Product(
    id: 'occasion-wedding-shirt',
    slug: 'crinkled-cotton-wedding-shirt',
    name: 'Crinkled Cotton Wedding Shirt',
    category: ProductCategory.occasionwear,
    tagline: 'For the person who never wears a tux.',
    description:
        'A crinkled double-cotton shirt with french cuffs and a hidden '
        'front placket. Cut to drape; meant to be worn un-ironed, well '
        'into the evening.',
    priceUSD: 215,
    sizes: const <SizeOption>[
      SizeOption('S'),
      SizeOption('M'),
      SizeOption('L'),
      SizeOption('XL'),
    ],
    colors: const <ColorOption>[
      ColorOption('White', 0xFFFBF7F1),
      ColorOption('Pearl', 0xFFE9DBC6),
    ],
    fabricTags: const <String>['Cotton', 'Double gauze'],
    care: 'Machine wash cold. Tumble dry low. The crinkle is permanent.',
    leadTimeDays: 5,
    mtmLeadTimeDays: 18,
    mtmAvailable: true,
    stock: 5,
    galleryLabels: const <String>['White', 'Cotton', 'Wedding'],
    createdAt: _d(2026, 4, 21),
  ),
];

DateTime _d(int y, int m, int d) => DateTime(y, m, d);
