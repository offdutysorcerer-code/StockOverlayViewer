# StockOverlayViewer

用途：方便觀察股價變化，讓使用者用群組管理股票代號，並將選擇的個股走勢圖疊加在畫面上。

## MVP 技術方向

本專案主線改為：

```text
純前端 HTML/CSS/JS
  ↓ 讀取本地 JSON
本地資料檔 data/*.json
  ↑ 由 scripts 更新
資料更新器 PowerShell / Python / C# Console / Browser Automation fallback
```

## 為什麼 MVP 先不使用後端 API

目前需求重點是觀察股價走勢，不是多人共用系統或複雜權限管理，因此先採用「資料更新器寫 JSON，前端讀 JSON」會比較輕量、好維護。

優點：

- 前端可以直接開發與測試。
- 不需要啟動 ASP.NET Core API 才能看畫面。
- 資料來源可以逐步替換。
- 即時資料與每日 K 線都能用固定格式保存。
- 後續要升級成 C# API 時，資料契約可以沿用。

## 核心需求

1. 股票群組管理
   - 使用 JSON 管理群組與股票代號。
   - 前端可選擇群組與多檔股票。

2. 疊加走勢圖
   - 選擇多檔股票。
   - 即時走勢圖 intraday overlay。
   - 每日 K 線圖 daily candles。
   - 支援 Indexed = 100 正規化比較。

3. 資料更新
   - 即時資料：交易時間內定期更新。
   - 日 K 資料：每日收盤後或開盤前更新。
   - 優先使用直接資料 endpoint。
   - 找不到直接資料來源時，才使用 browser automation。

## 資料夾結構

```text
StockOverlayViewer/
├── README.md
├── docs/
│   ├── Architecture.md
│   ├── DataContract.md
│   └── Roadmap.md
├── frontend/
│   ├── index.html
│   ├── css/styles.css
│   └── js/
│       ├── app.js
│       ├── api.js
│       ├── chart.js
│       └── groups.js
├── data/
│   ├── groups.json
│   ├── groups.sample.json
│   ├── latest.json
│   ├── intraday/
│   │   └── 2330.json
│   ├── daily/
│   │   └── 2330.json
│   └── cache/
├── scripts/
│   ├── StartFrontend.ps1
│   ├── StartDataCollector.ps1
│   ├── FetchIntraday.Mock.ps1
│   ├── FetchDaily.Mock.ps1
│   └── FetchDataPlaceholder.ps1
└── backend/
    └── StockOverlay.Api/
        └── optional backend backup
```

## 建議啟動方式

先啟動前端：

```powershell
cd D:\MarketResearch\Apps\StockOverlayViewer\frontend
python -m http.server 5174
```

開啟：

```text
http://localhost:5174
```

產生 mock 資料：

```powershell
cd D:\MarketResearch\Apps\StockOverlayViewer
.\scripts\StartDataCollector.ps1 -Mock
```

## 資料來源策略

建議優先順序：

1. 直接資料 endpoint / JSON / CSV。
2. PowerShell 或 Python 抓取資料並寫成 JSON。
3. C# Console App 資料更新器。
4. Browser automation，只作為最後選項。

## 備註

`backend/StockOverlay.Api` 先保留，未來如果需要 API、快取、權限、多裝置同步，再升級使用。

## 協作模式 (Collaboration Mode)

本專案採用 **雙 AI 協作開發** 模式，透過明確分工與版本控制來避免衝突。

| 角色 | 負責範圍 | 溝通機制 |
| :--- | :--- | :--- |
| **LM Studio (我)** | 資料層 (`scripts/`, `data/`)、後端邏輯 | 更新 `STATUS.md`、遵守 `docs/Contract.md` |
| **ChatGPT** | 展示層 (`frontend/`)、UI/UX | 更新 `STATUS.md`、遵守 `docs/Contract.md` |

**協作規範：**
1.  **數據契約**：任何 JSON 結構變更必須優先更新 `docs/Contract.md`。
2.  **狀態同步**：每個 AI 在開始工作前需讀取 `STATUS.md`，工作結束後更新進度。
3.  **版本控制**：使用 Git 追蹤歷史，Commit Message 需標註來源 (例如 `[LM]`, `[Chat]`)。

## 開發進度

- **2026-06-28**：
  - [x] 專案初始化與 Git 倉庫建立。
  - [x] 建立 `docs/Contract.md` 定義 JSON 數據結構。
  - [x] 建立 `STATUS.md` 用於雙 AI 狀態同步。
  - [x] 前端服務 (Port 5174) 測試啟動成功。
