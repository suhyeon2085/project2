<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>풍력 발전량 시각화</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 30px;
            background: #f5f7fa;
            color: #222;
        }
        h2 {
            text-align: center;
            margin-bottom: 25px;
        }
        .buttons {
            text-align: center;
            margin-bottom: 20px;
        }
        button {
            background-color: #cbd5e1;
            border: none;
            border-radius: 5px;
            padding: 10px 20px;
            margin: 0 5px;
            cursor: pointer;
            font-weight: bold;
            color: #1e293b;
            transition: background-color 0.3s ease;
        }
        button.active, button:hover {
            background-color: #334155;
            color: white;
        }
        .container {
            display: flex;
            max-width: 1200px;
            margin: 0 auto;
            gap: 30px;
        }
        .chart-area {
            flex: 3;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgb(0 0 0 / 0.1);
        }
        .info-area {
            flex: 1;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgb(0 0 0 / 0.1);
            text-align: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            font-size: 0.9rem;
        }
        th, td {
            border: 1px solid #cbd5e1;
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #e2e8f0;
            font-weight: 600;
        }
    </style>
</head>
<body>

<h2>풍력 발전량 시각화 (시간별 / 일간, 주간, 월간)</h2>

<div class="buttons">
    <button id="btnDaily" class="active" onclick="updateView('daily')">일간</button>
    <button id="btnWeekly" onclick="updateView('weekly')">주간</button>
    <button id="btnMonthly" onclick="updateView('monthly')">월간</button>
</div>

<div class="container">
    <div class="chart-area">
        <canvas id="lineChart" width="900" height="350"></canvas>
        <canvas id="pieChart" width="350" height="350" style="margin-top:40px;"></canvas>
    </div>

    <div class="info-area">
        <h3>발전소별 발전량 합계 (%)</h3>
        <table id="plantTable">
            <thead>
                <tr><th>발전소</th><th>합계 발전량</th></tr>
            </thead>
            <tbody>
                <!-- JS에서 채움 -->
            </tbody>
        </table>
    </div>
</div>

<script>
    // DTO 데이터가 넘어온다고 가정 (items는 List<WindPowerDTO>)
    // JSP에서 넘어오는 데이터를 JS 객체 배열로 변환
    const rawData = [
        <c:forEach var="item" items="${list}" varStatus="loop">
            {
                date: "${item.dgenYmd}",
                plantCode: "${item.ippt}",
                plantName: "${item.ipptNam}",
                // 시간별 발전량 24개
                gen: [
                    ${item.qhorGen01}, ${item.qhorGen02}, ${item.qhorGen03}, ${item.qhorGen04},
                    ${item.qhorGen05}, ${item.qhorGen06}, ${item.qhorGen07}, ${item.qhorGen08},
                    ${item.qhorGen09}, ${item.qhorGen10}, ${item.qhorGen11}, ${item.qhorGen12},
                    ${item.qhorGen13}, ${item.qhorGen14}, ${item.qhorGen15}, ${item.qhorGen16},
                    ${item.qhorGen17}, ${item.qhorGen18}, ${item.qhorGen19}, ${item.qhorGen20},
                    ${item.qhorGen21}, ${item.qhorGen22}, ${item.qhorGen23}, ${item.qhorGen24}
                ],
                total: ${item.qsum}
            }<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];

    let lineChart, pieChart;

    // 날짜 문자열을 Date 객체로 변환 (yyyyMMdd -> Date)
    function parseDate(str) {
        return new Date(str.substring(0,4), Number(str.substring(4,6))-1, str.substring(6,8));
    }

    // 데이터 그룹핑 함수 (일간, 주간, 월간)
    function groupData(type) {
        if (type === 'daily') {
            // 일간 그대로 리턴
            return rawData;
        }

        // 주간 그룹핑 (ISO 주차가 아니라, 첫 데이터 기준으로 7일씩 그룹)
        if (type === 'weekly') {
            let weeks = new Map();
            let firstDate = parseDate(rawData[0].date);
            rawData.forEach(d => {
                let curDate = parseDate(d.date);
                let diffDays = Math.floor((curDate - firstDate)/(1000*60*60*24));
                let weekNum = Math.floor(diffDays/7) + 1;
                if (!weeks.has(weekNum)) weeks.set(weekNum, []);
                weeks.get(weekNum).push(d);
            });

            let grouped = [];
            weeks.forEach((items, weekNum) => {
                // 각 시간별 발전량 합산 후 평균 구하기
                let genSum = new Array(24).fill(0);
                let plantNames = new Set();
                items.forEach(item => {
                    plantNames.add(item.plantName);
                    for (let i=0; i<24; i++) genSum[i] += item.gen[i];
                });

                // 주차 표시 (1주차, 2주차...)
                grouped.push({
                    date: weekNum + '주차',
                    plantName: Array.from(plantNames).join(", "),
                    gen: genSum,
                    total: genSum.reduce((a,b) => a+b, 0)
                });
            });
            return grouped;
        }

        // 월간 그룹핑
        if (type === 'monthly') {
            let months = new Map();
            rawData.forEach(d => {
                let monthKey = d.date.substring(0,6); // yyyyMM
                if (!months.has(monthKey)) months.set(monthKey, []);
                months.get(monthKey).push(d);
            });

            let grouped = [];
            months.forEach((items, monthKey) => {
                let genSum = new Array(24).fill(0);
                let plantNames = new Set();
                items.forEach(item => {
                    plantNames.add(item.plantName);
                    for(let i=0; i<24; i++) genSum[i] += item.gen[i];
                });

                grouped.push({
                    date: monthKey.substring(0,4) + "년 " + monthKey.substring(4,6) + "월",
                    plantName: Array.from(plantNames).join(", "),
                    gen: genSum,
                    total: genSum.reduce((a,b) => a+b, 0)
                });
            });
            return grouped;
        }
    }

    // lineChart 그리기
    function drawLineChart(data) {
        const ctx = document.getElementById('lineChart').getContext('2d');

        // 라벨: 시간 1~24시
        const hours = [];
        for(let i=1; i<=24; i++) hours.push(i + "시");

        // datasets: 각 날짜별(또는 주차/월간) 시간별 발전량
        // 최대 5개만 표시 (너무 많으면 복잡해서)
        let datasets = data.slice(0,5).map((d, idx) => ({
            label: d.date,
            data: d.gen,
            fill: false,
            borderColor: `hsl(${idx*60}, 70%, 50%)`,
            tension: 0.3,
            pointRadius: 3
        }));

        if(lineChart) lineChart.destroy();

        lineChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: hours,
                datasets: datasets
            },
            options: {
                responsive: false,
                plugins: {
                    legend: { position: 'bottom' }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: { display: true, text: '발전량' }
                    },
                    x: {
                        title: { display: true, text: '시간' }
                    }
                }
            }
        });
    }

    // pieChart 그리기 (발전소별 합계 발전량 비율)
    function drawPieChart(data) {
        const ctx = document.getElementById('pieChart').getContext('2d');

        // 발전소별 합계 집계
        let plantMap = new Map();
        data.forEach(d => {
            // d.plantName 여러개일 수 있지만, 여기선 첫번째만 쓸게
            // (daily는 단일 발전소, 주간/월간은 여러 발전소 합친 이름이라 제외)
            let plants = d.plantName.split(", ");
            plants.forEach(p => {
                plantMap.set(p, (plantMap.get(p) || 0) + d.total/data.length);
            });
        });

        let labels = Array.from(plantMap.keys());
        let values = Array.from(plantMap.values());

        if(pieChart) pieChart.destroy();

        pieChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    backgroundColor: labels.map((_,i) => `hsl(${i*60}, 70%, 60%)`),
                    borderColor: 'white',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: false,
                plugins: {
                    legend: { position: 'right' }
                }
            }
        });

        // 테이블도 같이 업데이트
        updateTable(plantMap);
    }

    // 발전소별 테이블 업데이트
    function updateTable(plantMap) {
        const tbody = document.querySelector("#plantTable tbody");
        tbody.innerHTML = "";
        plantMap.forEach((val, key) => {
            let tr = document.createElement("tr");
            let tdName = document.createElement("td");
            tdName.textContent = key;
            let tdVal = document.createElement("td");
            tdVal.textContent = val.toFixed(2);
            tr.appendChild(tdName);
            tr.appendChild(tdVal);
            tbody.appendChild(tr);
        });
    }

    // 뷰 변경 함수
    function updateView(type) {
        // 버튼 스타일 변경
        document.querySelectorAll(".buttons button").forEach(btn => btn.classList.remove("active"));
        document.getElementById("btn" + capitalize(type)).classList.add("active");

        const groupedData = groupData(type);
        drawLineChart(groupedData);
        drawPieChart(groupedData);
    }

    function capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    // 초기 화면 (일간)
    updateView('daily');

</script>

</body>
</html>