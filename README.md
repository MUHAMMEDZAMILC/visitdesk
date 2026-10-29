# VisitDesk

Visitor management app for front-desk and security staff (Sumadhura Group machine test).
Register visitors, search/edit/delete, generate and scan QR codes, check in/out, and see live stats.

- Flutter 3.47.5 / Dart (stable), package `com.visitdesk.user`

## Features
- Dashboard stats, register/edit/delete, search, QR generation and scanning, check-in/out
- Bonus: splash screen, filter by status/project, pull-to-refresh, offline cache of the last list, dark mode (toggle on dashboard)

## Setup
1. `flutter pub get && flutter run`
2. No backend needed. Visitors are stored as one JSON file each:
   `<app documents>/visitdesk_data/visitors/<id>.json`
   On first launch the folder is seeded from `assets/data/visitors/` (5 sample records). The exact
   path is printed in the debug console (`VisitDesk data folder: ...`).
3. iOS: the camera usage description for QR scanning is already in `ios/Runner/Info.plist`.

### Sample record
```json
{
  "id": "1", "name": "Rahul Sharma", "mobile": "9876543210", "email": "rahul@example.com",
  "visitor_type": "Customer", "project": "Project A", "purpose": "Site Visit",
  "status": "Registered", "created_at": "2026-10-26T10:00:00+05:30",
  "check_in_time": null, "check_out_time": null
}
```
The `id` is the file name and is what the QR code encodes.

## Theme
Matches the GoLoad user app: mint `#00D1A7` primary, navy `#07161E` secondary, off-white background,
pill buttons and fields, Plus Jakarta Sans for headings/buttons and Liberation Sans for body text.
Shared widgets: `AppButton`, `AppText`, `AppContainer`, `AppTextField` (in `lib/widgets/`),
colors in `core/theme/app_colors.dart`.

## Tests
`flutter test` (unit) and `flutter test integration_test -d <device>` (full walkthrough of every screen).

## Packages
provider, path_provider, go_router, qr_flutter, mobile_scanner, permission_handler, intl, shared_preferences

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
- Data is local to the device; uninstalling the app removes it.
