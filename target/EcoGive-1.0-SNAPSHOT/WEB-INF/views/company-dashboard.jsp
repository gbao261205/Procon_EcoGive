<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="ecogive.Model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="ecogive.Model.CollectionPoint" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>

<html>
<head>
    <title>Dashboard - ${currentUser.username}</title>
    <style>
        body { font-family: sans-serif; margin: 2em; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .form-container { margin-top: 2em; padding: 1em; border: 1px solid #ccc; }
        .form-container div { margin-bottom: 1em; }
        .form-container label { display: block; margin-bottom: .5em; }
        .form-container input, .form-container select { width: 100%; padding: 8px; }
        .btn-delete { color: red; cursor: pointer; }
    </style>
</head>
<body>
    <h1>Dashboard Doanh nghiệp: ${currentUser.username}</h1>
    <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>

    <hr>

    <h2>Quản lý Điểm thu gom</h2>

    <!-- Form Thêm Điểm Thu Gom -->
    <div class="form-container">
        <h3>Thêm Điểm thu gom mới</h3>
        <form id="addPointForm">
            <div>
                <label for="name">Tên điểm:</label>
                <input type="text" id="name" name="name" required>
            </div>
            <div>
                <label for="address">Địa chỉ:</label>
                <input type="text" id="address" name="address" required>
            </div>
            <div>
                <label for="type">Loại:</label>
                <select id="type" name="type">
                    <c:forEach var="type" items="${ecogive.Model.CollectionPointType.values()}">
                        <option value="${type.name()}">${type.name()}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label for="latitude">Vĩ độ (Latitude):</label>
                <input type="number" step="any" id="latitude" name="latitude" required>
            </div>
            <div>
                <label for="longitude">Kinh độ (Longitude):</label>
                <input type="number" step="any" id="longitude" name="longitude" required>
            </div>
            <button type="submit">Thêm mới</button>
        </form>
        <p id="formMessage" style="margin-top: 1em;"></p>
    </div>

    <!-- Bảng Liệt Kê Điểm Thu Gom -->
    <h3>Danh sách Điểm thu gom của bạn</h3>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Tên</th>
                <th>Địa chỉ</th>
                <th>Loại</th>
                <th>Vĩ độ</th>
                <th>Kinh độ</th>
                <th>Hành động</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="point" items="${collectionPoints}">
                <tr id="point-${point.pointId}">
                    <td>${point.pointId}</td>
                    <td>${point.name}</td>
                    <td>${point.address}</td>
                    <td>${point.type}</td>
                    <td>${point.latitude}</td>
                    <td>${point.longitude}</td>
                    <td>
                        <button class="btn-delete" onclick="deletePoint(${point.pointId})">Xóa</button>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <script>
        // Add new point
        document.getElementById('addPointForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const form = e.target;
            const formData = new FormData(form);
            const messageEl = document.getElementById('formMessage');

            fetch('${pageContext.request.contextPath}/company/collect-point/add', { // <-- SỬA ENDPOINT
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => response.json())
            .then(data => {
                messageEl.textContent = data.message;
                if (data.status === 'success') {
                    messageEl.style.color = 'green';
                    form.reset();
                    // Reload page to see the new point
                    setTimeout(() => window.location.reload(), 1000);
                } else {
                    messageEl.style.color = 'red';
                }
            })
            .catch(err => {
                messageEl.textContent = 'Lỗi kết nối. Vui lòng thử lại.';
                messageEl.style.color = 'red';
            });
        });

        // Delete a point
        function deletePoint(pointId) {
            if (!confirm('Bạn có chắc chắn muốn xóa điểm thu gom này không?')) {
                return;
            }

            fetch('${pageContext.request.contextPath}/api/delete-collection-point', { // <-- GIỮ NGUYÊN ENDPOINT XÓA
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'pointId=' + pointId
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    alert(data.message);
                    const row = document.getElementById('point-' + pointId);
                    if (row) {
                        row.remove();
                    }
                } else {
                    alert('Lỗi: ' + data.message);
                }
            })
            .catch(err => {
                alert('Lỗi kết nối. Vui lòng thử lại.');
            });
        }
    </script>
</body>
</html>
