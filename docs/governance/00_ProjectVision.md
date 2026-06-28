# 00 Project Vision / 專案願景

## 目的 / Purpose

建立一個輕量、可維護、可由多個 AI Agent 協作開發的股價觀察工具。

Build a lightweight and maintainable stock overlay viewer that can be developed collaboratively by multiple AI agents.

## 核心目標 / Core Goals

1. 用群組管理股票代號。
   Manage stock symbols with groups.

2. 疊加多檔股票的即時走勢圖。
   Overlay intraday price lines for multiple symbols.

3. 逐步加入每日 K 線、相對強弱、族群比較。
   Gradually add daily charts, relative strength, and sector comparison.

4. 先以本地 JSON 與 PowerShell local server 完成 MVP。
   Use local JSON and a PowerShell local server for the MVP.

5. 後續可升級成正式後端或共用資料服務。
   Allow future migration to a formal backend or shared data service.

## MVP 原則 / MVP Principles

- 先能用，再完善。
  Make it usable first, then refine.

- 先穩定資料契約，再擴充功能。
  Stabilize the data contract before expanding features.

- 前端只讀標準資料格式，不直接依賴外部資料來源。
  The frontend reads standard data formats and should not directly depend on external providers.

- 資料來源差異由 scripts 或 future backend 消化。
  Provider differences are handled by scripts or a future backend.

- Runtime 產生的資料不應該污染版本控制。
  Runtime-generated files should not pollute version control.

## 非目標 / Non-goals

- 本工具目前不處理下單。
  This tool does not place trades.

- 本工具目前不處理使用者權限。
  This tool does not manage user authentication or authorization.

- MVP 不要求正式 ASP.NET 後端。
  The MVP does not require a formal ASP.NET backend.
