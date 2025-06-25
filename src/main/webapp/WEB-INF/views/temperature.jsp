<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>풍향과 발전량의 상관관계 그래프</title>
<style>
body{
	background-color: #474747;
	display: flex;
	font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; 
}

/* 메뉴 사이드바 */
#title {
	display: flex;
	flex-direction: column;
	align-items: center;
	background-color: #595959;
	border-radius: 10px;
	padding: 10px 5px;
	width: 70px;
	flex-shrink: 0;
	height: 850px;
	gap: 7px;
	margin-top:30px;
}
#title div {
	display: flex;
	justify-content: center;
	align-items: center;
	height: 70px;
	width: 100%;
}
#title a {
	display: flex;
	justify-content: center;
	align-items: center;
	width: 100%;
	height: 100%;
	text-decoration: none;
}
#title img {
	width: 50px;
	height: 56px;
	object-fit: contain;
}
#title img:hover {
	transform: translateY(-5px);
	transition: all 0.3s ease;
}

#sun{
	background-color: #595959;
	width:100%;
	border-radius: 10px;
	padding: 10px 10px;
	margin-left: 10px;
	margin-top:30px;
}
p{
	color: white;
	margin: 5px 10px;
	font-size: 30px;
}
/* 입체감 있는 버튼 스타일 */
.button-3d {
    padding: 7px;
    height: auto;
    box-sizing: border-box;
    border-radius: 50px;
    font-size: 12px;
    font-weight: 700;
    color: #595959;
    border: 2px solid #999999;  
    background-color: #F4F3F2; 
    cursor: pointer;
    transition: all 0.3s ease;
    font-family: 'Trebuchet MS', 'Segoe UI', Verdana, sans-serif;
    font-size: 17px;
    font-weight: bold;
    text-decoration: none;
    display: inline-block;
    text-align: center;
    width: 140px;
}


.button-3d:hover {
    background-color: #e0e0e0;  
    border-color: #7a7a7a; 
    box-shadow: 0px -2px 6px #ffffff, 0px 2px 6px #b0b0b0;
    color: #444444;          
}

</style> 
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
	<div id="title">
		<div><a href="weather"><img src="resources/img/weather.png" alt="현재 목록"></a></div>
		<div><img src="resources/img/power.png" alt="이전 목록"></div>
		<div><a href="correlation"><img src="resources/img/correlation.png" alt="상관관계 그래프 목록"></a></div>
	</div>
	
	  
	<!-- 기온 발전량 그래프 --> 
	<div id="sun">
		<div style="display: flex; justify-content: space-between; align-items: center;">
		  <p style="margin: 0;">풍향과 발전량 그래프</p>
		  <a href="windspeed" class="button-3d">풍속 바로가기</a>
		</div>
 
	
	<!-- 차트 그릴 캔버스 -->
	
	<!-- 풍향 & 발전량 상관관계  -->
	<div>
	  	<canvas id="windDirPowerChart" width="300" height="100" style="margin-top:30px;"></canvas>
	</div>  	
	
	<div>
	    <canvas id="windDirVsPowerScatter" width="800" height="400" style="margin-top:50px;"></canvas>
	</div>
	
	</div>
	
<script>
	//상관관계 표현 ( 상관관계 산점도) 
	const dataList = JSON.parse('<c:out value="${dataListJson}" escapeXml="false" />');
	
	// 1. 날짜에서 'YYYY-MM'만 추출
		const monthlyLabels = [...new Set(dataList.map(d => d.date.substring(0, 7)))];
		
		// 2. 월별로 그룹화
		const grouped = {};
		dataList.forEach(d => {
		    const month = d.date.substring(0, 7);
		    if (!grouped[month]) {
		        grouped[month] = { power: [], windDir: [] };
		    }
		    grouped[month].power.push(d.power);
		    grouped[month].windDir.push(d.windDirection);
		});
		
		// 3. 월별 평균 계산
		const avgPower = monthlyLabels.map(m => {
		    const arr = grouped[m].power;
		    return arr.reduce((a, b) => a + b, 0) / arr.length;
		});
		const avgWindDir = monthlyLabels.map(m => {
		    const arr = grouped[m].windDir;
		    return arr.reduce((a, b) => a + b, 0) / arr.length;
		});
	    
	    
		// 4. 차트 생성
		new Chart(document.getElementById('windDirPowerChart'), {
		    type: 'line',
		    data: {
		        labels: monthlyLabels,
		        datasets: [
		            {
		                label: '발전량 (월 평균)',
		                data: avgPower,
		                yAxisID: 'y',
		                borderColor: '#3498db',
		                backgroundColor: 'rgba(52, 152, 219, 0.2)',
		                fill: true,
		                tension: 0.3
		            },
		            {
		                label: '풍향 (월 평균)',
		                data: avgWindDir,
		                yAxisID: 'y1',
		                borderColor: '#f39c12',
		                backgroundColor: 'rgba(243, 156, 18, 0.2)',
		                fill: true,
		                tension: 0.3
		            }
		        ]
		    },
		    options: {
		        responsive: true,
		        plugins: {
		            legend: {
		                labels: {
		                    color: '#ffffff',
		                    font: { size: 14, weight: 'bold' }
		                }
		            },
		            tooltip: {
		                backgroundColor: '#2c3e50',
		                titleColor: '#ffffff',
		                bodyColor: '#ecf0f1'
		            }
		        },
		        scales: {
		            x: {
		                ticks: {
		                    color: '#ffffff',
		                    font: { size: 12 }
		                },
		                grid: {
		                    color: '#555555'
		                }
		            },
		            y: {
		                type: 'linear',
		                position: 'left',
		                title: {
		                    display: true,
		                    text: '발전량',
		                    color: '#ffffff',
		                    font: { size: 14 }
		                },
		                ticks: {
		                    color: '#ffffff'
		                },
		                grid: {
		                    color: '#444444'
		                }
		            },
		            y1: {
		                type: 'linear',
		                position: 'right',
		                min: 0,
		                max: 360,
		                title: {
		                    display: true,
		                    text: '풍향 (0~360도)',
		                    color: '#ffffff',
		                    font: { size: 14 }
		                },
		                ticks: {
		                    color: '#ffffff'
		                },
		                grid: {
		                    drawOnChartArea: false
		                }
		            }
		        }
		    }
		});
	
	
	// 연도별 비교 차트( 시계열 비교 )
	const scatterData = dataList.map(d => ({
	    x: d.windDirection,
	    y: d.power
	  }));
	
	  // 단순 선형회귀 함수 (y = mx + b)
	  function linearRegression(x, y) {
	    const n = x.length;
	    const xMean = x.reduce((a,b) => a+b, 0) / n;
	    const yMean = y.reduce((a,b) => a+b, 0) / n;
	
	    let numerator = 0, denominator = 0;
	    for(let i=0; i<n; i++) {
	      numerator += (x[i] - xMean)*(y[i] - yMean);
	      denominator += (x[i] - xMean)**2;
	    }
	
	    const m = numerator / denominator;
	    const b = yMean - m * xMean;
	
	    return {m, b};
	  }
	
	  const xVals = scatterData.map(p => p.x);
	  const yVals = scatterData.map(p => p.y);
	  const {m, b} = linearRegression(xVals, yVals);
	
	  // 회귀선 끝점 (풍향 0~360)
	  const regressionLine = [
	    {x: 0, y: b},
	    {x: 360, y: m*360 + b}
	  ];
	
	  // 산점도 + 회귀선 차트 그리기
	  new Chart(document.getElementById('windDirVsPowerScatter'), {
	    type: 'scatter',
	    data: {
	      datasets: [
	        {
	          label: '풍향 vs 발전량',
	          data: scatterData,
	          backgroundColor: '#27ae60',
	        },
	        {
	          label: '회귀선',
	          data: regressionLine,
	          type: 'line',
	          borderColor: '#e74c3c',
	          pointRadius: 0,
	          fill: false,
	          tension: 0
	        }
	      ]
	    },
	    options: {
	      scales: {
	        x: {
	          type: 'linear',
	          min: 0,
	          max: 360,
	          title: {
	            display: true,
	            text: '풍향 (°)'
	          }
	        },
	        y: {
	          title: {
	            display: true,
	            text: '발전량'
	          }
	        }
	      }
	    }
	  });
</script>

<!--  확인하는 템플릿 문자열  -->
<%--  ${dataListJson}  --%>
</body>
</html>