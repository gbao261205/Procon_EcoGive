<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Company Dashboard - EcoGive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-100 min-h-screen font-sans text-slate-800">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 p-8">
    <header class="flex justify-between items-center mb-8">
        <div>
            <h1 class="text-2xl font-bold text-slate-800">Dashboard Doanh nghiệp</h1>
            <p class="text-sm text-slate-500">Chào mừng, ${sessionScope.currentUser.username}!</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/home" class="bg-emerald-600 text-white font-bold px-4 py-2 rounded-lg hover:bg-emerald-700 transition shadow-md flex items-center gap-2">
                <span>🗺️</span> Mở Bản Đồ để Thêm Điểm
            </a>
        </div>
    </header>

    <!-- Danh sách các điểm thu gom -->
    <div class="bg-white p-6 rounded-xl shadow-sm border border-slate-100">
        <h2 class="text-xl font-bold mb-4">Các Điểm Thu Gom Của Bạn (${totalPoints})</h2>
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-slate-200">
                <thead class="bg-slate-50">
                    <tr>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Tên Điểm</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Loại</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Địa chỉ</th>
                        <th scope="col" class="relative px-6 py-3">
                            <span class="sr-only">Hành động</span>
                        </th>
                    </tr>
                </thead>
                <tbody id="pointsTableBody" class="bg-white divide-y divide-slate-200">
                    <c:forEach var="point" items="${collectionPoints}">
                        <tr data-point-id="${point.pointId}">
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-slate-900">${point.name}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">${point.type}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-500">${point.address}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                <button onclick="deletePoint(${point.pointId})" class="text-rose-600 hover:text-rose-900">Xóa</button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty collectionPoints}">
                        <tr>
                            <td colspan="4" class="text-center py-8 text-slate-500">Bạn chưa có điểm thu gom nào.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script>
    function deletePoint(pointId) {
        if (!confirm('Bạn có chắc chắn muốn xóa điểm thu gom này không?')) {
            return;
        }

        const formData = new FormData();
        formData.append('pointId', pointId);

        fetch('${pageContext.request.contextPath}/company/collect-point/delete', {
            method: 'POST',
            body: new URLSearchParams(formData)
        })
        .then(response => response.json().then(data => ({ status: response.status, body: data })))
        .then(({ status, body }) => {
            alert(body.message);
            if (status === 200) { // OK
                document.querySelector(`tr[data-point-id='${pointId}']`).remove();
                setTimeout(() => window.location.reload(), 1000);
            }
        })
        .catch(error => {
            alert('Lỗi kết nối. Vui lòng thử lại.');
            console.error('Error:', error);
        });
    }
</script>

</body>
</html>
