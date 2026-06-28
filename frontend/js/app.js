import { getGroups, saveGroups, resetGroups, getIntraday, getDaily, getLatestIndex, getSymbolsMeta, saveSymbolsMeta, lookupSymbol, startMockFeed, stopMockFeed } from "./api.js";
import { renderIntradayChart, renderDailyChart, clearDailyChart } from "./chart.js";
import { renderGroups, renderSymbols, getSymbolLabel } from "./groups.js";

const state = {
  groups: [],
  symbolsMeta: {},
  selectedGroupId: null,
  selectedSymbols: [],
  dailySymbol: null,
  priceMode: "indexed"
};

const el = {
  groupList: document.getElementById("groupList"),
  symbolList: document.getElementById("symbolList"),
  refreshButton: document.getElementById("refreshButton"),
  resetGroupsButton: document.getElementById("resetGroupsButton"),
  startFeedButton: document.getElementById("startFeedButton"),
  stopFeedButton: document.getElementById("stopFeedButton"),
  addGroupButton: document.getElementById("addGroupButton"),
  addSymbolButton: document.getElementById("addSymbolButton"),
  importSymbolButton: document.getElementById("importSymbolButton"),
  symbolFileInput: document.getElementById("symbolFileInput"),
  priceModeSelect: document.getElementById("priceModeSelect"),
  intradayChart: document.getElementById("intradayChart"),
  dailyChart: document.getElementById("dailyChart"),
  intradayStatus: document.getElementById("intradayStatus"),
  dailyStatus: document.getElementById("dailyStatus"),
  dailySymbolSelect: document.getElementById("dailySymbolSelect")
};

init();

async function init() {
  el.refreshButton.addEventListener("click", refreshCharts);
  el.resetGroupsButton.addEventListener("click", resetAllGroups);
  el.startFeedButton.addEventListener("click", startFeedFromUi);
  el.stopFeedButton.addEventListener("click", stopFeedFromUi);
  el.addGroupButton.addEventListener("click", addGroup);
  el.addSymbolButton.addEventListener("click", addSymbol);
  el.importSymbolButton.addEventListener("click", () => el.symbolFileInput.click());
  el.symbolFileInput.addEventListener("change", importSymbolsFromFile);
  el.priceModeSelect.addEventListener("change", async (event) => {
    state.priceMode = event.target.value;
    await refreshCharts();
  });
  el.dailySymbolSelect.addEventListener("change", async (event) => {
    state.dailySymbol = event.target.value;
    await refreshCharts();
  });

  state.symbolsMeta = await getSymbolsMeta();
  state.groups = await getGroups();
  state.selectedGroupId = state.groups[0]?.id ?? null;
  state.selectedSymbols = state.groups[0]?.symbols.slice(0, 3) ?? [];
  state.dailySymbol = state.selectedSymbols[0] ?? null;

  renderAll();
  await refreshCharts();
  window.setInterval(refreshCharts, 5000);
}

function renderAll() {
  const group = getSelectedGroup();
  renderDailySymbolOptions(group?.symbols ?? []);
  renderGroups(el.groupList, state.groups, state.selectedGroupId, {
    onSelectGroup: async (groupId) => {
      state.selectedGroupId = groupId;
      state.selectedSymbols = getSelectedGroup()?.symbols.slice(0, 3) ?? [];
      state.dailySymbol = state.selectedSymbols[0] ?? null;
      renderAll();
      await refreshCharts();
    },
    onEditGroup: editGroup,
    onDeleteGroup: removeGroup
  });
  renderSymbols(el.symbolList, group?.symbols ?? [], state.selectedSymbols, state.symbolsMeta, {
    onToggleSymbol: async (symbol) => {
      state.selectedSymbols = state.selectedSymbols.includes(symbol)
        ? state.selectedSymbols.filter((item) => item !== symbol)
        : [...state.selectedSymbols, symbol];
      if (!state.dailySymbol) state.dailySymbol = symbol;
      renderAll();
      await refreshCharts();
    },
    onDeleteSymbol: removeSymbol
  });
}

async function startFeedFromUi() {
  el.intradayStatus.textContent = "Starting mock feed...";
  const result = await startMockFeed(2, 60);
  el.intradayStatus.textContent = `Mock feed ${result.status} | pid ${result.pid ?? "-"}`;
  setTimeout(refreshCharts, 1000);
}

async function stopFeedFromUi() {
  const result = await stopMockFeed();
  el.intradayStatus.textContent = `Mock feed ${result.status}`;
}

async function refreshCharts() {
  if (state.selectedSymbols.length === 0) {
    clearDailyChart();
    setStatus(el.intradayStatus, "No symbols selected");
    setStatus(el.dailyStatus, "No symbols selected");
    return;
  }
  const latest = await getLatestIndex();
  const intradaySeries = await Promise.all(state.selectedSymbols.map((symbol) => getIntraday(symbol)));
  renderIntradayChart(el.intradayChart, intradaySeries, state.priceMode);
  const newestTime = intradaySeries.map((series) => series.updatedAt).filter(Boolean).sort().at(-1);
  const intradayUpdatedAt = newestTime || latest.updatedAt;
  const sources = [...new Set(intradaySeries.map((series) => series.source).filter(Boolean))].join(", ") || latest.mode || "unknown";
  setStatus(el.intradayStatus, `Loaded ${state.selectedSymbols.length} | source ${sources} | updated ${formatTime(intradayUpdatedAt)}`, intradayUpdatedAt);
  const dailySymbol = state.dailySymbol || state.selectedSymbols[0];
  const firstDaily = await getDaily(dailySymbol);
  renderDailyChart(el.dailyChart, firstDaily);
  setStatus(el.dailyStatus, `Showing ${getSymbolLabel(dailySymbol, state.symbolsMeta)} | source ${firstDaily.source ?? "unknown"} | updated ${formatTime(firstDaily.updatedAt)}`, firstDaily.updatedAt);
}

async function addGroup() {
  const name = window.prompt("Group name:");
  if (!name) return;
  const id = createId(name);
  state.groups.push({ id, name, symbols: [] });
  state.selectedGroupId = id;
  state.selectedSymbols = [];
  await saveAndRender();
}

async function editGroup(groupId) {
  const group = state.groups.find((item) => item.id === groupId);
  if (!group) return;
  const name = window.prompt("New group name:", group.name);
  if (!name) return;
  group.name = name;
  await saveAndRender();
}

async function removeGroup(groupId) {
  state.groups = state.groups.filter((item) => item.id !== groupId);
  state.selectedGroupId = state.groups[0]?.id ?? null;
  state.selectedSymbols = getSelectedGroup()?.symbols.slice(0, 3) ?? [];
  state.dailySymbol = state.selectedSymbols[0] ?? null;
  await saveAndRender();
}

async function addSymbol() {
  const group = getSelectedGroup();
  if (!group) return;
  const symbol = window.prompt("Symbol code, for example 2330:");
  if (!symbol) return;
  const normalized = symbol.trim().toUpperCase();
  if (!normalized) return;
  try {
    const meta = await lookupSymbol(normalized);
    if (meta && meta.symbol && meta.source !== "not-found") {
      state.symbolsMeta[normalized] = {
        name: meta.name || "",
        displayName: meta.displayName || "",
        market: meta.market || "",
        source: meta.source || "",
        updatedAt: meta.updatedAt || new Date().toISOString()
      };
      await saveSymbolsMeta(state.symbolsMeta);
    } else {
      window.alert(`No official name found for ${normalized}. It will be added with code only.`);
    }
  } catch (error) {
    console.warn("Symbol lookup failed", error);
    window.alert(`Lookup failed for ${normalized}. It will be added with code only.`);
  }
  if (!group.symbols.includes(normalized)) group.symbols.push(normalized);
  if (!state.selectedSymbols.includes(normalized)) state.selectedSymbols.push(normalized);
  await saveAndRender();
  await refreshCharts();
}

async function removeSymbol(symbol) {
  const group = getSelectedGroup();
  if (!group) return;
  group.symbols = group.symbols.filter((item) => item !== symbol);
  state.selectedSymbols = state.selectedSymbols.filter((item) => item !== symbol);
  await saveAndRender();
  await refreshCharts();
}

async function resetAllGroups() {
  state.groups = await resetGroups();
  state.selectedGroupId = state.groups[0]?.id ?? null;
  state.selectedSymbols = state.groups[0]?.symbols.slice(0, 3) ?? [];
  state.dailySymbol = state.selectedSymbols[0] ?? null;
  renderAll();
  await refreshCharts();
}

async function saveAndRender() {
  await saveGroups(state.groups);
  renderAll();
}

function getSelectedGroup() {
  return state.groups.find((group) => group.id === state.selectedGroupId);
}

function createId(value) {
  return value.trim().toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || `group-${Date.now()}`;
}

function formatTime(value) {
  if (!value) return "unknown";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleTimeString("zh-TW", { hour12: false });
}


async function importSymbolsFromFile(event) {
  const file = event.target.files[0];
  if (!file) return;

  try {
    let content = await file.text();
    
    // Try to parse as JSON first
    let importedSymbols = {};
    try {
      importedSymbols = JSON.parse(content);
    } catch (jsonError) {
      // Parse CSV format
      const lines = content.split('\n').filter(line => line.trim() !== '');
      if (lines.length > 0) {
        // Assume first row is header
        const headers = lines[0].split(',').map(h => h.trim().toLowerCase());
        
        let codeIdx = -1, nameIdx = -1;
        for (let i = 0; i < headers.length; i++) {
          if (headers[i].match(/代號|code|stock.*code/)) codeIdx = i;
          if (headers[i].match(/名稱|name|stock.*name/)) nameIdx = i;
        }
        
        // Fallback: assume first column is code, second is name
        if (codeIdx === -1) codeIdx = 0;
        if (nameIdx === -1) nameIdx = 1;
        
        for (let i = 1; i < lines.length; i++) {
          const parts = lines[i].split(',');
          if (parts[codeIdx]?.trim()) {
            const code = parts[codeIdx].trim();
            const name = parts[nameIdx]?.trim() || code;
            importedSymbols[code] = { name, displayName: name };
          }
        }
      }
    }

    // Merge with existing symbols
    state.symbolsMeta = { ...state.symbolsMeta, ...importedSymbols };
    
    // Try to save via API
    try {
      await saveSymbolsMeta(state.symbolsMeta);
      alert(`Successfully imported ${Object.keys(importedSymbols).length} symbols!`);
    } catch (apiError) {
      console.warn("Failed to save via API:", apiError);
      
      // Fallback: show instructions for manual update
      const jsonStr = JSON.stringify(state.symbolsMeta, null, 2);
      alert(`Imported ${Object.keys(importedSymbols).length} symbols. Please copy the following content to data/symbols.json:\n\n${jsonStr.substring(0, 500)}...`);
    }

    // Refresh UI
    renderAll();
    await refreshCharts();
    
  } catch (error) {
    console.error("Import failed:", error);
    alert(`Import failed: ${error.message}`);
  } finally {
    event.target.value = ''; // Reset file input
  }
}


function renderDailySymbolOptions(symbols) {
  const available = symbols.filter((symbol) => state.selectedSymbols.includes(symbol));
  if (!available.includes(state.dailySymbol)) {
    state.dailySymbol = available[0] ?? null;
  }
  el.dailySymbolSelect.innerHTML = "";
  available.forEach((symbol) => {
    const option = document.createElement("option");
    option.value = symbol;
    option.textContent = getSymbolLabel(symbol, state.symbolsMeta);
    option.selected = symbol === state.dailySymbol;
    el.dailySymbolSelect.appendChild(option);
  });
  el.dailySymbolSelect.disabled = available.length === 0;
}

function setStatus(element, message, updatedAt = null) {
  element.textContent = message;
  element.classList.remove("stale", "error");
  if (!updatedAt) return;
  const timestamp = new Date(updatedAt).getTime();
  if (!Number.isNaN(timestamp) && Date.now() - timestamp > 15 * 60 * 1000) {
    element.textContent += " | stale";
    element.classList.add("stale");
  }
}
