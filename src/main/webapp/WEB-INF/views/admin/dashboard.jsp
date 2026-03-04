<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<fmt:setBundle basename="messages" scope="session" />

<!DOCTYPE html>
<html lang="${sessionScope.lang != null ? sessionScope.lang : 'vi'}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="admin.overview" /> - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 min-h-screen transition-all duration-300 flex flex-col">
    <header class="bg-white border-b border-slate-200 sticky top-0 z-10 px-8 py-4 flex justify-between items-center shadow-sm">
        <div>
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight"><fmt:message key="admin.overview" /></h1>
            <p class="text-sm text-slate-500 mt-1"><fmt:message key="admin.welcome" /></p>
        </div>

        <div class="flex items-center gap-3">
            <button onclick="confirmResetSeason()" class="hidden md:flex items-center gap-2 px-4 py-2 bg-red-50 text-red-600 text-xs font-bold rounded-xl border border-red-100 hover:bg-red-100 transition-colors shadow-sm">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/></svg>
                <fmt:message key="admin.end_season" />
            </button>

            <span class="hidden md:flex items-center gap-2 px-3 py-1.5 bg-emerald-50 text-emerald-700 text-xs font-bold rounded-full border border-emerald-100">
                <span class="relative flex h-2 w-2">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                </span>
                <fmt:message key="admin.system_stable" />
            </span>
            <button onclick="window.location.reload()" class="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition-colors" title="Tải lại dữ liệu">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.5 2v6h-6M2.5 22v-6h6M2 11.5a10 10 0 0 1 18.8-4.3M22 12.5a10 10 0 0 1-18.8 4.3"/></svg>
            </button>
        </div>
    </header>

    <div class="p-8 max-w-7xl mx-auto w-full space-y-8">

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            <a href="${pageContext.request.contextPath}/admin?action=items&status=PENDING" class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-amber-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider"><fmt:message key="admin.pending_items" /></p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-amber-600 transition-colors">${pendingItems}</h3>
                    </div>
                    <div class="p-3 bg-amber-50 text-amber-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    </div>
                </div>
                <div class="flex items-center gap-1 text-xs font-medium text-amber-600">
                    <span><fmt:message key="admin.urgent" /></span>
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/admin?action=stations" class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-rose-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider"><fmt:message key="admin.active_stations" /></p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-rose-600 transition-colors">${totalStations}</h3>
                    </div>
                    <div class="p-3 bg-rose-50 text-rose-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                    </div>
                </div>
                <div class="text-xs text-slate-500">Trạm thu gom hoạt động</div>
            </a>

            <a href="${pageContext.request.contextPath}/admin?action=items" class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-blue-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider"><fmt:message key="admin.total_items" /></p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-blue-600 transition-colors">${totalItems}</h3>
                    </div>
                    <div class="p-3 bg-blue-50 text-blue-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                    </div>
                </div>
                <div class="text-xs text-slate-500">Toàn bộ tin đã đăng</div>
            </a>

            <div class="group bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md hover:border-purple-200 transition-all relative overflow-hidden">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider"><fmt:message key="admin.total_points" /></p>
                        <h3 class="text-3xl font-bold text-slate-800 mt-1 group-hover:text-purple-600 transition-colors">${totalEcoPoints}</h3>
                    </div>
                    <div class="p-3 bg-purple-50 text-purple-600 rounded-xl group-hover:scale-110 transition-transform">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69l5.74 5.88-5.74 5.88-5.74-5.88z"/><path d="M12 10.31l5.74 5.88-5.74 5.88-5.74-5.88z"/></svg>
                    </div>
                </div>
                <div class="text-xs text-slate-500">Điểm thưởng đã cấp</div>
            </div>
        </div>

        <div class="bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-8 text-center relative overflow-hidden flex flex-col justify-center items-center shadow-lg">
            <div class="absolute top-0 right-0 -mr-16 -mt-16 w-64 h-64 rounded-full bg-emerald-500 opacity-20 blur-3xl"></div>
            <div class="absolute bottom-0 left-0 -ml-16 -mb-16 w-64 h-64 rounded-full bg-blue-500 opacity-20 blur-3xl"></div>

            <div class="relative z-10 max-w-2xl">
                <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/10 backdrop-blur-sm mb-6 text-emerald-400 ring-1 ring-white/20 shadow-lg">
                    <span class="text-3xl">🗺️</span>
                </div>
                <h3 class="text-2xl font-bold text-white mb-3"><fmt:message key="admin.realtime_map" /></h3>
                <p class="text-slate-300 mb-8 text-sm leading-relaxed">
                    <fmt:message key="admin.map_desc" />
                </p>
                <a href="${pageContext.request.contextPath}/home"
                   class="inline-flex items-center gap-2 px-6 py-3 bg-emerald-600 text-white font-bold rounded-xl shadow-lg hover:bg-emerald-500 hover:scale-105 transition-all duration-300 group">
                    <span><fmt:message key="admin.access_map" /></span>
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                    </svg>
                </a>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div class="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h3 class="text-lg font-bold text-slate-800"><fmt:message key="admin.transaction_stats" /></h3>
                        <p class="text-xs text-slate-400 mt-1"><fmt:message key="admin.give_trade_stats" /></p>
                    </div>
                    <div>
                        <select id="yearFilter" class="bg-white border border-slate-200 text-slate-700 text-sm rounded-xl focus:ring-emerald-500 focus:border-emerald-500 block w-full p-2.5 outline-none transition-all shadow-sm cursor-pointer font-medium">
                            <option value="all">Tất cả các năm</option>
                        </select>
                    </div>
                </div>

                <div id="echartsContainer" class="w-full h-80"></div>
            </div>

            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 flex flex-col">
                <h3 class="text-lg font-bold text-slate-800 mb-1"><fmt:message key="admin.item_categories" /></h3>
                <p class="text-xs text-slate-400 mb-6"><fmt:message key="admin.waste_distribution" /></p>

                <div class="relative h-56 w-full flex justify-center mb-4">
                    <canvas id="categoryChart"></canvas>
                </div>

                <div id="categoryLegend" class="mt-auto space-y-3 overflow-y-auto max-h-40 custom-scrollbar pr-2">
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    // --- ECharts Setup ---
    document.addEventListener("DOMContentLoaded", function() {
        var chartDom = document.getElementById('echartsContainer');
        var myChart = echarts.init(chartDom);
        var option;

        // Lấy dữ liệu từ Server
        const rawData = <%= request.getAttribute("timeSeriesDataJson") != null ? request.getAttribute("timeSeriesDataJson") : "{}" %>;

        // 1. Hàm lọc, sắp xếp dữ liệu và trích xuất các năm có trong data
        function processAndExtractYears(dataMap) {
            let yearsSet = new Set();
            let processedGive = [];
            let processedTrade = [];

            if (dataMap.GIVE) {
                processedGive = dataMap.GIVE.filter(item => item && item[0]).sort((a, b) => new Date(a[0]) - new Date(b[0]));
                processedGive.forEach(item => {
                    const year = new Date(item[0]).getFullYear();
                    if(!isNaN(year)) yearsSet.add(year);
                });
            }
            if (dataMap.TRADE) {
                processedTrade = dataMap.TRADE.filter(item => item && item[0]).sort((a, b) => new Date(a[0]) - new Date(b[0]));
                processedTrade.forEach(item => {
                    const year = new Date(item[0]).getFullYear();
                    if(!isNaN(year)) yearsSet.add(year);
                });
            }

            return {
                years: Array.from(yearsSet).sort((a,b) => b - a), // Sắp xếp năm mới nhất lên đầu
                allGive: processedGive,
                allTrade: processedTrade
            };
        }

        const { years, allGive, allTrade } = processAndExtractYears(rawData);

        // 2. Tự động đổ danh sách năm vào Dropdown
        const yearSelect = document.getElementById('yearFilter');
        years.forEach(year => {
            const opt = document.createElement('option');
            opt.value = year;
            opt.textContent = `Năm ` + year;
            yearSelect.appendChild(opt);
        });

        // 3. Cấu hình cơ bản của ECharts
        option = {
            tooltip: {
                trigger: 'axis',
                axisPointer: { type: 'line' }
            },
            legend: {
                data: ['Give', 'Trade'],
                bottom: 0
            },
            grid: {
                left: '3%', right: '4%', bottom: '15%', top: '10%', containLabel: true
            },
            xAxis: {
                type: 'time',
                boundaryGap: false,
                min: 'dataMin', // Ép trục X bắt đầu từ điểm dữ liệu đầu tiên
                max: 'dataMax', // Ép trục X kết thúc ở điểm dữ liệu cuối cùng
                axisLabel: {
                    formatter: {
                        year: '{yyyy}',
                        month: '{MMM} {yyyy}',
                        day: '{dd}/{MM}',
                        hour: '{HH}:{mm}'
                    },
                    color: '#64748b'
                },
                axisLine: { lineStyle: { color: '#e2e8f0' } }
            },
            yAxis: {
                type: 'value',
                axisLabel: { color: '#64748b' },
                splitLine: { lineStyle: { color: '#f1f5f9', type: 'dashed' } }
            },
            dataZoom: [
                { type: 'inside', xAxisIndex: 0, filterMode: 'none', start: 0, end: 100 },
                {
                    type: 'slider', xAxisIndex: 0, filterMode: 'none', start: 0, end: 100,
                    height: 20, bottom: 30,
                    handleIcon: 'path://M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
                    handleSize: '80%',
                    handleStyle: {
                        color: '#fff',
                        shadowBlur: 3,
                        shadowColor: 'rgba(0, 0, 0, 0.6)',
                        shadowOffsetX: 2,
                        shadowOffsetY: 2
                    }
                }
            ]
        };

        // Gắn cấu hình cơ bản vào Chart
        myChart.setOption(option);

        // 4. Hàm cập nhật lại đường vẽ (Series) dựa trên năm được chọn
        function updateChartByYear(selectedYear) {
            let filteredGive = allGive;
            let filteredTrade = allTrade;

            // Nếu không phải chọn "Tất cả", tiến hành lọc dữ liệu theo năm
            if (selectedYear !== 'all') {
                const yearNum = parseInt(selectedYear);
                filteredGive = allGive.filter(item => new Date(item[0]).getFullYear() === yearNum);
                filteredTrade = allTrade.filter(item => new Date(item[0]).getFullYear() === yearNum);
            }

            // Ghi đè cấu hình series để biểu đồ tự động vẽ lại
            myChart.setOption({
                series: [
                    {
                        name: 'Give', type: 'line', smooth: true,
                        showSymbol: false, symbol: 'circle', symbolSize: 6,
                        data: filteredGive,
                        itemStyle: { color: '#10b981' }, lineStyle: { width: 2 }
                    },
                    {
                        name: 'Trade', type: 'line', smooth: true,
                        showSymbol: false, symbol: 'circle', symbolSize: 6,
                        data: filteredTrade,
                        itemStyle: { color: '#f59e0b' }, lineStyle: { width: 2 }
                    }
                ]
            });
        }

        // 5. Lắng nghe sự kiện khi Admin đổi năm trong Dropdown
        yearSelect.addEventListener('change', function(e) {
            updateChartByYear(e.target.value);
        });

        // Vẽ biểu đồ lần đầu tiên (hiển thị tất cả các năm mặc định)
        updateChartByYear('all');

        // Resize chart khi đổi kích thước màn hình
        window.addEventListener('resize', function() {
            myChart.resize();
        });
    });

    // 2. Category Chart (Doughnut) - Giữ nguyên code cũ
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

    // --- Logic Reset Season ---
    async function confirmResetSeason() {
        if (!confirm("⚠️ CẢNH BÁO: Bạn có chắc chắn muốn kết thúc mùa giải hiện tại?\n\nHành động này sẽ:\n1. Lưu Top 5 vào lịch sử.\n2. Cộng thưởng cho Top 5.\n3. Reset điểm Season của TẤT CẢ user về 0.\n4. Gửi email thông báo.\n\nHành động này KHÔNG THỂ hoàn tác!")) {
            return;
        }

        try {
            const btn = document.querySelector('button[onclick="confirmResetSeason()"]');
            const originalText = btn.innerHTML;
            btn.innerHTML = 'Đang xử lý...';
            btn.disabled = true;

            const res = await fetch('${pageContext.request.contextPath}/admin/season-reset', {
                method: 'POST'
            });
            const data = await res.json();

            if (data.status === 'success') {
                alert("✅ " + data.message);
                location.reload();
            } else {
                alert("❌ Lỗi: " + data.message);
                btn.innerHTML = originalText;
                btn.disabled = false;
            }
        } catch (e) {
            console.error(e);
            alert("❌ Lỗi kết nối server!");
        }
    }
</script>

</body>
</html>