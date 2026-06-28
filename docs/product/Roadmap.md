# Roadmap

## Phase 0 - Static Data MVP

- [x] 建立專案資料夾
- [x] 建立前端 HTML/CSS/JS 骨架
- [x] 建立本地 JSON 資料結構
- [x] 建立 mock data collector 腳本
- [ ] 前端穩定讀取 data/groups.json
- [ ] 前端讀取 data/intraday/{symbol}.json
- [ ] 前端讀取 data/daily/{symbol}.json

## Phase 1 - Local JSON Viewer

- [ ] 使用者可以選取群組與股票代號
- [ ] 即時走勢圖可疊加多檔股票
- [ ] 每日 K 線圖可切換股票
- [ ] 支援 Actual Price / Indexed Price 顯示模式
- [ ] 顯示資料更新時間與資料來源
- [ ] 顯示資料過期警示

## Phase 2 - Data Collector

- [ ] 建立正式的資料更新器
- [ ] 交易時間內更新 intraday JSON
- [ ] 收盤後更新 daily JSON
- [ ] 寫入 latest.json 作為總覽索引
- [ ] 加入錯誤紀錄 logs

## Phase 3 - Real Data Source

- [ ] 評估台股即時資料來源
- [ ] 評估台股日 K 資料來源
- [ ] 優先使用直接 endpoint
- [ ] 找不到 endpoint 時再考慮 browser automation
- [ ] 設計節流與快取，避免過度刷新

## Phase 4 - Optional Backend

- [ ] 評估是否需要 ASP.NET Core API
- [ ] 若需要，再把 JSON 資料層升級成 API
- [ ] 加入 SQLite 或 LiteDB
- [ ] 加入 WebSocket 或 Server-Sent Events

## 原則

1. 先能用，再追求完整。
2. 前端只讀標準資料格式，不直接依賴外部資料來源。
3. 資料更新器負責處理資料來源差異。
4. Browser automation 只作為 fallback。
