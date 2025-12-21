import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication을 관리하는 서비스 클래스
/// 로그인, 회원가입, 로그아웃 등의 인증 기능을 제공합니다.
class AuthService {
  /// FirebaseAuth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// GoogleSignIn 인스턴스 (조건부 생성)
  GoogleSignIn? _googleSignIn;

  /// 현재 로그인된 사용자를 가져옵니다
  User? get currentUser => _auth.currentUser;

  /// 인증 상태 변경 스트림
  /// 로그인/로그아웃 시 자동으로 UI를 업데이트할 수 있습니다
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 이메일과 비밀번호로 회원가입
  /// 
  /// [email]: 사용자 이메일
  /// [password]: 비밀번호 (최소 6자 이상)
  /// 
  /// 성공 시 User 객체 반환, 실패 시 예외 발생
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 오류 처리
      throw _handleAuthException(e);
    } catch (e) {
      throw '회원가입 중 오류가 발생했습니다: $e';
    }
  }

  /// 이메일과 비밀번호로 로그인
  /// 
  /// [email]: 사용자 이메일
  /// [password]: 비밀번호
  /// 
  /// 성공 시 User 객체 반환, 실패 시 예외 발생
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw '로그인 중 오류가 발생했습니다: $e';
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      throw '로그아웃 중 오류가 발생했습니다: $e';
    }
  }

  /// Google 로그인
  /// 
  /// Google 계정으로 로그인합니다.
  /// 성공 시 User 객체 반환, 실패 시 예외 발생
  Future<User?> signInWithGoogle() async {
    try {
      // GoogleSignIn 초기화 (처음 호출 시에만)
      _googleSignIn ??= GoogleSignIn();
      
      // Google 로그인 팝업 표시
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      
      // 사용자가 로그인을 취소한 경우
      if (googleUser == null) {
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Firebase 인증 credential 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google 로그인 중 오류가 발생했습니다: $e';
    }
  }

  /// 비밀번호 재설정 이메일 전송
  /// 
  /// [email]: 비밀번호를 재설정할 계정의 이메일
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw '비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: $e';
    }
  }

  /// Firebase 인증 예외를 사용자 친화적인 메시지로 변환
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 최소 6자 이상 입력해주세요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 시도가 있었습니다. 나중에 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 활성화되지 않았습니다.';
      case 'account-exists-with-different-credential':
        return '이미 다른 로그인 방법으로 등록된 계정입니다.';
      case 'invalid-credential':
        return '잘못된 인증 정보입니다.';
      default:
        return '인증 오류: ${e.message}';
    }
  }

  /// 현재 사용자의 UID를 가져옵니다
  /// 로그인되지 않은 경우 null 반환
  String? get userId => currentUser?.uid;

  /// 현재 사용자의 이메일을 가져옵니다
  /// 로그인되지 않은 경우 null 반환
  String? get userEmail => currentUser?.email;

  /// 사용자가 로그인되어 있는지 확인
  bool get isLoggedIn => currentUser != null;
}
