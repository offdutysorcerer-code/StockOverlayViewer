let intradayChart;
let dailyChart;

const FULL_INTRADAY_LABELS = createFullIntradayLabels();

export function renderIntradayChart(canvas, seriesList, priceMode) {
  const datasets = seriesList.map((series) => {
    const prices = series.points.map((point) => point.price);
    const normalized = normalizeToBase100(prices);
    const values = priceMode === "indexed" ? normalized : prices;

    return {
      label: series.symbol,
      data: alignToFullLabels(series.points, values),
      tension: 0,
      pointRadius: 0,
      borderWidth: 2,
      spanGaps: false
    };
  });

  if (!intradayChart) {
    intradayChart = new Chart(canvas, {
      type: "line",
      data: { labels: FULL_INTRADAY_LABELS, datasets },
      options: createChartOptions()
    });
    return;
  }

  intradayChart.data.datasets = datasets;
  intradayChart.update("none");
}

export function renderDailyChart(canvas, dailyData) {
  const candles = dailyData?.candles ?? [];
  const data = candles.map((candle) => ({
    x: candle.date,
    o: Number(candle.open),
    h: Number(candle.high),
    l: Number(candle.low),
    c: Number(candle.close)
  }));

  if (!dailyChart) {
    dailyChart = new Chart(canvas, {
      type: "candlestick",
      data: {
        datasets: [{
          label: dailyData?.symbol ?? "Daily",
          data,
          color: {
            up: "#ef4444",
            down: "#22c55e",
            unchanged: "#94a3b8"
          }
        }]
      },
      options: {
        ...createChartOptions(),
        parsing: false,
        scales: {
          x: {
            type: "time",
            time: { unit: "day", tooltipFormat: "yyyy-MM-dd" },
            ticks: { color: "#9ca3af", maxRotation: 0 },
            grid: { color: "#374151" }
          },
          y: {
            position: "right",
            ticks: { color: "#9ca3af" },
            grid: { color: "#374151" }
          }
        }
      }
    });
    return;
  }

  dailyChart.data.datasets[0].label = dailyData?.symbol ?? "Daily";
  dailyChart.data.datasets[0].data = data;
  dailyChart.update("none");
}

export function clearDailyChart() {
  if (!dailyChart) return;
  dailyChart.data.datasets[0].data = [];
  dailyChart.update("none");
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
  points.forEach((point, index) => map.set(point.time, values[index]));
  return FULL_INTRADAY_LABELS.map((label) => map.get(label) ?? null);
}

function createChartOptions() {
  return {
    responsive: true,
    maintainAspectRatio: false,
    animation: false,
    interaction: { mode: "index", intersect: false },
    plugins: {
      legend: { labels: { color: "#e5e7eb" } }
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
