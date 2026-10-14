import Foundation

/// A kind of personal data that ``PersonalDataRedactor`` can find.
public enum PersonalDataKind: String, Hashable, Sendable, CaseIterable, Codable {
    /// An email address.
    case emailAddress
    /// A phone number in a format the system data detector recognizes.
    case phoneNumber
    /// A web address. Email addresses are reported as ``emailAddress`` instead.
    case link
    /// A street address in a format the system data detector recognizes.
    case postalAddress
    /// A payment card number of 13 to 19 digits that passes the Luhn check.
    case paymentCardNumber
    /// An IBAN that passes the ISO 13616 mod-97 check.
    case iban
    /// An IPv4 or IPv6 address.
    case ipAddress
    /// A person's name, found by the NaturalLanguage name tagger.
    case personName

    /// The uppercase tag used in redacted text, for example `EMAIL`.
    public var tag: String {
        switch self {
        case .emailAddress: "EMAIL"
        case .phoneNumber: "PHONE"
        case .link: "LINK"
        case .postalAddress: "ADDRESS"
        case .paymentCardNumber: "CARD"
        case .iban: "IBAN"
        case .ipAddress: "IP"
        case .personName: "NAME"
        }
    }
}

/// One piece of personal data found in a text.
public struct PersonalDataMatch: Hashable, Sendable {
    /// What kind of data it is.
    public let kind: PersonalDataKind
    /// The data as it appears in the text.
    public let value: String
    /// Where it is in the scanned string.
    public let range: Range<String.Index>

    public init(kind: PersonalDataKind, value: String, range: Range<String.Index>) {
        self.kind = kind
        self.value = value
        self.range = range
    }
}

/// Text with its personal data replaced, and what was replaced.
public struct RedactedText: Hashable, Sendable {
    /// The text with every match replaced.
    public let text: String
    /// The matches, in order of appearance in the original text.
    public let matches: [PersonalDataMatch]
    /// The original value behind each placeholder, for ``PersonalDataRedactor/Replacement/placeholder``.
    /// Empty for the other replacement styles, which cannot be reversed.
    public let originals: [String: String]

    public init(text: String, matches: [PersonalDataMatch], originals: [String: String]) {
        self.text = text
        self.matches = matches
        self.originals = originals
    }

    /// Puts the original values back into `text`, for example into a model's answer that
    /// quotes a placeholder such as `[EMAIL_1]`.
    public func restoringOriginals(in text: String) -> String {
        originals.keys.sorted { $0.count > $1.count }.reduce(text) { result, placeholder in
            result.replacingOccurrences(of: placeholder, with: originals[placeholder]!)
        }
    }
}
