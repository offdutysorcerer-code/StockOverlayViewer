# Git Strategy

## Current goal

Use Git to make multi-agent development safe and reversible.

## Branch model

Keep `master` stable. New work should happen on topic branches.

Suggested branch names:

```text
chatgpt/<short-task>
lm/<short-task>
human/<short-task>
collab/<short-task>
```

Examples:

```text
chatgpt/daily-overlay
lm/stock-metadata-cache
collab/contract-v2
```

## Commit rules

Commit messages must include agent prefix:

```text
[ChatGPT] Add progressive mock feed controls
[LM] Add TWSE stock metadata fetcher
[Human] Adjust watchlist symbols
[Collab] Align data contract with implementation
```

Each commit should contain one coherent change.

## What to commit

Commit:

- Source code under `frontend/`, `scripts/`, `backend/`.
- Canonical configuration such as `data/groups.json`, `data/groups.sample.json`, `data/symbols.json`.
- Documentation under `docs/`.
- `STATUS.md` when it records meaningful coordination state.

Do not commit:

- Runtime quote output under `data/intraday/*.json`.
- Runtime quote output under `data/daily/*.json`.
- `data/latest.json`.
- `data/collector.pid`.
- Logs, temp files, editor caches.

## Before starting work

```powershell
git status --short --branch
```

If there are unrelated changes, do not overwrite them. Read `STATUS.md` and ask for direction.

## Before committing

```powershell
git status --short
git diff --stat
```

For PowerShell scripts, run at least a syntax check when possible:

```powershell
$errors = $null
[System.Management.Automation.PSParser]::Tokenize((Get-Content .\scripts\StartFrontend.ps1 -Raw), [ref]$errors) | Out-Null
$errors
```

## Initial baseline recommendation

The first commit should establish the current MVP baseline and collaboration rules after generated files are ignored.

Suggested message:

```text
[Collab] Establish StockOverlayViewer MVP baseline
```
