# Project Status

This file is used for multi-agent coordination.

## Current status

| Agent | Status | Files / Area | Notes |
|---|---|---|---|
| LM Studio | IDLE | `scripts/`, `data/`, `docs/Contract.md` | Created initial collaboration draft. Contract has now been reconciled with current implementation. |
| ChatGPT | DONE | `docs/`, `.gitignore` | Added collaboration workflow, Git strategy, canonical contract, and runtime ignore policy. |
| Human | REVIEW | Git baseline | Ready to review and create first baseline commit. |

## Coordination rules

- Read this file before editing.
- Read `docs/Contract.md` before changing data files, API payloads, or frontend readers.
- Use topic branches for new work.
- Commit messages must include `[ChatGPT]`, `[LM]`, `[Human]`, or `[Collab]`.

## Current conflicts / warnings

- `docs/Contract.md` previously used a different draft shape. It now documents the current canonical implementation.
- Runtime files under `data/intraday/`, `data/daily/`, `data/latest.json`, and `data/collector.pid` should not be committed.
- Stock symbol lookup is not reliable enough yet; next planned task is a local stock metadata cache.

## Next recommended task

Create the first baseline commit after reviewing `git status`.
