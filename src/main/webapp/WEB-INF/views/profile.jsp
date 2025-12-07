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
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-slate-50 min-h-screen">

<header class="bg-white shadow-sm px-6 py-4 flex justify-between items-center">
    <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 text-emerald-600 font-bold text-xl hover:opacity-80">
        <span>⬅</span> Về bản đồ
    </a>
    <div class="flex items-center gap-4">
        <span class="text-sm font-bold text-slate-700">${sessionScope.currentUser.username}</span>
        <a href="${pageContext.request.contextPath}/logout" class="text-sm text-red-500 hover:underline">Đăng xuất</a>
    </div>
</header>

<main class="max-w-5xl mx-auto p-6">

    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-8 mb-8 flex flex-col md:flex-row items-center md:items-start gap-8">
        <div class="w-32 h-32 rounded-full bg-emerald-100 flex items-center justify-center text-4xl font-bold text-emerald-600 border-4 border-white shadow-lg">
            <c:set var="firstChar" value="${fn:substring(sessionScope.currentUser.username, 0, 1)}" />
            ${not empty firstChar ? fn:toUpperCase(firstChar) : '?'}
        </div>

        <div class="flex-1 text-center md:text-left">
            <h1 class="text-3xl font-bold text-slate-800 mb-2">${sessionScope.currentUser.username}</h1>
            <p class="text-slate-500 text-sm mb-6">${sessionScope.currentUser.email}</p>

            <div class="flex flex-wrap justify-center md:justify-start gap-4">
                <div class="bg-slate-50 px-5 py-3 rounded-xl border border-slate-100">
                    <div class="text-xs text-slate-400 uppercase font-bold">EcoPoints</div>
                    <div class="text-xl font-bold text-emerald-600">${sessionScope.currentUser.ecoPoints} 🌱</div>
                </div>
                <div class="bg-slate-50 px-5 py-3 rounded-xl border border-slate-100">
                    <div class="text-xs text-slate-400 uppercase font-bold">Uy tín</div>
                    <div class="text-xl font-bold text-blue-600">${sessionScope.currentUser.reputationScore} ⭐</div>
                </div>
                <div class="bg-slate-50 px-5 py-3 rounded-xl border border-slate-100">
                    <div class="text-xs text-slate-400 uppercase font-bold">Đã tặng</div>
                    <div class="text-xl font-bold text-slate-700">${givenItems.size()} món</div>
                </div>
            </div>
        </div>

        <button class="px-4 py-2 border border-slate-300 rounded-lg text-sm font-bold text-slate-600 hover:bg-slate-50 transition">
            ✏️ Sửa hồ sơ
        </button>
    </div>

    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden min-h-[400px]">
        <div class="flex border-b border-slate-100">
            <button onclick="switchTab('given')" id="tab-given" class="flex-1 py-4 text-sm font-bold text-emerald-600 border-b-2 border-emerald-600 bg-emerald-50 transition-colors">
                🎁 Đồ đã tặng (${givenItems.size()})
            </button>
            <button onclick="switchTab('received')" id="tab-received" class="flex-1 py-4 text-sm font-bold text-slate-500 hover:text-emerald-600 hover:bg-slate-50 transition-colors">
                📥 Đồ đã nhận (${receivedItems.size()})
            </button>
            <button onclick="switchTab('reviews')" id="tab-reviews" class="flex-1 py-4 text-sm font-bold text-slate-500 hover:text-emerald-600 hover:bg-slate-50 transition-colors">
                ⭐ Đánh giá (${reviews.size()})
            </button>
        </div>

        <div class="p-6">

            <div id="content-given" class="block">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <c:forEach var="item" items="${givenItems}">
                        <div class="border border-slate-100 rounded-lg p-3 hover:shadow-md transition">
                            <div class="h-32 bg-slate-100 rounded-md mb-3 overflow-hidden">
                                <c:url value="/images" var="imgSrc"><c:param name="path" value="${item.imageUrl}" /></c:url>
                                <img src="${imgSrc}" class="w-full h-full object-cover" onerror="this.src='https://placehold.co/200x150'">
                            </div>
                            <h3 class="font-bold text-slate-800 truncate">${item.title}</h3>
                            <div class="flex justify-between items-center mt-2">
                                <span class="text-xs text-slate-500">${item.postDate}</span>
                                <span class="text-[10px] font-bold px-2 py-1 rounded-full
                                        ${item.status == 'AVAILABLE' ? 'bg-green-100 text-green-700' :
                                         (item.status == 'CONFIRMED' ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-700')}">
                                        ${item.status}
                                </span>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty givenItems}"><p class="text-slate-400 italic col-span-3 text-center py-10">Bạn chưa tặng món đồ nào.</p></c:if>
                </div>
            </div>

            <div id="content-received" class="hidden">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <c:forEach var="item" items="${receivedItems}">
                        <div class="border border-slate-100 rounded-lg p-3 hover:shadow-md transition relative">
                            <div class="absolute top-2 right-2 bg-emerald-500 text-white text-[10px] font-bold px-2 py-1 rounded shadow">Đã nhận</div>
                            <div class="h-32 bg-slate-100 rounded-md mb-3 overflow-hidden">
                                <c:url value="/images" var="imgSrc"><c:param name="path" value="${item.imageUrl}" /></c:url>
                                <img src="${imgSrc}" class="w-full h-full object-cover" onerror="this.src='https://placehold.co/200x150'">
                            </div>
                            <h3 class="font-bold text-slate-800 truncate">${item.title}</h3>
                            <p class="text-xs text-slate-500 mt-1 truncate">${item.description}</p>
                        </div>
                    </c:forEach>
                    <c:if test="${empty receivedItems}"><p class="text-slate-400 italic col-span-3 text-center py-10">Bạn chưa nhận món đồ nào.</p></c:if>
                </div>
            </div>

            <div id="content-reviews" class="hidden space-y-4">
                <c:forEach var="rev" items="${reviews}">
                    <div class="flex gap-4 p-4 border border-slate-100 rounded-xl bg-slate-50">
                        <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center font-bold text-blue-600 shrink-0">
                                ${rev.reviewerName.charAt(0).toUpperCase()}
                        </div>
                        <div>
                            <div class="flex items-center gap-2 mb-1">
                                <span class="font-bold text-slate-700">${rev.reviewerName}</span>
                                <span class="text-xs text-slate-400">• ${rev.createdAt}</span>
                            </div>
                            <div class="text-yellow-500 text-sm mb-1">
                                <c:forEach begin="1" end="${rev.rating}">⭐</c:forEach>
                            </div>
                            <p class="text-sm text-slate-600">"${rev.comment}"</p>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty reviews}"><p class="text-slate-400 italic text-center py-10">Chưa có đánh giá nào về bạn.</p></c:if>
            </div>

        </div>
    </div>
</main>

<script>
    // Logic chuyển Tab đơn giản
    function switchTab(tabName) {
        // 1. Ẩn tất cả nội dung
        ['given', 'received', 'reviews'].forEach(t => {
            document.getElementById('content-' + t).classList.add('hidden');

            // Reset style nút bấm
            const btn = document.getElementById('tab-' + t);
            btn.className = "flex-1 py-4 text-sm font-bold text-slate-500 hover:text-emerald-600 hover:bg-slate-50 transition-colors";
        });

        // 2. Hiện nội dung được chọn
        document.getElementById('content-' + tabName).classList.remove('hidden');

        // 3. Active nút bấm
        const activeBtn = document.getElementById('tab-' + tabName);
        activeBtn.className = "flex-1 py-4 text-sm font-bold text-emerald-600 border-b-2 border-emerald-600 bg-emerald-50 transition-colors";
    }
</script>
</body>
</html>