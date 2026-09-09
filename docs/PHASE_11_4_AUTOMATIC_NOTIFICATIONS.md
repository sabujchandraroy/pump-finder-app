# PumpFinder Phase 11.4 — Automatic Notifications

## What was added
- Server-side report status notifications.
- Server-side new-pump notifications to registered users.
- Server-side new-review notifications to admins.
- Server-side new-favorite notifications to admins.
- Supabase Realtime subscription for the Flutter notification provider.
- Notification badge/list can update automatically after a database notification is inserted.

## Architecture
UI → Provider → UseCase → Repository → RemoteDataSource → Supabase/PostgreSQL

Database-generated notifications are created by PostgreSQL SECURITY DEFINER trigger functions. The Flutter client does not receive permission to insert arbitrary notification rows.

## Supabase setup
Run these SQL files in order:
1. `supabase_phase11_notifications.sql`
2. `supabase_phase11_4_automatic_notifications.sql`

Then run:
```powershell
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```

## Important recipient rule
The current `petrol_pumps` table does not contain an `owner_id`, so review/favorite events are sent to admin users rather than pretending there is a pump owner. A future `owner_id` feature can change this without changing the notification UI architecture.
