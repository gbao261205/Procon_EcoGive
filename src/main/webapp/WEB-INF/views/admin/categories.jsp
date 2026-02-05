<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Danh mục - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Inter', sans-serif; } </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 min-h-screen transition-all duration-300 flex flex-col">
    <header class="bg-white border-b border-slate-200 sticky top-0 z-10 px-8 py-4 flex justify-between items-center shadow-sm">
        <div>
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight">Danh mục</h1>
            <p class="text-sm text-slate-500 mt-1">Phân loại vật phẩm và thiết lập điểm thưởng.</p>
        </div>
    </header>

    <div class="p-8 max-w-6xl mx-auto w-full grid grid-cols-1 lg:grid-cols-3 gap-8">

        <!-- Left Column: Form -->
        <div class="lg:col-span-1">
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 sticky top-24">
                <h3 id="form-title" class="text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm">✨</span>
                    Thêm danh mục
                </h3>

                <form id="category-form" action="${pageContext.request.contextPath}/admin" method="POST" class="space-y-4">
                    <input type="hidden" id="form-action" name="action" value="add-category">
                    <input type="hidden" id="category-id" name="id" value="">

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Tên danh mục <span class="text-red-500">*</span></label>
                        <input type="text" id="catName" name="name" required
                               class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                               placeholder="VD: Đồ điện tử">
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Điểm thưởng cố định <span class="text-red-500">*</span></label>
                        <div class="relative">
                            <input type="number" step="0.5" id="catPoints" name="fixed_points" required
                                   class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400 pl-10"
                                   placeholder="5.0">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <span class="text-emerald-500 font-bold">+</span>
                            </div>
                        </div>
                        <p class="text-[10px] text-slate-400 mt-1">Điểm này sẽ được cộng cho người dùng khi quyên góp thành công.</p>
                    </div>

                    <div class="pt-2 flex gap-2">
                        <button id="cancel-button" type="button" onclick="cancelEdit()" class="hidden flex-1 px-4 py-2.5 rounded-xl text-sm font-semibold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">
                            Hủy
                        </button>
                        <button id="submit-button" type="submit" class="flex-1 px-4 py-2.5 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 shadow-lg shadow-emerald-200 transition-all active:scale-95">
                            Thêm mới
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Right Column: List -->
        <div class="lg:col-span-2">
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
                    <h2 class="font-bold text-slate-700">Danh sách hiện có</h2>
                    <span class="text-xs font-bold text-slate-500 bg-white border border-slate-200 px-2.5 py-1 rounded-lg shadow-sm">${categories.size()} danh mục</span>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                        <tr>
                            <th class="px-6 py-4 border-b border-slate-100">ID</th>
                            <th class="px-6 py-4 border-b border-slate-100">Tên danh mục</th>
                            <th class="px-6 py-4 border-b border-slate-100">Điểm thưởng</th>
                            <th class="px-6 py-4 border-b border-slate-100 text-right">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-sm">
                        <c:forEach var="cat" items="${categories}">
                            <tr class="group hover:bg-slate-50 transition-colors">
                                <td class="px-6 py-4 text-slate-400 font-mono text-xs">#${cat.categoryId}</td>
                                <td class="px-6 py-4 font-semibold text-slate-800">${cat.name}</td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-100">
                                        +${cat.fixedPoints}
                                        <span class="text-[10px] opacity-70">pts</span>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button onclick="editCategory(${cat.categoryId}, '${cat.name}', ${cat.fixedPoints})"
                                                class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="Sửa">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                        </button>

                                        <a href="${pageContext.request.contextPath}/admin?action=delete-category&id=${cat.categoryId}"
                                           class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Xóa"
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa danh mục này không?');">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty categories}">
                            <tr>
                                <td colspan="4" class="px-6 py-12 text-center text-slate-400 italic">
                                    <div class="flex flex-col items-center">
                                        <span class="text-2xl mb-2 opacity-50">🗂️</span>
                                        <span>Chưa có danh mục nào.</span>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    function editCategory(id, name, points) {
        document.getElementById('form-action').value = 'update-category';
        document.getElementById('category-id').value = id;
        document.getElementById('catName').value = name;
        document.getElementById('catPoints').value = points;

        // UI Updates
        document.getElementById('form-title').innerHTML = '<span class="w-8 h-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center text-sm">✏️</span> Cập nhật danh mục';
        const btn = document.getElementById('submit-button');
        btn.innerText = 'Lưu thay đổi';
        btn.classList.remove('bg-emerald-600', 'hover:bg-emerald-700', 'shadow-emerald-200');
        btn.classList.add('bg-blue-600', 'hover:bg-blue-700', 'shadow-blue-200');

        document.getElementById('cancel-button').classList.remove('hidden');
        document.getElementById('catName').focus();
    }

    function cancelEdit() {
        document.getElementById('form-action').value = 'add-category';
        document.getElementById('category-id').value = '';
        document.getElementById('category-form').reset();

        // UI Reset
        document.getElementById('form-title').innerHTML = '<span class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm">✨</span> Thêm danh mục';
        const btn = document.getElementById('submit-button');
        btn.innerText = 'Thêm mới';
        btn.classList.add('bg-emerald-600', 'hover:bg-emerald-700', 'shadow-emerald-200');
        btn.classList.remove('bg-blue-600', 'hover:bg-blue-700', 'shadow-blue-200');

        document.getElementById('cancel-button').classList.add('hidden');
    }
</script>

</body>
</html>