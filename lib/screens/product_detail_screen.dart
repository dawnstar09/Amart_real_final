import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/allergen.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

/// 개별 제품의 상세 정보를 표시하는 화면
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final List<String> userAllergens;
  final NotificationService notificationService;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.userAllergens,
    required this.notificationService,
  });

  /// 제품이 포함하고 있는 알레르기 정보 가져오기
  List<Allergen> get _productAllergens {
    return Allergen.commonAllergens
        .where((allergen) => product.allergenIds.contains(allergen.id))
        .toList();
  }

  /// 사용자의 알레르기와 제품의 알레르기가 겹치는지 확인
  List<Allergen> get _dangerousAllergens {
    return _productAllergens
        .where((allergen) => userAllergens.contains(allergen.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isSafe = product.isSafeFor(userAllergens);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('제품 상세 정보'),
        backgroundColor: Colors.orange[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 제품 이미지 섹션
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.orange[50],
              child: Center(
                child: Text(
                  product.imageUrl,
                  style: const TextStyle(fontSize: 120),
                ),
              ),
            ),

            /// 안전 상태 배너
            if (userAllergens.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: isSafe ? Colors.green[100] : Colors.red[100],
                child: Row(
                  children: [
                    Icon(
                      isSafe ? Icons.check_circle : Icons.warning,
                      color: isSafe ? Colors.green[700] : Colors.red[700],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isSafe 
                            ? '✓ 안전합니다! 알레르기 성분이 없습니다.'
                            : '⚠ 주의! 알레르기 성분이 포함되어 있습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSafe ? Colors.green[900] : Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// 제품 기본 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 제품명
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  /// 카테고리
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  /// 가격
                  Text(
                    '${product.price.toStringAsFixed(0)}원',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  /// 구분선
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  
                  /// 제품 설명 제목
                  const Text(
                    '제품 설명',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  /// 제품 설명 내용
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  /// 구분선
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  
                  /// 알레르기 정보 제목
                  Row(
                    children: [
                      const Text(
                        '알레르기 정보',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.medical_information,
                        color: Colors.orange[700],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  /// 알레르기 성분 목록
                  if (_productAllergens.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '알레르기 유발 성분이 포함되어 있지 않습니다.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _productAllergens.map((allergen) {
                        final isDangerous = userAllergens.contains(allergen.id);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isDangerous 
                                ? Colors.red[50] 
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: isDangerous 
                                  ? Colors.red[200]! 
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              /// 알레르기 아이콘
                              Text(
                                allergen.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              
                              /// 알레르기 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allergen.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDangerous 
                                            ? Colors.red[900] 
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      allergen.nameEn,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              /// 경고 아이콘
                              if (isDangerous)
                                Icon(
                                  Icons.warning,
                                  color: Colors.red[700],
                                  size: 32,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      /// 하단 구매 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isSafe || userAllergens.isEmpty
              ? () {
                  // 장바구니 추가 알림
                  notificationService.addNotification(
                    title: '장바구니 추가',
                    message: '${product.name}을(를) 장바구니에 추가했습니다!',
                    type: NotificationType.cart,
                  );
                  
                  // 스낵바 메시지
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name}을(를) 장바구니에 추가했습니다!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: '알림 보기',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                    ),
                  );
                }
              : null, // 안전하지 않으면 버튼 비활성화
          style: ElevatedButton.styleFrom(
            backgroundColor: isSafe || userAllergens.isEmpty
                ? Colors.orange[700]
                : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            isSafe || userAllergens.isEmpty 
                ? '장바구니에 담기' 
                : '알레르기 성분 포함',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
