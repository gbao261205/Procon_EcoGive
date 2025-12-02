<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Danh mục - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 min-h-screen font-sans text-slate-800">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 p-8">
    <h1 class="text-2xl font-bold text-slate-800 mb-6">Quản lý Danh mục</h1>

    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 mb-8">
        <h3 class="text-lg font-semibold text-emerald-700 mb-4 flex items-center gap-2">
            <span>✨</span> Thêm danh mục mới
        </h3>

        <form action="${pageContext.request.contextPath}/admin" method="POST" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
            <input type="hidden" name="action" value="add-category">

            <div class="md:col-span-6">
                <label class="block text-sm font-medium text-slate-700 mb-1">Tên danh mục</label>
                <input type="text" name="name" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-slate-400"
                       placeholder="VD: Đồ điện tử cũ">
            </div>

            <div class="md:col-span-4">
                <label class="block text-sm font-medium text-slate-700 mb-1">Điểm cố định (Points)</label>
                <input type="number" step="0.5" name="fixed_points" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-slate-400"
                       placeholder="VD: 5.0">
            </div>

            <div class="md:col-span-2">
                <button type="submit" class="w-full inline-flex items-center justify-center rounded-lg bg-emerald-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition-all">
                    + Thêm mới
                </button>
            </div>
        </form>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                <tr>
                    <th class="px-6 py-4 border-b border-slate-100">ID</th>
                    <th class="px-6 py-4 border-b border-slate-100">Tên danh mục</th>
                    <th class="px-6 py-4 border-b border-slate-100">Điểm thưởng</th>
                    <th class="px-6 py-4 border-b border-slate-100 text-right">Hành động</th>
                </tr>
                </thead>
                <tbody class="text-sm divide-y divide-slate-100">
                <c:forEach var="cat" items="${categories}">
                    <tr class="hover:bg-slate-50 transition-colors">
                        <td class="px-6 py-4 text-slate-500">#${cat.categoryId}</td>
                        <td class="px-6 py-4 font-medium text-slate-800">${cat.name}</td>
                        <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
                                        +${cat.fixedPoints} pts
                                    </span>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <a href="${pageContext.request.contextPath}/admin?action=delete-category&id=${cat.categoryId}"
                               class="text-slate-400 hover:text-red-600 font-medium transition-colors text-xs border border-slate-200 hover:border-red-200 rounded px-2 py-1"
                               onclick="return confirm('Xóa danh mục này?');">
                                Xóa
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty categories}">
                    <tr>
                        <td colspan="4" class="px-6 py-8 text-center text-slate-400 italic">
                            Chưa có dữ liệu danh mục.
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