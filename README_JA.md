# SwiftIntelligence

> 日本語 | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Appleプラットフォーム向けのモジュラーな on-device AI toolkit です。`Vision`、`NaturalLanguage`、`Speech`、`Privacy` を実運用向けの流れで結びます。

## 現在の状態

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- 最も強い導入経路: `Vision -> NLP -> Privacy`
- 公開 proof surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## ここから始める

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## インストール

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.1")
```

推奨の最初の構成:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## ローカル検証

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
