<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ của ${profileUser.displayName != null ? profileUser.displayName : profileUser.username} - EcoGive</title>
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
        @keyframes scale-in {
            0% { transform: scale(0.9); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
        .animate-scale-in { animation: scale-in 0.2s ease-out forwards; }
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
        <h1 class="text-lg md:text-xl font-bold tracking-tight text-slate-800">EcoGive <span class="text-slate-400 font-normal text-sm ml-1 hidden md:inline">Map</span></h1>
    </a>
    <div class="flex items-center gap-4">
        <a href="${pageContext.request.contextPath}/home" class="hidden md:flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-emerald-50 hover:text-primary rounded-lg transition-all">
            <span class="material-symbols-outlined text-[20px]">map</span>
            <span>Về bản đồ</span>
        </a>
        <div class="h-6 w-px bg-slate-200 hidden md:block"></div>

        <!-- User Profile & Notifications -->
        <div class="flex items-center gap-3">
            <c:if test="${sessionScope.currentUser != null}">
                <!-- Notification Bell -->
                <div class="relative" id="noti-container">
                    <button id="noti-button" onclick="toggleNotificationDropdown()" class="w-9 h-9 md:w-10 md:h-10 rounded-full bg-slate-50 hover:bg-slate-100 text-slate-600 flex items-center justify-center transition relative">
                        <span class="material-symbols-outlined text-[22px]">notifications</span>
                        <span id="noti-badge" class="absolute top-0 right-0 w-3 h-3 bg-red-500 border-2 border-white rounded-full hidden"></span>
                    </button>

                    <!-- Notification Dropdown -->
                    <div id="noti-dropdown" class="hidden absolute right-0 mt-2 w-80 md:w-96 bg-white rounded-xl shadow-2xl border border-slate-100 z-50 origin-top-right animate-scale-in overflow-hidden">
                        <div class="px-4 py-3 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <h3 class="font-bold text-slate-800 text-sm">Thông báo</h3>
                            <button onclick="markAllRead()" class="text-xs text-primary font-bold hover:underline">Đã đọc tất cả</button>
                        </div>
                        <div id="noti-list" class="max-h-80 overflow-y-auto custom-scrollbar">
                            <!-- Notifications will be loaded here -->
                            <div class="text-center py-8 text-slate-400 text-xs">Đang tải...</div>
                        </div>
                        <div class="px-4 py-2 border-t border-slate-100 bg-slate-50 text-center">
                            <a href="${pageContext.request.contextPath}/chat" class="text-xs font-bold text-slate-500 hover:text-primary">Xem tất cả trong tin nhắn</a>
                        </div>
                    </div>
                </div>
            </c:if>

            <div class="text-right hidden sm:block">
                <div class="text-sm font-bold text-slate-800">${sessionScope.currentUser.displayName != null ? sessionScope.currentUser.displayName : sessionScope.currentUser.username}</div>
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
        <div class="absolute top-0 right-0 -mt-16 -mr-16 w-64 h-64 bg-primary-light rounded-full opacity-50 blur-3xl pointer-events-none"></div>
        <div class="relative z-10 flex flex-col md:flex-row items-center md:items-start gap-8">
            <div class="group relative">
                <div class="w-32 h-32 md:w-40 md:h-40 rounded-full bg-slate-50 flex items-center justify-center border-4 border-white shadow-lg overflow-hidden shrink-0 cursor-help transition-transform duration-300 group-hover:scale-105">
                    <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=${profileUser.username}" alt="Avatar" class="w-full h-full object-cover">
                </div>
                <div class="absolute bottom-0 left-1/2 -translate-x-1/2 translate-y-full pt-2 opacity-0 group-hover:opacity-100 transition-all duration-200 pointer-events-none z-20">
                    <div class="bg-slate-800 text-white text-xs py-1.5 px-3 rounded-lg shadow-lg whitespace-nowrap relative">
                        Avatar sinh tự động
                        <div class="absolute -top-1 left-1/2 -translate-x-1/2 w-2 h-2 bg-slate-800 rotate-45"></div>
                    </div>
                </div>
            </div>
            <div class="flex-1 text-center md:text-left space-y-4">
                <div>
                    <h1 class="text-3xl md:text-4xl font-bold text-slate-800 tracking-tight mb-1 flex items-center justify-center md:justify-start gap-2">
                        ${profileUser.displayName != null ? profileUser.displayName : profileUser.username}
                        <c:if test="${profileUser.isCompanyVerified()}">
                            <span class="material-symbols-outlined text-blue-500 text-2xl" title="Doanh nghiệp đã xác thực">verified</span>
                        </c:if>
                    </h1>
                    <p class="text-slate-500 font-medium">@${profileUser.username}</p>
                    <c:if test="${isMyProfile}">
                        <p class="text-slate-400 text-sm">${profileUser.email}</p>
                    </c:if>
                </div>
                <div class="grid grid-cols-3 gap-4 max-w-lg mx-auto md:mx-0">
                    <div class="bg-slate-50 hover:bg-white hover:shadow-md transition-all duration-300 p-4 rounded-2xl border border-slate-100 text-center group">
                        <div class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">EcoPoints</div>
                        <div class="text-xl md:text-2xl font-bold text-primary group-hover:scale-110 transition-transform duration-300 inline-block">
                            ${profileUser.ecoPoints} <span class="text-lg">🌱</span>
                        </div>
                    </div>
                    <div class="bg-slate-50 hover:bg-white hover:shadow-md transition-all duration-300 p-4 rounded-2xl border border-slate-100 text-center group">
                        <div class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Uy tín</div>
                        <div class="text-xl md:text-2xl font-bold text-blue-600 group-hover:scale-110 transition-transform duration-300 inline-block">
                            ${profileUser.reputationScore} <span class="text-lg">⭐</span>
                        </div>
                    </div>
                    <div class="bg-slate-50 hover:bg-white hover:shadow-md transition-all duration-300 p-4 rounded-2xl border border-slate-100 text-center group">
                        <div class="text-xs text-slate-400 uppercase font-bold tracking-wider mb-1">Đã tặng</div>
                        <div class="text-xl md:text-2xl font-bold text-slate-700 group-hover:scale-110 transition-transform duration-300 inline-block">
                            ${fn:length(givenItems)} <span class="text-lg">🎁</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Content Tabs -->
    <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden min-h-[500px]">
        <div class="flex border-b border-slate-100 overflow-x-auto scrollbar-hide">
            <button onclick="switchTab('given')" id="tab-given" class="flex-1 min-w-[120px] py-5 text-sm font-bold text-primary border-b-2 border-primary bg-primary-light/30 transition-all duration-200 hover:bg-primary-light/50">
                🎁 Vật phẩm đã đăng tặng <span class="ml-1 px-2 py-0.5 rounded-full bg-primary/10 text-primary text-xs">${fn:length(givenItems)}</span>
            </button>
            <c:if test="${isMyProfile}">
                <button onclick="switchTab('received')" id="tab-received" class="flex-1 min-w-[120px] py-5 text-sm font-bold text-slate-500 border-b-2 border-transparent hover:text-primary hover:bg-slate-50 transition-all duration-200">
                    📥 Vật phẩm đã nhận <span class="ml-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-xs">${fn:length(receivedItems)}</span>
                </button>
            </c:if>
            <c:if test="${profileUser.role == 'COLLECTOR_COMPANY'}">
                <button onclick="switchTab('points')" id="tab-points" class="flex-1 min-w-[120px] py-5 text-sm font-bold text-slate-500 border-b-2 border-transparent hover:text-primary hover:bg-slate-50 transition-all duration-200">
                    ♻️ Điểm tập kết <span class="ml-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-xs">${fn:length(companyPoints)}</span>
                </button>
            </c:if>
            <button onclick="switchTab('reviews')" id="tab-reviews" class="flex-1 min-w-[120px] py-5 text-sm font-bold text-slate-500 border-b-2 border-transparent hover:text-primary hover:bg-slate-50 transition-all duration-200">
                ⭐ Đánh giá <span class="ml-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-xs">${fn:length(reviews)}</span>
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
                                <c:if test="${isMyProfile}">
                                    <th class="px-6 py-4 border-b border-slate-100 text-right whitespace-nowrap">Hành động</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody class="text-sm divide-y divide-slate-100 bg-white">
                            <c:forEach var="item" items="${givenItems}">
                                <c:choose>
                                    <c:when test="${fn:startsWith(item.imageUrl, 'http')}"><c:set var="finalImgUrl" value="${item.imageUrl}" /></c:when>
                                    <c:otherwise><c:url value="/images" var="localImgUrl"><c:param name="path" value="${item.imageUrl}" /></c:url><c:set var="finalImgUrl" value="${localImgUrl}" /></c:otherwise>
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
                                    <td class="px-6 py-4 text-slate-700 font-medium whitespace-nowrap"><span class="px-2.5 py-1 rounded-lg bg-slate-100 text-xs border border-slate-200">${item.categoryName}</span></td>
                                    <td class="px-6 py-4 text-slate-500 text-xs whitespace-nowrap">
                                        <c:set var="dateStr" value="${fn:substring(item.postDate, 0, 19)}" /><c:set var="dateParts" value="${fn:split(dateStr, 'T')}" /><c:set var="ymd" value="${fn:split(dateParts[0], '-')}" />
                                        <div class="font-medium text-slate-700">${ymd[2]}/${ymd[1]}/${ymd[0]}</div>
                                        <div class="text-slate-400">${fn:substring(dateParts[1], 0, 5)}</div>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <c:choose>
                                            <c:when test="${item.status == 'PENDING'}"><span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200"><span class="w-2 h-2 rounded-full bg-amber-500 animate-pulse"></span> Chờ duyệt</span></c:when>
                                            <c:when test="${item.status == 'AVAILABLE'}"><span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200"><span class="w-2 h-2 rounded-full bg-emerald-500"></span> Đang hiển thị</span></c:when>
                                            <c:when test="${item.status == 'CONFIRMED'}"><span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-blue-50 text-blue-700 border border-blue-200"><span class="w-2 h-2 rounded-full bg-blue-500"></span> Đã chốt tặng</span></c:when>
                                            <c:when test="${item.status == 'COMPLETED'}"><span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-purple-50 text-purple-700 border border-purple-200"><span class="w-2 h-2 rounded-full bg-purple-500"></span> Hoàn thành</span></c:when>
                                            <c:when test="${item.status == 'CANCELLED'}"><span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-red-50 text-red-700 border border-red-200"><span class="w-2 h-2 rounded-full bg-red-500"></span> Đã hủy</span></c:when>
                                            <c:otherwise><span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold bg-gray-100 text-gray-600 border border-gray-200">${item.status}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <c:if test="${isMyProfile}">
                                        <td class="px-6 py-4 text-right whitespace-nowrap">
                                            <c:if test="${item.status == 'PENDING'}">
                                                <form action="${pageContext.request.contextPath}/profile" method="post" class="inline">
                                                    <input type="hidden" name="action" value="cancel-item"><input type="hidden" name="itemId" value="${item.itemId}">
                                                    <button type="submit" onclick="return confirm('Bạn muốn hủy đăng món đồ này?')" class="text-red-600 hover:text-white hover:bg-red-600 border border-red-200 hover:border-red-600 rounded-lg px-4 py-2 text-xs font-bold transition-all duration-200">Hủy yêu cầu</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${item.status == 'AVAILABLE'}">
                                                <form action="${pageContext.request.contextPath}/profile" method="post" class="inline">
                                                    <input type="hidden" name="action" value="remove-item"><input type="hidden" name="itemId" value="${item.itemId}">
                                                    <button type="submit" onclick="return confirm('Bạn muốn gỡ bài đăng này?')" class="text-orange-600 hover:text-white hover:bg-orange-600 border border-orange-200 hover:border-orange-600 rounded-lg px-4 py-2 text-xs font-bold transition-all duration-200">Gỡ bài đăng</button>
                                                </form>
                                            </c:if>
                                        </td>
                                    </c:if>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty givenItems}">
                                <tr><td colspan="5" class="text-center py-16"><div class="flex flex-col items-center justify-center text-slate-400"><span class="text-4xl mb-3">📦</span><p class="text-sm">Người dùng này chưa đăng món đồ nào.</p></div></td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB: Đồ đã nhận (chỉ hiển thị cho chủ profile) -->
            <c:if test="${isMyProfile}">
                <div id="content-received" class="hidden animate-fade-in">
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                        <c:forEach var="item" items="${receivedItems}">
                            <c:choose>
                                <c:when test="${fn:startsWith(item.imageUrl, 'http')}"><c:set var="finalImgUrl" value="${item.imageUrl}" /></c:when>
                                <c:otherwise><c:url value="/images" var="localImgUrl"><c:param name="path" value="${item.imageUrl}" /></c:url><c:set var="finalImgUrl" value="${localImgUrl}" /></c:otherwise>
                            </c:choose>
                            <div class="group bg-white border border-slate-100 rounded-2xl p-4 hover:shadow-lg hover:-translate-y-1 transition-all duration-300 relative">
                                <div class="absolute top-4 right-4 z-10"><span class="bg-emerald-500/90 backdrop-blur text-white text-[10px] font-bold px-2.5 py-1 rounded-full shadow-sm">Đã nhận</span></div>
                                <div class="h-48 bg-slate-50 rounded-xl mb-4 overflow-hidden relative">
                                    <img src="${finalImgUrl}" alt="${item.title}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.src='https://placehold.co/300x200?text=No+Image'">
                                    <div class="absolute inset-0 bg-black/5 group-hover:bg-transparent transition-colors"></div>
                                </div>
                                <h3 class="font-bold text-slate-800 text-lg truncate mb-1">${item.title}</h3>
                                <p class="text-sm text-slate-500 line-clamp-2 h-10">${item.description}</p>
                            </div>
                        </c:forEach>
                        <c:if test="${empty receivedItems}">
                            <div class="col-span-full text-center py-16 text-slate-400"><span class="text-4xl block mb-3">📥</span><p>Bạn chưa nhận món đồ nào.</p></div>
                        </c:if>
                    </div>
                </div>
            </c:if>

            <!-- TAB: Điểm tập kết (chỉ hiển thị cho doanh nghiệp) -->
            <c:if test="${profileUser.role == 'COLLECTOR_COMPANY'}">
                <div id="content-points" class="hidden animate-fade-in">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <c:forEach var="point" items="${companyPoints}">
                            <div class="bg-white border border-slate-100 rounded-2xl p-5 hover:shadow-md transition-all duration-300 flex gap-4 items-start">
                                <div class="w-12 h-12 rounded-xl bg-yellow-50 flex items-center justify-center text-yellow-600 shrink-0 border border-yellow-100">
                                    <span class="material-symbols-outlined text-2xl">recycling</span>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <h3 class="font-bold text-slate-800 text-lg mb-1 truncate">${point.name}</h3>
                                    <p class="text-sm text-slate-500 mb-2 flex items-center gap-1">
                                        <span class="material-symbols-outlined text-sm">location_on</span> ${point.address}
                                    </p>
                                    <div class="flex items-center gap-2">
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-lg text-xs font-medium bg-slate-100 text-slate-600 border border-slate-200">
                                            ${point.typeName}
                                        </span>
                                        <a href="https://www.google.com/maps/search/?api=1&query=${point.location.latitude},${point.location.longitude}" target="_blank" class="text-xs font-bold text-blue-600 hover:underline">Chỉ đường</a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty companyPoints}">
                            <div class="col-span-full text-center py-16 text-slate-400"><span class="text-4xl block mb-3">🏢</span><p>Doanh nghiệp này chưa có điểm tập kết nào.</p></div>
                        </c:if>
                    </div>
                </div>
            </c:if>

            <!-- TAB: Đánh giá -->
            <div id="content-reviews" class="hidden animate-fade-in">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <c:forEach var="rev" items="${reviews}">
                        <div class="flex gap-5 p-6 border border-slate-100 rounded-2xl bg-slate-50/50 hover:bg-white hover:shadow-md transition-all duration-300">
                            <div class="w-12 h-12 rounded-full bg-gradient-to-br from-blue-100 to-blue-50 flex items-center justify-center font-bold text-blue-600 shrink-0 uppercase text-lg border border-white shadow-sm">
                                <c:set var="revChar" value="${fn:substring(rev.reviewerName, 0, 1)}" />${fn:toUpperCase(revChar)}
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
                        <div class="col-span-full text-center py-16 text-slate-400"><span class="text-4xl block mb-3">⭐</span><p>Chưa có đánh giá nào về người dùng này.</p></div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    function switchTab(tabName) {
        const tabs = ['given', 'reviews'];
        if (${isMyProfile}) {
            tabs.push('received');
        }
        if ('${profileUser.role}' === 'COLLECTOR_COMPANY') {
            tabs.push('points');
        }

        tabs.forEach(t => {
            const content = document.getElementById('content-' + t);
            const btn = document.getElementById('tab-' + t);
            if (content) content.classList.add('hidden');
            if (btn) {
                btn.className = "flex-1 min-w-[120px] py-5 text-sm font-bold text-slate-500 border-b-2 border-transparent hover:text-primary hover:bg-slate-50 transition-all duration-200";
                const badge = btn.querySelector('span');
                if(badge) badge.className = "ml-1 px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-xs";
            }
        });

        document.getElementById('content-' + tabName).classList.remove('hidden');
        const activeBtn = document.getElementById('tab-' + tabName);
        activeBtn.className = "flex-1 min-w-[120px] py-5 text-sm font-bold text-primary border-b-2 border-primary bg-primary-light/30 transition-all duration-200";
        const activeBadge = activeBtn.querySelector('span');
        if(activeBadge) activeBadge.className = "ml-1 px-2 py-0.5 rounded-full bg-primary/10 text-primary text-xs";
    }

    // --- NOTIFICATION LOGIC ---
    document.addEventListener("DOMContentLoaded", function() {
        if (${sessionScope.currentUser != null}) {
            loadNotifications();
            setInterval(loadNotifications, 10000); // Poll every 10s
        }

        // Notification dropdown close on click outside
        const notiContainer = document.getElementById('noti-container');
        if (notiContainer) {
            window.addEventListener('click', (e) => {
                if (!notiContainer.contains(e.target)) {
                    document.getElementById('noti-dropdown').classList.add('hidden');
                }
            });
        }
    });

    function toggleNotificationDropdown() {
        const dropdown = document.getElementById('noti-dropdown');
        dropdown.classList.toggle('hidden');
    }

    async function loadNotifications() {
        try {
            const res = await fetch('${pageContext.request.contextPath}/api/notifications');
            const data = await res.json();

            const badge = document.getElementById('noti-badge');
            if (data.unreadCount > 0) {
                badge.classList.remove('hidden');
            } else {
                badge.classList.add('hidden');
            }

            const listEl = document.getElementById('noti-list');
            listEl.innerHTML = '';

            if (data.notifications.length === 0) {
                listEl.innerHTML = '<div class="text-center py-8 text-slate-400 text-xs">Không có thông báo nào</div>';
                return;
            }

            data.notifications.forEach(n => {
                const bgClass = n.isRead ? 'bg-white' : 'bg-blue-50';
                const icon = n.type === 'GIFT_REQUEST' ? 'volunteer_activism' : (n.type === 'TRADE_REQUEST' ? 'swap_horiz' : 'notifications');
                const color = n.type === 'GIFT_REQUEST' ? 'text-primary' : (n.type === 'TRADE_REQUEST' ? 'text-purple-500' : 'text-slate-500');

                const html = `
                    <div class="px-4 py-3 border-b border-slate-50 hover:bg-slate-50 transition \${bgClass} group relative">
                        <div class="flex gap-3">
                            <div class="w-8 h-8 rounded-full bg-white border border-slate-100 flex items-center justify-center shrink-0 shadow-sm">
                                <span class="material-symbols-outlined text-lg \${color}">\${icon}</span>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="text-sm text-slate-700 leading-snug">\${n.content}</p>
                                <p class="text-[10px] text-slate-400 mt-1">\${timeAgo(n.createdAt)}</p>
                            </div>
                        </div>
                        <div class="absolute top-2 right-2 hidden group-hover:flex gap-1 bg-white/80 backdrop-blur rounded-lg p-1 shadow-sm">
                            \${!n.isRead ? `<button onclick="markRead(\${n.id})" class="p-1 hover:bg-blue-100 rounded text-blue-600" title="Đã đọc"><span class="material-symbols-outlined text-[16px]">check</span></button>` : ''}
                            <button onclick="deleteNoti(\${n.id})" class="p-1 hover:bg-red-100 rounded text-red-600" title="Xóa"><span class="material-symbols-outlined text-[16px]">delete</span></button>
                        </div>
                    </div>
                `;
                listEl.insertAdjacentHTML('beforeend', html);
            });
        } catch(e) { console.error(e); }
    }

    function timeAgo(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const now = new Date();
        const seconds = Math.floor((now - date) / 1000);

        let interval = seconds / 31536000;
        if (interval > 1) return Math.floor(interval) + " năm trước";
        interval = seconds / 2592000;
        if (interval > 1) return Math.floor(interval) + " tháng trước";
        interval = seconds / 86400;
        if (interval > 1) return Math.floor(interval) + " ngày trước";
        interval = seconds / 3600;
        if (interval > 1) return Math.floor(interval) + " giờ trước";
        interval = seconds / 60;
        if (interval > 1) return Math.floor(interval) + " phút trước";
        return "vừa xong";
    }

    async function markRead(id) {
        await fetch('${pageContext.request.contextPath}/api/notifications?action=read&id=' + id, { method: 'POST' });
        loadNotifications();
    }

    async function markAllRead() {
        await fetch('${pageContext.request.contextPath}/api/notifications?action=read_all', { method: 'POST' });
        loadNotifications();
    }

    async function deleteNoti(id) {
        if(!confirm("Xóa thông báo này?")) return;
        await fetch('${pageContext.request.contextPath}/api/notifications?action=delete&id=' + id, { method: 'POST' });
        loadNotifications();
    }
</script>

</body>
</html>