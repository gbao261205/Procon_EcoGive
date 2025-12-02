<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 min-h-screen font-sans text-slate-800">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 p-8">
    <header class="flex justify-between items-center mb-8">
        <div>
            <h1 class="text-2xl font-bold text-slate-800">Tổng quan</h1>
            <p class="text-sm text-slate-500">Chào mừng trở lại, Administrator!</p>
        </div>
        <div class="flex items-center gap-3">
                <span class="text-sm font-medium text-emerald-600 bg-emerald-50 px-3 py-1 rounded-full border border-emerald-100">
                    🟢 Hệ thống hoạt động tốt
                </span>
        </div>
    </header>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between mb-4">
                <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">👥</div>
                <span class="text-xs font-semibold text-slate-400 uppercase">Users</span>
            </div>
            <div class="text-3xl font-bold text-slate-800">${totalUsers}</div>
            <div class="text-xs text-slate-400 mt-1">Tổng thành viên</div>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between mb-4">
                <div class="p-2 bg-emerald-50 text-emerald-600 rounded-lg">📦</div>
                <span class="text-xs font-semibold text-slate-400 uppercase">Items</span>
            </div>
            <div class="text-3xl font-bold text-slate-800">${totalItems}</div>
            <div class="text-xs text-slate-400 mt-1">Vật phẩm đang có</div>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between mb-4">
                <div class="p-2 bg-amber-50 text-amber-600 rounded-lg">⏳</div>
                <span class="text-xs font-semibold text-slate-400 uppercase">Pending</span>
            </div>
            <div class="text-3xl font-bold text-slate-800">${pendingItems}</div>
            <div class="text-xs text-slate-400 mt-1">Cần duyệt gấp</div>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between mb-4">
                <div class="p-2 bg-purple-50 text-purple-600 rounded-lg">🌱</div>
                <span class="text-xs font-semibold text-slate-400 uppercase">EcoPoints</span>
            </div>
            <div class="text-3xl font-bold text-slate-800">${totalEcoPoints}</div>
            <div class="text-xs text-slate-400 mt-1">Điểm đã cấp</div>
        </div>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 p-8 text-center">
        <div class="mb-4">
            <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-emerald-100 mb-4">
                <span class="text-3xl">🗺️</span>
            </div>
            <h3 class="text-xl font-bold text-slate-800">Bản đồ Phân bố Vật phẩm</h3>
            <p class="text-slate-500 mt-2 max-w-lg mx-auto">
                Xem trực quan vị trí các vật phẩm đang được chia sẻ trên toàn thành phố để nắm bắt khu vực hoạt động sôi nổi nhất.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/home"
           class="inline-flex items-center gap-2 px-6 py-3 bg-emerald-600 text-white font-bold rounded-xl shadow-lg hover:bg-emerald-700 hover:shadow-xl transition transform hover:-translate-y-0.5">
            <span>Mở Bản Đồ Toàn Màn Hình</span>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
            </svg>
        </a>
    </div>
</main>
</body>
</html>