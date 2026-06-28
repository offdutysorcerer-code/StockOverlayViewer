# Development Workflow

## Goal

Keep development safe when multiple AI agents or machines edit StockOverlayViewer.

## One source of truth

`docs/Contract.md` is the canonical data contract. If implementation and documentation disagree, reconcile the contract first.

## Standard workflow

1. Read `STATUS.md`.
2. Read `docs/Contract.md`.
3. Check Git status.
4. Work on a task branch.
5. Make small changes.
6. Test the smallest useful path.
7. Update docs when behavior or data shapes change.
8. Update `STATUS.md`.
9. Commit with an agent prefix.

## Local run

```powershell
cd D:\MarketResearch\Apps\StockOverlayViewer
.\scripts\StartFrontend.ps1
```

Open:

```text
http://localhost:5174
```

Use the UI button:

```text
Start Mock Feed
```

Manual fallback:

```powershell
.\scripts\StartDataCollector.ps1 -Mock -IntervalSeconds 2 -DurationSeconds 60
```

## Contract change workflow

For any JSON shape change:

1. Update `docs/Contract.md` first.
2. Update data writer.
3. Update frontend reader.
4. Update sample data.
5. Test with current UI.

## Runtime data policy

Generated quote files are runtime artifacts and should normally stay out of Git:

- `data/intraday/*.json`
- `data/daily/*.json`
- `data/latest.json`
- `data/collector.pid`

## Known current issues

- Stock name lookup through the current endpoint may miss valid symbols.
- A local stock metadata cache should be built before real data integration.
- `backend/StockOverlay.Api` is optional and not part of MVP runtime.
