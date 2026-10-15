# Security Policy

## Supported versions

| Version | Supported |
| --- | --- |
| 2.x | Yes |
| 1.x | No (a different, retired code base) |

## Reporting a vulnerability

Do not open a public issue. Report it privately as described in the
[shared security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md):
through **Report a vulnerability** on this repository's **Security** tab, or by email. Include
the version, the platform, the smallest input that shows the problem (with made-up personal
data) and what you expected. You get a reply within seven days; fixes are released as a patch
version and noted in the [changelog](CHANGELOG.md).

## What counts as a vulnerability here

- **Redaction bypasses**: personal data of a kind that `PersonalDataRedactor` claims to find
  (see the "What it catches" section of the Redacting Personal Data article) that stays
  visible, fully or in part, in `redact(_:)` output or in a `KnowledgeBase` that uses a
  redactor.
- **Crashes or hangs on input**: any public API that traps, or takes time that grows faster
  than linearly with the input, on text, numbers or saved data, including files passed to
  `KnowledgeBase(contentsOf:)`.
- **Restoring values into the wrong place**: `restoringOriginals(in:)` putting a value where
  the redaction did not create its placeholder.

## Known limits (not vulnerabilities)

- Data that is spelled out ("jane at example dot com"), split by ordinary words, or invalid by
  its own rules (a card number with a wrong check digit) is not found.
- Name detection is statistical and may miss names, especially outside English; the iOS
  simulator has no name model.
- A language model can follow instructions written inside your documents. `GroundedPrompt`
  tells the model to treat sources as data, but no prompt guarantees it; do not give a session
  that reads untrusted documents tools that act for the user.
- A saved knowledge base is not encrypted by the package; pass `.completeFileProtection` to
  `save(to:options:)` on iOS, or store it in an encrypted location.
