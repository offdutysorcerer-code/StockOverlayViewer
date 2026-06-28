# Git Strategy / Git 策略

> This file is kept as a short entry point. The bilingual canonical workflow is in `docs/governance/03_GitWorkflow.md`.
>
> 本文件保留作為簡短入口。正式雙語 Git 流程在 `docs/governance/03_GitWorkflow.md`。

## Branches / 分支

`master` should stay stable.

`master` 應保持穩定。

Use task branches:

使用任務分支：

```text
chatgpt/<short-task>
lm/<short-task>
human/<short-task>
collab/<short-task>
```

## Commit Prefix / Commit 前綴

```text
[ChatGPT]
[LM]
[Human]
[Collab]
```

## Runtime Data / Runtime 資料

Do not commit runtime quote output.

不要提交即時產生的報價資料。

```text
data/intraday/*.json
data/daily/*.json
data/latest.json
data/collector.pid
```

## Full Workflow / 完整流程

See:

請見：

```text
docs/governance/03_GitWorkflow.md
```
