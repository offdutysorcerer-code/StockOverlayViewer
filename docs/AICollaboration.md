# AI Collaboration Guide

This project may be edited by multiple agents: ChatGPT conversations, LM Studio instances, and future local tools.

## Required start procedure

Before editing, every agent must read:

1. `STATUS.md`
2. `docs/Contract.md`
3. `docs/Architecture.md`
4. `docs/GitStrategy.md`
5. The files it plans to edit

## Required finish procedure

After editing, every agent must:

1. Update `STATUS.md`.
2. Run a quick check if possible.
3. Record changed files in its final message.
4. Commit only its own scoped changes or leave a clear note saying no commit was made.

## Ownership map

Default ownership is advisory, not absolute. If a change crosses ownership, update `STATUS.md` first.

| Area | Primary owner | Notes |
|---|---|---|
| `frontend/` | ChatGPT | UI, chart rendering, user interactions |
| `scripts/` | LM Studio / ChatGPT | Data collector and local PowerShell server |
| `data/groups.json` | Shared | Contract-sensitive user configuration |
| `data/symbols.json` | Shared | Stock metadata cache |
| `data/intraday/` | Runtime | Generated files; should normally be ignored |
| `data/daily/` | Runtime | Generated files; should normally be ignored |
| `docs/Contract.md` | Shared | Must be updated before breaking data shape changes |
| `docs/` | Shared | Architecture, workflow, roadmap |
| `backend/` | Future backend owner | Optional ASP.NET Core backup path |

## Conflict prevention

- Do not rewrite entire files unless necessary.
- Prefer small, scoped edits.
- Do not modify generated data files unless the task is about data generation.
- Do not silently change JSON shapes.
- Do not change both frontend and data contract without documenting the compatibility impact.

## Agent labels

Use these commit prefixes:

```text
[ChatGPT] message
[LM] message
[Human] message
```

For multi-agent work, use:

```text
[Collab] message
```

## Status meanings

```text
IDLE       not working
PLANNING   reading and planning
WORKING    editing files
BLOCKED    waiting for human decision or tool access
DONE       finished changes and updated status
```
