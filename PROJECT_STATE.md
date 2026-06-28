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
| Current work branch | `chatgpt/bilingual-governance` |

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

- Stock symbol lookup is not reliable enough yet.
  股票名稱查詢目前仍不夠可靠。

- Real-time market data is not integrated yet.
  尚未接入真實即時行情資料。

- Daily chart area is still placeholder-level.
  日 K 區域仍是 placeholder 等級。

- `backend/StockOverlay.Api` is not part of the active MVP runtime.
  `backend/StockOverlay.Api` 不是目前 MVP runtime 的一部分。

## Next Recommended Work / 下一步建議

建立本地股票主檔快取：

Build local stock metadata cache:

```text
collab/stock-metadata-cache
```

目標：

Goal:

- 一次建立完整台股股票主檔。
  Build a complete Taiwan stock metadata file.

- 新增股票時先查本地 `data/symbols.json`。
  Look up `data/symbols.json` first when adding symbols.

- 網路查詢只作為補充。
  Use online lookup only as fallback.
