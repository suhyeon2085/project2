<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>풍력 발전 예측</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Reset & 기본 설정 */
        * {
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 30px;
            background: #f9fafb;
            color: #333;
        }

        h2 {
            margin-bottom: 25px;
            font-weight: 700;
            color: #222;
            text-align: center;
        }

        /* 버튼 스타일 */
        .buttons {
            text-align: center;
            margin-bottom: 30px;
        }
        button {
            background-color: #e0e7ff;
            border: none;
            border-radius: 6px;
            color: #4f46e5;
            font-weight: 600;
            padding: 10px 22px;
            margin: 0 8px;
            cursor: pointer;
            transition: background-color 0.3s ease, color 0.3s ease;
            box-shadow: 0 3px 6px rgba(79,70,229,0.3);
        }
        button:hover {
            background-color: #4338ca;
            color: white;
        }
        button.active {
            background-color: #4338ca;
            color: white;
            box-shadow: 0 5px 12px rgba(67,56,202,0.6);
        }

        /* 레이아웃 - flex로 가로 배치 */
        .container {
            display: flex;
            gap: 40px;
            max-width: 1300px;
            margin: 0 auto;
            align-items: flex-start;
        }
        .chart-box {
            flex: 3;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.1);
        }
        .table-box {
            flex: 1;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* 차트 크기 조정 */
        canvas {
            max-width: 100%;
            height: auto !important;
        }

        /* 도넛차트 영역 */
        .pie-container {
            width: 100%;
            text-align: center;
            margin-bottom: 25px;
        }
        .pie-container h3 {
            margin-bottom: 15px;
            font-weight: 600;
            color: #4f46e5;
        }

        /* 표 스타일 */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 0.95rem;
        }
        th, td {
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            text-align: center;
            transition: background-color 0.3s ease;
        }
        th {
            background-color: #e0e7ff;
            font-weight: 700;
            color: #4338ca;
        }
        tbody tr:hover {
            background-color: #f3f4f6;
        }

    </style>
</head>
<body>
    <h2>풍력 발전량 예측 vs 실제</h2>

    <div class="buttons">
        <button id="btnDaily" class="active" onclick="updateCharts('daily')">일간</button>
        <button id="btnWeekly" onclick="updateCharts('weekly')">주간</button>
        <button id="btnMonthly" onclick="updateCharts('monthly')">월간</button>
    </div>

    <div class="container">
        <div class="chart-box">
            <canvas id="powerChart" width="1200" height="400"></canvas>
            <canvas id="errorBarChart" width="1200" height="300" style="margin-top:40px;"></canvas>
        </div>

        <div class="table-box">
            <div class="pie-container">
                <h3>발전 비중 (예시)</h3>
                <canvas id="pieChart" width="300" height="300"></canvas>
                <table id="plantTable">
                    <thead>
                        <tr>
                            <th>발전소</th>
                            <th>발전 비율 (%)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- JS에서 데이터 채움 -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // 원본 데이터 - JSP에서 넘어온 데이터
        const rawData = [
            <c:forEach var="row" items="${powerData}" varStatus="loop">
                {
                    date: "${row.date}",
                    actual: ${row.actual},
                    predicted: ${row.predicted}
                }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        // 발전소별 비중 예시 데이터 (임의 값)
        const samplePieData = {
            daily: [40, 30, 20, 10],
            weekly: [35, 35, 20, 10],
            monthly: [30, 40, 20, 10]
        };

        const plantNames = ['1호', '2호', '3호', '4호'];

        let powerChart, errorBarChart, pieChart;

        // 날짜 문자열 -> Date 객체 변환
        function parseDate(str) {
            return new Date(str + 'T00:00:00');
        }

        // 데이터 그룹핑 (일간, 주간, 월간)
        function groupData(data, type) {
            if (type === 'daily') {
                return data;
            } else if (type === 'weekly') {
                let grouped = [];
                let weekMap = new Map();
                data.forEach(d => {
                    let date = parseDate(d.date);
                    let firstDate = parseDate(data[0].date);
                    let diffDays = Math.floor((date - firstDate) / (1000*60*60*24));
                    let weekNum = Math.floor(diffDays / 7) + 1;
                    if (!weekMap.has(weekNum)) weekMap.set(weekNum, []);
                    weekMap.get(weekNum).push(d);
                });
                for (let [week, items] of weekMap) {
                    let sumActual = 0, sumPredicted = 0;
                    items.forEach(i => { sumActual += i.actual; sumPredicted += i.predicted; });
                    grouped.push({
                        date: `${week}주차`,
                        actual: sumActual / items.length,
                        predicted: sumPredicted / items.length
                    });
                }
                return grouped;
            } else if (type === 'monthly') {
                let monthMap = new Map();
                data.forEach(d => {
                    let month = d.date.substring(0,7);
                    if (!monthMap.has(month)) monthMap.set(month, []);
                    monthMap.get(month).push(d);
                });
                let grouped = [];
                for (let [month, items] of monthMap) {
                    let sumActual = 0, sumPredicted = 0;
                    items.forEach(i => { sumActual += i.actual; sumPredicted += i.predicted; });
                    grouped.push({
                        date: month,
                        actual: sumActual / items.length,
                        predicted: sumPredicted / items.length
                    });
                }
                return grouped;
            }
        }

        // 오차율 계산 (%)
        function calcErrorRate(data) {
            return data.map(d => {
                return ((d.actual - d.predicted) / d.actual) * 100;
            });
        }

        // 발전소별 표 업데이트 함수
        function updatePlantTable(type) {
            const tbody = document.querySelector('#plantTable tbody');
            tbody.innerHTML = '';
            samplePieData[type].forEach((val, idx) => {
                let tr = document.createElement('tr');
                let tdName = document.createElement('td');
                tdName.textContent = plantNames[idx];
                let tdValue = document.createElement('td');
                tdValue.textContent = val + ' %';
                tr.appendChild(tdName);
                tr.appendChild(tdValue);
                tbody.appendChild(tr);
            });
        }

        // 차트 업데이트 함수
        function updateCharts(type) {
            // 버튼 활성화 토글
            ['btnDaily', 'btnWeekly', 'btnMonthly'].forEach(id => {
                let btn = document.getElementById(id);
                if (id === 'btn' + capitalize(type)) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });

            const groupedData = groupData(rawData, type);
            const labels = groupedData.map(d => d.date);
            const actualData = groupedData.map(d => d.actual);
            const predictedData = groupedData.map(d => d.predicted);
            const errorData = calcErrorRate(groupedData);

            // 선형 차트
            if (powerChart) powerChart.destroy();
            powerChart = new Chart(document.getElementById('powerChart').getContext('2d'), {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: '실제 발전량',
                            data: actualData,
                            borderColor: '#111',
                            fill: false,
                            tension: 0.15,
                            pointRadius: 5,
                            pointHoverRadius: 7,
                            borderWidth: 2,
                        },
                        {
                            label: '예측 발전량',
                            data: predictedData,
                            borderColor: '#e53935',
                            fill: false,
                            tension: 0.15,
                            pointRadius: 5,
                            pointHoverRadius: 7,
                            borderWidth: 2,
                        }
                    ]
                },
                options: {
                    responsive: false,
                    plugins: {
                        legend: { position: 'bottom' },
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                color: '#555'
                            },
                            grid: {
                                color: '#eee'
                            }
                        },
                        x: {
                            ticks: {
                                color: '#555'
                            },
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            // 오차율 막대 차트
            if (errorBarChart) errorBarChart.destroy();
            errorBarChart = new Chart(document.getElementById('errorBarChart').getContext('2d'), {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '예측 오차율 (%)',
                        data: errorData,
                        backgroundColor: errorData.map(e => e > 10 ? '#e53935' : '#4bc0c0'),
                        borderRadius: 5,
                    }]
                },
                options: {
                    responsive: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 20,
                            ticks: {
                                color: '#555'
                            },
                            grid: {
                                color: '#eee'
                            }
                        },
                        x: {
                            ticks: {
                                color: '#555'
                            },
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            // 도넛 차트
            if (pieChart) pieChart.destroy();
            pieChart = new Chart(document.getElementById('pieChart').getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: plantNames,
                    datasets: [{
                        data: samplePieData[type],
                        backgroundColor: ['#36A2EB', '#FFCE56', '#4BC0C0', '#FF6384'],
                        borderWidth: 2,
                        borderColor: 'white'
                    }]
                },
                options: {
                    responsive: false,
                    plugins: {
                        legend: { position: 'bottom', labels: { color: '#333', font: {weight:'600'} } },
                        tooltip: { enabled: true }
                    }
                }
            });

            // 발전소별 표 업데이트
            updatePlantTable(type);
        }

        // 첫 로드시 일간 데이터 표시
        updateCharts('daily');

        function capitalize(str) {
            return str.charAt(0).toUpperCase() + str.slice(1);
        }
    </script>
</body>
</html>