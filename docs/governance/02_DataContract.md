# 02 Data Contract / 資料契約

本文件是 `docs/Contract.md` 的雙語治理版本。正式資料形狀仍以 `docs/Contract.md` 為 canonical source。

This is the bilingual governance version of `docs/Contract.md`. The canonical data shapes remain in `docs/Contract.md`.

## 基本規則 / Basic Rules

- JSON 必須使用 UTF-8 without BOM。
  JSON files must use UTF-8 without BOM.

- 股票代號使用純字串，例如 `2330`。
  Stock symbols are plain strings, for example `2330`.

- 寫入端必須遵守契約。
  Writers must follow the contract.

- 讀取端應盡量容忍 optional fields。
  Readers should tolerate optional fields.

## groups.json / 群組設定

目前正式格式是 top-level array，不是 `{ "groups": [] }`。

The canonical shape is a top-level array, not `{ "groups": [] }`.

```json
[
  {
    "id": "semiconductor-core",
    "name": "Semiconductor Core",
    "displayNameKey": "group.semiconductorCore",
    "symbols": ["2330", "2454", "2303", "3034"],
    "descriptionKey": "group.semiconductorCore.description"
  }
]
```

## symbols.json / 股票主檔

```json
{
  "2330": {
    "name": "TSMC",
    "displayName": "台積電",
    "market": "TWSE",
    "industry": "Semiconductor",
    "source": "manual-or-provider",
    "updatedAt": "2026-06-28T22:00:00+08:00"
  }
}
```

## intraday JSON / 即時走勢資料

```json
{
  "symbol": "2330",
  "date": "2026-06-28",
  "iteration": 3,
  "simulatedTime": "09:10:00",
  "isComplete": false,
  "points": [
    { "time": "09:00:00", "price": 575.98, "volume": 580 }
  ],
  "source": "mock-powershell-progressive",
  "updatedAt": "2026-06-28T22:14:07+08:00"
}
```

## daily JSON / 日 K 資料

```json
{
  "symbol": "2330",
  "candles": [
    {
      "date": "2026-06-26",
      "open": 1015,
      "high": 1025,
      "low": 1008,
      "close": 1020,
      "volume": 63000
    }
  ],
  "source": "sample",
  "updatedAt": "2026-06-28T00:00:00+08:00"
}
```

## Deprecated / 已棄用格式

以下舊格式不得再新增使用：

Do not create new files with these old shapes:

```json
{ "groups": [] }
```

```json
{ "symbol": "2330", "data": [] }
```
