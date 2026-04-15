# SwiftIntelligence

> Русский | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Модульный on-device AI toolkit для платформ Apple. Соединяет `Vision`, `NaturalLanguage`, `Speech` и `Privacy` в один реальный продуктовый путь.

## Текущее состояние

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Самый сильный путь: `Vision -> NLP -> Privacy`
- Публичная proof surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Начать здесь

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Установка

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.2")
```

Рекомендуемый стартовый набор:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Локальная проверка

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
