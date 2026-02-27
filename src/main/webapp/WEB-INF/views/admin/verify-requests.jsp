<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Duyệt Doanh nghiệp - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 min-h-screen transition-all duration-300 flex flex-col">
    <!-- Header -->
    <header class="bg-white border-b border-slate-200 sticky top-0 z-10 px-8 py-4 flex justify-between items-center shadow-sm">
        <div>
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight">Xác thực Doanh nghiệp</h1>
            <p class="text-sm text-slate-500 mt-1">Duyệt các yêu cầu xác thực từ tài khoản doanh nghiệp.</p>
        </div>
    </header>

    <div class="p-8 max-w-7xl mx-auto w-full">
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                    <tr>
                        <th class="px-6 py-4 border-b border-slate-100">Doanh nghiệp</th>
                        <th class="px-6 py-4 border-b border-slate-100">Email</th>
                        <th class="px-6 py-4 border-b border-slate-100">Tài liệu</th>
                        <th class="px-6 py-4 border-b border-slate-100 text-right">Hành động</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-sm">
                    <c:forEach var="req" items="${requests}">
                        <tr class="hover:bg-slate-50 transition-colors">
                            <td class="px-6 py-4 font-bold text-slate-800">${req.username}</td>
                            <td class="px-6 py-4 text-slate-600">${req.email}</td>
                            <td class="px-6 py-4">
                                <c:choose>
                                    <c:when test="${not empty req.verificationDocument}">
                                        <a href="${req.verificationDocument}" target="_blank" class="text-blue-600 hover:underline font-medium flex items-center gap-1">
                                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                                            </svg>
                                            Xem tài liệu
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-slate-400 italic">Không có tài liệu</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-6 py-4 text-right">
                                <div class="flex justify-end gap-2">
                                    <a href="${pageContext.request.contextPath}/admin?action=approve-company&id=${req.userId}"
                                       onclick="return confirm('Xác nhận duyệt doanh nghiệp này?');"
                                       class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-lg shadow-sm transition-colors">
                                        Duyệt
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin?action=reject-company&id=${req.userId}"
                                       onclick="return confirm('Từ chối yêu cầu này?');"
                                       class="px-3 py-1.5 bg-white border border-slate-200 hover:bg-red-50 hover:text-red-600 hover:border-red-200 text-slate-600 text-xs font-bold rounded-lg transition-colors">
                                        Từ chối
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <tr>
                            <td colspan="4" class="px-6 py-16 text-center text-slate-500">
                                Không có yêu cầu nào đang chờ duyệt.
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

</body>
</html>
