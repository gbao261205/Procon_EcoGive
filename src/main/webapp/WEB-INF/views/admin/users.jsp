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

<div class="flex-1 md:ml-64 p-8">
    <h1 class="text-2xl font-bold text-gray-800 mb-6">Danh sách Người dùng</h1>

    <div class="bg-white rounded-lg shadow-md overflow-hidden">
        <table class="w-full text-left border-collapse">
            <thead class="bg-slate-100 text-slate-600 uppercase text-sm font-semibold">
            <tr>
                <th class="px-6 py-3 border-b">ID</th>
                <th class="px-6 py-3 border-b">Username</th>
                <th class="px-6 py-3 border-b">Email</th>
                <th class="px-6 py-3 border-b">Điểm Eco</th>
                <th class="px-6 py-3 border-b">Uy tín</th>
                <th class="px-6 py-3 border-b">Ngày tham gia</th>
            </tr>
            </thead>
            <tbody class="text-gray-700">
            <c:forEach var="u" items="${users}">
                <tr class="border-b hover:bg-slate-50">
                    <td class="px-6 py-4">#${u.userId}</td>
                    <td class="px-6 py-4 font-medium flex items-center gap-2">
                        <img src="https://ui-avatars.com/api/?name=${u.username}&background=random" class="w-8 h-8 rounded-full">
                            ${u.username}
                    </td>
                    <td class="px-6 py-4 text-gray-500">${u.email}</td>
                    <td class="px-6 py-4 text-green-600 font-bold">${u.ecoPoints}</td>
                    <td class="px-6 py-4">
                                <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-0.5 rounded">
                                    ${u.reputationScore} / 5.0
                                </span>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500">${u.joinDate}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>