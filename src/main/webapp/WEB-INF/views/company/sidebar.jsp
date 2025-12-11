<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<aside class="fixed top-0 left-0 w-64 h-full bg-white shadow-md z-10 hidden md:block">
    <div class="flex items-center justify-center h-20 border-b">
        <h1 class="text-2xl font-bold text-emerald-600">EcoGive</h1>
        <span class="text-xs ml-2 font-semibold text-slate-500">Company</span>
    </div>
    <nav class="mt-4">
        <a href="${pageContext.request.contextPath}/dashboard/company" class="flex items-center px-6 py-3 text-slate-700 hover:bg-emerald-50 hover:text-emerald-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>
            <span class="ml-3">Tổng quan</span>
        </a>
        <a href="#addPointForm" class="flex items-center px-6 py-3 text-slate-700 hover:bg-emerald-50 hover:text-emerald-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
            <span class="ml-3">Điểm thu gom</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="absolute bottom-4 flex items-center w-full px-6 py-3 text-rose-500 hover:bg-rose-50">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
            <span class="ml-3">Đăng xuất</span>
        </a>
    </nav>
</aside>
