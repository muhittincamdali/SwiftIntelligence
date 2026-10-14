<!-- i18n-source: README.md@44ff211be1e0a00ecd38c72c7a00a2edff6bbf8a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-es-light.svg" alt="SwiftIntelligence: Búsqueda, respuestas y anonimización en el dispositivo para el texto de tu app, con los frameworks de Apple."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="Última versión: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

Un paquete de Swift que hace que el texto de tu app de iOS o macOS se pueda buscar y consultar en el dispositivo. Añade notas, artículos de ayuda o mensajes a un `KnowledgeBase`, búscalos por palabras y por significado, haz que el modelo de Apple en el dispositivo responda preguntas a partir de ellos con citas, y elimina direcciones de correo, números de tarjeta y otros datos personales antes de que se guarden o se envíen a un modelo. Está construido sobre NaturalLanguage, Accelerate y Foundation Models, no tiene dependencias y nada sale del dispositivo a menos que tu app lo envíe.

## Lo más destacado

- **Búsqueda híbrida**: cada pasaje se indexa dos veces, por sus palabras (BM25) y como vector, y las dos clasificaciones se combinan con reciprocal rank fusion, de modo que una búsqueda encuentra tanto códigos exactos como "E-4012" como pasajes que usan otras palabras.
- **Respuestas con fuentes**: en iOS 26 y macOS 26, `answer(_:)` pide al modelo de Apple en el dispositivo que responda solo a partir de los mejores pasajes y que los cite; `groundedPrompt(for:)` genera el mismo prompt para cualquier otro modelo, y `KnowledgeSearchTool` permite que una sesión de Foundation Models busque por sí misma.
- **Anonimización reversible**: ocho tipos de datos personales se convierten en marcadores como `[EMAIL_1]` a los que un modelo todavía puede referirse, y `restoringOriginals(in:)` devuelve los valores originales a su respuesta. Los números de tarjeta y los IBAN deben superar sus dígitos de control, y los dígitos de ancho completo, los caracteres de ancho cero y los grupos separados por espacios, tabulaciones, guiones, puntos, barras, guiones bajos o un salto de línea no ocultan un valor.
- **Tres embedders, o el tuyo**: un embedder de hashing que funciona en todas partes sin ningún modelo, el embedding de oraciones de Apple y el embedding contextual de Apple; adopta `TextEmbedder` para conectar un modelo de Core ML o de un servidor.
- **Guardado entre sesiones**: `save(to:)` escribe un único archivo con los pasajes anonimizados y sus vectores, y al cargarlo se comprueba que el embedder y los datos coincidan.
- **Probado**: 156 pruebas de Swift Testing en macOS y 155 en un simulador de iPhone, que cubren intentos de eludir la anonimización, archivos guardados manipulados, entradas con NaN o desbordamiento, todos los ejemplos del README y una respuesta del modelo en el dispositivo cuando está disponible.

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Pégala en el campo de búsqueda de la parte superior derecha de la ventana. Deja **Dependency Rule** en **Up to Next Major Version** desde `2.0.0` y haz clic en **Add Package**. En la ventana siguiente, elige el target de tu app junto a **SwiftIntelligence** y haz clic de nuevo en **Add Package**.

**2. Importa el módulo**

```swift
import SwiftIntelligence
```

Pon esta línea al principio del archivo de Swift donde uses el paquete.

**3. Úsalo**

En una app nueva de Xcode (**File › New › Project… › App**), sustituye todo el contenido de `ContentView.swift` por:

```swift
import SwiftUI
import SwiftIntelligence

struct ContentView: View {
    @State private var answer = "Searching…"

    var body: some View {
        Text(answer)
            .padding()
            .task { answer = await Self.bestMatch() }
    }

    static func bestMatch() async -> String {
        do {
            let knowledge = KnowledgeBase()
            try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
            try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")
            let results = try await knowledge.search("How do I return an item for a refund?")
            return results.first?.text ?? "Nothing found"
        } catch {
            return "Search failed: \(error)"
        }
    }
}
```

Pulsa **Run** (⌘R). La app busca en los dos textos y muestra la mejor coincidencia: "You can return any item within 30 days of delivery for a full refund."

## Instalación

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

O añádelo a las `dependencies` de tu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftIntelligence.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftIntelligence", package: "SwiftIntelligence")
    ])
]
```

## Uso

Cada ejemplo de abajo se compila en la [app de ejemplo](Examples/KnowledgeDemo) y se ejecuta en las pruebas del paquete ([`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)).

### Busca en tus documentos

Añade documentos con un identificador y metadatos opcionales y busca en el modo híbrido predeterminado, o solo por palabras (`.keyword`) o solo por significado (`.semantic`):

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

Añadir un documento con un identificador existente lo reemplaza, `remove(id:)` lo elimina y `search(_:limit:mode:matching:)` acepta pares de metadatos que los resultados deben tener.

### Responde preguntas con el modelo en el dispositivo

En iOS 26 y macOS 26 con Apple Intelligence activado, el modelo del sistema responde a partir de los pasajes que coinciden con la pregunta y los cita como `[1]`, `[2]`, …:

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

Lanza `AnswerError.noRelevantPassages` sin consultar al modelo cuando nada coincide, y `AnswerError.modelUnavailable` cuando Apple Intelligence está desactivado o no es compatible. Para otro modelo, `knowledge.groundedPrompt(for:)` devuelve el prompt y sus fuentes numeradas.

### Anonimiza datos personales

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

Pasa un redactor a `KnowledgeBase(redactor:)` y solo se indexarán y guardarán pasajes anonimizados. La anonimización es una red de seguridad, no una garantía: los datos escritos con palabras ("jane at example dot com") no se detectan, y los nombres los detecta un modelo estadístico.

### Busca por significado

El `HashingEmbedder` predeterminado encuentra palabras y formas de palabra en común. El embedding de oraciones de Apple también encuentra palabras relacionadas:

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Los embeddings de Apple son modelos generales pequeños y el simulador de iOS no los tiene; mantén el modo híbrido predeterminado, a menos que tus propias pruebas muestren que la búsqueda semántica sola funciona mejor con tus textos.

### Guarda y restaura

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

Restaura con el mismo embedder; uno distinto lanza `KnowledgeBaseError.embedderMismatch`.

### Analiza texto

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## Demo

La app de ejemplo en un simulador de iPhone, buscando, respondiendo y anonimizando ocho artículos de un centro de ayuda:

| Buscar                                                                    | Preguntar                                                               | Anonimizar                                                                     |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| ![Pantalla de búsqueda, modo claro](docs/images/example-search-light.png) | ![Pantalla de preguntas, modo claro](docs/images/example-ask-light.png) | ![Pantalla de anonimización, modo claro](docs/images/example-redact-light.png) |
| ![Pantalla de búsqueda, modo oscuro](docs/images/example-search-dark.png) | ![Pantalla de preguntas, modo oscuro](docs/images/example-ask-dark.png) | ![Pantalla de anonimización, modo oscuro](docs/images/example-redact-dark.png) |

La respuesta de la pantalla de preguntas es la redacción propia del modelo en el dispositivo en esa ejecución. Las capturas se toman de [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) con [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). Para ejecutar la app, abre `KnowledgeDemo.xcodeproj` en Xcode, elige un simulador de iPhone o **My Mac** y pulsa **Run**; [Examples/README.md](Examples/README.md) tiene los detalles.

## Documentación

Referencia de la API y artículos:

- [Referencia de la API](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/) (DocC, publicada en GitHub Pages desde `main`)
- Compílala en local en Xcode con **Product › Build Documentation**, o desde la línea de comandos:

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## Guías

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted): añadir el paquete, indexar y buscar, guardar entre sesiones, analizar un texto ([código fuente](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)).
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments): modos de búsqueda, cómo elegir un embedder, filtros de metadatos y tamaño de los pasajes ([código fuente](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)).
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions): respuestas en el dispositivo, prompts para otros modelos, streaming y la herramienta de búsqueda ([código fuente](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)).
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata): los ocho tipos, estilos de sustitución, cómo restaurar valores y qué no se detecta ([código fuente](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)).

## Requisitos

| Plataforma | Versión mínima |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| Herramientas | Swift 6.2 · Xcode 26+ |

Las respuestas del modelo en el dispositivo requieren iOS 26 o macOS 26 en un dispositivo compatible con Apple Intelligence, con Apple Intelligence activado. El simulador de iOS no tiene los modelos de NaturalLanguage para nombres, sentimiento y categorías gramaticales, ni el embedding de oraciones: allí `TextAnalyzer` no encuentra nombres ni palabras clave, el redactor no encuentra nombres y `SentenceEmbedder` lanza un error. La CI compila con el Xcode predeterminado de la imagen de runner `macos-26` de GitHub; el paquete se desarrolla con Xcode 27.

## Arquitectura

- `Text/`: `TextAnalyzer`, `TextChunker` y la normalización de términos compartida (unificación de mayúsculas, acentos y anchura; con los límites de palabra de `NLTokenizer`, de modo que el chino y el japonés se dividen en palabras).
- `Privacy/`: `PersonalDataRedactor`. Los patrones se ejecutan sobre una copia normalizada del texto (`FoldedText`) cuyo mapa lleva cada coincidencia de vuelta a los caracteres originales; los dígitos de control (`Checksums`) confirman tarjetas e IBAN; `NSDataDetector` encuentra números de teléfono, enlaces y direcciones, y `NLTagger` los nombres.
- `Embedding/`: el protocolo `TextEmbedder` y sus tres implementaciones.
- `Search/`: `VectorIndex` (búsqueda exacta por coseno con una sola multiplicación de matrices de Accelerate), `KeywordIndex` (BM25), `RankFusion` y el actor `KnowledgeBase`, que los une y los guarda.
- `Generation/`: `GroundedPrompt`, `GroundedAnswer` y, tras `canImport(FoundationModels)` y las comprobaciones de disponibilidad, `answer(_:)` y `KnowledgeSearchTool`.

`KnowledgeBase` calcula todos los vectores de un lote antes de cambiar nada, así que un error de embedding la deja sin modificar. Los índices son exactos y están en memoria: sirven para los documentos de un usuario o de una app, hasta decenas de miles de pasajes.

## Hoja de ruta

- Texto de PDF e imágenes (PDFKit y el reconocedor de texto de Vision) como fuentes de documentos.
- Un embedder con un codificador de oraciones de Core ML, para una búsqueda semántica más potente que la de los embeddings integrados de Apple.

## Contribuir

Las contribuciones son bienvenidas. Lee la [guía de contribución](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md) y el [código de conducta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir una pull request. Informa de los problemas de seguridad de forma privada, como se describe en la [política de seguridad](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
