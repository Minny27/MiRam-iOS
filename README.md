# MiRam iOS

MiRam은 iOS에서 동작하는 간단한 알람 앱입니다.  
`SwiftUI`, `SwiftData`, `UserNotifications`, `AVFoundation` 기반으로 구현되어 있으며, 로컬 알림을 이용해 알람을 예약하고 앱 내부에서 알람 울림 화면을 표시합니다.

## 주요 기능

- 알람 추가, 수정, 삭제
- 알람 활성화 / 비활성화
- 1회성 알람 및 요일 반복 알람
- 알람 라벨 설정
- 알람 사운드 및 울림 시간 설정
- 알림 수신 시 전체 화면 알람 UI 표시

## 기술 스택

- `Swift 5.10`
- `iOS 17.0+`
- `SwiftUI`
- `SwiftData`
- `UIKit App Lifecycle` (`AppDelegate`, `SceneDelegate`)
- `UserNotifications`
- `AVFoundation`
- `XcodeGen`

## 프로젝트 실행

### 1. 요구 사항

- Xcode 15 이상
- iOS 17.0 이상 시뮬레이터 또는 실제 기기
- 선택 사항: `XcodeGen`

### 2. 프로젝트 열기

저장소에는 이미 [MiRam.xcodeproj](/Users/seungmin/Repositories/MiRam-iOS/MiRam.xcodeproj) 가 포함되어 있으므로 바로 열 수 있습니다.

```bash
open MiRam.xcodeproj
```

### 3. XcodeGen으로 프로젝트 재생성

`project.yml`을 기준으로 프로젝트를 관리하고 싶다면 아래 명령으로 재생성할 수 있습니다.

```bash
xcodegen generate
```

프로젝트 설정의 소스 오브 트루스는 [project.yml](/Users/seungmin/Repositories/MiRam-iOS/project.yml) 입니다.

## 권한 및 동작 방식

- 앱 실행 시 알림 권한을 요청합니다.
- 알람 예약은 `UNUserNotificationCenter` 기반 로컬 알림으로 처리합니다.
- 알림이 도착하면 `AppDelegate`에서 이벤트를 수신하고, 이를 `NotificationCenter`로 전달합니다.
- `AlarmStateManager`가 해당 이벤트를 받아 SwiftUI의 전체 화면 알람 화면을 띄웁니다.
- 데이터 저장은 `SwiftData`의 `ModelContainer`를 사용합니다.

## 프로젝트 구조

```text
MiRam-iOS
├── App                # 앱 진입점, 윈도우/씬 구성
├── Features           # 화면별 UI와 ViewModel
├── Routes             # 화면 전환 및 내비게이션 구성
├── Shared
│   ├── Models         # Alarm 등 도메인 모델
│   ├── Services       # 알람 예약/상태 관리
│   ├── Style          # 공통 스타일
│   └── DI             # 현재는 비워진 DI 관련 위치
├── SupportingFiles    # Info.plist, LaunchScreen
├── project.yml        # XcodeGen 설정
└── MiRam.xcodeproj
```

## 핵심 파일

- [AppDelegate.swift](/Users/seungmin/Repositories/MiRam-iOS/App/AppDelegate.swift): 알림 권한 요청 및 알람 발화 이벤트 처리
- [SceneDelegate.swift](/Users/seungmin/Repositories/MiRam-iOS/App/SceneDelegate.swift): 루트 화면 구성 및 `SwiftData` 컨테이너 주입
- [MainRoute.swift](/Users/seungmin/Repositories/MiRam-iOS/Routes/Main/MainRoute.swift): 메인 내비게이션 및 알람 울림 화면 연결
- [Alarm.swift](/Users/seungmin/Repositories/MiRam-iOS/Shared/Models/Alarm.swift): 알람 도메인 모델
- [AlarmScheduler.swift](/Users/seungmin/Repositories/MiRam-iOS/Shared/Services/AlarmScheduler.swift): 로컬 알림 예약 및 취소
- [HomeView.swift](/Users/seungmin/Repositories/MiRam-iOS/Features/Main/Home/HomeView.swift): 알람 목록 화면

## 개발 메모

- 현재 `DIContainer`, `AlarmRepository`는 제거된 상태이며, CRUD는 `SwiftData`의 `modelContext`를 통해 직접 처리합니다.
- `SceneDelegate`에서 `ModelContainer` 생성 실패 시 기존 저장소 파일을 삭제한 뒤 재생성하도록 되어 있습니다.
- 앱은 세로 방향(`Portrait`)만 지원합니다.

## 추후 추가하면 좋은 항목

- 앱 스크린샷
- 아키텍처 설명
- 테스트 전략 및 실행 방법
- 배포 / 서명 설정
- 팀 컨벤션
