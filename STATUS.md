# Project Status / 專案狀態

此文件是多 Agent 協作時的即時看板，保留在專案根目錄，方便所有 Agent 一開始就讀取。

This file is the live coordination board for multi-agent collaboration. It stays at the project root so every agent can find it first.

## Current Status / 目前狀態

| Agent | Status | Files / Area | Notes |
|---|---|---|---|
| LM Studio | ONBOARDING | `AGENTS.md`, `STATUS.md`, `PROJECT_STATE.md`, `docs/Contract.md` | Read onboarding files. Confirmed Git workflow and contract rules. Ready for task assignment. |
| ChatGPT | REVIEW | metadata builder/importer, local symbol lookup, intraday mock feed, commit workflow | Built 1,980-symbol cache; fixed Windows PowerShell UTF-8 JSON import; added `Import-StockMetadata.ps1 -OutputFile`; verified local frontend uses `mock-powershell-progressive` intraday data; strengthened bilingual commit title/body format. Daily Chart remains unfinished. Branch: `chatgpt/complete-local-mvp`. |
| ChatGPT | 檢視 | 股票主檔匯入器、本地代號查詢、盤中 mock feed、提交流程 | 已建立 1,980 筆股票主檔快取；已修正 Windows PowerShell UTF-8 JSON 匯入；已新增 `Import-StockMetadata.ps1 -OutputFile`；已確認本地前端使用 `mock-powershell-progressive` 盤中資料；已強化中英雙語 commit 主題與說明格式。Daily Chart 尚未完成。分支：`chatgpt/complete-local-mvp`。 |
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

- Commit message 必須包含 `[ChatGPT]`, `[LM]`, `[Human]`, or `[Collab]`，且提交主題、tag、說明必須採中英雙語，格式為 `[Agent] 中文主題 / English subject`。
  Commit messages must include `[ChatGPT]`, `[LM]`, `[Human]`, or `[Collab]`, and commit subjects, tags, and descriptions must be bilingual in Chinese and English using `[Agent] Chinese subject / English subject`.

## Current Warnings / 目前注意事項

- Runtime files under `data/intraday/`, `data/daily/`, `data/latest.json`, and `data/collector.pid` should not be committed.
  `data/intraday/`, `data/daily/`, `data/latest.json`, `data/collector.pid` 屬於 runtime 產物，不應提交。

- Production real-time and historical quote providers are not integrated yet.
  正式即時與歷史行情來源尚未整合。

## Next Recommended Task / 下一步建議

Evaluate and implement a production quote provider while preserving `docs/Contract.md`.

評估並實作正式行情來源，並維持 `docs/Contract.md` 契約。
