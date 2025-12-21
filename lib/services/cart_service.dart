import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// 장바구니를 관리하는 서비스 클래스
class CartService extends ChangeNotifier {
  /// 장바구니 아이템 목록
  final List<CartItem> _items = [];
  
  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 현재 사용자 ID
  String? _userId;

  /// 모든 장바구니 아이템
  List<CartItem> get items => List.unmodifiable(_items);

  /// 장바구니 아이템 개수
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// 장바구니가 비어있는지
  bool get isEmpty => _items.isEmpty;

  /// 총 금액
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// 사용자 ID 설정 및 장바구니 로드
  Future<void> setUserId(String? userId) async {
    _userId = userId;
    if (userId != null) {
      await loadCart();
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  /// Firestore에서 장바구니 로드
  Future<void> loadCart() async {
    if (_userId == null) return;
    
    try {
      final doc = await _firestore.collection('carts').doc(_userId).get();
      
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          _items.clear();
          final itemsList = data['items'] as List;
          for (var itemData in itemsList) {
            final product = Product.fromMap(itemData['product']);
            _items.add(CartItem(
              product: product,
              quantity: itemData['quantity'] ?? 1,
            ));
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('장바구니 로드 오류: $e');
    }
  }

  /// Firestore에 장바구니 저장
  Future<void> _saveCart() async {
    if (_userId == null) return;
    
    try {
      final cartData = {
        'items': _items.map((item) => {
          'product': item.product.toMap(),
          'quantity': item.quantity,
        }).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('carts').doc(_userId).set(cartData);
    } catch (e) {
      debugPrint('장바구니 저장 오류: $e');
    }
  }

  /// 장바구니에 상품 추가
  void addProduct(Product product) async {
    // 이미 장바구니에 있는 상품인지 확인
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // 이미 있으면 수량만 증가
      _items[existingIndex].increaseQuantity();
    } else {
      // 없으면 새로 추가
      _items.add(CartItem(product: product));
    }
    
    notifyListeners();
    await _saveCart();
  }

  /// 장바구니에서 상품 제거
  void removeProduct(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await _saveCart();
  }

  /// 특정 상품의 수량 증가
  void increaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].increaseQuantity();
      notifyListeners();
      await _saveCart();
    }
  }

  /// 특정 상품의 수량 감소
  void decreaseQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].decreaseQuantity();
      } else {
        // 수량이 1이면 장바구니에서 제거
        _items.removeAt(index);
      }
      notifyListeners();
      await _saveCart();
    }
  }

  /// 장바구니 비우기
  void clear() async {
    _items.clear();
    notifyListeners();
    await _saveCart();
  }

  /// 특정 상품이 장바구니에 있는지 확인
  bool containsProduct(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// 특정 상품의 수량 가져오기
  int getProductQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: '',
        name: '',
        description: '',
        price: 0,
        category: '',
        imageUrl: '',
        allergenIds: [],
      )),
    );
    return item.product.id.isEmpty ? 0 : item.quantity;
  }
}
