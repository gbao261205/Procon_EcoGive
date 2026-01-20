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
        /* Hiệu ứng fade cho modal */
        .modal-enter { opacity: 0; transform: scale(0.95); }
        .modal-enter-active { opacity: 1; transform: scale(1); transition: opacity 0.2s, transform 0.2s; }
    </style>
</head>
<body class="bg-slate-100 min-h-screen font-sans text-slate-800">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 p-8">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-slate-800">Quản lý Vật phẩm</h1>

        <!-- Nút Duyệt Tự Động AI -->
        <form action="${pageContext.request.contextPath}/admin" method="post" class="inline-block">
            <input type="hidden" name="action" value="auto-approve">
            <button type="submit" onclick="return confirm('Hệ thống sẽ tự động duyệt các vật phẩm PENDING bằng AI. Quá trình này có thể mất vài giây. Tiếp tục?')"
                    class="px-4 py-2 rounded-lg text-sm font-bold text-white bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 shadow-md transition-all flex items-center gap-2">
                <span>✨</span> Duyệt tự động (AI)
            </button>
        </form>
    </div>

    <!-- Filter Buttons -->
    <div class="flex flex-wrap gap-2 mb-6">
        <a href="${pageContext.request.contextPath}/admin?action=items"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${empty param.status ? 'bg-slate-800 text-white border-slate-800' : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'}">
            Tất cả
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=items&status=PENDING"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'PENDING' ? 'bg-amber-100 text-amber-800 border-amber-200' : 'bg-white text-slate-600 border-slate-200 hover:text-amber-600 hover:bg-amber-50'}">
            Chờ duyệt
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=items&status=AVAILABLE"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'AVAILABLE' ? 'bg-emerald-100 text-emerald-800 border-emerald-200' : 'bg-white text-slate-600 border-slate-200 hover:text-emerald-600 hover:bg-emerald-50'}">
            Đang hiển thị
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=items&status=CONFIRMED"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'CONFIRMED' ? 'bg-blue-100 text-blue-800 border-blue-200' : 'bg-white text-slate-600 border-slate-200 hover:text-blue-600 hover:bg-blue-50'}">
            Đã chốt tặng
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=items&status=COMPLETED"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'COMPLETED' ? 'bg-purple-100 text-purple-800 border-purple-200' : 'bg-white text-slate-600 border-slate-200 hover:text-purple-600 hover:bg-purple-50'}">
            Hoàn thành
        </a>
        <a href="${pageContext.request.contextPath}/admin?action=items&status=CANCELLED"
           class="px-4 py-2 rounded-lg text-sm font-medium border shadow-sm transition-all
           ${param.status == 'CANCELLED' ? 'bg-red-100 text-red-800 border-red-200' : 'bg-white text-slate-600 border-slate-200 hover:text-red-600 hover:bg-red-50'}">
            Đã hủy
        </a>
    </div>

    <!-- Thông báo kết quả AI -->
    <c:if test="${not empty param.msg}">
        <div class="mb-6 p-4 bg-blue-50 border border-blue-200 text-blue-700 rounded-lg flex items-center gap-2">
            <span>ℹ️</span>
            <span>${fn:replace(param.msg, '_', ' ')}</span>
        </div>
    </c:if>

    <!-- Table -->
    <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden mb-6">
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
                <tbody class="text-sm divide-y divide-slate-100">
                <c:forEach var="item" items="${items}">
                    <!-- Xử lý URL ảnh trước để dùng cho cả hiển thị và data attribute -->
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

                    <tr class="hover:bg-slate-50 transition-colors cursor-pointer group"
                        onclick="openItemModal(this)"
                        data-id="${item.itemId}"
                        data-title="${item.title}"
                        data-desc="${item.description}"
                        data-image="${finalImgUrl}"
                        data-giver="${item.giverId}"
                        data-category="${item.categoryId}"
                        data-status="${item.status}"
                        data-points="${item.ecoPoints}"
                        data-date="${item.postDate}">

                        <td class="px-6 py-4">
                            <div class="flex items-center gap-3">
                                <div class="h-12 w-12 rounded-lg bg-slate-200 overflow-hidden flex-shrink-0 border border-slate-200">
                                    <img src="${finalImgUrl}" alt="${item.title}" class="h-full w-full object-cover"
                                         onerror="this.src='https://placehold.co/100x100?text=No+Image'">
                                </div>
                                <div>
                                    <div class="font-medium text-slate-800 group-hover:text-emerald-600 transition-colors">${item.title}</div>
                                    <div class="text-xs text-slate-500 truncate w-32" title="${item.description}">
                                            ${item.description}
                                    </div>
                                </div>
                            </div>
                        </td>

                        <td class="px-6 py-4 text-slate-500 font-mono text-xs">ID: ${item.giverId}</td>
                        <td class="px-6 py-4 text-slate-500 font-mono text-xs">Cat ID: ${item.categoryId}</td>

                        <td class="px-6 py-4">
                            <c:choose>
                                <c:when test="${item.status == 'PENDING'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-50 text-amber-700 border border-amber-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span> Chờ duyệt
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'AVAILABLE'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700 border border-emerald-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Đang hiển thị
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'CONFIRMED'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-700 border border-blue-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span> Đã chốt tặng
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'COMPLETED'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-purple-50 text-purple-700 border border-purple-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-purple-500"></span> Hoàn thành
                                    </span>
                                </c:when>
                                <c:when test="${item.status == 'CANCELLED'}">
                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-red-50 text-red-700 border border-red-100">
                                        <span class="w-1.5 h-1.5 rounded-full bg-red-500"></span> Đã hủy
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-600">${item.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class="px-6 py-4 text-right" onclick="event.stopPropagation()">
                            <c:choose>
                                <c:when test="${item.status == 'PENDING'}">
                                    <a href="${pageContext.request.contextPath}/admin?action=approve-item&id=${item.itemId}"
                                       class="text-emerald-600 hover:text-emerald-800 font-medium text-xs border border-emerald-200 bg-emerald-50 hover:bg-emerald-100 rounded px-3 py-1 mr-2 transition-colors">
                                        ✓ Duyệt
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin?action=reject-item&id=${item.itemId}"
                                       class="text-red-600 hover:text-red-800 font-medium text-xs border border-red-200 bg-red-50 hover:bg-red-100 rounded px-3 py-1 transition-colors"
                                       onclick="return confirm('Từ chối vật phẩm này?');">
                                        ✗ Hủy
                                    </a>
                                </c:when>
                                <c:when test="${item.status == 'AVAILABLE'}">
                                    <a href="${pageContext.request.contextPath}/admin?action=reject-item&id=${item.itemId}"
                                       class="text-orange-600 hover:text-orange-800 font-medium text-xs border border-orange-200 bg-orange-50 hover:bg-orange-100 rounded px-3 py-1 transition-colors"
                                       onclick="return confirm('Bạn chắc chắn muốn gỡ bỏ vật phẩm đang hiển thị này?');">
                                        ✗ Gỡ bỏ
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-slate-400 text-xs italic">Đã xử lý</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty items}">
                    <tr>
                        <td colspan="5" class="px-6 py-12 text-center text-slate-400 italic">
                            <div class="flex flex-col items-center">
                                <span class="text-2xl mb-2">📭</span>
                                <span>Không có vật phẩm nào trong danh sách này.</span>
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
        <div class="flex justify-center items-center gap-2 mt-6">
            <c:if test="${currentPage > 1}">
                <a href="${pageContext.request.contextPath}/admin?action=items&page=${currentPage - 1}&status=${currentStatus}"
                   class="px-3 py-1 rounded border border-slate-300 bg-white text-slate-600 hover:bg-slate-50 text-sm">
                    &laquo; Trước
                </a>
            </c:if>
            <span class="text-sm text-slate-600 font-medium">
                Trang ${currentPage} / ${totalPages}
            </span>
            <c:if test="${currentPage < totalPages}">
                <a href="${pageContext.request.contextPath}/admin?action=items&page=${currentPage + 1}&status=${currentStatus}"
                   class="px-3 py-1 rounded border border-slate-300 bg-white text-slate-600 hover:bg-slate-50 text-sm">
                    Sau &raquo;
                </a>
            </c:if>
        </div>
    </c:if>
</main>

<!-- ITEM DETAIL MODAL -->
<div id="itemDetailModal" class="fixed inset-0 z-50 hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <!-- Backdrop -->
    <div class="fixed inset-0 bg-gray-900 bg-opacity-75 transition-opacity" onclick="closeItemModal()"></div>

    <div class="fixed inset-0 z-10 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
            <div class="relative transform overflow-hidden rounded-2xl bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-2xl">

                <!-- Header -->
                <div class="bg-slate-50 px-4 py-3 sm:px-6 flex justify-between items-center border-b border-slate-100">
                    <h3 class="text-lg font-bold leading-6 text-slate-800" id="modal-title">Chi tiết Vật phẩm</h3>
                    <button type="button" class="text-slate-400 hover:text-slate-600" onclick="closeItemModal()">
                        <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <!-- Body -->
                <div class="px-4 py-5 sm:p-6">
                    <div class="flex flex-col md:flex-row gap-6">
                        <!-- Image Section -->
                        <div class="w-full md:w-1/2">
                            <div class="aspect-w-4 aspect-h-3 rounded-xl overflow-hidden bg-slate-100 border border-slate-200">
                                <img id="modalImg" src="" alt="Item Image" class="object-contain w-full h-64 bg-slate-50">
                            </div>
                            <div class="mt-4 flex justify-between items-center bg-emerald-50 p-3 rounded-lg border border-emerald-100">
                                <span class="text-xs font-bold text-emerald-800 uppercase">Eco Points</span>
                                <span id="modalPoints" class="text-lg font-bold text-emerald-600">0</span>
                            </div>
                        </div>

                        <!-- Info Section -->
                        <div class="w-full md:w-1/2 space-y-4">
                            <div>
                                <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Tên vật phẩm</label>
                                <h2 id="modalItemTitle" class="text-xl font-bold text-slate-800 leading-tight"></h2>
                            </div>

                            <div>
                                <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Mô tả chi tiết</label>
                                <div id="modalDesc" class="text-sm text-slate-600 bg-slate-50 p-3 rounded-lg border border-slate-100 max-h-40 overflow-y-auto"></div>
                            </div>

                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Người đăng (ID)</label>
                                    <div id="modalGiver" class="text-sm font-medium text-slate-700"></div>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Danh mục (ID)</label>
                                    <div id="modalCategory" class="text-sm font-medium text-slate-700"></div>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Ngày đăng</label>
                                    <div id="modalDate" class="text-sm font-medium text-slate-700"></div>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-slate-400 uppercase mb-1">Trạng thái</label>
                                    <div id="modalStatus" class="text-sm font-bold"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="bg-slate-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6 border-t border-slate-100 gap-2">
                    <!-- Action Buttons -->
                    <div id="modalActions" class="hidden sm:flex-row-reverse gap-2 w-full sm:w-auto">
                        <a id="btnModalApprove" href="#" class="inline-flex w-full justify-center rounded-lg bg-emerald-600 px-3 py-2 text-sm font-bold text-white shadow-sm hover:bg-emerald-700 sm:w-auto">
                            ✓ Duyệt
                        </a>
                        <a id="btnModalReject" href="#" onclick="return confirm('Xác nhận hành động này?');" class="inline-flex w-full justify-center rounded-lg bg-red-600 px-3 py-2 text-sm font-bold text-white shadow-sm hover:bg-red-700 sm:w-auto">
                            ✗ Hủy
                        </a>
                    </div>

                    <button type="button" class="mt-3 inline-flex w-full justify-center rounded-lg bg-white px-3 py-2 text-sm font-semibold text-slate-900 shadow-sm ring-1 ring-inset ring-slate-300 hover:bg-slate-50 sm:mt-0 sm:w-auto" onclick="closeItemModal()">Đóng</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function openItemModal(row) {
        // Lấy dữ liệu từ data attributes
        const id = row.getAttribute('data-id');
        const title = row.getAttribute('data-title');
        const desc = row.getAttribute('data-desc');
        const imgUrl = row.getAttribute('data-image');
        const giver = row.getAttribute('data-giver');
        const category = row.getAttribute('data-category');
        const status = row.getAttribute('data-status');
        const points = row.getAttribute('data-points');
        const date = row.getAttribute('data-date');

        // Điền dữ liệu vào modal
        document.getElementById('modalItemTitle').innerText = title;
        document.getElementById('modalDesc').innerText = desc;
        document.getElementById('modalImg').src = imgUrl;
        document.getElementById('modalGiver').innerText = giver;
        document.getElementById('modalCategory').innerText = category;
        document.getElementById('modalPoints').innerText = points;
        document.getElementById('modalDate').innerText = date.replace('T', ' ');

        // Style cho status
        const statusEl = document.getElementById('modalStatus');
        statusEl.innerText = status;
        statusEl.className = 'text-sm font-bold'; // Reset class
        if (status === 'PENDING') statusEl.classList.add('text-amber-600');
        else if (status === 'AVAILABLE') statusEl.classList.add('text-emerald-600');
        else if (status === 'CONFIRMED') statusEl.classList.add('text-blue-600');
        else if (status === 'COMPLETED') statusEl.classList.add('text-purple-600');
        else statusEl.classList.add('text-red-600');

        // Xử lý nút Duyệt/Hủy
        const actionDiv = document.getElementById('modalActions');
        const btnApprove = document.getElementById('btnModalApprove');
        const btnReject = document.getElementById('btnModalReject');

        // Reset trạng thái mặc định
        actionDiv.classList.add('hidden');
        actionDiv.classList.remove('flex');
        btnApprove.classList.remove('hidden'); // Hiện nút duyệt mặc định
        btnReject.innerText = '✗ Hủy'; // Reset text nút hủy
        btnReject.classList.remove('bg-orange-600', 'hover:bg-orange-700'); // Reset màu
        btnReject.classList.add('bg-red-600', 'hover:bg-red-700');

        if (status === 'PENDING') {
            actionDiv.classList.remove('hidden');
            actionDiv.classList.add('flex');

            btnApprove.href = '${pageContext.request.contextPath}/admin?action=approve-item&id=' + id;
            btnReject.href = '${pageContext.request.contextPath}/admin?action=reject-item&id=' + id;
        }
        else if (status === 'AVAILABLE') {
            actionDiv.classList.remove('hidden');
            actionDiv.classList.add('flex');

            // Ẩn nút duyệt
            btnApprove.classList.add('hidden');

            // Cấu hình nút Hủy thành nút Gỡ bỏ
            btnReject.innerText = '✗ Gỡ bỏ';
            btnReject.href = '${pageContext.request.contextPath}/admin?action=reject-item&id=' + id;

            // Đổi màu sang cam cho khác biệt
            btnReject.classList.remove('bg-red-600', 'hover:bg-red-700');
            btnReject.classList.add('bg-orange-600', 'hover:bg-orange-700');
        }

        // Hiển thị modal
        document.getElementById('itemDetailModal').classList.remove('hidden');
    }

    function closeItemModal() {
        document.getElementById('itemDetailModal').classList.add('hidden');
    }

    // Đóng modal khi nhấn ESC
    document.addEventListener('keydown', function(event) {
        if (event.key === "Escape") {
            closeItemModal();
        }
    });
</script>

</body>
</html>
