import '../repositories/notification_repository.dart';

class MarkNotificationRead {
  final NotificationRepository repository;
  MarkNotificationRead(this.repository);

  Future<void> call(String notificationId) => repository.markAsRead(notificationId);
}
