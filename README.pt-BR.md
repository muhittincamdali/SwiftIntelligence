<!-- i18n-source: README.md@c3973900c06dd9a898716cff73ecfa521ffe82e0 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-pt-BR-light.svg" alt="SwiftIntelligence: Busca, respostas e anonimização no dispositivo para os textos do seu app, com os frameworks da Apple."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="Versão mais recente: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

Um pacote Swift que torna o texto do seu app de iOS ou macOS pesquisável e capaz de responder perguntas no próprio dispositivo. Adicione anotações, artigos de ajuda ou mensagens a uma `KnowledgeBase`, pesquise nelas por palavras e por significado, peça ao modelo da Apple no dispositivo que responda perguntas com base nelas, com citações, e remova e-mails, números de cartão e outros dados pessoais antes que qualquer coisa seja armazenada ou enviada a um modelo. Ele é construído sobre NaturalLanguage, Accelerate e Foundation Models, não tem dependências, e nada sai do dispositivo a menos que o seu app envie.

## Destaques

- **Busca híbrida** — cada trecho é indexado duas vezes, pelas suas palavras (BM25) e como um vetor, e os dois rankings são combinados com reciprocal rank fusion, de modo que a busca encontra tanto códigos exatos como "E-4012" quanto trechos que usam outras palavras.
- **Respostas com fontes** — no iOS 26 e no macOS 26, `answer(_:)` pede ao modelo da Apple no dispositivo que responda apenas com base nos melhores trechos e os cite; `groundedPrompt(for:)` monta o mesmo prompt para qualquer outro modelo, e `KnowledgeSearchTool` permite que uma sessão do Foundation Models pesquise por conta própria.
- **Anonimização reversível** — oito tipos de dados pessoais viram marcadores como `[EMAIL_1]`, aos quais um modelo ainda consegue se referir, e `restoringOriginals(in:)` devolve os valores à resposta dele. Números de cartão e IBANs precisam passar nos dígitos verificadores, e dígitos de largura total, caracteres de largura zero e separadores incomuns não escondem um valor.
- **Três embedders, ou o seu próprio** — um embedder de hashing que funciona em qualquer lugar, sem modelo, o embedding de frases da Apple e o embedding contextual da Apple; adote `TextEmbedder` para conectar um modelo Core ML ou de servidor.
- **Salvo entre execuções** — `save(to:)` grava um único arquivo com os trechos anonimizados e seus vetores, e o carregamento verifica se o embedder e os dados correspondem.
- **Testado** — 156 testes do Swift Testing no macOS e 155 em um simulador de iPhone, cobrindo tentativas de burlar a anonimização, arquivos salvos adulterados, entradas com NaN e com estouro, todos os exemplos do README e uma resposta do modelo no dispositivo onde ele estiver disponível.

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Cole-a no campo de busca, no canto superior direito da janela. Deixe **Dependency Rule** em **Up to Next Major Version** a partir de `2.0.0` e clique em **Add Package**. Na janela seguinte, escolha o target do seu app ao lado de **SwiftIntelligence** e clique em **Add Package** de novo.

**2. Importe o módulo**

```swift
import SwiftIntelligence
```

Coloque esta linha no topo do arquivo Swift em que você usa o pacote.

**3. Use**

Em um app novo do Xcode (**File › New › Project… › App**), substitua todo o conteúdo de `ContentView.swift` por:

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

Pressione **Run** (⌘R). O app pesquisa nos dois textos e mostra a melhor correspondência: "You can return any item within 30 days of delivery for a full refund."

## Instalação

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Ou adicione-o às `dependencies` do seu `Package.swift`:

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

Cada exemplo abaixo é compilado pelo [app de exemplo](Examples/KnowledgeDemo) e executado pelos testes do pacote ([`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)).

### Pesquise nos seus documentos

Adicione documentos com um identificador e metadados opcionais e pesquise no modo híbrido padrão, ou apenas por palavras (`.keyword`) ou apenas por significado (`.semantic`):

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

Adicionar um documento com um identificador existente o substitui, `remove(id:)` o exclui, e `search(_:limit:mode:matching:)` aceita pares de metadados que os resultados precisam ter.

### Responda perguntas com o modelo no dispositivo

No iOS 26 e no macOS 26 com o Apple Intelligence ativado, o modelo do sistema responde com base nos trechos que correspondem à pergunta e os cita como `[1]`, `[2]`, …:

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

Ela lança `AnswerError.noRelevantPassages`, sem consultar o modelo, quando nada corresponde, e `AnswerError.modelUnavailable` quando o Apple Intelligence está desativado ou não é compatível. Para outro modelo, `knowledge.groundedPrompt(for:)` retorna o prompt e suas fontes numeradas.

### Anonimize dados pessoais

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

Passe um redactor para `KnowledgeBase(redactor:)` e apenas trechos anonimizados serão indexados e salvos. A anonimização é uma rede de segurança, não uma garantia: dados escritos por extenso ("jane at example dot com") não são encontrados, e os nomes vêm de um modelo estatístico.

### Pesquise por significado

O `HashingEmbedder` padrão encontra palavras e formas de palavras em comum. O embedding de frases da Apple também encontra palavras relacionadas:

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Os embeddings da Apple são modelos gerais pequenos e o simulador do iOS não os tem; mantenha o modo híbrido padrão, a menos que os seus próprios testes mostrem que a busca somente semântica é melhor para os seus textos.

### Salve e restaure

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

Restaure com o mesmo embedder; um diferente lança `KnowledgeBaseError.embedderMismatch`.

### Analise texto

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## Demonstração

O app de exemplo em um simulador de iPhone, pesquisando, respondendo e anonimizando oito artigos de uma central de ajuda:

| Busca                                                              | Pergunta                                                           | Anonimização                                                              |
| ------------------------------------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------------- |
| ![Tela de busca, modo claro](docs/images/example-search-light.png) | ![Tela de pergunta, modo claro](docs/images/example-ask-light.png) | ![Tela de anonimização, modo claro](docs/images/example-redact-light.png) |
| ![Tela de busca, modo escuro](docs/images/example-search-dark.png) | ![Tela de pergunta, modo escuro](docs/images/example-ask-dark.png) | ![Tela de anonimização, modo escuro](docs/images/example-redact-dark.png) |

A resposta na tela de pergunta é o texto do próprio modelo no dispositivo naquela execução. As capturas de tela são feitas a partir de [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) por [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). Para executar o app, abra `KnowledgeDemo.xcodeproj` no Xcode, escolha um simulador de iPhone ou **My Mac** e pressione **Run**; [Examples/README.md](Examples/README.md) traz os detalhes.

## Documentação

Referência da API e artigos:

- [Referência da API](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/) (DocC, publicada no GitHub Pages a partir de `main`)
- Gere-a localmente no Xcode com **Product › Build Documentation**, ou pela linha de comando:

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## Guias

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted) — adicionar o pacote, indexar e pesquisar, salvar entre execuções, analisar um texto ([código-fonte](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)).
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments) — modos de busca, como escolher um embedder, filtros de metadados e tamanho dos trechos ([código-fonte](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)).
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions) — respostas no dispositivo, prompts para outros modelos, streaming e a ferramenta de busca ([código-fonte](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)).
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata) — os oito tipos, estilos de substituição, como restaurar valores e o que não é detectado ([código-fonte](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)).

## Requisitos

| Plataforma | Versão mínima |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| Ferramentas | Swift 6.2 · Xcode 26+ |

As respostas do modelo no dispositivo exigem iOS 26 ou macOS 26 em um aparelho compatível com o Apple Intelligence, com o Apple Intelligence ativado. O simulador do iOS não tem os modelos de nomes, sentimento e classes gramaticais do NaturalLanguage nem o embedding de frases: nele, `TextAnalyzer` não encontra nomes nem palavras-chave, o redactor não encontra nomes e `SentenceEmbedder` lança um erro. A CI compila com o Xcode padrão da imagem de runner `macos-26` do GitHub; o pacote é desenvolvido com o Xcode 27.

## Arquitetura

- `Text/` — `TextAnalyzer`, `TextChunker` e a normalização de termos compartilhada (unificação de maiúsculas e minúsculas, acentos e largura; limites de palavra do `NLTokenizer`, de modo que chinês e japonês são divididos em palavras).
- `Privacy/` — `PersonalDataRedactor`. Os padrões rodam sobre uma cópia normalizada do texto (`FoldedText`), cujo mapa leva cada ocorrência de volta aos caracteres originais; dígitos verificadores (`Checksums`) confirmam cartões e IBANs; `NSDataDetector` encontra telefones, links e endereços, e `NLTagger` encontra nomes.
- `Embedding/` — o protocolo `TextEmbedder` e suas três implementações.
- `Search/` — `VectorIndex` (busca exata por cosseno com uma única multiplicação de matrizes do Accelerate), `KeywordIndex` (BM25), `RankFusion` e o actor `KnowledgeBase`, que os une e os salva.
- `Generation/` — `GroundedPrompt`, `GroundedAnswer` e, por trás de `canImport(FoundationModels)` e de verificações de disponibilidade, `answer(_:)` e `KnowledgeSearchTool`.

`KnowledgeBase` calcula todos os vetores de um lote antes de alterar qualquer coisa, então um erro de embedding a deixa intacta. Os índices são exatos e ficam na memória: servem para os documentos de um usuário ou de um app, até dezenas de milhares de trechos.

## Roteiro

- Texto de PDFs e imagens (PDFKit e o reconhecedor de texto do Vision) como fontes de documentos.
- Um embedder com codificador de frases Core ML, para uma busca semântica mais forte do que os embeddings integrados da Apple.

## Como contribuir

Contribuições são bem-vindas. Leia o [guia de contribuição](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md) e o [código de conduta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir um pull request. Relate problemas de segurança de forma privada, como descrito na [política de segurança](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
