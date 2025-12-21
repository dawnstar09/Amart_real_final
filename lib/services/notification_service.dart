import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

/// 알림을 관리하는 서비스 클래스
/// ChangeNotifier를 상속하여 상태 변경을 감지할 수 있습니다
class NotificationService extends ChangeNotifier {
  /// 알림 목록
  final List<AppNotification> _notifications = [];
  
  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 현재 사용자 ID
  String? _userId;

  /// 읽지 않은 알림 개수
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 모든 알림 목록
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  
  /// 사용자 ID 설정 및 알림 로드
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await loadNotifications();
  }
  
  /// Firestore에서 알림 로드
  Future<void> loadNotifications() async {
    if (_userId == null) return;
    
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _userId)
          .get();
      
      _notifications.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _notifications.add(AppNotification(
          id: doc.id,
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          type: NotificationType.values.firstWhere(
            (e) => e.toString() == 'NotificationType.${data['type']}',
            orElse: () => NotificationType.info,
          ),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: data['isRead'] ?? false,
        ));
      }
      
      // 최신 알림이 위로 오도록 정렬
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 알림 로드 오류: $e');
    }
  }

  /// 알림 추가
  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification); // 최신 알림을 맨 위에 추가
    notifyListeners(); // 리스너들에게 변경 알림
    
    // Firestore에 저장
    if (_userId != null) {
      try {
        await _firestore.collection('notifications').doc(notification.id).set({
          'userId': _userId,
          'title': title,
          'message': message,
          'type': type.toString().split('.').last,
          'timestamp': Timestamp.fromDate(notification.timestamp),
          'isRead': false,
        });
        debugPrint('✅ 알림 저장 성공: $title');
      } catch (e) {
        debugPrint('❌ 알림 저장 오류: $e');
      }
    }
  }

  /// 알림을 읽음 상태로 변경
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].markAsRead();
      notifyListeners();
      
      // Firestore 업데이트
      if (_userId != null) {
        try {
          await _firestore.collection('notifications').doc(id).update({
            'isRead': true,
          });
        } catch (e) {
          debugPrint('❌ 알림 읽음 처리 오류: $e');
        }
      }
    }
  }

  /// 모든 알림을 읽음 상태로 변경
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].markAsRead();
    }
    notifyListeners();
    
    // Firestore 일괄 업데이트
    if (_userId != null) {
      try {
        final batch = _firestore.batch();
        for (var notification in _notifications) {
          batch.update(
            _firestore.collection('notifications').doc(notification.id),
            {'isRead': true},
          );
        }
        await batch.commit();
        debugPrint('✅ 모든 알림 읽음 처리 성공');
      } catch (e) {
        debugPrint('❌ 알림 일괄 읽음 처리 오류: $e');
      }
    }
  }

  /// 알림 삭제
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    
    // Firestore에서 삭제
    if (_userId != null) {
      try {
        await _firestore.collection('notifications').doc(id).delete();
        debugPrint('✅ 알림 삭제 성공');
      } catch (e) {
        debugPrint('❌ 알림 삭제 오류: $e');
      }
    }
  }

  /// 모든 알림 삭제
  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
    
    // Firestore에서 삭제
    if (_userId != null) {
      try {
        final snapshot = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: _userId)
            .get();
        
        final batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        debugPrint('✅ 모든 알림 삭제 성공');
      } catch (e) {
        debugPrint('❌ 알림 일괄 삭제 오류: $e');
      }
    }
  }
}
