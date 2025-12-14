import 'cart_item.dart';

/// 배달 상태
enum DeliveryStatus {
  preparing,      // 제품 준비
  readyToShip,    // 배달 준비
  inTransit,      // 배달 중
  delivered,      // 도착
}

/// 주문 모델
class Order {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;
  DeliveryStatus status;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    this.status = DeliveryStatus.preparing,
  });

  /// 배달 상태를 한글로 변환
  String get statusText {
    switch (status) {
      case DeliveryStatus.preparing:
        return '제품 준비';
      case DeliveryStatus.readyToShip:
        return '배달 준비';
      case DeliveryStatus.inTransit:
        return '배달 중';
      case DeliveryStatus.delivered:
        return '도착';
    }
  }

  /// 배달 상태 아이콘
  String get statusIcon {
    switch (status) {
      case DeliveryStatus.preparing:
        return '📦';
      case DeliveryStatus.readyToShip:
        return '🚚';
      case DeliveryStatus.inTransit:
        return '🚛';
      case DeliveryStatus.delivered:
        return '✅';
    }
  }

  /// 배달 상태 진행률 (0.0 ~ 1.0)
  double get progress {
    switch (status) {
      case DeliveryStatus.preparing:
        return 0.25;
      case DeliveryStatus.readyToShip:
        return 0.5;
      case DeliveryStatus.inTransit:
        return 0.75;
      case DeliveryStatus.delivered:
        return 1.0;
    }
  }

  /// 총 상품 개수
  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
