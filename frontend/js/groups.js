export function renderGroups(container, groups, selectedGroupId, handlers) {
  container.innerHTML = "";

  groups.forEach((group) => {
    const row = document.createElement("div");
    row.className = `group-item ${group.id === selectedGroupId ? "active" : ""}`;

    const main = document.createElement("div");
    main.className = "item-main";
    main.innerHTML = `<div class="item-name">${escapeHtml(group.name || group.id)}</div><div class="item-sub">${group.symbols.length} items</div>`;
    main.addEventListener("click", () => handlers.onSelectGroup(group.id));

    const actions = document.createElement("div");
    actions.className = "item-actions";
    actions.appendChild(createButton("Edit", () => handlers.onEditGroup(group.id)));
    actions.appendChild(createButton("Del", () => handlers.onDeleteGroup(group.id)));

    row.appendChild(main);
    row.appendChild(actions);
    container.appendChild(row);
  });
}

export function renderSymbols(container, symbols, selectedSymbols, symbolsMeta, handlers) {
  container.innerHTML = "";

  symbols.forEach((symbol) => {
    const wrapper = document.createElement("div");
    wrapper.className = "symbol-item";

    const label = document.createElement("label");
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = selectedSymbols.includes(symbol);
    checkbox.addEventListener("change", () => handlers.onToggleSymbol(symbol));

    const title = document.createElement("span");
    title.className = "symbol-title";
    title.textContent = getSymbolLabel(symbol, symbolsMeta);

    label.appendChild(checkbox);
    label.appendChild(title);

    const actions = document.createElement("div");
    actions.className = "item-actions";
    actions.appendChild(createButton("Del", () => handlers.onDeleteSymbol(symbol)));

    wrapper.appendChild(label);
    wrapper.appendChild(actions);
    container.appendChild(wrapper);
  });
}

export function getSymbolLabel(symbol, symbolsMeta) {
  const meta = symbolsMeta?.[symbol];
  if (!meta) return symbol;
  return `${symbol} ${meta.displayName || meta.name || ""}`.trim();
}

function createButton(text, onClick) {
  const button = document.createElement("button");
  button.className = "icon-button";
  button.textContent = text;
  button.addEventListener("click", (event) => {
    event.stopPropagation();
    onClick();
  });
  return button;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
