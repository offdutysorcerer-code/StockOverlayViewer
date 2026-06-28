# StockOverlay.Api

ASP.NET Core Minimal API backend for StockOverlayViewer.

## 目標

提供前端需要的資料：

- 股票群組
- 即時走勢 intraday
- 每日 K 線 daily candles

## 建議建立專案指令

在此資料夾執行：

```powershell
dotnet new web -n StockOverlay.Api
```

若已經位於 `backend/StockOverlay.Api`，則可使用：

```powershell
dotnet new web
```

接著把本資料夾內的 `Program.cs` 覆蓋 dotnet 產生的檔案。

## 啟動

```powershell
dotnet run --urls http://localhost:5088
```

前端預設 API_BASE_URL：

```text
http://localhost:5088
```

## API

```text
GET /api/health
GET /api/groups
GET /api/stocks/{symbol}/intraday
GET /api/stocks/{symbol}/daily
```

## 下一步

目前 Program.cs 使用 mock data。後續應拆出：

```text
Models/
Services/IStockPriceProvider.cs
Services/MockStockPriceProvider.cs
Services/RealDataProvider.cs
Data/groups.json
```
