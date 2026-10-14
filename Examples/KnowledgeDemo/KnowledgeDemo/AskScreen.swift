import SwiftIntelligence
import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Answers a question from the articles with the on-device model, or shows the grounded prompt
/// when the model is not available.
struct AskScreen: View {
    let library: DemoLibrary
    @State private var question = "How long do I have to return a laptop?"
    @State private var answer: GroundedAnswer?
    @State private var prompt: GroundedPrompt?
    @State private var message: String?
    @State private var isWorking = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField("Question", text: $question, axis: .vertical)
                        .lineLimit(2...4)
                    Button(isWorking ? "Answering…" : "Ask", action: ask)
                        .disabled(isWorking || !library.isReady)
                }
                if let answer {
                    Section("Answer") {
                        Text(answer.text)
                    }
                    Section("Cited sources") {
                        ForEach(answer.citedSources) { source in
                            LabeledContent(DemoLibrary.title(of: source.documentID), value: source.text)
                        }
                    }
                }
                if let message {
                    Section("On-device model") {
                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                }
                if answer == nil, let prompt {
                    Section("Prompt for any model") {
                        Text(prompt.text)
                            .font(.caption.monospaced())
                    }
                }
            }
            .navigationTitle("Ask")
            .task(id: library.isReady) {
                if library.isReady, answer == nil, prompt == nil { ask() }
            }
        }
    }

    private func ask() {
        isWorking = true
        Task {
            defer { isWorking = false }
            do {
                prompt = try await library.knowledge.groundedPrompt(for: question)
                answer = try await answerWithSystemModel()
                message = answer == nil ? "Apple Intelligence is not available here (it needs iOS 26 or macOS 26 on a supported device), so only the prompt is shown." : nil
            } catch AnswerError.noRelevantPassages {
                answer = nil
                prompt = nil
                message = "No article matches the question."
            } catch AnswerError.modelUnavailable(let reason) {
                answer = nil
                message = "The on-device model is unavailable: \(reason)."
            } catch {
                answer = nil
                message = error.localizedDescription
            }
        }
    }

    private func answerWithSystemModel() async throws -> GroundedAnswer? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            return try await library.knowledge.answer(question)
        }
        #endif
        return nil
    }
}
