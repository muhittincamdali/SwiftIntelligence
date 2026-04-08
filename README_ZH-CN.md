# SwiftIntelligence

> 简体中文 | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

面向 Apple 平台的模块化 on-device AI toolkit。它把 `Vision`、`NaturalLanguage`、`Speech` 和 `Privacy` 组合成一条真实的产品路径。

## 当前状态

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- 当前最强路径: `Vision -> NLP -> Privacy`
- 公开 proof surface: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## 从这里开始

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## 安装

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.0.0")
```

推荐入口:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## 本地验证

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
