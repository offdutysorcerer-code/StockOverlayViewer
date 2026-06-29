# Data Contract

This is the canonical data contract for StockOverlayViewer.
All agents must update this file before changing JSON shapes, API payloads, or file paths.

## Canonical rules

- JSON files must be UTF-8 without BOM.
- Stock symbols are plain strings, for example `2330`.
- Generated runtime quote files must not be treated as source code.
- Frontend readers must tolerate optional fields, but writers must follow this contract.

## data/groups.json

Current canonical shape is a top-level array, not an object wrapper.

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

Required fields:

- `id`: stable group id.
- `name`: fallback display name.
- `symbols`: array of stock symbol strings.

Optional fields:

- `displayNameKey`
- `descriptionKey`

## data/symbols.json

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

Required key:

- top-level key is the stock symbol.

Recommended fields:

- `name`: English or romanized company name.
- `displayName`: Chinese display name.
- `market`: `TWSE`, `TPEx`, `ETF`, or `unknown`.
- `industry`
- `source`
- `updatedAt`

## data/latest.json

```json
{
  "updatedAt": "2026-06-28T22:14:07+08:00",
  "mode": "mock",
  "iteration": 55,
  "symbols": {
    "2330": {
      "intraday": "data/intraday/2330.json",
      "daily": "data/daily/2330.json",
      "status": "mock"
    }
  }
}
```

## data/intraday/{symbol}.json

```json
{
  "symbol": "2330",
  "date": "2026-06-28",
  "iteration": 3,
  "simulatedTime": "09:10:00",
  "isComplete": false,
  "points": [
    { "time": "09:00:00", "price": 575.98, "volume": 580 },
    { "time": "09:05:00", "price": 576.64, "volume": 910 }
  ],
  "source": "mock-powershell-progressive",
  "updatedAt": "2026-06-28T22:14:07+08:00"
}
```

Required fields:

- `symbol`
- `points`
- `source`
- `updatedAt`

Point fields:

- `time`: `HH:mm:ss`
- `price`: number
- `volume`: number

## data/daily/{symbol}.json

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

Required fields:

- `symbol`
- `candles`
- `source`
- `updatedAt`

## Local server API

Current local server is `scripts/StartFrontend.ps1`.

```text
GET  /api/symbols/lookup?symbol=2330
POST /api/groups/save
POST /api/symbols/save
POST /api/collector/start?intervalSeconds=2&durationSeconds=60&provider=mock
POST /api/collector/stop
GET  /api/collector/status
```

### Collector provider query

- `provider` is optional and defaults to `mock`.
- Supported values are currently `mock` and `twse`.
- `twse` is reserved for the production Taiwan Stock Exchange provider and may return a clear not-implemented error until provider scripts are completed.
- Provider-specific scripts must still write the canonical `data/intraday/{symbol}.json`, `data/daily/{symbol}.json`, and `data/latest.json` shapes above.

## Deprecated draft shapes

The earlier LM Studio draft used:

```json
{ "groups": [] }
```

and intraday/daily arrays named `data`.

Those shapes are deprecated. Agents must use the current canonical shapes above unless this file is updated first.
