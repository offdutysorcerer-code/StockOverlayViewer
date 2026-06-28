# 01 Architecture / 架構

## MVP 架構 / MVP Architecture

目前 MVP 採用「純前端 + 本地 JSON + PowerShell local server + 資料更新腳本」。

The current MVP uses static frontend files, local JSON, a PowerShell local server, and data collector scripts.

```text
External Data Source / 外部資料來源
  ↓
Data Collector Script / 資料更新腳本
  ↓ writes JSON / 寫入 JSON
/data/intraday/*.json
/data/daily/*.json
/data/latest.json
  ↓ read by fetch() / 由前端讀取
Frontend HTML/CSS/JS / 前端
  ↓
Charts / 圖表
```

## Local Server / 本地伺服器

`frontend/` 不是直接用瀏覽器開檔，而是由 `scripts/StartFrontend.ps1` 提供本地 HTTP server。

`frontend/` is served through `scripts/StartFrontend.ps1`, not opened directly as local files.

目前 local server 負責：

The local server currently handles:

- 提供前端靜態檔案。
  Serving frontend static files.

- 提供 `/data/*` JSON 檔案。
  Serving `/data/*` JSON files.

- 儲存 `groups.json` 與 `symbols.json`。
  Saving `groups.json` and `symbols.json`.

- 啟動與停止 mock data collector。
  Starting and stopping the mock data collector.

## Data Collector / 資料更新器

資料更新器只做一件事：

The data collector has one responsibility:

```text
取得資料 → 轉成標準格式 → 寫入 JSON
Fetch data → convert to contract format → write JSON
```

目前 mock collector：

Current mock collector:

```text
scripts/StartDataCollector.ps1
scripts/FetchIntraday.Mock.ps1
scripts/FetchDaily.Mock.ps1
```

## Optional Backend / 選用後端

`backend/StockOverlay.Api` 是未來升級備案，不是目前 MVP 必要路徑。

`backend/StockOverlay.Api` is a future upgrade path and is not required for the current MVP.

適合導入正式後端的情境：

A formal backend is useful when we need:

- 多人共用。
  Multi-user sharing.

- 遠端存取。
  Remote access.

- 統一資料快取與排程。
  Centralized cache and scheduled jobs.

- WebSocket 或 Server-Sent Events。
  WebSocket or Server-Sent Events.
