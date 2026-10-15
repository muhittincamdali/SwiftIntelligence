import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Errors from ``KnowledgeBase/answer(_:limit:mode:matching:model:)``.
public enum AnswerError: Error, Hashable, Sendable {
    /// No passage matches the question, so there is nothing to answer from. The model is not
    /// asked.
    case noRelevantPassages
    /// The on-device model cannot be used, for example because Apple Intelligence is off or
    /// the device does not support it. The value describes the reason.
    case modelUnavailable(String)
}

extension KnowledgeBase {
    /// Searches for `question` and builds a ``GroundedPrompt`` from the results, for any
    /// language model.
    ///
    /// - Throws: ``AnswerError/noRelevantPassages`` when nothing matches.
    public func groundedPrompt(
        for question: String,
        limit: Int = 4,
        mode: SearchMode = .hybrid,
        matching metadata: [String: String] = [:],
        passageBudget: Int = GroundedPrompt.defaultPassageBudget
    ) async throws -> GroundedPrompt {
        let results = try await search(question, limit: limit, mode: mode, matching: metadata)
        guard !results.isEmpty else { throw AnswerError.noRelevantPassages }
        return GroundedPrompt(question: question, results: results, passageBudget: passageBudget)
    }
}

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
extension KnowledgeBase {
    /// Answers `question` with Apple's on-device language model, from the passages that best
    /// match it, and returns the answer with its sources.
    ///
    /// Nothing leaves the device. The model sees only the passages in the prompt, is told to
    /// cite them and to say when they do not contain the answer; check
    /// ``GroundedAnswer/citedSources`` before showing an answer as sourced.
    ///
    /// ```swift
    /// let answer = try await knowledge.answer("How long do I have to return an item?")
    /// print(answer.text)                         // "You can return items within 30 days [1]."
    /// print(answer.citedSources.map(\.documentID)) // ["returns"]
    /// ```
    ///
    /// - Throws: ``AnswerError/noRelevantPassages``, ``AnswerError/modelUnavailable(_:)`` or an
    ///   error from the model, such as exceeding its context size.
    public func answer(
        _ question: String,
        limit: Int = 4,
        mode: SearchMode = .hybrid,
        matching metadata: [String: String] = [:],
        model: SystemLanguageModel = .default
    ) async throws -> GroundedAnswer {
        if case .unavailable(let reason) = model.availability {
            throw AnswerError.modelUnavailable(String(describing: reason))
        }
        let prompt = try await groundedPrompt(for: question, limit: limit, mode: mode, matching: metadata)
        let session = LanguageModelSession(model: model, instructions: GroundedPrompt.instructions)
        let response = try await session.respond(to: prompt.text)
        return GroundedAnswer(text: response.content, sources: prompt.sources)
    }
}

/// A Foundation Models tool that lets a `LanguageModelSession` search a ``KnowledgeBase``
/// on its own, when a conversation needs facts from your documents.
///
/// ```swift
/// let session = LanguageModelSession(
///     tools: [KnowledgeSearchTool(knowledge: knowledge)],
///     instructions: "Answer questions about the store's policies."
/// )
/// let response = try await session.respond(to: "Can I return shoes after three weeks?")
/// ```
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
public struct KnowledgeSearchTool: Tool {
    /// What the model searches for.
    @Generable
    public struct Arguments: Sendable {
        @Guide(description: "A short search query with the key words of what to look up")
        public var query: String
    }

    public let name: String
    public let description: String
    /// The knowledge base to search.
    public let knowledge: KnowledgeBase
    /// The most passages returned per call.
    public let limit: Int

    /// Creates the tool.
    ///
    /// - Parameters:
    ///   - knowledge: The knowledge base to search.
    ///   - name: The tool name the model sees.
    ///   - description: Tells the model when to use the tool; describe your documents.
    ///   - limit: The most passages per call, kept between 1 and 10 so the results fit in the
    ///     model's context.
    public init(
        knowledge: KnowledgeBase,
        name: String = "searchDocuments",
        description: String = "Searches the user's documents and returns the passages that best match a query.",
        limit: Int = 3
    ) {
        self.knowledge = knowledge
        self.name = name
        self.description = description
        self.limit = min(max(1, limit), 10)
    }

    public func call(arguments: Arguments) async throws -> String {
        let results = try await knowledge.search(arguments.query, limit: limit)
        return Self.output(for: results)
    }

    /// The passages as numbered lines, or a sentence saying that nothing matched.
    static func output(for results: [SearchResult]) -> String {
        guard !results.isEmpty else { return "No passage matches this query." }
        return results.enumerated()
            .map { "[\($0.offset + 1)] (\($0.element.documentID)) \(GroundedPrompt.singleLine($0.element.text))" }
            .joined(separator: "\n")
    }
}
#endif
