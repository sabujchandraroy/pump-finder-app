import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;
  GetNotifications(this.repository);

  Future<List<AppNotification>> call() => repository.getNotifications();
}
