# 04 AI Collaboration / AI 協作規範

## 目的 / Purpose

避免多個 AI Agent 同時修改同一區域造成衝突，並讓專案管理者可以快速掌握狀態。

Prevent conflicts when multiple AI agents edit the same project, and help the project manager understand the current state quickly.

## 開工前必讀 / Required Reading Before Work

每個 Agent 開始修改前必須閱讀：

Every agent must read these before editing:

1. `STATUS.md`
2. `docs/Contract.md`
3. `docs/governance/03_GitWorkflow.md`
4. 與任務相關的檔案。
   Files related to the task.

## 收工前必做 / Required Steps Before Finish

每個 Agent 完成後必須：

Every agent must:

1. 更新 `STATUS.md`。
   Update `STATUS.md`.

2. 說明修改了哪些檔案。
   List changed files.

3. 說明是否有測試。
   State whether tests or checks were run.

4. 建立 commit，或明確說明未 commit。
   Commit changes or clearly state that no commit was made.

## 權責範圍 / Ownership Map

| 區域 Area | 主要負責 Primary Owner | 備註 Notes |
|---|---|---|
| `frontend/` | ChatGPT | UI, chart, interaction |
| `scripts/` | LM Studio / ChatGPT | local server, collectors |
| `data/groups.json` | Shared | user watchlists / groups |
| `data/symbols.json` | Shared | stock metadata |
| `data/intraday/` | Runtime | generated output |
| `data/daily/` | Runtime | generated output |
| `docs/Contract.md` | Shared | canonical data contract |
| `docs/governance/` | Shared | project rules |
| `backend/` | Future owner | optional backend |

## 狀態值 / Status Values

```text
IDLE       閒置 / not working
PLANNING   規劃中 / reading and planning
WORKING    開發中 / editing files
BLOCKED    阻塞 / waiting for decision or access
DONE       完成 / finished changes
REVIEW     待審查 / waiting for human review
```

## 禁止事項 / Do Not

- 不要未讀 `STATUS.md` 就開始修改。
  Do not edit without reading `STATUS.md`.

- 不要默默改資料契約。
  Do not silently change the data contract.

- 不要提交 runtime quote output。
  Do not commit runtime quote output.

- 不要把大範圍重寫當成小修改。
  Do not perform large rewrites as if they are small edits.
