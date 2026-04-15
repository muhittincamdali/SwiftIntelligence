# SwiftIntelligence

> Українська | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Модульний on-device AI toolkit для платформ Apple. Поєднує `Vision`, `NaturalLanguage`, `Speech` і `Privacy` в один реальний продуктовий шлях.

## Поточний стан

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Найсильніший шлях: `Vision -> NLP -> Privacy`
- Публічний proof surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Почати тут

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Встановлення

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.1")
```

Рекомендований стартовий набір:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Локальна перевірка

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
