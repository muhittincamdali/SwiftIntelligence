# SwiftIntelligence

> 🇹🇷 Turkce | [English](README.md)

Apple platformlari icin moduler, native-framework-first AI toolkit.

## Durum

- aktif package graph korunuyor
- `swift test` geciyor
- ornekler compile-validate ediliyor
- benchmark ve release proof script tabanli

Bu repo eski umbrella anlatisi yerine aktif modullere odaklanir.
Public kurulum versiyonu `CHANGELOG.md` icindeki son numarali release ile hizali tutulur.

## Kurulum

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.0.0")
]
```

Ardindan ihtiyacin olan urunleri ekle:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence")
```

## Baslangic Noktalari

- [README (English)](README.md)
- [Documentation Index](Documentation/README.md)
- [Getting Started](Documentation/Getting-Started.md)
- [Security Policy](SECURITY.md)
- [Roadmap](ROADMAP.md)

## Not

Eski dokumanlar veya inactive urun referanslari gorursen aktif gercek olarak `Package.swift`, testler ve validation script’lerini esas al.
