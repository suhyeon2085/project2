<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="false" language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>날씨에 따라 다른 발전량</title>

<style>

* { box-sizing: border-box; }

body {
  background-color: #474747;
  font-family: 'Segoe UI', 'Malgun Gothic', sans-serif;
  margin: 0;
  padding: 0;
}
p { 
	color: white; 
	margin: 5px 10px; 
	font-size: 30px; } 
	
#title {
  display: flex; 
  flex-direction: column; 
  align-items: center;
  background-color: #595959; 
  border-radius: 10px; 
  padding: 10px 0;
  width: 70px; 
  flex-shrink: 0; 
  height: 570px; 
  gap: 7px;
}
#title div { 
	display: flex; 
	justify-content: center; 
	align-items: center; 
	height: 70px; 
	width: 100%; }
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
transition: all 0.3s ease; }

#korea {
  background-color: #595959; 
  padding: 0; 
  text-align: center;
  border-radius: 10px; 
  overflow: hidden; 
  flex-shrink: 0;
  width: 310px; 
  height: 570px; 
  margin: 0 10px;
}
#korea img {
  width: 250px; 
  height: 500px; 
  object-fit: cover; 
  border-radius: 10px;
}

#korea img:hover { 
transform: translateY(-5px); 
transition: all 0.3s ease; }

#weather {
  background: linear-gradient(45deg, #6799FF, white);
  padding: 10px; 
  border-radius: 10px; 
  width: 100%; 
  height: 270px;
  overflow: visible;
}

.weather-title {
  color: white; 
  font-size: 20px; 
  font-weight: bold;
  margin-left: 7px; 
  margin-bottom: 10px;
}

.weather-row {
  display: flex; 
  justify-content: space-between; 
  gap: 8px;
  flex-wrap: nowrap; 
  overflow-x: visible; 
  height: 250px;
}

.day-icon {
  display: flex; 
  flex-direction: column; 
  align-items: center;
  font-size: 17px; 
  color: #222; 
  background-color: rgba(255,255,255,0.7);
  border-radius: 8px; 
  padding: 15px; 
  min-width: 80px; 
  height: 210px;
}

.day-icon:hover{
transform: translateY(-5px); 
transition: all 0.3s ease;
}


/*날씨 img*/
.weather-icon {
  width: 80px; 
  height: 40px; 
  margin-top: 20px; 
  margin-bottom: 20px;
}

.weather-icon:hover{
transform: translateY(-5px); 
transition: all 0.3s ease;
}

.bottom-section {
  display: flex; 
  gap: 10px; 
  margin-top: 10px;
  width: 100%; 
  height: 287px; 
  margin-bottom: 0px;
}

.power-chart {
  flex: 2; 
  background-color: #595959; 
  padding: 10px;
  border-radius: 10px; 
  color: white; 
  font-size: 14px;
}

.right-info {
  flex: 1; 
  display: flex; 
  flex-direction: column;
  gap: 10px; 
  height: 300px;
}

.info-box {
  background-color: #595959; 
  padding: 10px;
  border-radius: 10px; 
  color: white; 
  font-size: 14px;
  height: 139px;
}

#map { 
	width: 100%; 
	height: 600px;
	transform: translateY(-5px); 
	transition: all 0.3s ease;
	 }
</style>
</head>
<body>

<header>
  <p>날씨에 따라 다른 발전량 알아보기</p>
</header>

<!-- 전체 레이아웃 -->
<div style="display: flex; width: 100%; padding: 10px;">
  <!-- 좌측: 메뉴 -->
  <div id="title">
    <div><a href="weather"><img src="resources/img/weather.png" alt="현재 목록"></a></div>
    <div><img src="resources/img/power.png" alt="이전 목록"></div>
    <div><a href="correlation"><img src="resources/img/correlation.png" alt="상관관계 그래프 목록"></a></div>
  </div>

  <!-- 지도 영역 -->
  <div id="korea">
    <div id="map"></div>
    <div style="color:white;"></div>
  </div>

  <!-- 우측 날씨예보 및 하단 정보 -->
  <div style="display: flex; flex-direction: column; flex: 1; gap: 3px; height: 600px;">
    <div id="weather">

      <div class="weather-title">주간 날씨 예보</div>
      <div class="weather-row">
        <div class="day-icon"><div>${weather.day}</div><img src="resources/img/sun.png" class="weather-icon">
        <div>${weather.minTemp}°C/${weather.maxTemp}°C</div><div>${weather.precipitation}</div><div>${weather.windDirection}°</div></div>
        
        <div class="day-icon"><div>${weather.day}</div><img src="resources/img/cloudy.png" class="weather-icon">
        <div>19/24</div><div>40%</div><div>3m/s</div></div>
         
        <div class="day-icon"><div>${weather.day}</div><img src="resources/img/windy.png" class="weather-icon">
        <div>17/23</div><div>10%</div><div>7m/s</div></div>
        
        <div class="day-icon"><div>${weather.day}</div><img src="resources/img/cloudy.png" class="weather-icon">
        <div>18/25</div><div>30%</div><div>4m/s</div></div>
        
        <div class="day-icon"><div>${weather.day}</div><img src="resources/img/cloudy.png" class="weather-icon">
        <div>20/27</div><div>20%</div><div>3m/s</div></div>
        
        <div class="day-icon"><div>${weather.day}</div><img src="resources/img/rainy.png" class="weather-icon">
        <div>22/28</div><div>90%</div><div>6m/s</div></div>
        
        <div class="day-icon"><div>${weather.day}</div><img src="resources/img/rainy.png" class="weather-icon">
        <div>23/29</div><div>80%</div><div>5m/s</div></div>
      </div>
    </div>


    <!-- 발전량과 기상 요소 -->
    <div class="bottom-section">
      <div class="power-chart">
        계절에 따라 다른 발전량 차이
        <div>봄</div>
        <div>여름</div>
        <div>가을</div>
        <div>겨울</div>
      </div>
      
      <div class="right-info">
        <div class="info-box">오늘의 바람 (풍향)
         <div>${weather.windSpeed}</div>
        <!-- 파이썬에서 받은 풍향 데이터 넣기  -->
        </div>
        <div class="info-box">오늘의 기압 (저/고)
        <!-- 파이썬에서 받은 기압 데이터 넣기  -->
        </div>
      </div>
      
    </div>
</div>
</div>

<script src="http://dapi.kakao.com/v2/maps/sdk.js?appkey=e950db27bdab1260d20a67d4d89b7bbf&autoload=false"></script>
<script>

  kakao.maps.load(function () {
    var mapContainer = document.getElementById('map');
    var mapOption = {
      center: new kakao.maps.LatLng(36.5, 127.8),
      level: 13
    };
    var map = new kakao.maps.Map(mapContainer, mapOption);
  });
</script>

</body>
</html>
