import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

/// 알림 목록을 표시하는 화면
class NotificationScreen extends StatelessWidget {
  final NotificationService notificationService;

  const NotificationScreen({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notificationService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('알림'),
            actions: [
              if (notificationService.notifications.isNotEmpty)
                TextButton(
                  onPressed: () {
                    notificationService.markAllAsRead();
                  },
                  child: const Text(
                    '모두 읽음',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (notificationService.notifications.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('알림 삭제'),
                        content: const Text('모든 알림을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              notificationService.clearAll();
                              Navigator.pop(context);
                            },
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          body: notificationService.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '알림이 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notificationService.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationService.notifications[index];
                    return _NotificationItem(
                      notification: notification,
                      onTap: () {
                        notificationService.markAsRead(notification.id);
                      },
                      onDismissed: () {
                        notificationService.removeNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('알림이 삭제되었습니다'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

/// 개별 알림 아이템 위젯
class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  Color _getColorByType(NotificationType type) {
    switch (type) {
      case NotificationType.cart:
        return Colors.blue;
      case NotificationType.allergy:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead ? Colors.grey[100] : Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorByType(notification.type).withOpacity(0.2),
            child: Text(
              notification.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
              if (notification.isRead)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '읽음',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(
                  color: notification.isRead ? Colors.grey[600] : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(notification.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          onTap: onTap,
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.month}월 ${timestamp.day}일';
    }
  }
}
