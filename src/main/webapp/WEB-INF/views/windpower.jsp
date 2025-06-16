<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>풍력 발전 데이터</title>
</head>
<body>
<h2>풍력 발전 데이터 리스트</h2>

<c:if test="${empty windList}">
    <p>데이터가 없습니다.</p>
</c:if>

<table border="1" cellpadding="5" cellspacing="0">
    <thead>
    <tr>
        <th>일자</th>
        <th>발전소명</th>
        <th>1시 발전량</th>
        <th>2시 발전량</th>
        <th>3시 발전량</th>
        <th>총 발전량</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="item" items="${windList}">
        <tr>
            <td><c:out value="${item.dgenYmd}"/></td>
            <td><c:out value="${item.ipptNam}"/></td>
            <td><c:out value="${item.qhorGen01}"/></td>
            <td><c:out value="${item.qhorGen02}"/></td>
            <td><c:out value="${item.qhorGen03}"/></td>
            <td><c:out value="${item.qsum}"/></td>
        </tr>
    </c:forEach>
    </tbody>
</table>

</body>
</html>