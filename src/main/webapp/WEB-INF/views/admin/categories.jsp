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
<body class="bg-gray-100 flex h-screen overflow-hidden">

<jsp:include page="sidebar.jsp" />

<div class="flex-1 md:ml-64 p-8 rounded-2xl overflow-y-auto h-full">
    <h1 class="text-2xl font-bold text-gray-800 mb-6">Quản lý Danh mục</h1>

    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 mb-8">
        <h3 id="form-title" class="text-lg font-semibold text-emerald-700 mb-4 flex items-center gap-2">
            <span>🗂️</span> Thêm danh mục mới
        </h3>

        <form id="category-form" action="${pageContext.request.contextPath}/admin" method="POST" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
            <input type="hidden" id="form-action" name="action" value="add-category">
            <input type="hidden" id="category-id" name="id" value="">

            <div class="md:col-span-6">
                <label class="block text-xs font-bold text-slate-700 mb-1">Tên danh mục</label>
                <input type="text" id="catName" name="name" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-slate-400"
                       placeholder="VD: Đồ điện tử cũ">
            </div>

            <div class="md:col-span-4">
                <label class="block text-xs font-bold text-slate-700 mb-1">Điểm cố định (Points)</label>
                <input type="number" step="0.5" id="catPoints" name="fixed_points" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-slate-400"
                       placeholder="VD: 5.0">
            </div>

            <div class="md:col-span-12 flex justify-end gap-2 mt-2">
                <button id="cancel-button" type="button" onclick="cancelEdit()" class="hidden bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm font-bold hover:bg-gray-300 transition">
                    Hủy
                </button>
                <button id="submit-button" type="submit" class="bg-emerald-600 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-emerald-700 shadow-sm transition">
                    Thêm mới
                </button>
            </div>
        </form>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
        <div class="p-6 border-b border-slate-100 flex justify-between items-center">
            <h2 class="font-bold text-slate-700">Danh sách Danh mục</h2>
            <span class="text-xs font-semibold text-slate-500 bg-slate-100 px-3 py-1 rounded-full">Tổng: ${categories.size()}</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="bg-slate-50 text-slate-600 text-xs uppercase tracking-wider font-semibold">
                <tr>
                    <th class="px-6 py-4 border-b">ID</th>
                    <th class="px-6 py-4 border-b">Tên danh mục</th>
                    <th class="px-6 py-4 border-b">Điểm thưởng</th>
                    <th class="px-6 py-4 border-b text-right">Hành động</th>
                </tr>
                </thead>
                <tbody class="text-sm divide-y divide-slate-100 text-slate-700">
                <c:forEach var="cat" items="${categories}">
                    <tr class="hover:bg-slate-50 transition-colors">
                        <td class="px-6 py-4 text-slate-500 font-mono">#${cat.categoryId}</td>
                        <td class="px-6 py-4 font-medium text-slate-800">${cat.name}</td>
                        <td class="px-6 py-4">
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-100">
                                +${cat.fixedPoints} pts
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <div class="flex justify-end gap-2">
                                <button onclick="editCategory(${cat.categoryId}, '${cat.name}', ${cat.fixedPoints})"
                                        class="text-blue-600 bg-blue-50 hover:bg-blue-100 px-3 py-1 rounded border border-blue-200 font-medium text-xs transition">
                                    Sửa
                                </button>

                                <a href="${pageContext.request.contextPath}/admin?action=delete-category&id=${cat.categoryId}"
                                   class="text-red-600 bg-red-50 hover:bg-red-100 px-3 py-1 rounded border border-red-200 font-medium text-xs transition inline-block"
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa danh mục này không?');">
                                    Xóa
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty categories}">
                    <tr>
                        <td colspan="4" class="px-6 py-12 text-center text-slate-400 italic">
                            <div class="flex flex-col items-center">
                                <span class="text-2xl mb-2">🗂️</span>
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

<script>
    function editCategory(id, name, points) {
        // 1. Đổi action của form (nếu backend hỗ trợ update-category)
        // Nếu chưa hỗ trợ, bạn cần thêm case 'update-category' vào AdminServlet
        document.getElementById('form-action').value = 'update-category';
        document.getElementById('category-id').value = id;

        // 2. Điền dữ liệu vào ô input
        document.getElementById('catName').value = name;
        document.getElementById('catPoints').value = points;

        // 3. Cập nhật giao diện Form
        document.getElementById('form-title').innerHTML = '<span class="text-blue-600">✏️</span> Chỉnh sửa danh mục: ' + name;
        const btn = document.getElementById('submit-button');
        btn.innerText = 'Cập nhật';
        btn.classList.replace('bg-emerald-600', 'bg-blue-600');
        btn.classList.replace('hover:bg-emerald-700', 'hover:bg-blue-700');

        // 4. Hiện nút Hủy
        document.getElementById('cancel-button').classList.remove('hidden');

        // 5. Cuộn lên đầu
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function cancelEdit() {
        // Reset về chế độ Thêm mới
        document.getElementById('form-action').value = 'add-category';
        document.getElementById('category-id').value = '';
        document.getElementById('category-form').reset();

        // Reset giao diện Form
        document.getElementById('form-title').innerHTML = '<span>🗂️</span> Thêm danh mục mới';
        const btn = document.getElementById('submit-button');
        btn.innerText = 'Thêm mới';
        btn.classList.replace('bg-blue-600', 'bg-emerald-600');
        btn.classList.replace('hover:bg-blue-700', 'hover:bg-emerald-700');

        // Ẩn nút Hủy
        document.getElementById('cancel-button').classList.add('hidden');
    }
</script>

</body>
</html>