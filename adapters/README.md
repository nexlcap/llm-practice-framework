# Adapters

The framework's core (`README.md`, `call-site-contract.md`, `panel-protocol.md`, `agent-rules.md`)
assumes nothing about the model, the vendor, or the coding tool. A tool needs to provide only two
things to run it:

1. **An instructions file the agent reads.** `agent-rules.md` is pasted into it by `adopt.sh`.
2. **A way to run reviewer sessions with fresh context** that can read the artifact and the code.
   Delegated agents where the tool has them; separate command-line runs or chats where it does not.

| Tool | Instructions file it reads | How the panel runs |
|---|---|---|
| Any command-line model or HTTP API | whatever your workflow uses | `generic/panel-run.sh` with `LLM_REVIEW_CMD` set to the command |
| Claude Code | `CLAUDE.md` | `claude-code/expert-panel` skill (delegated agents), installed by `claude-code/install.sh` |
| Agents that read `AGENTS.md` (Codex CLI and others) | `AGENTS.md` | `generic/panel-run.sh`, or the tool's own delegation if it has one |
| Gemini CLI | `GEMINI.md` | `generic/panel-run.sh` |
| Editor agents (Cursor, Copilot, and similar) | `.cursor/rules`, `.github/copilot-instructions.md`, or equivalent | `generic/panel-run.sh` |

The file names above are the conventional ones at the time of writing; pass the right path as the
second argument of `adopt.sh` if your tool uses another.

## Adding an adapter

- Keep `panel-protocol.md` the single source of the protocol. Generate the tool's file from it
  (the Claude Code skill is the protocol body under a short tool-specific header) rather than
  maintaining a second copy.
- The adapter's job is execution only: how to start fresh-context reviewer sessions, how to hand them
  the artifact and code, where their reports go. Roster, scoping, verdict shape, reproduction, and
  gates stay in the protocol.
- Never let the adapter review inline. If the tool cannot start an independent session, use the
  generic runner with the tool's command-line entry point.
