# Development Workflow

How we build **Debone Them All**. Right-sized for a solo dev + AI collaborator on a Godot
game: solid foundations, no enterprise ceremony. Future sessions should follow this.

---

## Documentation layers

| Layer | Where | Purpose |
|---|---|---|
| **Vision** | [`GDD.md`](./GDD.md) | The game's design bible. Update as decisions are made. |
| **Milestone specs** | `docs/Mx-*.md` | Buildable scope + success criteria per milestone. |
| **Architecture** | [`architecture.md`](./architecture.md) | Big-picture technical map. Read this first. |
| **Decision records** | `docs/adr/NNNN-*.md` | One short file per notable technical decision (the *why*). |
| **Player reference** | [`mechanics.md`](./mechanics.md) | Towers, enemies, counters, currencies. Seed for a future in-game codex. |
| **Code doc-comments** | `##` in `.gd` files | Surfaced in Godot's in-editor help. Keep on every script + public method. |
| **Changelog** | [`../CHANGELOG.md`](../CHANGELOG.md) | Human-readable, per milestone. |

**Rule:** a feature isn't done until the docs it touches are updated in the same PR.

---

## Testing (GUT, logic-focused)

Framework: **[GUT](https://github.com/bitwes/Gut)**, vendored in `addons/gut/`. Tests live in
`tests/unit/` (config in `.gutconfig.json`).

**What we test** (test the logic that would *silently* break):
- **Pure logic** — counter matrix, economy math, save/load round-trips, wave scheduling, skill-tree
  effect application. Fast, deterministic, headless.
- **Node/scene behavior** (as needed) — spawn a node, simulate frames, assert state (e.g. an enemy
  reaches the end; a minion damages a target). Formalizes the M0 headless smoke-runs.

**What we don't test:** visuals, feel, balance — those are manual playtest + screenshot review.

**Run the suite:**
```bash
./run_tests.sh
# or directly:
./Godot_v4.7.1-stable_linux.x86_64 --headless -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
```

CI (GitHub Actions) is **deferred** — run tests locally for now.

---

## Git workflow (feature branches + PRs)

- **Branch per feature:** `m1/meta-state`, `m1/skill-tree`, `chore/...`, `fix/...`. Never build on `main`.
- **Conventional Commits:** `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
  Example: `feat(meta): persist Grave Bones to user://save.json`.
- **Open a GitHub PR** per feature; review the diff before merging to `main`.
- `main` stays always-runnable.

---

## Definition of Done (per feature)

- [ ] Boots clean headless (no parse/runtime errors).
- [ ] Relevant **GUT tests** written and passing.
- [ ] **Doc-comments** on new scripts/public methods.
- [ ] `architecture.md` / `mechanics.md` / `CHANGELOG.md` updated if touched.
- [ ] Manually run (or screenshot-verified) that it actually works.
- [ ] Committed on a feature branch with Conventional Commit messages; PR opened.

---

## Review — self-review via dedicated agents

There is **no human PR review**. Claude reviews its own work by invoking dedicated **review
subagents** (defined in `.claude/agents/`) whenever a change is complete, before committing/merging.
Each is read-only: it reports prioritized findings; the main session applies the fixes, then
re-runs the relevant agent if the changes were substantial.

| Agent | Invoke when… | Checks |
|---|---|---|
| **`code-reviewer`** | any code change is complete | correctness, Godot/GDScript pitfalls, project conventions, test coverage (runs `./run_tests.sh`), regressions |
| **`user-doc-reviewer`** | player-facing docs or the mechanics they describe change | `docs/mechanics.md` / codex accuracy vs. code, clarity, completeness |
| **`tech-doc-reviewer`** | systems/architecture or technical docs change | `architecture.md`, ADRs, `dev-workflow.md`, `CHANGELOG.md`, doc-comments — accuracy vs. implementation, staleness |

**Per-feature review flow:**
1. Finish the change (code + tests + docs).
2. Self-check: headless parse → `./run_tests.sh` → smoke-run/screenshot.
3. Invoke the **applicable** review agents (always `code-reviewer` for code; add the doc reviewers
   when their docs are touched). Run them in parallel when independent.
4. Address blocker/important findings; note or defer nits.
5. Commit, push, open the PR, and **merge** (optionally after a deeper `/code-review` or cloud
   `ultrareview` pass at milestone end).
