<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Người dùng</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex">

<jsp:include page="sidebar.jsp" />

<div class="flex-1 md:ml-64 p-8 rounded-2xl">
    <h1 class="text-2xl font-bold text-gray-800 mb-6">Quản lý Người dùng</h1>

    <!-- Add/Edit User Form -->
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 mb-8">
        <h3 id="form-title" class="text-lg font-semibold text-emerald-700 mb-4 flex items-center gap-2">
            <span>👤</span> Thêm người dùng mới
        </h3>

        <form id="user-form" action="${pageContext.request.contextPath}/admin/users" method="POST" class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
            <input type="hidden" id="form-action" name="action" value="add-user">
            <input type="hidden" id="user-id" name="user_id" value="">

            <div class="md:col-span-3">
                <label class="block text-sm font-medium text-slate-700 mb-1">Tên đăng nhập</label>
                <input type="text" id="username" name="username" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-slate-400">
            </div>

            <div class="md:col-span-3">
                <label class="block text-sm font-medium text-slate-700 mb-1">Email</label>
                <input type="email" id="email" name="email" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-slate-400">
            </div>

            <div class="md:col-span-3">
                <label class="block text-sm font-medium text-slate-700 mb-1">Mật khẩu</label>
                <input type="password" id="password" name="password" required
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 placeholder-slate-400"
                       placeholder="Để trống nếu không muốn thay đổi">
            </div>
            
            <div class="md:col-span-3">
                <label class="block text-sm font-medium text-slate-700 mb-1">Vai trò</label>
                <select id="role" name="role" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500">
                    <option value="USER">USER</option>
                    <option value="ADMIN">ADMIN</option>
                </select>
            </div>

            <div class="md:col-span-12 flex justify-end gap-2 mt-4">
                <button id="cancel-button" type="button" onclick="cancelEdit()" class="hidden w-full md:w-auto inline-flex items-center justify-center rounded-lg bg-gray-300 px-4 py-2 text-sm font-semibold text-gray-800 shadow-sm hover:bg-gray-400 focus:outline-none transition-all">
                    Hủy
                </button>
                <button id="submit-button" type="submit" class="w-full md:w-auto inline-flex items-center justify-center rounded-lg bg-emerald-600 px-6 py-2 text-sm font-semibold text-white shadow-sm hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 transition-all">
                    Thêm người dùng
                </button>
            </div>
        </form>
    </div>

    <!-- User List Table -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <h2 class="text-xl font-bold text-gray-800 p-6">Danh sách Người dùng</h2>
        <table class="w-full text-left border-collapse">
            <thead class="bg-slate-100 text-slate-600 uppercase text-sm font-semibold">
            <tr>
                <th class="px-6 py-3 border-b">ID</th>
                <th class="px-6 py-3 border-b">Username</th>
                <th class="px-6 py-3 border-b">Email</th>
                <th class="px-6 py-3 border-b">Điểm Eco</th>
                <th class="px-6 py-3 border-b">Uy tín</th>
                <th class="px-6 py-3 border-b">Ngày tham gia</th>
                <th class="px-6 py-3 border-b">Vai trò</th>
                <th class="px-6 py-3 border-b text-right">Hành động</th>
            </tr>
            </thead>
            <tbody class="text-gray-700">
            <c:forEach var="u" items="${users}">
                <tr class="border-b hover:bg-slate-50">
                    <td class="px-6 py-4">#${u.userId}</td>
                    <td class="px-6 py-4 font-medium">${u.username}</td>
                    <td class="px-6 py-4 text-gray-500">${u.email}</td>
                    <td class="px-6 py-4 text-green-600 font-bold">${u.ecoPoints}</td>
                    <td class="px-6 py-4">
                        <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-0.5 rounded">
                            ${u.reputationScore} / 5.0
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500">${u.joinDate}</td>
                    <td class="px-6 py-4">
                        <c:choose>
                            <c:when test="${u.role == 'ADMIN'}">
                                <span class="bg-red-100 text-red-800 text-xs font-semibold px-2 py-0.5 rounded-full">${u.role}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="bg-green-100 text-green-800 text-xs font-semibold px-2 py-0.5 rounded-full">${u.role}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="px-6 py-4 text-right">
                        <a href="#" onclick="editUser(${u.userId}, '${u.username}', '${u.email}', '${u.role}')" class="text-blue-600 hover:text-blue-800 font-medium">Sửa</a>
                        <a href="${pageContext.request.contextPath}/admin/users?action=delete-user&id=${u.userId}" onclick="return confirm('Bạn có chắc chắn muốn xóa người dùng này?')" class="text-red-600 hover:text-red-800 font-medium ml-4">Xóa</a>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<script>
    function editUser(id, username, email, role) {
        // Change form action and hidden ID
        document.getElementById('form-action').value = 'update-user';
        document.getElementById('user-id').value = id;

        // Populate form fields
        document.getElementById('username').value = username;
        document.getElementById('email').value = email;
        document.getElementById('role').value = role;

        // Update UI
        document.getElementById('form-title').innerHTML = '<span>✏️</span> Chỉnh sửa người dùng: ' + username;
        document.getElementById('submit-button').innerText = 'Cập nhật';
        document.getElementById('password').required = false; // Password is not required for update
        document.getElementById('cancel-button').classList.remove('hidden');

        // Scroll to form
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function cancelEdit() {
        // Reset form action and hidden ID
        document.getElementById('form-action').value = 'add-user';
        document.getElementById('user-id').value = '';

        // Clear form fields
        document.getElementById('user-form').reset();

        // Update UI
        document.getElementById('form-title').innerHTML = '<span>👤</span> Thêm người dùng mới';
        document.getElementById('submit-button').innerText = 'Thêm người dùng';
        document.getElementById('password').required = true; // Password is required for new user
        document.getElementById('cancel-button').classList.add('hidden');
    }
</script>

</body>
</html>