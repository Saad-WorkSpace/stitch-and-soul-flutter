import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_and_soul/data/mock_catalog.dart';
import 'package:stitch_and_soul/data/models.dart';
import 'package:stitch_and_soul/data/repositories.dart';
import 'package:stitch_and_soul/state/cart_notifier.dart';

void main() {
  group('CartNotifier', () {
    late CartNotifier cart;
    late InMemoryProductRepository repo;

    setUp(() {
      cart = CartNotifier();
      repo = InMemoryProductRepository(kMockProducts);
    });

    test('starts empty', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
    });

    test('addLine increases item count and lines', () {
      cart.addLine(
        const CartLine(
          productId: 'top-essex-shirt',
          size: 'M',
          colorName: 'White',
          quantity: 2,
        ),
      );
      expect(cart.isEmpty, isFalse);
      expect(cart.itemCount, 2);
      expect(cart.lines.length, 1);
    });

    test('updateQuantity with 0 removes the line', () {
      cart.addLine(
        const CartLine(
          productId: 'top-essex-shirt',
          size: 'M',
          colorName: 'White',
          quantity: 1,
          lineId: 'L1',
        ),
      );
      cart.updateQuantity('L1', 0);
      expect(cart.lines, isEmpty);
    });

    test('updateQuantity with positive value updates quantity', () {
      cart.addLine(
        const CartLine(
          productId: 'top-essex-shirt',
          size: 'M',
          colorName: 'White',
          quantity: 1,
          lineId: 'L1',
        ),
      );
      cart.updateQuantity('L1', 3);
      expect(cart.lines.single.quantity, 3);
      expect(cart.itemCount, 3);
    });

    test('totals apply MTM surcharge and percentage promo', () {
      final product = kMockProducts.firstWhere(
        (p) => p.id == 'dress-ivory-linen',
      );
      // RTW
      cart.addLine(
        CartLine(
          productId: product.id,
          size: 'M',
          colorName: 'Ivory',
          quantity: 1,
          madeToMeasure: false,
          lineId: 'L1',
        ),
      );
      final totalsRtw = cart.totals(repo);
      expect(totalsRtw.subtotal, closeTo(product.priceUSD, 0.001));

      // Add a second line made to measure.
      cart.addLine(
        CartLine(
          productId: product.id,
          size: 'M',
          colorName: 'Clay',
          quantity: 1,
          madeToMeasure: true,
          lineId: 'L2',
        ),
      );
      final totalsBoth = cart.totals(repo);
      expect(
        totalsBoth.subtotal,
        closeTo(product.priceUSD + product.priceUSD * 1.25, 0.001),
      );

      // Apply 10% promo
      cart.applyPromo('WELCOME10');
      final totalsPromo = cart.totals(repo);
      expect(totalsPromo.discount, greaterThan(0));
      expect(totalsPromo.discount, closeTo(totalsBoth.subtotal * 0.10, 0.001));
    });

    test('free shipping kicks in above the threshold', () {
      // Find an expensive product to push the subtotal over the threshold.
      final gown = kMockProducts.firstWhere(
        (p) => p.id == 'occasion-evening-gown',
      );
      cart.addLine(
        CartLine(
          productId: gown.id,
          size: 'M',
          colorName: 'Bordeaux',
          quantity: 1,
          lineId: 'L1',
        ),
      );
      final totals = cart.totals(repo);
      expect(
        totals.subtotal,
        greaterThanOrEqualTo(CartNotifier.freeShippingThreshold),
      );
      expect(totals.shipping, 0);
    });

    test('unknown promo code returns an error', () {
      final err = cart.applyPromo('NOPE');
      expect(err, isNotNull);
      expect(cart.appliedPromo, isNull);
    });

    test('clear empties cart and promo', () {
      cart.addLine(
        const CartLine(
          productId: 'top-essex-shirt',
          size: 'M',
          colorName: 'White',
          quantity: 1,
          lineId: 'L1',
        ),
      );
      cart.applyPromo('WELCOME10');
      cart.clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.appliedPromo, isNull);
    });
  });
}
