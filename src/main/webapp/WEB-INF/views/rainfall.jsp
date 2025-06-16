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
	height: 570px;
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

#sun{
	background-color: #595959;
	width:100%;
	border-radius: 10px;
	padding: 10px 10px;
	margin-left: 10px;
}
p{
	color: white;
	margin: 5px 10px;
	font-size: 30px;
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
		<p>강수량과 발전량 그래프</p>
	
	<div>파이썬에서 받은 그래프 넣기</div>
	
	
	
	</div>
	

	
</body>
</html>