const DATA_BASE_URL = "../data";
const STORAGE_GROUPS_KEY = "stockOverlay.groups.v1";
const STORAGE_SYMBOLS_KEY = "stockOverlay.symbols.v1";

export async function getGroups() {
  return await fetchJson(`${DATA_BASE_URL}/groups.json`, `${DATA_BASE_URL}/groups.sample.json`);
}

export async function saveGroups(groups) {
  localStorage.setItem(STORAGE_GROUPS_KEY, JSON.stringify(groups));
  try { await postJson("/api/groups/save", groups); }
  catch (error) { console.warn("Failed to save groups to file. localStorage fallback used.", error); }
}

export async function resetGroups() {
  localStorage.removeItem(STORAGE_GROUPS_KEY);
  return await fetchJson(`${DATA_BASE_URL}/groups.json`, `${DATA_BASE_URL}/groups.sample.json`);
}

export async function getSymbolsMeta() {
  const fileSymbols = await fetchJson(`${DATA_BASE_URL}/symbols.json`).catch(() => ({}));
  const localSymbols = loadJsonFromStorage(STORAGE_SYMBOLS_KEY) ?? {};
  return { ...getBuiltInChineseSymbolNames(), ...fileSymbols, ...localSymbols };
}

export async function saveSymbolsMeta(symbolsMeta) {
  localStorage.setItem(STORAGE_SYMBOLS_KEY, JSON.stringify(symbolsMeta));
  try { await postJson("/api/symbols/save", symbolsMeta); }
  catch (error) { console.warn("Failed to save symbols to file. localStorage fallback used.", error); }
}

export async function lookupSymbol(symbol) {
  const normalized = symbol.trim().toUpperCase();
  const response = await fetch(`/api/symbols/lookup?symbol=${encodeURIComponent(normalized)}`, { cache: "no-store" });
  if (!response.ok) throw new Error(`Lookup failed: ${response.status}`);
  return await response.json();
}

export async function startMockFeed(intervalSeconds = 2, durationSeconds = 60) {
  return await postJson(`/api/collector/start?intervalSeconds=${intervalSeconds}&durationSeconds=${durationSeconds}`, {});
}

export async function stopMockFeed() {
  return await postJson("/api/collector/stop", {});
}

export async function getCollectorStatus() {
  return await fetchJson("/api/collector/status");
}

export async function getIntraday(symbol) {
  try { return await fetchJson(`${DATA_BASE_URL}/intraday/${symbol}.json`); }
  catch (error) { return createMockIntraday(symbol); }
}

export async function getDaily(symbol) {
  try { return await fetchJson(`${DATA_BASE_URL}/daily/${symbol}.json`); }
  catch (error) { return createMockDaily(symbol); }
}

export async function getLatestIndex() {
  try { return await fetchJson(`${DATA_BASE_URL}/latest.json`); }
  catch (error) { return { updatedAt: new Date().toISOString(), mode: "fallback", symbols: {} }; }
}

async function fetchJson(primaryUrl, fallbackUrl = null) {
  try {
    const response = await fetch(`${primaryUrl}${primaryUrl.includes("?") ? "&" : "?"}t=${Date.now()}`, { cache: "no-store" });
    if (!response.ok) throw new Error(`Fetch error: ${response.status} ${primaryUrl}`);
    return await response.json();
  } catch (error) {
    if (!fallbackUrl) throw error;
    const fallbackResponse = await fetch(`${fallbackUrl}?t=${Date.now()}`, { cache: "no-store" });
    if (!fallbackResponse.ok) throw new Error(`Fetch error: ${fallbackResponse.status} ${fallbackUrl}`);
    return await fallbackResponse.json();
  }
}

async function postJson(url, value) {
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(value)
  });
  if (!response.ok) throw new Error(`POST failed: ${response.status} ${url}`);
  return await response.json();
}

function loadJsonFromStorage(key) {
  try { const raw = localStorage.getItem(key); return raw ? JSON.parse(raw) : null; }
  catch { return null; }
}

function getBuiltInChineseSymbolNames() {
  return {
    "2303": { name: "UMC", displayName: "\u806f\u96fb" },
    "2308": { name: "Delta", displayName: "\u53f0\u9054\u96fb" },
    "2327": { name: "Yageo", displayName: "\u570b\u5de8" },
    "2330": { name: "TSMC", displayName: "\u53f0\u7a4d\u96fb" },
    "2356": { name: "Inventec", displayName: "\u82f1\u696d\u9054" },
    "2382": { name: "Quanta", displayName: "\u5ee3\u9054" },
    "2454": { name: "MediaTek", displayName: "\u806f\u767c\u79d1" },
    "2481": { name: "Pan Jit", displayName: "\u5f37\u8302" },
    "2492": { name: "Walsin", displayName: "\u83ef\u65b0\u79d1" },
    "3016": { name: "Episil", displayName: "\u5609\u6676" },
    "3026": { name: "Holy Stone", displayName: "\u79be\u4f38\u5802" },
    "3034": { name: "Novatek", displayName: "\u806f\u8a60" },
    "3231": { name: "Wistron", displayName: "\u7def\u5275" },
    "5425": { name: "TSC", displayName: "\u53f0\u534a" },
    "6669": { name: "Wiwynn", displayName: "\u7def\u7a4e" },
    "8043": { name: "Honey Hope", displayName: "\u871c\u671b\u5be6" },
    "8261": { name: "AP Memory", displayName: "\u5bcc\u9f0e" }
  };
}

function createMockIntraday(symbol) {
  const seed = Number(symbol.replace(/\D/g, "")) || 1000;
  const base = 50 + (seed % 900);
  const points = [];
  for (let i = 0; i < 10; i += 1) {
    const hour = 9 + Math.floor(i / 12);
    const minute = (i % 12) * 5;
    points.push({ time: `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}:00`, price: Number((base + Math.sin(i / 5 + seed) * 5 + i * 0.08).toFixed(2)), volume: Math.floor(100 + Math.random() * 2000) });
  }
  return { symbol, date: new Date().toISOString().slice(0, 10), points, source: "frontend-fallback-mock", updatedAt: new Date().toISOString() };
}

function createMockDaily(symbol) {
  const seed = Number(symbol.replace(/\D/g, "")) || 1000;
  const base = 50 + (seed % 900);
  const candles = [];
  for (let i = 59; i >= 0; i -= 1) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    const close = base + Math.sin(i / 4 + seed) * 8 + (60 - i) * 0.12;
    candles.push({ date: date.toISOString().slice(0, 10), open: Number((close - 1).toFixed(2)), high: Number((close + 3).toFixed(2)), low: Number((close - 4).toFixed(2)), close: Number(close.toFixed(2)), volume: Math.floor(5000 + Math.random() * 50000) });
  }
  return { symbol, candles, source: "frontend-fallback-mock", updatedAt: new Date().toISOString() };
}
