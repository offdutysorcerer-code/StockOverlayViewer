# 05 Coding Standard / 程式碼規範

## 目標 / Goal

保持程式碼簡單、可讀、可由多個 Agent 安全修改。

Keep code simple, readable, and safe for multiple agents to modify.

## Frontend / 前端

目前前端使用 HTML、CSS、JavaScript，不使用 build step。

The current frontend uses HTML, CSS, and JavaScript without a build step.

規則 / Rules:

- 使用 ES modules。
  Use ES modules.

- 避免一次重寫整個檔案。
  Avoid rewriting entire files when a small change is enough.

- UI 文字可以先英文，之後再導入 i18n。
  UI text can remain English first; i18n can be added later.

- 前端不得直接依賴外部股價網站。
  The frontend must not directly depend on external quote websites.

## PowerShell / PowerShell 腳本

必須相容 Windows PowerShell 5.1，除非文件明確說明只支援 PowerShell 7。

Scripts must support Windows PowerShell 5.1 unless documented otherwise.

規則 / Rules:

- 不使用 `??` null-coalescing operator。
  Do not use the `??` null-coalescing operator.

- 寫 JSON 時使用 UTF-8 without BOM。
  Write JSON as UTF-8 without BOM.

- 對外部網路請求要有 timeout。
  External web requests must have timeouts.

- Runtime output 寫入 `data/`，不要寫入 `frontend/`。
  Runtime output should go under `data/`, not `frontend/`.

## JSON / JSON 檔案

- 遵守 `docs/Contract.md`。
  Follow `docs/Contract.md`.

- 盡量保持 key 穩定。
  Keep keys stable.

- 新欄位優先做 optional。
  Prefer optional fields for extensions.

## Documentation / 文件

治理文件採用中文優先、英文輔助。

Governance documents should be Chinese-first and English-assisted.

格式 / Format:

```md
## 中文標題 / English Title

中文說明。
English explanation.
```
