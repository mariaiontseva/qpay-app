# qpay-app

QPay mobile client — Flutter iOS + Android.

Companion repos:
- [`qpay-strategy`](https://github.com/mariaiontseva/qpay-strategy) — product strategy, wireframes, CH plan, architecture (public)
- `qpay-backend` — TypeScript API, Companies House integration, database (private, TBD)

Full architecture context: https://mariaiontseva.github.io/qpay-strategy/architecture.html

## Current status

First 5 onboarding screens of the formation flow implemented:
- **A-01** Sign up for QPay (name, email, +44 mobile)
- **A-02** Pick your path (form a new Ltd / have one already)
- **A-03** Pre-flight (passport, home address, company idea)
- **A-04** Is this just you, or a team? (solo default)
- **A-05** Name your company (live availability)

Design system is wired up end-to-end:
- Tokens (colors, spacing, radii, motion) → `lib/design_system/tokens.dart`
- Typography presets (Plus Jakarta Sans + JetBrains Mono via `google_fonts`) → `lib/design_system/typography.dart`
- Reusable widgets: `QScreen`, `QProgressBar`, `QHeader`, `QField`, `QButton`, `QChoiceCard`, `QNumberedRow`, `QBottomBar` → `lib/design_system/widgets/`

Reference designs (prototype): Claude Design export `QPay Formation Flow.html` + `qpay-tokens.jsx`.

## Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.22+ |
| Language | Dart 3.4+ |
| Navigation | `go_router` |
| Fonts | `google_fonts` (Plus Jakarta Sans, JetBrains Mono) |
| Networking | *Generated Dart client from `qpay-backend` OpenAPI schema — TBD* |
| Push / crash | Firebase Messaging + Crashlytics (TBD) |
| Release | Fastlane → TestFlight + Play Internal (TBD) |

## Getting started

Prerequisites:
- Flutter SDK ≥ 3.22 (`flutter --version`)
- Xcode 15+ (macOS) for iOS builds
- Android Studio + Android SDK for Android builds

One-time bootstrap after cloning (Flutter needs to generate the platform
folders for iOS and Android — we don't commit them because they're entirely
derived):

```bash
flutter create . --project-name qpay_app --org com.mariaiontseva --platforms ios,android
flutter pub get
```

Run on an attached device or simulator:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

## Project layout

```
lib/
  main.dart                    Boot + orientation lock
  app.dart                     MaterialApp.router + GoRouter config
  design_system/
    tokens.dart                Colors, spacing, radii, motion
    typography.dart            TextStyle presets (Plus Jakarta / Mono)
    widgets/
      q_screen.dart            Warm-canvas scaffold + optional ambient bg
      q_progress_bar.dart      Back arrow + animated step progress
      q_header.dart            Hero title + optional subtitle
      q_field.dart             Text input with accent focus ring
      q_button.dart            Pill CTA (primary / secondary / ghost / accent)
      q_choice_card.dart       Selectable option card with round checkbox
      q_numbered_row.dart      Numbered checklist item
      q_bottom_bar.dart        Safe-area CTA wrapper
  features/onboarding/screens/
    signup_screen.dart         A-01
    intent_screen.dart         A-02
    preflight_screen.dart      A-03
    solo_screen.dart           A-04
    name_screen.dart           A-05
test/
  onboarding_flow_test.dart    Smoke test for initial route + nav
```

## What lives here vs. not here

**Here:** UI screens, local state, device integrations (camera, biometrics,
NFC for passport scan), generated API client, visual design system.

**Not here:** business logic, direct database access, direct Stripe /
Companies House / KYC vendor calls, long-lived secrets. All of that goes
through `qpay-backend`.

## Related

- [Architecture](https://mariaiontseva.github.io/qpay-strategy/architecture.html)
- [Formation flow wireframes (Path A)](https://mariaiontseva.github.io/qpay-strategy/formation.html)
- [Companies House access plan](https://mariaiontseva.github.io/qpay-strategy/ch-access.html)
