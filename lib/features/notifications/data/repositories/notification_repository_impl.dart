import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;
  final String? Function() currentUserId;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.currentUserId,
  });

  @override
  Future<List<AppNotification>> getNotifications() async {
    final userId = currentUserId();
    if (userId == null) return const [];
    try {
      final remote = await remoteDataSource.getNotifications();
      await localDataSource.saveNotifications(userId, remote);
      return remote;
    } catch (_) {
      return localDataSource.getNotifications(userId);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
    final userId = currentUserId();
    if (userId == null) return;
    final items = await localDataSource.getNotifications(userId);
    await localDataSource.saveNotifications(userId, items.map((item) {
      if (item.id != notificationId) return item;
      return _copy(item, isRead: true);
    }).toList());
  }

  @override
  Future<void> markAllAsRead() async {
    await remoteDataSource.markAllAsRead();
    final userId = currentUserId();
    if (userId == null) return;
    final items = await localDataSource.getNotifications(userId);
    await localDataSource.saveNotifications(
      userId,
      items.map((item) => _copy(item, isRead: true)).toList(),
    );
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await remoteDataSource.deleteNotification(notificationId);
    final userId = currentUserId();
    if (userId == null) return;
    final items = await localDataSource.getNotifications(userId);
    await localDataSource.saveNotifications(
      userId,
      items.where((item) => item.id != notificationId).toList(),
    );
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return remoteDataSource.watchNotifications().asyncMap((items) async {
      final userId = currentUserId();
      if (userId != null) await localDataSource.saveNotifications(userId, items);
      return items;
    });
  }

  @override
  Future<void> stopWatchingNotifications() {
    return remoteDataSource.stopWatchingNotifications();
  }

  NotificationModel _copy(AppNotification item, {required bool isRead}) {
    return NotificationModel(
      id: item.id,
      userId: item.userId,
      title: item.title,
      message: item.message,
      type: item.type,
      relatedId: item.relatedId,
      isRead: isRead,
      createdAt: item.createdAt,
    );
  }
}
