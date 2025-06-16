<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>풍력 발전량 예측 대시보드</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f4f6f8;
            margin: 40px;
            color: #333;
        }

        h2 {
            text-align: center;
            margin-bottom: 40px;
            color: #222;
        }

        .chart-container {
            width: 100%;
            max-width: 1000px;
            margin: 0 auto 60px;
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        canvas {
            width: 100% !important;
            height: 400px !important;
        }

        h3 {
            margin-bottom: 20px;
            font-size: 20px;
            color: #4f46e5;
            text-align: center;
        }
    </style>
</head>
<body>

<h2>풍력 발전량 예측 대시보드</h2>

<div class="chart-container">
    <h3>월별 전체 발전량 (작년 vs 예측)</h3>
    <canvas id="totalChart"></canvas>
</div>

<div class="chart-container">
    <h3>전체 발전소 예측 vs 실제</h3>
    <canvas id="plantChart"></canvas>
</div>

<script>
    const lastYearActual = {
        "202301": 500, "202302": 520, "202303": 550, "202304": 530, "202305": 600, "202306": 620,
        "202307": 610, "202308": 640, "202309": 630, "202310": 600, "202311": 590, "202312": 620
    };

    const thisYearForecast = {
        "202301": 510, "202302": 530, "202303": 560, "202304": 540, "202305": 610, "202306": 630,
        "202307": 620, "202308": 650, "202309": 640, "202310": 610, "202311": 600, "202312": 630
    };

    const plants = ["1호", "2호", "3호", "4호"];

    const plantActual = {
        "1호": [120,130,140,135,150,160,155,165,160,150,145,155],
        "2호": [110,115,120,118,125,130,128,132,130,125,122,128],
        "3호": [100,105,110,108,115,120,118,122,120,115,112,118],
        "4호": [90,95,100,98,105,110,108,112,110,105,102,108]
    };

    const plantForecast = {
        "1호": [125,135,145,140,155,165,160,170,165,155,150,160],
        "2호": [115,120,125,123,130,135,133,137,135,130,127,133],
        "3호": [105,110,115,113,120,125,123,127,125,120,117,123],
        "4호": [95,100,105,103,110,115,113,117,115,110,107,113]
    };

    const labels = Object.keys(lastYearActual).map(k => k.substring(4) + "월");
    const lastYearData = Object.values(lastYearActual);
    const thisYearData = Object.values(thisYearForecast);

    // 전체 발전량 비교 그래프
    new Chart(document.getElementById("totalChart"), {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: "작년 실제",
                    data: lastYearData,
                    backgroundColor: "rgba(54, 162, 235, 0.7)"
                },
                {
                    label: "올해 예측",
                    data: thisYearData,
                    backgroundColor: "rgba(255, 206, 86, 0.7)"
                }
            ]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });

    // 발전소별 실제 vs 예측 총합 그래프
    const sumActual = Array(12).fill(0);
    const sumForecast = Array(12).fill(0);

    for (let i = 0; i < 12; i++) {
        for (let plant of plants) {
            sumActual[i] += plantActual[plant][i];
            sumForecast[i] += plantForecast[plant][i];
        }
    }

    new Chart(document.getElementById("plantChart"), {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: "실제",
                    data: sumActual,
                    backgroundColor: "rgba(75, 192, 192, 0.7)"
                },
                {
                    label: "예측",
                    data: sumForecast,
                    backgroundColor: "rgba(255, 99, 132, 0.7)"
                }
            ]
        },
        options: {
            responsive: true,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });
</script>

</body>
</html>