# SwiftIntelligence

> العربية | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

مجموعة أدوات ذكاء اصطناعي معيارية لمنصات Apple، مبنية لمسارات عمل حقيقية بين `Vision` و `NaturalLanguage` و `Speech` و `Privacy`.

## الحالة الحالية

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- أقوى مسار حالي: `Vision -> NLP -> Privacy`
- الدليل العام: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## ابدأ من هنا

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## التثبيت

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.0.0")
```

ابدأ عادةً بـ:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## التحقق المحلي

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
