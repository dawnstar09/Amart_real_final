import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

/// 주문을 관리하는 서비스 클래스
class OrderService extends ChangeNotifier {
  /// 주문 목록 (최신 주문이 맨 앞)
  final List<Order> _orders = [];

  /// 모든 주문 목록
  List<Order> get orders => List.unmodifiable(_orders);

  /// 주문이 있는지
  bool get hasOrders => _orders.isNotEmpty;

  /// 가장 최근 주문
  Order? get latestOrder => _orders.isEmpty ? null : _orders.first;

  /// 새 주문 생성
  Order createOrder({
    required List<CartItem> items,
    required double totalPrice,
  }) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items.map((item) => CartItem(
        product: item.product,
        quantity: item.quantity,
      )).toList(),
      totalPrice: totalPrice,
      orderDate: DateTime.now(),
    );

    _orders.insert(0, order); // 최신 주문을 맨 앞에 추가
    notifyListeners();

    // 자동으로 배달 상태 진행 (데모용)
    _autoUpdateDeliveryStatus(order.id);

    return order;
  }

  /// 주문 상태 업데이트
  void updateOrderStatus(String orderId, DeliveryStatus status) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      _orders[index].status = status;
      notifyListeners();
    }
  }

  /// 자동으로 배달 상태 업데이트 (데모용)
  void _autoUpdateDeliveryStatus(String orderId) {
    // 10초마다 배달 상태 업데이트
    Future.delayed(const Duration(seconds: 10), () {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0 && _orders[index].status == DeliveryStatus.preparing) {
        _orders[index].status = DeliveryStatus.readyToShip;
        notifyListeners();

        Future.delayed(const Duration(seconds: 10), () {
          final idx = _orders.indexWhere((order) => order.id == orderId);
          if (idx >= 0 && _orders[idx].status == DeliveryStatus.readyToShip) {
            _orders[idx].status = DeliveryStatus.inTransit;
            notifyListeners();

            Future.delayed(const Duration(seconds: 10), () {
              final i = _orders.indexWhere((order) => order.id == orderId);
              if (i >= 0 && _orders[i].status == DeliveryStatus.inTransit) {
                _orders[i].status = DeliveryStatus.delivered;
                notifyListeners();
              }
            });
          }
        });
      }
    });
  }

  /// 특정 주문 가져오기
  Order? getOrder(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// 모든 주문 삭제
  void clearAll() {
    _orders.clear();
    notifyListeners();
  }
}
