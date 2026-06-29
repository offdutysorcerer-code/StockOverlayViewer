# PROJECT_STATE.md / 專案目前狀態

本文件描述專案「相對穩定」的目前狀態，和 `STATUS.md` 不同。

This file describes relatively stable project state. It is different from `STATUS.md`.

## Snapshot / 狀態快照

| Item | Current State |
|---|---|
| Project | StockOverlayViewer |
| Runtime | PowerShell local server |
| Frontend | HTML + CSS + JavaScript |
| Chart library | Chart.js |
| Backend | Optional ASP.NET Core backup only |
| Data storage | Local JSON files |
| Data collector | PowerShell scripts |
| Current quote source | Mock progressive intraday data |
| Collaboration model | Multi-agent, branch-based workflow |
| Canonical contract | `docs/Contract.md` |
| Governance docs | `docs/governance/` |
| Current stable branch | `master` |
| Current work branch | `chatgpt/complete-local-mvp` |

## Current Runtime / 目前執行方式

啟動 local server：

Start local server:

```powershell
cd D:\MarketResearch\Apps\StockOverlayViewer
.\scripts\StartFrontend.ps1
```

Open:

```text
http://localhost:5174
```

可從 UI 按下：

Use UI button:

```text
Start Mock Feed
```

## Current Architecture / 目前架構

```text
frontend HTML/CSS/JS
  ↓ fetch
PowerShell local server
  ↓ serve/save/start collector
data/*.json
  ↑ written by
scripts/StartDataCollector.ps1
```

## Important Files / 重要文件

| File | Purpose |
|---|---|
| `AGENTS.md` | AI onboarding entry / AI 協作者入口 |
| `STATUS.md` | live coordination board / 即時協作看板 |
| `PROJECT_STATE.md` | stable project state / 穩定狀態摘要 |
| `docs/README.md` | documentation index / 文件索引 |
| `docs/Contract.md` | canonical data contract / 正式資料契約 |
| `docs/governance/README.md` | governance index / 治理文件入口 |
| `docs/product/Architecture.md` | architecture detail / 架構細節 |
| `docs/product/Roadmap.md` | roadmap / 路線圖 |

## Current Known Limitations / 目前限制

- Real-time market data is not integrated yet.
  尚未接入真實即時行情資料。

- Daily Chart is not complete yet; current UI and mock files are scaffolding for the next task.
  Daily Chart 尚未完成；目前 UI 與 mock 檔案是下一階段工作的基礎。

- `backend/StockOverlay.Api` is not part of the active MVP runtime.
  `backend/StockOverlay.Api` 不是目前 MVP runtime 的一部分。

## Completed MVP Work / 已完成 MVP

- Local metadata contains 1,980 four-digit TWSE and TPEx company symbols.
- Symbol lookup reads `data/symbols.json` first.
- Intraday overlay supports Actual and Indexed modes.
- Intraday overlay reads `mock-powershell-progressive` data from the PowerShell collector when launched through `scripts/StartFrontend.ps1`.
- `Import-StockMetadata.ps1` supports `-OutputFile` for safe import testing without overwriting `data/symbols.json`.
- Source, update time, and stale warnings are visible.
- Daily Chart has UI and initial code, but it is not considered complete yet.

## Next Recommended Work / 下一步建議

Implement and evaluate a production quote provider for Phase 2 and Phase 3. Keep provider-specific logic in collector scripts and preserve the canonical JSON contract.
