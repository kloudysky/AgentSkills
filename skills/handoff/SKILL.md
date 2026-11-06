---
name: handoff
description: Compact the current conversation into a handoff document and start a new T3 Code thread with it.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

## Start the next thread

Running this skill is the user's request for a new thread. Call `t3_thread_launch` from the T3 Code MCP server, loading it through tool search if it is deferred:

- `title`: the next session's focus, in a few words.
- `message`: the full document, opening with one line that tells the agent to continue the work.
- `workspaceStrategy`: a launch defaults to the project root. If `t3_worktree_status` reports `attached: true`, pass `{ "type": "existing_worktree", "worktreePath": "<its worktreePath>" }` so the next agent lands in this checkout.

Leave the project, model, and modes unset so they inherit from this thread.

You are done when the thread exists. Reply with its `link` and leave the work to the new thread.

Outside T3 Code, or if the launch fails, save the document to the OS temp directory, outside the workspace, and reply with its path.
