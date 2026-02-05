<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ cá nhân - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <style>
        body { font-family: 'Inter', sans-serif; }
        /* Custom scrollbar for table */
        .custom-scrollbar::-webkit-scrollbar { height: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: #f1f5f9; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

        @keyframes fade-in {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-in {
            animation: fade-in 0.3s ease-out forwards;
        }
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

<!-- Header (Đồng bộ với Home) -->
<header class="bg-white shadow-sm z-30 px-4 md:px-6 h-16 flex justify-between items-center flex-shrink-0 border-b border-slate-100 sticky top-0">
    <!-- Logo Section -->
    <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 group">
        <span class="material-symbols-outlined text-primary group-hover:scale-110 transition-transform duration-300" style="font-size: 28px; md:32px;">spa</span>
        <h1 class="text-lg md:text-xl font-bold tracking-tight text-slate-800">EcoGive <span class="text-slate-400 font-normal text-sm ml-1 hidden md:inline">Map</span></h1>
    </a>

    <!-- Actions & Profile -->
    <div class="flex items-center gap-4">
        <a href="${pageContext.request.contextPath}/home" class="hidden md:flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-emerald-50 hover:text-primary rounded-lg transition-all">
            <span class="material-symbols-outlined text-[20px]">map</span>
            <span>Về bản đồ</span>
        </a>

        <div class="h-6 w-px bg-slate-200 hidden md:block"></div>

        <div class="flex items-center gap-3">
            <div class="text-right hidden sm:block">
                <div class="text-sm font-bold text-slate-800">${sessionScope.currentUser.username}</div>
                <div class="text-xs text-slate-500">Thành viên</div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center justify-center w-9 h-9 rounded-full text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all" title="Đăng xuất">
                <span class="material-symbols-outlined text-[20px]">logout</span>
            </a>
        </div>
    </div>
</header>

<main class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

    <!-- Profile Header Card -->
    <div class="bg-white rounded-3xl shadow-sm border border-slate-100 p-6 md:p-10 mb-8 relative overflow-hidden">
        <!-- Decorative background circle -->
        <div class="absolute top-0 right-0 -mt-16 -mr-16 w-64 h-64 bg-primary-light rounded-full opacity-50 blur-3xl pointer-events-none"></div>

        <div class="relative z-10 flex flex-col md:flex-row items-center md:items-start gap-8">
            <!-- Avatar Section with Tooltip -->
            <div class="group relative">
                <div class="w-32 h-32 md:w-40 md:h-40 rounded-full bg-slate-50 flex items-center justify-center border-4 border-white shadow-lg overflow-hidden shrink-0 cursor-help transition-transform duration-300 group-hover:scale-105">
                    <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=${sessionScope.currentUser.username}"
                         alt="Avatar"
                         class="w-full h-full object-cover">
                </div>
                <!-- Tooltip -->
                <div class="absolute bottom-0 left-1/2 -translate-x-1/2 translate-y-full pt-2 opacity-0 group-hover:opacity-100 transition-all duration-200 pointer-events-none z-20">
                    <div class="bg-slate-800 text-white text-xs py-1.5 px-3 rounded-lg shadow-lg whitespace-nowrap relative">
                        Avatar sinh tự động
                        <div class="absolute -top-1 left-1/2 -translate-x-1/2 w-2 h-2 bg-slate-800 rotate-45"></div>
                    </div>
                </div>
            </div>

            <!-- Info Section -->
            <div class="flex-1 text-center md:text-left space-y-4">
                <div>
                    <h1 class="text-3xl md:text-4xl font-bold text-slate-800 tracking-tight mb-1">${sessionScope.currentUser.username}</h1>
                    <p class="text-slate-500 font-medium">${sessionScope.currentUser.email}</p>
                </div>

                <!-- Stats Grid -->
                <div class="grid grid-cols-3 gap-4 max-w-lg mx-auto md:mx-0">
                    <div class="bg-slate-50 hover:bg-white hover:shadow-md transition-all duration-300 p-4 rounded-2xl border border-slate-100 text-center group">
                        <div class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">EcoPoints</div>
                        <div class="text-xl md:text-2xl font-bold text-primary group-hover:scale-110 transition-transform duration-300 inline-block">
                            ${sessionScope.currentUser.ecoPoints} <span class="text-lg">🌱</span>
                        </div>
                    </div>
                    <div class="bg-slate-50 hover:bg-white hover:shadow-md transition-all duration-300 p-4 rounded-2xl border border-slate-100 text-center group">
                        <div class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Uy tín</div>
                        <div class="text-xl md:text-2xl font-bold text-blue-600 group-hover:scale-110 transition-transform duration-300 inline-block">
                            ${sessionScope.currentUser.reputationScore} <span class="text-lg">⭐</span>
                        </div>
                    </div>
                    <div class="bg-slate-50 hover:bg-white hover:shadow-md transition-all duration-300 p-4 rounded-2xl border border-slate-100 text-center group">
                        <div class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Đã tặng</div>
                        <div class="text-xl md:text-2xl font-bold text-slate-700 group-hover:scale-110 transition-transform duration-300 inline-block">
                            ${givenItems.size()} <span class="text-lg">🎁</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Content Tabs -->
    <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden min-h-[500px]">
        <!-- Tab Navigation -->
        <div class="flex border-b border-slate-100 overflow-x-auto scrollbar-hide">
            <button onclick="switchTab('given')" id="tab-given" class="flex-1 min-w-[120px] py-5 text-sm font-bold text-primary border-b-2 border-primary bg-primary-light/30 transition-all duration-200 hover:bg-primary-light/50">
                🎁 Đồ đã tặng <span class="ml-1 px-2 py-0.5 rounded-full bg-primary/10 text-primary text-xs">${givenItems.size()}</span>
            </button>
            <button onclick="switchTab('received')" id="tab-received" class="flex-1 min-w-[120px] py-5 text-sm font-bold text-slate-500 border-b-2 border-transparent hover:text-primary hover:bg-slate-50 transition-all duration-200">
                📥 Đồ đã nhận <span class="ml-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-xs">${receivedItems.size()}</span>
            </button>
            <button onclick="switchTab('reviews')" id="tab-reviews" class="flex-1 min-w-[120px] py-5 text-sm font-bold text-slate-500 border-b-2 border-transparent hover:text-primary hover:bg-slate-50 transition-all duration-200">
                ⭐ Đánh giá <span class="ml-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-xs">${reviews.size()}</span>
            </button>
        </div>

        <div class="p-6 md:p-8">

            <!-- TAB: Đồ đã tặng -->
            <div id="content-given" class="block animate-fade-in">
                <div class="overflow-x-auto custom-scrollbar rounded-xl border border-slate-100">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-slate-50/80 backdrop-blur text-slate-500 text-xs uppercase font-bold tracking-wider">
                            <tr>
                                <th class="px-6 py-4 border-b border-slate-100">Vật phẩm</th>
                                <th class="px-6 py-4 border-b border-slate-100 whitespace-nowrap">Danh mục</th>
                                <th class="px-6 py-4 border-b border-slate-100 whitespace-nowrap">Ngày đăng</th>
                                <th class="px-6 py-4 border-b border-slate-100 whitespace-nowrap">Trạng thái</th>
                                <th class="px-6 py-4 border-b border-slate-100 text-right whitespace-nowrap">Hành động</th>
                            </tr>
                        </thead>
                        <tbody class="text-sm divide-y divide-slate-100 bg-white">
                            <c:forEach var="item" items="${givenItems}">
                                <!-- Logic ảnh -->
                                <c:choose>
                                    <c:when test="${fn:startsWith(item.imageUrl, 'http')}">
                                        <c:set var="finalImgUrl" value="${item.imageUrl}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:url value="/images" var="localImgUrl"><c:param name="path" value="${item.imageUrl}" /></c:url>
                                        <c:set var="finalImgUrl" value="${localImgUrl}" />
                                    </c:otherwise>
                                </c:choose>

                                <tr class="hover:bg-slate-50/80 transition-colors group">
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-4">
                                            <div class="h-14 w-14 rounded-xl bg-slate-100 overflow-hidden flex-shrink-0 border border-slate-200 shadow-sm group-hover:shadow transition-all">
                                                <img src="${finalImgUrl}" alt="${item.title}" class="h-full w-full object-cover" onerror="this.src='https://placehold.co/100x100?text=No+Image'">
                                            </div>
                                            <div class="min-w-[150px]">
                                                <div class="font-bold text-slate-800 text-base mb-0.5">${item.title}</div>
                                                <div class="text-xs text-slate-500 truncate max-w-[200px]">${item.description}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 text-slate-700 font-medium whitespace-nowrap">
                                        <span class="px-2.5 py-1 rounded-lg bg-slate-100 text-xs border border-slate-200">
                                            ${item.categoryName}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-slate-500 text-xs whitespace-nowrap">
                                        <c:set var="dateStr" value="${fn:substring(item.postDate, 0, 19)}" />
                                        <c:set var="dateParts" value="${fn:split(dateStr, 'T')}" />
                                        <c:set var="ymd" value="${fn:split(dateParts[0], '-')}" />
                                        <div class="font-medium text-slate-700">${ymd[2]}/${ymd[1]}/${ymd[0]}</div>
                                        <div class="text-slate-400">${fn:substring(dateParts[1], 0, 5)}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <c:choose>
                                            <c:when test="${item.status == 'PENDING'}">
                                                <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                                    <span class="w-2 h-2 rounded-full bg-amber-500 animate-pulse"></span> Chờ duyệt
                                                </span>
                                            </c:when>
                                            <c:when test="${item.status == 'AVAILABLE'}">
                                                <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                    <span class="w-2 h-2 rounded-full bg-emerald-500"></span> Đang hiển thị
                                                </span>
                                            </c:when>
                                            <c:when test="${item.status == 'CONFIRMED'}">
                                                <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-blue-50 text-blue-700 border border-blue-200">
                                                    <span class="w-2 h-2 rounded-full bg-blue-500"></span> Đã chốt tặng
                                                </span>
                                            </c:when>
                                            <c:when test="${item.status == 'COMPLETED'}">
                                                <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-purple-50 text-purple-700 border border-purple-200">
                                                    <span class="w-2 h-2 rounded-full bg-purple-500"></span> Hoàn thành
                                                </span>
                                            </c:when>
                                            <c:when test="${item.status == 'CANCELLED'}">
                                                <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-red-50 text-red-700 border border-red-200">
                                                    <span class="w-2 h-2 rounded-full bg-red-500"></span> Đã hủy
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-gray-100 text-gray-600 border border-gray-200">
                                                    ${item.status}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-6 py-4 text-right whitespace-nowrap">
                                        <c:if test="${item.status == 'PENDING'}">
                                            <form action="${pageContext.request.contextPath}/profile" method="post" class="inline">
                                                <input type="hidden" name="action" value="cancel-item">
                                                <input type="hidden" name="itemId" value="${item.itemId}">
                                                <button type="submit" onclick="return confirm('Bạn muốn hủy đăng món đồ này?')"
                                                        class="text-red-600 hover:text-white hover:bg-red-600 border border-red-200 hover:border-red-600 rounded-lg px-4 py-2 text-xs font-bold transition-all duration-200">
                                                    Hủy yêu cầu
                                                </button>
                                            </form>
                                        </c:if>
                                        <c:if test="${item.status == 'AVAILABLE'}">
                                            <form action="${pageContext.request.contextPath}/profile" method="post" class="inline">
                                                <input type="hidden" name="action" value="remove-item">
                                                <input type="hidden" name="itemId" value="${item.itemId}">
                                                <button type="submit" onclick="return confirm('Bạn muốn gỡ bài đăng này?')"
                                                        class="text-orange-600 hover:text-white hover:bg-orange-600 border border-orange-200 hover:border-orange-600 rounded-lg px-4 py-2 text-xs font-bold transition-all duration-200">
                                                    Gỡ bài đăng
                                                </button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty givenItems}">
                                <tr>
                                    <td colspan="5" class="text-center py-16">
                                        <div class="flex flex-col items-center justify-center text-slate-400">
                                            <span class="text-4xl mb-3">📦</span>
                                            <p class="text-sm">Bạn chưa đăng món đồ nào.</p>
                                            <a href="${pageContext.request.contextPath}/home" class="mt-4 text-primary font-bold hover:underline text-sm">Đăng ngay</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB: Đồ đã nhận -->
            <div id="content-received" class="hidden animate-fade-in">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    <c:forEach var="item" items="${receivedItems}">
                        <!-- Logic ảnh -->
                        <c:choose>
                            <c:when test="${fn:startsWith(item.imageUrl, 'http')}">
                                <c:set var="finalImgUrl" value="${item.imageUrl}" />
                            </c:when>
                            <c:otherwise>
                                <c:url value="/images" var="localImgUrl"><c:param name="path" value="${item.imageUrl}" /></c:url>
                                <c:set var="finalImgUrl" value="${localImgUrl}" />
                            </c:otherwise>
                        </c:choose>

                        <div class="group bg-white border border-slate-100 rounded-2xl p-4 hover:shadow-lg hover:-translate-y-1 transition-all duration-300 relative">
                            <div class="absolute top-4 right-4 z-10">
                                <span class="bg-emerald-500/90 backdrop-blur text-white text-[10px] font-bold px-2.5 py-1 rounded-full shadow-sm">Đã nhận</span>
                            </div>
                            <div class="h-48 bg-slate-50 rounded-xl mb-4 overflow-hidden relative">
                                <img src="${finalImgUrl}" alt="${item.title}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.src='https://placehold.co/300x200?text=No+Image'">
                                <div class="absolute inset-0 bg-black/5 group-hover:bg-transparent transition-colors"></div>
                            </div>
                            <h3 class="font-bold text-slate-800 text-lg truncate mb-1">${item.title}</h3>
                            <p class="text-sm text-slate-500 line-clamp-2 h-10">${item.description}</p>
                        </div>
                    </c:forEach>
                    <c:if test="${empty receivedItems}">
                        <div class="col-span-full text-center py-16 text-slate-400">
                            <span class="text-4xl block mb-3">📥</span>
                            <p>Bạn chưa nhận món đồ nào.</p>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- TAB: Đánh giá -->
            <div id="content-reviews" class="hidden animate-fade-in">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <c:forEach var="rev" items="${reviews}">
                        <div class="flex gap-5 p-6 border border-slate-100 rounded-2xl bg-slate-50/50 hover:bg-white hover:shadow-md transition-all duration-300">
                            <div class="w-12 h-12 rounded-full bg-gradient-to-br from-blue-100 to-blue-50 flex items-center justify-center font-bold text-blue-600 shrink-0 uppercase text-lg border border-white shadow-sm">
                                <c:set var="revChar" value="${fn:substring(rev.reviewerName, 0, 1)}" />
                                ${fn:toUpperCase(revChar)}
                            </div>
                            <div class="flex-1">
                                <div class="flex justify-between items-start mb-2">
                                    <div>
                                        <div class="font-bold text-slate-800">${rev.reviewerName}</div>
                                        <div class="text-xs text-slate-400 mt-0.5"><fmt:formatDate value="${rev.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                    </div>
                                    <div class="flex text-yellow-400 text-sm bg-yellow-50 px-2 py-1 rounded-lg border border-yellow-100">
                                        <c:forEach begin="1" end="${rev.rating}">⭐</c:forEach>
                                    </div>
                                </div>
                                <p class="text-sm text-slate-600 leading-relaxed italic">"${rev.comment}"</p>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty reviews}">
                        <div class="col-span-full text-center py-16 text-slate-400">
                            <span class="text-4xl block mb-3">⭐</span>
                            <p>Chưa có đánh giá nào về bạn.</p>
                        </div>
                    </c:if>
                </div>
            </div>

        </div>
    </div>
</main>

<script>
    function switchTab(tabName) {
        // 1. Ẩn tất cả nội dung
        ['given', 'received', 'reviews'].forEach(t => {
            document.getElementById('content-' + t).classList.add('hidden');

            // Reset style nút bấm
            const btn = document.getElementById('tab-' + t);
            btn.className = "flex-1 min-w-[120px] py-5 text-sm font-bold text-slate-500 border-b-2 border-transparent hover:text-primary hover:bg-slate-50 transition-all duration-200";

            // Reset badge style (optional, if needed)
            const badge = btn.querySelector('span');
            if(badge) badge.className = "ml-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-xs";
        });

        // 2. Hiện nội dung được chọn
        document.getElementById('content-' + tabName).classList.remove('hidden');

        // 3. Active nút bấm
        const activeBtn = document.getElementById('tab-' + tabName);
        activeBtn.className = "flex-1 min-w-[120px] py-5 text-sm font-bold text-primary border-b-2 border-primary bg-primary-light/30 transition-all duration-200";

        // Active badge
        const activeBadge = activeBtn.querySelector('span');
        if(activeBadge) activeBadge.className = "ml-1 px-2 py-0.5 rounded-full bg-primary/10 text-primary text-xs";
    }
</script>

</body>
</html>