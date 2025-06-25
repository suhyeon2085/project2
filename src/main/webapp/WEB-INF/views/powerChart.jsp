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
            margin: 0 auto;
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
        <button onclick="updateAllCharts('2022')">2022년</button>
        <button onclick="updateAllCharts('2023')">2023년</button>
        <button onclick="updateAllCharts('2024')">2024년</button>
        <button onclick="updateAllCharts('2025')">2025년 (예측)</button>
    </div>

    <div class="chart-container">
        <div class="chart-box line-chart">
            
            <canvas id="lineChart"></canvas>
        </div>

        <div class="side-charts">
            <div class="chart-box small-chart">
                <h3>발전소별 월별 발전량</h3>
                <canvas id="barChart"></canvas>
            </div>
            <div class="chart-box small-chart">
                <h3>발전소별 연도별 합산 발전량 추이</h3>
                <canvas id="trendChart"></canvas>
            </div>
        </div>
    </div>

<script>
    // JSP에서 전달된 JSON 문자열을 JS 배열로 파싱
    const list_9997 = ${list_9997};
    const list_9998 = ${list_9998};
    const list_D001 = ${list_D001};

    const pred_9997 = ${pred_9997};
    const pred_9998 = ${pred_9998};
    const pred_D001 = ${pred_D001};

    const aver_9997 = ${aver_9997};
    const aver_9998 = ${aver_9998};
    const aver_D001 = ${aver_D001};

    const labels = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"];

    const yearIndexMap = {
        "2022": [84, 96],
        "2023": [96, 108],
        "2024": [108, 120]
    };

    function getSummedMonthlyData(year) {
        let data9997, data9998, dataD001;
        if (year === '2025') {
            data9997 = pred_9997;
            data9998 = pred_9998;
            dataD001 = pred_D001;
        } else if (yearIndexMap.hasOwnProperty(year)) {
            const [start, end] = yearIndexMap[year];
            data9997 = list_9997.slice(start, end);
            data9998 = list_9998.slice(start, end);
            dataD001 = list_D001.slice(start, end);
        } else {
            data9997 = [];
            data9998 = [];
            dataD001 = [];
        }

        const summed = [];
        for(let i=0; i<12; i++){
            summed[i] = (Number(data9997[i])||0) + (Number(data9998[i])||0) + (Number(dataD001[i])||0);
        }
        return summed;
    }

    function getFixedAverageSum() {
        const avgArr = [];
        for(let i=0; i<12; i++){
            avgArr[i] = (Number(aver_9997[i])||0) + (Number(aver_9998[i])||0) + (Number(aver_D001[i])||0);
        }
        return avgArr;
    }

    function getMonthlyDataByPlant(year) {
        let data9997, data9998, dataD001;
        if (year === '2025') {
            data9997 = pred_9997;
            data9998 = pred_9998;
            dataD001 = pred_D001;
        } else if (yearIndexMap.hasOwnProperty(year)) {
            const [start, end] = yearIndexMap[year];
            data9997 = list_9997.slice(start, end);
            data9998 = list_9998.slice(start, end);
            dataD001 = list_D001.slice(start, end);
        } else {
            data9997 = [];
            data9998 = [];
            dataD001 = [];
        }

        data9997 = data9997.map(x => Number(x) || 0);
        data9998 = data9998.map(x => Number(x) || 0);
        dataD001 = dataD001.map(x => Number(x) || 0);

        return { data9997, data9998, dataD001 };
    }

    function getYearlySumByPlant() {
        const years = ["2022", "2023", "2024", "2025"];

        function sumRange(arr, start, end) {
            return arr.slice(start, end).reduce((a,b) => a + Number(b||0), 0);
        }

        const sums9997 = [];
        const sums9998 = [];
        const sumsD001 = [];

        years.forEach(year => {
            if(year === '2025') {
                sums9997.push(pred_9997.reduce((a,b) => a + Number(b||0), 0));
                sums9998.push(pred_9998.reduce((a,b) => a + Number(b||0), 0));
                sumsD001.push(pred_D001.reduce((a,b) => a + Number(b||0), 0));
            } else if(yearIndexMap.hasOwnProperty(year)) {
                const [start, end] = yearIndexMap[year];
                sums9997.push(sumRange(list_9997, start, end));
                sums9998.push(sumRange(list_9998, start, end));
                sumsD001.push(sumRange(list_D001, start, end));
            } else {
                sums9997.push(0);
                sums9998.push(0);
                sumsD001.push(0);
            }
        });

        return { sums9997, sums9998, sumsD001, years };
    }

    let lineChart, barChart, trendChart;

    function updateAllCharts(year) {
        const summedData = getSummedMonthlyData(year);
        const fixedAvgData = getFixedAverageSum();

        if(lineChart) lineChart.destroy();

        const ctxLine = document.getElementById('lineChart').getContext('2d');
        lineChart = new Chart(ctxLine, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: year + '년 발전량 (3개 발전소 합산)',
                        data: summedData,
                        borderColor: 'lime',
                        backgroundColor: 'rgba(50,205,50,0.3)',
                        tension: 0.3,
                        fill: true,
                    },
                    {
                        label: '평균 발전량 (월별 총합 평균)',
                        data: fixedAvgData,
                        borderColor: 'orange',
                        borderDash: [6, 6],
                        tension: 0,
                        fill: false,
                        pointRadius: 0,
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: year + '년 발전량 vs 평균 발전량',
                        color: 'white',
                        font: {size: 18}
                    },
                    legend: {
                        position: 'top',
                        labels: {color: 'white'}
                    },
                    tooltip: {
                        callbacks: {
                            label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y.toLocaleString()} MW`
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {display:true, text:'발전량 (MW)', color: 'white'},
                        ticks: {color: 'white'}
                    },
                    x: {
                        title: {display:true, text:'월', color: 'white'},
                        ticks: {color: 'white'}
                    }
                }
            }
        });

        const plantData = getMonthlyDataByPlant(year);

        if(barChart) barChart.destroy();

        const ctxBar = document.getElementById('barChart').getContext('2d');
        barChart = new Chart(ctxBar, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: '영흥풍력1호기',
                        data: plantData.data9997,
                        backgroundColor: 'rgba(54, 162, 235, 0.7)'
                    },
                    {
                        label: '영흥풍력2호기',
                        data: plantData.data9998,
                        backgroundColor: 'rgba(255, 99, 132, 0.7)'
                    },
                    {
                        label: '군위 화산풍력',
                        data: plantData.dataD001,
                        backgroundColor: 'rgba(255, 206, 86, 0.7)'
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                	
                    legend: {
                        position: 'top',
                        labels: {color: 'white'}
                    },
                    tooltip: {
                        callbacks: {
                            label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y.toLocaleString()} MW`
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {display:true, text:'발전량 (MW)', color: 'white'},
                        ticks: {color: 'white'}
                    },
                    x: {
                        title: {display:true, text:'월', color: 'white'},
                        ticks: {color: 'white'}
                    }
                }
            }
        });

        if(trendChart) trendChart.destroy();

        const yearlyData = getYearlySumByPlant();
        const maxValue = Math.max(...yearlyData.sums9997, ...yearlyData.sums9998, ...yearlyData.sumsD001);

        const ctxTrend = document.getElementById('trendChart').getContext('2d');
        trendChart = new Chart(ctxTrend, {
            type: 'line',
            data: {
                labels: yearlyData.years,
                datasets: [
                    {
                        label: '영흥풍력1호기 합산',
                        data: yearlyData.sums9997,
                        borderColor: 'rgba(54, 162, 235, 1)',
                        
                        tension: 0.3,
                        fill: true
                    },
                    {
                        label: '영흥풍력2호기 합산',
                        data: yearlyData.sums9998,
                        borderColor: 'rgba(255, 99, 132, 1)',
                        
                        tension: 0.3,
                        fill: true
                    },
                    {
                        label: '군위 화산풍력 합산',
                        data: yearlyData.sumsD001,
                        borderColor: 'rgba(255, 206, 86, 1)',
                        
                        tension: 0.3,
                        fill: true
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {color: 'white'}
                    },
                    tooltip: {
                        callbacks: {
                            label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y.toLocaleString()} MW`
                        }
                    },
                    
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: maxValue * 1.1,  // 최대값보다 10% 여유 둠
                        title: {display:true, text:'발전량 (MW)', color: 'white'},
                        ticks: {color: 'white'}
                    },
                    x: {
                        title: {display:true, text:'연도', color: 'white'},
                        ticks: {color: 'white'}
                    }
                }
            }
        });
    }

    updateAllCharts('2022');
</script>

</body>
</html>