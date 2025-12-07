<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Người dùng</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Inter', sans-serif; } </style>
</head>
<body class="bg-gray-100 flex h-screen overflow-hidden">

<jsp:include page="sidebar.jsp" />

<div class="flex-1 md:ml-64 p-8 rounded-2xl overflow-y-auto h-full">
    <h1 class="text-2xl font-bold text-gray-800 mb-6">Quản lý Người dùng</h1>

    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 mb-8">
        <h3 id="form-title" class="text-lg font-semibold text-emerald-700 mb-4 flex items-center gap-2">
            <span>👤</span> Thêm người dùng mới
        </h3>

        <form id="user-form" action="${pageContext.request.contextPath}/admin/users" method="POST" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
            <input type="hidden" id="form-action" name="action" value="add-user">
            <input type="hidden" id="user-id" name="user_id" value="">

            <div class="md:col-span-3">
                <label class="block text-xs font-bold text-slate-700 mb-1">Tên đăng nhập</label>
                <input type="text" id="username" name="username" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:ring-emerald-500">
            </div>

            <div class="md:col-span-3">
                <label class="block text-xs font-bold text-slate-700 mb-1">Email</label>
                <input type="email" id="email" name="email" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:ring-emerald-500">
            </div>

            <div class="md:col-span-3">
                <label class="block text-xs font-bold text-slate-700 mb-1">Mật khẩu</label>
                <input type="password" id="password" name="password" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:ring-emerald-500"
                       placeholder="Nhập mật khẩu...">
            </div>

            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-slate-700 mb-1">Vai trò</label>
                <select id="role" name="role" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm bg-white">
                    <option value="USER">USER</option>
                    <option value="ADMIN">ADMIN</option>
                </select>
            </div>

            <div class="md:col-span-12 grid grid-cols-2 gap-4 mt-2 p-3 bg-slate-50 rounded-lg border border-slate-200">
                <div>
                    <label class="block text-xs font-bold text-slate-500 mb-1">Điểm Eco</label>
                    <input type="text" id="ecoPoints" value="0.00" readonly
                           class="w-full bg-gray-100 text-slate-500 border-none rounded text-sm font-bold px-2 py-1 cursor-not-allowed">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-500 mb-1">Điểm Uy Tín</label>
                    <input type="text" id="reputationScore" value="5.00" readonly
                           class="w-full bg-gray-100 text-slate-500 border-none rounded text-sm font-bold px-2 py-1 cursor-not-allowed">
                </div>
            </div>

            <div class="md:col-span-12 flex justify-end gap-2 mt-4">
                <button id="cancel-button" type="button" onclick="cancelEdit()" class="hidden bg-gray-200 text-gray-700 px-4 py-2 rounded-lg text-sm font-bold hover:bg-gray-300 transition">
                    Hủy
                </button>
                <button id="submit-button" type="submit" class="bg-emerald-600 text-white px-6 py-2 rounded-lg text-sm font-bold hover:bg-blue-700 shadow-sm transition">
                    Thêm người dùng
                </button>
            </div>
        </form>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
        <div class="p-6 border-b border-slate-100 flex justify-between items-center">
            <h2 class="font-bold text-slate-700">Danh sách Người dùng</h2>
            <span class="text-xs font-semibold text-slate-500 bg-slate-100 px-3 py-1 rounded-full">Tổng: ${users.size()}</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="bg-slate-50 text-slate-600 text-xs uppercase tracking-wider font-semibold">
                <tr>
                    <th class="px-6 py-4 border-b">ID</th>
                    <th class="px-6 py-4 border-b">Username</th>
                    <th class="px-6 py-4 border-b">Email</th>
                    <th class="px-6 py-4 border-b">Điểm Eco</th>
                    <th class="px-6 py-4 border-b">Uy tín</th>
                    <th class="px-6 py-4 border-b">Ngày tham gia</th>
                    <th class="px-6 py-4 border-b">Vai trò</th>
                    <th class="px-6 py-4 border-b text-right">Hành động</th>
                </tr>
                </thead>
                <tbody class="text-sm divide-y divide-slate-100 text-slate-700">
                <c:forEach var="u" items="${users}">
                    <tr class="hover:bg-slate-50 transition-colors">
                        <td class="px-6 py-4 text-slate-500 font-mono">#${u.userId}</td>
                        <td class="px-6 py-4 font-medium text-slate-800">${u.username}</td>
                        <td class="px-6 py-4 text-slate-500">${u.email}</td>
                        <td class="px-6 py-4 font-bold text-emerald-600">${u.ecoPoints}</td>
                        <td class="px-6 py-4">
                            <span class="bg-blue-50 text-blue-700 text-xs font-bold px-2 py-1 rounded border border-blue-100">
                                ⭐ ${u.reputationScore}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-xs text-slate-500">${u.joinDate}</td>
                        <td class="px-6 py-4">
                            <span class="${u.role == 'ADMIN' ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'} text-xs font-bold px-2.5 py-0.5 rounded-full">
                                    ${u.role}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <div class="flex justify-end gap-2">
                                <button onclick="editUser(${u.userId}, '${u.username}', '${u.email}', '${u.role}', ${u.ecoPoints}, ${u.reputationScore})"
                                        class="text-blue-600 bg-blue-50 hover:bg-blue-100 px-3 py-1 rounded border border-blue-200 font-medium text-xs transition">
                                    Sửa
                                </button>

                                <a href="${pageContext.request.contextPath}/admin?action=delete-user&id=${u.userId}"
                                   onclick="return confirm('Xóa người dùng này sẽ xóa toàn bộ dữ liệu liên quan. Tiếp tục?')"
                                   class="text-red-600 bg-red-50 hover:bg-red-100 px-3 py-1 rounded border border-red-200 font-medium text-xs transition inline-block">
                                    Xóa
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    function editUser(id, username, email, role, ecoPoints, reputation) {
        document.getElementById('form-action').value = 'update-user';
        document.getElementById('user-id').value = id;

        document.getElementById('username').value = username;
        document.getElementById('email').value = email;
        document.getElementById('role').value = role;

        // Cập nhật giá trị hiển thị (Read-only)
        document.getElementById('ecoPoints').value = ecoPoints;
        document.getElementById('reputationScore').value = reputation;

        // UI Updates
        document.getElementById('form-title').innerHTML = '<span class="text-blue-600">✏️</span> Chỉnh sửa người dùng: ' + username;
        document.getElementById('submit-button').innerText = 'Cập nhật thông tin';
        document.getElementById('submit-button').classList.replace('bg-emerald-600', 'bg-blue-600');
        document.getElementById('submit-button').classList.replace('hover:bg-emerald-700', 'hover:bg-blue-700');

        document.getElementById('password').required = false;
        document.getElementById('password').placeholder = "Nhập mật khẩu mới (nếu muốn đổi)";
        document.getElementById('cancel-button').classList.remove('hidden');

        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function cancelEdit() {
        document.getElementById('form-action').value = 'add-user';
        document.getElementById('user-id').value = '';
        document.getElementById('user-form').reset();

        // Reset hiển thị
        document.getElementById('ecoPoints').value = '0.00';
        document.getElementById('reputationScore').value = '5.00';

        document.getElementById('form-title').innerHTML = '<span>👤</span> Thêm người dùng mới';
        document.getElementById('submit-button').innerText = 'Thêm người dùng';
        document.getElementById('submit-button').classList.replace('bg-blue-600', 'bg-emerald-600');
        document.getElementById('submit-button').classList.replace('hover:bg-blue-700', 'hover:bg-emerald-700');

        document.getElementById('password').required = true;
        document.getElementById('password').placeholder = "Nhập mật khẩu...";
        document.getElementById('cancel-button').classList.add('hidden');
    }
</script>

</body>
</html>