# ADR 0002 — GUT for testing, logic-focused

**Status:** Accepted · **Date:** 2026-07 (engineering setup)

## Context
We want automated safety on the logic that would silently break (counter matrix, economy,
save/load, wave scheduling) without over-investing in test infrastructure for a solo game.

## Decision
Use **GUT** (Godot Unit Test), vendored in `addons/gut/`, tests in `tests/unit/`, run headless
via `./run_tests.sh`. Focus tests on **pure logic and critical node behavior**; do not test
visuals, feel, or balance. Considered GdUnit4 (richer, more CI tooling) but chose GUT for
simplicity.

## Consequences
- **+** Fast, deterministic regression safety on the parts that matter.
- **+** Simple, well-documented, headless-friendly.
- **−** Vendoring the addon adds files to the repo; must update it manually.
- CI (GitHub Actions) is deferred; tests run locally for now.
