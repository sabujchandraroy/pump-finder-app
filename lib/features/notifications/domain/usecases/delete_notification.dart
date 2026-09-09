import '../repositories/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository repository;
  DeleteNotification(this.repository);

  Future<void> call(String notificationId) => repository.deleteNotification(notificationId);
}
