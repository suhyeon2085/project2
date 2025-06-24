<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page isELIgnored="false" language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, org.zerock.domain.WeatherData" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, org.zerock.domain.WeatherData" %>

<%
// "0600" 과  "1500"이 필요해서 따로 리스트로 저장후 사용
List<WeatherData> weatherList = (List<WeatherData>) request.getAttribute("weather");

Map<String, Map<String, String>> dayWeather1500 = new TreeMap<>();
Map<String, Map<String, String>> dayWeather0600 = new TreeMap<>();

SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMdd");
SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy/MM/dd");
  
  
System.out.println(new com.google.gson.Gson().toJson(weatherList));

for (WeatherData item : weatherList) {
    String rawDate = item.getFcstDate();
    Date parsedDate = inputFormat.parse(rawDate);
    String formattedDate = outputFormat.format(parsedDate);

    if ("1500".equals(item.getFcstTime())) {
        dayWeather1500.putIfAbsent(formattedDate, new HashMap<>());
        dayWeather1500.get(formattedDate).put(item.getCategory(), item.getFcstValue());
    } else if ("0600".equals(item.getFcstTime()) && "TMN".equals(item.getCategory())) {
        dayWeather0600.putIfAbsent(formattedDate, new HashMap<>());
        dayWeather0600.get(formattedDate).put(item.getCategory(), item.getFcstValue());
    }
}

// 오늘 날짜 데이터 세팅
String todayRaw = new SimpleDateFormat("yyyyMMdd").format(new Date());
Date todayParsed = inputFormat.parse(todayRaw);
String todayFormatted = outputFormat.format(todayParsed);

Map<String, String> todayData = dayWeather1500.get(todayFormatted);
String todayREH = (todayData != null && todayData.get("REH") != null) ? todayData.get("REH") : "0";

String windVec = dayWeather1500.getOrDefault(todayFormatted, new HashMap<>()).get("VEC");



// 풍향 계산 
String windDirectionStr = "풍향 없음";
String windDesc = "";
if (windVec != null) {
    int degree = Integer.parseInt(windVec);
    if (degree >= 0 && degree < 22.5 || degree >= 337.5) {
        windDirectionStr = "북풍";
        windDesc = "차갑고 건조하며, 때로는 맑은 날씨를 가져오지만, 한파를 유발할 수도 있습니다.";
    } else if (degree >= 22.5 && degree < 67.5) {
        windDirectionStr = "북동풍";
        windDesc = "북동풍은 여름철 날씨에 큰 영향을 미치지 않습니다.";
    } else if (degree >= 67.5 && degree < 112.5) {
        windDirectionStr = "동풍";
        windDesc = "폭염을 완화시키기도 하지만, 더운 공기가 더 더워져서 폭염을 심화시킬 수 있습니다.";
    } else if (degree >= 112.5 && degree < 157.5) {
        windDirectionStr = "남동풍";
        windDesc = "여름철에는 더위를 더욱 가중시키고, 비를 몰고 오는 경우가 있습니다.";
    } else if (degree >= 157.5 && degree < 202.5) {
        windDirectionStr = "남풍";
        windDesc = "따뜻하고 습한 기운이며, 저기압의 접근이나 태풍의 영향으로 비를 동반할 수 있습니다.";
    } else if (degree >= 202.5 && degree < 247.5) {
        windDirectionStr = "남서풍";
        windDesc = "무더위와 함께 집중 호우가 내리는 경우가 많습니다.";
    } else if (degree >= 247.5 && degree < 292.5) {
        windDirectionStr = "서풍";
        windDesc = "온대 저기압과 고기압을 동반하여 때로는 격렬한 뇌우를 일으킬 수 있습니다.";
    } else {
        windDirectionStr = "북서풍";
        windDesc = "차갑고 건조한 공기를 가져와 황사나 미세먼지를 동반할 수 있습니다.";
    }
}

request.setAttribute("dayWeather1500", dayWeather1500);
request.setAttribute("dayWeather0600", dayWeather0600);

request.setAttribute("today", todayFormatted);
request.setAttribute("todayREH", todayREH);
request.setAttribute("vecText", windDirectionStr);
request.setAttribute("windDesc", windDesc);
request.setAttribute("todayVEC", windVec);
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
	  margin: 10px 10px 0 10px;
	}
	
	label{
	margin: 10px 0px 0px 10px;
	padding: 0px;
	color: white;
	font-size: 15px;
	}
	
	.weather-row {
	  display: flex;
	  flex-direction: row;
	  gap: 20px;
	  flex-wrap: nowrap;
	  overflow: hidden;
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
	
	/* 습도 css*/
	#humidity {
	  text-align: center;
	  color: #222;
	  font-family: 'Malgun Gothic', 'Segoe UI', sans-serif;
	  border-radius: 10px;
	  /* wave 스타일 추가 */
	  width: 100%;
	  height: 100%;
	  background: linear-gradient(270deg, #00aaff, #004eff, #00aaff);
	  background-size: 600% 610%;
	  animation: waveMove 8s ease infinite;
	}
	
	@keyframes waveMove {
	  0% {background-position: 0% 50%;}
	  50% {background-position: 100% 50%;}
	  100% {background-position: 0% 50%;}
	}


	
	/*여기서부터는 풍향 css*/
	#winddirection {
	  background-color: #F4F3F2;
	  width: 100%;
	  height: 100%;
	  border-radius: 10px;
	  padding: 10px;
	  text-align: center;
	}
	
	.wind-title {
	  margin-top:5px;
	  font-size: 25px;
	  font-weight: bold;
	  margin-bottom: 27px;
	  color: #222;
	}
	
	.wind-row {
	  display: flex;
	  justify-content: center;
	  align-items: center;
	  gap: 30px;
	}
	
	.wind-left, .wind-right {
	  font-size: 45px;
	  font-weight: bold;
	  color: #333;
	  font-family: 'Malgun Gothic', 'Segoe UI', sans-serif;
	  margin-bottom: 7px;
	}

	.wind-desc {
	  font-size: 12px;
	  color: #818181;
	  margin-top: 8px;
	  border-left: 3px solid #ccc;
	  padding-left: 10px;
	}


	/* 검색 영역 스타일 */
	header {
	  position: relative;
	  width: 100%;
	}
	
	.header-container {
	  display: flex;
	  justify-content: space-between;
	  align-items: center;
	  position: relative;
	}
	
	.header-title {
	  color: white;
	  margin: 10px 20px;
	  font-size: 30px;
	}
	
	.search-box {
	  position: relative;
	  width: 220px;
	  margin-right: 15px;
	}
	
	.custom-input {
	  width: 100%;
	  padding: 10px 40px 10px 10px; /* 오른쪽에 아이콘 공간 확보 */
	  font-size: 16px;
	  background-color: #F4F3F2;
	  border: 1px solid #ccc;
	  border-radius: 4px;
	}
	
	.search-icon {
	  position: absolute;
	  top: 50%;
	  right: 10px;
	  transform: translateY(-50%);
	  cursor: pointer;
	  font-size: 20px;
	  color: #595959;
	  user-select: none;
	  transition: color 0.3s ease;
	}
	
	.search-icon:hover,
	.search-icon:focus {
	  color: #6799FF;
	  outline: none;
	}
	
	
	.suggestions-list {
	  list-style: none;
	  padding: 0;
	  margin: 0;
	  width: 100%;
	  max-height: 150px;
	  overflow-y: auto;
	  background: white;
	  position: absolute;
	  top: 100%;
	  left: 0;
	  z-index: 1000;
	  border: none;
	}
	
	.suggestions-list li {
	  padding: 10px;
	  cursor: pointer;
	  border-radius: 4px;
	}
	
	.suggestions-list li:hover {
	  background-color: #f0f0f0;
	}
	
	.search-icon i {
	  color: #595959;    
	  font-size: 20px;     
	  cursor: pointer;     
	  transition: color 0.3s ease, transform 0.3s ease;
	}
	
	.search-icon:hover i {
	  color: #6799FF;   
	  transform: scale(1.1);
	}
	

</style>
</head>

<body>
<!-- 계기판 게이지  -->
<script src="https://bernii.github.io/gauge.js/dist/gauge.min.js"></script>
<link
  href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
  rel="stylesheet"
/>

<header>
  <div class="header-container">
    <p class="header-title">날씨에 따라 다른 발전량 알아보기</p>

		<div class="search-box">
		  <input type="text" id="searchInput" class="custom-input" placeholder="검색어 입력" autocomplete="off" />
		  <span id="searchIcon" class="search-icon" role="button" tabindex="0" aria-label="검색">
  <i class="fas fa-search"></i>
</span>

		  <ul class="suggestions-list" id="suggestions"></ul>
		</div>

    
  </div>
</header>



<!-- 전체 레이아웃 -->
<div style="display: flex; width: 100%; padding: 10px;">
  <!-- 좌측: 메뉴 -->
  <div id="title">
    <div><a href="weather"><img src="resources/img/weather.png" alt="현재 목록"></a></div>
    <div><a href="windpower"><img src="resources/img/power.png" alt="이전 목록"></a></div>
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
        <label>당일 최저기온 ℃은 제공하지 않음</label>
        <div class="weather-row">
          <c:forEach items="${dayWeather1500}" var="entry">
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
           <div>
        <c:out value="${dayWeather0600[entry.key].TMN}" default="0" />°C /
        <c:out value="${entry.value.TMX}" default="N/A" />°C
      </div>
      <div>강수량: ${entry.value.POP}%</div>
      <div>풍속: ${entry.value.WSD} m/s</div>
    </div>
          </c:forEach>
        </div>
      </div>

      <!-- 바람 / 기압 -->
      <div class="right-info" style="flex: 1;">
        <div class="info-box">
        
	     <div id="winddirection">
		  <div class="wind-title">오늘의 풍향</div>
		  <div class="wind-row">
		    <div class="wind-left">${todayVEC}°</div>
		    <div class="wind-right">${vecText}</div>
		  </div>
		  	    <span class="wind-desc">${windDesc}</span>
		</div>
	
	
		
        </div>
			<div class="info-box">
			  <div id="humidity">
			  
			    <div style="font-size: 25px; font-weight: bold; padding-top: 17px;">오늘의 습도</div>
			    <canvas id="humidityGauge" width="200" height="100"></canvas>
			    <div id="humidityValue" style="margin-top:7px; font-size: 27px; font-weight: bold;">
			        ${todayREH}%
			    </div>
			  </div>
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

	//이건 지도 맵 
	  kakao.maps.load(function () {
	    var mapContainer = document.getElementById('map');
	    var mapOption = {
	      center: new kakao.maps.LatLng(36.5, 127.8),
	      level: 13
	    };
	    var map = new kakao.maps.Map(mapContainer, mapOption);
	  });
  

  
  // 네비게이션 바 
	function handleCityChange(city) {
	  if (city) {
	    // 선택된 도시로 이동하거나 필터링 동작 나중에 지역넣자
	    window.location.href = `/weather?city=${city}`;
	  }
	}
 
 
 // 습도 계기판 
 window.onload = function() {
	 var opts = {
			  angle: 0, 			//반원 기울기
			  lineWidth: 0.32,  	//반원 굴기
			  radiusScale: 1,		//반원 전체 크기
			  pointer: {
			    length: 0.6,		//바늘 길이
			    strokeWidth: 0.03,	// 바늘 굵기
			    color: '#f4f3f2'	//바늘 색깔
			  },
			  limitMax: false,
			  limitMin: false,
			  colorStart: '#00aaff', 	//그라데이션 시작 색
			  colorStop: '#0042ff', 	//그라데이션 끝 색
			  strokeColor: '#d5f4ff',	//반원 배경 색
			  generateGradient: true,	//그라데이션 사용 여부
			  highDpiSupport: true,
			};
	    
	    var target = document.getElementById('humidityGauge'); 
	    var gauge = new Gauge(target).setOptions(opts);
	    gauge.maxValue = 100;
	    gauge.setMinValue(0);
	    gauge.animationSpeed = 32;
	    
	    // JSP에서 넘어온 습도값을 JS 변수로 받아오기
	   var humidityValue = parseInt('${todayREH}');

	    
	    gauge.set(humidityValue);
	  };
	  
	  
	  // 검색칸 자동완성
	const locations = ["울산", "인천", "제주도", "대전", "전라남도"];
	const input = document.getElementById("searchInput");
	const suggestions = document.getElementById("suggestions");
	
	input.addEventListener("input", () => {
	  const value = input.value.trim().toLowerCase();
	  suggestions.innerHTML = "";
	
	  if (value) {
	    const filtered = locations.filter(location =>
	      location.toLowerCase().includes(value)
	    );
	
	    if (filtered.length > 0) {
	      suggestions.style.display = "block"; // 리스트 보이게
	      filtered.forEach(location => {
	        const li = document.createElement("li");
	        li.textContent = location;
	        li.addEventListener("click", () => {
	          input.value = location;
	          suggestions.innerHTML = "";
	          suggestions.style.display = "none"; // 선택시 숨기기
	        });
	        suggestions.appendChild(li);
	      });
	    } else {
	      suggestions.style.display = "none"; // 필터 없으면 숨기기
	    }
	  } else {
	    suggestions.style.display = "none"; // 입력 없으면 숨기기
	  }
	});
	
	document.addEventListener("click", (e) => {
	  if (!e.target.closest(".search-box")) {
	    suggestions.innerHTML = "";
	    suggestions.style.display = "none";
	  }
	});

</script>

</body>
</html>
