<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Người dùng - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        /* Custom Scrollbar */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 min-h-screen transition-all duration-300 flex flex-col">
    <!-- Header -->
    <header class="bg-white border-b border-slate-200 sticky top-0 z-10 px-8 py-4 flex justify-between items-center shadow-sm">
        <div>
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight">Người dùng</h1>
            <p class="text-sm text-slate-500 mt-1">Quản lý tài khoản và phân quyền hệ thống.</p>
        </div>
        <button onclick="toggleForm()" class="bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2.5 rounded-xl font-semibold shadow-lg shadow-emerald-200 transition-all flex items-center gap-2 active:scale-95">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Thêm mới
        </button>
    </header>

    <div class="p-8 max-w-7xl mx-auto w-full space-y-8">

        <!-- Form Section (Hidden by default or Toggle) -->
        <div id="user-form-container" class="hidden bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden transition-all duration-300">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex justify-between items-center">
                <h3 id="form-title" class="text-lg font-bold text-slate-800 flex items-center gap-2">
                    <span class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm">👤</span>
                    Thông tin người dùng
                </h3>
                <button onclick="toggleForm()" class="text-slate-400 hover:text-slate-600 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                </button>
            </div>

            <form id="user-form" action="${pageContext.request.contextPath}/admin/users" method="POST" class="p-6">
                <input type="hidden" id="form-action" name="action" value="add-user">
                <input type="hidden" id="user-id" name="user_id" value="">

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <div class="space-y-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Tên đăng nhập <span class="text-red-500">*</span></label>
                            <input type="text" id="username" name="username" required
                                   class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                                   placeholder="VD: nguyenvan_a">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Email <span class="text-red-500">*</span></label>
                            <input type="email" id="email" name="email" required
                                   class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                                   placeholder="example@email.com">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Mật khẩu <span class="text-red-500" id="pwd-star">*</span></label>
                            <input type="password" id="password" name="password" required
                                   class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                                   placeholder="••••••••">
                        </div>
                    </div>

                    <div class="space-y-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Vai trò</label>
                            <div class="relative">
                                <select id="role" name="role" class="w-full appearance-none rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all cursor-pointer">
                                    <option value="USER">Người dùng (User)</option>
                                    <option value="ADMIN">Quản trị viên (Admin)</option>
                                </select>
                                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-slate-500">
                                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                                </div>
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-4 p-4 bg-slate-50 rounded-xl border border-slate-100">
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Điểm Eco</label>
                                <div class="text-xl font-bold text-emerald-600" id="displayEco">0.00</div>
                                <input type="hidden" id="ecoPoints" name="ecoPoints" value="0.00">
                            </div>
                            <div>
                                <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Uy tín</label>
                                <div class="text-xl font-bold text-blue-600 flex items-center gap-1">
                                    <span id="displayRep">5.00</span>
                                    <svg class="w-4 h-4 text-yellow-400 fill-current" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                                </div>
                                <input type="hidden" id="reputationScore" name="reputationScore" value="5.00">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex justify-end gap-3 pt-4 border-t border-slate-100">
                    <button type="button" onclick="toggleForm()" class="px-5 py-2.5 rounded-xl text-sm font-semibold text-slate-600 hover:bg-slate-100 transition-colors">
                        Hủy bỏ
                    </button>
                    <button id="submit-button" type="submit" class="px-6 py-2.5 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 shadow-lg shadow-emerald-200 transition-all active:scale-95">
                        Thêm người dùng
                    </button>
                </div>
            </form>
        </div>

        <!-- Table Section -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                    <tr class="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500 font-bold">
                        <th class="px-6 py-4">User</th>
                        <th class="px-6 py-4">Vai trò</th>
                        <th class="px-6 py-4">Điểm Eco</th>
                        <th class="px-6 py-4">Uy tín</th>
                        <th class="px-6 py-4">Ngày tham gia</th>
                        <th class="px-6 py-4 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-sm">
                    <c:forEach var="u" items="${users}">
                        <tr class="group hover:bg-slate-50/80 transition-colors">
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-gradient-to-br from-slate-100 to-slate-200 flex items-center justify-center text-slate-500 font-bold text-xs border border-slate-200">
                                        ${u.username.substring(0,1).toUpperCase()}
                                    </div>
                                    <div>
                                        <div class="font-semibold text-slate-800">${u.username}</div>
                                        <div class="text-xs text-slate-500">${u.email}</div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border ${u.role == 'ADMIN' ? 'bg-purple-50 text-purple-700 border-purple-100' : 'bg-emerald-50 text-emerald-700 border-emerald-100'}">
                                    ${u.role == 'ADMIN' ? '🛡️ Admin' : '👤 User'}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="font-bold text-emerald-600">${u.ecoPoints}</div>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-1 text-slate-700 font-medium">
                                    <span>${u.reputationScore}</span>
                                    <svg class="w-3.5 h-3.5 text-yellow-400 fill-current" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-slate-500 text-xs">
                                ${u.joinDate}
                            </td>
                            <td class="px-6 py-4 text-right">
                                <div class="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button onclick="editUser(${u.userId}, '${u.username}', '${u.email}', '${u.role}', ${u.ecoPoints}, ${u.reputationScore})"
                                            class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="Chỉnh sửa">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/admin?action=delete-user&id=${u.userId}"
                                       onclick="return confirm('Cảnh báo: Xóa người dùng sẽ xóa toàn bộ dữ liệu liên quan. Tiếp tục?')"
                                       class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Xóa">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
            <!-- Empty State -->
            <c:if test="${empty users}">
                <div class="p-12 text-center">
                    <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
                        <span class="text-2xl">👥</span>
                    </div>
                    <h3 class="text-slate-800 font-bold mb-1">Chưa có người dùng</h3>
                    <p class="text-slate-500 text-sm">Danh sách hiện tại đang trống.</p>
                </div>
            </c:if>
        </div>
    </div>
</main>

<script>
    function toggleForm() {
        const formContainer = document.getElementById('user-form-container');
        formContainer.classList.toggle('hidden');
        if (!formContainer.classList.contains('hidden')) {
            // Reset form when opening if it was in edit mode but closed
            if(document.getElementById('form-action').value === 'add-user') {
                document.getElementById('user-form').reset();
            }
        }
    }

    function editUser(id, username, email, role, ecoPoints, reputation) {
        // Show form
        const formContainer = document.getElementById('user-form-container');
        formContainer.classList.remove('hidden');

        // Set values
        document.getElementById('form-action').value = 'update-user';
        document.getElementById('user-id').value = id;
        document.getElementById('username').value = username;
        document.getElementById('email').value = email;
        document.getElementById('role').value = role;

        // Display read-only values
        document.getElementById('displayEco').innerText = ecoPoints;
        document.getElementById('displayRep').innerText = reputation;

        // UI Updates
        document.getElementById('form-title').innerHTML = '<span class="w-8 h-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center text-sm">✏️</span> Cập nhật: ' + username;
        const btn = document.getElementById('submit-button');
        btn.innerText = 'Lưu thay đổi';
        btn.classList.remove('bg-emerald-600', 'hover:bg-emerald-700', 'shadow-emerald-200');
        btn.classList.add('bg-blue-600', 'hover:bg-blue-700', 'shadow-blue-200');

        // Password optional
        document.getElementById('password').required = false;
        document.getElementById('password').placeholder = "Nhập mật khẩu mới (nếu muốn đổi)";
        document.getElementById('pwd-star').classList.add('hidden');

        // Scroll to form
        formContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    // Reset form when manually cancelled or toggled closed (optional logic enhancement)
    document.getElementById('user-form').addEventListener('reset', function() {
        setTimeout(() => {
            document.getElementById('form-action').value = 'add-user';
            document.getElementById('user-id').value = '';
            document.getElementById('form-title').innerHTML = '<span class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm">👤</span> Thông tin người dùng';
            const btn = document.getElementById('submit-button');
            btn.innerText = 'Thêm người dùng';
            btn.classList.add('bg-emerald-600', 'hover:bg-emerald-700', 'shadow-emerald-200');
            btn.classList.remove('bg-blue-600', 'hover:bg-blue-700', 'shadow-blue-200');
            document.getElementById('password').required = true;
            document.getElementById('password').placeholder = "••••••••";
            document.getElementById('pwd-star').classList.remove('hidden');
            document.getElementById('displayEco').innerText = '0.00';
            document.getElementById('displayRep').innerText = '5.00';
        }, 10);
    });
</script>

</body>
</html>