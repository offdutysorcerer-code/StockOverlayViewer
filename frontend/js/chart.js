let intradayChart;
let dailyChart;

export function renderIntradayChart(canvas, seriesList, priceMode) {
  const labels = createIntradayLabels(seriesList);
  const datasets = seriesList.map((series) => {
    const prices = series.points.map((point) => point.price);
    const normalized = normalizeToBase100(prices);
    const values = priceMode === "indexed" ? normalized : prices;

    return {
      label: series.symbol,
      data: alignToLabels(series.points, values, labels),
      tension: 0,
      pointRadius: values.length <= 3 ? 3 : 0,
      pointHoverRadius: 5,
      borderWidth: 2,
      spanGaps: true
    };
  });

  if (!intradayChart) {
    intradayChart = new Chart(canvas, {
      type: "line",
      data: { labels, datasets },
      options: createChartOptions()
    });
    return;
  }

  intradayChart.data.labels = labels;
  intradayChart.data.datasets = datasets;
  intradayChart.update("none");
}

export function renderDailyChart(canvas, dailyData) {
  const candles = dailyData?.candles ?? [];
  const data = candles.map((candle) => ({
    x: Date.parse(`${candle.date}T00:00:00`),
    o: Number(candle.open),
    h: Number(candle.high),
    l: Number(candle.low),
    c: Number(candle.close),
    date: candle.date
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
      options: createDailyChartOptions()
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

function createIntradayLabels(seriesList) {
  const hasUsSession = seriesList.some((series) =>
    (series.points ?? []).some((point) => {
      const hour = Number(String(point.time ?? "").slice(0, 2));
      return hour >= 20 || hour < 8;
    })
  );

  return hasUsSession
    ? createTimeLabels("21:30:00", "04:00:00", 1)
    : createTimeLabels("09:00:00", "13:30:00", 1);
}

function createTimeLabels(start, end, stepMinutes) {
  const labels = [];
  const startSeconds = intradaySortKey(start);
  const endSeconds = intradaySortKey(end);
  for (let seconds = startSeconds; seconds <= endSeconds; seconds += stepMinutes * 60) {
    labels.push(formatIntradaySeconds(seconds));
  }
  return labels;
}

function formatIntradaySeconds(value) {
  const secondsInDay = ((value % 86400) + 86400) % 86400;
  const hour = Math.floor(secondsInDay / 3600);
  const minute = Math.floor((secondsInDay % 3600) / 60);
  const second = secondsInDay % 60;
  return `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}:${String(second).padStart(2, "0")}`;
}

function intradaySortKey(value) {
  const [hourText, minuteText, secondText] = String(value).split(":");
  const hour = Number(hourText) || 0;
  const minute = Number(minuteText) || 0;
  const second = Number(secondText) || 0;
  const raw = hour * 3600 + minute * 60 + second;
  return hour < 8 ? raw + 24 * 3600 : raw;
}

function alignToLabels(points, values, labels) {
  const map = new Map();
  points.forEach((point, index) => map.set(point.time, values[index]));
  return labels.map((label) => map.get(label) ?? null);
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

function createDailyChartOptions() {
  return {
    ...createChartOptions(),
    parsing: false,
    interaction: { mode: "index", intersect: false },
    plugins: {
      ...createChartOptions().plugins,
      tooltip: {
        callbacks: {
          title: (items) => {
            const item = items[0]?.raw;
            return item?.date ?? "";
          },
          label: (context) => {
            const item = context.raw;
            if (!item) return "";
            return `O: ${formatPrice(item.o)}  H: ${formatPrice(item.h)}  L: ${formatPrice(item.l)}  C: ${formatPrice(item.c)}`;
          }
        }
      },
      zoom: {
        pan: { enabled: true, mode: "x" },
        zoom: { wheel: { enabled: true }, pinch: { enabled: true }, mode: "x" }
      }
    },
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
  };
}

function formatPrice(value) {
  return Number(value).toFixed(2);
}

function normalizeToBase100(values) {
  const first = values[0] || 1;
  return values.map((value) => Number(((value / first) * 100).toFixed(2)));
}
