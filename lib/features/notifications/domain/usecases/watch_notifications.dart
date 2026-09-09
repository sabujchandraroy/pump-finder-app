import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class WatchNotifications {
  final NotificationRepository repository;

  WatchNotifications(this.repository);

  Stream<List<AppNotification>> call() {
    return repository.watchNotifications();
  }
}
