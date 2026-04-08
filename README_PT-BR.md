# SwiftIntelligence

> Portugues (Brasil) | [English](README.md) | [Language Hub](Documentation/README-Languages.md)

Toolkit modular de IA on-device para plataformas Apple. Conecta `Vision`, `NaturalLanguage`, `Speech` e `Privacy` em um fluxo de produto real.

## Estado atual

- `Publish readiness`: `ready`
- `Distribution posture`: `release-grade`
- `Required release floor`: `Mac + iPhone`
- Caminho mais forte: `Vision -> NLP -> Privacy`
- Superficie publica de prova: [Public Proof Status](Documentation/Generated/Public-Proof-Status.md)

## Comece aqui

- [Getting Started](Documentation/Getting-Started.md)
- [IntelligentCamera Demo](Examples/DemoApps/IntelligentCamera/README.md)
- [Comparisons](Documentation/Comparisons/README.md)
- [Showcase](Documentation/Showcase.md)

## Instalacao

```swift
.package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "1.2.0")
```

Caminho inicial recomendado:

```swift
.product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
.product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
```

## Validacao local

```bash
swift build
bash Scripts/validate-flagship-demo.sh
bash Scripts/validate-examples.sh
swift test
```
