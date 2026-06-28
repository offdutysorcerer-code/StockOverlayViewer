let intradayChart;

const FULL_INTRADAY_LABELS = createFullIntradayLabels();

export function renderIntradayChart(canvas, seriesList, priceMode) {
  const datasets = seriesList.map((series) => {
    const prices = series.points.map((point) => point.price);
    const normalized = normalizeToBase100(prices);
    const values = priceMode === "indexed" ? normalized : prices;
    const aligned = alignToFullLabels(series.points, values);

    return {
      label: series.symbol,
      data: aligned,
      tension: 0,
      pointRadius: 0,
      borderWidth: 2,
      spanGaps: false
    };
  });

  if (!intradayChart) {
    intradayChart = new Chart(canvas, {
      type: "line",
      data: {
        labels: FULL_INTRADAY_LABELS,
        datasets
      },
      options: createChartOptions()
    });
    return;
  }

  intradayChart.data.labels = FULL_INTRADAY_LABELS;
  intradayChart.data.datasets = datasets;
  intradayChart.update("none");
}

export function renderDailyPlaceholder(container, dailyData) {
  if (!dailyData) {
    container.textContent = "請先選擇股票。";
    return;
  }

  const latest = dailyData.candles[dailyData.candles.length - 1];
  container.innerHTML = `
    <div>
      <strong>${dailyData.symbol}</strong><br />
      最新日 K：${latest.date}<br />
      O ${latest.open} / H ${latest.high} / L ${latest.low} / C ${latest.close}<br />
      <small>下一步可接 Lightweight Charts 顯示正式 K 線。</small>
    </div>
  `;
}

function createFullIntradayLabels() {
  const labels = [];
  const start = new Date("2000-01-01T09:00:00");

  for (let i = 0; i < 55; i += 1) {
    const time = new Date(start.getTime() + i * 5 * 60 * 1000);
    labels.push(time.toTimeString().slice(0, 8));
  }

  return labels;
}

function alignToFullLabels(points, values) {
  const map = new Map();
  points.forEach((point, index) => {
    map.set(point.time, values[index]);
  });

  return FULL_INTRADAY_LABELS.map((label) => map.get(label) ?? null);
}

function createChartOptions() {
  return {
    responsive: true,
    maintainAspectRatio: false,
    animation: false,
    animations: false,
    transitions: {
      active: { animation: { duration: 0 } },
      resize: { animation: { duration: 0 } },
      show: { animation: { duration: 0 } },
      hide: { animation: { duration: 0 } }
    },
    interaction: {
      mode: "index",
      intersect: false
    },
    plugins: {
      legend: {
        labels: {
          color: "#e5e7eb"
        }
      }
    },
    scales: {
      x: {
        ticks: { color: "#9ca3af", maxRotation: 60, minRotation: 60 },
        grid: { color: "#374151" }
      },
      y: {
        ticks: { color: "#9ca3af" },
        grid: { color: "#374151" }
      }
    }
  };
}

function normalizeToBase100(values) {
  const first = values[0] || 1;
  return values.map((value) => Number(((value / first) * 100).toFixed(2)));
}
