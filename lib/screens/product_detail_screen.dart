import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/allergen.dart';
import '../models/notification.dart';
import '../models/review.dart';
import '../services/notification_service.dart';
import '../services/cart_service.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';

/// 개별 제품의 상세 정보를 표시하는 화면
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<String> userAllergens;
  final NotificationService notificationService;
  final CartService cartService;
  final ReviewService reviewService;
  final AuthService authService;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.userAllergens,
    required this.notificationService,
    required this.cartService,
    required this.reviewService,
    required this.authService,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoadingReviews = true;
  Review? _userReview;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  /// 리뷰 데이터 불러오기
  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    
    final reviews = await widget.reviewService.getProductReviews(widget.product.id);
    final avgRating = await widget.reviewService.getAverageRating(widget.product.id);
    final count = await widget.reviewService.getReviewCount(widget.product.id);
    
    // 사용자의 리뷰가 있는지 확인
    final userId = widget.authService.userId;
    Review? userReview;
    if (userId != null) {
      userReview = await widget.reviewService.getUserReview(
        productId: widget.product.id,
        userId: userId,
      );
    }
    
    setState(() {
      _reviews = reviews;
      _averageRating = avgRating;
      _reviewCount = count;
      _userReview = userReview;
      _isLoadingReviews = false;
    });
  }

  /// 제품이 포함하고 있는 알레르기 정보 가져오기
  List<Allergen> get _productAllergens {
    return Allergen.commonAllergens
        .where((allergen) => widget.product.allergenIds.contains(allergen.id))
        .toList();
  }

  /// 사용자의 알레르기와 제품의 알레르기가 겹치는지 확인
  List<Allergen> get _dangerousAllergens {
    return _productAllergens
        .where((allergen) => widget.userAllergens.contains(allergen.id))
        .toList();
  }

  /// 리뷰 작성 다이얼로그 표시
  void _showReviewDialog({Review? existingReview}) {
    final isEdit = existingReview != null;
    double rating = existingReview?.rating ?? 5.0;
    final contentController = TextEditingController(text: existingReview?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? '리뷰 수정' : '리뷰 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('별점', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 36,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('리뷰 내용', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '제품에 대한 솔직한 리뷰를 작성해주세요',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = widget.authService.userId;
                final userEmail = widget.authService.currentUser?.email;
                
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인이 필요합니다')),
                  );
                  return;
                }

                if (contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰 내용을 입력해주세요')),
                  );
                  return;
                }

                Navigator.pop(context);

                bool success;
                if (isEdit) {
                  success = await widget.reviewService.updateReview(
                    reviewId: existingReview.id,
                    rating: rating,
                    content: contentController.text.trim(),
                  );
                } else {
                  success = await widget.reviewService.addReview(
                    productId: widget.product.id,
                    userId: userId,
                    userName: userEmail?.split('@')[0] ?? '익명',
                    rating: rating,
                    content: contentController.text.trim(),
                  );
                }

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? '리뷰가 수정되었습니다' : '리뷰가 작성되었습니다'),
                    ),
                  );
                  _loadReviews();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰 작성에 실패했습니다')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
              ),
              child: Text(isEdit ? '수정' : '작성'),
            ),
          ],
        ),
      ),
    );
  }

  /// 리뷰 삭제 확인 다이얼로그
  void _showDeleteDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리뷰 삭제'),
        content: const Text('이 리뷰를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await widget.reviewService.deleteReview(review.id);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리뷰가 삭제되었습니다')),
                );
                _loadReviews();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리뷰 삭제에 실패했습니다')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSafe = widget.product.isSafeFor(widget.userAllergens);
    
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
                  widget.product.imageUrl,
                  style: const TextStyle(fontSize: 120),
                ),
              ),
            ),

            /// 안전 상태 배너
            if (widget.userAllergens.isNotEmpty)
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
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  /// 카테고리와 평점
                  Row(
                    children: [
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
                          widget.product.category,
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!_isLoadingReviews && _reviewCount > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${_averageRating.toStringAsFixed(1)} ($_reviewCount)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  /// 가격
                  Text(
                    '${widget.product.price.toStringAsFixed(0)}원',
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
                    widget.product.description,
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
                        final isDangerous = widget.userAllergens.contains(allergen.id);
                        
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
            
            /// 리뷰 섹션
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 구분선
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  
                  /// 리뷰 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '리뷰',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!_isLoadingReviews)
                            Text(
                              '($_reviewCount)',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (widget.authService.currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인이 필요합니다')),
                            );
                            return;
                          }
                          
                          // 사용자가 이미 리뷰를 작성했으면 수정, 아니면 작성
                          if (_userReview != null) {
                            _showReviewDialog(existingReview: _userReview);
                          } else {
                            _showReviewDialog();
                          }
                        },
                        icon: Icon(_userReview != null ? Icons.edit : Icons.add),
                        label: Text(_userReview != null ? '내 리뷰 수정' : '리뷰 작성'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  /// 평균 별점 표시
                  if (!_isLoadingReviews && _reviewCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 36),
                          const SizedBox(width: 8),
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ 5.0',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  /// 리뷰 목록
                  if (_isLoadingReviews)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '아직 리뷰가 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '첫 리뷰를 작성해보세요!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._reviews.map((review) {
                      final isMyReview = review.userId == widget.authService.userId;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.orange[700],
                                    child: Text(
                                      review.userName[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              review.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (isMyReview) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange[100],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '내 리뷰',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.orange[900],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            ...List.generate(5, (index) {
                                              return Icon(
                                                index < review.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.orange,
                                                size: 16,
                                              );
                                            }),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}-${review.createdAt.day.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isMyReview)
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('수정'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 20, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('삭제', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showReviewDialog(existingReview: review);
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(review);
                                        }
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                review.content,
                                style: const TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
          onPressed: () async {
            // 알러지 경고 표시 (알러지가 있는 경우)
            if (!isSafe && widget.userAllergens.isNotEmpty) {
              final shouldAdd = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      const Text('알레르기 경고'),
                    ],
                  ),
                  content: Text(
                    '이 제품에는 알레르기 유발 성분이 포함되어 있습니다.\n\n'
                    '그래도 장바구니에 담으시겠습니까?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                      ),
                      child: const Text('담기'),
                    ),
                  ],
                ),
              );
              
              if (shouldAdd != true) return;
            }
            
            // 장바구니에 상품 추가
            widget.cartService.addProduct(widget.product);
            
            // 장바구니 추가 알림
            widget.notificationService.addNotification(
              title: '장바구니 추가',
              message: '${widget.product.name}을(를) 장바구니에 추가했습니다!',
              type: NotificationType.cart,
            );
            
            // 스낵바 메시지
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${widget.product.name}을(를) 장바구니에 추가했습니다!'),
                      ),
                    ],
                  ),
                  backgroundColor: isSafe ? Colors.green : Colors.orange[700],
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: '장바구니',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSafe || widget.userAllergens.isEmpty
                ? Colors.orange[700]
                : Colors.orange[400],
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isSafe && widget.userAllergens.isNotEmpty) ...[
                Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                isSafe || widget.userAllergens.isEmpty 
                    ? '장바구니에 담기' 
                    : '알레르기 경고 - 담기',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
