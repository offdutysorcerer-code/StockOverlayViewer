# Documentation Index / 文件索引

本資料夾採用「入口清楚、治理集中、舊文件歸檔」的結構。

This folder uses a clear-entry, centralized-governance, archived-legacy structure.

## 必讀入口 / Required Entry Points

| 文件 File | 用途 Purpose |
|---|---|
| `../STATUS.md` | 即時協作狀態 / live collaboration board |
| `Contract.md` | 唯一正式資料契約 / canonical data contract |
| `governance/README.md` | 治理文件入口 / governance docs index |

## Governance / 治理文件

多 AI、多機協作規範集中在：

Multi-agent and multi-machine collaboration rules are centralized in:

```text
docs/governance/
```

建議閱讀順序：

Suggested reading order:

```text
docs/governance/README.md
```

## Product Docs / 產品與技術文件

產品架構、Roadmap 等長期技術文件放在：

Product architecture, roadmap, and long-lived technical documents are stored in:

```text
docs/product/
```

目前包含：

Current files:

- `product/Architecture.md`
- `product/Roadmap.md`

## Archive / 歸檔區

舊版治理入口、重複契約草案與已被取代的文件放在：

Legacy governance entries, duplicated contract drafts, and superseded files are archived in:

```text
docs/archive/legacy/
```

歸檔文件只供追溯，不應作為目前規範。

Archived files are for historical reference only and must not be treated as current rules.

## Canonical Contract Rule / 正式契約規則

所有 JSON shape、API payload、資料檔路徑變更，都必須先更新：

All JSON shape, API payload, and data path changes must update this first:

```text
docs/Contract.md
```
