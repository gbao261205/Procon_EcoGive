<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đổi Quà - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <style>
        body { font-family: 'Inter', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { height: 6px; width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: #f1f5f9; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
        @keyframes fade-in {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-in { animation: fade-in 0.3s ease-out forwards; }
    </style>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                        'primary-light': '#e6fcf5',
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-slate-50 min-h-screen text-slate-600">

<!-- Header -->
<header class="bg-white shadow-sm z-30 px-4 md:px-6 h-16 flex justify-between items-center flex-shrink-0 border-b border-slate-100 sticky top-0">
    <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 group">
        <span class="material-symbols-outlined text-primary group-hover:scale-110 transition-transform duration-300" style="font-size: 28px; md:32px;">spa</span>
        <h1 class="text-lg md:text-xl font-bold tracking-tight text-slate-800">EcoGive <span class="text-slate-400 font-normal text-sm ml-1 hidden md:inline">Redeem</span></h1>
    </a>
    <div class="flex items-center gap-4">
        <a href="${pageContext.request.contextPath}/home" class="hidden md:flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-emerald-50 hover:text-primary rounded-lg transition-all">
            <span class="material-symbols-outlined text-[20px]">map</span>
            <span>Về bản đồ</span>
        </a>
        <div class="h-6 w-px bg-slate-200 hidden md:block"></div>

        <!-- User Profile -->
        <div class="flex items-center gap-3">
            <div class="text-right hidden sm:block">
                <div class="text-sm font-bold text-slate-800">${sessionScope.currentUser.displayName != null ? sessionScope.currentUser.displayName : sessionScope.currentUser.username}</div>
                <div class="text-xs text-primary font-bold flex items-center justify-end gap-1">
                    <span class="material-symbols-outlined text-[14px]">eco</span>
                    ${sessionScope.currentUser.seasonPoints} EcoPoints
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/profile" class="w-9 h-9 md:w-10 md:h-10 rounded-full bg-slate-100 overflow-hidden border border-slate-200 hover:border-primary transition-colors">
                <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=${sessionScope.currentUser.username}" alt="Avatar" class="w-full h-full object-cover">
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center justify-center w-9 h-9 rounded-full text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all" title="Đăng xuất">
                <span class="material-symbols-outlined text-[20px]">logout</span>
            </a>
        </div>
    </div>
</header>

<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

    <!-- Hero Section -->
    <div class="bg-gradient-to-r from-emerald-600 to-teal-500 rounded-3xl shadow-lg p-8 md:p-12 mb-10 text-white relative overflow-hidden">
        <div class="absolute top-0 right-0 -mt-10 -mr-10 w-64 h-64 bg-white opacity-10 rounded-full blur-3xl pointer-events-none"></div>
        <div class="relative z-10 max-w-2xl">
            <h1 class="text-3xl md:text-5xl font-bold mb-4 tracking-tight">Đổi điểm lấy quà xanh 🌱</h1>
            <p class="text-emerald-100 text-lg mb-8">Sử dụng EcoPoints tích lũy từ việc tái chế để đổi lấy những phần quà hấp dẫn và thân thiện với môi trường.</p>

            <div class="flex flex-wrap gap-4">
                <div class="bg-white/20 backdrop-blur-sm rounded-xl p-4 border border-white/30 flex items-center gap-3 min-w-[180px]">
                    <div class="w-10 h-10 rounded-full bg-white text-emerald-600 flex items-center justify-center font-bold text-xl shadow-sm">
                        <span class="material-symbols-outlined">eco</span>
                    </div>
                    <div>
                        <div class="text-xs text-emerald-100 uppercase font-bold">Điểm khả dụng</div>
                        <div class="text-2xl font-bold">${sessionScope.currentUser.currentPoints}</div>
                    </div>
                </div>

                <div class="bg-white/20 backdrop-blur-sm rounded-xl p-4 border border-white/30 flex items-center gap-3 min-w-[180px]">
                    <div class="w-10 h-10 rounded-full bg-white text-yellow-600 flex items-center justify-center font-bold text-xl shadow-sm">
                        <span class="material-symbols-outlined">military_tech</span>
                    </div>
                    <div>
                        <div class="text-xs text-emerald-100 uppercase font-bold">Hạng thành viên</div>
                        <div class="text-2xl font-bold">${sessionScope.currentUser.tier}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Filters & Search -->
    <div class="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
        <h2 class="text-2xl font-bold text-slate-800 flex items-center gap-2">
            <span class="material-symbols-outlined text-primary">redeem</span>
            Danh sách quà tặng
        </h2>
        <div class="flex gap-3 w-full md:w-auto">
            <div class="relative flex-1 md:w-64">
                <span class="absolute left-3 top-2.5 text-slate-400 material-symbols-outlined text-lg">search</span>
                <input type="text" placeholder="Tìm kiếm quà..." class="w-full pl-10 pr-4 py-2 rounded-xl border border-slate-200 focus:ring-2 focus:ring-primary outline-none text-sm">
            </div>
            <select class="px-4 py-2 rounded-xl border border-slate-200 bg-white text-sm font-medium text-slate-600 focus:ring-2 focus:ring-primary outline-none cursor-pointer">
                <option value="all">Tất cả loại quà</option>
                <option value="voucher">Voucher giảm giá</option>
                <option value="product">Sản phẩm xanh</option>
                <option value="donation">Quyên góp từ thiện</option>
            </select>
        </div>
    </div>

    <!-- Rewards Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        <c:forEach var="reward" items="${rewards}">
            <div class="bg-white rounded-2xl border border-slate-100 shadow-sm hover:shadow-lg hover:-translate-y-1 transition-all duration-300 overflow-hidden group flex flex-col h-full animate-fade-in">
                <!-- Image -->
                <div class="h-48 bg-slate-50 relative overflow-hidden">
                    <img src="${reward.imageUrl}" alt="${reward.name}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" onerror="this.src='https://placehold.co/400x300?text=No+Image'">
                    <div class="absolute top-3 right-3 bg-white/90 backdrop-blur px-2.5 py-1 rounded-lg text-xs font-bold text-slate-700 shadow-sm border border-slate-100">
                        Còn ${reward.stock}
                    </div>
                    <c:if test="${reward.type == 'SPONSOR'}">
                        <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-3 pt-8">
                            <div class="text-[10px] text-white font-medium flex items-center gap-1">
                                <span class="material-symbols-outlined text-[14px]">verified</span>
                                Tài trợ bởi ${reward.sponsorName}
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- Content -->
                <div class="p-5 flex-1 flex flex-col">
                    <div class="flex justify-between items-start mb-2">
                        <h3 class="font-bold text-slate-800 text-lg line-clamp-1" title="${reward.name}">${reward.name}</h3>
                    </div>
                    <p class="text-sm text-slate-500 line-clamp-2 mb-4 flex-1">${reward.description}</p>

                    <div class="mt-auto pt-4 border-t border-slate-50 flex items-center justify-between gap-3">
                        <div class="font-bold text-primary text-lg flex items-center gap-1">
                            <span class="material-symbols-outlined">eco</span>
                            ${reward.pointCost}
                        </div>
                        <button onclick="confirmRedeem(${reward.rewardId}, '${reward.name}', ${reward.pointCost})"
                                class="px-4 py-2 bg-primary text-white text-sm font-bold rounded-xl hover:bg-primary-hover transition shadow-md shadow-emerald-100 disabled:opacity-50 disabled:cursor-not-allowed"
                                ${reward.stock <= 0 || sessionScope.currentUser.currentPoints < reward.pointCost ? 'disabled' : ''}>
                            ${reward.stock <= 0 ? 'Hết hàng' : 'Đổi ngay'}
                        </button>
                    </div>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty rewards}">
            <div class="col-span-full text-center py-20">
                <div class="w-20 h-20 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-4 text-slate-400">
                    <span class="material-symbols-outlined text-4xl">inventory_2</span>
                </div>
                <h3 class="text-lg font-bold text-slate-700">Chưa có quà tặng nào</h3>
                <p class="text-slate-500 text-sm">Hãy quay lại sau nhé!</p>
            </div>
        </c:if>
    </div>

</main>

<!-- Confirm Modal -->
<div id="confirmModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
    <div class="bg-white rounded-2xl w-full max-w-sm shadow-2xl p-6 text-center animate-fade-in relative">
        <button onclick="closeModal()" class="absolute top-4 right-4 text-slate-400 hover:text-slate-600 transition">
            <span class="material-symbols-outlined">close</span>
        </button>

        <div class="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto mb-4 text-3xl">
            <span class="material-symbols-outlined">redeem</span>
        </div>

        <h3 class="text-xl font-bold text-slate-800 mb-2">Xác nhận đổi quà?</h3>
        <p class="text-slate-500 text-sm mb-6">Bạn sẽ dùng <span class="font-bold text-primary" id="modalCost">0</span> EcoPoints để đổi lấy <span class="font-bold text-slate-700" id="modalName">...</span>.</p>

        <div class="flex gap-3">
            <button onclick="closeModal()" class="flex-1 py-2.5 border border-slate-200 rounded-xl text-slate-600 font-bold hover:bg-slate-50 transition">Hủy</button>
            <button onclick="processRedeem()" class="flex-1 py-2.5 bg-primary text-white rounded-xl font-bold hover:bg-primary-hover transition shadow-lg shadow-emerald-100">Xác nhận</button>
        </div>
    </div>
</div>

<script>
    let selectedRewardId = null;

    function confirmRedeem(id, name, cost) {
        selectedRewardId = id;
        document.getElementById('modalName').innerText = name;
        document.getElementById('modalCost').innerText = cost;
        document.getElementById('confirmModal').classList.remove('hidden');
    }

    function closeModal() {
        document.getElementById('confirmModal').classList.add('hidden');
        selectedRewardId = null;
    }

    async function processRedeem() {
        if (!selectedRewardId) return;

        const btn = document.querySelector('#confirmModal button:last-child');
        const originalText = btn.innerText;
        btn.innerText = "Đang xử lý...";
        btn.disabled = true;

        try {
            const formData = new URLSearchParams();
            formData.append('rewardId', selectedRewardId);

            const res = await fetch('${pageContext.request.contextPath}/redeem', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            });

            const data = await res.json();

            if (data.status === 'success') {
                alert("🎉 " + data.message);
                location.reload();
            } else {
                alert("❌ Lỗi: " + data.message);
                btn.innerText = originalText;
                btn.disabled = false;
                closeModal();
            }
        } catch (e) {
            console.error(e);
            alert("Lỗi kết nối server!");
            btn.innerText = originalText;
            btn.disabled = false;
        }
    }
</script>

</body>
</html>
