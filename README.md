# Stitch & Soul

An editorial, responsive Flutter storefront for a one-person clothing atelier. The app is web-first and remains compatible with Android and iOS.

The product requirements are in [`docs/PRD.md`](docs/PRD.md).

## What is implemented

- Home, catalog, category, product detail, services, story, contact, favorites, cart, measurement wizard, demo checkout, success receipt, and not-found routes.
- Thirteen clothing products across dresses, tops, bottoms, outerwear, and occasionwear.
- Ready-to-wear and made-to-measure variants, sizes, colors, lead times, stock, care, and related products.
- Search, category, availability, price, and sort controls.
- Cart quantity changes, removal, promo codes, shipping/tax estimates, and a 25% made-to-measure surcharge.
- Five-step measurement flow with cm/in support, validation, fit preference, notes, consent, review, and optional local persistence.
- Riverpod state, `go_router` navigation, `SharedPreferences` persistence, responsive layouts, keyboard-aware controls, semantics, and reduced-motion behavior.
- Local textile-style placeholders, so the experience remains usable without remote images.

## Prerequisites

- Flutter stable 3.27 or newer.
- Dart is included with Flutter.
- Chrome or Edge for Flutter Web.
- VS Code extensions: **Flutter** and **Dart**.

This project has been verified with Flutter 3.47.0 and Dart 3.13.0.

Verify your environment:

```powershell
flutter doctor
flutter --version
```

## Run locally

From the project directory:

```powershell
flutter pub get
flutter run -d chrome
```

For a mobile emulator/device:

```powershell
flutter devices
flutter run -d <device-id>
```

## Quality checks

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

The focused tests cover catalog filtering, safe result limits, cart totals and quantities, measurement validation, and a home-to-product smoke path.

## Routes

| Route | Experience |
| --- | --- |
| `/` | Editorial home |
| `/shop` | Full catalog |
| `/shop/category/:category` | Category catalog |
| `/product/:slug` | Product detail |
| `/measurements/new` | Measurement wizard |
| `/services` | Made-to-measure and alterations |
| `/story` | Atelier story |
| `/contact` | Demo consultation/contact form |
| `/favorites` | Saved garments |
| `/cart` | Shopping bag |
| `/checkout` | Demo checkout |
| `/checkout/success` | Mock receipt |

## Architecture

```text
lib/
  app/          theme, motion, tokens, brand details, router, bootstrap
  data/         immutable models, mock catalog, filtering, repositories
  state/        cart and catalog state
  features/     route-level screens grouped by feature
  widgets/      shared responsive, navigation, product, and visual widgets
```

The app uses a small feature-first structure. Repositories isolate mocked data and local persistence, so a production API can replace them without rewriting route-level UI. State avoids generated code to keep the first setup predictable.

Brand constants are centralized in `lib/app/brand.dart`. Visual tokens and breakpoints live in `lib/app/tokens.dart`; motion timings and reduced-motion handling live in `lib/app/motion.dart`.

## Motion approach

The React Bits reference is translated into native Flutter behavior: staggered hero reveals, animated gradient orbs, fade/slide route transitions, hover lift, animated chips and favorites, and smooth content switching. `MediaQuery.disableAnimations` disables decorative motion where requested.

## Demo behavior

- No backend, authentication, inventory service, email delivery, shipping quote, tax service, or payment processor is connected.
- Checkout never requests or stores real card credentials.
- Cart state resets when the app restarts.
- Favorites and a measurement profile are stored locally only when the applicable action/consent occurs.
- Contact and newsletter forms show local confirmation but transmit nothing.
- Product imagery is represented by reliable local placeholders.

## Production next steps

1. Run the quality commands above and fix any SDK-version-specific findings.
2. Replace placeholders with optimized, licensed product photography.
3. Connect catalog, inventory, customer, order, shipping, tax, analytics, and CMS services behind repository interfaces.
4. Add an audited hosted checkout; never collect raw payment credentials in this Flutter client.
5. Add localization, currency formatting, consent management, error reporting, and production analytics.
6. Validate keyboard, screen-reader, contrast, text-scaling, and responsive behavior at 360, 768, and 1440 logical pixels.
7. Configure web hosting rewrites so deep links return `index.html`.

## Demo promo codes

- `WELCOME10` — 10% off.
- `ATELIER15` — 15% off.
- `FREESHIP` — free shipping.
