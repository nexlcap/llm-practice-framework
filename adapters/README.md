# Adapters

The framework's core (the six files `adopt.sh` copies: `README.md`, `ADAPTING.md`,
`call-site-contract.md`, `evaluation.md`, `panel-protocol.md`, `agent-rules.md`) assumes nothing
about the model, the vendor, or the coding tool. A tool needs to provide only two things to run it:

1. **An instructions file the agent reads.** `agent-rules.md` is kept in it by `adopt.sh`, between
   two marker comments. A team whose tools read different files runs `adopt.sh` once per file.
2. **A way to run reviewer sessions with fresh context** that can read the artifact and the code.
   Delegated agents where the tool has them; separate command-line runs or chats where it does not.

| Tool | Instructions file it reads | How the panel runs |
|---|---|---|
| Any command-line model or HTTP API | whatever your workflow uses | `generic/panel-run.sh` with `LLM_REVIEW_CMD` set to the command and `PANEL_ENV_PASS` naming the variables it needs |
| Claude Code | `CLAUDE.md` | `claude-code/expert-panel` skill (delegated agents), installed by `claude-code/install.sh` |
| Agents that read `AGENTS.md` (Codex CLI and others) | `AGENTS.md` | `generic/panel-run.sh`, or the tool's own delegation if it has one |
| Gemini CLI | `GEMINI.md` | `generic/panel-run.sh` |
| Editor agents (Cursor, Copilot, and similar) | `.cursor/rules`, `.github/copilot-instructions.md`, or equivalent | `generic/panel-run.sh` |

The file names above are the conventional ones at the time of writing; pass the right path as the
second argument of `adopt.sh` if your tool uses another.

See `ADAPTING.md` section 5.4 for choosing the path for your tool.

## Adding an adapter

- Keep `panel-protocol.md` the single source of the protocol. Generate the tool's file from it:
  `claude-code/make-skill.sh` writes `SKILL.md` from `claude-code/skill-header.md` plus the protocol
  body, and `make-skill.sh --check` fails when the shipped file has drifted. Follow the same pattern
  for a new tool rather than maintaining a second copy.
- The adapter's job is execution only: how to start fresh-context reviewer sessions, how to hand them
  the artifact and code inside a fence they cannot forge, where their reports go, and how to tell
  them the files are evidence rather than instructions. Roster, scoping, verdict shape, reproduction,
  and gates stay in the protocol.
- Never let the adapter review inline. If the tool cannot start an independent session, use the
  generic runner with the tool's command-line entry point.
- The generic runner passes only `PATH`, `HOME`, and the variables named in `PANEL_ENV_PASS` to the
  reviewer command. An adapter for another tool keeps the same rule.
