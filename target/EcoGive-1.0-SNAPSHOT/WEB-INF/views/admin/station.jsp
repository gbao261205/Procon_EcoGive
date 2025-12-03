<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Điểm tập kết - EcoGive Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-50 flex h-screen overflow-hidden">

<jsp:include page="sidebar.jsp" />

<div class="flex-1 flex flex-col md:ml-64 transition-all duration-300 h-full">
    <header class="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-8 shrink-0 z-10">
        <h1 class="text-xl font-bold text-slate-800">Quản lý Điểm tập kết</h1>
        <div class="flex items-center gap-4">
            <span class="text-sm font-medium text-slate-600">Admin: <span class="text-emerald-600">${sessionScope.currentUser.username}</span></span>
            <a href="${pageContext.request.contextPath}/" class="text-sm text-emerald-600 hover:text-emerald-700 font-medium hover:underline">Về trang chủ ↗</a>
        </div>
    </header>

    <main class="flex-1 overflow-y-auto p-8">
        <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="p-6 border-b border-slate-100 flex justify-between items-center">
                <h2 class="font-bold text-slate-700 text-lg">Danh sách trạm thu gom</h2>
                <span class="text-xs font-semibold text-slate-500 bg-slate-100 px-3 py-1 rounded-full border border-slate-200">
                        Tổng: ${stations.size()} trạm
                    </span>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                    <tr class="bg-slate-50 text-slate-600 text-xs uppercase tracking-wider border-b border-slate-200">
                        <th class="p-4 font-semibold w-20">ID</th>
                        <th class="p-4 font-semibold">Tên trạm</th>
                        <th class="p-4 font-semibold">Loại hình</th>
                        <th class="p-4 font-semibold">Địa chỉ</th>
                        <th class="p-4 font-semibold text-right">Hành động</th>
                    </tr>
                    </thead>
                    <tbody class="text-sm divide-y divide-slate-100">
                    <c:forEach var="st" items="${stations}">
                        <tr class="hover:bg-slate-50 transition-colors group">
                            <td class="p-4 text-slate-500 font-mono">#${st.pointId}</td>

                            <td class="p-4 font-medium text-slate-800">
                                    ${st.name}
                            </td>

                            <td class="p-4">
                                <c:choose>
                                    <c:when test="${st.type == 'BATTERY'}">
                                                <span class="inline-flex items-center gap-1 bg-yellow-100 text-yellow-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-yellow-200">
                                                    🔋 Pin
                                                </span>
                                    </c:when>
                                    <c:when test="${st.type == 'E_WASTE'}">
                                                <span class="inline-flex items-center gap-1 bg-blue-100 text-blue-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-blue-200">
                                                    💻 Điện tử
                                                </span>
                                    </c:when>
                                    <c:when test="${st.type == 'TEXTILE'}">
                                                <span class="inline-flex items-center gap-1 bg-purple-100 text-purple-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-purple-200">
                                                    👕 Quần áo
                                                </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="bg-gray-100 text-gray-800 px-2.5 py-0.5 rounded-full text-xs font-bold">Khác</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <td class="p-4 text-slate-600 max-w-xs truncate" title="${st.address}">
                                    ${st.address}
                            </td>

                            <td class="p-4 text-right">
                                <form action="${pageContext.request.contextPath}/admin" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn xóa trạm này không? Hành động này không thể hoàn tác.');" class="inline-block">
                                    <input type="hidden" name="action" value="delete-station">
                                    <input type="hidden" name="id" value="${st.pointId}">
                                    <button type="submit" class="text-red-500 hover:text-red-700 bg-white border border-red-200 hover:bg-red-50 px-3 py-1.5 rounded-lg text-xs font-bold transition shadow-sm">
                                        Xóa
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty stations}">
                        <tr>
                            <td colspan="5" class="p-12 text-center">
                                <div class="flex flex-col items-center justify-center text-slate-400">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mb-3 opacity-50" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
                                    <p class="text-sm font-medium">Chưa có điểm tập kết nào.</p>
                                    <p class="text-xs mt-1">Hãy thêm điểm mới từ trang chủ.</p>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>
</body>
</html>