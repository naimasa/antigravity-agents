# 🤖 Antigravity Autonomous AI Developer Pipeline

*[日本語版 README](README.md)*

> **This file is a guide for humans. Agents do not need to read it** — the behavioural definitions live in `agents.md` and `skills/`, which are the single source of truth.

An orchestration config that puts Antigravity in charge of a development pipeline and delegates the heavy lifting to Codex CLI and Claude Code CLI, each on the work it is best at. It covers greenfield builds as well as refactoring and feature work on an existing codebase.

The persona structure, the `.agents/` layout, the `/startcycle` workflow and the approval gate come from a Google codelab — see [Credits](#-credits). What this repository adds on top is multi-CLI delegation, per-run result aggregation, spec history preservation, and usage accounting.

## 📁 Layout

```
.agents/                      # this repository (agent configuration)
├── agents.md                 # persona definitions & routing rules (always loaded)
├── skills/
│   ├── startcycle         # the `/startcycle` entry point (orchestration)
│   ├── write-specs        # @pm: requirements, approval gate, spec history
│   ├── generate-code      # @engineer: implementation & in-place refactoring (Codex)
│   ├── audit-code         # @qa: audit & regression prevention (Claude Code)
│   ├── deploy-app         # @devops: local run
│   ├── deploy-production  # @devops: production / cloud deploy
│   ├── track-progress     # shared: recording conventions (single source of truth)
│   ├── manage-quota       # shared: usage accounting & routing control
│   ├── verify-ui          # shared: browser verification policy (script it)
│   └── report-run         # shared: end-of-cycle report generation
├── scripts/                  # deterministic helpers: run_init / log / state / cli / verify / report / install / lint_skills
├── workflows/startcycle.md   # compatibility stub (real definition: skills/startcycle)
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

## ✅ Quality gates and token optimisation

- **Acceptance criteria**: every spec carries Given/When/Then ACs with a verification method; you approve them at the gate.
- **Mechanical definition of done**: `scripts/verify.sh` runs lint / types / tests / E2E (steps in `docs/verify.json`, bootstrap with `verify.sh --detect`) with no model inference.
- **Bounded fix loop**: @engineer feeds only the tail of failing logs back, max 3 rounds, then escalates to Opus analysis or asks you.
- **Independent tests**: tests for each AC are generated in a separate call that never sees the implementation.
- **Brief files**: CLIs get `docs/runs/<RUN_ID>/briefs/NN.md` (ACs, files to touch, done criteria) instead of pasted snippets, and read what they need themselves.
- **`docs/ARCHITECTURE.md`**: a ≤100-line repo map every CLI reads first, replacing repeated exploration.
- **Scripts over prose**: run ID, journal, CLI invocation (`cli.sh`: flags, raw output, cost, usage-limit detection → exit 75) and reporting (`report.sh`) are deterministic shell. Only summaries are read back; raw output stays in `raw/`.
- **Tighter permissions by default**: Codex `workspace-write`; Claude `acceptEdits` with an explicit tool allow-list and `--max-turns`. Widen only deliberately (`CODEX_SANDBOX`, `CLAUDE_TOOLS`).
- **Resume**: `/startcycle resume` reads only the ≤20-line `STATE.md`.

## ⚖️ Spreading the load across providers

Left to its own judgement, the orchestrator does nearly everything itself and burns through the Gemini quota while the other subscriptions sit idle. So **delegation is the default**, not an option.

> **None of the three services expose remaining quota.** Gemini shows it in the Antigravity UI only, Claude Code CLI has no `usage` subcommand, and neither does Codex CLI. This config therefore runs on measured consumption, an estimate against limits you declare yourself, and a manual mode switch.

### Routing rules

If the orchestrator handles work that `agents.md` assigns to a CLI — multi-file implementation, algorithm design, review, audit, architecture — **it must record why in the journal**. Doing so silently is a violation of the convention. Antigravity itself is limited to orchestration: file I/O, git, builds, tests and talking to you. Claude Code uses **Sonnet** as its default model, and switches to **Opus** for complex architecture designs and in-depth bug/issue investigations.

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

### Handling Usage Limits
When Codex CLI or Claude Code CLI hits a usage limit (rate limit, quota exceeded, 429 error, insufficient balance, etc.), Antigravity will not silently fall back or proceed on its own. **It stops and presents available options to confirm how you want to proceed:**

1. **Switch to alternative CLI / model**: If Codex hits a limit, switch to Claude Code; if Claude Code hits a limit, switch to Codex (or another configured model).
2. **Handle directly via Antigravity (Gemini)**: Proceed by letting Antigravity handle the task directly in-house (and record the reason in the journal).
3. **Wait for limit reset**: Pause the workflow and wait until the quota or rate limit resets before retrying.

### Browser verification

Verifying a web app by driving a browser interactively — screenshot, reason, act, repeat — is the fastest way to burn quota, because every step ships an image to the model and the whole sequence re-runs on each cycle.

So the rule is: **capture it once as a spec, then run it without inference.**

1. Write a Playwright spec (**generation is delegated to Codex**)
2. Run it with `npx playwright test` — no model inference, so no tokens
3. Send **only the failing cases**, with their logs and screenshots, to Claude Code for diagnosis

Interactive browser use is allowed in exactly two cases: a single smoke check when no spec exists yet, and visual judgements that can't be automated. Either way the step count goes in the journal and is billed to "handled in-house" in the ledger. Anything you need to check twice gets turned into a spec first. See `skills/verify-ui`.

### Usage accounting

Claude Code CLI reports `total_cost_usd` per call with `--output-format json`, so its spend is measured directly. Codex is counted by invocation, Gemini by "tasks handled in-house". Each run appends a row to `docs/runs/usage.md` recording the **delegation rate** (CLI calls ÷ total tasks). If that stays below 50% in `balanced` mode, the report raises a warning.

## 🔌 Cross-tool compatibility

Skills follow the Agent Skills standard (`<name>/SKILL.md` with `name` and `description` frontmatter). With this repo mounted as `.agents/` in the parent project:

| Tool | Skill discovery | Here |
|:---|:---|:---|
| **Antigravity** | `<workspace>/.agents/skills/<name>/` | found natively |
| **Codex** | `.agents/skills` from the CWD up to the repo root (symlinks OK) | found natively |
| **Claude Code** | `.claude/skills/<name>/` | `install.sh` symlinks them |

Only each skill's `description` is always loaded; bodies load on demand. `/startcycle` is itself a skill (`workflows/startcycle.md` is a compatibility stub). `install.sh` adds a managed block to the parent `AGENTS.md`; if the parent has a `CLAUDE.md`, add `@AGENTS.md` to it, since Claude Code otherwise ignores `AGENTS.md`. Enforcement relies on scripts (`verify.sh`, the `APPROVED` file), not tool-specific hooks. Run `scripts/lint_skills.sh` after editing skills.

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

## 📈 Evaluating the harness (evals)

`evals/` holds two small tasks (greenfield and refactor) with hidden acceptance checks. `run_eval.sh` runs them, `results.tsv` records pass rate, fix-loop rounds, CLI calls, USD and tokens, and `compare.sh` averages per harness version. See `evals/README.md`.

## 📦 Using it in another project

`install.sh` sets up the Claude Code links (`.claude/skills/`), the managed `AGENTS.md` block, `docs/` and `.gitignore`. Pick one of two patterns depending on whether those should show up in git.

### Pattern A: team-shared (Git submodule, commit the generated files)
```bash
git rev-parse --git-dir || git init                  # required for history preservation
git submodule add https://github.com/naimasa/antigravity-agents.git .agents
.agents/scripts/install.sh                           # .claude/skills, AGENTS.md, .gitignore (idempotent)
.agents/scripts/verify.sh --detect                   # bootstrap docs/verify.json (review it)
git add .gitmodules .agents .claude AGENTS.md .gitignore docs
git commit -m "chore: add antigravity-agents harness"

cp .agents/quota.example.yml .agents/quota.local.yml # optional; already gitignored

# updating
git submodule update --remote && .agents/scripts/install.sh
```

### Pattern B: personal use (nothing shows in `git status`)
Clone into `.agents` and run `install.sh --local`, which registers the generated files in `.git/info/exclude` (local-only ignore rules).
```bash
git rev-parse --git-dir || git init
git clone https://github.com/naimasa/antigravity-agents.git .agents
.agents/scripts/install.sh --local                   # excludes .agents/, .claude/skills, AGENTS.md
.agents/scripts/verify.sh --detect                   # bootstrap docs/verify.json (review it)
git status --short                                   # → none of the above appear

cp .agents/quota.example.yml .agents/quota.local.yml # optional

# updating
git -C .agents pull && .agents/scripts/install.sh --local
```
- If a tracked `AGENTS.md` already exists, `--local` leaves it untouched and prints the block to add by hand (skills are still discovered from `.agents/skills`).
- Development artifacts (`docs/spec.md`, `docs/runs/`) still appear in diffs as normal project records; only the harness files are excluded.
- To switch to sharing later, delete the matching lines from `.git/info/exclude` and follow Pattern A.

## 🙏 Credits

Built on the Google codelab **[Build Autonomous Developer Pipelines using agents.md and skills.md in Antigravity](https://codelabs.developers.google.com/autonomous-ai-developer-pipelines-antigravity)**.

The four-persona structure (@pm / @engineer / @qa / @devops), the `.agents/` directory convention, the `/startcycle` workflow and the human approval gate all come from that codelab. This repository extends it with delegation to Codex CLI and Claude Code CLI, per-run result aggregation, spec history preservation, usage accounting, and packaging as a reusable submodule.
