# PumpFinder Final Project Roadmap

## Completed phases
1. Supabase + petrol pump database + Google Maps foundation.
2. Favorites with remote/local persistence.
3. Supabase email authentication and AuthGate.
4. Hive cache/offline fallback.
5. Search, filters, nearby mode and sorting.
6. Pump details, calling, directions and address actions.
7. Admin pump management and role-based access.
8. Profile and admin dashboard.
9. Reviews and ratings with aggregate rating refresh.
10. Reports and Safety Center with moderation workflow.
11.1-11.6 Notification domain, data, UI, automatic events, navigation, realtime/cache reliability.
12. Responsive UI/UX polish, theme settings and map control layout improvements.
13. Location/map reliability, nearby distance calculation and responsive map controls.
14. Fuel types and fuel prices in model, admin form and pump details.
15. Admin/moderation hardening, database indexes and server-side notification fan-out.
16. Production security/performance migration, RLS-oriented server triggers and safer client responsibilities.
17. Testing/release preparation, documentation and project cleanup.

## Important setup
Run the Supabase SQL migrations from the project in their phase order. The final migration is:
`supabase_final_production_migration.sql`

The Flutter project uses Provider for presentation state, UseCases in Domain, Repository contracts/implementations, and Remote/Local data sources. UI does not directly access Supabase or Hive.
