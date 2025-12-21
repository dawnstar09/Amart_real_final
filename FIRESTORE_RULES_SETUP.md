# Firestore 보안 규칙 설정 방법

## 문제
리뷰와 주문이 Firestore에 저장되지 않는 문제는 보안 규칙 때문입니다.

## 해결 방법

### 1. Firebase Console 접속
https://console.firebase.google.com/project/data-sunlight-467707-r7/firestore

### 2. Firestore Database 선택
왼쪽 메뉴에서 "Firestore Database" 클릭

### 3. Rules 탭 클릭
상단의 "규칙" 또는 "Rules" 탭 클릭

### 4. 다음 규칙으로 교체

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 문서 - 본인만 읽기/쓰기 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 장바구니 - 본인만 읽기/쓰기 가능
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 주문 - 본인 주문만 읽기/쓰기 가능
    match /orders/{orderId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && request.auth.uid == resource.data.userId;
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // 리뷰 - 모든 사용자가 읽기 가능, 로그인한 사용자만 작성 가능
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

### 5. "게시" 또는 "Publish" 버튼 클릭

### 6. Flutter 앱 재시작
터미널에서 `R` (Hot Restart) 입력

---

## 또는 임시로 테스트 모드 사용 (보안 취약 - 개발용만!)

테스트를 위해 임시로 모든 접근 허용:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **주의**: 이 규칙은 모든 로그인한 사용자가 모든 데이터를 읽고 쓸 수 있습니다. 개발/테스트용으로만 사용하세요!
