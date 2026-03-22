# MiRam iOS

MiRam은 iOS에서 동작하는 간단한 알람 앱입니다.  
`SwiftUI`, `SwiftData`, `AlarmKit` 기반으로 구현되어 있으며, 시스템 알람 권한을 이용해 알람을 예약하고 관리합니다.

## 주요 기능

- 알람 추가, 수정, 삭제
- 알람 활성화 / 비활성화
- 1회성 알람 및 요일 반복 알람
- 알람 라벨 설정
- 알람 사운드 및 울림 시간 설정
- 홈 화면에서 다음 알람 요약 확인
- 시스템 알람 권한 상태 안내

## 기술 스택

- `Swift 5.10`
- `iOS 17.0+`
- `SwiftUI`
- `SwiftData`
- `AlarmKit`
- `ActivityKit`
- `UIKit App Lifecycle` (`AppDelegate`, `SceneDelegate`)
- `XcodeGen`

## 최근 변경 사항

### 2026-03-20

- `Migrate alarm flow to AlarmKit`
  - 기존 로컬 알림 중심 알람 예약 흐름을 `AlarmKit` 기반으로 전환했습니다.
  - `AlarmSchedule` 모델을 추가하고 반복/단일 알람 스케줄링 방식을 정리했습니다.
  - 알람 권한 상태를 기준으로 저장 및 예약 실패 메시지를 표시하도록 보완했습니다.
- `Update home alarm navigation behavior`
  - 홈 화면에서 알람 추가/수정 진입을 시트 기반으로 조정했습니다.
  - 다음 알람 요약 카드, 권한 안내 카드, 빈 상태 UI를 추가해 홈 화면 동선을 개선했습니다.

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

- 알람 활성화 시 `AlarmScheduler`가 `AlarmKit` 권한 상태를 확인하고 필요하면 시스템 권한을 요청합니다.
- 알람 예약과 취소는 `AlarmManager.shared`를 통해 처리합니다.
- 반복 알람은 주간 반복 스케줄로, 1회성 알람은 다음 발화 시각 기준 고정 스케줄로 등록합니다.
- 홈 화면은 권한 거부 상태를 감지해 사용자에게 별도 안내 카드를 표시합니다.
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

- [AppDelegate.swift](/Users/seungmin/Repositories/MiRam-iOS/App/AppDelegate.swift): 앱 생명주기 진입점 및 씬 구성 시작점
- [SceneDelegate.swift](/Users/seungmin/Repositories/MiRam-iOS/App/SceneDelegate.swift): 루트 화면 구성 및 `SwiftData` 컨테이너 주입
- [MainRoute.swift](/Users/seungmin/Repositories/MiRam-iOS/Routes/Main/MainRoute.swift): 메인 내비게이션 스택 구성
- [Alarm.swift](/Users/seungmin/Repositories/MiRam-iOS/Shared/Models/Alarm.swift): 알람 도메인 모델
- [AlarmSchedule.swift](/Users/seungmin/Repositories/MiRam-iOS/Shared/Models/AlarmSchedule.swift): `AlarmKit` 스케줄 구성을 위한 보조 모델
- [AlarmScheduler.swift](/Users/seungmin/Repositories/MiRam-iOS/Shared/Services/AlarmScheduler.swift): `AlarmKit` 기반 알람 예약, 권한 요청, 취소 처리
- [HomeView.swift](/Users/seungmin/Repositories/MiRam-iOS/Features/Main/Home/HomeView.swift): 다음 알람 요약, 알람 목록, 추가/수정 시트 진입을 포함한 홈 화면

## 개발 메모

- `AppDelegate`는 현재 씬 연결 진입점 역할만 담당하며, 알람 예약 로직은 `AlarmScheduler`에 모여 있습니다.
- 홈 화면의 추가/수정 플로우는 `NavigationStack` 내부 푸시가 아니라 시트로 처리됩니다.
- `SceneDelegate`에서 `ModelContainer` 생성 실패 시 기존 저장소 파일을 삭제한 뒤 재생성하도록 되어 있습니다.
- 앱은 세로 방향(`Portrait`)만 지원합니다.

## 추후 추가하면 좋은 항목

- 앱 스크린샷
- 아키텍처 설명
- 테스트 전략 및 실행 방법
- 배포 / 서명 설정
- 팀 컨벤션
