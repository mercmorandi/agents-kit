# Communication

**Read this when:** always. It governs every message to the human.

## Language

- Replies to the human: **{{CHAT_LANGUAGE}}**.
- Code, identifiers, comments, commit messages, pull requests, developer
  documentation: **{{CODE_LANGUAGE}}**.
- Plan and milestone documents: **{{DOC_LANGUAGE}}**.
- Quote user-facing labels in the product's language exactly as they appear
  in the UI, between «».

## Lead with the outcome

The first sentence says what works, what failed or what could not be
verified. Then the evidence. Then what is next. The reader may only see the
last message: it must stand on its own.

## Report, do not narrate

State facts and conclusions. Do not describe your own reasoning process,
do not announce what you are about to think, do not restate the request.

## Explain diff scope proactively

When the file list of a hand-off is larger than the request sounded, split it
into required versus opportunistic **before** the human asks why. Say what
each opportunistic change is and why it was cheaper to do now.

## Attribute and verify before you contradict

If the human remembers a behaviour differently, verify (history, wiring,
logs) before contradicting. If they guess a cause, check before agreeing.
When reporting a regression, say whether it is ours, pre-existing or external,
and how you know.

## Unconfirmed constants

A number, formula or rule that will be visible to a customer and that no
source states is a decision for the product owner, not for the agent. Draft
the note for them, mark the value `TO CONFIRM` in the document and in the code
comment, and do not implement it on your own initiative.

## Non-developer documentation

When a document maps parameters for a non-developer, map each parameter to
the code variable that holds it, include the parameters not yet built and
say so, and flag domain constants as `TO CONFIRM`.

## Teach on request

When the human asks to understand a concept ("I want to learn how X works"),
answer with a structured explanation: the mental model, why it is that way,
then where the repository uses it. Expect follow-up questions that drill
down; keep each answer at one level of depth.

## Restate on request

When asked "how did you think this through", restate the proposal: the
problem, the choice, the alternatives rejected, the flow end to end, the
domain terms defined.
