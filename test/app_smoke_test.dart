import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch_and_soul/app/router.dart';
import 'package:stitch_and_soul/data/repositories.dart';
import 'package:stitch_and_soul/widgets/product_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home → product → cart smoke path', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: <Override>[
        favoritesRepositoryProvider.overrideWithValue(
          FavoritesRepository(prefs),
        ),
        measurementsRepositoryProvider.overrideWithValue(
          MeasurementsRepository(prefs),
        ),
      ],
    );

    // Build the full app with a provider scope and a router bound to the
    // same container.
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    // We are on the home screen.
    expect(find.text('Stitch & Soul'), findsWidgets);
    expect(
      find.text('Garments, made slowly,\nfor the long table.'),
      findsOneWidget,
    );

    // Tap the Shop the collection CTA in the hero.
    final shopCta = find.widgetWithText(
      ElevatedButton,
      'SHOP THE COLLECTION',
    );
    await tester.ensureVisible(shopCta);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(shopCta);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(router.state.uri.path, '/shop');
    expect(find.text('THE COLLECTION'), findsOneWidget);

    // Tap the first product card.
    await tester.ensureVisible(find.byType(ProductCard).first);
    await tester.tap(find.byType(ProductCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // We're on a product detail page with a working purchase action.
    expect(find.text('ADD TO CART'), findsOneWidget);
  });
}
