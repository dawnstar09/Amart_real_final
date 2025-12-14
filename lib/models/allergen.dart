/// 알레르기 유발 물질을 나타내는 모델 클래스
/// 
/// Flutter에서 모델 클래스는 데이터를 구조화하여 저장하고 전달하는 역할을 합니다.
class Allergen {
  final String id;        // 고유 식별자
  final String name;      // 알레르기 이름 (예: "우유", "땅콩")
  final String nameEn;    // 영문 이름
  final String icon;      // 아이콘 이모지

  /// 생성자: 객체를 만들 때 필요한 정보를 받습니다
  /// const를 사용하면 컴파일 시간에 상수로 처리되어 성능이 향상됩니다
  const Allergen({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
  });

  /// 주요 알레르기 유발 물질 목록
  /// static const를 사용하면 클래스 레벨에서 접근 가능한 상수가 됩니다
  static const List<Allergen> commonAllergens = [
    Allergen(id: 'milk', name: '우유', nameEn: 'Milk', icon: '🥛'),
    Allergen(id: 'egg', name: '계란', nameEn: 'Egg', icon: '🥚'),
    Allergen(id: 'peanut', name: '땅콩', nameEn: 'Peanut', icon: '🥜'),
    Allergen(id: 'soy', name: '대두', nameEn: 'Soy', icon: '🫘'),
    Allergen(id: 'wheat', name: '밀', nameEn: 'Wheat', icon: '🌾'),
    Allergen(id: 'shellfish', name: '갑각류', nameEn: 'Shellfish', icon: '🦐'),
    Allergen(id: 'fish', name: '어류', nameEn: 'Fish', icon: '🐟'),
    Allergen(id: 'tree_nuts', name: '견과류', nameEn: 'Tree Nuts', icon: '🌰'),
  ];
}
