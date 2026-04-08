# SwiftIntelligence

> Tieng Viet | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

Bo cong cu AI on-device theo kieu modular cho nen tang Apple. No ket hop `Vision`, `NaturalLanguage`, `Speech` va `Privacy` trong mot luong san pham thuc te.

## Trang thai hien tai

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Duong dan manh nhat: `Vision -> NLP -> Privacy`
- Be mat bang chung cong khai: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Bat dau tai day

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Cai dat

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.0.0")
```

Duong vao de xuat:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Xac thuc local

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
