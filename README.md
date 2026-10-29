# VisitDesk

Visitor management app for front-desk and security staff (Sumadhura Group machine test).
Register visitors, search/edit/delete, generate and scan QR codes, check in/out, and see live stats.

- Flutter 3.47.5 / Dart (stable), Android only, package `com.visitdesk.user`

## Features
- Dashboard stats, register/edit/delete, search, QR generation and scanning, check-in/out
- Bonus: splash screen, filter by status/project, pull-to-refresh, offline cache of the last list, dark mode (toggle on dashboard)

## Setup
1. Create a [MockAPI.io](https://mockapi.io) project with a `visitors` resource (fields below) and seed 4–5 records
   covering all three statuses and different dates.
2. Set the base URL in `lib/core/config/api_config.dart`, or pass it at run time:
   `flutter run --dart-define=API_BASE_URL=https://<id>.mockapi.io/api/v1`
3. `flutter pub get && flutter run`
4. Release APK: `flutter build apk --release --dart-define=API_BASE_URL=...`

### Sample record
```json
{
  "id": "1", "name": "Rahul Sharma", "mobile": "9876543210", "email": "rahul@example.com",
  "visitor_type": "Customer", "project": "Project A", "purpose": "Site Visit",
  "status": "Registered", "created_at": "2026-10-26T10:00:00+05:30",
  "check_in_time": null, "check_out_time": null
}
```
The `id` is server generated and is what the QR code encodes.

## Packages
provider, dio, go_router, qr_flutter, mobile_scanner, permission_handler, intl, shared_preferences

## State management
Provider (`ChangeNotifier`): simple, part of the Flutter ecosystem, and enough for this app's scale.
`VisitorProvider` is the single source of truth; list, details and dashboard all read from it, so a
check-in updates every screen without a restart. Transitions are re-validated in the provider and
a per-visitor busy flag ignores double taps.

## Structure
`core/` (config, theme, network, router, utils) · `data/` (model, repository) · `providers/` ·
`features/` (dashboard, visitors, scanner, shell) · `widgets/` (reusable components)

## Known limitations
- One visit per registration; no history.
- Offline cache is read-only: the last fetched list is shown with a banner, but writes need a connection.
- Free MockAPI tiers have resource limits; keep the project active during evaluation.
