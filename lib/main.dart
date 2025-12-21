import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/product_list_screen.dart';
import 'screens/allergy_profile_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/delivery_status_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/review_service.dart';
import 'models/notification.dart';

/// 앱의 시작점
/// main() 함수는 Flutter 앱이 실행될 때 가장 먼저 호출됩니다
void main() async {
  // Flutter 바인딩 초기화 (Firebase 사용을 위해 필요)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AllergyGroceryApp());
}

/// 앱의 최상위 위젯
/// MaterialApp을 반환하여 앱의 전체 테마와 네비게이션을 설정합니다
class AllergyGroceryApp extends StatelessWidget {
  const AllergyGroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 앱 제목
      title: '알레르기 안심 장보기',
      
      /// 디버그 배너 숨기기
      debugShowCheckedModeBanner: false,
      
      /// 앱 전체 테마 설정
      theme: ThemeData(
        /// 주요 색상 (오렌지)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        
        /// 앱바 테마
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange[700],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        
        /// 카드 테마
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        /// 기본 폰트 설정
        useMaterial3: true,
      ),
      
      /// 앱의 첫 화면 - 인증 상태에 따라 로그인/홈 화면 표시
      home: const AuthWrapper(),
    );
  }
}

/// 인증 상태를 확인하여 적절한 화면을 표시하는 위젯
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    // Firebase Authentication 상태를 실시간으로 감지
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 로그인되어 있으면 홈 화면, 아니면 로그인 화면
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// 홈 화면 - 하단 네비게이션을 포함한 메인 화면
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 현재 선택된 탭 인덱스
  /// 0: 제품 목록, 1: 장바구니, 2: 프로필
  int _selectedIndex = 0;
  
  /// 사용자가 선택한 알레르기 목록
  /// 이 리스트는 앱 전체에서 사용됩니다
  List<String> _userAllergens = [];
  
  /// 데이터 로딩 상태
  bool _isLoading = true;

  /// 알림 서비스 인스턴스
  final NotificationService _notificationService = NotificationService();
  
  /// 장바구니 서비스 인스턴스
  final CartService _cartService = CartService();
  
  /// 주문 서비스 인스턴스
  final OrderService _orderService = OrderService();
  
  /// 리뷰 서비스 인스턴스
  final ReviewService _reviewService = ReviewService();
  
  /// 인증 서비스 인스턴스
  final AuthService _authService = AuthService();
  
  /// 사용자 서비스 인스턴스
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Firestore에서 사용자 데이터를 불러옴
  Future<void> _loadUserData() async {
    final userId = _authService.userId;
    if (userId != null) {
      try {
        // 장바구니, 주문, 알림 서비스에 userId 설정
        await _cartService.setUserId(userId);
        await _orderService.setUserId(userId);
        await _notificationService.setUserId(userId);
        
        // 알러지 정보 로드
        final allergens = await _userService.getUserAllergens(userId: userId);
        setState(() {
          _userAllergens = allergens;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('데이터를 불러오지 못했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 알레르기 설정이 변경될 때 호출되는 함수
  Future<void> _onAllergensChanged(List<String> allergens) async {
    final oldCount = _userAllergens.length;
    
    // Firebase에 저장
    final userId = _authService.userId;
    if (userId != null) {
      try {
        await _userService.saveUserAllergens(
          userId: userId,
          allergenIds: allergens,
        );
        
        setState(() {
          _userAllergens = allergens;
        });
        
        // 알러지 설정 변경 알림 추가
        if (allergens.length > oldCount) {
          _notificationService.addNotification(
            title: '알레르기 항목 추가',
            message: '새로운 알레르기 항목이 추가되었습니다. 제품 검색 시 자동으로 필터링됩니다.',
            type: NotificationType.allergy,
          );
        } else if (allergens.length < oldCount) {
          _notificationService.addNotification(
            title: '알레르기 항목 제거',
            message: '알레르기 항목이 제거되었습니다.',
            type: NotificationType.allergy,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('알러지 정보 저장에 실패했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    try {
      // 장바구니와 주문 데이터 초기화
      await _cartService.setUserId(null);
      await _orderService.setUserId(null);
      
      await _authService.signOut();
      // 로그아웃 시 AuthWrapper에서 자동으로 로그인 화면으로 이동
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 하단 네비게이션 탭이 선택될 때 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 로딩 중일 때 로딩 화면 표시
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      /// AppBar: 화면 상단 타이틀 바
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_cart, size: 28),
            const SizedBox(width: 8),
            const Text(
              '알레르기 안심 장보기',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          /// 알림 버튼
          ListenableBuilder(
            listenable: _notificationService,
            builder: (context, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications, size: 28),
                    if (_notificationService.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_notificationService.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: '알림',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(
                        notificationService: _notificationService,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          /// 알레르기 프로필 설정 버튼
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.medical_information, size: 28),
                if (_userAllergens.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_userAllergens.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: '알레르기 프로필 설정',
            onPressed: () {
              /// 알레르기 프로필 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllergyProfileScreen(
                    selectedAllergens: _userAllergens,
                    onAllergensChanged: _onAllergensChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      
      /// 메인 화면 내용
      body: _selectedIndex == 0
          ? ProductListScreen(
              userAllergens: _userAllergens,
              notificationService: _notificationService,
              cartService: _cartService,
              reviewService: _reviewService,
              authService: _authService,
            )
          : _selectedIndex == 1
              ? CartScreen(
                  cartService: _cartService,
                  notificationService: _notificationService,
                  orderService: _orderService,
                  userAllergens: _userAllergens,
                )
              : _selectedIndex == 2
                  ? DeliveryStatusScreen(
                      orderService: _orderService,
                    )
                  : _buildProfileTab(),
      
      /// 하단 네비게이션 바
      bottomNavigationBar: ListenableBuilder(
        listenable: Listenable.merge([_cartService, _orderService]),
        builder: (context, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket),
                label: '제품',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (_cartService.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_cartService.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: '장바구니',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.local_shipping),
                    if (_orderService.hasOrders)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.orange[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: '배달 상황',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '내 정보',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orange[700],
            onTap: _onItemTapped,
          );
        },
      ),
    );
  }

  /// 프로필 탭 화면
  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 프로필 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 24),
            
            /// 사용자 이메일
            Text(
              _authService.userEmail ?? '사용자',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              _userAllergens.isEmpty
                  ? '아직 알레르기 정보가 설정되지 않았습니다'
                  : '${_userAllergens.length}개의 알레르기 항목 설정됨',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            /// 알레르기 설정 버튼
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllergyProfileScreen(
                      selectedAllergens: _userAllergens,
                      onAllergensChanged: _onAllergensChanged,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.medical_information),
              label: const Text('알레르기 프로필 설정'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            /// 로그아웃 버튼
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            /// 앱 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '이 앱에 대하여',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '알레르기가 있는 분들을 위한 안전한 식료품 쇼핑 앱입니다. '
                    '제품에 포함된 알레르기 성분을 확인하고, 안전한 제품만 '
                    '필터링하여 쇼핑할 수 있습니다.',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
