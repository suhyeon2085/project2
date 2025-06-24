<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>발전량 예측 대시보드</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', 'Noto Sans KR', sans-serif;
            background-color: #f5f8fa;
            margin: 0;
            padding: 40px;
        }
        h2 {
            text-align: center;
            color: #222;
            font-size: 28px;
            margin-bottom: 30px;
        }
        .selector-container {
            text-align: center;
            margin-bottom: 30px;
        }
        select {
            padding: 10px 16px;
            font-size: 16px;
            border-radius: 8px;
            border: 1px solid #ccc;
        }
        .chart-container {
            background: white;
            padding: 24px;
            border-radius: 16px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
            width: 80%;
            max-width: 900px;
            margin: 0 auto;
        }
        canvas {
            width: 100% !important;
            height: auto !important;
        }
    </style>
</head>
<body>

<h2>📈 연도별 발전량 (3개 발전소 합산) vs 과거 평균 합산</h2>

<div class="selector-container">
    <label for="yearSelector">연도 선택: </label>
    <select id="yearSelector" onchange="updateChart()">
        <option value="2022">2022</option>
        <option value="2023">2023</option>
        <option value="2024">2024</option>
        <option value="2025">2025</option>
    </select>
</div>

<div class="chart-container">
    <canvas id="powerChart"></canvas>
</div>

<script>
    const list_9997 = JSON.parse('${list_9997}');
    const list_9998 = JSON.parse('${list_9998}');
    const list_D001 = JSON.parse('${list_D001}');
    const pred_9997 = JSON.parse('${pred_9997}');
    const pred_9998 = JSON.parse('${pred_9998}');
    const pred_D001 = JSON.parse('${pred_D001}');
    const aver_9997 = JSON.parse('${aver_9997}');
    const aver_9998 = JSON.parse('${aver_9998}');
    const aver_D001 = JSON.parse('${aver_D001}');

    const labels = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"];

    // 3개 발전소 데이터를 연도별로 슬라이스 및 합산 함수
    function sumMonthlyData(year) {
        // 1년 데이터 12개월 = 12개 데이터, list 데이터 배열 전체 월 수에 따라 인덱스 조정 필요
        // 2022년 ~ 2024년은 슬라이스 인덱스, 2025년은 pred 배열 그대로 사용

        // slice 인덱스: 2022 -> 84~95, 2023 -> 96~107, 2024 -> 108~119 (0부터 시작)
        const yearIndexMap = {
            "2022": [84, 96],
            "2023": [96, 108],
            "2024": [108, 120]
        };

        let data9997, data9998, dataD001;

        if(year === "2025") {
            data9997 = pred_9997;
            data9998 = pred_9998;
            dataD001 = pred_D001;
        } else {
            let [start, end] = yearIndexMap[year];
            data9997 = list_9997.slice(start, end);
            data9998 = list_9998.slice(start, end);
            dataD001 = list_D001.slice(start, end);
        }

        // 3개 발전소 월별 합산 배열 생성
        const summed = [];
        for(let i=0; i<12; i++) {
            const val9997 = Number(data9997[i]) || 0;
            const val9998 = Number(data9998[i]) || 0;
            const valD001 = Number(dataD001[i]) || 0;
            summed.push(val9997 + val9998 + valD001);
        }
        return summed;
    }

    // 3개 발전소 평균 발전량 합산 (고정)
    const avgSum = [];
    for(let i=0; i<12; i++) {
        avgSum[i] = (Number(aver_9997[i]) || 0) + (Number(aver_9998[i]) || 0) + (Number(aver_D001[i]) || 0);
    }

    let chart;

    function updateChart() {
        const year = document.getElementById("yearSelector").value;
        const summedData = sumMonthlyData(year);

        chart.data.datasets[0].data = summedData;
        chart.data.datasets[0].label = `${year}년 3개 발전소 합산 발전량`;

        chart.data.datasets[1].data = avgSum;
        chart.data.datasets[1].label = `2015~2024년 3개 발전소 평균 발전량 합산`;

        chart.options.plugins.title.text = `${year}년 발전량 vs 평균 발전량 (3개 발전소 합산)`;
        chart.update();
    }

    window.onload = function () {
        const ctx = document.getElementById('powerChart').getContext('2d');
        chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: "연도별 발전량",
                        data: [],
                        borderColor: 'blue',
                        backgroundColor: 'rgba(0, 0, 255, 0.1)',
                        tension: 0.3
                    },
                    {
                        label: "평균 발전량",
                        data: [],
                        borderColor: 'red',
                        backgroundColor: 'rgba(255, 0, 0, 0.1)',
                        borderDash: [5, 5],
                        tension: 0.3
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: '발전량 예측',
                        font: { size: 18 }
                    },
                    legend: {
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: '발전량 (단위)'
                        }
                    }
                }
            }
        });

        updateChart(); // 초기 차트 그리기
    };
</script>

</body>
</html>