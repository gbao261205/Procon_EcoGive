<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Doanh nghiệp - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Inter', sans-serif; }
        /* Custom scrollbar for webkit */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="bg-gray-50 text-slate-800 antialiased">

<div class="flex h-screen overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-72 bg-white border-r border-gray-200 flex flex-col transition-all duration-300 hidden md:flex z-20">
        <!-- Logo Area -->
        <div class="h-16 flex items-center px-8 border-b border-gray-100">
            <div class="flex items-center gap-2 text-primary font-bold text-2xl tracking-tight">
                <svg width="23px" height="84px" viewBox="0 0 23 84" version="1.1" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet">
                    <g transform="scale(0.022) translate(0, 1400)">
                        <path d="M531.8 385v483.3h0.1V385h-0.1z" fill="#343535" />
                        <path d="M670.9 497.1h86v16h-86zM670.9 625.1h86v16h-86zM233.9 241.1h86v16h-86zM384 241.1h86v16h-86zM233.9 369h86v16h-86zM384 369h86v16h-86zM234 497.5h86v16h-86zM384 497.2h86v16h-86z" fill="#39393A" />
                        <path d="M398.3 704.4c-11.9-11.9-28.4-19.3-46.5-19.3-36.2 0-65.8 29.6-65.8 65.8v117.4h20V750.9c0-12.2 4.8-23.6 13.5-32.3 8.7-8.7 20.2-13.5 32.3-13.5 12.2 0 23.6 4.8 32.3 13.5 8.7 8.7 13.5 20.2 13.5 32.3v117.4h20V750.9c0-18.1-7.4-34.5-19.3-46.5z" fill="#E73B37" />
                        <path d="M575.8 429v437.9h0.1V429h-0.1zM286.2 868.3h131.6-131.6z" fill="#343535" />
                        <path d="M896 868.3V385H575.9V111.6H128v756.7H64v44h896v-44h-64z m-364.1 0H172V155.6h359.9v712.7z m320.1-1.5H575.8V429H852v437.8z" fill="#39393A" />
                    </g>
                </svg>
                EcoGive
            </div>
        </div>

        <!-- User Profile Summary -->
        <div class="p-6 border-b border-gray-50 bg-gray-50/50">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-lg border border-primary/20 shadow-sm">
                    DN
                </div>
                <div>
                    <h3 class="text-sm font-bold text-slate-900">Doanh Nghiệp</h3>
                    <p class="text-xs text-slate-500 font-medium">Partner Account</p>
                </div>
            </div>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 overflow-y-auto py-6 px-4 space-y-1">
            <a href="#" class="flex items-center gap-3 px-4 py-3 text-primary bg-primary/10 rounded-lg font-semibold transition-all shadow-sm border border-primary/10">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                Điểm thu gom
            </a>

<%--            <a href="#" class="flex items-center gap-3 px-4 py-3 text-slate-600 hover:bg-slate-50 hover:text-slate-900 rounded-lg font-medium transition-colors group">--%>
<%--                <svg class="w-5 h-5 text-slate-400 group-hover:text-slate-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>--%>
<%--                Thống kê--%>
<%--            </a>--%>

<%--            <a href="#" class="flex items-center gap-3 px-4 py-3 text-slate-600 hover:bg-slate-50 hover:text-slate-900 rounded-lg font-medium transition-colors group">--%>
<%--                <svg class="w-5 h-5 text-slate-400 group-hover:text-slate-600 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>--%>
<%--                Cài đặt--%>
<%--            </a>--%>
        </nav>

        <!-- Footer -->
        <div class="p-4 border-t border-gray-100">
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-4 py-3 text-red-600 hover:bg-red-50 rounded-lg font-medium transition-colors">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H3"></path></svg>
                Đăng xuất
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col overflow-hidden relative bg-gray-50">
        <!-- Mobile Header -->
        <header class="md:hidden bg-white border-b border-gray-200 h-16 flex items-center justify-between px-4 shadow-sm z-10">
            <div class="font-bold text-primary text-xl flex items-center gap-2">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path></svg>
                EcoGive
            </div>
            <button class="text-slate-500 hover:text-slate-700 p-2 rounded-md hover:bg-gray-100">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
            </button>
        </header>

        <!-- Scrollable Content Area -->
        <div class="flex-1 overflow-y-auto p-4 md:p-8">
            <div class="max-w-7xl mx-auto">
                <!-- Page Header -->
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
                    <div>
                        <h1 class="text-2xl md:text-3xl font-bold text-slate-900 tracking-tight">Quản lý Điểm thu gom</h1>
                        <p class="text-slate-500 mt-1 text-sm md:text-base">Xem và quản lý danh sách các địa điểm thu gom rác thải của bạn.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center justify-center gap-2 bg-primary hover:bg-primary-hover text-white font-semibold py-2.5 px-5 rounded-lg shadow-lg shadow-primary/30 transition-all transform hover:-translate-y-0.5 active:scale-95">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
                        <span>Thêm Điểm Mới</span>
                    </a>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="mb-6 bg-red-50 border-l-4 border-red-500 p-4 rounded-r-lg shadow-sm flex items-start gap-3 animate-fade-in-down" role="alert">
                        <svg class="w-5 h-5 text-red-500 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        <div class="flex-1">
                            <p class="text-sm text-red-700 font-medium">${sessionScope.errorMessage}</p>
                        </div>
                        <% session.removeAttribute("errorMessage"); %>
                    </div>
                </c:if>

                <!-- Content Card -->
                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <!-- Card Header -->
                    <div class="px-6 py-5 border-b border-gray-100 flex items-center justify-between bg-white">
                        <div class="flex items-center gap-2">
                            <div class="w-1 h-6 bg-primary rounded-full"></div>
                            <h3 class="text-lg font-bold text-slate-800">Danh sách điểm thu gom</h3>
                        </div>
                        <div class="text-sm text-slate-500 bg-gray-50 px-3 py-1 rounded-full border border-gray-200">
                            Tổng số: <span class="font-bold text-slate-900"><c:out value="${collectionPoints != null ? collectionPoints.size() : 0}"/></span> điểm
                        </div>
                    </div>

                    <!-- Table -->
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm text-left">
                            <thead class="bg-gray-50/80 text-slate-500 font-semibold uppercase tracking-wider text-xs border-b border-gray-200">
                                <tr>
                                    <th class="px-6 py-4">Tên Điểm</th>
                                    <th class="px-6 py-4">Địa chỉ</th>
                                    <th class="px-6 py-4">Loại rác</th>
                                    <th class="px-6 py-4 text-right">Hành động</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <c:choose>
                                    <c:when test="${not empty collectionPoints}">
                                        <c:forEach var="point" items="${collectionPoints}">
                                            <tr class="group hover:bg-blue-50/30 transition-colors duration-200">
                                                <td class="px-6 py-4 font-medium text-slate-900">
                                                    <div class="flex items-center gap-3">
                                                        <div class="w-9 h-9 rounded-lg bg-primary/10 flex items-center justify-center text-primary flex-shrink-0">
                                                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                                                        </div>
                                                        <span class="truncate max-w-[200px]" title="${point.name}">${point.name}</span>
                                                    </div>
                                                </td>
                                                <td class="px-6 py-4 text-slate-600 max-w-xs truncate" title="${point.address}">
                                                    ${point.address}
                                                </td>
                                                <td class="px-6 py-4">
                                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border shadow-sm
                                                        ${point.type == 'BATTERY' ? 'bg-yellow-50 text-yellow-700 border-yellow-200' :
                                                         point.type == 'E_WASTE' ? 'bg-blue-50 text-blue-700 border-blue-200' :
                                                         'bg-green-50 text-green-700 border-green-200'}">
                                                        <span class="w-1.5 h-1.5 rounded-full mr-1.5
                                                            ${point.type == 'BATTERY' ? 'bg-yellow-500' :
                                                             point.type == 'E_WASTE' ? 'bg-blue-500' :
                                                             'bg-green-500'}"></span>
                                                        ${point.type.displayName}
                                                    </span>
                                                </td>
                                                <td class="px-6 py-4 text-right">
                                                    <div class="flex items-center justify-end gap-2 opacity-60 group-hover:opacity-100 transition-opacity">
                                                        <!-- Delete Form -->
                                                        <form action="${pageContext.request.contextPath}/dashboard/company" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn xóa điểm này? Hành động này không thể hoàn tác.');" class="inline-block">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="pointId" value="${point.pointId}">
                                                            <button type="submit" class="flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-red-600 bg-red-50 hover:bg-red-100 border border-red-100 rounded-md transition-colors" title="Xóa điểm này">
                                                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                                                Xóa
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="px-6 py-20 text-center">
                                                <div class="flex flex-col items-center justify-center">
                                                    <div class="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center mb-4 text-gray-300 border border-gray-100">
                                                        <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                                                    </div>
                                                    <h3 class="text-slate-900 font-semibold text-lg mb-2">Chưa có điểm thu gom nào</h3>
                                                    <p class="text-slate-500 text-sm mb-6 max-w-sm mx-auto">Danh sách của bạn đang trống. Hãy đóng góp cho môi trường bằng cách thêm địa điểm thu gom đầu tiên.</p>
                                                    <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-2 text-primary hover:text-primary-hover font-semibold text-sm bg-primary/5 hover:bg-primary/10 px-4 py-2 rounded-lg transition-colors">
                                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                                                        Thêm điểm mới ngay
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination (Static Placeholder) -->
                    <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 flex items-center justify-between">
                        <span class="text-xs text-slate-500">Hiển thị <span class="font-semibold text-slate-700">1</span> đến <span class="font-semibold text-slate-700"><c:out value="${collectionPoints != null ? collectionPoints.size() : 0}"/></span> kết quả</span>
                        <div class="flex gap-2">
                            <button class="px-3 py-1.5 text-xs font-medium border border-gray-300 rounded-md bg-white text-slate-400 cursor-not-allowed shadow-sm" disabled>Trước</button>
                            <button class="px-3 py-1.5 text-xs font-medium border border-gray-300 rounded-md bg-white text-slate-400 cursor-not-allowed shadow-sm" disabled>Sau</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

</body>
</html>
