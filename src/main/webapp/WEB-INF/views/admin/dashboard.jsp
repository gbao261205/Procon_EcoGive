<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng quan - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight">Tổng quan</h1>
            <p class="text-sm text-slate-500 mt-1">Xin chào Administrator, đây là báo cáo hôm nay.</p>
        </div>
        <div class="flex items-center gap-3">
            <span class="hidden md:flex items-center gap-2 px-3 py-1.5 bg-emerald-50 text-emerald-700 text-xs font-bold rounded-full border border-emerald-100">
                <span class="relative flex h-2 w-2">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                </span>
                Hệ thống ổn định
            </span>
            <button onclick="window.location.reload()" class="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition-colors" title="Tải lại dữ liệu">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M2.5 22v-6h6M2 11.5a10 10 0 0 1 18.8-4.3M22 12.5a10 10 0 0 1-18.8 4.3"/></svg>
            </button>
        </div>
    </header>

    <div class="p-8 max-w-7xl mx-auto w-full space-y-8">

        <!-- Stats Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            <!-- Card 1: Pending Items -->
            <a href="${pageContext.request.contextPath}/admin?action=items&status=PENDING" class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-amber-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Tin chờ duyệt</p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-amber-600 transition-colors">${pendingItems}</h3>
                    </div>
                    <div class="p-3 bg-amber-50 text-amber-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    </div>
                </div>
                <div class="flex items-center gap-1 text-xs font-medium text-amber-600">
                    <span>Cần xử lý ngay</span>
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                </div>
            </a>

            <!-- Card 2: Stations -->
            <a href="${pageContext.request.contextPath}/admin?action=stations" class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-rose-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Điểm tập kết</p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-rose-600 transition-colors">${totalStations}</h3>
                    </div>
                    <div class="p-3 bg-rose-50 text-rose-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                    </div>
                </div>
                <div class="text-xs text-slate-500">Trạm thu gom hoạt động</div>
            </a>

            <!-- Card 3: Total Items -->
            <a href="${pageContext.request.contextPath}/admin?action=items" class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-blue-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Tổng vật phẩm</p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-blue-600 transition-colors">${totalItems}</h3>
                    </div>
                    <div class="p-3 bg-blue-50 text-blue-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                    </div>
                </div>
                <div class="text-xs text-slate-500">Toàn bộ tin đã đăng</div>
            </a>

            <!-- Card 4: EcoPoints -->
            <div class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-purple-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Tổng EcoPoints</p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-purple-600 transition-colors">${totalEcoPoints}</h3>
                    </div>
                    <div class="p-3 bg-purple-50 text-purple-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69l5.74 5.88-5.74 5.88-5.74-5.88z"/><path d="M12 10.31l5.74 5.88-5.74 5.88-5.74-5.88z"/></svg>
                    </div>
                </div>
                <div class="text-xs text-slate-500">Điểm thưởng đã cấp</div>
            </div>
        </div>

        <!-- Map Banner -->
        <div class="bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-8 text-center relative overflow-hidden flex flex-col justify-center items-center shadow-lg">
            <div class="absolute top-0 right-0 -mr-16 -mt-16 w-64 h-64 rounded-full bg-emerald-500 opacity-20 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 -ml-16 -mb-16 w-64 h-64 rounded-full bg-blue-500 opacity-20 blur-3xl"></div>

            <div class="relative z-10 max-w-2xl">
                <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/10 backdrop-blur-sm mb-6 text-emerald-400 ring-1 ring-white/20 shadow-lg">
                    <span class="text-3xl">🗺️</span>
                </div>
                <h3 class="text-2xl font-bold text-white mb-3">Bản đồ Thời gian thực</h3>
                <p class="text-slate-300 mb-8 text-sm leading-relaxed">
                    Theo dõi vị trí các vật phẩm, điểm thu gom và hoạt động trao đổi đang diễn ra trên toàn thành phố.
                    Giúp bạn có cái nhìn tổng quan về mạng lưới EcoGive.
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

        <!-- Charts Section -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- Impact Chart -->
            <div class="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h3 class="text-lg font-bold text-slate-800">Tác động Môi trường</h3>
                        <p class="text-xs text-slate-400 mt-1">Lượng rác thải giảm thiểu (kg) theo tháng</p>
                    </div>
                    <select class="text-xs font-medium border border-slate-200 rounded-lg px-3 py-1.5 bg-slate-50 outline-none focus:ring-2 focus:ring-emerald-500 text-slate-600">
                        <option>6 tháng gần đây</option>
                        <option>Năm nay</option>
                    </select>
                </div>
                <div class="relative h-72 w-full">
                    <canvas id="impactChart"></canvas>
                </div>
            </div>

            <!-- Category Chart -->
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 flex flex-col">
                <h3 class="text-lg font-bold text-slate-800 mb-1">Danh mục vật phẩm</h3>
                <p class="text-xs text-slate-400 mb-6">Tỷ lệ phân bố theo loại rác thải</p>

                <div class="relative h-56 w-full flex justify-center mb-4">
                    <canvas id="categoryChart"></canvas>
                </div>

                <div id="categoryLegend" class="mt-auto space-y-3 overflow-y-auto max-h-40 custom-scrollbar pr-2">
                    <!-- Legend items injected by JS -->
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    // 1. Impact Chart (Line)
    const ctxImpact = document.getElementById('impactChart').getContext('2d');
    new Chart(ctxImpact, {
        type: 'line',
        data: {
            labels: ['T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
            datasets: [{
                label: 'Rác thải giảm thiểu (kg)',
                data: [65, 80, 120, 145, 180, 250],
                borderColor: '#059669', // Emerald 600
                backgroundColor: (context) => {
                    const ctx = context.chart.ctx;
                    const gradient = ctx.createLinearGradient(0, 0, 0, 300);
                    gradient.addColorStop(0, 'rgba(5, 150, 105, 0.2)');
                    gradient.addColorStop(1, 'rgba(5, 150, 105, 0)');
                    return gradient;
                },
                tension: 0.4,
                fill: true,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#059669',
                pointBorderWidth: 2,
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#1e293b',
                    padding: 12,
                    titleFont: { size: 13 },
                    bodyFont: { size: 13 },
                    cornerRadius: 8,
                    displayColors: false
                }
            },
            scales: {
                y: {
                    grid: { borderDash: [4, 4], color: '#f1f5f9' },
                    beginAtZero: true,
                    ticks: { font: { size: 11 }, color: '#64748b' }
                },
                x: {
                    grid: { display: false },
                    ticks: { font: { size: 11 }, color: '#64748b' }
                }
            }
        }
    });

    // 2. Category Chart (Doughnut)
    const categoryLabels = <%= request.getAttribute("categoryLabelsJson") != null ? request.getAttribute("categoryLabelsJson") : "[]" %>;
    const categoryData = <%= request.getAttribute("categoryDataJson") != null ? request.getAttribute("categoryDataJson") : "[]" %>;

    const ctxCategory = document.getElementById('categoryChart').getContext('2d');
    const palette = ['#10b981', '#3b82f6', '#f59e0b', '#8b5cf6', '#f97316', '#06b6d4', '#ef4444'];

    new Chart(ctxCategory, {
        type: 'doughnut',
        data: {
            labels: categoryLabels,
            datasets: [{
                data: categoryData,
                backgroundColor: categoryLabels.map((_, i) => palette[i % palette.length]),
                borderWidth: 0,
                hoverOffset: 10
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            cutout: '75%',
            layout: { padding: 10 }
        }
    });

    // Custom Legend
    (function renderCategoryLegend(labels, data) {
        const container = document.getElementById('categoryLegend');
        container.innerHTML = '';
        if (!Array.isArray(labels) || !Array.isArray(data) || labels.length === 0) {
            container.innerHTML = '<div class="text-slate-400 text-center text-xs py-4">Chưa có dữ liệu danh mục</div>';
            return;
        }
        const total = data.reduce((s, v) => s + Number(v || 0), 0) || 1;

        labels.forEach((label, i) => {
            const value = Number(data[i] || 0);
            const percent = ((value / total) * 100).toFixed(1).replace(/\.0$/, '');
            const color = palette[i % palette.length];

            const row = document.createElement('div');
            row.className = 'flex items-center justify-between text-sm';
            row.innerHTML = `
                <div class="flex items-center gap-2.5">
                    <span class="w-3 h-3 rounded-full" style="background-color: \${color}"></span>
                    <span class="text-slate-600 font-medium truncate max-w-[120px]">\${label}</span>
                </div>
                <div class="flex items-baseline gap-2">
                    <span class="font-bold text-slate-800">\${value}</span>
                    <span class="text-xs text-slate-400">\${percent}%</span>
                </div>
            `;
            container.appendChild(row);
        });
    })(categoryLabels, categoryData);
</script>

</body>
</html>