# 알레르기 안심 장보기 앱 🛒

알레르기가 있는 사람들을 위한 안전한 식료품 쇼핑 Flutter 앱입니다.

## 📱 주요 기능

### 1. 알레르기 프로필 관리
- 사용자의 알레르기 정보를 설정하고 관리
- 8가지 주요 알레르기 항목 지원:
  - 우유 🥛
  - 계란 🥚
  - 땅콩 🥜
  - 대두 🫘
  - 밀 🌾
  - 갑각류 🦐
  - 어류 🐟
  - 견과류 🌰

### 2. 제품 검색 및 필터링
- 제품 이름으로 검색 가능
- 카테고리별 필터링 (유제품, 과자, 과일 등)
- "안전한 제품만 보기" 필터로 알레르기 성분이 없는 제품만 표시
- 실시간 안전 상태 표시 (✓ 안전 / ⚠ 주의)

### 3. 제품 상세 정보
- 제품의 모든 알레르기 성분 표시
- 사용자의 알레르기와 매칭하여 위험 성분 강조
- 시각적 경고 시스템 (안전: 초록색, 위험: 빨간색)
- 장바구니 담기 기능 (안전한 제품만 담기 가능)

### 4. 사용자 프로필
- 현재 설정된 알레르기 개수 표시
- 앱 정보 및 사용 가이드
- 간편한 알레르기 프로필 설정 접근

## 🏗️ 프로젝트 구조

```
allergy_grocery_app/
├── lib/
│   ├── main.dart                           # 앱 진입점 및 홈 화면
│   ├── models/                             # 데이터 모델
│   │   ├── allergen.dart                   # 알레르기 모델 (8가지 주요 알레르기)
│   │   └── product.dart                    # 제품 모델 (샘플 제품 10개 포함)
│   └── screens/                            # 화면 위젯
│       ├── allergy_profile_screen.dart     # 알레르기 프로필 설정 화면
│       ├── product_list_screen.dart        # 제품 목록 화면
│       └── product_detail_screen.dart      # 제품 상세 화면
├── test/
│   └── widget_test.dart                    # 위젯 테스트
├── pubspec.yaml                             # 프로젝트 의존성 파일
└── README.md                                # 이 파일
```

## 🚀 시작하기

### 1. Flutter 설치 확인
```powershell
flutter --version
```

### 2. 의존성 설치
```powershell
cd c:\Users\dawns\Documents\Amart_vscode\allergy_grocery_app
flutter pub get
```

### 3. 앱 실행

#### Chrome (웹)에서 실행:
```powershell
flutter run -d chrome
```

#### Windows 데스크톱에서 실행:
```powershell
flutter run -d windows
```

#### Android 에뮬레이터에서 실행 (Android Studio 필요):
```powershell
flutter run
```

### 4. 핫 리로드
앱이 실행 중일 때:
- `r` - 핫 리로드 (코드 변경사항 즉시 반영)
- `R` - 핫 리스타트 (앱 전체 재시작)
- `q` - 앱 종료

## 📚 Flutter 핵심 개념 설명

### 위젯 (Widget)
Flutter의 모든 것은 위젯입니다. 버튼, 텍스트, 레이아웃 등 모든 UI 요소가 위젯입니다.

**두 가지 주요 위젯 타입:**
1. **StatelessWidget**: 상태가 변하지 않는 위젯 (예: 고정된 텍스트, 아이콘)
2. **StatefulWidget**: 상태가 변할 수 있는 위젯 (예: 체크박스, 카운터)

### setState()
`setState()`를 호출하면 Flutter가 화면을 다시 그립니다. 이는 사용자 인터랙션에 반응하여 UI를 업데이트하는 방법입니다.

```dart
setState(() {
  // 상태 변경
  _counter++;
});
```

### Navigator
화면 간 이동을 관리합니다.

```dart
// 새 화면으로 이동
Navigator.push(context, MaterialPageRoute(
  builder: (context) => NewScreen(),
));

// 이전 화면으로 돌아가기
Navigator.pop(context);
```

### Scaffold
앱의 기본 레이아웃 구조를 제공합니다 (AppBar, Body, BottomNavigationBar 등).

## 🎨 주요 위젯 설명

### MaterialApp
앱의 최상위 위젯으로, Material Design을 따르는 앱을 만듭니다.

### ListView.builder
리스트를 효율적으로 표시합니다. 화면에 보이는 항목만 렌더링합니다.

### Card
그림자 효과가 있는 카드형 컨테이너입니다.

### TextField
사용자 입력을 받는 텍스트 필드입니다.

### BottomNavigationBar
하단 탭 네비게이션을 제공합니다.

## 💡 코드 학습 가이드

### 1. 먼저 `lib/models/` 확인
- `allergen.dart`: 알레르기 데이터 구조 이해
- `product.dart`: 제품 데이터와 안전성 검사 로직 이해

### 2. `lib/main.dart` 분석
- 앱의 전체 구조와 네비게이션 이해
- `setState()`를 사용한 상태 관리 학습

### 3. `lib/screens/` 화면들 학습
- `allergy_profile_screen.dart`: 체크박스와 리스트 사용법
- `product_list_screen.dart`: 검색, 필터링, ListView 사용법
- `product_detail_screen.dart`: 상세 정보 표시와 조건부 UI

## 🔧 커스터마이징

### 새로운 알레르기 항목 추가
`lib/models/allergen.dart`의 `commonAllergens` 리스트에 추가:

```dart
Allergen(id: 'sesame', name: '참깨', nameEn: 'Sesame', icon: '🌱'),
```

### 새로운 제품 추가
`lib/models/product.dart`의 `sampleProducts` 리스트에 추가:

```dart
Product(
  id: '11',
  name: '새로운 제품',
  category: '카테고리',
  description: '제품 설명',
  price: 5000,
  allergenIds: ['milk', 'wheat'],
  imageUrl: '🍞',
),
```

### 테마 색상 변경
`lib/main.dart`의 `theme`에서 `seedColor` 변경:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue,  // 원하는 색상으로 변경
),
```

## 📖 추가 학습 자료

### Flutter 공식 문서
- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Flutter API 문서](https://api.flutter.dev/)
- [Flutter YouTube 채널](https://www.youtube.com/c/flutterdev)

### 추천 학습 순서
1. **위젯 기초**: StatelessWidget vs StatefulWidget
2. **레이아웃**: Row, Column, Container, Stack
3. **사용자 입력**: TextField, Button, Checkbox
4. **내비게이션**: Navigator, Routes
5. **상태 관리**: setState, Provider, Riverpod

## 🐛 문제 해결

### 앱이 실행되지 않는 경우
```powershell
# 의존성 다시 설치
flutter pub get

# 캐시 정리
flutter clean
flutter pub get

# Flutter 업그레이드
flutter upgrade
```

### 빌드 오류 발생 시
- VS Code에서 `Ctrl + Shift + P` → "Dart: Restart Analysis Server" 실행
- 터미널에서 앱을 종료하고 다시 실행

## 🎯 향후 개선 사항

- [ ] 제품 데이터베이스 연동 (Firebase 등)
- [ ] 제품 바코드 스캔 기능
- [ ] 사용자 리뷰 및 평점 시스템
- [ ] 알레르기 대체 제품 추천
- [ ] 장바구니 및 주문 기능
- [ ] 다국어 지원
- [ ] 제품 즐겨찾기 기능

## 👩‍💻 개발자

이민주 (Lee Min-ju)

## 📄 라이선스

이 프로젝트는 학습 목적으로 만들어졌습니다.

---

**Flutter를 처음 사용하시는 분께:**

이 앱은 Flutter의 기본 개념들을 모두 포함하고 있습니다. 각 파일의 주석을 꼼꼼히 읽어보시면 Flutter 개발의 핵심을 이해하실 수 있습니다. 코드를 수정해보고, 에러를 해결해보면서 학습하시는 것을 추천드립니다!

궁금한 점이 있으시면 언제든 질문해주세요. 즐거운 Flutter 학습 되세요! 🚀
