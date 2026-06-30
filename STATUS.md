# Project Status / 專案狀態

此文件是多 Agent 協作時的即時看板，保留在專案根目錄，方便所有 Agent 一開始就讀取。

This file is the live coordination board for multi-agent collaboration. It stays at the project root so every agent can find it first.

## Current Status / 目前狀態

| Agent | Status | Files / Area | Notes |
|---|---|---|---|
| ChatGPT | DONE | `scripts/StartDataCollector.ps1`, `scripts/FetchIntraday.Us.ps1`, `scripts/FetchDaily.Us.ps1`, `frontend/js/chart.js`, `data/groups.json`, `STATUS.md` | US provider now reads symbols from the `us-mvp` group, so added symbols such as MU are collected instead of falling back to frontend mock data. Intraday overlay now uses a fixed full session axis (`21:30` to `04:00` for US Taiwan-time data, `09:00` to `13:30` for TW/mock) and leaves missing minutes blank. Daily Chart tooltip uses index hover behavior, and refresh no longer resets zoom/pan. Syntax checks passed. Smoke test `StartDataCollector.ps1 -Provider us -Once` passed with MU Yahoo intraday/daily data. |
| ChatGPT | DONE | `scripts/FetchIntraday.Us.ps1`, `scripts/FetchDaily.Us.ps1`, `frontend/index.html`, `frontend/js/chart.js`, `STATUS.md` | Adjusted US intraday timestamps to Taiwan time (`21:30` to `04:00` for current DST data), changed US daily range to 1y, added Daily Chart zoom/pan support, and fixed candlestick tooltip OHLC display. Syntax checks passed. Smoke test `StartDataCollector.ps1 -Provider us -Once` passed with 391 intraday points and 251 daily candles for AAPL. Verified Yahoo Finance can also return Taiwan symbols such as `2330.TW`, `2454.TW`, and `6488.TWO`. |
| ChatGPT | DONE | `scripts/FetchIntraday.Us.ps1`, `scripts/FetchDaily.Us.ps1`, `scripts/StartDataCollector.ps1`, `scripts/StartFrontend.ps1`, `frontend/index.html`, `frontend/js/api.js`, `frontend/js/app.js`, `data/groups.json`, `STATUS.md` | Added US Provider MVP (`provider=us`) using Yahoo Finance chart JSON, no API key required. Supports AAPL, MSFT, NVDA, AMD, and TSM. Preserved existing JSON Contract paths/shapes. PowerShell syntax checks passed. Smoke test `StartDataCollector.ps1 -Provider us -Once` passed and generated compatible intraday/daily/latest runtime JSON. |
| ChatGPT | 完成 | `scripts/FetchIntraday.Us.ps1`, `scripts/FetchDaily.Us.ps1`, `scripts/StartDataCollector.ps1`, `scripts/StartFrontend.ps1`, `frontend/index.html`, `frontend/js/api.js`, `frontend/js/app.js`, `data/groups.json`, `STATUS.md` | 新增 US Provider MVP（`provider=us`），資料來源為 Yahoo Finance chart JSON，不需要 API Key。先支援 AAPL、MSFT、NVDA、AMD、TSM。維持既有 JSON Contract 路徑與 shape。PowerShell 語法檢查通過，smoke test `StartDataCollector.ps1 -Provider us -Once` 通過並產生相容 intraday/daily/latest runtime JSON。 |
| LM Studio | ONBOARDING | `AGENTS.md`, `STATUS.md`, `PROJECT_STATE.md`, `docs/Contract.md` | Read onboarding files. Confirmed Git workflow and contract rules. Ready for task assignment. |
| ChatGPT | REVIEW | `scripts/FetchIntraday.Twse.ps1`, `frontend/index.html`, `frontend/js/api.js`, `frontend/js/app.js`, `STATUS.md` | Cleaned TWSE intraday session handling so a new collector run does not carry over mock or stale points. Added a provider selector to the UI so Start Feed can launch either `twse` or `mock`. Syntax checks passed, and `twse -Once` now leaves 2330 with one clean real MIS point instead of a mixed mock/TWSE line. |
| ChatGPT | 檢視 | `scripts/FetchIntraday.Twse.ps1`, `frontend/index.html`, `frontend/js/api.js`, `frontend/js/app.js`, `STATUS.md` | 已修正 TWSE intraday session 處理，新 collector 執行不再沿用 mock 或舊點位。前端新增 provider 選單，Start Feed 可啟動 `twse` 或 `mock`。語法檢查通過，且 `twse -Once` 後 2330 只留下乾淨的真實 MIS 點，不再混成 mock/TWSE 假斜線。 |
| Human | REVIEW | onboarding flow, Git branch | Review `AGENTS.md` and onboarding instructions before merge. |

## First Entry / 第一入口

所有新協作者請先閱讀：

All new collaborators should start here:

```text
AGENTS.md
```

## Documentation Entry / 文件入口

核心文件：

Core files:

```text
AGENTS.md                         AI onboarding entry / AI 協作者入口
STATUS.md                         live collaboration board / 即時協作看板
PROJECT_STATE.md                  stable project state / 穩定狀態摘要
docs/README.md                    documentation index / 文件索引
docs/Contract.md                  canonical data contract / 正式資料契約
docs/governance/README.md         governance index / 治理文件入口
docs/product/README.md            product docs index / 產品文件入口
docs/archive/legacy/README.md     archived legacy docs / 舊文件歸檔
```

## Coordination Rules / 協作規則

- 開始修改前請先閱讀本檔案。
  Read this file before editing.

- 修改 data shape、API payload、檔案路徑前，請先更新 `docs/Contract.md`。
  Update `docs/Contract.md` before changing data shapes, API payloads, or file paths.

- 新功能請使用 task branch。
  Use task branches for new work.

- Commit message 必須包含 `[ChatGPT]`, `[LM]`, `[Human]`, or `[Collab]`，且提交主題、tag、說明必須採中英雙語，格式為 `[Agent] Chinese subject / English subject`。
  Commit messages must include `[ChatGPT]`, `[LM]`, `[Human]`, or `[Collab]`, and commit subjects, tags, and descriptions must be bilingual in Chinese and English using `[Agent] Chinese subject / English subject`.

## Current Warnings / 目前注意事項

- Runtime files under `data/intraday/`, `data/daily/`, `data/latest.json`, and `data/collector.pid` should not be committed.
  `data/intraday/`, `data/daily/`, `data/latest.json`, `data/collector.pid` 屬於 runtime 產物，不應提交。

- Production real-time and historical quote providers are not integrated yet.
  正式即時與歷史行情來源尚未整合。

## Next Recommended Task / 下一步建議

Implement the real `twse` provider scripts behind the new provider switch and keep the canonical JSON contract unchanged.

在新的 provider 切換架構後方實作真實 `twse` provider 腳本，並維持正式 JSON 契約不變。
