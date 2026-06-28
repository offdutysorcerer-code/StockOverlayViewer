# 03 Git Workflow / Git 工作流程

## 目標 / Goal

使用 Git 讓多 AI、多機器協作可以回溯、比較與安全復原。

Use Git to make multi-agent and multi-machine development traceable, comparable, and recoverable.

## 分支策略 / Branch Strategy

`master` 保持相對穩定。新功能請使用 task branch。

Keep `master` relatively stable. Use task branches for new work.

建議分支命名：

Suggested branch names:

```text
chatgpt/<short-task>
lm/<short-task>
human/<short-task>
collab/<short-task>
```

例子 / Examples:

```text
chatgpt/daily-overlay
lm/stock-metadata-cache
collab/contract-v2
```

## Commit 訊息 / Commit Messages

Commit message 必須標註來源。

Commit messages must include an agent prefix.

```text
[ChatGPT] Add daily overlay chart
[LM] Add stock metadata cache builder
[Human] Adjust semiconductor watchlist
[Collab] Align contract and implementation
```

## 應提交內容 / What to Commit

應提交：

Commit:

- `frontend/`
- `scripts/`
- `backend/`
- `docs/`
- `STATUS.md`
- `data/groups.json`
- `data/groups.sample.json`
- `data/symbols.json`

## 不應提交內容 / What Not to Commit

不應提交 runtime 產物：

Do not commit runtime artifacts:

- `data/intraday/*.json`
- `data/daily/*.json`
- `data/latest.json`
- `data/collector.pid`
- `logs/`
- temporary files

## 開始工作前 / Before Work

```powershell
git status --short --branch
```

如果有不屬於你的修改，先停止並確認。

If there are unrelated changes, stop and ask for direction.

## 提交前 / Before Commit

```powershell
git status --short
git diff --stat
```

PowerShell 腳本至少做語法檢查。

Run at least a syntax check for PowerShell scripts.

```powershell
$errors = $null
[System.Management.Automation.PSParser]::Tokenize((Get-Content .\scripts\StartFrontend.ps1 -Raw), [ref]$errors) | Out-Null
$errors
```
