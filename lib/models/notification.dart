/// 알림 타입 정의
enum NotificationType {
  cart,       // 장바구니 추가
  allergy,    // 알러지 설정
  warning,    // 경고
  info,       // 정보
}

/// 알림 모델
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  /// 알림을 읽음 상태로 변경
  AppNotification markAsRead() {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: true,
    );
  }

  /// 알림 타입에 따른 아이콘 가져오기
  String get icon {
    switch (type) {
      case NotificationType.cart:
        return '🛒';
      case NotificationType.allergy:
        return '⚕️';
      case NotificationType.warning:
        return '⚠️';
      case NotificationType.info:
        return 'ℹ️';
    }
  }
}
