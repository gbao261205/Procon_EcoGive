<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<aside class="w-64 bg-white border-r border-slate-200 hidden md:flex flex-col h-screen fixed left-0 top-0 overflow-y-auto z-10">
    <div class="h-16 flex items-center px-6 border-b border-slate-100">
        <h2 class="text-2xl font-bold text-emerald-600 tracking-tight">EcoGive <span class="text-slate-400 text-sm font-normal">Admin</span></h2>
    </div>

    <nav class="flex-1 p-4 space-y-1">
        <p class="px-3 text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">Quản lý chung</p>

        <a href="${pageContext.request.contextPath}/admin?action=dashboard"
           class="group flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-lg transition-colors ${param.action == 'dashboard' || param.action == null ? 'bg-emerald-50 text-emerald-700' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span>📊</span> Tổng quan
        </a>

        <p class="px-3 text-xs font-semibold text-slate-400 uppercase tracking-wider mt-6 mb-2">Dữ liệu</p>

        <a href="${pageContext.request.contextPath}/admin?action=users"
           class="group flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-lg transition-colors ${param.action == 'users' ? 'bg-emerald-50 text-emerald-700' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span>👥</span> Người dùng
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=categories"
           class="group flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-lg transition-colors ${param.action == 'categories' ? 'bg-emerald-50 text-emerald-700' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span>🗂️</span> Danh mục
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items"
           class="group flex items-center gap-3 px-3 py-2.5 text-sm font-medium rounded-lg transition-colors ${param.action == 'items' ? 'bg-emerald-50 text-emerald-700' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span>📦</span> Vật phẩm
        </a>
    </nav>

    <div class="p-4 border-t border-slate-100">
        <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-3 py-2.5 text-sm font-medium text-red-600 rounded-lg hover:bg-red-50 transition-colors">
            <span>🚪</span> Đăng xuất
        </a>
    </div>
</aside>