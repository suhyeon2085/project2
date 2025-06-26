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
        
        System.out.println("[1500]" + formattedDate + "," + item.getCategory() + "=" + item.getFcstValue());
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
String todayTMP = (todayData != null && todayData.get("TMP") != null) ? todayData.get("TMP") : "0";
String todayPCP = (todayData != null && todayData.get("PCP") != null) ? todayData.get("PCP") : "0";
String todayREH = (todayData != null && todayData.get("REH") != null) ? todayData.get("REH") : "0";
String todayVEC = (todayData != null && todayData.get("VEC") != null) ? todayData.get("VEC") : "0";

String windVec = dayWeather1500.getOrDefault(todayFormatted, new HashMap<>()).get("VEC");

System.out.println("tmp :" + todayTMP + "PCP :" + todayPCP + "REH :" + todayREH + "VEC :" +todayVEC);

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
	
	.region-label span {
	  font-weight: bold;
	  color: #003366;
	  font-size: 14px;
	  background-color: rgba(255, 255, 255, 0.7);
	  padding: 2px 6px;
	  border-radius: 5px;
	  border: 1px solid #ccc;
	  max-width: none; 
	}
</style>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.3/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.3/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        <div class="weather-row">
		  <c:forEach items="${dayWeather1500}" var="entry">
		    <div class="day-icon"
		         data-date="${entry.key}"
		         data-pop="${entry.value.POP}"
		         data-wsd="${entry.value.WSD}"
		         data-tmx="${entry.value.TMX}"
		         data-tmn="${dayWeather0600[entry.key].TMN}"
		         data-vec="${entry.value.TMP}"
		         data-vec="${entry.value.VEC}"
			     data-reh="${entry.value.REH}"
			     data-pcp="${entry.value.PCP}"
		         >
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
		      <div class="temp">${dayWeather0600[entry.key].TMN}°C / ${entry.value.TMX}°C</div>
		      <div class="rain">강수확률: ${entry.value.POP}%</div>
		      <div class="windspeed">풍속: ${entry.value.WSD} m/s</div>
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

    <!-- 예측 발전량 -->
    <div class="power-chart" id="predictPower">
	  <div style="font-weight:bold; font-size:16px;">예측 발전량</div>
  	  <canvas id="powerChart" style="width: 100%; height: 350px;"></canvas>
	</div>
  </div>
</div>


<script>
let selectedRegion = "인천";
let plantData = [];
let allResults = [];
let geojson;
let regionChart

function parsePCP(value) {
	  if (!value || value.includes("없음")) return 0;
	  const match = value.match(/[\d.]+/);
	  return match ? parseFloat(match[0]) : 0;
	}

const map = L.map('map').setView([36.0, 127.7], 7);
L.tileLayer('https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png', {
  attribution: '&copy; CARTO', subdomains: 'abcd', maxZoom: 18
}).addTo(map);

window.addEventListener('DOMContentLoaded', async () => {
  const sidoData = await fetch('resources/Data/SIDO_MAP_2022.json').then(r => r.json());
  geojson = L.geoJSON(sidoData, { style, onEachFeature }).addTo(map);

  plantData = await fetch('/resources/Data/plant_location.json').then(r => r.json());
  
  geojson.eachLayer(layer => {
	    if (layer.feature.properties.CTP_KOR_NM === "인천광역시") {
	      layer.fire('click'); // 클릭 이벤트 강제 실행
	    }
	  });
  //updateRegionView("인천");
});


function style(feature) {
  return { fillColor: '#f0f0f0', weight: 1, color: '#666', fillOpacity: 0.7 };
}

function highlightFeature(e) {
  e.target.setStyle({ weight: 2, color: '#000', fillColor: '#003366', fillOpacity: 0.9 });
}

function resetHighlight(e) {
  geojson.resetStyle(e.target);
}
	
	let selectedLayer = null;  // 마지막 선택된 지역의 레이어
	let selectedLabel = null;
	let labelMarker = null;    // 현재 마우스오버 라벨

	function onEachFeature(feature, layer) {
	  layer.on({
	    mouseover: function (e) {
	      highlightFeature(e);

	      const name = feature.properties.CTP_KOR_NM;
	      let position = layer.getBounds().getCenter();

	      if (name === "인천광역시") {
	        const bounds = layer.getBounds();
	        position = L.latLng(position.lat, bounds.getEast());
	      }

	      // 기존 hover 라벨 제거
	      if (labelMarker) {
	        map.removeLayer(labelMarker);
	      }

	      labelMarker = L.marker(position, {
	        icon: L.divIcon({
	          className: 'region-label',
	          html: "<span>" + name + "</span>",
	          iconSize: [160, 24],       // 너비 충분히 확보
	          iconAnchor: [80, 12]       // 가운데 정렬
	        }),
	        interactive: false
	      });

	      labelMarker.addTo(map);
	    },

	    mouseout: function (e) {
	      if (selectedLayer !== layer && labelMarker) {
	        map.removeLayer(labelMarker);
	        labelMarker = null;
	      }
	      if (selectedLayer !== layer) {
	        resetHighlight(e);
	      }
	    },

	    click: function () {
	      selectedRegion = feature.properties.CTP_KOR_NM;
	      updateRegionView(selectedRegion);

	      // 이전 선택된 레이어 초기화
	      if (selectedLayer && selectedLayer !== layer) {
	        geojson.resetStyle(selectedLayer);
	      }

	      // 이전 라벨 제거 (hover 또는 클릭이든)
	      if (labelMarker) {
	        map.removeLayer(labelMarker);
	        labelMarker = null;
	      }
	      if (selectedLabel) {
	        map.removeLayer(selectedLabel);
	        selectedLabel = null;
	      }

	      // 현재 선택 레이어 강조
	      highlightFeature({ target: layer });
	      selectedLayer = layer;

	      const name = feature.properties.CTP_KOR_NM;
	      let position = layer.getBounds().getCenter();
	      if (name === "인천광역시") {
	        const bounds = layer.getBounds();
	        position = L.latLng(position.lat, bounds.getEast());
	      }

	      selectedLabel = L.marker(position, {
	        icon: L.divIcon({
	          className: 'region-label',
	          html: "<span>" + name + "</span>",
	          iconSize: [100, 20],
	          iconAnchor: [50, 10]
	        }),
	        interactive: false
	      }).addTo(map);
	    }
	  });
	}


function convertLatLngToGrid(lat, lng) {
  const RE = 6371.00877, GRID = 5.0, SLAT1 = 30.0, SLAT2 = 60.0, OLNG = 126.0, OLAT = 38.0, XO = 43, YO = 136;
  const DEGRAD = Math.PI / 180.0;
  const re = RE / GRID;
  const slat1 = SLAT1 * DEGRAD;
  const slat2 = SLAT2 * DEGRAD;
  const olng = OLNG * DEGRAD;
  const olat = OLAT * DEGRAD;
  const sn = Math.log(Math.cos(slat1) / Math.cos(slat2)) /
             Math.log(Math.tan(Math.PI * 0.25 + slat2 * 0.5) / Math.tan(Math.PI * 0.25 + slat1 * 0.5));
  const sf = Math.pow(Math.tan(Math.PI * 0.25 + slat1 * 0.5), sn) * Math.cos(slat1) / sn;
  const ro = re * sf / Math.pow(Math.tan(Math.PI * 0.25 + olat * 0.5), sn);

  const ra = re * sf / Math.pow(Math.tan(Math.PI * 0.25 + lat * DEGRAD * 0.5), sn);
  let theta = lng * DEGRAD - olng;
  if (theta > Math.PI) theta -= 2.0 * Math.PI;
  if (theta < -Math.PI) theta += 2.0 * Math.PI;
  theta *= sn;

  return {
    nx: Math.floor(ra * Math.sin(theta) + XO + 0.5),
    ny: Math.floor(ro - ra * Math.cos(theta) + YO + 0.5)
  };
}

async function getWeather(lat, lng) {
	  const { nx, ny } = convertLatLngToGrid(lat, lng);
	  const today = new Date();
	  const baseDate = today.toISOString().slice(0, 10).replace(/-/g, '');  // 오늘 날짜로 고정
	  const baseTime = "0500";
	  const url = "/weather/data?nx=" + nx + "&ny=" + ny + "&baseDate=" + baseDate + "&baseTime=" + baseTime;
  console.log("날씨 요청 URL:", url);

  const res = await fetch(url);
  const text = await res.text();

  try {
    const json = JSON.parse(text);
    return json || [];
  } catch (e) {
    console.error("❌ 날씨 JSON 파싱 실패:", e);
    return [];
  }
}

async function updateRegionView(region) {
  const regionPlants = plantData.filter(p => p.ADD.includes(region));
  console.log("🔍 선택한 지역:", region);
  console.log("📍 해당 지역 발전소:", regionPlants);

  if (regionPlants.length === 0) {
    document.getElementById("predictPower").innerHTML =
      `<div style="font-size: 18px; font-weight: bold; color: red;">⚠️ \${region} 지역의 발전소 데이터를 찾을 수 없습니다.</div>`;
    return;
  }

  const dayIcons = document.querySelectorAll('.day-icon');
  const dateList = Array.from(dayIcons).map(icon => icon.dataset.date);
  let html = "";
  let chartData = []; 

  //1번만 API 호출
  const fullWeatherData = await getWeather(Number(regionPlants[0].lat), Number(regionPlants[0].lng), dateList[0]);

  for (const dateKey of dateList) {
    const cleanDate = dateKey.replace(/\//g, '');

    // 날짜별 값 추출
    const TMP = getValue(fullWeatherData, "TMP", cleanDate) || 20;
    const WSD = getValue(fullWeatherData, "WSD", cleanDate) || 3;
    const VEC = getValue(fullWeatherData, "VEC", cleanDate) || 180;
    const PCP_raw = getValue(fullWeatherData, "PCP", cleanDate) || "0";
    const PCP = parsePCP(PCP_raw);
    const REH = getValue(fullWeatherData, "REH", cleanDate) || 70;

    const queryParams = regionPlants.map(async plant => {
      const query = new URLSearchParams({
        TMP, WSD, VEC, PCP, REH,
        CAP: plant.CAP,
        plant: plant.PLANT,
        lat: plant.lat,
        lng: plant.lng
      }).toString();

      try {
        const resp = await fetch("http://localhost:8000/predict?" + query);
        return await resp.json();
      } catch (error) {
        console.error("❌ 예측 실패:", error);
        return { plant: plant.PLANT, predicted_power: 0 };
      }
    });

    const predictions = await Promise.all(queryParams);
    const total = predictions.reduce((sum, p) => sum + (p.predicted_power || 0), 0);

    html += `
      <div style="margin-bottom: 15px;">
        <div style="font-weight:bold; font-size:16px;">📅 \${region} (\${dateKey}) 총 예측 발전량: \${total.toFixed(2)} kW</div>
        <ul>
        \${predictions.map(p =>
          `<li>\${p.plant}: \${p.predicted_power != null ? p.predicted_power.toFixed(2) : "예측 실패"} kW</li>`
        ).join('')}
      </ul>
      </div>`;
      
 	// 👇 그래프용 데이터 저장
    chartData.push({
	    date: dateKey,
	    total: total.toFixed(2),
	    tooltip: `총 예측 발전량: \${total.toFixed(2)} kW`
	    //tooltip: `총 예측 발전량: \${total.toFixed(2)} kW\n` + 
	    	//predictions.map(p => `\${p.plant}: \${p.predicted_power.toFixed(2)} kW`).join('\n')
    });
  }
  const latestWeatherData = await getWeather(Number(regionPlants[0].lat), Number(regionPlants[0].lng), dateList[0]);
  updateWeatherPanel(latestWeatherData);
  updateDayIcons(latestWeatherData);

  document.getElementById("predictPower").innerHTML =
	  `<div style="font-weight:bold; font-size:16px; margin-bottom:30px;">📅 \${region} 예측 발전량</div>
	   <canvas id="powerChart" style="width:100%; height: 350px;"></canvas>`;


  drawPowerChart(chartData);

  
}

function drawPowerChart(data) {
	  const ctx = document.getElementById('powerChart').getContext('2d');
	  if (regionChart) regionChart.destroy();  // 기존 차트 제거

	  regionChart = new Chart(ctx, {
	    type: 'bar',
	    data: {
	      labels: data.map(d => d.date),
	      datasets: [{
	        label: '총 예측 발전량 (kW)',
	        data: data.map(d => d.total),
	        backgroundColor: '#003366',
	        borderRadius: 6
	      }]
	    },
	    options: {
	      responsive: true,
	      plugins: {
	        tooltip: {
	          callbacks: {
	            label: function(context) {
	              return data[context.dataIndex].tooltip.split('\n');
	            }
	          }
	        },
	        legend: {
	          display: false
	        }
	      },
	      scales: {
	          x: {
	            ticks: {
	              color: '#ffffff' // ✅ x축 눈금 색상 흰색
	            },
	            grid: {
	              color: '#ffffff',     // ✅ x축 그리드 선 색상
	              borderColor: '#ffffff' // ✅ x축 테두리 색상
	            }
	          },
	          y: {
	            title: {
	              display: true,
	              text: 'kW',
	              color: '#ffffff' // ✅ y축 제목 색상 흰색
	            },
	            ticks: {
	              color: '#ffffff' // ✅ y축 눈금 색상 흰색
	            },
	            grid: {
	              color: '#ffffff',     // ✅ y축 그리드 선 색상
	              borderColor: '#ffffff' // ✅ y축 테두리 색상
	            },
	            beginAtZero: true
	          }
	        }
	    }
	  });
	}


function updateWeatherPanel(weatherData) {
  const TMP = weatherData.find(w => w.category === "TMP")?.fcstValue;
  const VEC = weatherData.find(w => w.category === "VEC")?.fcstValue;
  const REH = weatherData.find(w => w.category === "REH")?.fcstValue;
  if (VEC !== undefined) document.querySelector("#winddirection .wind-left").innerText = VEC +"°";
  if (REH !== undefined) {
    document.getElementById("humidityValue").innerText = REH+"%";
    if (window.gauge) window.gauge.set(REH);
  }
}

function updateDayIcons(weatherData) {
	  document.querySelectorAll('.day-icon').forEach((el) => {
	    const date = el.dataset.date.replace(/\//g, '');

	    // 날씨값 추출
	    const TMP = getValue(weatherData, "TMP", date) || 20;
	    const WSD = getValue(weatherData, "WSD", date) || 3;
	    const REH = getValue(weatherData, "REH", date) || 60;
	    const PCP = getValue(weatherData, "PCP", date) || 0;
	    const POP = getValue(weatherData, "POP", date) || 0;
	    const TMX = getValue(weatherData, "TMX", date) || 28;
	    const TMN = getValue(weatherData, "TMN", date) || 20;
	    const VEC = getValue(weatherData, "VEC", date) || 180;

	    // data-* 속성도 업데이트 (필요 시 다른 스크립트에서 활용 가능)
	    el.dataset.tmp = TMP;
	    el.dataset.vec = VEC;
	    el.dataset.wsd = WSD;
	    el.dataset.reh = REH;
	    el.dataset.pcp = PCP;
	    el.dataset.pop = POP;
	    el.dataset.tmx = TMX;
	    el.dataset.tmn = TMN;

	    // 🌤 날씨 아이콘 교체
	    const iconEl = el.querySelector('img.weather-icon');
	    if (POP <= 33) {
	      iconEl.src = "resources/img/sun.png";
	    } else if (POP <= 66) {
	      iconEl.src = "resources/img/cloudy.png";
	    } else {
	      iconEl.src = "resources/img/rainy.png";
	    }

	    // 🌡️ 기온 텍스트 갱신 (class="temp")
	    const tempEl = el.querySelector('.temp');
	    if (tempEl) tempEl.innerText = TMN+"°C / "+TMX+"°C";

	    // 🌧️ 강수 텍스트 갱신 (class="rain")
	    const rainEl = el.querySelector('.rain');
	    if (rainEl) rainEl.innerText = "강수확률: "+POP+"%";

	    // 💨 풍속 텍스트 갱신 (class="windspeed")
	    const windEl = el.querySelector('.windspeed');
	    if (windEl) windEl.innerText = "풍속: "+WSD+" m/s";
	  });
	}


window.onload = function () {
  const opts = {
    angle: 0, lineWidth: 0.32, radiusScale: 1,
    pointer: { length: 0.6, strokeWidth: 0.03, color: '#f4f3f2' },
    limitMax: false, limitMin: false,
    colorStart: '#00aaff', colorStop: '#0042ff',
    strokeColor: '#d5f4ff', generateGradient: true,
    highDpiSupport: true,
  };
  const target = document.getElementById('humidityGauge');
  window.gauge = new Gauge(target).setOptions(opts);
  window.gauge.maxValue = 100;
  window.gauge.setMinValue(0);
  window.gauge.animationSpeed = 32;
  window.gauge.set(70);
};

function getValue(arr, cat, date) {
	  const baseDate = date.replace(/\//g, '');
	  const filtered = arr.filter(d => d.category === cat && d.fcstDate === baseDate);
	  const preferredTime = "1500";
	  const preferred = filtered.find(d => d.fcstTime === preferredTime);
	  return preferred?.fcstValue || filtered[0]?.fcstValue || null;
	}
</script>
</body>
</html>
