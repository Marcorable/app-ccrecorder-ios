---
paths:
  - "**/*.swift"
  - "**/*.xcstrings"
---

# Localization

사용자에게 노출되는 문자열은 String Catalog와 Xcode가 생성한 `LocalizedStringResource` 심벌로 관리한다.

## Catalog 소유권

- 여러 화면에서 사용하는 문자열과 공용 Component가 소유하는 문자열은 타깃의 기본 `Localizable.xcstrings`에 둔다.
- 특정 Screen에서만 사용하는 문자열은 `<Screen 타입명>.xcstrings`에 둔다. Catalog는 해당 Screen 폴더에 배치한다.
- `Info.plist`가 사용하는 앱 이름과 권한 안내 문구는 앱 타깃의 `InfoPlist.xcstrings`에 둔다.
- Catalog 파일은 문자열을 조회하는 코드와 같은 리소스 번들 타깃에 포함한다.
- 화면별 Catalog를 만들 때 `Localizable.xcstrings`에 같은 화면 전용 문자열을 중복해서 두지 않는다.

```text
Presentation/
├── Resources/
│   └── Localizable.xcstrings
└── Sources/UserInterface/MainScreen/
    ├── MainScreen.Root.swift
    └── MainScreen.xcstrings
```

## 키 이름

기본 Catalog에는 `common` 접두어를 붙이지 않는다. 파일 자체가 공통 범위를 나타낸다.

- 일반 공통 문구: `{텍스트 역할}.{상세}_{추가 상세}`
- 공용 Component 문구: `{Component 타입명}.{텍스트 역할}.{상세}_{추가 상세}`
- Screen Catalog 문구: `[{사용 View 타입명}.]{텍스트 역할}.{상세}_{추가 상세}`

타입명은 키에서 lower camel case로 쓰고 Xcode가 생성한 심벌의 표기를 따른다. `button`, `label`, `title`, `prompt`, `message`, `error`, `alert`, `accessibility`처럼 문구가 UI에서 맡는 역할을 구분점으로 사용한다.

```text
// Localizable.xcstrings
button.confirm
error.try_again_later
noteBoard.prompt.sentence_translation

// MainScreen.xcstrings
button.confirm
conversationList.label.empty_title
conversationListRow.label.attendee_count
```

상태만 달라지고 표시 문구가 같다면 키를 나누지 않는다. 실제 문구나 번역 의미가 다른 경우에만 `_disabled` 같은 추가 상세를 붙인다.

## 생성 심벌 사용

String Catalog를 소유한 타깃에서 `Generate String Catalog Symbols`를 활성화한다. 기본 `Localizable` 테이블의 심벌은 바로 사용하고, 화면별 Catalog의 심벌은 Catalog 이름 네임스페이스로 사용한다.

```swift
Text(.buttonConfirm)
Text(.noteBoardPromptSentenceTranslation)
Text(.MainScreen.buttonConfirm)
Text(.MainScreen.conversationListLabelEmptyTitle)
```

문자열 보간이나 복수형은 Catalog의 format 또는 plural variation으로 정의하고 생성된 함수를 호출한다.

```swift
Text(.MainScreen.conversationListRowLabelAttendeeCount(count))
```

SwiftUI API가 `LocalizedStringResource`를 받으면 생성 심벌을 직접 전달한다. `String`이 필요한 API에서는 `String(localized:)`를 사용한다. 연산 프로퍼티나 메서드의 반환 타입이 명확하게 `String`인 경우에만 `.init(localized:)`로 줄인다.

```swift
Text(.MainScreen.titleNavigation)

String(localized: .MainScreen.titleNavigation)

private var title: String {
    .init(localized: .MainScreen.titleNavigation)
}
```

`LocalizedStringResource` extension, `L10n` wrapper, 문자열 키를 받는 자체 helper는 만들지 않는다. 생성 심벌을 사용할 수 있는 문구에 raw key와 `table`, `bundle`을 반복해서 작성하지 않는다.

## 포함과 제외

- Button, Label, Alert, 접근성 label·hint 등 실제 사용자 노출 문구를 현지화한다.
- Preview 전용 데이터, 테스트 fixture, 로그, 디버그 문구, 외부 시스템 식별자는 합리적인 근거가 있으면 제외할 수 있다.
- 제외 여부는 문자열이 실제 배포 UI에 노출되는지를 우선해서 판단한다.
