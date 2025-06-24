<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>날씨와 상관관계 나타내는 그래프</title>
<style> 
* { box-sizing: border-box; }

body {
	margin: 0;
	padding: 0;
	background-color: #474747;
	font-family: 'Segoe UI', 'Malgun Gothic', sans-serif;
}

p { 
	color: white;
	margin: 10px 20px;
	font-size: 30px;
}

/* 전체 레이아웃 */
#container {
	display: flex;
	width: 100%;
	padding: 10px;
}

/* 메뉴 사이드바 */
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

/* 그래프 전체 영역 */
#a {
	background-color: #595959;
	height: 850px;
	border-radius: 10px;
	margin-left: 10px;
	flex: 1;
	display: flex;
	justify-content: center;
	align-items: center;
	gap: 10px;
	transition: all 0.5s ease;
	box-sizing: border-box;
	padding: 10px;
}

/* 개별 그래프 */
.graph {
	position: relative;
	flex: 1;
	height: 830px;
	background-color: #848484;
	border-radius: 10px;
	overflow: hidden;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	color: white;
	box-sizing: border-box;
	padding: 10px;
	text-align: center;
	transition: flex 0.5s ease;
}

/* 배경 이미지 */
.graph img.bgi {
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	object-fit: cover;
	border-radius: 10px;
	opacity: 0.3;
	transition: all 0.5s ease;
	z-index: 0;
}

/* 텍스트 내용 */
.graph a > div {
	position: relative;
	z-index: 1;
	font-size: 25px;
	font-weight: 600;
	padding: 0 10px;
	white-space: nowrap;
	text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
}

/* hover 효과 */
.graph:hover img.bgi {
	opacity: 1;
}
.graph.expanded {
	flex: 5 !important;
}


.graph.shrunk {
	flex: 0.5 !important;
}

a {
  color: inherit;
  text-decoration: none;
}
</style>
</head>
<body>

<p>날씨와 상관관계를 나타내는 그래프</p>

<div id="container">
	<!-- 좌측 메뉴바 -->
	<div id="title">
		<div><a href="weather"><img src="resources/img/weather.png" alt="현재 목록"></a></div>
		<div><img src="resources/img/power.png" alt="이전 목록"></div>
		<div><a href="correlation"><img src="resources/img/correlation.png" alt="상관관계 그래프 목록"></a></div>
	</div>

	<!-- 우측 그래프 영역 -->
	<div id="a">
		<div class="graph" id="g1">
		<a href="temperature">
			<img src="resources/img/temperature2.jpg" alt="기온" class="bgi">
			<div>기온 - 발전량 상관관계 그래프</div>
		</a>
		</div>

		<div class="graph" id="g2">
		<a href="windspeed">
			<img src="resources/img/windspeed.jpg" alt="풍속" class="bgi">
			<div>풍속 - 발전량 상관관계 그래프</div>
		</a>
		</div>
		
	</div>
</div>

<script>
// 그래프 확대/축소 효과
const graphs = document.querySelectorAll('.graph');
graphs.forEach(graph => {
	graph.addEventListener('mouseenter', () => {
		graph.classList.add('expanded');
		graphs.forEach(g => {
			if (g !== graph) g.classList.add('shrunk');
		});
	});
	graph.addEventListener('mouseleave', () => {
		graph.classList.remove('expanded');
		graphs.forEach(g => g.classList.remove('shrunk'));
	});
});
</script>

</body>
</html>
