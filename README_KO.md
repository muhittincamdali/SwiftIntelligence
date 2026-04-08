# SwiftIntelligence

> 한국어 | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

Apple 플랫폼을 위한 modular on-device AI toolkit입니다. `Vision`, `NaturalLanguage`, `Speech`, `Privacy`를 하나의 실제 제품 흐름으로 묶습니다.

## 현재 상태

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- 가장 강한 경로: `Vision -> NLP -> Privacy`
- 공개 proof surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## 여기서 시작

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## 설치

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.0")
```

권장 시작 구성:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## 로컬 검증

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
