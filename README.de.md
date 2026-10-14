<!-- i18n-source: README.md@44ff211be1e0a00ecd38c72c7a00a2edff6bbf8a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-de-light.svg" alt="SwiftIntelligence: Suche, Antworten und Schwärzung auf dem Gerät für die Texte deiner App, mit Apples Frameworks."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

Ein Swift-Paket, das die Texte in deiner iOS- oder macOS-App auf dem Gerät durchsuchbar macht und Fragen dazu beantwortet. Füge Notizen, Hilfeartikel oder Nachrichten zu einer `KnowledgeBase` hinzu, durchsuche sie nach Wörtern und nach Bedeutung, lass Apples Modell auf dem Gerät Fragen daraus mit Quellenangaben beantworten und entferne E-Mail-Adressen, Kartennummern und andere personenbezogene Daten, bevor irgendetwas gespeichert oder an ein Modell gesendet wird. Es baut auf NaturalLanguage, Accelerate und Foundation Models auf, hat keine Abhängigkeiten, und nichts verlässt das Gerät, solange deine App es nicht sendet.

## Highlights

- **Hybride Suche** — Jede Passage wird zweimal indiziert, nach ihren Wörtern (BM25) und als Vektor. Die beiden Rangfolgen werden mit Reciprocal Rank Fusion zusammengeführt, sodass die Suche sowohl exakte Codes wie "E-4012" als auch Passagen findet, die andere Wörter verwenden.
- **Antworten mit Quellen** — Unter iOS 26 und macOS 26 bittet `answer(_:)` Apples Modell auf dem Gerät, nur anhand der besten Passagen zu antworten und sie zu zitieren; `groundedPrompt(for:)` erzeugt denselben Prompt für jedes andere Modell, und mit `KnowledgeSearchTool` kann eine Foundation-Models-Sitzung selbstständig suchen.
- **Umkehrbare Schwärzung** — Acht Arten personenbezogener Daten werden zu Platzhaltern wie `[EMAIL_1]`, auf die sich ein Modell weiterhin beziehen kann, und `restoringOriginals(in:)` setzt die Werte wieder in seine Antwort ein. Kartennummern und IBANs müssen ihre Prüfziffern bestehen, und Ziffern in Vollbreite, Zeichen ohne Breite sowie Gruppen, die durch Leerzeichen, Tabulatoren, Bindestriche, Punkte, Schrägstriche, Unterstriche oder einen Zeilenumbruch getrennt sind, verbergen einen Wert nicht.
- **Drei Embedder oder dein eigener** — ein Hashing-Embedder, der überall ohne Modell funktioniert, Apples Satz-Embedding und Apples kontextuelles Embedding; mit `TextEmbedder` bindest du ein Core-ML- oder Servermodell an.
- **Zwischen den Starts gespeichert** — `save(to:)` schreibt die geschwärzten Passagen und ihre Vektoren in eine Datei, und beim Laden wird geprüft, ob Embedder und Daten zusammenpassen.
- **Getestet** — 156 Swift-Testing-Tests auf macOS und 155 auf einem iPhone-Simulator, die Versuche, die Schwärzung zu umgehen, präparierte Speicherdateien, NaN und überlaufende Eingaben, jedes README-Beispiel und, wo verfügbar, eine Antwort des Modells auf dem Gerät abdecken.

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Füge sie oben rechts im Fenster in das Suchfeld ein. Lass **Dependency Rule** auf **Up to Next Major Version** ab `2.0.0` stehen und klicke auf **Add Package**. Wähle im nächsten Fenster neben **SwiftIntelligence** das Target deiner App und klicke noch einmal auf **Add Package**.

**2. Modul importieren**

```swift
import SwiftIntelligence
```

Setze diese Zeile an den Anfang der Swift-Datei, in der du das Paket verwendest.

**3. Verwenden**

Ersetze in einer neuen Xcode-App (**File › New › Project… › App**) den gesamten Inhalt von `ContentView.swift` durch:

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

Drücke **Run** (⌘R). Die App durchsucht die beiden Texte und zeigt den besten Treffer: "You can return any item within 30 days of delivery for a full refund."

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Oder füge es zu den `dependencies` in deiner `Package.swift` hinzu:

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

## Verwendung

Jedes Beispiel unten wird von der [Beispiel-App](Examples/KnowledgeDemo) kompiliert und von den Paket-Tests ausgeführt ([`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)).

### Dokumente durchsuchen

Füge Dokumente mit einer Kennung und optionalen Metadaten hinzu und suche dann im hybriden Standardmodus, oder nur nach Wörtern (`.keyword`) oder nur nach Bedeutung (`.semantic`):

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

Fügst du ein Dokument mit einer bereits vorhandenen Kennung hinzu, ersetzt es das vorhandene; `remove(id:)` löscht es, und `search(_:limit:mode:matching:)` nimmt Metadatenpaare entgegen, die die Ergebnisse haben müssen.

### Fragen mit dem Modell auf dem Gerät beantworten

Unter iOS 26 und macOS 26 mit eingeschaltetem Apple Intelligence antwortet das Systemmodell anhand der Passagen, die zur Frage passen, und zitiert sie als `[1]`, `[2]`, …:

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

Passt nichts, wirft es `AnswerError.noRelevantPassages`, ohne das Modell zu fragen; ist Apple Intelligence aus oder nicht unterstützt, wirft es `AnswerError.modelUnavailable`. Für ein anderes Modell liefert `knowledge.groundedPrompt(for:)` den Prompt und seine nummerierten Quellen.

### Personenbezogene Daten schwärzen

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

Übergib einen Redactor an `KnowledgeBase(redactor:)`, dann werden nur geschwärzte Passagen indiziert und gespeichert. Die Schwärzung ist ein Sicherheitsnetz, keine Garantie: Ausgeschriebene Daten ("jane at example dot com") werden nicht gefunden, und Namen stammen von einem statistischen Modell.

### Nach Bedeutung suchen

Der standardmäßige `HashingEmbedder` findet gemeinsame Wörter und Wortformen. Apples Satz-Embedding findet auch verwandte Wörter:

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Apples Embeddings sind kleine, allgemeine Modelle, und der iOS-Simulator hat sie nicht; bleib beim hybriden Standardmodus, es sei denn, deine eigenen Tests zeigen, dass die rein semantische Suche für deine Texte besser ist.

### Speichern und wiederherstellen

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

Stelle mit demselben Embedder wieder her; ein anderer wirft `KnowledgeBaseError.embedderMismatch`.

### Text analysieren

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## Demo

Die Beispiel-App in einem iPhone-Simulator, die acht Hilfecenter-Artikel durchsucht, daraus Fragen beantwortet und sie schwärzt:

| Suche                                                       | Fragen                                                    | Schwärzen                                                          |
| ----------------------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------ |
| ![Suchansicht, hell](docs/images/example-search-light.png)  | ![Frageansicht, hell](docs/images/example-ask-light.png)  | ![Schwärzungsansicht, hell](docs/images/example-redact-light.png)  |
| ![Suchansicht, dunkel](docs/images/example-search-dark.png) | ![Frageansicht, dunkel](docs/images/example-ask-dark.png) | ![Schwärzungsansicht, dunkel](docs/images/example-redact-dark.png) |

Die Antwort in der Frageansicht ist die eigene Formulierung des Modells auf dem Gerät aus diesem Durchlauf. Die Screenshots werden von [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) aus [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) aufgenommen. Um die App auszuführen, öffne `KnowledgeDemo.xcodeproj` in Xcode, wähle einen iPhone-Simulator oder **My Mac** und drücke **Run**; Einzelheiten stehen in [Examples/README.md](Examples/README.md).

## Dokumentation

API-Referenz und Artikel:

- [API-Referenz](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/) (DocC, von `main` auf GitHub Pages veröffentlicht)
- Baue sie lokal in Xcode mit **Product › Build Documentation** oder über die Kommandozeile:

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## Anleitungen

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted) — Paket hinzufügen, indizieren und suchen, zwischen den Starts speichern, einen Text analysieren ([Quelle](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)).
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments) — Suchmodi, Wahl eines Embedders, Metadatenfilter und Passagengröße ([Quelle](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)).
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions) — Antworten auf dem Gerät, Prompts für andere Modelle, Streaming und das Suchwerkzeug ([Quelle](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)).
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata) — die acht Arten, Ersetzungsstile, Werte wiederherstellen und was nicht erkannt wird ([Quelle](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)).

## Voraussetzungen

| Plattform | Mindestversion |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| Toolchain | Swift 6.2 · Xcode 26+ |

Antworten des Modells auf dem Gerät erfordern iOS 26 oder macOS 26 auf einem Gerät, das Apple Intelligence unterstützt, bei eingeschaltetem Apple Intelligence. Dem iOS-Simulator fehlen die NaturalLanguage-Modelle für Namen, Stimmung und Wortarten sowie das Satz-Embedding: Dort findet `TextAnalyzer` keine Namen oder Schlüsselwörter, der Redactor findet keine Namen, und `SentenceEmbedder` wirft einen Fehler. Die CI baut mit dem Standard-Xcode des `macos-26`-Runner-Images von GitHub; das Paket wird mit Xcode 27 entwickelt.

## Architektur

- `Text/` — `TextAnalyzer`, `TextChunker` und die gemeinsame Normalisierung von Begriffen (Vereinheitlichung von Groß-/Kleinschreibung, Akzenten und Zeichenbreite; Wortgrenzen von `NLTokenizer`, sodass Chinesisch und Japanisch in Wörter zerlegt werden).
- `Privacy/` — `PersonalDataRedactor`. Die Muster laufen auf einer vereinheitlichten Kopie des Texts (`FoldedText`), deren Zuordnung jeden Treffer zu den ursprünglichen Zeichen zurückführt; Prüfziffern (`Checksums`) bestätigen Karten und IBANs; `NSDataDetector` findet Telefonnummern, Links und Adressen, `NLTagger` Namen.
- `Embedding/` — das Protokoll `TextEmbedder` und seine drei Implementierungen.
- `Search/` — `VectorIndex` (exakte Kosinussuche mit einer einzigen Accelerate-Matrixmultiplikation), `KeywordIndex` (BM25), `RankFusion` und der Actor `KnowledgeBase`, der sie verbindet und speichert.
- `Generation/` — `GroundedPrompt`, `GroundedAnswer` und, hinter `canImport(FoundationModels)` und Verfügbarkeitsprüfungen, `answer(_:)` und `KnowledgeSearchTool`.

`KnowledgeBase` berechnet alle Vektoren eines Stapels, bevor es etwas ändert, sodass ein Embedding-Fehler sie unverändert lässt. Die Indizes sind exakt und liegen im Arbeitsspeicher: Sie eignen sich für die Dokumente eines Nutzers oder einer App, bis zu zehntausenden Passagen.

## Roadmap

- Text aus PDFs und Bildern (PDFKit und die Texterkennung von Vision) als Dokumentquellen.
- Ein Embedder mit einem Core-ML-Satzencoder für eine stärkere semantische Suche als mit Apples eingebauten Embeddings.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
