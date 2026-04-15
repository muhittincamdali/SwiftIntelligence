# SwiftIntelligence

> Espanol | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

> Localized summary. The English README is the canonical and most complete version.

Toolkit modular de IA on-device para plataformas Apple. Une `Vision`, `NaturalLanguage`, `Speech` y `Privacy` en un flujo de producto real.

## Estado actual

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Camino mas fuerte: `Vision -> NLP -> Privacy`
- Superficie publica de evidencia: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Empieza aqui

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Instalacion

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.2")
```

Entrada recomendada:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Verificacion local

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
