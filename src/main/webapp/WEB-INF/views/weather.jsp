<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="false" language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, org.zerock.domain.WeatherData" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, org.zerock.domain.WeatherData" %>

<%
    List<WeatherData> weatherList = (List<WeatherData>) request.getAttribute("weather");
    Map<String, Map<String, String>> groupedWeather = new TreeMap<>();

    SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMdd");
    SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy/MM/dd");

    for (WeatherData item : weatherList) {
        if (!"1500".equals(item.getFcstTime())) continue;

        String rawDate = item.getFcstDate(); // 예: "20250619"
        Date parsedDate = inputFormat.parse(rawDate);
        String formattedDate = outputFormat.format(parsedDate); // 예: "2025/06/19"

        groupedWeather.putIfAbsent(formattedDate, new HashMap<>());
        groupedWeather.get(formattedDate).put(item.getCategory(), item.getFcstValue());
    }

    // 오늘 날짜도 같은 형식으로 포맷팅
    String todayRaw = "20250619";
    Date todayParsed = inputFormat.parse(todayRaw);
    String todayFormatted = outputFormat.format(todayParsed);
    request.setAttribute("groupedWeather", groupedWeather);
    request.setAttribute("today", todayFormatted);
%>

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
	p { color: white; margin: 5px 10px; font-size: 40px; }
	
	#title {
	  display: flex;
	  flex-direction: column;
	  align-items: center;
	  background-color: #595959;
	  border-radius: 10px;
	  padding: 10px 0;
	  width: 70px;
	  flex-shrink: 0;
	  height: 850px;
	  gap: 7px;
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
	
	#korea {
	  background-color: #595959;
	  padding: 0;
	  text-align: center;
	  border-radius: 10px;
	  overflow: hidden;
	  flex-shrink: 0;
	  width: 410px;
	  height: 850px;
	  margin: 0 10px;
	}
	#map {
	  width: 100%;
	  height: 855px;
	  transform: translateY(-5px);
	  transition: all 0.3s ease;
	}
	
	#weather {
	  background: linear-gradient(45deg, #6799FF, white);
	  padding: 10px;
	  border-radius: 10px;
	  height: 100%;
	  display: flex;
	  flex-direction: column;
	  gap: 10px;
	  overflow: hidden;
	}
	
	.weather-title {
	  color: white;
	  font-size: 35px;
	  font-weight: bold;
	  margin: 10px 10px;
	}
	
	.weather-row {
	  display: flex;
	  flex-direction: row;
	  gap: 20px;
	  flex-wrap: nowrap;
	  overflow-x: auto;
	  padding: 10px;
	}
	
	.day-icon {
	  flex: auto;
	  width: 190px;
	  height: 300px;
	  background-color: rgba(255, 255, 255, 0.85);
	  border-radius: 8px;
	  padding: 15px;
	  display: flex;
	  flex-direction: column;
	  align-items: center;
	  font-size: 25px;
	  color: #222;
	}
	.day-icon:hover {
	  transform: translateY(-5px);
	  transition: all 0.3s ease;
	}
	
	.weather-icon {
	  width: 110px;
	  height: 70px;
	  margin-top: 20px;
	  margin-bottom: 20px;
	}
	.weather-icon:hover {
	  transform: translateY(-5px);
	  transition: all 0.3s ease;
	}
	
	.right-info {
	  display: flex;
	  flex-direction: column;
	  gap: 10px;
	  height: 100%;
	}
	.info-box {
	  background-color: #595959;
	  padding: 5px 5px;
	  border-radius: 10px;
	  color: white;
	  font-size: 14px;
	  flex: 1;
	}
	.power-chart {
	  background-color: #595959;
	  padding: 10px;
	  border-radius: 10px;
	  color: white;
	  font-size: 14px;
	  height: 500px;
	}
	
	/*여기서부터는 풍향 css*/
	#winddirection {
	  background-color: #F4F3F2;
	  width: 100%;
	  height: 100%;
	  border-radius: 10px;
	  padding: 5px;
	  position: relative; /* 🔥 기준 위치 지정 */
	}
	
	#com {
	  width: 200px;
	  height: 200px;
	  display: block;
	  margin: 0 auto;
	  position: relative; /* 배경 기준 유지 */
	  z-index: 1;
	}
	
	#arrow {
	  width: 200px;
	  height: 200px;
	  position: absolute;
	  top: 50%;
	  left: 50%;
	  transform: translate(-48%, -50%) rotate(0deg);
	  transform-origin: center center;
	  transition: transform 0.5s ease-in-out;
	  z-index: 2;
	  pointer-events: none;
	}

		
</style>
</head>

<body>
<header>
  <p>날씨에 따라 다른 발전량 알아보기</p>
</header>

<!-- 생략된 상단 JSP & 스타일은 그대로 유지하고, layout 부분만 수정합니다 -->

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
  </div>

  <!-- 우측 전체 내용 -->
  <div style="display: flex; flex-direction: column; flex: 1; height: 850px; gap: 10px;">
    
    <!-- 날씨 + 바람/기압 -->
    <div style="display: flex; flex: 1; gap: 10px;">
      <!-- 날씨 예보 -->
      <div id="weather" style="flex: 2;">
        <div class="weather-title">일간 날씨 예보</div>
        <div class="weather-row">
          <c:forEach items="${groupedWeather}" var="entry">
            <div class="day-icon">
              <div>${entry.key}</div>
              <c:choose>
				    <c:when test="${entry.value.POP <= 33}">
				      <img src="resources/img/sun.png" class="weather-icon" />
				    </c:when>
				    <c:when test="${entry.value.POP <= 66}">
				      <img src="resources/img/cloudy.png" class="weather-icon" />
				    </c:when>
				    <c:otherwise>
				      <img src="resources/img/rainy.png" class="weather-icon" />
				    </c:otherwise>
				  </c:choose>
              <div> -- / ${entry.value.TMX}°C </div>
              <div>강수확률: ${entry.value.POP}%</div>
              <div>풍속: ${entry.value.WSD} m/s</div>
            </div>
          </c:forEach>
        </div>
      </div>

      <!-- 바람 / 기압 -->
      <div class="right-info" style="flex: 1;">
        <div class="info-box">
        
          <div id="winddirection" style="position: relative;">
			  <div style="font-size: 25px; color: black; margin:5px;">
			    풍향: ${groupedWeather[today].VEC}°
			    <img src="resources/img/compass.png" id="com" />
			    <img src="resources/img/arrow.png" id="arrow" />
			  </div>
		  </div>

        </div>
        <div class="info-box">
          오늘의 기압 (저/고)
          <div><!-- 아직 데이터 안갖고옴 ㅋㅋ --></div>
        </div>
      </div>
    </div>

    <!-- 계절별 발전량 -->
    <div class="power-chart">
      <div style="font-weight:bold; font-size:16px;">계절에 따라 다른 발전량 차이</div>

    </div>
  </div>
</div>


<!-- 카카오 지도 스크립트 -->
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
  
  

  const windDirectionDeg = parseInt("${groupedWeather[today].VEC}", 10);
  const arrowImg = document.getElementById("arrow");
  arrowImg.style.transform = `translate(-50%, -50%) rotate(${windDirectionDeg}deg)`;

  
</script>
</body>
</html>
했는데 왜 안먹지? VEC 값은 category 안에 있어