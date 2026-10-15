# Examples

## KnowledgeDemo

A small iOS and macOS app that runs the package on eight help-center articles:

- **Search**: semantic, keyword and hybrid ranking of the articles, with the scores.
- **Ask**: an answer from Apple's on-device model with the cited articles. Where the model is
  not available (Apple Intelligence off, an unsupported device, or iOS 18 and macOS 15) the
  screen shows the grounded prompt instead, which you can send to any model.
- **Redact**: personal data replaced while you type, with placeholders, tags or a mask.
- **Analyze**: language, sentiment, names and keywords of a text.

It uses the package from this checkout (a local package reference to `../..`), so it always
shows the current code. It searches with Apple's sentence embedding where the system has it and
with the hashing embedder elsewhere; the search screen names the one in use.

Run it:

1. Open `Examples/KnowledgeDemo/KnowledgeDemo.xcodeproj` in Xcode 26 or later.
2. Choose the **KnowledgeDemo** scheme and an iPhone simulator or **My Mac** as the run
   destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/KnowledgeDemo
xcodebuild build -scheme KnowledgeDemo -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme KnowledgeDemo -destination 'platform=macOS'
```

The iOS simulator has no NaturalLanguage name, sentiment or part-of-speech models, so the
Analyze screen shows dashes there and the redactor finds no names; run on a Mac or a device to
see them. The on-device language model works in the simulator when the Mac running it has Apple
Intelligence turned on.

The README samples live in
[`KnowledgeDemo/ReadmeSamples.swift`](KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift). The
README copies its code from that file, and the package's test target runs the same file through
the symlink `Tests/SwiftIntelligenceTests/ReadmeSamples.swift`.

The README screenshots are taken from this app by
[`scripts/capture-example-screens.sh`](../scripts/capture-example-screens.sh).

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](KnowledgeDemo/project.yml) and committed, so you only need XcodeGen after
editing `project.yml`.
