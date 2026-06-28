# StockOverlayViewer

用途：方便觀察股價變化，讓使用者用群組管理股票代號，並將選擇的個股走勢圖疊加在畫面上。

Purpose: manage stock symbols by groups and overlay selected price charts for quick market observation.

## New Collaborators / 新協作者

所有新 AI Agent 或協作者請先閱讀：

All new AI agents or collaborators should start here:

```text
AGENTS.md
```

接著依序閱讀：

Then read:

```text
STATUS.md
PROJECT_STATE.md
docs/README.md
docs/Contract.md
docs/governance/README.md
```

## Current MVP / 目前 MVP

```text
Frontend HTML/CSS/JS
  ↓ reads JSON
Local JSON data files
  ↑ written by
PowerShell local server and data collector scripts
```

目前不需要正式 ASP.NET 後端；`backend/StockOverlay.Api` 保留為未來升級備案。

A formal ASP.NET backend is not required for the current MVP. `backend/StockOverlay.Api` is kept as a future upgrade path.

## Start / 啟動

```powershell
cd D:\MarketResearch\Apps\StockOverlayViewer
.\scripts\StartFrontend.ps1
```

Open:

```text
http://localhost:5174
```

Mock feed can be started from the UI with:

```text
Start Mock Feed
```

Manual fallback:

```powershell
.\scripts\StartDataCollector.ps1 -Mock -IntervalSeconds 2 -DurationSeconds 60
```

## Refresh Stock Metadata / 更新股票主檔

Use the official TWSE and TPEx OpenAPI sources to rebuild the local cache:

```powershell
.\collab\stock-metadata-cache\Get-TaiwanStockMetadata.ps1
```

The script validates record counts and only replaces `data/symbols.json` after a complete UTF-8 write succeeds.

## Documentation / 文件

請從文件索引開始：

Start from the documentation index:

```text
docs/README.md
```

Key files:

```text
AGENTS.md                         AI onboarding entry
STATUS.md                         live collaboration status
PROJECT_STATE.md                  stable project state
docs/Contract.md                  canonical data contract
docs/governance/README.md         governance docs
docs/product/README.md            product docs
docs/archive/legacy/README.md     archived legacy docs
```

## Project Structure / 專案結構

```text
StockOverlayViewer/
├── AGENTS.md
├── PROJECT_STATE.md
├── README.md
├── STATUS.md
├── docs/
│   ├── README.md
│   ├── Contract.md
│   ├── governance/
│   ├── product/
│   └── archive/
├── frontend/
├── data/
├── scripts/
└── backend/
```

## Collaboration / 協作

本專案支援多 AI、多機協作。開始修改前請先讀：

This project supports multi-agent and multi-machine collaboration. Before editing, read:

```text
AGENTS.md
STATUS.md
PROJECT_STATE.md
docs/Contract.md
docs/governance/README.md
```

Commit message must use one of:

```text
[ChatGPT]
[LM]
[Human]
[Collab]
```

## Data Policy / 資料政策

Runtime quote output should not be committed:

```text
data/intraday/*.json
data/daily/*.json
data/latest.json
data/collector.pid
```

Canonical configuration may be committed:

```text
data/groups.json
data/groups.sample.json
data/symbols.json
```
