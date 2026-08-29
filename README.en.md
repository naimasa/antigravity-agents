# 🤖 Antigravity Autonomous AI Developer Pipeline

*[日本語版 README](README.md)*

> **This file is a guide for humans. Agents do not need to read it** — the behavioural definitions live in `agents.md`, `skills/` and `workflows/`, which are the single source of truth.

An orchestration config that puts Antigravity in charge of a development pipeline and delegates the heavy lifting to Codex CLI and Claude Code CLI, each on the work it is best at. It covers greenfield builds as well as refactoring and feature work on an existing codebase.

The persona structure, the `.agents/` layout, the `/startcycle` workflow and the approval gate come from a Google codelab — see [Credits](#-credits). What this repository adds on top is multi-CLI delegation, per-run result aggregation, spec history preservation, and usage accounting.

## 📁 Layout

```
.agents/                      # this repository (agent configuration)
├── agents.md                 # persona definitions & routing rules (always loaded)
├── skills/
│   ├── write_specs.md        # @pm: requirements, approval gate, spec history
│   ├── generate_code.md      # @engineer: implementation & in-place refactoring (Codex)
│   ├── audit_code.md         # @qa: audit & regression prevention (Claude Code)
│   ├── deploy_app.md         # @devops: local run
│   ├── deploy_production.md  # @devops: production / cloud deploy
│   ├── track_progress.md     # shared: recording conventions (single source of truth)
│   ├── manage_quota.md       # shared: usage accounting & routing control
│   └── report_run.md         # shared: end-of-cycle report generation
├── workflows/startcycle.md   # the `/startcycle` slash command
├── quota.example.yml         # routing mode template
└── quota.local.yml           # (optional) your own plan limits. gitignore this

docs/
├── spec.md                   # living spec (current To-Be + revision history)
├── specs/<RUN_ID>.md         # immutable snapshot taken at approval time
└── runs/
    ├── index.md              # dashboard of every cycle
    ├── usage.md              # cumulative CLI usage ledger (delegation rate)
    └── <RUN_ID>/             # journal.md / report.md / raw/ (raw CLI output)
src/                          # application source
```

## 🚀 Usage

> ⚠️ **Prerequisite**: the parent project must be a Git repository. If it isn't, the pipeline stops at Step 0 rather than starting.

Run it from the Antigravity chat box:

```text
/startcycle "Build an Othello game"
/startcycle "Refactor state management in game.js into a state machine and add difficulty settings"
```

| Step | Owner | What happens |
|:-:|:---|:---|
| 0 | — | Assign a `RUN_ID`, pin the working tree as the baseline commit |
| 1 | **@pm** | Analyse As-Is / To-Be, write `docs/spec.md`, then **stop and wait for approval** |
| 2 | **@engineer** | Implement, respecting existing code and applying minimal diffs |
| 3 | **@qa** | Audit for regressions, type mismatches and vulnerabilities, then fix |
| 4 | **@devops** | Launch or deploy, report the URL |
| 5 | — | Generate the consolidated report and post a summary to chat |

The approval gate in Step 1 is not optional and is never auto-approved.

## 📊 Where the results end up

One `/startcycle` invocation is one **Run** (`RUN_ID = YYYYMMDD-HHMMSS-<slug>`). All four personas write into the same place. Each writes **immediately after finishing its step**, so a cycle that breaks halfway still leaves a record.

| What you want to see | Where to look |
|:---|:---|
| Every cycle so far (when, what, outcome) | `docs/runs/index.md` |
| Summary of one cycle (who did what) | `docs/runs/<RUN_ID>/report.md` |
| Detailed per-agent log | `docs/runs/<RUN_ID>/journal.md` |
| Raw Codex / Claude Code output (the reasoning behind a decision) | `docs/runs/<RUN_ID>/raw/` |
| The spec as approved / the spec as it stands now | `docs/specs/<RUN_ID>.md` / `docs/spec.md` |

## ⚖️ Spreading the load across providers

Left to its own judgement, the orchestrator does nearly everything itself and burns through the Gemini quota while the other subscriptions sit idle. So **delegation is the default**, not an option.

> **None of the three services expose remaining quota.** Gemini shows it in the Antigravity UI only, Claude Code CLI has no `usage` subcommand, and neither does Codex CLI. This config therefore runs on measured consumption, an estimate against limits you declare yourself, and a manual mode switch.

### Routing rules

If the orchestrator handles work that `agents.md` assigns to a CLI — code generation over 20 lines, algorithm design, review, audit, architecture — **it must record why in the journal**. Doing so silently is a violation of the convention. Antigravity itself is limited to orchestration: file I/O, git, builds, tests and talking to you.

### Modes

```bash
cp .agents/quota.example.yml .agents/quota.local.yml   # then edit `mode`
```

| mode | When to use it |
|:---|:---|
| `balanced` (default) | Delegate per the routing rules |
| `gemini-saver` | Gemini is running low — push even small generation and reading tasks out to the CLIs |
| `local-only` | Codex/Claude are exhausted — handle everything in Antigravity and note it in the report |

Switching modes is a manual decision, because no API will tell you when you are running low.

### Usage accounting

Claude Code CLI reports `total_cost_usd` per call with `--output-format json`, so its spend is measured directly. Codex is counted by invocation, Gemini by "tasks handled in-house". Each run appends a row to `docs/runs/usage.md` recording the **delegation rate** (CLI calls ÷ total tasks). If that stays below 50% in `balanced` mode, the report raises a warning.

## 🗂 Keeping spec history

`docs/spec.md` always reflects the current To-Be, so it gets overwritten. Three mechanisms keep the older versions from disappearing.

1. **Commit before overwriting** — the uncommitted previous version is committed before any rewrite, so every round-trip through the approval gate survives in history. *Being inside a Git repository is not enough: uncommitted work is still lost to an overwrite.*
2. **Snapshot on approval** — the approved content is copied to `docs/specs/<RUN_ID>.md` and left immutable, so "the spec we agreed on" is one file to open rather than a diff to reconstruct.
3. **Revision history table** — run ID, date and summary are appended to the top of `docs/spec.md`.

```bash
git log --oneline --follow docs/spec.md
```

Because each gate commits separately, history separates whose work a change came from.

| Gate | Commit message |
|:---|:---|
| Run starts | `chore: baseline before <RUN_ID>` |
| Spec approved | `docs(spec): approve spec for <RUN_ID>` |
| Implementation done (@engineer) | `feat: <summary> (<RUN_ID>)` |
| QA fixes done (@qa) | `fix(qa): <summary> (<RUN_ID>)` |
| Report generated | `docs(run): add report for <RUN_ID>` |

## 📦 Using it in another project (Git submodule)

```bash
git submodule add https://github.com/naimasa/antigravity-agents.git .agents
mkdir -p docs/specs docs/runs src
git rev-parse --git-dir || git init   # required for history preservation
git submodule update --remote         # pull the latest agent definitions

cp .agents/quota.example.yml .agents/quota.local.yml   # optional: routing mode
echo ".agents/quota.local.yml" >> .gitignore
```

## 🙏 Credits

Built on the Google codelab **[Build Autonomous Developer Pipelines using agents.md and skills.md in Antigravity](https://codelabs.developers.google.com/autonomous-ai-developer-pipelines-antigravity)**.

The four-persona structure (@pm / @engineer / @qa / @devops), the `.agents/` directory convention, the `/startcycle` workflow and the human approval gate all come from that codelab. This repository extends it with delegation to Codex CLI and Claude Code CLI, per-run result aggregation, spec history preservation, usage accounting, and packaging as a reusable submodule.
