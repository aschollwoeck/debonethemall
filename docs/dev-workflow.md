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

## Review

- **Self-review (every handoff):** headless parse → `./run_tests.sh` → smoke-run/screenshot before presenting.
- **Deeper review:** `/code-review` on the working diff, or the heavier cloud `ultrareview`, at feature/milestone end.
- **Human review:** the PR diff on GitHub before merge.
