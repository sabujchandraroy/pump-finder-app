import 'package:hive/hive.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getNotifications(String userId);

  Future<void> saveNotifications(
    String userId,
    List<NotificationModel> notifications,
  );

  Future<void> clearUser(String userId);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const boxName = 'notifications_cache';

  final Box<Map> box;

  NotificationLocalDataSourceImpl(this.box);

  String _key(String userId, String notificationId) {
    return '$userId:$notificationId';
  }

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final prefix = '$userId:';

    final notifications = box
        .toMap()
        .entries
        .where(
          (entry) => entry.key.toString().startsWith(prefix))
        .map(
          (entry) =>
              NotificationModel.fromMap(Map<String, dynamic>.from(entry.value)),
        )
        .toList();

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }

  @override
  Future<void> saveNotifications(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    await clearUser(userId);

    for (final notification in notifications) {
      await box.put(_key(userId, notification.id), {
        'id': notification.id,
        'user_id': notification.userId,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type,
        'related_id': notification.relatedId,
        'is_read': notification.isRead,
        'created_at': notification.createdAt.toIso8601String(),
      });
    }
  }

  @override
  Future<void> clearUser(String userId) async {
    final keys = box.keys
        .where((key) => key.toString().startsWith('$userId:'))
        .toList();

    await box.deleteAll(keys);
  }
}
