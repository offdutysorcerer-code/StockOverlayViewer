# Project Status / 專案狀態

此文件是多 Agent 協作時的即時看板。

This file is the live coordination board for multi-agent collaboration.

## Current Status / 目前狀態

| Agent | Status | Files / Area | Notes |
|---|---|---|---|
| LM Studio | IDLE | `scripts/`, `data/`, `docs/Contract.md` | Waiting for next task. |
| ChatGPT | DONE | `docs/governance/`, `docs/*.md`, `STATUS.md` | Added bilingual governance structure. |
| Human | REVIEW | governance docs, Git branch | Review bilingual governance docs before merge. |

## Coordination Rules / 協作規則

- 開始修改前請先閱讀本檔案。
  Read this file before editing.

- 修改 data shape、API payload、檔案路徑前，請先更新 `docs/Contract.md`。
  Update `docs/Contract.md` before changing data shapes, API payloads, or file paths.

- 新功能請使用 task branch。
  Use task branches for new work.

- Commit message 必須包含 `[ChatGPT]`, `[LM]`, `[Human]`, or `[Collab]`。
  Commit messages must include `[ChatGPT]`, `[LM]`, `[Human]`, or `[Collab]`.

## Current Warnings / 目前注意事項

- Runtime files under `data/intraday/`, `data/daily/`, `data/latest.json`, and `data/collector.pid` should not be committed.
  `data/intraday/`, `data/daily/`, `data/latest.json`, `data/collector.pid` 屬於 runtime 產物，不應提交。

- Stock symbol lookup is not reliable enough yet.
  股票名稱查詢目前仍不夠可靠。

## Next Recommended Task / 下一步建議

建立本地股票主檔快取：`collab/stock-metadata-cache`。

Build a local stock metadata cache: `collab/stock-metadata-cache`.
