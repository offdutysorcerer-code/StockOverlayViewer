# Architecture

## MVP 架構

StockOverlayViewer 的 MVP 採用「純前端 + 本地 JSON + 資料更新腳本」。

```text
External Data Source
  ↓
Data Collector Script
  ↓ writes JSON
/data/intraday/*.json
/data/daily/*.json
/data/latest.json
  ↓ read by fetch()
Frontend HTML/CSS/JS
  ↓
Charts
```

## 為什麼不用後端作為第一版主線

目前需求是個人研究與觀察用途，資料流可以先簡化為本地檔案：

- 前端不需要登入、權限或交易功能。
- 群組與股票代號可以用 JSON 管理。
- 即時資料可以由獨立腳本更新。
- 每日 K 線可以由獨立腳本更新。
- 未來若要升級 API，資料格式可以直接沿用。

## 前端

技術：HTML + CSS + JavaScript。

主要責任：

- 讀取 `data/groups.json`。
- 依群組顯示股票代號。
- 定時讀取 `data/intraday/{symbol}.json`。
- 讀取 `data/daily/{symbol}.json`。
- 繪製即時走勢疊圖。
- 顯示每日 K 線。

## 資料更新器

初始建議使用 PowerShell 或 Python。

原因：

- 快速開發。
- 容易手動測試。
- 容易排程。
- 可逐步替換資料來源。

資料更新器只做一件事：

```text
取得資料 → 轉成標準格式 → 寫入 JSON
```

## Browser Automation 的定位

Browser automation 不作為第一優先，因為：

- 資源負擔較高。
- 長時間執行穩定性較差。
- 網頁 DOM 變動容易導致失效。
- 頻繁刷新可能被網站限制。

只有在沒有可直接請求的資料 endpoint 時，才使用 browser automation。

## 後端備案

`backend/StockOverlay.Api` 保留作為未來升級方向。

適合導入後端的情境：

- 需要集中快取。
- 需要多人共用。
- 需要遠端存取。
- 需要統一管理資料來源。
- 需要 WebSocket 推送。
- 需要更細緻的錯誤處理與監控。

## 建議資料更新頻率

```text
即時走勢：交易時間內每 5～10 秒更新一次
每日 K 線：每日收盤後更新一次
前端讀取：每 3～5 秒重新讀取 JSON
```

## 檔案流

```text
scripts/StartDataCollector.ps1
  ├── scripts/FetchIntraday.Mock.ps1
  ├── scripts/FetchDaily.Mock.ps1
  └── future real provider
        ↓
data/intraday/{symbol}.json
data/daily/{symbol}.json
data/latest.json
        ↓
frontend/js/api.js
        ↓
frontend/js/chart.js
```
