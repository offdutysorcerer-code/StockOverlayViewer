# Data Contract (數據契約)

本文件定義 `StockOverlayViewer` 專案中前後端交換的 JSON 格式。
**請雙方 AI 務必遵守此格式，以免產生串接錯誤。**

## 1. `data/groups.json` (群組設定)
```json
{
  "groups": [
    {
      "id": "tech",
      "name": "科技股",
      "symbols": ["2330", "2454", "3034"]
    }
  ]
}
```

## 2. `data/latest.json` (即時資料索引)
```json
{
  "updatedAt": "2026-06-28T21:30:00+08:00",
  "mode": "mock",
  "symbols": {
    "2330": {
      "intraday": "data/intraday/2330.json",
      "daily": "data/daily/2330.json",
      "status": "mock"
    }
  }
}
```

## 3. `data/intraday/{symbol}.json` (即時走勢)
```json
{
  "symbol": "2330",
  "data": [
    { "time": "09:00", "price": 200.0 },
    { "time": "09:01", "price": 200.5 }
  ]
}
```

## 4. `data/daily/{symbol}.json` (每日 K 線)
```json
{
  "symbol": "2330",
  "data": [
    { "date": "2026-06-27", "open": 198, "high": 202, "low": 197, "close": 200, "volume": 50000 }
  ]
}
```
