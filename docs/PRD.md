# Stitch & Soul — Product Requirements Document

> Version: 1.0 (MVP demo) · Owner: Maker · Status: Implementation-ready
> Last updated: 2026-08-17

---

## 1. Executive summary

**Stitch & Soul** is an independent sewing atelier and custom-clothing brand. The MVP is a
Flutter storefront (web-first, mobile/tablet responsive, mobile-compatible) that lets
visitors discover the maker's work, browse ready-to-wear and made-to-measure garments,
save favorites, capture custom measurements, and walk through a believable demo
checkout. The product targets editorial-grade presentation with restrained,
performant motion and a warm, premium aesthetic. The MVP is local-only: no
backend, no real payment processing, no PII persistence beyond the local device.

### 1.1 Vision

A small atelier's online home that *feels* like turning the pages of a fashion
journal, where every garment has a story, every measurement is taken with care,
and the path from discovery to checkout is calm, confident, and tactile.

### 1.2 Problem

Independent tailors and dressmakers struggle to translate a hand-made brand into
a credible online experience. Generic e-commerce platforms feel sterile, lose
the maker's voice, and ignore the realities of made-to-measure. Customers, in
turn, hesitate to commission custom work online because the process is opaque.

### 1.3 Goals

- Convey a premium, editorial brand presence on web and mobile.
- Let a first-time visitor reach a product detail page in **≤ 3 taps / clicks**.
- Provide a credible made-to-measure workflow with explicit unit handling and
  validation.
- Demonstrate a full happy-path commerce flow (browse → cart → checkout →
  receipt) entirely on-device.
- Reach Lighthouse Performance ≥ 85 on web for the landing and shop routes
  (target, not enforced in MVP).

### 1.4 Non-goals (MVP)

- Real payment processing, real card data, real PSP integration.
- Persistent server-side accounts, order storage, or inventory.
- Real shipping calculations, taxes, or address validation.
- Multi-language/currency content; only the scaffolding is provided.
- Admin dashboard, order management, or analytics ingestion.
- Native iOS/Android distribution beyond code that *compiles* for those
  targets; web is the primary surface.

### 1.5 Assumptions

- Single maker running the business.
- Catalog size in MVP: ~10–20 SKUs, all with a stable slug and id.
- Visuals use photography placeholders (semantic color blocks + labels) so the
  app renders without network access.
- All data is in-memory / on-device; no telemetry leaves the browser.
- The user has Flutter 3.22+ and Dart 3.4+ installed locally; if not, setup
  steps are documented in `README.md`.

### 1.6 Personas

| Persona | Goal | Pain today | What they need |
|---|---|---|---|
| **Maya, the bride-to-be** | Commission a one-of-a-kind dress | "I don't know if online tailoring is real." | Clear process, transparent timeline, simple measurement form |
| **Theo, the regular** | Buy a well-fitting linen shirt | "Mass-market shirts never fit my shoulders." | Size guidance, made-to-measure option, easy re-order |
| **Lena, the gift-giver** | Buy a gift card / outfit for her sister | "I need to feel the brand before I commit." | Editorial story, clear return/alteration policy, saved favorites |
| **Hiro, the browser** | Discover indie fashion | "Indie sites feel janky." | Fast, beautiful, accessible, on every device |

### 1.7 Jobs to be done

- *When I want a unique garment for an event*, I want to see samples, get a
  quote timeline, and submit my measurements, so I feel confident ordering
  custom.
- *When I want a wardrobe staple*, I want a clear size + fabric picker and
  fast add-to-cart, so I check out without friction.
- *When I am uncertain about fit*, I want a guided measurement form that
  explains each step, so I don't waste a commission.
- *When I am curious about a small brand*, I want a quiet, editorial site
  that loads fast, so I trust them with my money.

---

## 2. Value proposition & brand voice

**Value proposition.** A one-person atelier where every garment is made with
intention — discover ready-to-wear pieces or commission made-to-measure with
a guided, human process.

**Brand voice.** Calm, considered, intimate, slightly literary. Never breathless.
Never pushy. Plain words, well-chosen adjectives, sentence-case typography,
generous whitespace. Micro-copy uses the second person ("you") and first person
("we") sparingly.

**Visual language.** Warm ivory ground, ink type, clay accents, muted sage
supporting hue, subtle textile grain. Editorial spacing (12-pt scale with
generous gutters). Premium serif for display, neo-grotesque for UI. Motion
under 600 ms; never blocks interaction.

---

## 3. Information architecture

### 3.1 Routes (web URLs map 1:1 to mobile routes)

| Path | Screen | Notes |
|---|---|---|
| `/` | Home | Hero, featured collections, story, newsletter |
| `/shop` | Shop / catalog | Filters, search, sort, grid |
| `/shop/:category` | Shop filtered by category | `dresses`, `tops`, `bottoms`, `outerwear`, `occasionwear` |
| `/product/:slug` | Product detail | Gallery, options, MTM entry, related |
| `/services` | Services | MTM, alterations, consultation |
| `/story` | Story / about | Atelier narrative, process timeline |
| `/contact` | Contact | Form, location, hours |
| `/measurements/new` | Measurement flow | Multi-step wizard |
| `/favorites` | Favorites | Saved products |
| `/cart` | Cart | Editable lines, promo |
| `/checkout` | Checkout demo | 3-step (contact → delivery → review) |
| `/checkout/success` | Order receipt | Mock order number |
| `/404` | Not found | Editorial empty state |

### 3.2 Primary user journeys

1. **Discover → buy ready-to-wear**
   Home → Shop → filter "Dresses" → product → size+color → Add to cart →
   Cart → Checkout (demo) → Receipt.

2. **Discover → commission made-to-measure**
   Home → "Made to measure" CTA → Services → Start a commission → Product
   detail (MTM variant) → Enter measurements (wizard) → Add to cart with
   MTM flag → Checkout (demo) → Receipt with longer lead time.

3. **Browse → favorite → return**
   Shop → tap heart → Favorites icon in nav shows count → return to
   Favorites later.

4. **Story → contact**
   Home → Story → "Visit the atelier" → Contact form.

5. **Search-driven**
   Shop → type "linen" → grid filters live → open a product.

---

## 4. Functional requirements

Each requirement is **P0** (must ship), **P1** (ship if time permits), or
**P2** (later). Acceptance criteria are testable.

### 4.1 Catalog & merchandising

- **F-1 [P0]** Product taxonomy includes five categories: `dresses`, `tops`,
  `bottoms`, `outerwear`, `occasionwear`. **AC:** category chips render on
  the Shop screen and route to filtered lists.
- **F-2 [P0]** ≥ 10 mock products across the taxonomy, each with a stable
  `id` and `slug`. **AC:** `test/catalog_test.dart` asserts count and
  category coverage.
- **F-3 [P0]** Filters: category, size, color, fabric, price range,
  availability. **AC:** chips toggle; grid updates; URL query param
  reflects active filters.
- **F-4 [P0]** Sort: Featured, Price ↑, Price ↓, Newest. **AC:** sort
  change re-orders grid without page reload.
- **F-5 [P0]** Search by title and short description (case-insensitive,
  substring). **AC:** empty query shows full list; no results state shows
  "No matches" with a "Clear filters" CTA.
- **F-6 [P1]** Empty state with editorial copy and "Browse all" CTA.

### 4.2 Product detail

- **F-10 [P0]** Gallery with primary image + 2–3 alternates, accessible
  thumbnails. **AC:** keyboard arrow keys cycle images on web when focused.
- **F-11 [P0]** Options: size, color/fabric, quantity, ready-to-wear vs
  made-to-measure, lead time, care. **AC:** unavailable options are
  visibly disabled with reason.
- **F-12 [P0]** Availability indicator and estimated ship date. **AC:**
  out-of-stock products show "Made to order" CTA instead of "Add to cart".
- **F-13 [P0]** Add to cart adds the selected variant with quantity and
  any customizations; cart count updates. **AC:** cart count badge
  animates on add.
- **F-14 [P0]** Favorite toggle persists in local state. **AC:** tapping
  the heart toggles state and animates the icon.
- **F-15 [P0]** Related products row (same category, exclude self). **AC:**
  shows up to 4 items.
- **F-16 [P1]** "Made to measure" entry point opens the measurement wizard
  prefilled with the product context.

### 4.3 Measurement flow

- **F-20 [P0]** Multi-step wizard: Welcome → Units → Body → Fit
  preferences → Notes → Review.
- **F-21 [P0]** Unit toggle: cm / in (stored as a single source of truth
  in cm internally; displayed in chosen unit).
- **F-22 [P0]** Fields: bust/chest, waist, hips, shoulder, sleeve length,
  inseam, height. **AC:** each field shows min/max bounds and inline
  validation.
- **F-23 [P0]** Fit preference: Slim, Standard, Relaxed. **AC:** choice is
  recorded in the cart line and on the receipt.
- **F-24 [P0]** "Save my profile locally" consent checkbox (opt-in, not
  opt-out). **AC:** unchecked by default; only when checked is the profile
  stored in `SharedPreferences` (or in-memory on web).
- **F-25 [P1]** Progress indicator with step labels.
- **F-26 [P0]** "How to measure" guidance on every body step.
- **F-27 [P0]** Review screen summarizes entered data; user can jump back
  to any step.

### 4.4 Cart, promo, checkout

- **F-30 [P0]** Editable quantities, remove, and clear-cart.
- **F-31 [P0]** Promo code input accepts codes from a static list
  (`WELCOME10`, `ATELIER15`); rejected codes show inline error.
- **F-32 [P0]** Subtotal, shipping estimate, tax estimate, total.
  - Subtotal = sum(qty × unit price).
  - Shipping = flat demo rate, free over a configurable threshold.
  - Tax = 8% demo rate of subtotal; can be zeroed with promo `ATELIER15`.
- **F-33 [P0]** Checkout 3 steps: contact, delivery/pickup, review.
- **F-34 [P0]** Placeholder payment step **never** collects or persists
  real card data. **AC:** the form only contains a "Use demo card" button
  that simulates success; no field accepts a real PAN.
- **F-35 [P0]** Success page shows a generated mock order number
  (`SS-YYYYMMDD-XXXX`), summary, and "Continue browsing" CTA.

### 4.5 Services, story, contact

- **F-40 [P0]** Services page lists MTM, alterations, consultation with
  per-service description, starting price, and ETA.
- **F-41 [P0]** Story page has atelier narrative, process timeline, and
  "Visit the atelier" CTA.
- **F-42 [P0]** Contact form: name, email, subject, message, with
  validation and a "demo only" notice on submit.

### 4.6 Home

- **F-50 [P0]** Hero with animated headline, supporting copy, two CTAs
  ("Shop the collection", "Made to measure").
- **F-51 [P0]** Featured collections row.
- **F-52 [P0]** Bestsellers grid (top 4).
- **F-53 [P0]** MTM explainer with timeline.
- **F-54 [P0]** Craftsmanship / story snippet with "Read our story" CTA.
- **F-55 [P0]** Testimonials carousel (manual swipe + auto-rotate,
  pause-on-hover; auto-rotate disabled under reduced motion).
- **F-56 [P0]** Newsletter email input (UI only, with demo "subscribed"
  confirmation).
- **F-57 [P0]** Footer with brand, links, social placeholders, copyright.

### 4.7 Navigation & layout

- **F-60 [P0]** Responsive nav: top bar with logo + links + cart/favorites
  on ≥768 px; bottom-anchored drawer trigger on <768 px.
- **F-61 [P0]** Cart and favorites counts visible at all breakpoints.
- **F-62 [P0]** All primary CTAs route to a real screen or trigger an
  explicit demo state.
- **F-63 [P0]** Deep links work on web refresh via standard Flutter web
  URL strategy.

### 4.8 Accessibility (WCAG 2.2 AA intent)

- **F-70 [P0]** Color contrast ≥ 4.5:1 for body text, ≥ 3:1 for large
  text and UI components.
- **F-71 [P0]** Visible focus rings on all interactive elements on web.
- **F-72 [P0]** Semantic labels for icon-only buttons (favorites, cart,
  menu).
- **F-73 [P0]** Form fields have associated labels and inline error text.
- **F-74 [P0]** Tap targets ≥ 44 × 44 px on touch.
- **F-75 [P0]** `MediaQuery.disableAnimations` / `prefers-reduced-motion`
  disables non-essential motion.
- **F-76 [P1]** Text scaling up to 1.5× without overflow on home and shop.

### 4.9 Performance, SEO, privacy

- **F-80 [P0]** Initial route under ~250 KB gzip on web (target; not
  measured in MVP, code is structured to enable tree-shaking).
- **F-81 [P0]** Page titles and meta descriptions set per route via
  Flutter web's `<title>` injection; `robots.txt` and `sitemap.xml` are
  documented even if not deployed.
- **F-82 [P0]** No third-party analytics in MVP. All state local. Privacy
  copy on the contact and newsletter forms.
- **F-83 [P0]** Imagery uses placeholders; remote images, if used, fall
  back gracefully.

### 4.10 Errors, empty, loading, offline

- **F-90 [P0]** Loading skeletons on shop and product detail.
- **F-91 [P0]** Empty states designed (favorites, cart, search).
- **F-92 [P0]** 404 page with editorial copy and a "Back to home" CTA.
- **F-93 [P0]** Image fallback: a styled placeholder block with the
  product name appears if an image is missing or fails to load.

---

## 5. Data model (in-memory)

```dart
class Product {
  final String id;            // stable
  final String slug;          // url-safe
  final String name;
  final String category;      // dresses | tops | bottoms | outerwear | occasionwear
  final String description;
  final List<String> story;   // 1–3 paragraphs
  final double priceUSD;
  final List<SizeOption> sizes;
  final List<ColorOption> colors;
  final List<String> fabricTags;
  final int leadTimeDays;     // ready-to-wear
  final int mtmLeadTimeDays;  // made-to-measure
  final bool mtmAvailable;
  final String care;          // one-paragraph care guide
  final List<String> imageLabels;  // semantic placeholders
  final List<String> galleryLabels;
  final DateTime createdAt;
  final bool featured;
  final bool bestseller;
}

class SizeOption { final String label; final bool inStock; }
class ColorOption { final String name; final int hex; }

class CartLine {
  final String productId;
  final String size;
  final String color;
  final int quantity;
  final bool madeToMeasure;
  final MeasurementProfile? measurements;
  final String? notes;
}

class MeasurementProfile {
  final UnitSystem units;          // cm | in
  final double? bust;              // cm internally
  final double? waist;
  final double? hips;
  final double? shoulder;
  final double? sleeve;
  final double? inseam;
  final double? height;
  final FitPreference fit;         // slim | standard | relaxed
  final String? notes;
}
```

---

## 6. Service / API boundaries (MVP)

The MVP has **no remote API**. All data lives in Dart constants under
`lib/data/` and in `SharedPreferences` (web `localStorage`) for
favorites/measurement profile. The seams are designed so a real backend can
drop in later:

```dart
abstract class ProductRepository {
  Future<List<Product>> all();
  Future<Product?> bySlug(String slug);
  Future<List<Product>> related(Product p, {int limit = 4});
}

abstract class CartRepository { /* in-memory + serialization for handoff */ }
abstract class FavoritesRepository { /* local persistence */ }
abstract class MeasurementsRepository { /* local persistence, consent-gated */ }
```

---

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Flutter not installed in env | Document `flutter` install steps in `README.md`; commit a complete, runnable source tree. |
| Heavy animations hurt perf on web | Use `AnimatedBuilder` + `Tween`; cap durations ≤ 600 ms; respect `prefers-reduced-motion`. |
| Image network failures | Render a labeled color-block placeholder; no broken-image icons. |
| Accessibility regression | Use `Semantics` widgets; provide `label`/`hint` for icon buttons; visible focus rings. |
| Cart total drift | Single source of truth in `CartNotifier`; totals computed from lines, not stored. |
| MTM measurement mistakes | Inline validation, unit display, "How to measure" copy on every step. |
| "Dead CTA" perception | Every primary CTA in the nav and home is wired to a real screen; demo states are explicit. |

---

## 8. MVP vs later roadmap

**MVP (this delivery)**
- All routes, screens, and states above.
- Local mock data, local persistence for favorites and consent-given
  measurement profile.
- Editorial visual system, motion system, accessibility baseline.
- Unit tests for catalog filtering, cart math, measurement validation,
  one navigation smoke.

**Phase 2**
- Real backend (orders, accounts, inventory).
- Real payment (Stripe / Adyen) on the existing placeholder step.
- Real photography; replace placeholder blocks.
- Internationalization (en, fr, ja) and currency switching.
- Admin app for orders, MTM queue, fabric inventory.

**Phase 3**
- Lookbook CMS, blog, press kit.
- Gift cards, store credit, referrals.
- Loyalty program.

---

## 9. Launch checklist (MVP)

- [x] All routes implemented and reachable.
- [x] At least 10 products across the taxonomy.
- [x] Cart, checkout (demo), and receipt flows.
- [x] Measurement wizard with validation and consent.
- [ ] Verify responsive behavior at 360 / 768 / 1440 with Flutter installed.
- [x] Reduced-motion respected.
- [ ] Run unit tests and static analysis after Flutter is installed.
- [x] README documents setup, run, test, build.

---

## 10. Success metrics

- **Activation:** % of visitors who reach a product detail page.
- **Engagement:** % of visitors who add to cart or favorite.
- **Conversion (demo):** % of cart-reachers who reach `/checkout/success`.
- **A11y:** zero critical a11y issues on home, shop, product, cart.
- **Perf:** home first-contentful-paint < 1.5 s on a 4G throttled run
  (target; not measured in CI).

---

## 11. Definition of done (this delivery)

- `docs/PRD.md` exists and is complete.
- `flutter pub get` succeeds; `flutter analyze` is clean or only has
  pre-agreed advisory lints; `flutter test` passes. This remains a launch
  gate because Flutter was unavailable in the generation environment.
- The app runs on web (`flutter run -d chrome`) and the seven required
  experiences are reachable and functional.
- Every primary CTA is wired to a real screen or explicit demo state.
- README documents the exact setup commands and known demo limits.

---

## 12. Demo limitations (explicit)

- No real payments, no real shipping, no real taxes.
- No server: cart state resets with the app; favorites and a consent-given
  measurement profile persist locally through `SharedPreferences`.
- No real photography; visuals are semantic color blocks with labels.
- Newsletter, contact, and consultation forms only confirm receipt on the
  client; nothing is sent.
- Order numbers are timestamp-derived mocks.

---

*End of PRD.*
