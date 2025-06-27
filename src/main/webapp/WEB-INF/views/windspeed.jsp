<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>기온과 발전량의 상관관계 그래프</title>
<style>
body{
	background-color: #003366;
	display: flex;
	font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif; 
}

/* 메뉴 사이드바 */
#title {
	display: flex;
	flex-direction: column;
	align-items: center;
	background-color: rgba(240,240,240,0.6);
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
#contain{
	background-color: rgba(240,240,240,0.6);
	width:100%;
	border-radius: 10px;
	padding: 10px;
	margin-left: 10px;
	margin-top:30px;
}
#sun{
	background-color: #595959;
	width:100%;
	border-radius: 10px;
	padding: 10px;
	/*margin-left: 10px;
	margin-top: 30px;*/
	box-sizing: border-box;
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
    border-radius: 10px;
    font-size: 12px;
    font-weight: 700;
    color: #F4F3F2;
    border: 2px solid #999999;  
/*     background-color: #F4F3F2;  */
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
	/*타이틀 css*/
	/* 툴팁이 들어갈 부모 a태그 위치 지정 */
	.tooltip-container {
	  position: relative;
	  display: inline-block;
	}
	
	/* 툴팁 텍스트 숨기기 + 스타일 */
	.tooltip-text {
	  visibility: hidden;
	  width: max-content;
	  max-width: 300px;
	  background-color: rgba(0, 0, 0, 0.75);
	  color: #fff;
	  text-align: center;
	  padding: 6px 10px;
	  border-radius: 6px;
	
	  /* 위치 조절 */
	  position: absolute;
	  bottom: 110%;  /* 이미지 바로 위에 뜨도록 */
	  left: 0;
	  transform: none;
	  z-index: 10;
	
	  /* 부드러운 나타남 효과 */
	  opacity: 0;
	  transition: opacity 0.3s;
	  pointer-events: none; /* 마우스 이벤트 차단 */
	}
	
	/* 화살표 추가 */
	.tooltip-text::after {
	  content: "";
	  position: absolute;
	  top: 100%;  /* 툴팁 박스 아래쪽 */
	  left: 14px;
	  border-width: 6px;
	  border-style: solid;
	  border-color: rgba(0, 0, 0, 0.75) transparent transparent transparent;
	}
	
	/* 마우스 오버 시 툴팁 보이기 */
	.tooltip-container:hover .tooltip-text {
	  visibility: visible;
	  opacity: 1;
	}
	.tooltip-container:first-child .tooltip-text {
	  bottom: auto;
	  top: 110%;   /* 위가 아니라 아래에 뜨게 */
	  left: 0;
	  transform:none;
	}
	.tooltip-container:first-child .tooltip-text::after {
	  top: -6px; /* 화살표가 텍스트 위에 붙음 */
	  transform: translateX(-50%) rotate(180deg);  /* 아래 화살표를 위쪽 화살표로 돌림 */
	  border-color: transparent transparent rgba(0, 0, 0, 0.75) transparent;
	}



</style>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@2"></script>
</head>

<body>
	<div id="title">
	  <div>
	    <a href="weather" class="tooltip-container">
	      <img src="resources/img/1.png" alt="날씨 목록">
	      <span class="tooltip-text">날씨에 따라 다른 발전량 알아보기</span>
	    </a>
	  </div>
	  <div>
	    <a href="powerChart" class="tooltip-container">
	      <img src="resources/img/2.png" alt="발전량 예측 목록"">
	      <span class="tooltip-text">풍력 발전량 비교</span>
	    </a>
	  </div>
	  <div>
	    <a href="windspeed" class="tooltip-container">
	      <img src="resources/img/3.png" alt="상관관계 그래프 목록">
	      <span class="tooltip-text">풍향과 발전량 상관관계</span>
	    </a>
	  </div>
	</div>
	
	
	<!-- 기온 발전량 그래프 -->
	<div id="contain">
	<div id="sun">
		<div style="display: flex; justify-content: space-between; align-items: center;">
		  <p style="margin: 0;">풍속과 발전량 그래프</p>
		  <!-- <a href="temperature" class="button-3d">풍향 바로가기</a> -->
		</div>


		<!-- 차트 그릴 캔버스 -->
		<div><!-- 풍속 & 발전량 상관관계  -->
		  	<canvas id="windPowerChart" width="300" height="65" style="margin-top:10px;"></canvas>
		</div>  
			
		
		<div><!-- 날짜 풍속 & 발전량 상관관계  -->
		    <canvas id="windVsPowerScatter" width="300" height="65" style="margin-top:10px;"></canvas>
		</div>
	
	</div>
	</div>

<script>
// const rawData = '<c:out value="${dataListJson}" escapeXml="false" />';

  
  //const dataList = JSON.parse('<c:out value="${dataListJson}" escapeXml="false" />');
  const dataList = ${dataListJson};
  console.log("✅ 파싱된 dataList:", dataList);
  console.log("🌬 풍속(wind) 리스트:", dataList.map(d => d.wind));
  
  // 1. 날짜에서 'YYYY-MM'만 추출
  const monthlyLabels = [...new Set(dataList.map(d => d.date.substring(0, 7)))];

  // 2. 월별로 그룹화
  const grouped = {};
  dataList.forEach(d => {
    const month = d.date.substring(0, 7);
    if (!grouped[month]) {
      grouped[month] = { power: [], wind: [] };
    }
    grouped[month].power.push(d.power);
    grouped[month].wind.push(d.wind);
  });
  


  // 3. 월별 평균 계산
  const avgPower = monthlyLabels.map(m => {
    const arr = grouped[m].power;
    return arr.reduce((a, b) => a + b, 0) / arr.length;
  });
  const avgWind = monthlyLabels.map(m => {
    const arr = grouped[m].wind;
    return arr.reduce((a, b) => a + b, 0) / arr.length;
  });

  // 4. 라인 차트: 풍속과 발전량 (월 평균)
  new Chart(document.getElementById('windPowerChart'), {
    type: 'line',
    data: {
      labels: monthlyLabels,
      datasets: [
        {
          label: '발전량 없애기👆❗',
          data: avgPower,
          yAxisID: 'y',
          borderColor: '#3498db',
          backgroundColor: 'rgba(52, 152, 219, 0.2)',
          fill: true,
          tension: 0.3
        },
        {
          label: '풍속 없애기👆❗',
          data: avgWind,
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
            maxTicksLimit: 12,
            color: '#ffffff',
            font: { size: 12 }
          },
          grid: {
            color: '#555555'
          }
        },
        y: {
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
          position: 'right',
          title: {
            display: true,
            text: '풍속',
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

  // 5. 풍속 vs 발전량 산점도 + 회귀선
  const scatterData = dataList.map(d => ({
    x: d.wind,   // 풍속
    y: d.power   // 발전량
  }));

  function linearRegression(x, y) {
    const n = x.length;
    const xMean = x.reduce((a, b) => a + b, 0) / n;
    const yMean = y.reduce((a, b) => a + b, 0) / n;

    let numerator = 0, denominator = 0;
    for (let i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += Math.pow(x[i] - xMean, 2);
    }

    const m = numerator / denominator;
    const b = yMean - m * xMean;
    return { m, b };
  }

  const xVals = scatterData.map(p => p.x);
  const yVals = scatterData.map(p => p.y);
  const { m, b } = linearRegression(xVals, yVals);

  const regressionLine = [
//    { x: 0, y: b },
//    { x: 20, y: m * 20 + b } // 풍속 최대값 20 정도로 가정
 ];
 
 for (let x = 0; x <= 20; x += 0.5) {
	  regressionLine.push({ x, y: m * x + b }); //풍속 발전량 없애도 회귀선 그대로 있도록 회귀선 포인트를 더많들어주는 함수 
	}
 
  new Chart(document.getElementById('windVsPowerScatter'), {
    type: 'scatter',
    data: {
      datasets: [
        {
          label: '풍속 vs 발전량 없애기👆❗',
          data: scatterData,
          backgroundColor: 'rgba(39, 174, 96, 0.7)',
          borderColor: '#27ae60',
          pointRadius: 6,
          pointHoverRadius: 9,
          pointHoverBackgroundColor: '#2ecc71'
        },
        {
          label: '회귀선 없애기👆❗',
          data: regressionLine,
          type: 'line',
          borderColor: '#e74c3c',
          borderWidth: 3,
          pointRadius: 4,
          pointHoverRadius: 5,
          pointBackgroundColor: '#e74c3c',
          fill: true,
          backgroundColor: 'rgba(231, 76, 60, 0.1)',
          tension: 0
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
        	enabled: true,
          backgroundColor: '#34495e',
          titleColor: '#ecf0f1',
          bodyColor: '#ecf0f1',
          callbacks: {
            label: function (context) {
//             	  console.log('tooltip context:', context);


             }
          }
        }
      },
      scales: {
        x: {
          type: 'linear',
          min: 0,
          max: 15,
          title: {
            display: true,
            text: '풍속 (m/s)',
            color: '#ffffff',
            font: { size: 16, weight: 'bold' }
          },
          ticks: {
            color: '#ffffff',
            stepSize: 2,
            font: { size: 12 }
          },
          grid: {
            color: 'rgba(255,255,255,0.2)',
            borderColor: '#cccccc'
          }
        },
        y: {
        	min:1,
          title: {
            display: true,
            text: '발전량',
            color: '#ffffff',
            font: { size: 16, weight: 'bold' }
          },
          ticks: {
            color: '#ffffff',
            font: { size: 12 }
          },
          grid: {
            color: 'rgba(255,255,255,0.2)',
            borderColor: '#cccccc'
          }
        }
      },
      layout: {
        padding: 20
      }
    }
  });
</script>


</body>
</html>