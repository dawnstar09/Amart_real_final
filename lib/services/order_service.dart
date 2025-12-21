import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// 주문을 관리하는 서비스 클래스
class OrderService extends ChangeNotifier {
  /// 주문 목록 (최신 주문이 맨 앞)
  final List<Order> _orders = [];
  
  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 현재 사용자 ID
  String? _userId;

  /// 모든 주문 목록
  List<Order> get orders => List.unmodifiable(_orders);

  /// 주문이 있는지
  bool get hasOrders => _orders.isNotEmpty;

  /// 가장 최근 주문
  Order? get latestOrder => _orders.isEmpty ? null : _orders.first;

  /// 사용자 ID 설정 및 주문 로드
  Future<void> setUserId(String? userId) async {
    _userId = userId;
    if (userId != null) {
      await loadOrders();
    } else {
      _orders.clear();
      notifyListeners();
    }
  }

  /// Firestore에서 주문 목록 로드
  Future<void> loadOrders() async {
    if (_userId == null) return;
    
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: _userId)
          .get();
      
      _orders.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = (data['items'] as List).map((itemData) {
          return CartItem(
            product: Product.fromMap(itemData['product']),
            quantity: itemData['quantity'] ?? 1,
          );
        }).toList();
        
        _orders.add(Order(
          id: doc.id,
          items: items,
          totalPrice: (data['totalPrice'] ?? 0).toDouble(),
          orderDate: (data['orderDate'] as Timestamp).toDate(),
          status: DeliveryStatus.values.firstWhere(
            (e) => e.toString() == 'DeliveryStatus.${data['status']}',
            orElse: () => DeliveryStatus.preparing,
          ),
        ));
      }
      
      // 클라이언트 측에서 날짜순 정렬 (최신 주문이 앞에)
      _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      
      notifyListeners();
    } catch (e) {
      debugPrint('주문 목록 로드 오류: $e');
    }
  }

  /// 새 주문 생성
  Future<Order> createOrder({
    required List<CartItem> items,
    required double totalPrice,
  }) async {
    if (_userId == null) {
      throw '로그인이 필요합니다';
    }

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

    // Firestore에 저장
    await _saveOrder(order);

    // 자동으로 배달 상태 진행 (데모용)
    _autoUpdateDeliveryStatus(order.id);

    return order;
  }

  /// Firestore에 주문 저장
  Future<void> _saveOrder(Order order) async {
    if (_userId == null) return;
    
    try {
      await _firestore.collection('orders').doc(order.id).set({
        'userId': _userId,
        'items': order.items.map((item) => {
          'product': item.product.toMap(),
          'quantity': item.quantity,
        }).toList(),
        'totalPrice': order.totalPrice,
        'orderDate': Timestamp.fromDate(order.orderDate),
        'status': order.status.toString().split('.').last,
      });
      debugPrint('✅ 주문 저장 성공: ${order.id}');
    } catch (e) {
      debugPrint('❌ 주문 저장 오류: $e');
    }
  }

  /// 주문 상태 업데이트
  Future<void> updateOrderStatus(String orderId, DeliveryStatus status) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      _orders[index].status = status;
      notifyListeners();
      
      // Firestore 업데이트
      if (_userId != null) {
        try {
          await _firestore.collection('orders').doc(orderId).update({
            'status': status.toString().split('.').last,
          });
        } catch (e) {
          debugPrint('주문 상태 업데이트 오류: $e');
        }
      }
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
