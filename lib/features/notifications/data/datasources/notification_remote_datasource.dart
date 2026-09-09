import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Stream<List<NotificationModel>> watchNotifications();
  Future<void> stopWatchingNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabase;
  RealtimeChannel? _channel;
  StreamController<List<NotificationModel>>? _controller;

  NotificationRemoteDataSourceImpl(this.supabase);

  User _requireUser() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }
    return user;
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final user = _requireUser();
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => NotificationModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final user = _requireUser();
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', user.id);
  }

  @override
  Future<void> markAllAsRead() async {
    final user = _requireUser();
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final user = _requireUser();
    await supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId)
        .eq('user_id', user.id);
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final user = _requireUser();
    _channel?.unsubscribe();
    _controller?.close();
    _controller = StreamController<List<NotificationModel>>.broadcast();

    _channel = supabase
        .channel('notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (_) async {
            try {
              final notifications = await getNotifications();
              _controller?.add(notifications);
            } catch (error, stackTrace) {
              _controller?.addError(error, stackTrace);
            }
          },
        )
        .subscribe();

    return _controller!.stream;
  }

  @override
  Future<void> stopWatchingNotifications() async {
    await _channel?.unsubscribe();
    _channel = null;
    await _controller?.close();
    _controller = null;
  }

}
