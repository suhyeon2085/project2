<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>기온과 발전량의 상관관계 그래프</title>
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
	margin-top: 30px;
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
		  <p style="margin: 0;">풍속과 발전량 그래프</p>
		  <a href="temperature" class="button-3d">풍향 바로가기</a>
		</div>


	
	
		<div id="windDirection"> 
			<!-- 차트 그릴 캔버스 -->
			<canvas id="windPowerChart"></canvas>
			<canvas id="windVsPowerScatter"></canvas>
		</div>
	
	
	
	</div>
	${dataListJson} 
<script>

// ③ 풍속-발전량 시계열 + 이중축
new Chart(document.getElementById('windPowerChart'), {
  type: 'bar',
  data: {
    labels: dates,
    datasets: [
      {
        type: 'bar',
        label: '발전량',
        data: powers,
        yAxisID: 'y',
        backgroundColor: '#1abc9c'
      },
      {
        type: 'line',
        label: '풍속',
        data: winds,
        yAxisID: 'y1',
        borderColor: '#9b59b6',
        fill: false
      }
    ]
  },
  options: {
    scales: {
      y: { type: 'linear', position: 'left', title: { display:true, text:'발전량' } },
      y1: { type: 'linear', position: 'right', title: { display:true, text:'풍속' }, grid: { drawOnChartArea:false } }
    }
  }
});

// ④ 풍속-발전량 산점도 + 회귀선
{
  const scatterCtx2 = document.getElementById('windVsPowerScatter').getContext('2d');
  const {m, b} = linearRegression(winds, powers);
  const xMin = Math.min(...winds);
  const xMax = Math.max(...winds);
  const regress = [{x: xMin, y: m * xMin + b}, {x: xMax, y: m * xMax + b}];

  new Chart(scatterCtx2, {
    type: 'scatter',
    data: {
      datasets: [
        { label: '산점도', data: scatterDataWindSpeed, backgroundColor: 'rgba(75, 192, 192, 0.7)' },
        { label: '회귀선', data: regress, type: 'line', borderColor: '#c0392b', fill: false, pointRadius: 0 }
      ]
    },
    options: {
      responsive: true,
      scales: {
        x: {
          type: 'linear',
          position: 'bottom',
          title: { display: true, text: '풍속' }
        },
        y: {
          title: { display: true, text: '발전량' }
        }
      },
      plugins: {
        legend: { display: true, position: 'top' },
        tooltip: { enabled: true }
      }
    }
  });
}

</script>
	
</body>
</html>