import { getGroups, saveGroups, resetGroups, getIntraday, getDaily, getLatestIndex, getSymbolsMeta, saveSymbolsMeta, lookupSymbol, startMockFeed, stopMockFeed } from "./api.js";
import { renderIntradayChart, renderDailyPlaceholder } from "./chart.js";
import { renderGroups, renderSymbols, getSymbolLabel } from "./groups.js";

const state = {
  groups: [],
  symbolsMeta: {},
  selectedGroupId: null,
  selectedSymbols: [],
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
  priceModeSelect: document.getElementById("priceModeSelect"),
  intradayChart: document.getElementById("intradayChart"),
  dailyChart: document.getElementById("dailyChart"),
  intradayStatus: document.getElementById("intradayStatus"),
  dailyStatus: document.getElementById("dailyStatus")
};

init();

async function init() {
  el.refreshButton.addEventListener("click", refreshCharts);
  el.resetGroupsButton.addEventListener("click", resetAllGroups);
  el.startFeedButton.addEventListener("click", startFeedFromUi);
  el.stopFeedButton.addEventListener("click", stopFeedFromUi);
  el.addGroupButton.addEventListener("click", addGroup);
  el.addSymbolButton.addEventListener("click", addSymbol);
  el.priceModeSelect.addEventListener("change", async (event) => {
    state.priceMode = event.target.value;
    await refreshCharts();
  });

  state.symbolsMeta = await getSymbolsMeta();
  state.groups = await getGroups();
  state.selectedGroupId = state.groups[0]?.id ?? null;
  state.selectedSymbols = state.groups[0]?.symbols.slice(0, 3) ?? [];

  renderAll();
  await refreshCharts();
  window.setInterval(refreshCharts, 5000);
}

function renderAll() {
  const group = getSelectedGroup();
  renderGroups(el.groupList, state.groups, state.selectedGroupId, {
    onSelectGroup: async (groupId) => {
      state.selectedGroupId = groupId;
      state.selectedSymbols = getSelectedGroup()?.symbols.slice(0, 3) ?? [];
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
    el.intradayStatus.textContent = "No symbols selected";
    el.dailyStatus.textContent = "No symbols selected";
    renderDailyPlaceholder(el.dailyChart, null);
    return;
  }
  const latest = await getLatestIndex();
  const intradaySeries = await Promise.all(state.selectedSymbols.map((symbol) => getIntraday(symbol)));
  renderIntradayChart(el.intradayChart, intradaySeries, state.priceMode);
  const newestTime = intradaySeries.map((series) => series.updatedAt).filter(Boolean).sort().at(-1);
  el.intradayStatus.textContent = `Loaded ${state.selectedSymbols.length} | updated ${formatTime(newestTime || latest.updatedAt)}`;
  const firstDaily = await getDaily(state.selectedSymbols[0]);
  renderDailyPlaceholder(el.dailyChart, firstDaily);
  el.dailyStatus.textContent = `Showing ${getSymbolLabel(state.selectedSymbols[0], state.symbolsMeta)} | source ${firstDaily.source ?? "unknown"}`;
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
