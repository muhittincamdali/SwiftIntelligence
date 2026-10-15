# Redacting Personal Data

Replace email addresses, phone numbers, card numbers, IBANs and names before text is stored or sent to a model, and put them back in the answer.

## Overview

``PersonalDataRedactor`` finds eight kinds of personal data (``PersonalDataKind``) and
replaces them:

```swift
let redactor = PersonalDataRedactor()
let redacted = redactor.redact("Mail jane@example.com or pay with 4111 1111 1111 1111.")
print(redacted.text)  // "Mail [EMAIL_1] or pay with [CARD_1]."
```

| Kind | Found by |
| --- | --- |
| Email address | pattern with RFC 5321 length limits, Unicode letters allowed |
| Payment card number | 13 to 19 digits that pass the Luhn check |
| IBAN | country code and check digits that pass the ISO 13616 mod-97 check, cut to the country's length |
| IP address | IPv4 and IPv6, confirmed by `inet_pton` |
| Phone number, link, postal address | the system data detector (`NSDataDetector`) |
| Person's name | the NaturalLanguage name tagger |

Card numbers and IBANs must pass their check digits, so order numbers and other long numbers
stay readable.

## Placeholders, tags or a mask

``PersonalDataRedactor/Replacement`` decides what replaces a match:

- ``PersonalDataRedactor/Replacement/placeholder`` (default): `[EMAIL_1]`, `[EMAIL_2]`, … The
  same value always gets the same number, so a model can still tell two people apart.
- ``PersonalDataRedactor/Replacement/tag``: `[EMAIL]`, when the values do not matter.
- ``PersonalDataRedactor/Replacement/mask(_:)``: one character per character, for display.

With placeholders, ``RedactedText/restoringOriginals(in:)`` puts the values back into a
model's answer:

```swift
let reply = redacted.restoringOriginals(in: "I wrote to [EMAIL_1].")
print(reply)  // "I wrote to jane@example.com."
```

The text is read once, so a restored value is never read again as a placeholder, and
placeholders already present in the input keep their numbers free: an input that contains the
literal text "[EMAIL_1]" gets "[EMAIL_2]" for its first address.

## Redact before indexing

Give a ``KnowledgeBase`` a redactor and it stores, indexes and saves only redacted passages;
the original values are not kept:

```swift
let knowledge = KnowledgeBase(redactor: PersonalDataRedactor(replacement: .tag))
```

## What it catches and what it does not

Matching looks at a folded copy of the text and reports the original values and ranges:

- Full-width and other compatibility characters, such as "４１１１" or "ｊａｎｅ＠…", match as
  their plain forms.
- Invisible format characters inside a value (zero-width space, soft hyphen, direction marks)
  are ignored, and the replacement covers them.
- Card numbers and IBANs may be grouped with spaces, tabs, dashes, dots, slashes or
  underscores, or broken over two lines. Card numbers may follow other digit groups such as an
  order number; IBANs may be in upper or lower case and follow each other or a code that looks
  like one.
- Email addresses may use every character RFC 5322 allows before the "@" ("o'brien",
  "first/last"), letters outside the Basic Multilingual Plane ("𠀀"), a quoted local part, up
  to three spaces or tabs or one line break around the "@", up to three spaces or tabs before
  a dot of the domain ("example .com"), ideographic full stops ("example。com") between its
  labels, or an address literal ("jane@[192.0.2.1]") instead of a domain.
- Overlapping matches are merged, so no part of either stays visible.

It does not find data that is spelled out ("jane at example dot com", "four one one one"),
split by ordinary words, or invalid by its own rules (a card number with a wrong check digit).
Names come from a statistical model and are the least reliable kind, especially outside
English, and the iOS simulator has no name model at all. Treat redaction as a safety net that
lowers the amount of personal data in your index and prompts, not as a guarantee.

Every pattern has bounded repetition, so the time to scan a text grows linearly with its
length, whatever the text contains.
