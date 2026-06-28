# Project Status / 專案狀態

此文件是多 Agent 協作時的即時看板，保留在專案根目錄，方便所有 Agent 一開始就讀取。

This file is the live coordination board for multi-agent collaboration. It stays at the project root so every agent can find it first.

## Current Status / 目前狀態

| Agent | Status | Files / Area | Notes |
|---|---|---|---|
| LM Studio | IDLE | `scripts/`, `data/`, `docs/Contract.md` | Waiting for next task. |
| ChatGPT | DONE | `docs/`, `STATUS.md` | Reorganized documentation into governance, product, and archive areas. |
| Human | REVIEW | docs structure, Git branch | Review the new documentation structure before merge. |

## Documentation Entry / 文件入口

請從這裡開始：

Start here:

```text
docs/README.md
```

核心文件：

Core files:

```text
docs/Contract.md                 canonical data contract / 正式資料契約
docs/governance/README.md        governance index / 治理文件入口
docs/product/README.md           product docs index / 產品文件入口
docs/archive/legacy/README.md    archived legacy docs / 舊文件歸檔
```

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
