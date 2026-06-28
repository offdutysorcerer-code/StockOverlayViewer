# Data Contract

## Stock Symbol

台股代號建議先用純股票代號，例如：

```json
"2330"
```

未來若要支援多市場，可改為：

```json
"TWSE:2330"
"TPEX:6488"
"NASDAQ:NVDA"
```

## Group

```json
{
  "id": "ai-server",
  "name": "AI 伺服器",
  "symbols": ["2330", "2382", "3231", "6669"],
  "description": "AI 伺服器與相關供應鏈"
}
```

## Intraday Point

即時走勢圖資料格式：

```json
{
  "symbol": "2330",
  "date": "2026-06-28",
  "points": [
    {
      "time": "09:00:00",
      "price": 1000.0,
      "volume": 1250
    }
  ],
  "source": "mock",
  "updatedAt": "2026-06-28T09:01:00+08:00"
}
```

## Daily Candle

每日 K 線資料格式：

```json
{
  "symbol": "2330",
  "candles": [
    {
      "date": "2026-06-28",
      "open": 1000.0,
      "high": 1020.0,
      "low": 995.0,
      "close": 1010.0,
      "volume": 45000
    }
  ],
  "source": "mock",
  "updatedAt": "2026-06-28T15:00:00+08:00"
}
```

## Batch Request

```json
{
  "symbols": ["2330", "2454", "2317"],
  "range": "1D"
}
```

Daily range 建議：

```text
1M, 3M, 6M, YTD, 1Y, 3Y, 5Y
```

Intraday range 建議：

```text
1D
```

## Error Response

```json
{
  "error": "DataSourceUnavailable",
  "message": "資料來源暫時無法取得",
  "symbol": "2330"
}
```
