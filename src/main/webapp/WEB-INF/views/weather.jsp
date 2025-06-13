<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>날씨에 따라 다른 발전량</title>
</head>
<style>
body{
background-color: #474747;
font-family: 'Segoe UI', 'Malgun Gothic', sans-serif;
}

p{
color: white;
margin: 5px 5px;
}

#korea {
	background-color: #595959;
    padding: 0px;
    text-align: center;
    width : 310px;
    height : 310px;
    margin: 5px 5px;
    border-radius : 10px;
	overflow: hidden;
}
#korea img {
    width: 310px;
    height: 310px;
    object-fit: cover;
    box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.5);  /* 입체 그림자 */
    border-radius: 10px;                          /* 둥근 테두리 */
}
#korea img:hover {
    transform: translateY(-5px); /* 살짝 위로 뜨게 */
    transition: all 0.3s ease;
}

#title{
	display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    align-items: flex-start; /* 왼쪽 정렬 */
    background-color: #595959;
    border-radius : 10px;
    margin: 5px 5px;
    width: 70px;
    padding: 10px 0;
}

#title div{
	display: flex;
	justify-content: center;
	align-items: center;
	height: 60px;
	width: 60px;
	margin: 5px 0;
}

#title img{
    width: 40px;
    height: 40px;
	object-fit: contain;
}



#weather{
	background: linear-gradient(45deg, #6799FF, white);
}

.weatherimg {
    width: 200px;
    height: 200px;
    object-fit: contain;
    margin-left: 5px;
}

#weather {
  background: linear-gradient(45deg, #6799FF, white);
  padding: 10px;
  border-radius: 10px;
  margin-top: 20px;
}

.weather-row {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 10px;
}

.day-icon {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 14px;
  color: #222;
}

.weather-icon {
  width: 70px;
  height: 50px;
  margin-top: 2px;
}


</style>
<body>

<header>
<p>날씨에 따라 다른 발전량 알아보기</p>
</header>

<div style="display: flex;"> <!-- 문단이랑 지도 페이지 나란이 css -->
<!-- 문단표시 div -->

<!-- 이미지에 a href 넣어야됌 -->
<div id= "title">
	<div><img src="resources/img/weather.png" alt="현재 목록" style= "width: 50px; height: 50px;"></div>
	<div><img src="resources/img/power.png" alt="이전 목록" style= "width: 50px; height:  50px;"></div>
	<div><img src="resources/img/correlation.png" alt="상관관계 그래프 목록" style= "width: 50px; height:  50px;"></div>
</div>
<!-- 지도 표시 div -->
<div id="korea">
	<img src="resources/img/kroea.png" alt ="한국지도">
	<div>지역별 날씨에 따른 발전량 예측 지도</div>
	
</div>

<!--  주간 날찌 예보 div -->
<!-- 위에  -->
<div id="weather" class="weather-row">
  <div class="day-icon">
    <div>일</div>
    <img src="resources/img/sun.png" class="weather-icon">
  </div>
  <div class="day-icon">
    <div>월</div>
    <img src="resources/img/cloudy.png" class="weather-icon">
  </div>
  <div class="day-icon">
    <div>화</div>
    <img src="resources/img/windy.png" class="weather-icon">
  </div>
  <div class="day-icon">
    <div>수</div>
    <img src="resources/img/cloudy.png" class="weather-icon">
  </div>
  <div class="day-icon">
    <div>목</div>
    <img src="resources/img/cloudy.png" class="weather-icon">
  </div>
  <div class="day-icon">
    <div>금</div>
    <img src="resources/img/rainy.png" class="weather-icon">
  </div>
  <div class="day-icon">
    <div>토</div>
    <img src="resources/img/rainy.png" class="weather-icon">
  </div>
</div>

<!-- 아래 -->
<!-- 계절에 따라 다른 발전량 차트 div -->
<div>
	<div>계절에 따라 다른 발전량 차이 (봄,여름,가을, 겨울)</div>
</div>

<!-- 오늘의 날씨 div -->
<div>
	<div>오늘의 날씨</div>
</div>

<!-- 오늘의 강수량 div -->
<div>
	<div>오늘의 강수량</div>
</div>

</div>
<!-- 상관관계 그래프 div -->
<div>
	<div>기온- 발전량 상관관계 그래프</div>
</div>
<div>
	<div>풍속- 발전량 상관관계 그래프</div>
</div>
<div>
	<div>강수량- 발전량 상관관계 그래프</div>
</div>


</body>
</html>