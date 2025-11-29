<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Vật phẩm - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 min-h-screen font-sans text-slate-800">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 p-8">
    <h1 class="text-2xl font-bold text-slate-800 mb-6">Quản lý Vật phẩm</h1>

    <div class="flex gap-4 mb-6">
        <button class="px-4 py-2 bg-white rounded-lg shadow-sm text-sm font-medium text-slate-600 hover:text-emerald-600">Tất cả</button>
        <button class="px-4 py-2 bg-white rounded-lg shadow-sm text-sm font-medium text-amber-600 border border-amber-100 bg-amber-50">Chờ duyệt</button>
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
                                <div class="h-12 w-12 rounded-lg bg-slate-200 overflow-hidden flex-shrink-0">
                                    <img src="${item.imageUrl}" alt="" class="h-full w-full object-cover">
                                </div>
                                <div>
                                    <div class="font-medium text-slate-800">${item.title}</div>
                                    <div class="text-xs text-slate-500 truncate w-32">${item.description}</div>
                                </div>
                            </div>
                        </td>

                        <td class="px-6 py-4 text-slate-500">ID: ${item.giverId}</td>
                        <td class="px-6 py-4 text-slate-500">
                            Cat ID: ${item.categoryId}
                        </td>

                        <td class="px-6 py-4">
                            <c:choose>
                                <c:when test="${item.status == 'PENDING'}">
                                            <span class="px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800">
                                                Chờ duyệt
                                            </span>
                                </c:when>
                                <c:when test="${item.status == 'AVAILABLE'}">
                                            <span class="px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
                                                Đang hiển thị
                                            </span>
                                </c:when>
                                <c:when test="${item.status == 'CANCELLED'}">
            <span class="px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                Đã hủy
            </span>
                                </c:when>
                                <c:otherwise>
                                            <span class="px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-600">
                                                    ${item.status}
                                            </span>
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
                        <td colspan="5" class="px-6 py-8 text-center text-slate-400 italic">
                            Chưa có vật phẩm nào trong hệ thống.
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