# Contributing

Thanks for taking the time to improve SwiftIntelligence.

## Reporting bugs

Open an issue with:

- the type and method you called, and a short text that shows the problem (replace real
  personal data with made-up values),
- what you expected and what happened,
- platform and OS version (iOS simulator, device or macOS), Xcode version, and whether Apple
  Intelligence is on when the issue is about `answer(_:)`.

A redaction bypass (personal data that stays visible) is a security issue: report it privately
as described in [SECURITY.md](SECURITY.md).

## Pull requests

1. Fork the repository and branch from `main`.
2. Keep each pull request focused on one change.
3. Run the tests on both platforms:

    ```sh
    swift test
    xcodebuild test -scheme SwiftIntelligence \
      -destination 'platform=iOS Simulator,name=iPhone 17'
    ```

    Tests that need a NaturalLanguage model the simulator lacks, or the on-device language
    model, are skipped there with the reason; on macOS the NaturalLanguage models are required.
4. Add or update a test in `Tests/SwiftIntelligenceTests` for every change in behavior. For the
   redactor, add both the value that must be found and a look-alike that must stay readable.
5. Public entry points must not trap on input: check NaN and infinite numbers, sizes read from
   saved data (with overflow-checked arithmetic) and limits, and keep every regular expression
   quantifier bounded.
6. If you change a README code sample, change the copy in
   `Examples/KnowledgeDemo/KnowledgeDemo/ReadmeSamples.swift` as well. That file is what gets
   compiled: by the example app, and by `swift test` through the symlink
   `Tests/SwiftIntelligenceTests/ReadmeSamples.swift`. Build the app with:

    ```sh
    cd Examples/KnowledgeDemo
    xcodebuild build -scheme KnowledgeDemo -destination 'generic/platform=iOS Simulator'
    ```

7. If a change affects the screenshots, capture them again with
   `scripts/capture-example-screens.sh`.

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- The package builds in the Swift 6 language mode; new code should not add warnings.
- Document public API with DocC comments (`///`); `xcodebuild docbuild` should stay free of
  warnings.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).

## License

By contributing you agree that your contributions are licensed under the MIT License.
