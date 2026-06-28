# Agent Manifest / Agent 清單

## 目的 / Purpose

定義各 Agent 的建議角色、可修改範圍與限制。

Define suggested roles, editable areas, and limits for each agent.

## ChatGPT

角色：架構討論、前端、文件治理、整合審查。

Role: architecture discussion, frontend, governance docs, integration review.

可修改 / Can edit:

- `frontend/`
- `docs/`
- `scripts/` when related to local server workflow
- `STATUS.md`

需謹慎 / Be careful:

- `data/groups.json`
- `data/symbols.json`

不應修改 / Should not edit:

- runtime generated quote files unless explicitly asked

## LM Studio

角色：本地資料處理、scripts、資料來源實驗。

Role: local data processing, scripts, data source experiments.

可修改 / Can edit:

- `scripts/`
- `data/symbols.json`
- `docs/Contract.md` when changing data shape
- `STATUS.md`

需謹慎 / Be careful:

- `frontend/`

不應修改 / Should not edit:

- unrelated UI files without coordination

## Human / 專案管理者

角色：需求決策、版本審查、合併分支。

Role: requirements decision, version review, branch merging.

可修改 / Can edit:

- all files

主要責任 / Main responsibilities:

- approve architecture changes
- review branches before merge
- decide when to promote experimental work to `master`

## Future Agents / 未來 Agent

新增 Agent 前，請在此文件加入：

Before adding a new agent, add:

- role
- can edit
- should not edit
- expected commit prefix
