<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chủ - EcoGive</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
        .container { max-width: 800px; margin: auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .user-info { margin-bottom: 20px; }
        .logout-btn {
            display: inline-block;
            padding: 10px 15px;
            background-color: #d9534f;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Chào mừng đến với EcoGive!</h1>

        <c:if test="${sessionScope.currentUser != null}">
            <div class="user-info">
                <p>Xin chào, <strong><c:out value="${sessionScope.currentUser.username}"/></strong>!</p>
                <p>Email: <c:out value="${sessionScope.currentUser.email}"/></p>
                <p>Điểm Eco: <c:out value="${sessionScope.currentUser.ecoPoints}"/></p>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Đăng xuất</a>
        </c:if>

        <c:if test="${sessionScope.currentUser == null}">
            <p>Vui lòng <a href="${pageContext.request.contextPath}/login">đăng nhập</a> để tiếp tục.</p>
        </c:if>
    </div>
</body>
</html>
