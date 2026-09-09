# Phase 11.6 — Notification Polish & Reliability

## Included
- Supabase Realtime subscription remains behind the notification repository/data source.
- Notification data is cached locally with Hive.
- Cache is scoped by authenticated user ID to avoid cross-account notification leakage.
- Remote notifications are preferred; cached notifications are used when remote loading fails.
- Read-all/read/delete operations update the local cache after successful remote mutation.
- Realtime events refresh the cache.
- Provider exposes `restartRealtime()` and `stopRealtime()` for lifecycle/recovery handling.

## Supabase
Run `supabase_phase11_6_notification_realtime.sql` after the Phase 11 notifications SQL.

## Test
```powershell
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```

Then verify:
1. Notifications load while online.
2. Turn network off and reopen Notifications; cached items remain available.
3. Mark one/all as read and delete an item.
4. Insert a notification for the signed-in user from a trusted server/SQL test and verify the badge/list updates without reopening the screen.
5. Sign out and sign in as another account; the previous account's cached notifications must not appear.
