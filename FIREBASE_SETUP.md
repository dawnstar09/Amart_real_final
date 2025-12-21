# Firebase 설정 가이드

이 앱은 Firebase Authentication과 Firestore를 사용합니다.
아래 단계를 따라 Firebase를 설정하세요.

## 1단계: Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: "allergy-grocery-app")
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

## 2단계: Firebase Authentication 활성화

1. Firebase Console > 빌드 > Authentication 클릭
2. "시작하기" 버튼 클릭
3. Sign-in method 탭에서 다음 제공업체 활성화:
   - **이메일/비밀번호**: 사용 설정
   - **Google**: 사용 설정 (프로젝트 지원 이메일 입력 필요)

## 3단계: Firestore 데이터베이스 생성

1. Firebase Console > 빌드 > Firestore Database 클릭
2. "데이터베이스 만들기" 클릭
3. **테스트 모드로 시작** 선택 (개발용)
4. 위치 선택 (예: asia-northeast3 - Seoul)
5. 사용 설정

## 4단계: 웹 앱 추가

1. Firebase Console > 프로젝트 개요 > 웹 아이콘 클릭
2. 앱 닉네임 입력 (예: "Amart Web")
3. Firebase Hosting 설정하지 않음
4. **앱 등록** 클릭
5. Firebase SDK 구성 정보가 표시됨 - 이 값들을 복사하세요!

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "프로젝트ID.firebaseapp.com",
  projectId: "프로젝트ID",
  storageBucket: "프로젝트ID.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:..."
};
```

## 5단계: flutter firebase CLI 사용 (자동 설정)

터미널에서 다음 명령어 실행:

```bash
# Firebase CLI 설치 (이미 설치했다면 생략)
npm install -g firebase-tools

# Firebase 로그인
firebase login

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Flutter 앱에 Firebase 설정 자동 적용
flutterfire configure
```

flutterfire configure 명령어를 실행하면:
1. Firebase 프로젝트 선택 프롬프트가 나타남
2. 사용할 플랫폼 선택 (Android, iOS, Web 등)
3. lib/firebase_options.dart 파일이 **자동으로 생성/업데이트**됨

## 6단계: Google 로그인 설정 (웹용)

web/index.html 파일의 `<head>` 태그 안에 다음 추가:

```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

**YOUR_WEB_CLIENT_ID 찾는 방법:**
1. Firebase Console > 빌드 > Authentication > Settings 탭
2. Authorized domains에 localhost 추가
3. Firebase Console > 프로젝트 설정 > 일반
4. 웹 앱 섹션에서 "웹 클라이언트 ID" 복사

## 7단계: 앱 실행

```bash
flutter run -d chrome
```

## 주의사항

- **lib/firebase_options.dart** 파일은 민감한 정보를 포함하므로 `.gitignore`에 추가되어 있습니다.
- 팀원들과 협업 시 각자 `flutterfire configure`를 실행하여 자신의 설정 파일을 생성해야 합니다.
- 프로덕션 배포 시에는 Firestore 보안 규칙을 반드시 설정하세요!

## Firestore 보안 규칙 (개발용)

Firebase Console > Firestore Database > 규칙 탭에 다음 규칙 적용:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 데이터만 읽고 쓸 수 있음
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 문제 해결

### Google 로그인 오류
- web/index.html에 google-signin-client_id meta 태그가 있는지 확인
- Firebase Console에서 Google 로그인이 활성화되어 있는지 확인

### Firebase 초기화 오류
- flutterfire configure를 정상적으로 실행했는지 확인
- lib/firebase_options.dart 파일이 존재하는지 확인

### Firestore 권한 오류
- Firestore Database가 생성되어 있는지 확인
- 보안 규칙이 올바르게 설정되어 있는지 확인
