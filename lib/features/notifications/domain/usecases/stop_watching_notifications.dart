import '../repositories/notification_repository.dart';

class StopWatchingNotifications {
  final NotificationRepository repository;

  StopWatchingNotifications(this.repository);

  Future<void> call() {
    return repository.stopWatchingNotifications();
  }
}
