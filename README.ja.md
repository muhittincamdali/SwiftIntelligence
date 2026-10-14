<!-- i18n-source: README.md@c3973900c06dd9a898716cff73ecfa521ffe82e0 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ja-light.svg" alt="SwiftIntelligence: Apple のフレームワークで、アプリのテキストをデバイス上で検索・回答・マスキング。"></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

iOS や macOS アプリ内のテキストを、デバイス上で検索でき、質問にも答えられるようにする Swift パッケージです。メモ、ヘルプ記事、メッセージを `KnowledgeBase` に追加すると、単語や意味で検索できます。Apple のオンデバイスモデルに、それらの内容から引用付きで質問に答えさせることもできます。さらに、データを保存したりモデルに送ったりする前に、メールアドレス、カード番号などの個人データを取り除けます。NaturalLanguage、Accelerate、Foundation Models の上に構築されていて、依存関係はなく、アプリが送信しない限りデータがデバイスの外に出ることはありません。

## 主な特長

- **ハイブリッド検索** — すべてのパッセージは、単語（BM25）とベクトルの 2 通りで索引付けされます。2 つの順位は reciprocal rank fusion で統合されるため、"E-4012" のような正確なコードも、別の言葉で書かれたパッセージも見つかります。
- **出典付きの回答** — iOS 26 と macOS 26 では、`answer(_:)` が Apple のオンデバイスモデルに、最も関連するパッセージだけを根拠に答え、出典を示すよう依頼します。`groundedPrompt(for:)` は他のモデル向けに同じプロンプトを作り、`KnowledgeSearchTool` を使うと Foundation Models のセッションが自分で検索できます。
- **元に戻せるマスキング** — 8 種類の個人データが `[EMAIL_1]` のようなプレースホルダーに置き換わります。モデルはそれを参照でき、`restoringOriginals(in:)` が元の値を回答に戻します。カード番号と IBAN はチェックディジットに通らなければならず、全角数字、ゼロ幅文字、珍しい区切り文字を使っても値は隠せません。
- **3 つの embedder、または独自のもの** — モデルなしでどこでも動く hashing embedder、Apple の文埋め込み、Apple のコンテキスト埋め込み。`TextEmbedder` に準拠すれば、Core ML やサーバー上のモデルも組み込めます。
- **起動をまたいで保存** — `save(to:)` はマスキング済みのパッセージとそのベクトルを 1 つのファイルに書き出し、読み込み時には embedder とデータが一致するか確認します。
- **テスト済み** — macOS で 149 個、iPhone シミュレーターで 148 個の Swift Testing テストがあり、マスキングの回避の試み、細工された保存ファイル、NaN やオーバーフローする入力、README のすべてのサンプル、そして利用できる環境ではオンデバイスモデルによる回答を対象にしています。

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

ウィンドウ右上の検索欄に貼り付けます。**Dependency Rule** は `2.0.0` からの **Up to Next Major Version** のままにして、**Add Package** をクリックします。次のウィンドウで **SwiftIntelligence** の横にアプリのターゲットを選び、もう一度 **Add Package** をクリックします。

**2. モジュールをインポートする**

```swift
import SwiftIntelligence
```

パッケージを使う Swift ファイルの先頭に、この行を置きます。

**3. 使ってみる**

新しい Xcode アプリ（**File › New › Project… › App**）で、`ContentView.swift` の中身をすべて次の内容に置き換えます。

```swift
import SwiftUI
import SwiftIntelligence

struct ContentView: View {
    @State private var answer = "Searching…"

    var body: some View {
        Text(answer)
            .padding()
            .task {
                do {
                    let knowledge = KnowledgeBase()
                    try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
                    try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")
                    let results = try await knowledge.search("How do I return an item for a refund?")
                    answer = results.first?.text ?? "Nothing found"
                } catch {
                    answer = "Search failed: \(error)"
                }
            }
    }
}
```

**Run**（⌘R）を押します。アプリが 2 つのテキストを検索し、最も一致したものを表示します："You can return any item within 30 days of delivery for a full refund."

## インストール

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

または、`Package.swift` の `dependencies` に追加します。

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

## 使い方

以下のサンプルはすべて、[サンプルアプリ](Examples/KnowledgeDemo)でコンパイルされ、パッケージのテスト（[`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)）で実行されています。

### ドキュメントを検索する

識別子と、必要に応じてメタデータを付けてドキュメントを追加し、既定のハイブリッドモードで検索します。単語だけ（`.keyword`）、または意味だけ（`.semantic`）で検索することもできます。

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

既存の識別子でドキュメントを追加すると置き換えられ、`remove(id:)` で削除できます。`search(_:limit:mode:matching:)` には、結果が持っていなければならないメタデータのペアを渡せます。

### オンデバイスモデルで質問に答える

Apple Intelligence をオンにした iOS 26 と macOS 26 では、システムモデルが質問に一致するパッセージから回答し、`[1]`、`[2]`、… の形で出典を示します。

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

一致するものがなければ、モデルに問い合わせずに `AnswerError.noRelevantPassages` を投げます。Apple Intelligence がオフ、または非対応の場合は `AnswerError.modelUnavailable` を投げます。他のモデルを使う場合は、`knowledge.groundedPrompt(for:)` がプロンプトと番号付きの出典を返します。

### 個人データをマスキングする

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

`KnowledgeBase(redactor:)` に redactor を渡すと、マスキング済みのパッセージだけが索引付けされ、保存されます。マスキングは安全網であり、保証ではありません。文字で書き表されたデータ（"jane at example dot com"）は検出されず、人名は統計モデルによるものです。

### 意味で検索する

既定の `HashingEmbedder` は、共通する単語と語形を照合します。Apple の文埋め込みは、関連する単語も照合します。

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Apple の埋め込みは小さな汎用モデルで、iOS シミュレーターにはありません。自分たちのテストで、意味検索だけの方がテキストに合うと確認できない限り、既定のハイブリッドモードのままにしてください。

### 保存と復元

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

復元には同じ embedder を使ってください。異なる embedder では `KnowledgeBaseError.embedderMismatch` を投げます。

### テキストを分析する

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## デモ

iPhone シミュレーター上のサンプルアプリが、8 件のヘルプセンター記事を検索し、回答し、マスキングしています。

| 検索                                                        | 質問                                                     | マスキング                                                        |
| ----------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------- |
| ![検索画面（ライト）](docs/images/example-search-light.png) | ![質問画面（ライト）](docs/images/example-ask-light.png) | ![マスキング画面（ライト）](docs/images/example-redact-light.png) |
| ![検索画面（ダーク）](docs/images/example-search-dark.png)  | ![質問画面（ダーク）](docs/images/example-ask-dark.png)  | ![マスキング画面（ダーク）](docs/images/example-redact-dark.png)  |

質問画面の回答は、その実行時のオンデバイスモデル自身の表現です。スクリーンショットは [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) で [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) から取得しています。アプリを実行するには、Xcode で `KnowledgeDemo.xcodeproj` を開き、iPhone シミュレーターまたは **My Mac** を選んで **Run** を押してください。詳しくは [Examples/README.md](Examples/README.md) を参照してください。

## ドキュメント

API リファレンスと解説記事：

- [API リファレンス](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/)（DocC。`main` から GitHub Pages に公開）
- ローカルでは、Xcode の **Product › Build Documentation** で、またはコマンドラインからビルドできます。

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## ガイド

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted) — パッケージの追加、索引付けと検索、起動をまたぐ保存、テキストの分析（[ソース](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)）。
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments) — 検索モード、embedder の選び方、メタデータによる絞り込み、パッセージのサイズ（[ソース](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)）。
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions) — オンデバイスの回答、他のモデル向けのプロンプト、ストリーミング、検索ツール（[ソース](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)）。
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata) — 8 つの種類、置換スタイル、値の復元、検出されないもの（[ソース](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)）。

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| ツールチェーン | Swift 6.2 · Xcode 26+ |

オンデバイスモデルによる回答には、Apple Intelligence に対応したデバイスで iOS 26 または macOS 26 を使い、Apple Intelligence をオンにする必要があります。iOS シミュレーターには、NaturalLanguage の人名・感情・品詞のモデルと文埋め込みがありません。そのため、シミュレーターでは `TextAnalyzer` が人名やキーワードを見つけられず、redactor も人名を見つけられず、`SentenceEmbedder` はエラーを投げます。CI は GitHub の `macos-26` ランナーイメージの既定の Xcode でビルドします。パッケージ自体は Xcode 27 で開発しています。

## アーキテクチャ

- `Text/` — `TextAnalyzer`、`TextChunker`、そして共通の用語の正規化（大文字小文字、アクセント、全角半角の統一。`NLTokenizer` の単語境界を使うので、中国語と日本語も単語に分かれます）。
- `Privacy/` — `PersonalDataRedactor`。パターンは、テキストを正規化したコピー（`FoldedText`）に対して実行され、そのマップが一致箇所を元の文字に結び付けます。チェックディジット（`Checksums`）でカードと IBAN を確認し、電話番号、リンク、住所は `NSDataDetector` が、人名は `NLTagger` が見つけます。
- `Embedding/` — `TextEmbedder` プロトコルと、その 3 つの実装。
- `Search/` — `VectorIndex`（Accelerate の行列積 1 回で行う正確なコサイン検索）、`KeywordIndex`（BM25）、`RankFusion`、そしてそれらをまとめて保存する `KnowledgeBase` actor。
- `Generation/` — `GroundedPrompt`、`GroundedAnswer`、そして `canImport(FoundationModels)` と利用可否のチェックの内側にある `answer(_:)` と `KnowledgeSearchTool`。

`KnowledgeBase` は、何かを変更する前にバッチ内のすべてのベクトルを計算するので、埋め込みでエラーが起きても状態は変わりません。索引は正確なもので、メモリ上に置かれます。1 人のユーザーまたは 1 つのアプリのドキュメント、数万パッセージまでに向いています。

## ロードマップ

- PDF や画像からのテキスト（PDFKit と Vision のテキスト認識）を、ドキュメントの取り込み元として追加する。
- Apple 内蔵の埋め込みより強力な意味検索のために、Core ML の文エンコーダーを使う embedder を追加する。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md)と[行動規範](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
