/// 식료품 제품을 나타내는 모델 클래스
class Product {
  final String id;                    // 제품 고유 식별자
  final String name;                  // 제품 이름
  final String category;              // 카테고리 (예: "유제품", "과자")
  final String description;           // 제품 설명
  final double price;                 // 가격
  final List<String> allergenIds;     // 포함된 알레르기 물질 ID 목록
  final String imageUrl;              // 제품 이미지 URL (이모지로 대체)

  /// 생성자
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.allergenIds,
    required this.imageUrl,
  });

  /// 사용자의 알레르기와 제품의 알레르기 성분을 비교하여 안전한지 확인
  /// 
  /// [userAllergens]: 사용자가 가진 알레르기 ID 목록
  /// 반환값: 제품이 안전하면 true, 알레르기 성분이 포함되어 있으면 false
  bool isSafeFor(List<String> userAllergens) {
    // allergenIds에 userAllergens의 요소가 하나라도 있으면 false 반환
    for (String allergen in userAllergens) {
      if (allergenIds.contains(allergen)) {
        return false;
      }
    }
    return true;
  }

  /// 샘플 제품 데이터
  /// 실제 앱에서는 데이터베이스나 API에서 가져오지만, 
  /// 학습 목적으로 하드코딩된 샘플 데이터를 사용합니다
  static const List<Product> sampleProducts = [
    Product(
      id: '1',
      name: '신선한 우유',
      category: '유제품',
      description: '100% 순수 우유로 만든 신선한 제품입니다.',
      price: 3500,
      allergenIds: ['milk'],
      imageUrl: '🥛',
    ),
    Product(
      id: '2',
      name: '통밀 식빵',
      category: '베이커리',
      description: '건강한 통밀로 만든 고소한 식빵입니다.',
      price: 4500,
      allergenIds: ['wheat', 'egg', 'milk'],
      imageUrl: '🍞',
    ),
    Product(
      id: '3',
      name: '아몬드 초콜릿',
      category: '과자',
      description: '고급 아몬드와 초콜릿의 완벽한 조화.',
      price: 5500,
      allergenIds: ['tree_nuts', 'milk'],
      imageUrl: '🍫',
    ),
    Product(
      id: '4',
      name: '신선한 사과',
      category: '과일',
      description: '달콤하고 아삭한 국산 사과입니다.',
      price: 8000,
      allergenIds: [],
      imageUrl: '🍎',
    ),
    Product(
      id: '5',
      name: '땅콩버터',
      category: '스프레드',
      description: '고소한 땅콩으로 만든 크리미한 버터.',
      price: 6500,
      allergenIds: ['peanut'],
      imageUrl: '🥜',
    ),
    Product(
      id: '6',
      name: '연어 초밥',
      category: '즉석식품',
      description: '신선한 연어로 만든 프리미엄 초밥.',
      price: 12000,
      allergenIds: ['fish', 'soy'],
      imageUrl: '🍣',
    ),
    Product(
      id: '7',
      name: '바나나',
      category: '과일',
      description: '달콤하고 영양가 높은 필리핀산 바나나.',
      price: 3000,
      allergenIds: [],
      imageUrl: '🍌',
    ),
    Product(
      id: '8',
      name: '새우튀김',
      category: '냉동식품',
      description: '바삭한 튀김옷이 일품인 새우튀김.',
      price: 9500,
      allergenIds: ['shellfish', 'wheat'],
      imageUrl: '🍤',
    ),
    Product(
      id: '9',
      name: '두부',
      category: '반찬',
      description: '부드럽고 고소한 국산 콩 두부.',
      price: 2500,
      allergenIds: ['soy'],
      imageUrl: '🥢',
    ),
    Product(
      id: '10',
      name: '당근',
      category: '채소',
      description: '신선하고 아삭한 유기농 당근.',
      price: 3500,
      allergenIds: [],
      imageUrl: '🥕',
    ),
  ];
}
