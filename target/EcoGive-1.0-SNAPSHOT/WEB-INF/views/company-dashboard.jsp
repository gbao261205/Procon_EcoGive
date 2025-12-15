<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang quản lý Doanh nghiệp - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 font-sans">

<div class="flex min-h-screen">
    <!-- Sidebar -->
    <aside class="w-64 bg-white shadow-md flex-shrink-0">
        <div class="p-6 bg-emerald-600 text-white">
            <h2 class="text-xl font-bold">EcoGive</h2>
            <p class="text-sm opacity-80">Doanh nghiệp</p>
        </div>
        <nav class="mt-4">
            <a href="#" class="flex items-center px-6 py-3 text-emerald-700 bg-emerald-50 font-bold">
                <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                Điểm thu gom
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center px-6 py-3 text-slate-600 hover:bg-slate-50">
                <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H3"></path></svg>
                Đăng xuất
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 p-8">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold text-slate-800">Quản lý Điểm thu gom</h1>
            <a href="${pageContext.request.contextPath}/home" class="bg-emerald-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-emerald-700 transition shadow-md flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
                Thêm Điểm Mới (trên bản đồ)
            </a>
        </div>

        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <span class="block sm:inline">${sessionScope.errorMessage}</span>
                <% session.removeAttribute("errorMessage"); %>
            </div>
        </c:if>

        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="p-6">
                <h3 class="text-lg font-semibold text-slate-700">Danh sách điểm thu gom của bạn</h3>
            </div>
            <div class="overflow-x-auto">
                <table class="min-w-full text-sm">
                    <thead class="bg-slate-50">
                        <tr>
                            <th class="px-6 py-3 text-left font-medium text-slate-600 uppercase tracking-wider">Tên Điểm</th>
                            <th class="px-6 py-3 text-left font-medium text-slate-600 uppercase tracking-wider">Địa chỉ</th>
                            <th class="px-6 py-3 text-left font-medium text-slate-600 uppercase tracking-wider">Loại</th>
                            <th class="px-6 py-3 text-right font-medium text-slate-600 uppercase tracking-wider">Hành động</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200">
                        <c:choose>
                            <c:when test="${not empty collectionPoints}">
                                <c:forEach var="point" items="${collectionPoints}">
                                    <tr class="hover:bg-slate-50">
                                        <td class="px-6 py-4 whitespace-nowrap font-medium text-slate-800">${point.name}</td>
                                        <td class="px-6 py-4 whitespace-nowrap text-slate-600">${point.address}</td>
                                        <td class="px-6 py-4 whitespace-nowrap">
                                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                                ${point.type == 'BATTERY' ? 'bg-yellow-100 text-yellow-800' : 
                                                 point.type == 'E_WASTE' ? 'bg-blue-100 text-blue-800' : 
                                                 'bg-green-100 text-green-800'}">
                                                ${point.type.displayName}
                                            </span>
                                        </td>
                                        <td class="px-6 py-4 whitespace-nowrap text-right">
                                            <form action="${pageContext.request.contextPath}/dashboard/company" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn xóa điểm này?');" style="display:inline;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="pointId" value="${point.pointId}">
                                                <button type="submit" class="text-red-600 hover:text-red-900 font-medium">Xóa</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="px-6 py-10 text-center text-slate-500">
                                        Bạn chưa có điểm thu gom nào. Hãy thêm điểm mới!
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

</body>
</html>
