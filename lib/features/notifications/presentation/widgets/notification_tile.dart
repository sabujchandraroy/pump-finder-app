import 'package:flutter/material.dart';

import '../../domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'review':
        return Icons.star_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'report':
      case 'report_status':
        return Icons.flag_rounded;
      case 'pump':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),

      child: ListTile(
        onTap: onTap,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        tileColor: notification.isRead
            ? null
            : theme.colorScheme.primaryContainer.withOpacity(0.25),

        leading: CircleAvatar(
          child: Icon(
            _iconForType(notification.type),
          ),
        ),

        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (!notification.isRead)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${notification.message}\n${_timeAgo(notification.createdAt)}',
          ),
        ),

        // These belong to ListTile, NOT Padding.
        isThreeLine: true,

        trailing: IconButton(
          tooltip: 'Delete',
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline,
          ),
        ),
      ),
    );
  }
}