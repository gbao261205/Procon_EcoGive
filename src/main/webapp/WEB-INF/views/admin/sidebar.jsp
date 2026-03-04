<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setBundle basename="messages" scope="session" />

<aside class="w-64 bg-white border-r border-slate-200 hidden md:flex flex-col h-screen fixed left-0 top-0 z-20 shadow-[4px_0_24px_rgba(0,0,0,0.02)]">
    <!-- Logo Section -->
    <div class="h-20 flex items-center px-8 border-b border-slate-100">
        <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 group hover:opacity-80 transition-all">
            <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
            <span class="material-symbols-outlined text-emerald-600 group-hover:scale-110 transition-transform" style="font-size: 32px;">spa</span>
            <div>
                <h2 class="text-xl font-bold text-slate-800 tracking-tight leading-none">EcoGive</h2>
                <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider"><fmt:message key="sidebar.admin_panel" /></span>
            </div>
        </a>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 px-4 py-6 space-y-1 overflow-y-auto custom-scrollbar">
        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3"><fmt:message key="admin.overview" /></p>

        <a href="${pageContext.request.contextPath}/admin?action=dashboard"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${param.action == 'dashboard' || param.action == null ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${param.action == 'dashboard' || param.action == null ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
            </span>
            <fmt:message key="sidebar.dashboard" />
        </a>

        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mt-8 mb-3"><fmt:message key="home.manage" /></p>

        <a href="${pageContext.request.contextPath}/admin?action=users"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${param.action == 'users' ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${param.action == 'users' ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
            </span>
            <fmt:message key="sidebar.users" />
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=categories"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${param.action == 'categories' ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${param.action == 'categories' ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg>
            </span>
            <fmt:message key="sidebar.categories" />
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${param.action == 'items' ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${param.action == 'items' ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
            </span>
            <fmt:message key="sidebar.items" />
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=stations"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${param.action == 'stations' ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${param.action == 'stations' ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
            </span>
            <fmt:message key="sidebar.stations" />
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=station-types"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${param.action == 'station-types' ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${param.action == 'station-types' ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path></svg>
            </span>
            <fmt:message key="sidebar.station_types" />
        </a>

        <a href="${pageContext.request.contextPath}/admin/rewards"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${activeTab == 'rewards' || requestScope['javax.servlet.forward.servlet_path'] == '/admin/rewards' ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${activeTab == 'rewards' || requestScope['javax.servlet.forward.servlet_path'] == '/admin/rewards' ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 12 20 22 4 22 4 12"></polyline><rect x="2" y="7" width="20" height="5"></rect><line x1="12" y1="22" x2="12" y2="7"></line><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"></path><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"></path></svg>
            </span>
            <fmt:message key="sidebar.rewards" />
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=verify-requests"
           class="group flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200
           ${param.action == 'verify-requests' ? 'bg-emerald-50 text-emerald-700 shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-emerald-600'}">
            <span class="${param.action == 'verify-requests' ? 'text-emerald-600' : 'text-slate-400 group-hover:text-emerald-500'} transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
            </span>
            <fmt:message key="sidebar.verify_requests" />
        </a>
    </nav>

    <!-- Footer -->
    <div class="p-4 border-t border-slate-100">
        <a href="${pageContext.request.contextPath}/logout"
           class="flex items-center gap-3 px-4 py-3 text-sm font-medium text-red-600 rounded-xl hover:bg-red-50 transition-colors group">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="group-hover:-translate-x-1 transition-transform"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
            <fmt:message key="sidebar.logout" />
        </a>
    </div>
</aside>