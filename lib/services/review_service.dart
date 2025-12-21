import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

/// 리뷰 관리 서비스
class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 제품의 리뷰 목록 가져오기
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();
      
      // 클라이언트 측에서 정렬 (인덱스 불필요)
      final reviews = querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
      
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      print('리뷰 불러오기 오류: $e');
      return [];
    }
  }
  
  /// 제품의 평균 별점 계산
  Future<double> getAverageRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);
      if (reviews.isEmpty) return 0.0;
      
      final totalRating = reviews.fold<double>(
        0.0,
        (sum, review) => sum + review.rating,
      );
      
      return totalRating / reviews.length;
    } catch (e) {
      print('평균 별점 계산 오류: $e');
      return 0.0;
    }
  }
  
  /// 리뷰 작성
  Future<bool> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String content,
  }) async {
    try {
      final review = Review(
        id: '',
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        content: content,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('reviews').add(review.toMap());
      print('✅ 리뷰 작성 성공: ${review.toMap()}');
      return true;
    } catch (e) {
      print('❌ 리뷰 작성 오류: $e');
      return false;
    }
  }
  
  /// 리뷰 수정
  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String content,
  }) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'content': content,
      });
      return true;
    } catch (e) {
      print('리뷰 수정 오류: $e');
      return false;
    }
  }
  
  /// 리뷰 삭제
  Future<bool> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      return true;
    } catch (e) {
      print('리뷰 삭제 오류: $e');
      return false;
    }
  }
  
  /// 사용자가 해당 제품에 리뷰를 작성했는지 확인
  Future<Review?> getUserReview({
    required String productId,
    required String userId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) return null;
      
      return Review.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('사용자 리뷰 확인 오류: $e');
      return null;
    }
  }
  
  /// 리뷰 개수 가져오기
  Future<int> getReviewCount(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();
      
      return querySnapshot.docs.length;
    } catch (e) {
      print('리뷰 개수 확인 오류: $e');
      return 0;
    }
  }
}
