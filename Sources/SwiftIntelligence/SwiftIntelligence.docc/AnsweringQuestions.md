# Answering Questions

Answer from your documents with Apple's on-device model, or build the same prompt for any other model.

## Overview

Retrieval-augmented generation in three steps: search the knowledge base, put the best
passages in a prompt, and let a language model answer from them. On iOS 26 and macOS 26 with
Apple Intelligence on, ``KnowledgeBase/answer(_:limit:mode:matching:model:)`` does all three
with the system model. Nothing leaves the device.

```swift
if #available(iOS 26.0, macOS 26.0, *) {
    let answer = try await knowledge.answer("How long do I have to return an item?")
    print(answer.text)                            // for example "Within 30 days of delivery [1]."
    print(answer.citedSources.map(\.documentID))  // ["returns"]
}
```

The model is told to answer only from the numbered sources, to cite them as `[1]`, `[2]`, and
to say when the sources do not contain the answer. It is a language model all the same: show
``GroundedAnswer/citedSources`` next to the answer so users can check it, and treat an answer
without citations with suspicion.

## Handle the cases without an answer

- ``AnswerError/noRelevantPassages``: nothing matches the question, so the model is not
  asked. Show your own "nothing found" message.
- ``AnswerError/modelUnavailable(_:)``: Apple Intelligence is off, still downloading, or the
  device does not support it. Check `SystemLanguageModel.default.availability` up front to hide
  the feature.
- Errors from Foundation Models, for example when the prompt and answer exceed the model's
  context. Lower `limit` or the passage size.

## Use another model

``KnowledgeBase/groundedPrompt(for:limit:mode:matching:passageBudget:)`` returns the prompt
without calling a model. Send ``GroundedPrompt/instructions`` as the system message and
``GroundedPrompt/text`` as the user message to any model, on the device or on a server, then
wrap the reply in a ``GroundedAnswer`` to read its citations:

```swift
let prompt = try await knowledge.groundedPrompt(for: question)
let reply = try await myModel.complete(system: GroundedPrompt.instructions, user: prompt.text)
let answer = GroundedAnswer(text: reply, sources: prompt.sources)
```

Here `myModel` stands for your own client of that model.

To stream the on-device model's answer, use the prompt with your own session:

```swift
let session = LanguageModelSession(instructions: GroundedPrompt.instructions)
for try await partial in session.streamResponse(to: prompt.text) {
    // update the UI with partial.content
}
```

The prompt keeps passages within a character budget (6,000 by default), so the instructions,
question and answer fit the on-device model's 4,096-token context.

## Let the model search by itself

In a conversation, the model can decide when it needs your documents. Give the session a
``KnowledgeSearchTool``:

```swift
let session = LanguageModelSession(
    tools: [KnowledgeSearchTool(knowledge: knowledge, description: "Searches the store's help articles.")],
    instructions: "You help customers of the store."
)
let response = try await session.respond(to: "Can I return shoes after three weeks?")
```

## Documents are data, not instructions

Anyone who can write a document can write text that looks like an instruction ("ignore the
rules and …"). The prompt quotes passages one per line under numbered sources, so a line break
inside a passage cannot add a fake source, and the instructions tell the model to ignore
requests inside the sources. No prompt makes a model immune to such text: do not give a
session that reads untrusted documents tools that act on the user's behalf.
