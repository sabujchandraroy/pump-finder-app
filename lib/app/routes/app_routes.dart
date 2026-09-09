import 'package:flutter/material.dart';

import '../../features/petrol_pump/domain/entities/petrol_pump.dart';
import '../../features/petrol_pump/presentation/screens/favorites_screen.dart';
import '../../features/petrol_pump/presentation/screens/pump_details_screen.dart';
import '../../features/admin/presentation/screens/admin_pumps_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/safety/presentation/screens/safety_center_screen.dart';
import '../../features/reports/presentation/screens/report_form_screen.dart';
import '../../features/reports/presentation/screens/my_reports_screen.dart';
import '../../features/reports/presentation/screens/admin_reports_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'route_names.dart';

class AppRoutes {
  static const pumpDetails = RouteNames.pumpDetails;
  static const favorites = RouteNames.favorites;
  static const adminPumps = RouteNames.adminPumps;
  static const adminDashboard = RouteNames.adminDashboard;
  static const profile = RouteNames.profile;
  static const reviews = RouteNames.reviews;
  static const safetyCenter = RouteNames.safetyCenter;
  static const report = RouteNames.report;
  static const myReports = RouteNames.myReports;
  static const adminReports = RouteNames.adminReports;
  static const notifications = RouteNames.notifications;
  static const settings = RouteNames.settings;

  static Map<String, WidgetBuilder> get routes => {
        pumpDetails: (context) {
          final pump = ModalRoute.of(context)?.settings.arguments as PetrolPump?;
          if (pump == null) {
            return const Scaffold(
              body: Center(child: Text('Pump data was not provided.')),
            );
          }
          return PumpDetailsScreen(pump: pump);
        },
        favorites: (_) => const FavoritesScreen(),
        adminPumps: (_) => const AdminPumpsScreen(),
        adminDashboard: (_) => const AdminDashboardScreen(),
        profile: (_) => const ProfileScreen(),
        reviews: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final pumpId = args?['pumpId'] as String?;
          final pumpName = args?['pumpName'] as String?;
          if (pumpId == null || pumpName == null) {
            return const Scaffold(body: Center(child: Text('Pump data was not provided.')));
          }
          return ReviewsScreen(pumpId: pumpId, pumpName: pumpName);
        },
        safetyCenter: (_) => const SafetyCenterScreen(),
        myReports: (_) => const MyReportsScreen(),
        adminReports: (_) => const AdminReportsScreen(),
        notifications: (_) => const NotificationsScreen(),
        settings: (_) => const SettingsScreen(),
        report: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ReportFormScreen(
            pumpId: args?['pumpId'] as String?,
            pumpName: args?['pumpName'] as String?,
            reviewId: args?['reviewId'] as String?,
          );
        },
      };
}
