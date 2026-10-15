<!-- i18n-source: README.md@44ff211be1e0a00ecd38c72c7a00a2edff6bbf8a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-ru-light.svg" alt="SwiftIntelligence: Поиск, ответы и маскирование данных на устройстве для текстов вашего приложения на фреймворках Apple."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

Swift-пакет, который делает тексты в вашем приложении для iOS или macOS доступными для поиска и ответов прямо на устройстве. Добавьте заметки, статьи справки или сообщения в `KnowledgeBase`, ищите по ним по словам и по смыслу, поручите модели Apple на устройстве отвечать на вопросы по этим текстам со ссылками на источники и удаляйте адреса электронной почты, номера карт и другие персональные данные до того, как что-либо будет сохранено или отправлено модели. Пакет построен на NaturalLanguage, Accelerate и Foundation Models, не имеет зависимостей, и ничто не покидает устройство, если этого не сделает ваше приложение.

## Основные возможности

- **Гибридный поиск** — каждый фрагмент индексируется дважды: по словам (BM25) и как вектор. Два ранжирования объединяются методом reciprocal rank fusion, поэтому поиск находит и точные коды вроде «E-4012», и фрагменты, где использованы другие слова.
- **Ответы с источниками** — в iOS 26 и macOS 26 `answer(_:)` просит модель Apple на устройстве отвечать только по лучшим фрагментам и ссылаться на них; `groundedPrompt(for:)` собирает такой же промпт для любой другой модели, а `KnowledgeSearchTool` позволяет сессии Foundation Models искать самостоятельно.
- **Маскирование с возможностью отката** — восемь видов персональных данных превращаются в метки вроде `[EMAIL_1]`, на которые модель по-прежнему может ссылаться, а `restoringOriginals(in:)` возвращает исходные значения в её ответ. Номера карт и IBAN должны проходить проверку контрольных цифр, а полноширинные цифры, символы нулевой ширины и группы, разделённые пробелами, табуляциями, дефисами, точками, косыми чертами, подчёркиваниями или одним переводом строки, не скрывают значение.
- **Три embedder или ваш собственный** — hashing embedder, который работает везде без модели, векторные представления предложений от Apple и контекстные представления от Apple; реализуйте `TextEmbedder`, чтобы подключить модель Core ML или серверную модель.
- **Сохранение между запусками** — `save(to:)` записывает в один файл замаскированные фрагменты и их векторы, а при загрузке проверяется, что embedder и данные совпадают.
- **Протестировано** — 156 тестов Swift Testing на macOS и 155 на симуляторе iPhone; они покрывают попытки обойти маскирование, подделанные файлы сохранения, входные данные с NaN и переполнением, каждый пример из README и ответ модели на устройстве там, где она доступна.

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Вставьте его в поле поиска в правом верхнем углу окна. Оставьте **Dependency Rule** в положении **Up to Next Major Version** начиная с `2.0.0` и нажмите **Add Package**. В следующем окне выберите таргет вашего приложения напротив **SwiftIntelligence** и снова нажмите **Add Package**.

**2. Импортируйте модуль**

```swift
import SwiftIntelligence
```

Поставьте эту строку в начало Swift-файла, где вы используете пакет.

**3. Используйте**

В новом приложении Xcode (**File › New › Project… › App**) замените всё содержимое `ContentView.swift` следующим:

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

Нажмите **Run** (⌘R). Приложение выполнит поиск по двум текстам и покажет лучшее совпадение: «You can return any item within 30 days of delivery for a full refund.»

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

## Использование

Каждый пример ниже компилируется [приложением-примером](Examples/KnowledgeDemo) и запускается тестами пакета ([`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)).

### Поиск по документам

Добавляйте документы с идентификатором и необязательными метаданными, а затем ищите в гибридном режиме по умолчанию либо только по словам (`.keyword`) или только по смыслу (`.semantic`):

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

Добавление документа с уже существующим идентификатором заменяет его, `remove(id:)` удаляет документ, а `search(_:limit:mode:matching:)` принимает пары метаданных, которые должны быть у результатов.

### Ответы на вопросы с помощью модели на устройстве

В iOS 26 и macOS 26 при включённом Apple Intelligence системная модель отвечает по фрагментам, подходящим к вопросу, и ссылается на них как `[1]`, `[2]`, …:

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

Если ничего не подошло, она выбрасывает `AnswerError.noRelevantPassages`, не обращаясь к модели, а если Apple Intelligence выключен или не поддерживается — `AnswerError.modelUnavailable`. Для другой модели `knowledge.groundedPrompt(for:)` возвращает промпт и его пронумерованные источники.

### Маскирование персональных данных

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

Передайте redactor в `KnowledgeBase(redactor:)`, и индексироваться и сохраняться будут только замаскированные фрагменты. Маскирование — это страховка, а не гарантия: данные, записанные словами («jane at example dot com»), не находятся, а имена определяет статистическая модель.

### Поиск по смыслу

`HashingEmbedder` по умолчанию сопоставляет общие слова и их формы. Векторные представления предложений от Apple сопоставляют и родственные слова:

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Встроенные представления Apple — это небольшие универсальные модели, и в симуляторе iOS их нет; оставайтесь в гибридном режиме по умолчанию, если только ваши собственные тесты не покажут, что один лишь семантический поиск лучше подходит для ваших текстов.

### Сохранение и восстановление

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

Восстанавливайте с тем же embedder; другой выбросит `KnowledgeBaseError.embedderMismatch`.

### Анализ текста

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## Демо

Приложение-пример в симуляторе iPhone ищет по восьми статьям справочного центра, отвечает на вопросы и маскирует данные:

| Поиск                                                               | Вопрос                                                            | Маскирование                                                              |
| ------------------------------------------------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------- |
| ![Экран поиска, светлая тема](docs/images/example-search-light.png) | ![Экран вопроса, светлая тема](docs/images/example-ask-light.png) | ![Экран маскирования, светлая тема](docs/images/example-redact-light.png) |
| ![Экран поиска, тёмная тема](docs/images/example-search-dark.png)   | ![Экран вопроса, тёмная тема](docs/images/example-ask-dark.png)   | ![Экран маскирования, тёмная тема](docs/images/example-redact-dark.png)   |

Ответ на экране вопроса — это формулировка самой модели на устройстве в том запуске. Скриншоты снимаются из [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) скриптом [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). Чтобы запустить приложение, откройте `KnowledgeDemo.xcodeproj` в Xcode, выберите симулятор iPhone или **My Mac** и нажмите **Run**; подробности — в [Examples/README.md](Examples/README.md).

## Документация

Справочник API и статьи:

- [Справочник API](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/) (DocC, публикуется на GitHub Pages из ветки `main`)
- Соберите его локально в Xcode через **Product › Build Documentation** или из командной строки:

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## Руководства

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted) — добавление пакета, индексирование и поиск, сохранение между запусками, анализ текста ([исходник](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)).
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments) — режимы поиска, выбор embedder, фильтры по метаданным и размер фрагмента ([исходник](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)).
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions) — ответы на устройстве, промпты для других моделей, потоковая выдача и инструмент поиска ([исходник](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)).
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata) — восемь видов, стили подстановки, восстановление значений и то, что не распознаётся ([исходник](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)).

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| Инструменты | Swift 6.2 · Xcode 26+ |

Для ответов модели на устройстве нужны iOS 26 или macOS 26 на устройстве, поддерживающем Apple Intelligence, при включённом Apple Intelligence. В симуляторе iOS нет моделей NaturalLanguage для имён, тональности и частей речи, а также векторных представлений предложений: там `TextAnalyzer` не находит имён и ключевых слов, redactor не находит имён, а `SentenceEmbedder` выбрасывает ошибку. CI собирает проект с Xcode по умолчанию из образа раннера GitHub `macos-26`; сам пакет разрабатывается в Xcode 27.

## Архитектура

- `Text/` — `TextAnalyzer`, `TextChunker` и общая нормализация терминов (приведение регистра, диакритики и ширины символов; границы слов по `NLTokenizer`, поэтому китайский и японский текст делится на слова).
- `Privacy/` — `PersonalDataRedactor`. Шаблоны применяются к нормализованной копии текста (`FoldedText`), а её карта возвращает каждое совпадение к исходным символам; контрольные цифры (`Checksums`) подтверждают карты и IBAN; `NSDataDetector` находит номера телефонов, ссылки и адреса, а `NLTagger` — имена.
- `Embedding/` — протокол `TextEmbedder` и три его реализации.
- `Search/` — `VectorIndex` (точный поиск по косинусной близости с одним умножением матриц в Accelerate), `KeywordIndex` (BM25), `RankFusion` и actor `KnowledgeBase`, который связывает их и сохраняет.
- `Generation/` — `GroundedPrompt`, `GroundedAnswer` и, за проверками `canImport(FoundationModels)` и доступности, `answer(_:)` и `KnowledgeSearchTool`.

`KnowledgeBase` вычисляет все векторы партии документов, прежде чем что-либо изменить, поэтому ошибка embedding оставляет её без изменений. Индексы точные и хранятся в памяти: они подходят для документов одного пользователя или одного приложения, до десятков тысяч фрагментов.

## План развития

- Текст из PDF и изображений (PDFKit и распознавание текста Vision) в качестве источников документов.
- Embedder на основе кодировщика предложений Core ML для более сильного семантического поиска, чем встроенные представления Apple.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
