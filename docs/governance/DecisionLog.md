# Decision Log / 決策紀錄

此文件記錄重大架構決策，避免後續 Agent 重複討論或誤解背景。

This file records major architecture decisions so future agents do not need to rediscover context.

---

## 2026-06-28 - MVP uses local JSON and PowerShell server

### 決策 / Decision

MVP 暫時不使用正式 ASP.NET 後端，改用：

The MVP does not use a formal ASP.NET backend yet. It uses:

```text
frontend HTML/CSS/JS
PowerShell local server
local JSON files
data collector scripts
```

### 原因 / Reason

- 降低初期複雜度。
  Reduce early complexity.

- 使用者主要是個人研究與觀盤。
  The primary use case is personal research and monitoring.

- 前端與資料契約可以先穩定。
  Frontend and data contract can stabilize first.

### 影響 / Impact

- `scripts/StartFrontend.ps1` 成為 MVP runtime 的 local server。
  `scripts/StartFrontend.ps1` is the MVP local server.

- `backend/StockOverlay.Api` 保留為未來備案。
  `backend/StockOverlay.Api` remains a future option.

---

## 2026-06-28 - Use progressive mock intraday data

### 決策 / Decision

Mock intraday data must grow from 09:00 toward 13:30 instead of rendering a full-day line immediately.

Mock 即時資料必須從 09:00 逐步往 13:30 產生，而不是一開始就畫完整天。

### 原因 / Reason

這樣比較接近實際盤中資料流，也方便測試前端更新效果。

This better simulates real intraday data flow and makes frontend update behavior easier to test.

---

## 2026-06-28 - Governance docs should be bilingual

### 決策 / Decision

治理文件採中文優先、英文輔助。

Governance documents are Chinese-first and English-assisted.

### 原因 / Reason

- 專案管理者閱讀中文較快。
  The project manager reads Chinese faster.

- AI Agent 對英文技術詞彙理解穩定。
  AI agents often understand technical English consistently.

- 雙語格式可兼顧管理與自動化協作。
  Bilingual docs support both management and automated collaboration.
