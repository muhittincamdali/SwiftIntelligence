<!-- i18n-source: README.md@c3973900c06dd9a898716cff73ecfa521ffe82e0 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ko-light.svg" alt="SwiftIntelligence: Apple 프레임워크로 앱의 텍스트를 기기에서 검색하고, 답하고, 가립니다."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="최신 버전: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

iOS 또는 macOS 앱의 텍스트를 기기에서 검색하고 질문에 답할 수 있게 해 주는 Swift 패키지입니다. 메모, 도움말 문서, 메시지를 `KnowledgeBase`에 추가하면 단어와 의미로 검색할 수 있고, Apple의 온디바이스 모델이 그 내용을 바탕으로 출처를 밝히며 질문에 답하게 할 수 있습니다. 또한 데이터가 저장되거나 모델로 전송되기 전에 이메일 주소, 카드 번호 같은 개인 정보를 제거할 수 있습니다. NaturalLanguage, Accelerate, Foundation Models를 기반으로 만들어졌고 의존성이 없으며, 앱이 직접 보내지 않는 한 어떤 데이터도 기기를 떠나지 않습니다.

## 주요 기능

- **하이브리드 검색** — 모든 구절은 단어(BM25)와 벡터, 두 가지 방식으로 색인됩니다. 두 순위는 reciprocal rank fusion으로 합쳐지므로, 검색은 "E-4012" 같은 정확한 코드와 다른 단어로 쓰인 구절을 모두 찾아냅니다.
- **출처가 있는 답변** — iOS 26과 macOS 26에서 `answer(_:)`는 Apple의 온디바이스 모델에게 가장 알맞은 구절만 근거로 답하고 출처를 밝히도록 요청합니다. `groundedPrompt(for:)`는 다른 모델을 위해 같은 프롬프트를 만들어 주고, `KnowledgeSearchTool`을 쓰면 Foundation Models 세션이 스스로 검색할 수 있습니다.
- **되돌릴 수 있는 마스킹** — 여덟 가지 개인 정보가 `[EMAIL_1]` 같은 자리 표시자로 바뀌며 모델은 이를 계속 가리킬 수 있고, `restoringOriginals(in:)`가 원래 값을 답변에 되돌려 넣습니다. 카드 번호와 IBAN은 체크 숫자 검증을 통과해야 하며, 전각 숫자, 폭이 0인 문자, 흔치 않은 구분자로도 값을 숨길 수 없습니다.
- **세 가지 embedder, 또는 직접 만든 것** — 모델 없이 어디서나 동작하는 hashing embedder, Apple의 문장 임베딩, Apple의 문맥 임베딩이 있습니다. `TextEmbedder`를 채택하면 Core ML 또는 서버 모델을 연결할 수 있습니다.
- **실행 사이에 저장** — `save(to:)`는 마스킹된 구절과 그 벡터를 파일 하나에 기록하고, 불러올 때 embedder와 데이터가 일치하는지 확인합니다.
- **테스트 완료** — macOS에서 149개, iPhone 시뮬레이터에서 148개의 Swift Testing 테스트가 마스킹 우회 시도, 조작된 저장 파일, NaN과 오버플로 입력, README의 모든 예제, 그리고 사용할 수 있는 환경에서의 온디바이스 모델 답변을 다룹니다.

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

창 오른쪽 위의 검색 필드에 붙여 넣으세요. **Dependency Rule**은 `2.0.0`부터 **Up to Next Major Version**으로 그대로 두고 **Add Package**를 클릭하세요. 다음 창에서 **SwiftIntelligence** 옆에 앱 타깃을 선택하고 **Add Package**를 다시 클릭하세요.

**2. 모듈 가져오기**

```swift
import SwiftIntelligence
```

패키지를 사용하는 Swift 파일의 맨 위에 이 줄을 넣으세요.

**3. 사용하기**

새 Xcode 앱(**File › New › Project… › App**)에서 `ContentView.swift`의 내용을 모두 다음으로 바꾸세요.

```swift
import SwiftUI
import SwiftIntelligence

struct ContentView: View {
    @State private var answer = "Searching…"

    var body: some View {
        Text(answer)
            .padding()
            .task {
                do {
                    let knowledge = KnowledgeBase()
                    try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
                    try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")
                    let results = try await knowledge.search("How do I return an item for a refund?")
                    answer = results.first?.text ?? "Nothing found"
                } catch {
                    answer = "Search failed: \(error)"
                }
            }
    }
}
```

**Run**(⌘R)을 누르세요. 앱이 두 텍스트를 검색해 가장 잘 맞는 결과를 보여 줍니다: "You can return any item within 30 days of delivery for a full refund."

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

또는 `Package.swift`의 `dependencies`에 추가하세요.

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftIntelligence", package: "SwiftIntelligence")
    ])
]
```

## 사용법

아래 예제는 모두 [예제 앱](Examples/KnowledgeDemo)에서 컴파일되고 패키지 테스트([`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift))에서 실행됩니다.

### 문서 검색하기

식별자와 선택적인 메타데이터와 함께 문서를 추가한 다음, 기본인 하이브리드 모드로 검색하거나 단어(`.keyword`)만, 또는 의미(`.semantic`)만으로 검색하세요.

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

이미 있는 식별자로 문서를 추가하면 기존 문서가 교체되고, `remove(id:)`는 문서를 삭제합니다. `search(_:limit:mode:matching:)`에는 결과가 반드시 가져야 하는 메타데이터 쌍을 넘길 수 있습니다.

### 온디바이스 모델로 질문에 답하기

Apple Intelligence를 켠 iOS 26과 macOS 26에서는 시스템 모델이 질문과 일치하는 구절을 바탕으로 답하고 `[1]`, `[2]`, … 형식으로 출처를 표시합니다.

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

일치하는 것이 없으면 모델에 묻지 않고 `AnswerError.noRelevantPassages`를 던지며, Apple Intelligence가 꺼져 있거나 지원되지 않으면 `AnswerError.modelUnavailable`을 던집니다. 다른 모델을 쓸 때는 `knowledge.groundedPrompt(for:)`가 프롬프트와 번호가 붙은 출처를 반환합니다.

### 개인 정보 마스킹하기

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

`KnowledgeBase(redactor:)`에 redactor를 넘기면 마스킹된 구절만 색인되고 저장됩니다. 마스킹은 안전망일 뿐 보장은 아닙니다. 글자로 풀어 쓴 데이터("jane at example dot com")는 찾지 못하며, 이름은 통계 모델이 찾습니다.

### 의미로 검색하기

기본 `HashingEmbedder`는 공통 단어와 단어 형태를 맞춰 봅니다. Apple의 문장 임베딩은 관련된 단어도 맞춰 봅니다.

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Apple의 임베딩은 작은 범용 모델이며 iOS 시뮬레이터에는 없습니다. 직접 테스트해서 의미 검색만 쓰는 편이 내 텍스트에 더 낫다는 것을 확인하지 않았다면 기본 하이브리드 모드를 유지하세요.

### 저장과 복원

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

같은 embedder로 복원하세요. 다른 embedder를 쓰면 `KnowledgeBaseError.embedderMismatch`를 던집니다.

### 텍스트 분석하기

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## 데모

iPhone 시뮬레이터에서 실행한 예제 앱이 도움말 센터 문서 여덟 개를 검색하고, 답하고, 마스킹하는 모습입니다.

| 검색                                                       | 질문                                                    | 마스킹                                                       |
| ---------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| ![검색 화면, 라이트](docs/images/example-search-light.png) | ![질문 화면, 라이트](docs/images/example-ask-light.png) | ![마스킹 화면, 라이트](docs/images/example-redact-light.png) |
| ![검색 화면, 다크](docs/images/example-search-dark.png)    | ![질문 화면, 다크](docs/images/example-ask-dark.png)    | ![마스킹 화면, 다크](docs/images/example-redact-dark.png)    |

질문 화면의 답변은 그 실행에서 온디바이스 모델이 직접 쓴 표현입니다. 스크린샷은 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh)로 [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo)에서 캡처했습니다. 앱을 실행하려면 Xcode에서 `KnowledgeDemo.xcodeproj`를 열고 iPhone 시뮬레이터 또는 **My Mac**을 선택한 뒤 **Run**을 누르세요. 자세한 내용은 [Examples/README.md](Examples/README.md)에 있습니다.

## 문서

API 레퍼런스와 문서:

- [API 레퍼런스](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/) (DocC, `main`에서 GitHub Pages로 게시)
- 로컬에서는 Xcode의 **Product › Build Documentation**으로, 또는 명령줄에서 빌드할 수 있습니다.

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## 가이드

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted) — 패키지 추가, 색인과 검색, 실행 사이에 저장, 텍스트 분석 ([소스](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)).
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments) — 검색 모드, embedder 고르기, 메타데이터 필터, 구절 크기 ([소스](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)).
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions) — 온디바이스 답변, 다른 모델용 프롬프트, 스트리밍, 검색 도구 ([소스](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)).
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata) — 여덟 가지 종류, 대체 방식, 값 복원, 찾지 못하는 것 ([소스](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)).

## 요구 사항

| 플랫폼 | 최소 버전 |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| 툴체인 | Swift 6.2 · Xcode 26+ |

온디바이스 모델의 답변을 쓰려면 Apple Intelligence를 지원하는 기기에서 iOS 26 또는 macOS 26을 사용하고 Apple Intelligence를 켜야 합니다. iOS 시뮬레이터에는 NaturalLanguage의 이름·감정·품사 모델과 문장 임베딩이 없습니다. 그래서 시뮬레이터에서는 `TextAnalyzer`가 이름이나 키워드를 찾지 못하고, redactor도 이름을 찾지 못하며, `SentenceEmbedder`는 오류를 던집니다. CI는 GitHub의 `macos-26` 러너 이미지에 들어 있는 기본 Xcode로 빌드하며, 패키지는 Xcode 27로 개발합니다.

## 아키텍처

- `Text/` — `TextAnalyzer`, `TextChunker`, 그리고 공통 용어 정규화(대소문자, 악센트, 전각·반각 통일. `NLTokenizer`의 단어 경계를 쓰므로 중국어와 일본어도 단어로 나뉩니다).
- `Privacy/` — `PersonalDataRedactor`. 패턴은 텍스트를 정규화한 사본(`FoldedText`)에서 실행되며, 그 맵이 모든 일치 결과를 원래 문자로 되돌려 연결합니다. 체크 숫자(`Checksums`)로 카드와 IBAN을 확인하고, `NSDataDetector`가 전화번호, 링크, 주소를, `NLTagger`가 이름을 찾습니다.
- `Embedding/` — `TextEmbedder` 프로토콜과 세 가지 구현.
- `Search/` — `VectorIndex`(Accelerate 행렬 곱셈 한 번으로 하는 정확한 코사인 검색), `KeywordIndex`(BM25), `RankFusion`, 그리고 이들을 엮고 저장하는 `KnowledgeBase` actor.
- `Generation/` — `GroundedPrompt`, `GroundedAnswer`, 그리고 `canImport(FoundationModels)`와 가용성 검사 뒤에 있는 `answer(_:)`와 `KnowledgeSearchTool`.

`KnowledgeBase`는 무언가를 바꾸기 전에 한 배치의 모든 벡터를 먼저 계산하므로, 임베딩 오류가 나도 상태는 그대로입니다. 색인은 정확하고 메모리에 올라가 있습니다. 한 사용자 또는 한 앱의 문서, 수만 개 구절까지에 적합합니다.

## 로드맵

- PDF와 이미지의 텍스트(PDFKit과 Vision 텍스트 인식기)를 문서 소스로 지원.
- Apple 내장 임베딩보다 강력한 의미 검색을 위한 Core ML 문장 인코더 embedder.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
