<!-- i18n-source: README.md@44ff211be1e0a00ecd38c72c7a00a2edff6bbf8a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-zh-CN-light.svg" alt="SwiftIntelligence: 基于 Apple 框架，为应用中的文本提供设备端搜索、问答和脱敏。"></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="最新版本: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

这是一个 Swift 软件包，让 iOS 或 macOS 应用中的文本可以在设备上被搜索和用来回答问题。将笔记、帮助文章或消息添加到 `KnowledgeBase`，即可按字词和语义搜索它们，让 Apple 的设备端模型基于这些内容回答问题并给出引用，还能在数据被存储或发送给模型之前，去除其中的电子邮件地址、银行卡号等个人数据。它基于 NaturalLanguage、Accelerate 和 Foundation Models 构建，没有任何依赖；除非你的应用主动发送，否则不会有任何内容离开设备。

## 亮点

- **混合搜索**：每个段落会被索引两次，一次按字词（BM25），一次作为向量，再用 reciprocal rank fusion 合并两种排序，因此搜索既能找到 "E-4012" 这样的精确编号，也能找到用其他词语表达同一意思的段落。
- **带来源的回答**：在 iOS 26 和 macOS 26 上，`answer(_:)` 会让 Apple 的设备端模型只根据最相关的段落作答并标注引用；`groundedPrompt(for:)` 可为任何其他模型生成同样的提示词，`KnowledgeSearchTool` 则让 Foundation Models 会话自行搜索。
- **可还原的脱敏**：八类个人数据会变成 `[EMAIL_1]` 这样的占位符，模型仍然可以引用它们，而 `restoringOriginals(in:)` 会把原始值放回模型的回答中。银行卡号和 IBAN 必须通过校验位检查，全角数字、零宽字符，以及用空格、制表符、连字符、点、斜杠、下划线或一个换行分隔的数字组，也无法掩盖一个值。
- **三种 embedder，也可以用自己的**：无需模型、随处可用的 hashing embedder，Apple 的句子 embedding，以及 Apple 的上下文 embedding；遵循 `TextEmbedder` 协议即可接入 Core ML 模型或服务器端模型。
- **跨启动保存**：`save(to:)` 会把脱敏后的段落及其向量写入同一个文件，加载时会检查 embedder 与数据是否匹配。
- **经过测试**：macOS 上有 156 个、iPhone 模拟器上有 155 个 Swift Testing 测试，覆盖脱敏绕过尝试、构造的存档文件、NaN 和溢出的输入、README 中的每个示例，以及在可用时来自设备端模型的回答。

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

将它粘贴到窗口右上角的搜索框中。保持 **Dependency Rule** 为从 `2.0.0` 起的 **Up to Next Major Version**，然后点击 **Add Package**。在接下来的窗口中，在 **SwiftIntelligence** 旁选择你的应用 target，再次点击 **Add Package**。

**2. 导入模块**

```swift
import SwiftIntelligence
```

把这一行放在使用该软件包的 Swift 文件顶部。

**3. 开始使用**

在新建的 Xcode 应用中（**File › New › Project… › App**），将 `ContentView.swift` 的全部内容替换为：

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

按下 **Run**（⌘R）。应用会搜索这两段文本，并显示最匹配的一条："You can return any item within 30 days of delivery for a full refund."

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

或者将它添加到 `Package.swift` 的 `dependencies` 中：

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

## 使用方法

下面的每个示例都由[示例应用](Examples/KnowledgeDemo)编译，并由软件包的测试运行（[`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)）。

### 搜索你的文档

添加文档时需要提供标识符，也可以附带元数据；之后可以用默认的混合模式搜索，或者只按字词（`.keyword`）或只按语义（`.semantic`）搜索：

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

用已有的标识符添加文档会替换原文档，`remove(id:)` 会删除文档，`search(_:limit:mode:matching:)` 可接收元数据键值对，结果必须包含这些键值对。

### 用设备端模型回答问题

在开启 Apple Intelligence 的 iOS 26 和 macOS 26 上，系统模型会根据与问题匹配的段落作答，并以 `[1]`、`[2]`、… 的形式标注引用：

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

没有任何匹配时，它会在不询问模型的情况下抛出 `AnswerError.noRelevantPassages`；Apple Intelligence 未开启或设备不支持时，会抛出 `AnswerError.modelUnavailable`。若要使用其他模型，`knowledge.groundedPrompt(for:)` 会返回提示词及其带编号的来源。

### 对个人数据脱敏

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

把 redactor 传给 `KnowledgeBase(redactor:)`，就只会索引和保存脱敏后的段落。脱敏是一道保险，而不是保证：用文字拼写出来的数据（"jane at example dot com"）不会被发现，人名则来自统计模型。

### 按语义搜索

默认的 `HashingEmbedder` 匹配相同的字词和词形。Apple 的句子 embedding 还能匹配相关的词：

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Apple 的 embedding 是体积较小的通用模型，iOS 模拟器上没有；除非你自己的测试表明单独使用语义搜索对你的文本更好，否则请保持默认的混合模式。

### 保存与恢复

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

请使用相同的 embedder 恢复；使用不同的 embedder 会抛出 `KnowledgeBaseError.embedderMismatch`。

### 分析文本

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## 演示

iPhone 模拟器上的示例应用，正在对八篇帮助中心文章进行搜索、回答和脱敏：

| 搜索                                                    | 提问                                                 | 脱敏                                                    |
| ------------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------- |
| ![搜索界面，浅色](docs/images/example-search-light.png) | ![提问界面，浅色](docs/images/example-ask-light.png) | ![脱敏界面，浅色](docs/images/example-redact-light.png) |
| ![搜索界面，深色](docs/images/example-search-dark.png)  | ![提问界面，深色](docs/images/example-ask-dark.png)  | ![脱敏界面，深色](docs/images/example-redact-dark.png)  |

提问界面中的回答是设备端模型在那次运行中自己的措辞。截图由 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) 从 [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) 中捕获。要运行该应用，请在 Xcode 中打开 `KnowledgeDemo.xcodeproj`，选择一个 iPhone 模拟器或 **My Mac**，然后按下 **Run**；详情见 [Examples/README.md](Examples/README.md)。

## 文档

API 参考文档与文章：

- [API 参考](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/)（DocC，从 `main` 发布到 GitHub Pages）
- 在 Xcode 中通过 **Product › Build Documentation** 在本地构建，或使用命令行：

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## 指南

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted)：添加软件包、建立索引与搜索、跨启动保存、分析文本（[源文件](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)）。
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments)：搜索模式、选择 embedder、元数据过滤和段落大小（[源文件](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)）。
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions)：设备端回答、面向其他模型的提示词、流式输出和搜索工具（[源文件](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)）。
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata)：八种类型、替换样式、还原原始值，以及哪些内容不会被识别（[源文件](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)）。

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| 工具链 | Swift 6.2 · Xcode 26+ |

使用设备端模型回答，需要在支持 Apple Intelligence 的设备上运行 iOS 26 或 macOS 26，并开启 Apple Intelligence。iOS 模拟器缺少 NaturalLanguage 的人名、情感和词性模型以及句子 embedding：在模拟器上，`TextAnalyzer` 找不到人名或关键词，redactor 找不到人名，`SentenceEmbedder` 会抛出错误。CI 使用 GitHub 的 `macos-26` runner 镜像自带的默认 Xcode 构建；该软件包使用 Xcode 27 开发。

## 架构

- `Text/`：`TextAnalyzer`、`TextChunker` 以及共用的词项规范化（大小写、重音和宽度折叠；使用 `NLTokenizer` 的词边界，因此中文和日文会被切分成词）。
- `Privacy/`：`PersonalDataRedactor`。匹配规则在文本的折叠副本（`FoldedText`）上运行，其映射表会把每个匹配结果对应回原始字符；校验位（`Checksums`）用于确认银行卡号和 IBAN；`NSDataDetector` 负责识别电话号码、链接和地址，`NLTagger` 负责识别人名。
- `Embedding/`：`TextEmbedder` 协议及其三种实现。
- `Search/`：`VectorIndex`（用一次 Accelerate 矩阵乘法完成精确的余弦搜索）、`KeywordIndex`（BM25）、`RankFusion`，以及把它们串联并负责保存的 `KnowledgeBase` actor。
- `Generation/`：`GroundedPrompt`、`GroundedAnswer`，以及位于 `canImport(FoundationModels)` 和可用性检查之后的 `answer(_:)` 与 `KnowledgeSearchTool`。

`KnowledgeBase` 会先算出一批文档的全部向量，再修改任何内容，因此 embedding 出错时它保持不变。索引是精确的，并且保存在内存中：适合单个用户或单个应用的文档，规模可达数万个段落。

## 路线图

- 将 PDF 和图片中的文字（PDFKit 与 Vision 文字识别）作为文档来源。
- 增加基于 Core ML 句子编码器的 embedder，提供比 Apple 内置 embedding 更强的语义搜索。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
