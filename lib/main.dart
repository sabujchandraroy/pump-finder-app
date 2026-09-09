import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/constants/app_constants.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/settings/app_settings_provider.dart';
import 'core/services/location_service.dart';
import 'features/petrol_pump/data/datasources/petrol_pump_local_datasource.dart';
import 'features/petrol_pump/data/models/petrol_pump_model.dart';
import 'features/petrol_pump/data/datasources/petrol_pump_remote_datasource.dart';
import 'features/petrol_pump/data/repositories/petrol_pump_repository_impl.dart';
import 'features/petrol_pump/domain/repositories/petrol_pump_repository.dart';
import 'features/petrol_pump/domain/usecases/add_favorite_pump.dart';
import 'features/petrol_pump/domain/usecases/get_favorite_pumps.dart';
import 'features/petrol_pump/domain/usecases/get_nearby_pumps.dart';
import 'features/petrol_pump/domain/usecases/remove_favorite_pump.dart';
import 'features/petrol_pump/domain/usecases/get_petrol_pumps.dart';
import 'features/petrol_pump/domain/usecases/filter_pumps.dart';
import 'features/petrol_pump/domain/usecases/search_pumps.dart';
import 'features/petrol_pump/presentation/providers/petrol_pump_provider.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/domain/usecases/is_current_user_admin.dart';
import 'features/admin/domain/usecases/get_admin_pumps.dart';
import 'features/admin/domain/usecases/create_pump.dart';
import 'features/admin/domain/usecases/update_pump.dart';
import 'features/admin/domain/usecases/delete_pump.dart';
import 'features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'features/admin/presentation/providers/admin_provider.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_my_profile.dart';
import 'features/profile/domain/usecases/update_my_profile.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/reviews/data/datasources/review_remote_datasource.dart';
import 'features/reviews/data/repositories/review_repository_impl.dart';
import 'features/reviews/domain/repositories/review_repository.dart';
import 'features/reviews/domain/usecases/add_pump_review.dart';
import 'features/reviews/domain/usecases/delete_pump_review.dart';
import 'features/reviews/domain/usecases/get_pump_reviews.dart';
import 'features/reviews/domain/usecases/update_pump_review.dart';
import 'features/reviews/presentation/providers/review_provider.dart';
import 'features/reports/data/datasources/report_remote_datasource.dart';
import 'features/reports/data/repositories/report_repository_impl.dart';
import 'features/reports/domain/repositories/report_repository.dart';
import 'features/reports/domain/usecases/create_report.dart';
import 'features/reports/domain/usecases/get_my_reports.dart';
import 'features/reports/domain/usecases/get_all_reports.dart';
import 'features/reports/domain/usecases/update_report_status.dart';
import 'features/reports/presentation/providers/report_provider.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/data/datasources/notification_local_datasource.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/delete_notification.dart';
import 'features/notifications/domain/usecases/get_notifications.dart';
import 'features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'features/notifications/domain/usecases/mark_notification_read.dart';
import 'features/notifications/domain/usecases/watch_notifications.dart';
import 'features/notifications/domain/usecases/stop_watching_notifications.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PetrolPumpModelAdapter());
  }
  await Hive.openBox<PetrolPumpModel>(PetrolPumpLocalDataSourceImpl.pumpsBoxName);
  await Hive.openBox<bool>(PetrolPumpLocalDataSourceImpl.favoritesBoxName);
  await Hive.openBox<Map>(NotificationLocalDataSourceImpl.boxName);
  await Hive.openBox<dynamic>(AppSettingsProvider.boxName);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabasePublishableKey,
  );

  final remoteDataSource = PetrolPumpRemoteDataSourceImpl(
    Supabase.instance.client,
  );
  final localDataSource = PetrolPumpLocalDataSourceImpl();

  final PetrolPumpRepository repository = PetrolPumpRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    Supabase.instance.client,
  );
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  final adminRemoteDataSource = AdminRemoteDataSourceImpl(Supabase.instance.client);
  final AdminRepository adminRepository = AdminRepositoryImpl(remoteDataSource: adminRemoteDataSource);

  final profileRemoteDataSource = ProfileRemoteDataSourceImpl(Supabase.instance.client);
  final ProfileRepository profileRepository = ProfileRepositoryImpl(remoteDataSource: profileRemoteDataSource);

  final reviewRemoteDataSource = ReviewRemoteDataSourceImpl(Supabase.instance.client);
  final ReviewRepository reviewRepository = ReviewRepositoryImpl(remoteDataSource: reviewRemoteDataSource);

  final notificationRemoteDataSource = NotificationRemoteDataSourceImpl(Supabase.instance.client);
  final notificationLocalDataSource = NotificationLocalDataSourceImpl(
    Hive.box<Map>(NotificationLocalDataSourceImpl.boxName),
  );
  final NotificationRepository notificationRepository = NotificationRepositoryImpl(
    remoteDataSource: notificationRemoteDataSource,
    localDataSource: notificationLocalDataSource,
    currentUserId: () => Supabase.instance.client.auth.currentUser?.id,
  );

  final reportRemoteDataSource = ReportRemoteDataSourceImpl(Supabase.instance.client);
  final ReportRepository reportRepository = ReportRepositoryImpl(remoteDataSource: reportRemoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        Provider<SignIn>(create: (_) => SignIn(authRepository)),
        Provider<SignUp>(create: (_) => SignUp(authRepository)),
        Provider<SignOut>(create: (_) => SignOut(authRepository)),
        Provider<GetCurrentUser>(create: (_) => GetCurrentUser(authRepository)),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            signIn: context.read<SignIn>(),
            signUp: context.read<SignUp>(),
            signOut: context.read<SignOut>(),
            getCurrentUser: context.read<GetCurrentUser>(),
            authStateChanges: authRepository.authStateChanges,
          ),
        ),
        Provider<GetPetrolPumps>(
          create: (_) => GetPetrolPumps(repository),
        ),
        Provider<GetNearbyPumps>(
          create: (_) => GetNearbyPumps(repository),
        ),
        Provider<SearchPumps>(create: (_) => SearchPumps(repository)),
        Provider<FilterPumps>(create: (_) => FilterPumps()),
        Provider<GetFavoritePumps>(create: (_) => GetFavoritePumps(repository)),
        Provider<AddFavoritePump>(create: (_) => AddFavoritePump(repository)),
        Provider<RemoveFavoritePump>(create: (_) => RemoveFavoritePump(repository)),
        ChangeNotifierProvider<AdminProvider>(create: (context) => AdminProvider(
          isCurrentUserAdmin: IsCurrentUserAdmin(adminRepository),
          getAdminPumps: GetAdminPumps(adminRepository),
          createPump: CreatePump(adminRepository),
          updatePump: UpdatePump(adminRepository),
          deletePump: DeletePump(adminRepository),
          getAdminDashboardStats: GetAdminDashboardStats(adminRepository),
        )),
        ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider(
          getMyProfile: GetMyProfile(profileRepository),
          updateMyProfile: UpdateMyProfile(profileRepository),
        )),
        ChangeNotifierProvider<ReportProvider>(create: (_) => ReportProvider(
          createReport: CreateReport(reportRepository),
          getMyReports: GetMyReports(reportRepository),
          getAllReports: GetAllReports(reportRepository),
          updateReportStatus: UpdateReportStatus(reportRepository),
        )),
        ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider(
          getPumpReviews: GetPumpReviews(reviewRepository),
          addPumpReview: AddPumpReview(reviewRepository),
          updatePumpReview: UpdatePumpReview(reviewRepository),
          deletePumpReview: DeletePumpReview(reviewRepository),
        )),
        ChangeNotifierProvider<AppSettingsProvider>(
          create: (_) => AppSettingsProvider(Hive.box<dynamic>(AppSettingsProvider.boxName)),
        ),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider(
          getNotifications: GetNotifications(notificationRepository),
          markNotificationRead: MarkNotificationRead(notificationRepository),
          markAllNotificationsRead: MarkAllNotificationsRead(notificationRepository),
          deleteNotification: DeleteNotification(notificationRepository),
          watchNotifications: WatchNotifications(notificationRepository),
          stopWatchingNotifications: StopWatchingNotifications(notificationRepository),
        )),
        ChangeNotifierProvider<PetrolPumpProvider>(
          create: (context) => PetrolPumpProvider(
            getPetrolPumps: context.read<GetPetrolPumps>(),
            getNearbyPumps: context.read<GetNearbyPumps>(),
            searchPumps: context.read<SearchPumps>(),
            getFavoritePumps: context.read<GetFavoritePumps>(),
            addFavoritePump: context.read<AddFavoritePump>(),
            removeFavoritePump: context.read<RemoveFavoritePump>(),
            filterPumps: context.read<FilterPumps>(),
            locationService: LocationService(),
          ),
        ),
      ],
      child: const PetrolPumpApp(),
    ),
  );
}

class PetrolPumpApp extends StatelessWidget {
  const PetrolPumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<AppSettingsProvider>().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const AuthGate(),
      routes: AppRoutes.routes,
    );
  }
}
