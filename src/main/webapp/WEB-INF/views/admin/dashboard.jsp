<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-50 min-h-screen font-sans text-slate-800">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 p-8 transition-all duration-300">
    <header class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
            <h1 class="text-3xl font-bold text-slate-800 tracking-tight">Tổng quan</h1>
            <p class="text-sm text-slate-500 mt-1">Xin chào Administrator, đây là báo cáo hôm nay.</p>
        </div>
        <div class="flex items-center gap-3">
            <span class="text-xs font-bold text-emerald-700 bg-emerald-100 px-3 py-1.5 rounded-full border border-emerald-200 flex items-center gap-2 shadow-sm">
                <span class="relative flex h-2.5 w-2.5">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-600"></span>
                </span>
                Hệ thống vận hành ổn định
            </span>
            <button class="bg-white p-2 rounded-lg border hover:bg-slate-50 text-slate-500 shadow-sm" title="Tải lại dữ liệu" onclick="window.location.reload()">
                🔄
            </button>
        </div>
    </header>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">

        <a href="${pageContext.request.contextPath}/admin?action=items&status=PENDING" class="group bg-white p-5 rounded-2xl shadow-sm border border-slate-100 hover:shadow-lg hover:border-amber-200 transition-all cursor-pointer relative overflow-hidden">
            <div class="absolute right-0 top-0 h-full w-1 bg-amber-500"></div>
            <div class="flex justify-between items-start mb-4">
                <div>
                    <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Tin chờ duyệt</span>
                    <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-amber-600 transition-colors">${pendingItems}</h3>
                </div>
                <div class="p-3 bg-amber-50 text-amber-600 rounded-xl group-hover:scale-110 transition-transform">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
            </div>
            <div class="text-xs text-slate-500 flex items-center gap-1">
                <span class="text-amber-600 font-bold">Cần xử lý ngay</span>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=stations" class="group bg-white p-5 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-all relative overflow-hidden">
            <div class="absolute right-0 top-0 h-full w-1 bg-rose-500"></div>
            <div class="flex justify-between items-start mb-4">
                <div>
                    <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Điểm tập kết</span>
                    <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-rose-600 transition-colors">${totalStations}</h3>
                </div>
                <div class="p-3 bg-rose-50 text-rose-600 rounded-xl group-hover:scale-110 transition-transform">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                </div>
            </div>
            <div class="text-xs text-slate-500">Trạm thu gom hoạt động</div>
        </a>

        <a href="${pageContext.request.contextPath}/admin?action=items" class="group bg-white p-5 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-all relative overflow-hidden">
            <div class="absolute right-0 top-0 h-full w-1 bg-blue-500"></div>
            <div class="flex justify-between items-start mb-4">
                <div>
                    <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Tổng vật phẩm</span>
                    <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-blue-600 transition-colors">${totalItems}</h3>
                </div>
                <div class="p-3 bg-blue-50 text-blue-600 rounded-xl group-hover:scale-110 transition-transform">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                </div>
            </div>
            <div class="text-xs text-slate-500">
                Toàn bộ tin đã đăng
            </div>
        </a>

        <div class="group bg-white p-5 rounded-2xl shadow-sm border border-slate-100 hover:shadow-md transition-all relative overflow-hidden">
            <div class="absolute right-0 top-0 h-full w-1 bg-purple-500"></div>
            <div class="flex justify-between items-start mb-4">
                <div>
                    <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">Tổng điểm EcoPoints</span>
                    <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-purple-600 transition-colors">${totalEcoPoints}</h3>
                </div>
                <div class="p-3 bg-purple-50 text-purple-600 rounded-xl group-hover:scale-110 transition-transform">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69l5.74 5.88-5.74 5.88-5.74-5.88z"/><path d="M12 10.31l5.74 5.88-5.74 5.88-5.74-5.88z"/></svg>
                </div>
            </div>
            <div class="text-xs text-slate-500">Tổng điểm thưởng</div>
        </div>
    </div>
    <div class="grid grid-cols-1 lg:grid-cols-1 gap-6">

        <div class="bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-8 text-center relative overflow-hidden flex flex-col justify-center items-center shadow-lg mb-8">
            <div class="absolute top-0 right-0 -mr-16 -mt-16 w-64 h-64 rounded-full bg-emerald-500 opacity-20 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 -ml-16 -mb-16 w-64 h-64 rounded-full bg-blue-500 opacity-20 blur-3xl"></div>

            <div class="relative z-10">
                <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/10 backdrop-blur-sm mb-4 text-emerald-400 ring-1 ring-white/20">
                    <span class="text-3xl">🗺️</span>
                </div>
                <h3 class="text-2xl font-bold text-white mb-2">Bản đồ</h3>
                <p class="text-slate-300 mb-6 max-w-sm mx-auto text-sm leading-relaxed">
                    Theo dõi thời gian thực vị trí các vật phẩm, điểm thu gom và hoạt động trao đổi trên toàn thành phố.
                </p>
                <a href="${pageContext.request.contextPath}/home"
                   class="inline-flex items-center gap-2 px-6 py-3 bg-emerald-600 text-white font-bold rounded-xl shadow-lg hover:bg-emerald-500 hover:scale-105 transition-all duration-300 group">
                    <span>Truy cập Bản Đồ</span>
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                    </svg>
                </a>
            </div>
        </div>
    </div>
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">

        <div class="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
            <div class="flex justify-between items-center mb-6">
                <div>
                    <h3 class="text-lg font-bold text-slate-800">Thống kê Tác động Môi trường</h3>
                    <p class="text-xs text-slate-400">Số lượng rác thải giảm thiểu (kg) theo tháng</p>
                </div>
                <select class="text-xs border rounded px-2 py-1 bg-slate-50 outline-none focus:ring-1 focus:ring-emerald-500">
                    <option>6 tháng gần đây</option>
                    <option>Năm nay</option>
                </select>
            </div>
            <div class="relative h-64 w-full">
                <canvas id="impactChart"></canvas>
            </div>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
            <h3 class="text-lg font-bold text-slate-800 mb-1">Danh mục vật phẩm</h3>
            <p class="text-xs text-slate-400 mb-6">Tỷ lệ theo vật phẩm của danh mục</p>
            <div class="relative h-48 w-full flex justify-center">
                <canvas id="categoryChart"></canvas>
            </div>
            <div id="categoryLegend" class="mt-4 space-y-2 text-xs"></div>
        </div>
    </div>


</main>

<script>
    // 1. Biểu đồ Impact (Line Chart)
    const ctxImpact = document.getElementById('impactChart').getContext('2d');
    new Chart(ctxImpact, {
        type: 'line',
        data: {
            labels: ['T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
            datasets: [{
                label: 'Rác thải giảm thiểu (kg)',
                data: [65, 80, 120, 145, 180, 250],
                borderColor: '#059669', // Emerald 600
                backgroundColor: 'rgba(5, 150, 105, 0.1)',
                tension: 0.4,
                fill: true,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#059669',
                pointBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { grid: { borderDash: [5, 5] }, beginAtZero: true },
                x: { grid: { display: false } }
            }
        }
    });

    // 2. Biểu đồ Danh mục (Doughnut Chart) - dynamic from servlet attributes
    // Read JSON arrays produced by the servlet and set as request attributes
    const categoryLabels = <%= request.getAttribute("categoryLabelsJson") != null ? request.getAttribute("categoryLabelsJson") : "[]" %>;
    const categoryData = <%= request.getAttribute("categoryDataJson") != null ? request.getAttribute("categoryDataJson") : "[]" %>;

    const ctxCategory = document.getElementById('categoryChart').getContext('2d');
    const palette = ['#10b981', '#3b82f6', '#f59e0b', '#a78bfa', '#f97316', '#06b6d4', '#ef4444'];

    new Chart(ctxCategory, {
        type: 'doughnut',
        data: {
            labels: categoryLabels,
            datasets: [{
                data: categoryData,
                backgroundColor: categoryLabels.map((_, i) => palette[i % palette.length]),
                borderWidth: 0,
                hoverOffset: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            cutout: '75%'
        }
    });

    // Render legend dynamically
    (function renderCategoryLegend(labels, data) {
        const container = document.getElementById('categoryLegend');
        container.innerHTML = '';
        if (!Array.isArray(labels) || !Array.isArray(data) || labels.length === 0) {
            container.innerHTML = '<div class="text-slate-400">Không có dữ liệu danh mục</div>';
            return;
        }
        const total = data.reduce((s, v) => s + Number(v || 0), 0) || 1;
        for (let i = 0; i < labels.length; i++) {
            const label = labels[i];
            const value = Number(data[i] || 0);
            const percentFloat = (value / total) * 100;
            // show one decimal place but if integer show without .0
            const percentStr = Number.isFinite(percentFloat) ? (Math.round(percentFloat * 10) / 10).toString().replace(/\.0$/, '') : '0';
            const color = palette[i % palette.length];

            // build a row: color dot + label on the left, count and percent on the right
            const row = document.createElement('div');
            row.className = 'flex items-center justify-between';

            const left = document.createElement('div');
            left.className = 'flex items-center gap-2 text-slate-700';
            const dot = document.createElement('span');
            dot.className = 'w-3 h-3 rounded-full inline-block';
            dot.style.background = color;
            const lbl = document.createElement('span');
            lbl.textContent = label;
            left.appendChild(dot);
            left.appendChild(lbl);

            const right = document.createElement('div');
            right.className = 'text-slate-600 font-semibold text-sm flex items-baseline gap-2';
            const countSpan = document.createElement('span');
            countSpan.className = 'mr-2';
            countSpan.textContent = value;
            const percSpan = document.createElement('span');
            percSpan.className = 'text-slate-400 text-xs';
            percSpan.textContent = percentStr + '%';

            right.appendChild(countSpan);
            right.appendChild(percSpan);

            row.appendChild(left);
            row.appendChild(right);
            container.appendChild(row);
        }
    })(categoryLabels, categoryData);
</script>

</body>
</html>
