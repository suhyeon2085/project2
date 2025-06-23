<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <title>${targetYear}년 시간대 & 월별 평균 발전량</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
        }
        label {
            margin-right: 10px;
        }
        select, button {
            margin-right: 20px;
        }

        /* 가로 배치 flex */
        #chartsContainer {
            display: flex;
            flex-direction: row;
            gap: 40px;
            justify-content: center;
            align-items: flex-start;
            flex-wrap: nowrap;
            overflow-x: auto;
            padding-bottom: 10px;
        }

        /* 캔버스 크기 고정 */
        canvas {
            width: 600px !important;
            height: 400px !important;
            flex-shrink: 0;
            background: #fff;
            border: 1px solid #ccc;
            box-shadow: 0 0 8px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
    </style>
</head>
<body>

<h2>${targetYear}년 발전소+호기별 시간대 평균 발전량</h2>

<form method="get" action="wind">
    <label for="yearSelect">연도:</label>
    <select id="yearSelect" name="year">
        <c:forEach var="y" begin="2022" end="2025">
            <option value="${y}" <c:if test="${y.toString() eq targetYear.toString()}">selected</c:if>>${y}</option>
        </c:forEach>
    </select>

    <label for="keySelect">발전소+호기:</label>
    <select id="keySelect" name="targetKey">
        <option value="전체" <c:if test="${targetKey eq '전체'}">selected</c:if>>전체</option>
        <c:forEach var="key" items="${avgMap.keySet()}">
            <option value="${key}" <c:if test="${targetKey eq key}">selected</c:if>>${key}</option>
        </c:forEach>
    </select>

    <button type="submit">조회</button>
</form>

<hr/>

<div id="chartsContainer">
    <canvas id="hourlyChart" width="600" height="400"></canvas>
    <canvas id="monthlyChart" width="600" height="400"></canvas>
</div>

<script>
    const hourlyLabels = [
        "01시", "02시", "03시", "04시", "05시", "06시",
        "07시", "08시", "09시", "10시", "11시", "12시",
        "13시", "14시", "15시", "16시", "17시", "18시",
        "19시", "20시", "21시", "22시", "23시", "24시"
    ];

    const monthlyLabels = [
        "1월", "2월", "3월", "4월", "5월", "6월",
        "7월", "8월", "9월", "10월", "11월", "12월"
    ];

    // 시간대별 선택 데이터
    const selectedHourlyData = [
        <c:choose>
            <c:when test="${targetKey eq '전체'}">
                <c:forEach var="val" items="${totalAvg}" varStatus="s">
                    <fmt:formatNumber value="${val}" pattern="#.##" /><c:if test="${!s.last}">,</c:if>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <c:if test="${not empty avgMap[targetKey]}">
                    <c:forEach var="val" items="${avgMap[targetKey]}" varStatus="s">
                        <fmt:formatNumber value="${val}" pattern="#.##" /><c:if test="${!s.last}">,</c:if>
                    </c:forEach>
                </c:if>
            </c:otherwise>
        </c:choose>
    ];

    // 기준 시간대별 데이터
    const fixedHourlyData = [
        <c:forEach var="val" items="${fixedAvg}" varStatus="s">
            <fmt:formatNumber value="${val}" pattern="#.##" /><c:if test="${!s.last}">,</c:if>
        </c:forEach>
    ];

    // 월별 선택 데이터
    const selectedMonthlyData = [
        <c:choose>
            <c:when test="${targetKey eq '전체'}">
                <c:if test="${not empty monthlyAvgMap['전체']}">
                    <c:forEach var="val" items="${monthlyAvgMap['전체']}" varStatus="s">
                        <fmt:formatNumber value="${val}" pattern="#.##" /><c:if test="${!s.last}">,</c:if>
                    </c:forEach>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${not empty monthlyAvgMap[targetKey]}">
                    <c:forEach var="val" items="${monthlyAvgMap[targetKey]}" varStatus="s">
                        <fmt:formatNumber value="${val}" pattern="#.##" /><c:if test="${!s.last}">,</c:if>
                    </c:forEach>
                </c:if>
            </c:otherwise>
        </c:choose>
    ];

    // 기준 월별 데이터
    const fixedMonthlyData = [
        <c:choose>
            <c:when test="${not empty fixedMonthlyAvg[targetKey]}">
                <c:forEach var="val" items="${fixedMonthlyAvg[targetKey]}" varStatus="s">
                    <fmt:formatNumber value="${val}" pattern="#.##" /><c:if test="${!s.last}">,</c:if>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <c:if test="${not empty fixedMonthlyAvg['전체']}">
                    <c:forEach var="val" items="${fixedMonthlyAvg['전체']}" varStatus="s">
                        <fmt:formatNumber value="${val}" pattern="#.##" /><c:if test="${!s.last}">,</c:if>
                    </c:forEach>
                </c:if>
            </c:otherwise>
        </c:choose>
    ];

    // 시간대별 차트 생성
    new Chart(document.getElementById('hourlyChart').getContext('2d'), {
        type: 'line',
        data: {
            labels: hourlyLabels,
            datasets: [
                {
                    label: "${targetKey} (${targetYear}) 평균 발전량",
                    data: selectedHourlyData,
                    borderColor: 'rgba(54, 162, 235, 1)',
                    backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    borderWidth: 2,
                    tension: 0.3,
                    fill: true,
                },
                {
                    label: "기준 평균 (2022.01.01 ~ 2025.05.31)",
                    data: fixedHourlyData,
                    borderColor: 'rgba(255, 99, 132, 1)',
                    borderDash: [8, 4],
                    backgroundColor: 'rgba(255, 99, 132, 0.1)',
                    borderWidth: 2,
                    tension: 0.2,
                    fill: false,
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: "${targetYear}년 ${targetKey} 시간대 평균 vs 기준 평균"
                },
                legend: { position: 'bottom' },
                tooltip: { mode: 'index', intersect: false }
            },
            interaction: { mode: 'nearest', axis: 'x', intersect: false },
            scales: {
                y: { beginAtZero: true, title: { display: true, text: "평균 발전량 (kWh)" } }
            }
        }
    });

    // 월별 차트 생성
    new Chart(document.getElementById('monthlyChart').getContext('2d'), {
        type: 'line',
        data: {
            labels: monthlyLabels,
            datasets: [
                {
                    label: "${targetKey} (${targetYear}) 월별 평균 발전량",
                    data: selectedMonthlyData,
                    borderColor: 'rgba(75, 192, 192, 1)',
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderWidth: 2,
                    tension: 0.3,
                    fill: true,
                },
                {
                    label: "기준 평균 (2022.01.01 ~ 2025.05.31)",
                    data: fixedMonthlyData,
                    borderColor: 'rgba(153, 102, 255, 1)',
                    borderDash: [8,4],
                    backgroundColor: 'rgba(153, 102, 255, 0.1)',
                    borderWidth: 2,
                    tension: 0.2,
                    fill: false,
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: "${targetYear}년 ${targetKey} 월별 평균 발전량 vs 기준 평균"
                },
                legend: { position: 'bottom' }
            },
            scales: {
                y: { beginAtZero: true, title: { display: true, text: "평균 발전량 (kWh)" } }
            }
        }
    });
</script>

</body>
</html>
