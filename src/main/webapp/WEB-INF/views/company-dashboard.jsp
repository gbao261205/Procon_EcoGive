<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setBundle basename="messages" scope="session" />

<!DOCTYPE html>
<html lang="${sessionScope.lang != null ? sessionScope.lang : 'vi'}">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="company.title" /> - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Using Material Symbols Rounded for a friendlier, modern look -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0" />
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                        'primary-light': '#e6fcf5',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                    boxShadow: {
                        'soft': '0 4px 20px -2px rgba(0, 0, 0, 0.05)',
                        'card': '0 0 0 1px rgba(226, 232, 240, 1), 0 2px 4px rgba(0, 0, 0, 0.05)',
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-rounded { font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        /* Custom Scrollbar */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="bg-slate-50 text-slate-600 antialiased">

<div class="flex h-screen overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-72 bg-white border-r border-slate-100 flex flex-col z-20 hidden md:flex shadow-soft">
        <!-- Logo -->
        <div class="h-20 flex items-center px-8 border-b border-slate-50">
            <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 text-primary font-bold text-2xl tracking-tight group">
                <span class="material-symbols-rounded text-3xl group-hover:scale-110 transition-transform">spa</span>
                EcoGive
            </a>
        </div>

        <!-- User Info Card -->
        <div class="p-6">
            <div class="bg-primary-light/40 p-4 rounded-2xl border border-primary/10 flex items-center gap-4">
                <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center text-primary shadow-sm shrink-0">
                    <span class="material-symbols-rounded">business</span>
                </div>
                <div class="min-w-0">
                    <h3 class="text-sm font-bold text-slate-800 truncate">${sessionScope.currentUser.username}</h3>
                    <p class="text-xs text-slate-500 font-medium">Partner Portal</p>
                </div>
            </div>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 px-4 space-y-2 overflow-y-auto">
            <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-2 mt-2"><fmt:message key="home.manage" /></p>

            <a href="#" class="flex items-center gap-3 px-4 py-3.5 text-primary bg-primary-light rounded-xl font-semibold transition-all shadow-sm ring-1 ring-primary/10">
                <span class="material-symbols-rounded">recycling</span>
                <fmt:message key="sidebar.stations" />
            </a>

            <a href="${pageContext.request.contextPath}/verify-company" class="flex items-center gap-3 px-4 py-3.5 text-slate-500 hover:bg-slate-50 hover:text-primary rounded-xl font-medium transition-all group">
                <span class="material-symbols-rounded group-hover:scale-110 transition-transform">verified_user</span>
                <fmt:message key="verify.title" />
            </a>
        </nav>

        <!-- Footer -->
        <div class="p-4 border-t border-slate-50">
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-4 py-3 text-red-500 hover:bg-red-50 rounded-xl font-medium transition-colors">
                <span class="material-symbols-rounded">logout</span>
                <fmt:message key="sidebar.logout" />
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col overflow-hidden relative">
        <!-- Mobile Header -->
        <header class="md:hidden bg-white border-b border-slate-100 h-16 flex items-center justify-between px-4 shadow-sm z-10">
            <div class="font-bold text-primary text-xl flex items-center gap-2">
                <span class="material-symbols-rounded">spa</span> EcoGive
            </div>
            <button class="text-slate-500 p-2 rounded-lg hover:bg-slate-50">
                <span class="material-symbols-rounded">menu</span>
            </button>
        </header>

        <!-- Scrollable Area -->
        <div class="flex-1 overflow-y-auto p-4 md:p-8 lg:p-10">
            <div class="max-w-6xl mx-auto">

                <!-- Page Header & Actions -->
                <div class="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-10">
                    <div>
                        <h1 class="text-3xl font-bold text-slate-800 tracking-tight mb-2"><fmt:message key="company.my_points" /></h1>
                        <p class="text-slate-500"><fmt:message key="company.welcome" /></p>
                    </div>
                    <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-2 bg-primary hover:bg-primary-hover text-white font-bold py-3 px-6 rounded-xl shadow-lg shadow-primary/20 transition-all transform hover:-translate-y-1 active:scale-95">
                        <span class="material-symbols-rounded">add_location_alt</span>
                        <fmt:message key="company.add_point" />
                    </a>
                </div>

                <!-- Stats Overview -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                    <!-- Stat Card 1 -->
                    <div class="bg-white p-6 rounded-2xl shadow-card flex items-center gap-5 transition-transform hover:-translate-y-1 duration-300">
                        <div class="w-14 h-14 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
                            <span class="material-symbols-rounded text-3xl">location_on</span>
                        </div>
                        <div>
                            <p class="text-slate-400 text-xs font-bold uppercase tracking-wider"><fmt:message key="company.total_points" /></p>
                            <p class="text-3xl font-bold text-slate-800 mt-1"><c:out value="${collectionPoints != null ? collectionPoints.size() : 0}"/></p>
                        </div>
                    </div>

                    <!-- Stat Card 2 (Placeholder for future data) -->
                    <div class="bg-white p-6 rounded-2xl shadow-card flex items-center gap-5 transition-transform hover:-translate-y-1 duration-300">
                        <div class="w-14 h-14 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                            <span class="material-symbols-rounded text-3xl">check_circle</span>
                        </div>
                        <div>
                            <p class="text-slate-400 text-xs font-bold uppercase tracking-wider"><fmt:message key="company.status" /></p>
                            <p class="text-lg font-bold text-slate-800 mt-1"><fmt:message key="company.active" /></p>
                        </div>
                    </div>
                </div>

                <!-- Alert Messages -->
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="mb-8 bg-red-50 border border-red-100 text-red-600 p-4 rounded-xl flex items-start gap-3 animate-pulse shadow-sm">
                        <span class="material-symbols-rounded mt-0.5">error</span>
                        <div class="flex-1 font-medium text-sm leading-relaxed">${sessionScope.errorMessage}</div>
                        <% session.removeAttribute("errorMessage"); %>
                    </div>
                </c:if>

                <!-- Data Table Card -->
                <div class="bg-white rounded-3xl shadow-card overflow-hidden">
                    <div class="px-8 py-6 border-b border-slate-100 flex justify-between items-center bg-white">
                        <h3 class="font-bold text-slate-800 text-lg"><fmt:message key="company.list_title" /></h3>
                        <div class="text-xs font-medium text-slate-400 bg-slate-50 px-3 py-1 rounded-full border border-slate-100">
                            <fmt:message key="company.updated" />
                        </div>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50/80 border-b border-slate-100 text-xs uppercase font-bold text-slate-400 tracking-wider">
                                    <th class="px-8 py-5"><fmt:message key="company.table.info" /></th>
                                    <th class="px-8 py-5"><fmt:message key="company.table.type" /></th>
                                    <th class="px-8 py-5 text-right"><fmt:message key="company.table.action" /></th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-50">
                                <c:choose>
                                    <c:when test="${not empty collectionPoints}">
                                        <c:forEach var="point" items="${collectionPoints}">
                                            <tr class="hover:bg-slate-50/80 transition-colors group">
                                                <td class="px-8 py-5">
                                                    <div class="flex items-start gap-4">
                                                        <div class="w-12 h-12 rounded-xl bg-primary-light text-primary flex items-center justify-center shrink-0 mt-1 border border-primary/10 shadow-sm group-hover:scale-110 transition-transform duration-300">
                                                            <span class="material-symbols-rounded text-2xl">storefront</span>
                                                        </div>
                                                        <div>
                                                            <div class="font-bold text-slate-800 text-base mb-1 group-hover:text-primary transition-colors">${point.name}</div>
                                                            <div class="text-sm text-slate-500 flex items-center gap-1.5">
                                                                <span class="material-symbols-rounded text-[16px] text-slate-400">map</span>
                                                                ${point.address}
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="px-8 py-5 align-middle">
                                                    <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-slate-100 text-slate-600 border border-slate-200 group-hover:bg-white group-hover:shadow-sm transition-all">
                                                        <span>${point.typeIcon}</span> ${point.typeName}
                                                    </span>
                                                </td>
                                                <td class="px-8 py-5 text-right align-middle">
                                                    <fmt:message key="company.delete_confirm" var="deleteConfirm" />
                                                    <form action="${pageContext.request.contextPath}/dashboard/company" method="post" onsubmit="return confirm('${deleteConfirm}');" class="inline-block">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="pointId" value="${point.pointId}">
                                                        <button type="submit" class="w-10 h-10 rounded-full flex items-center justify-center text-slate-400 hover:text-red-600 hover:bg-red-50 border border-transparent hover:border-red-100 transition-all" title="<fmt:message key='company.delete' />">
                                                            <span class="material-symbols-rounded">delete</span>
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="3" class="px-8 py-24 text-center">
                                                <div class="flex flex-col items-center justify-center animate-fade-in">
                                                    <div class="w-24 h-24 bg-slate-50 rounded-full flex items-center justify-center mb-6 text-slate-300 border border-slate-100">
                                                        <span class="material-symbols-rounded text-5xl">location_off</span>
                                                    </div>
                                                    <h3 class="text-slate-800 font-bold text-xl mb-2"><fmt:message key="company.no_points" /></h3>
                                                    <p class="text-slate-500 text-sm max-w-xs mx-auto mb-8 leading-relaxed"><fmt:message key="company.empty_desc" /></p>
                                                    <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-2 text-primary font-bold hover:underline text-sm bg-primary-light/50 px-4 py-2 rounded-lg hover:bg-primary-light transition-colors">
                                                        <span class="material-symbols-rounded text-lg">add</span>
                                                        <fmt:message key="company.add_now" />
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination (Static for now) -->
                    <div class="px-8 py-4 border-t border-slate-100 bg-slate-50 flex items-center justify-between">
                        <span class="text-xs text-slate-500 font-medium"><fmt:message key="company.showing" /> <span class="text-slate-800"><c:out value="${collectionPoints != null ? collectionPoints.size() : 0}"/></span> <fmt:message key="company.results" /></span>
                        <div class="flex gap-2 opacity-50 pointer-events-none">
                            <button class="px-3 py-1.5 text-xs font-bold border border-slate-200 rounded-lg bg-white text-slate-400"><fmt:message key="company.prev" /></button>
                            <button class="px-3 py-1.5 text-xs font-bold border border-slate-200 rounded-lg bg-white text-slate-400"><fmt:message key="company.next" /></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

</body>
</html>