<!-- i18n-source: README.md@c3973900c06dd9a898716cff73ecfa521ffe82e0 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/banner-tr-light.svg" alt="SwiftIntelligence: Uygulamanızın metinleri için cihaz üzerinde arama, yanıtlar ve maskeleme, Apple çerçeveleriyle."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftIntelligence/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 18+ · macOS 15+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftIntelligence/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftIntelligence/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

Uygulamanızdaki iOS veya macOS metinlerini cihaz üzerinde aranabilir ve yanıtlanabilir hâle getiren bir Swift paketi. Notları, yardım makalelerini veya mesajları bir `KnowledgeBase`'e ekleyin; ardından bunları sözcüklere ve anlama göre arayın, Apple'ın cihaz üzerindeki modeline sorulara bu metinlerden kaynak göstererek yanıt verdirin ve e-posta adreslerini, kart numaralarını ve diğer kişisel verileri saklanmadan ya da bir modele gönderilmeden önce kaldırın. NaturalLanguage, Accelerate ve Foundation Models üzerine kuruludur, hiçbir bağımlılığı yoktur ve uygulamanız göndermedikçe hiçbir şey cihazdan çıkmaz.

## Öne çıkanlar

- **Hibrit arama** — her pasaj iki kez dizinlenir: sözcükleriyle (BM25) ve bir vektör olarak. İki sıralama reciprocal rank fusion ile birleştirilir; böylece arama hem "E-4012" gibi tam kodları hem de başka sözcükler kullanan pasajları bulur.
- **Kaynaklı yanıtlar** — iOS 26 ve macOS 26'da `answer(_:)`, Apple'ın cihaz üzerindeki modelinden yalnızca en iyi pasajlara dayanarak yanıt vermesini ve bunları kaynak göstermesini ister; `groundedPrompt(for:)` aynı istemi başka herhangi bir model için oluşturur, `KnowledgeSearchTool` ise bir Foundation Models oturumunun kendi kendine arama yapmasını sağlar.
- **Geri alınabilir maskeleme** — sekiz tür kişisel veri, bir modelin hâlâ atıfta bulunabileceği `[EMAIL_1]` gibi yer tutuculara dönüşür; `restoringOriginals(in:)` gerçek değerleri modelin yanıtına geri koyar. Kart numaraları ve IBAN'lar kontrol basamaklarını geçmek zorundadır; tam genişlikli rakamlar, sıfır genişlikli karakterler ve alışılmadık ayırıcılar bir değeri gizleyemez.
- **Üç embedder ya da kendinizinki** — model gerektirmeden her yerde çalışan bir hashing embedder, Apple'ın cümle embedding'i ve Apple'ın bağlamsal embedding'i; bir Core ML ya da sunucu modeli takmak için `TextEmbedder` protokolünü uygulayın.
- **Açılışlar arasında saklanır** — `save(to:)` maskelenmiş pasajları ve vektörlerini tek bir dosyaya yazar; yükleme sırasında embedder ile verinin birbiriyle eşleştiği denetlenir.
- **Test edilmiş** — macOS'ta 149, iPhone simülatöründe 148 Swift Testing testi; maskeleme atlatma girişimlerini, hazırlanmış kayıt dosyalarını, NaN ve taşan girdileri, README'deki her örneği ve kullanılabildiği yerde cihaz üzerindeki modelden alınan bir yanıtı kapsar.

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Bunu pencerenin sağ üstündeki arama alanına yapıştırın. **Dependency Rule** ayarını `2.0.0` sürümünden başlayan **Up to Next Major Version** olarak bırakın, ardından **Add Package**'a tıklayın. Açılan pencerede **SwiftIntelligence** yanından uygulama hedefinizi seçin ve **Add Package**'a yeniden tıklayın.

**2. Modülü içe aktarın**

```swift
import SwiftIntelligence
```

Bu satırı, paketi kullandığınız Swift dosyasının en üstüne koyun.

**3. Kullanın**

Yeni bir Xcode uygulamasında (**File › New › Project… › App**) `ContentView.swift` içindeki her şeyi şununla değiştirin:

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

**Run**'a (⌘R) basın. Uygulama iki metni arar ve en iyi eşleşmeyi gösterir: "You can return any item within 30 days of delivery for a full refund."

## Kurulum

### Swift Package Manager

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/SwiftIntelligence.git
```

Ya da `Package.swift` dosyanızdaki `dependencies` listesine ekleyin:

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

## Kullanım

Aşağıdaki her örnek [örnek uygulama](Examples/KnowledgeDemo) tarafından derlenir ve paket testlerinde ([`ReadmeSamples.swift`](Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift)) çalıştırılır.

### Belgelerinizde arama yapın

Belgeleri bir tanımlayıcı ve isteğe bağlı metadata ile ekleyin, ardından varsayılan hibrit modda arayın; ya da yalnızca sözcüklere (`.keyword`) veya anlama (`.semantic`) göre arayın:

```swift
let knowledge = KnowledgeBase()
try await knowledge.add("You can return any item within 30 days of delivery for a full refund.", id: "returns")
try await knowledge.add("Orders ship within two business days; delivery takes three to five days.", id: "shipping")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

let results = try await knowledge.search("How do I return an item for a refund?")
print(results.first?.documentID ?? "nothing found")  // returns
print(results.first?.text ?? "")                     // You can return any item within 30 days …
```

Var olan bir tanımlayıcıyla belge eklemek onun yerine geçer, `remove(id:)` belgeyi siler, `search(_:limit:mode:matching:)` ise sonuçların taşıması gereken metadata çiftlerini alır.

### Soruları cihaz üzerindeki modelle yanıtlayın

Apple Intelligence'ın açık olduğu iOS 26 ve macOS 26'da sistem modeli, soruyla eşleşen pasajlardan yanıt verir ve bunları `[1]`, `[2]`, … biçiminde kaynak gösterir:

```swift
@available(iOS 26.0, macOS 26.0, *)
func answer(from knowledge: KnowledgeBase) async throws -> GroundedAnswer {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                              // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))    // ["returns"]
    return answer
}
```

Hiçbir şey eşleşmediğinde modele sormadan `AnswerError.noRelevantPassages` fırlatır; Apple Intelligence kapalıysa ya da desteklenmiyorsa `AnswerError.modelUnavailable` fırlatır. Başka bir model için `knowledge.groundedPrompt(for:)` istemi ve numaralı kaynaklarını döndürür.

### Kişisel verileri maskeleyin

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."

// After a model has answered from the redacted text, put the values back.
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)          // "I wrote to jane@example.com."
```

`KnowledgeBase(redactor:)` içine bir redactor verirseniz yalnızca maskelenmiş pasajlar dizinlenir ve kaydedilir. Maskeleme bir güvenlik ağıdır, garanti değildir: yazıyla ifade edilen veriler ("jane at example dot com") bulunmaz ve adlar istatistiksel bir modelden gelir.

### Anlama göre arayın

Varsayılan `HashingEmbedder` ortak sözcükleri ve sözcük biçimlerini eşleştirir. Apple'ın cümle embedding'i ilişkili sözcükleri de eşleştirir:

```swift
let embedder = try SentenceEmbedder(language: .english)
let knowledge = KnowledgeBase(embedder: embedder)
try await knowledge.add("Our support team answers calls from 9 to 5 on weekdays.", id: "hours")
try await knowledge.add("Every laptop comes with a two-year warranty against defects.", id: "warranty")

// No word in common with the warranty text.
let results = try await knowledge.search("Is my computer covered if it breaks?", mode: .semantic)
print(results.first?.documentID ?? "nothing found")  // warranty
```

Apple'ın embedding'leri küçük, genel amaçlı modellerdir ve iOS simülatöründe bulunmaz; kendi testleriniz yalnızca anlama göre aramanın metinleriniz için daha iyi olduğunu göstermedikçe varsayılan hibrit modda kalın.

### Kaydedin ve geri yükleyin

```swift
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
let file = folder.appending(path: "knowledge.plist")
try await knowledge.save(to: file)

// On the next launch:
let restored = try KnowledgeBase(contentsOf: file)
```

Aynı embedder ile geri yükleyin; farklı bir embedder `KnowledgeBaseError.embedderMismatch` fırlatır.

### Metni çözümleyin

```swift
let analysis = TextAnalyzer().analyze("Tim Cook presented the new iPhone in Cupertino. The audience loved it.")
print(analysis.language?.rawValue ?? "unknown")  // "en"
print(analysis.entities.map(\.text))             // ["Tim Cook", "Cupertino"]
print(analysis.sentiment ?? 0)                   // a positive score
```

## Demo

iPhone simülatöründeki örnek uygulama, sekiz yardım merkezi makalesi üzerinde arama yapıyor, yanıt veriyor ve maskeleme yapıyor:

| Ara                                                              | Sor                                                         | Maskele                                                              |
| ---------------------------------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------- |
| ![Arama ekranı, açık tema](docs/images/example-search-light.png) | ![Sor ekranı, açık tema](docs/images/example-ask-light.png) | ![Maskeleme ekranı, açık tema](docs/images/example-redact-light.png) |
| ![Arama ekranı, koyu tema](docs/images/example-search-dark.png)  | ![Sor ekranı, koyu tema](docs/images/example-ask-dark.png)  | ![Maskeleme ekranı, koyu tema](docs/images/example-redact-dark.png)  |

Sor ekranındaki yanıt, o çalıştırmada cihaz üzerindeki modelin kendi ifadesidir. Ekran görüntüleri [`Examples/KnowledgeDemo`](Examples/KnowledgeDemo) uygulamasından [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) ile alınmıştır. Uygulamayı çalıştırmak için Xcode'da `KnowledgeDemo.xcodeproj` dosyasını açın, bir iPhone simülatörü ya da **My Mac** seçin ve **Run**'a basın; ayrıntılar [Examples/README.md](Examples/README.md) dosyasında.

## Dokümantasyon

API başvuru belgeleri ve makaleler:

- [API başvurusu](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/) (DocC, `main` dalından GitHub Pages'e yayımlanır)
- Yerelde Xcode'da **Product › Build Documentation** ile ya da komut satırından derleyin:

```sh
xcodebuild docbuild -scheme SwiftIntelligence -destination 'generic/platform=iOS'
```

## Rehberler

- [Getting Started](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/gettingstarted) — paketi ekleme, dizinleme ve arama, açılışlar arasında kaydetme, bir metni çözümleme ([kaynak](Sources/SwiftIntelligence/SwiftIntelligence.docc/GettingStarted.md)).
- [Searching Documents](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/searchingdocuments) — arama modları, embedder seçimi, metadata filtreleri ve pasaj boyutu ([kaynak](Sources/SwiftIntelligence/SwiftIntelligence.docc/SearchingDocuments.md)).
- [Answering Questions](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/answeringquestions) — cihaz üzerinde yanıtlar, başka modeller için istemler, akış (streaming) ve arama aracı ([kaynak](Sources/SwiftIntelligence/SwiftIntelligence.docc/AnsweringQuestions.md)).
- [Redacting Personal Data](https://muhittincamdali.github.io/SwiftIntelligence/documentation/swiftintelligence/redactingpersonaldata) — sekiz tür, yer tutucu biçimleri, değerleri geri koyma ve yakalanmayanlar ([kaynak](Sources/SwiftIntelligence/SwiftIntelligence.docc/RedactingPersonalData.md)).

## Gereksinimler

| Platform | En düşük sürüm |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| Araç zinciri | Swift 6.2 · Xcode 26+ |

Cihaz üzerindeki modelden yanıt almak için, Apple Intelligence'ı destekleyen bir cihazda iOS 26 veya macOS 26 gerekir ve Apple Intelligence açık olmalıdır. iOS simülatöründe NaturalLanguage'in ad, duygu ve sözcük türü modelleri ile cümle embedding'i yoktur: orada `TextAnalyzer` ad ya da anahtar sözcük bulamaz, redactor ad bulamaz ve `SentenceEmbedder` hata fırlatır. CI, GitHub'ın `macos-26` runner imajındaki varsayılan Xcode ile derler; paket Xcode 27 ile geliştirilmektedir.

## Mimari

- `Text/` — `TextAnalyzer`, `TextChunker` ve ortak terim normalleştirmesi (büyük/küçük harf, aksan ve genişlik katlama; `NLTokenizer` sözcük sınırları kullanıldığı için Çince ve Japonca sözcüklere ayrılır).
- `Privacy/` — `PersonalDataRedactor`. Desenler, metnin katlanmış bir kopyası (`FoldedText`) üzerinde çalışır; bu kopyanın eşlemesi her eşleşmeyi özgün karakterlere geri bağlar. Kontrol basamakları (`Checksums`) kartları ve IBAN'ları doğrular; `NSDataDetector` telefon numaralarını, bağlantıları ve adresleri, `NLTagger` ise adları bulur.
- `Embedding/` — `TextEmbedder` protokolü ve üç uygulaması.
- `Search/` — `VectorIndex` (tek bir Accelerate matris çarpımıyla tam kosinüs araması), `KeywordIndex` (BM25), `RankFusion` ve bunları birbirine bağlayıp kaydeden `KnowledgeBase` actor'ü.
- `Generation/` — `GroundedPrompt`, `GroundedAnswer` ve, `canImport(FoundationModels)` ile kullanılabilirlik denetimlerinin arkasında, `answer(_:)` ile `KnowledgeSearchTool`.

`KnowledgeBase`, bir toplu işlemin tüm vektörlerini herhangi bir şeyi değiştirmeden önce hesaplar; bu yüzden bir embedding hatası onu değiştirmeden bırakır. Dizinler tam (exact) ve bellek içindedir: tek bir kullanıcının ya da tek bir uygulamanın belgelerine, on binlerce pasaja kadar uygundur.

## Yol haritası

- PDF'lerden ve görsellerden metin (PDFKit ve Vision metin tanıyıcı), belge kaynağı olarak.
- Apple'ın yerleşik embedding'lerinden daha güçlü anlamsal arama için Core ML cümle kodlayıcılı bir embedder.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/SwiftIntelligence/blob/main/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
