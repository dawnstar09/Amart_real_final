import 'package:cloud_firestore/cloud_firestore.dart';

/// 리뷰 모델
class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating; // 1.0 ~ 5.0
  final String content;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  /// Firestore 문서로부터 Review 객체 생성
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '익명',
      rating: (data['rating'] ?? 0).toDouble(),
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore에 저장하기 위한 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
