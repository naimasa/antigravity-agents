---
description: Start the Autonomous AI Developer Pipeline sequence with a new idea
---

When the user triggers `/startcycle <idea>`, orchestrate the end-to-end development process strictly using `.agents/agents.md` and `.agents/skills/`.

### Execution Pipeline Sequence:

1. **Step 1: Product Manager (@pm) — 仕様策定 & 承認ゲート**
   - Execute the `write_specs.md` skill using the `<idea>`.
   - Formulate architecture, tech stack, and deployment strategy into `production_artifacts/Technical_Specification.md`.
   - **Halt and wait for explicit user approval.**
   - *If the user provides feedback or inline comments, act as @pm again to revise the specification and ask for approval again. Loop until the user approves.*

2. **Step 2: Full-Stack Engineer (@engineer) — 実装**
   - Shift context to @engineer.
   - Execute the `generate_code.md` skill based on `production_artifacts/Technical_Specification.md`.
   - For complex algorithms, data structures, or optimization, invoke **Codex CLI**.
   - Output all code to `app_build/`.

3. **Step 3: QA Engineer (@qa) — コード監査 & バグ修正**
   - Shift context to @qa.
   - Execute the `audit_code.md` skill on `app_build/`.
   - Invoke **Claude Code CLI** for security audit and type consistency checks.
   - Commit any necessary fixes directly to `app_build/`.

4. **Step 4: DevOps Master (@devops) — 起動 & デプロイ**
   - Shift context to @devops.
   - Follow the Deployment & Hosting Strategy in `Technical_Specification.md`:
     - If local execution is specified: Execute `deploy_app.md`.
     - If cloud/production deployment is specified: Execute `deploy_cloud_run.md`.
   - Report the live localhost/production URL to the user.
