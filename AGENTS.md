# AGENTS.md / AI 協作者入口

本文件是所有 AI Agent 的第一個入口。

This file is the first entry point for every AI agent.

## 必讀順序 / Required Reading Order

在修改任何檔案前，請依序閱讀：

Before editing any file, read these in order:

1. `AGENTS.md`
2. `STATUS.md`
3. `PROJECT_STATE.md`
4. `docs/README.md`
5. `docs/Contract.md`
6. `docs/governance/README.md`

## 依任務追加閱讀 / Task-specific Reading

### Frontend / 前端任務

Read:

```text
docs/product/Architecture.md
frontend/
```

### Data collector / 資料更新任務

Read:

```text
docs/Contract.md
docs/product/Architecture.md
scripts/
data/groups.json
data/symbols.json
```

### Governance / 治理與流程任務

Read:

```text
docs/governance/README.md
docs/governance/03_GitWorkflow.md
docs/governance/04_AICollaboration.md
docs/governance/06_StatusProtocol.md
```

### Product planning / 產品規劃任務

Read:

```text
docs/product/Roadmap.md
docs/governance/DecisionLog.md
```

## 核心規則 / Core Rules

- 開始工作前，先看 `STATUS.md` 是否有人正在改同一區域。
  Before starting, check `STATUS.md` for active work in the same area.

- 修改 JSON shape、API payload、檔案路徑前，先更新 `docs/Contract.md`。
  Update `docs/Contract.md` before changing JSON shapes, API payloads, or file paths.

- 新功能使用 task branch。
  Use a task branch for new work.

- Commit message 必須使用 Agent 前綴，且提交主題、tag、說明必須採中英雙語。
  Commit messages must use an agent prefix, and commit subjects, tags, and descriptions must be bilingual in Chinese and English.

```text
[ChatGPT]
[LM]
[Human]
[Collab]
```

Commit title format / Commit 主題格式：

```text
[Agent] 中文主題 / English subject
```

Examples / 範例：

```text
[ChatGPT] 修正 UTF-8 匯入 / Fix UTF-8 import
[LM] 新增日 K 圖表 / Add daily candlestick chart
[Human] 重構前端 API / Refactor frontend API
```

Commit body format / Commit 說明格式：

```text
中文：
- 說明修改內容。
- 說明測試結果。

English:
- Describe the changes.
- Describe test results.
```

- 不要提交 runtime 產物。
  Do not commit runtime artifacts.

```text
data/intraday/*.json
data/daily/*.json
data/latest.json
data/collector.pid
```

## 工作完成前 / Before Finishing

每個 Agent 完成工作前必須：

Every agent must:

1. 更新 `STATUS.md`。
   Update `STATUS.md`.

2. 說明修改檔案。
   List changed files.

3. 說明測試或檢查結果。
   State tests or checks run.

4. 建立 commit，或明確說明未 commit。
   Commit changes or clearly state no commit was made.

## 給專案管理者的指令 / Manager Prompt

新協作者加入時，可以直接給這句：

When a new collaborator joins, use this prompt:

```text
請先閱讀 AGENTS.md，並依照 Onboarding 流程開始工作。開始修改前，請回報你已閱讀的文件、目前 Git branch、以及你打算修改的檔案範圍。

Please read AGENTS.md first and follow the onboarding workflow. Before editing, report which files you have read, the current Git branch, and the files or areas you plan to modify.
```
