# Phases 12-17 finalization

- Phase 12: responsive UI, adaptive map controls, dark mode and settings.
- Phase 13: location permission handling remains in LocationService; nearby distance filtering is performed in the repository rather than the UI.
- Phase 14: fuel types and JSON fuel prices are supported in the domain/model, admin management form and pump details.
- Phase 15: admin/moderation database indexes and server-side notification fan-out are included.
- Phase 16: production migration moves automatic notification creation into security-definer PostgreSQL functions and keeps arbitrary notification insertion out of the Flutter client.
- Phase 17: release checklist, documentation, unit-test starters and analyzer-oriented cleanup are included.

Before publishing, replace any development Supabase/Maps configuration with environment/build-time secrets appropriate to the deployment and run `flutter analyze`, `flutter test`, `flutter build web`, and/or `flutter build appbundle` on a machine with Flutter installed.
