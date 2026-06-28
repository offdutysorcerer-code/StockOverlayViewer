# 06 Status Protocol / 狀態同步規範

## 目的 / Purpose

`STATUS.md` 是多 Agent 協作時的即時看板。

`STATUS.md` is the live coordination board for multi-agent development.

## 何時更新 / When to Update

以下情況必須更新：

Update it when:

- Agent 開始一項新任務。
  An agent starts a new task.

- Agent 修改跨區域檔案。
  An agent changes files across ownership boundaries.

- 發現衝突或阻塞。
  A conflict or blocker is found.

- Agent 完成任務。
  An agent finishes a task.

## 建議格式 / Suggested Format

```md
| Agent | Status | Files / Area | Notes |
|---|---|---|---|
| ChatGPT | WORKING | docs/governance/ | Converting governance docs to bilingual format |
| LM Studio | IDLE | - | Waiting for next task |
| Human | REVIEW | Git baseline | Reviewing collaboration process |
```

## 狀態值 / Status Values

```text
IDLE       閒置
PLANNING   規劃中
WORKING    開發中
BLOCKED    阻塞
DONE       完成
REVIEW     待審查
```

## 注意事項 / Notes

- `STATUS.md` 不是詳細日誌。
  `STATUS.md` is not a detailed log.

- 重大決策應寫入 `docs/governance/DecisionLog.md`。
  Major decisions should be recorded in `docs/governance/DecisionLog.md`.

- 完成工作後要留下下一步建議。
  Leave a next-step recommendation after finishing work.
