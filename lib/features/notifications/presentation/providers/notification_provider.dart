import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/delete_notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_all_notifications_read.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../../domain/usecases/watch_notifications.dart';
import '../../domain/usecases/stop_watching_notifications.dart';

class NotificationProvider extends ChangeNotifier {
  final GetNotifications getNotifications;
  final MarkNotificationRead markNotificationRead;
  final MarkAllNotificationsRead markAllNotificationsRead;
  final DeleteNotification deleteNotification;
  final WatchNotifications watchNotifications;
  final StopWatchingNotifications stopWatchingNotifications;

  NotificationProvider({
    required this.getNotifications,
    required this.markNotificationRead,
    required this.markAllNotificationsRead,
    required this.deleteNotification,
    required this.watchNotifications,
    required this.stopWatchingNotifications,
  });

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  StreamSubscription<List<AppNotification>>? _subscription;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  int get unreadCount => _notifications.where((item) => !item.isRead).length;
  bool get hasUnread => unreadCount > 0;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await getNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startRealtime() {
    if (_subscription != null) return;
    _error = null;
    try {
      _subscription = watchNotifications().listen(
        (items) {
          _notifications = items;
          _error = null;
          notifyListeners();
        },
        onError: (Object error) {
          _error = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> restartRealtime() async {
    await stopRealtime();
    startRealtime();
  }

  Future<void> stopRealtime() async {
    await _subscription?.cancel();
    _subscription = null;
    await stopWatchingNotifications();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    final previous = _notifications[index];
    _notifications[index] = _copyWithRead(previous, true);
    notifyListeners();
    try {
      await markNotificationRead(id);
    } catch (e) {
      _notifications[index] = previous;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (!hasUnread) return;
    _isUpdating = true;
    _error = null;
    final previous = List<AppNotification>.from(_notifications);
    _notifications = _notifications.map((item) => _copyWithRead(item, true)).toList();
    notifyListeners();
    try {
      await markAllNotificationsRead();
    } catch (e) {
      _notifications = previous;
      _error = e.toString();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final removed = _notifications[index];
    _notifications.removeAt(index);
    notifyListeners();
    try {
      await deleteNotification(id);
    } catch (e) {
      _notifications.insert(index, removed);
      _error = e.toString();
      notifyListeners();
    }
  }

  AppNotification _copyWithRead(AppNotification item, bool isRead) {
    return AppNotification(
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

  @override
  void dispose() {
    _subscription?.cancel();
    stopWatchingNotifications();
    super.dispose();
  }
}
