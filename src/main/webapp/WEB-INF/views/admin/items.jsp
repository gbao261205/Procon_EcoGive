<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Vật phẩm - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .line-clamp-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
    </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 min-h-screen transition-all duration-300 flex flex-col">
    <!-- Header -->
    <header class="bg-white border-b border-slate-200 sticky top-0 z-10 px-8 py-4 flex justify-between items-center shadow-sm">
        <div>
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight">Vật phẩm</h1>
            <p class="text-sm text-slate-500 mt-1">Duyệt và quản lý các bài đăng quyên góp.</p>
        </div>
        <form action="${pageContext.request.contextPath}/admin" method="post">
            <input type="hidden" name="action" value="auto-approve">
            <button type="submit" onclick="return confirm('Hệ thống sẽ tự động duyệt các vật phẩm PENDING bằng AI. Tiếp tục?')"
                    class="group relative inline-flex items-center justify-center px-5 py-2.5 text-sm font-bold text-white transition-all duration-200 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 rounded-xl hover:from-indigo-600 hover:via-purple-600 hover:to-pink-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 shadow-lg shadow-purple-200">
                <span class="mr-2">✨</span> Duyệt AI Tự động
            </button>
        </form>
    </header>

    <div class="p-8 max-w-7xl mx-auto w-full">

        <!-- Status Tabs -->
        <div class="flex flex-wrap gap-2 mb-8 p-1 bg-slate-200/50 rounded-xl w-fit">
            <a href="${pageContext.request.contextPath}/admin?action=items"
               class="px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200
               ${empty param.status ? 'bg-white text-slate-800 shadow-sm' : 'text-slate-500 hover:text-slate-700 hover:bg-slate-200/50'}">
                Tất cả
            </a>
            <a href="${pageContext.request.contextPath}/admin?action=items&status=PENDING"
               class="px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200 flex items-center gap-2
               ${param.status == 'PENDING' ? 'bg-white text-amber-600 shadow-sm' : 'text-slate-500 hover:text-amber-600 hover:bg-slate-200/50'}">
                <span class="w-2 h-2 rounded-full bg-amber-500"></span> Chờ duyệt
            </a>
            <a href="${pageContext.request.contextPath}/admin?action=items&status=AVAILABLE"
               class="px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200 flex items-center gap-2
               ${param.status == 'AVAILABLE' ? 'bg-white text-emerald-600 shadow-sm' : 'text-slate-500 hover:text-emerald-600 hover:bg-slate-200/50'}">
                <span class="w-2 h-2 rounded-full bg-emerald-500"></span> Đang hiển thị
            </a>
            <a href="${pageContext.request.contextPath}/admin?action=items&status=CONFIRMED"
               class="px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200 flex items-center gap-2
               ${param.status == 'CONFIRMED' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-blue-600 hover:bg-slate-200/50'}">
                <span class="w-2 h-2 rounded-full bg-blue-500"></span> Đã chốt
            </a>
            <a href="${pageContext.request.contextPath}/admin?action=items&status=COMPLETED"
               class="px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200 flex items-center gap-2
               ${param.status == 'COMPLETED' ? 'bg-white text-purple-600 shadow-sm' : 'text-slate-500 hover:text-purple-600 hover:bg-slate-200/50'}">
                <span class="w-2 h-2 rounded-full bg-purple-500"></span> Hoàn thành
            </a>
            <a href="${pageContext.request.contextPath}/admin?action=items&status=CANCELLED"
               class="px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200 flex items-center gap-2
               ${param.status == 'CANCELLED' ? 'bg-white text-red-600 shadow-sm' : 'text-slate-500 hover:text-red-600 hover:bg-slate-200/50'}">
                <span class="w-2 h-2 rounded-full bg-red-500"></span> Đã hủy
            </a>
        </div>

        <!-- AI Message -->
        <c:if test="${not empty param.msg}">
            <div class="mb-8 p-4 bg-blue-50 border border-blue-100 text-blue-700 rounded-xl flex items-start gap-3 shadow-sm">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mt-0.5 flex-shrink-0" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
                </svg>
                <span class="font-medium">${fn:replace(param.msg, '_', ' ')}</span>
            </div>
        </c:if>

        <!-- Items Grid/Table -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                    <tr>
                        <th class="px-6 py-4 border-b border-slate-100">Vật phẩm</th>
                        <th class="px-6 py-4 border-b border-slate-100">Người đăng</th>
                        <th class="px-6 py-4 border-b border-slate-100">Danh mục</th>
                        <th class="px-6 py-4 border-b border-slate-100">Trạng thái</th>
                        <th class="px-6 py-4 border-b border-slate-100 text-right">Hành động</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-sm">
                    <c:forEach var="item" items="${items}">
                        <c:choose>
                            <c:when test="${fn:startsWith(item.imageUrl, 'http')}">
                                <c:set var="finalImgUrl" value="${item.imageUrl}" />
                            </c:when>
                            <c:otherwise>
                                <c:url value="/images" var="localImgUrl">
                                    <c:param name="path" value="${item.imageUrl}" />
                                </c:url>
                                <c:set var="finalImgUrl" value="${localImgUrl}" />
                            </c:otherwise>
                        </c:choose>

                        <tr class="group hover:bg-slate-50 transition-colors cursor-pointer"
                            onclick="openItemModal(this)"
                            data-id="${item.itemId}"
                            data-title="${item.title}"
                            data-desc="${item.description}"
                            data-image="${finalImgUrl}"
                            data-giver="${item.giverId}"
                            data-category="${item.categoryId}"
                            data-status="${item.status}"
                            data-points="${item.ecoPoints}"
                            data-date="${item.postDate}"
                            data-address="${item.address}">

                            <td class="px-6 py-4">
                                <div class="flex items-start gap-4">
                                    <div class="h-16 w-16 rounded-xl bg-slate-100 overflow-hidden flex-shrink-0 border border-slate-200 shadow-sm">
                                        <img src="${finalImgUrl}" alt="${item.title}" class="h-full w-full object-cover transition-transform group-hover:scale-110 duration-500"
                                             onerror="this.src='https://placehold.co/100x100?text=No+Image'">
                                    </div>
                                    <div>
                                        <div class="font-bold text-slate-800 text-base mb-1 group-hover:text-emerald-600 transition-colors line-clamp-1">${item.title}</div>
                                        <div class="text-xs text-slate-500 line-clamp-2 max-w-xs leading-relaxed">
                                                ${item.description}
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <td class="px-6 py-4">
                                <div class="flex items-center gap-2">
                                    <span class="w-6 h-6 rounded-full bg-slate-100 flex items-center justify-center text-[10px] font-bold text-slate-500">ID</span>
                                    <span class="font-mono text-slate-600 font-medium">#${item.giverId}</span>
                                </div>
                            </td>

                            <td class="px-6 py-4">
                                <span class="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-medium bg-slate-100 text-slate-600 border border-slate-200">
                                    ${categoryMap[item.categoryId]}
                                </span>
                            </td>

                            <td class="px-6 py-4">
                                <c:choose>
                                    <c:when test="${item.status == 'PENDING'}">
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-100">
                                            <span class="relative flex h-2 w-2">
                                              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"></span>
                                              <span class="relative inline-flex rounded-full h-2 w-2 bg-amber-500"></span>
                                            </span>
                                            Chờ duyệt
                                        </span>
                                    </c:when>
                                    <c:when test="${item.status == 'AVAILABLE'}">
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-100">
                                            <span class="w-2 h-2 rounded-full bg-emerald-500"></span> Đang hiển thị
                                        </span>
                                    </c:when>
                                    <c:when test="${item.status == 'CONFIRMED'}">
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-blue-50 text-blue-700 border border-blue-100">
                                            <span class="w-2 h-2 rounded-full bg-blue-500"></span> Đã chốt
                                        </span>
                                    </c:when>
                                    <c:when test="${item.status == 'COMPLETED'}">
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-purple-50 text-purple-700 border border-purple-100">
                                            <span class="w-2 h-2 rounded-full bg-purple-500"></span> Hoàn thành
                                        </span>
                                    </c:when>
                                    <c:when test="${item.status == 'CANCELLED'}">
                                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-red-50 text-red-700 border border-red-100">
                                            <span class="w-2 h-2 rounded-full bg-red-500"></span> Đã hủy
                                        </span>
                                    </c:when>
                                </c:choose>
                            </td>

                            <td class="px-6 py-4 text-right" onclick="event.stopPropagation()">
                                <c:choose>
                                    <c:when test="${item.status == 'PENDING'}">
                                        <div class="flex justify-end gap-2">
                                            <a href="${pageContext.request.contextPath}/admin?action=approve-item&id=${item.itemId}"
                                               class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-lg shadow-sm transition-colors">
                                                Duyệt
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin?action=reject-item&id=${item.itemId}"
                                               onclick="return confirm('Từ chối vật phẩm này?');"
                                               class="px-3 py-1.5 bg-white border border-slate-200 hover:bg-red-50 hover:text-red-600 hover:border-red-200 text-slate-600 text-xs font-bold rounded-lg transition-colors">
                                                Hủy
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:when test="${item.status == 'AVAILABLE'}">
                                        <a href="${pageContext.request.contextPath}/admin?action=reject-item&id=${item.itemId}"
                                           onclick="return confirm('Gỡ bỏ vật phẩm này?');"
                                           class="px-3 py-1.5 bg-white border border-slate-200 hover:bg-orange-50 hover:text-orange-600 hover:border-orange-200 text-slate-600 text-xs font-bold rounded-lg transition-colors">
                                            Gỡ bỏ
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-slate-300 text-xs font-medium italic">--</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty items}">
                        <tr>
                            <td colspan="5" class="px-6 py-16 text-center">
                                <div class="flex flex-col items-center justify-center">
                                    <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-4">
                                        <span class="text-3xl opacity-50">📭</span>
                                    </div>
                                    <h3 class="text-slate-800 font-bold mb-1">Không tìm thấy vật phẩm</h3>
                                    <p class="text-slate-500 text-sm">Thử thay đổi bộ lọc trạng thái xem sao.</p>
                                </div>
                            </td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="flex justify-center items-center gap-2 mt-8">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/admin?action=items&page=${currentPage - 1}&status=${currentStatus}"
                       class="w-10 h-10 flex items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-colors">
                        &laquo;
                    </a>
                </c:if>
                <span class="px-4 py-2 rounded-lg bg-slate-100 text-slate-600 text-sm font-bold">
                    Trang ${currentPage} / ${totalPages}
                </span>
                <c:if test="${currentPage < totalPages}">
                    <a href="${pageContext.request.contextPath}/admin?action=items&page=${currentPage + 1}&status=${currentStatus}"
                       class="w-10 h-10 flex items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-colors">
                        &raquo;
                    </a>
                </c:if>
            </div>
        </c:if>
    </div>
</main>

<!-- MODAL -->
<div id="itemDetailModal" class="fixed inset-0 z-50 hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm transition-opacity" onclick="closeItemModal()"></div>

    <div class="fixed inset-0 z-10 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
            <div class="relative transform overflow-hidden rounded-2xl bg-white text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-3xl border border-slate-100">

                <form action="${pageContext.request.contextPath}/admin" method="post">
                    <input type="hidden" name="action" value="update-item-details">
                    <input type="hidden" id="modalItemId" name="id" value="">

                    <!-- Modal Header -->
                    <div class="bg-white px-6 py-4 border-b border-slate-100 flex justify-between items-center sticky top-0 z-10">
                        <h3 class="text-lg font-bold text-slate-800">Chi tiết Vật phẩm</h3>
                        <button type="button" class="text-slate-400 hover:text-slate-600 bg-slate-50 hover:bg-slate-100 p-2 rounded-full transition-colors" onclick="closeItemModal()">
                            <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>

                    <!-- Modal Body -->
                    <div class="px-6 py-6">
                        <div class="flex flex-col md:flex-row gap-8">
                            <!-- Left: Image & Points -->
                            <div class="w-full md:w-5/12 space-y-4">
                                <div class="aspect-[4/3] rounded-2xl overflow-hidden bg-slate-100 border border-slate-200 shadow-inner relative group">
                                    <img id="modalImg" src="" alt="Item Image" class="object-cover w-full h-full">
                                    <div class="absolute inset-0 bg-black/0 group-hover:bg-black/5 transition-colors"></div>
                                </div>

                                <div class="bg-emerald-50 rounded-xl p-4 border border-emerald-100 flex items-center justify-between">
                                    <div>
                                        <p class="text-[10px] font-bold text-emerald-800 uppercase tracking-wider mb-0.5">Eco Points</p>
                                        <p class="text-xs text-emerald-600/80">Điểm thưởng dự kiến</p>
                                    </div>
                                    <div class="relative">
                                        <input type="number" id="modalPoints" name="eco_points" step="0.5"
                                               class="text-2xl font-bold text-emerald-700 bg-transparent border-b-2 border-emerald-200 focus:border-emerald-600 focus:outline-none w-24 text-right transition-colors p-0"
                                               placeholder="0.0">
                                    </div>
                                </div>
                            </div>

                            <!-- Right: Info -->
                            <div class="w-full md:w-7/12 space-y-6">
                                <div>
                                    <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Tiêu đề</label>
                                    <h2 id="modalItemTitle" class="text-xl font-bold text-slate-800 leading-snug"></h2>
                                </div>

                                <div>
                                    <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Thông tin chi tiết</label>
                                    <div class="grid grid-cols-2 gap-4 mb-4">
                                        <div class="bg-slate-50 p-3 rounded-xl border border-slate-100">
                                            <span class="text-xs text-slate-500 block mb-1">Danh mục</span>
                                            <select id="modalCategory" name="category_id" class="w-full bg-transparent text-sm font-semibold text-slate-700 focus:outline-none cursor-pointer">
                                                <c:forEach var="cat" items="${categories}">
                                                    <option value="${cat.categoryId}">${cat.name}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="bg-slate-50 p-3 rounded-xl border border-slate-100">
                                            <span class="text-xs text-slate-500 block mb-1">Trạng thái</span>
                                            <div id="modalStatus" class="text-sm font-bold"></div>
                                        </div>
                                    </div>

                                    <div class="bg-slate-50 p-4 rounded-xl border border-slate-100 max-h-32 overflow-y-auto custom-scrollbar">
                                        <p id="modalDesc" class="text-sm text-slate-600 leading-relaxed whitespace-pre-line"></p>
                                    </div>
                                </div>

                                <div class="space-y-3">
                                    <div class="flex items-start gap-3">
                                        <div class="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 flex-shrink-0">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                        </div>
                                        <div>
                                            <p class="text-xs font-bold text-slate-700">Người đăng</p>
                                            <p id="modalGiver" class="text-sm text-slate-500 font-mono"></p>
                                        </div>
                                    </div>
                                    <div class="flex items-start gap-3">
                                        <div class="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 flex-shrink-0">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                                        </div>
                                        <div>
                                            <p class="text-xs font-bold text-slate-700">Địa chỉ</p>
                                            <p id="modalAddress" class="text-sm text-slate-500"></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Modal Footer -->
                    <div class="bg-slate-50 px-6 py-4 flex flex-row-reverse gap-3 border-t border-slate-100">
                        <button type="submit" id="btnSaveDetails" class="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold rounded-xl shadow-lg shadow-blue-200 transition-all active:scale-95">
                            💾 Lưu thay đổi
                        </button>

                        <div id="modalActions" class="hidden flex-row-reverse gap-3">
                            <a id="btnModalApprove" href="#" class="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-bold rounded-xl shadow-lg shadow-emerald-200 transition-all active:scale-95">
                                ✓ Duyệt bài
                            </a>
                            <a id="btnModalReject" href="#" onclick="return confirm('Xác nhận hành động này?');" class="px-5 py-2.5 bg-white border border-slate-200 text-red-600 hover:bg-red-50 hover:border-red-200 text-sm font-bold rounded-xl transition-all">
                                ✗ Từ chối
                            </a>
                        </div>

                        <button type="button" class="px-5 py-2.5 bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 text-sm font-bold rounded-xl transition-all" onclick="closeItemModal()">
                            Đóng
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function openItemModal(row) {
        const d = row.dataset;

        // Fill Data
        document.getElementById('modalItemId').value = d.id;
        document.getElementById('modalItemTitle').innerText = d.title;
        document.getElementById('modalDesc').innerText = d.desc;
        document.getElementById('modalImg').src = d.image;
        document.getElementById('modalGiver').innerText = 'ID: ' + d.giver;
        document.getElementById('modalAddress').innerText = d.address || 'Chưa cập nhật';
        document.getElementById('modalCategory').value = d.category;
        document.getElementById('modalPoints').value = d.points;

        // Status Styling
        const statusEl = document.getElementById('modalStatus');
        statusEl.innerText = d.status;
        statusEl.className = 'text-sm font-bold';
        if (d.status === 'PENDING') statusEl.classList.add('text-amber-600');
        else if (d.status === 'AVAILABLE') statusEl.classList.add('text-emerald-600');
        else if (d.status === 'CONFIRMED') statusEl.classList.add('text-blue-600');
        else if (d.status === 'COMPLETED') statusEl.classList.add('text-purple-600');
        else statusEl.classList.add('text-red-600');

        // Logic Input State
        const pointsInput = document.getElementById('modalPoints');
        const btnSave = document.getElementById('btnSaveDetails');

        if (d.status === 'PENDING' || d.status === 'AVAILABLE') {
            pointsInput.readOnly = false;
            pointsInput.classList.remove('opacity-50', 'cursor-not-allowed');
            btnSave.classList.remove('hidden');
        } else {
            pointsInput.readOnly = true;
            pointsInput.classList.add('opacity-50', 'cursor-not-allowed');
            // Vẫn cho save category nếu muốn, hoặc ẩn luôn nút save
            // btnSave.classList.add('hidden');
        }

        // Action Buttons Logic
        const actionDiv = document.getElementById('modalActions');
        const btnApprove = document.getElementById('btnModalApprove');
        const btnReject = document.getElementById('btnModalReject');

        actionDiv.classList.add('hidden');
        actionDiv.classList.remove('flex');

        if (d.status === 'PENDING') {
            actionDiv.classList.remove('hidden');
            actionDiv.classList.add('flex');
            btnApprove.href = '${pageContext.request.contextPath}/admin?action=approve-item&id=' + d.id;
            btnReject.href = '${pageContext.request.contextPath}/admin?action=reject-item&id=' + d.id;
            btnReject.innerText = '✗ Từ chối';
        } else if (d.status === 'AVAILABLE') {
            actionDiv.classList.remove('hidden');
            actionDiv.classList.add('flex');
            btnApprove.classList.add('hidden');
            btnReject.href = '${pageContext.request.contextPath}/admin?action=reject-item&id=' + d.id;
            btnReject.innerText = '✗ Gỡ bỏ';
        }

        document.getElementById('itemDetailModal').classList.remove('hidden');
    }

    function closeItemModal() {
        document.getElementById('itemDetailModal').classList.add('hidden');
    }

    // Close on Escape
    document.addEventListener('keydown', (e) => { if(e.key === "Escape") closeItemModal(); });
</script>

</body>
</html>