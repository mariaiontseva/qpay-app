# qpay-app

QPay mobile client — Flutter iOS + Android.

Companion repos:
- [`qpay-strategy`](https://github.com/mariaiontseva/qpay-strategy) — product strategy, wireframes, Companies House plan, architecture docs (public)
- `qpay-backend` — TypeScript API, Companies House integration, database (private, to come)

Full architecture context: https://mariaiontseva.github.io/qpay-strategy/architecture.html

## Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.x |
| Language | Dart |
| State | Riverpod |
| Navigation | GoRouter |
| Networking | Generated Dart client from `qpay-backend` OpenAPI schema |
| Push / crash | Firebase Messaging + Crashlytics |
| Release | Fastlane → TestFlight + Play Internal |

## What lives here vs. not here

**Here:** UI screens, local state, device integrations (camera, biometrics, NFC for passport scan), the generated API client, visual design system.

**Not here:** business logic, direct database access, direct Stripe / Companies House / KYC vendor calls, long-lived secrets. All of that goes through `qpay-backend`.

## Getting started

Prerequisites:
- Flutter SDK 3.x (`flutter --version`)
- Xcode 15+ (macOS) for iOS builds
- Android Studio + Android SDK for Android builds

```bash
flutter pub get
flutter run             # runs on attached device / simulator
```

## Project layout

```
lib/
  features/             # one folder per product area: onboarding, formation, accounts, ...
  core/                 # shared widgets, theming, helpers
  api/                  # generated OpenAPI client (do not edit by hand)
  main.dart
ios/                    # iOS platform project
android/                # Android platform project
test/                   # unit + widget tests
integration_test/       # end-to-end flows
```

## CI

GitHub Actions runs on every PR:

1. `flutter analyze` — static analysis
2. `flutter test` — unit + widget tests
3. `flutter build ios --no-codesign` — build sanity
4. `flutter build apk --debug` — Android build sanity

On merges to `main`:
- Fastlane pushes to TestFlight and Play Internal track

## Secrets

App Store Connect API key, Play Console service account, and Fastlane Match repo key live in GitHub Actions secrets. Never commit them.

## Access

| Role | Access |
|------|--------|
| Maria | admin |
| Farid | write (review UI + formation flow) |
| Mobile contractor | write (when onboarded) |
| Backend contractor | read |

## Related

- [Architecture doc](https://mariaiontseva.github.io/qpay-strategy/architecture.html)
- [Formation flow (Path A wireframes)](https://mariaiontseva.github.io/qpay-strategy/formation.html)
- [Companies House access plan](https://mariaiontseva.github.io/qpay-strategy/ch-access.html)
