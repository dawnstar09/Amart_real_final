import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/allergen.dart';

/// Firestore를 사용하여 사용자 데이터를 관리하는 서비스 클래스
/// 각 사용자별 알러지 정보를 저장하고 불러옵니다.
class UserService {
  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자 컬렉션 이름
  final String _usersCollection = 'users';

  /// 사용자의 알러지 정보를 Firestore에 저장
  /// 
  /// [userId]: 사용자 고유 ID (Firebase Auth UID)
  /// [allergenIds]: 사용자가 선택한 알러지 ID 리스트
  Future<void> saveUserAllergens({
    required String userId,
    required List<String> allergenIds,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).set(
        {
          'allergens': allergenIds,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // 기존 데이터와 병합
      );
    } catch (e) {
      throw '알러지 정보 저장 중 오류가 발생했습니다: $e';
    }
  }

  /// Firestore에서 사용자의 알러지 정보를 불러옴
  /// 
  /// [userId]: 사용자 고유 ID (Firebase Auth UID)
  /// 
  /// 반환: 저장된 알러지 ID 리스트 (저장된 정보가 없으면 빈 리스트)
  Future<List<String>> getUserAllergens({required String userId}) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['allergens'] != null) {
          // Firestore에서 가져온 데이터를 List<String>으로 변환
          return List<String>.from(data['allergens']);
        }
      }
      return [];
    } catch (e) {
      throw '알러지 정보를 불러오는 중 오류가 발생했습니다: $e';
    }
  }

  /// 사용자의 알러지 정보를 실시간으로 감지하는 스트림
  /// 
  /// [userId]: 사용자 고유 ID (Firebase Auth UID)
  /// 
  /// 반환: 알러지 ID 리스트를 방출하는 스트림
  Stream<List<String>> getUserAllergensStream({required String userId}) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['allergens'] != null) {
          return List<String>.from(data['allergens']);
        }
      }
      return <String>[];
    });
  }

  /// 사용자 프로필 전체를 저장
  /// 
  /// [userId]: 사용자 고유 ID
  /// [userData]: 저장할 사용자 데이터 맵
  Future<void> saveUserProfile({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).set(
        {
          ...userData,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw '사용자 프로필 저장 중 오류가 발생했습니다: $e';
    }
  }

  /// 사용자 프로필 전체를 불러옴
  /// 
  /// [userId]: 사용자 고유 ID
  /// 
  /// 반환: 사용자 데이터 맵 (없으면 null)
  Future<Map<String, dynamic>?> getUserProfile({
    required String userId,
  }) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw '사용자 프로필을 불러오는 중 오류가 발생했습니다: $e';
    }
  }

  /// 사용자가 선택한 알러지 정보를 Allergen 객체 리스트로 변환
  /// 
  /// [allergenIds]: 알러지 ID 리스트
  /// 
  /// 반환: Allergen 객체 리스트
  List<Allergen> getAllergenObjects(List<String> allergenIds) {
    return Allergen.commonAllergens
        .where((allergen) => allergenIds.contains(allergen.id))
        .toList();
  }

  /// 사용자 데이터 삭제 (회원 탈퇴 시 사용)
  /// 
  /// [userId]: 사용자 고유 ID
  Future<void> deleteUserData({required String userId}) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw '사용자 데이터 삭제 중 오류가 발생했습니다: $e';
    }
  }
}
