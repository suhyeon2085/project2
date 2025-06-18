<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>풍력 발전량 비교 대시보드</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
		    body {
    font-family: 'Segoe UI', 'Malgun Gothic', sans-serif;
    margin: 0;
    padding: 20px 30px;
    background-color: #474747;
    color: white;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

h2 {
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 20px;
    text-align: center;
    color: #eee;
    user-select: none;
}

.btn-group {
    margin: 0 auto 40px auto;
    text-align: center;
    width: fit-content;
    display: flex;
    gap: 15px;
}

.btn-group button {
    padding: 12px 25px;
    cursor: pointer;
    background-color: #595959;
    color: white;
    border: none;
    border-radius: 10px;
    font-weight: 600;
    font-size: 16px;
    transition: background-color 0.3s ease, transform 0.2s ease;
    user-select: none;
}

.btn-group button:hover {
    background-color: #6799FF;
    transform: translateY(-3px);
}

.chart-container {
    display: flex;
    justify-content: center;
    align-items: stretch;
    gap: 25px;
    width: 100%;
    max-width: 1400px;
    margin: 0 auto; /* 화면 가운데 정렬 */
    height: 700px;
    box-sizing: border-box;
}

.chart-box {
    background-color: #595959;
    border-radius: 10px;
    padding: 25px 20px 20px 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.3);
    color: white;
    user-select: none;
    display: flex;
    flex-direction: column;
    height: 100%;
}

.line-chart {
    flex: 2 2 0;
    max-width: 70%;
    min-width: 65%;
    height: 100%;
}

.side-charts {
    flex: 1 1 0;
    max-width: 30%;
    display: flex;
    flex-direction: column;
    gap: 25px;
    height: 100%;
}

.small-chart {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.chart-box h3 {
    margin-top: 0;
    margin-bottom: 15px;
    font-weight: 700;
    font-size: 20px;
    color: #e3e3e3;
    user-select: none;
}

canvas {
    flex-grow: 1;
    width: 100% !important;
    height: 100% !important;
    border-radius: 8px;
    background-color: #404040;
    box-shadow: inset 0 0 10px rgba(255,255,255,0.1);
    user-select: none;

		}
    </style>
</head>
<body>
    <h2>풍력 발전량 비교 대시보드</h2>

    <div class="btn-group">
        <button onclick="updateLineChart('daily')">일간</button>
        <button onclick="updateLineChart('weekly')">주간</button>
        <button onclick="updateLineChart('monthly')">월간</button>
    </div>

    <div class="chart-container">
        <div class="chart-box line-chart">
            <h3>전년도 vs 올해 예측 발전량</h3>
            <canvas id="lineChart"></canvas>
        </div>

        <div class="side-charts">
            <div class="chart-box small-chart">
                <h3>올해 예측 발전량 발전소별 합계</h3>
                <canvas id="pieChart"></canvas>
            </div>
            <div class="chart-box small-chart">
                <h3>예측 발전량 오차율</h3>
                <canvas id="barChart"></canvas>
            </div>
        </div>
    </div>

    <script>
        // 서버에서 전달된 JSON 데이터(JS 배열)
        const lastYearData = ${lastYearListJson};
        const predictedData = ${thisYearPredictedListJson};

        let lineChart, pieChart, barChart;
        let currentRange = 'monthly';

        // 데이터 그룹핑 함수 (일/주/월 별 평균 or 합계)
        function groupData(data, range, sumOnly = false) {
            const grouped = {};

            data.forEach(item => {
                const date = item.dgenYmd;
                const value = parseFloat(item.qsum) || 0;
                let key;

                if (range === 'daily') {
                    key = date;
                } else if (range === 'weekly') {
                    const day = parseInt(date.slice(8,10));
                    const weekNum = Math.ceil(day / 7);
                    key = date.slice(0,7) + " W" + weekNum;
                } else if (range === 'monthly') {
                    key = date.slice(0,7);
                }

                if (!grouped[key]) grouped[key] = { total: 0, count: 0 };
                grouped[key].total += value;
                grouped[key].count += 1;
            });

            const labels = Object.keys(grouped).sort();

            if (sumOnly) {
                const values = labels.map(k => grouped[k].total.toFixed(2));
                return { labels, values };
            } else {
                const values = labels.map(k => (grouped[k].total / grouped[k].count).toFixed(2));
                return { labels, values };
            }
        }

        // 발전소별 예측 발전량 합계 구하기
        function sumByPowerPlantRange(data, range) {
            const groupedByRange = {};

            data.forEach(item => {
                const date = item.dgenYmd;
                let key;

                if (range === 'daily') {
                    key = date;
                } else if (range === 'weekly') {
                    const day = parseInt(date.slice(8,10));
                    const weekNum = Math.ceil(day / 7);
                    key = date.slice(0,7) + " W" + weekNum;
                } else if (range === 'monthly') {
                    key = date.slice(0,7);
                }

                if (!groupedByRange[key]) groupedByRange[key] = {};

                const plantName = item.ipptNam;
                if (!groupedByRange[key][plantName]) groupedByRange[key][plantName] = 0;

                groupedByRange[key][plantName] += parseFloat(item.qsum) || 0;
            });

            const plantSums = {};
            for (const key in groupedByRange) {
                for (const plant in groupedByRange[key]) {
                    if (!plantSums[plant]) plantSums[plant] = 0;
                    plantSums[plant] += groupedByRange[key][plant];
                }
            }

            const labels = Object.keys(plantSums);
            const values = labels.map(k => Number(plantSums[k].toFixed(2)));

            return { labels, values };
        }

        // 원형 그래프 그리기 (발전소별 예측 발전량 합계)
        function drawPieChartByPlant(range) {
            const plantData = sumByPowerPlantRange(predictedData, range);
            const ctx = document.getElementById('pieChart').getContext('2d');

            if (pieChart) pieChart.destroy();

            pieChart = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: plantData.labels,
                    datasets: [{
                        label: '발전소별 예측 발전량 합계',
                        data: plantData.values,
                        backgroundColor: generateColors(plantData.labels.length)
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { position: 'right', labels: { color: 'white' } },
                        tooltip: {
                            callbacks: {
                                label: ctx => `${ctx.label}: ${ctx.parsed} MW`
                            }
                        }
                    }
                }
            });
        }

        // 예측 오차율 계산
        function calcErrorRate(range) {
            const actual = groupData(lastYearData, range);
            const predicted = groupData(predictedData, range);

            const labels = actual.labels;
            const errorRates = labels.map((label, idx) => {
                const actualVal = parseFloat(actual.values[idx]) || 0;
                const predVal = parseFloat(predicted.values[idx]) || 0;
                if (actualVal === 0) return 0;
                return ((predVal - actualVal) / actualVal * 100).toFixed(2);
            });

            return { labels, errorRates };
        }

        // 막대 그래프 업데이트 (예측 오차율)
        function updateBarChart(range) {
            const errorData = calcErrorRate(range);
            const ctx = document.getElementById('barChart').getContext('2d');

            if (barChart) barChart.destroy();

            barChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: errorData.labels,
                    datasets: [{
                        label: '예측 오차율 (%)',
                        data: errorData.errorRates,
                        backgroundColor: errorData.errorRates.map(val => val >= 0 ? 'rgba(255, 99, 132, 0.7)' : 'rgba(54, 162, 235, 0.7)')
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: true, position: 'top', labels: { color: 'white' } },
                        tooltip: {
                            callbacks: {
                                label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y}%`
                            }
                        }
                    },
                    scales: {
                        y: {
                            title: { display: true, text: '오차율 (%)', color: 'white' },
                            ticks: {
                                color: 'white',
                                callback: val => val + '%'
                            },
                            min: -100,
                            max: 100,
                        },
                        x: {
                            title: { display: true, text: range === 'daily' ? '일자' : range === 'weekly' ? '주' : '월', color: 'white' },
                            ticks: { color: 'white' }
                        }
                    }
                }
            });
        }

        // 선형 그래프 업데이트 (전년도 vs 올해 예측 발전량)
        function updateLineChart(range) {
            currentRange = range;

            const last = groupData(lastYearData, range);
            const pred = groupData(predictedData, range);
            const ctx = document.getElementById('lineChart').getContext('2d');

            if (lineChart) lineChart.destroy();

            lineChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: last.labels,
                    datasets: [
                        {
                            label: '전년도 발전량',
                            data: last.values,
                            borderColor: 'limegreen',
                            borderDash: [5, 5],
                            tension: 0.3,
                            fill: false
                        },
                        {
                            label: '올해 예측 발전량',
                            data: pred.values,
                            borderColor: 'tomato',
                            tension: 0.3,
                            fill: false
                        }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: {
                        tooltip: {
                            callbacks: {
                                label: ctx => `${ctx.dataset.label}: ${ctx.formattedValue} MW`
                            }
                        },
                        legend: {
                            position: 'top',
                            labels: { color: 'white' }
                        }
                    },
                    scales: {
                        y: {
                            title: { display: true, text: 'MW', color: 'white' },
                            ticks: { color: 'white' }
                        },
                        x: {
                            title: { display: true, text: range === 'daily' ? '일자' : range === 'weekly' ? '주' : '월', color: 'white' },
                            ticks: { color: 'white' }
                        }
                    }
                }
            });

            drawPieChartByPlant(range);
            updateBarChart(range);
        }

        // 그래프 색상 생성
        function generateColors(count) {
            const baseColors = [
                '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
                '#FF9F40', '#E7E9ED', '#71B37C', '#C9CBCF', '#BEBADA'
            ];

            let colors = [];
            for(let i = 0; i < count; i++) {
                colors.push(baseColors[i % baseColors.length]);
            }
            return colors;
        }

        // 초기 로딩 시 월간 차트 표시
        updateLineChart(currentRange);
    </script>
</body>
</html>