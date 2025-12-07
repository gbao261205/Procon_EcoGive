<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Vật phẩm - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Inter', sans-serif; } </style>
</head>
<body class="bg-slate-100 min-h-screen font-sans text-slate-800">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 p-8">
    <h1 class="text-2xl font-bold text-slate-800 mb-6">Quản lý Vật phẩm</h1>

    <div class="flex flex-wrap gap-2 mb-6">
        <a href="${pageContext.request.contextPath}/admin?action=items"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${empty param.status ? 'bg-slate-800 text-white border-slate-800' : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'}">
            Tất cả
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items&status=PENDING"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'PENDING' ? 'bg-amber-100 text-amber-800 border-amber-200' : 'bg-white text-slate-600 border-slate-200 hover:text-amber-600 hover:bg-amber-50'}">
            Chờ duyệt
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items&status=AVAILABLE"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'AVAILABLE' ? 'bg-emerald-100 text-emerald-800 border-emerald-200' : 'bg-white text-slate-600 border-slate-200 hover:text-emerald-600 hover:bg-emerald-50'}">
            Đang hiển thị
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items&status=CONFIRMED"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'CONFIRMED' ? 'bg-blue-100 text-blue-800 border-blue-200' : 'bg-white text-slate-600 border-slate-200 hover:text-blue-600 hover:bg-blue-50'}">
            Đã chốt tặng
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items&status=COMPLETED"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'COMPLETED' ? 'bg-purple-100 text-purple-800 border-purple-200' : 'bg-white text-slate-600 border-slate-200 hover:text-purple-600 hover:bg-purple-50'}">
            Hoàn thành
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items&status=CANCELLED"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'CANCELLED' ? 'bg-red-100 text-red-800 border-red-200' : 'bg-white text-slate-600 border-slate-200 hover:text-red-600 hover:bg-red-50'}">
            Đã hủy
        </a>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                <tr>
                    <th class="px-6 py-4 border-b border-slate-100">Vật phẩm</th>
                    <th class="px-6 py-4 border-b border-slate-100">Người đăng</th>
                    <th class="px-6 py-4 border-b border-slate-100">Danh mục</th>
                    <th class="px-6 py-4 border-b border-slate-100">Trạng thái</th>
                    <th class="px-6 py-4 border-b border-slate-100 text-right">Hành động</th>
                </tr>
                </thead>
                <tbody class="text-sm divide-y divide-slate-100">
                <c:forEach var="item" items="${items}">
                    <tr class="hover:bg-slate-50 transition-colors">
                        <td class="px-6 py-4">
                            <div class="flex items-center gap-3">
                                <div class="h-12 w-12 rounded-lg bg-slate-200 overflow-hidden flex-shrink-0 border border-slate-200">
                                    <c:url value="/images" var="imgSrc">
                                        <c:param name="path" value="${item.imageUrl}" />
                                    </c:url>
                                    <img src="${imgSrc}" alt="${item.title}" class="h-full w-full object-cover"
                                         onerror="this.src='https://placehold.co/100x100?text=No+Image'">
                                </div>
                                <div>
                                    <div class="font-medium text-slate-800">${item.title}</div>
                                    <div class="text-xs text-slate-500 truncate w-32" title="${item.description}">
                                            ${item.description}
                                    </div>
                                </div>
                            </div>
                        </td>

                        <td class="px-6 py-4 text-slate-500 font-mono text-xs">ID: ${item.giverId}</td>
                        <td class="px-6 py-4 text-slate-500 font-mono text-xs">Cat ID: ${item.categoryId}</td>

                        <td class="px-6 py-4">
                            <c:choose>
                                <c:when test="${item.status == 'PENDING'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-50 text-amber-700 border border-amber-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span> Chờ duyệt
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'AVAILABLE'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Đang hiển thị
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'CONFIRMED'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-700 border border-blue-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span> Đã chốt tặng
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'COMPLETED'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-purple-50 text-purple-700 border border-purple-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-purple-500"></span> Hoàn thành
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'CANCELLED'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-red-50 text-red-700 border border-red-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-red-500"></span> Đã hủy
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-600">${item.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class="px-6 py-4 text-right">
                            <c:if test="${item.status == 'PENDING'}">
                                <a href="${pageContext.request.contextPath}/admin?action=approve-item&id=${item.itemId}"
                                   class="text-emerald-600 hover:text-emerald-800 font-medium text-xs border border-emerald-200 bg-emerald-50 hover:bg-emerald-100 rounded px-3 py-1 mr-2 transition-colors">
                                    ✓ Duyệt
                                </a>
                                <a href="${pageContext.request.contextPath}/admin?action=reject-item&id=${item.itemId}"
                                   class="text-red-600 hover:text-red-800 font-medium text-xs border border-red-200 bg-red-50 hover:bg-red-100 rounded px-3 py-1 transition-colors"
                                   onclick="return confirm('Từ chối vật phẩm này?');">
                                    ✗ Hủy
                                </a>
                            </c:if>
                            <c:if test="${item.status != 'PENDING'}">
                                <span class="text-slate-400 text-xs italic">Đã xử lý</span>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty items}">
                    <tr>
                        <td colspan="5" class="px-6 py-12 text-center text-slate-400 italic">
                            <div class="flex flex-col items-center">
                                <span class="text-2xl mb-2">📭</span>
                                <span>Không có vật phẩm nào trong danh sách này.</span>
                            </div>
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>
</body>
</html>