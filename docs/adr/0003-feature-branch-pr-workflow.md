# ADR 0003 — Feature branches + GitHub PRs

**Status:** Accepted · **Date:** 2026-07 (engineering setup)

## Context
Even as a solo project, we want `main` to stay always-runnable and changes to be reviewable
before they land.

## Decision
- One **feature branch** per feature (`m1/skill-tree`, `fix/...`, `chore/...`); never build on `main`.
- **Conventional Commits** (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`).
- Open a **GitHub PR** per feature; review the diff before merging to `main`.

## Consequences
- **+** Clean, readable history; near-free changelog; reviewable diffs.
- **+** `main` stays green and playable.
- **−** Slightly more overhead than committing straight to `main` — accepted for the safety and clarity.
