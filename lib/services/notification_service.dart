import 'package:flutter/material.dart';
import '../models/notification.dart';

/// 알림을 관리하는 서비스 클래스
/// ChangeNotifier를 상속하여 상태 변경을 감지할 수 있습니다
class NotificationService extends ChangeNotifier {
  /// 알림 목록
  final List<AppNotification> _notifications = [];

  /// 읽지 않은 알림 개수
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 모든 알림 목록
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// 알림 추가
  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification); // 최신 알림을 맨 위에 추가
    notifyListeners(); // 리스너들에게 변경 알림
  }

  /// 알림을 읽음 상태로 변경
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].markAsRead();
      notifyListeners();
    }
  }

  /// 모든 알림을 읽음 상태로 변경
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].markAsRead();
    }
    notifyListeners();
  }

  /// 알림 삭제
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// 모든 알림 삭제
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
