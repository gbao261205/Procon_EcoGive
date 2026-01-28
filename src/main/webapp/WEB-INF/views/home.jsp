<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Bản đồ EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
    <style>
        .leaflet-popup-content-wrapper { border-radius: 12px; overflow: hidden; padding: 0; }
        .leaflet-popup-content { margin: 0; width: 240px !important; }
        /* Đã chỉnh sửa theo yêu cầu: object-fit: contain và thêm background */
        .custom-popup-img { width: 100%; height: 150px; object-fit: contain; background-color: #f1f5f9; }
        .custom-popup-body { padding: 12px; }
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
        @keyframes popIn { 0% { transform: scale(0.8); opacity: 0; } 100% { transform: scale(1); opacity: 1; } }
        .gift-popup { animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
    </style>
</head>

<body class="h-screen flex flex-col bg-slate-50 relative">

<header class="bg-white shadow-sm z-20 px-6 py-3 flex justify-between items-center h-16 flex-shrink-0">
    <div class="flex items-center gap-2">
        <h1 class="text-2xl font-bold text-emerald-600 tracking-tight">EcoGive <span class="text-slate-400 font-normal text-sm">Map</span></h1>
    </div>

    <div class="flex items-center gap-3">
        <div class="flex items-center gap-2 border-r border-slate-200 pr-4 mr-2">
            <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin?action=dashboard"
                   class="flex items-center gap-2 px-3 py-2 text-sm font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-lg shadow-sm transition" title="Trang quản trị">
                    <span>📊</span>
                </a>
            </c:if>
            <c:if test="${sessionScope.currentUser.role == 'COLLECTOR_COMPANY'}">
                <a href="${pageContext.request.contextPath}/dashboard/company"
                   class="flex items-center gap-2 px-3 py-2 text-sm font-bold text-white bg-emerald-600 hover:bg-emerald-700 rounded-lg shadow-sm transition" title="Trang quản lý Doanh nghiệp">
                    <span>🏢</span>
                </a>
            </c:if>
             <c:if test="${sessionScope.currentUser.role == 'ADMIN' || sessionScope.currentUser.role == 'COLLECTOR_COMPANY'}">
                <button id="btnAddPoint"
                        class="flex items-center gap-2 px-3 py-2 text-sm font-bold text-white bg-emerald-600 hover:bg-blue-700 rounded-lg shadow-sm transition" title="Thêm điểm tập kết">
                    <span>📍</span>
                </button>
            </c:if>
            <button id="btnPostItem"
                    class="flex items-center gap-2 px-3 py-2 text-sm font-bold text-white bg-emerald-600 hover:bg-blue-700 rounded-lg shadow-sm transition">
                Đăng tin
            </button>
        </div>

        <c:if test="${sessionScope.currentUser != null}">
            <a href="${pageContext.request.contextPath}/profile"
               class="text-right hidden md:block group hover:bg-slate-50 px-3 py-1 rounded-lg transition cursor-pointer"
               title="Xem hồ sơ cá nhân">
                <div class="text-sm font-bold text-slate-700 group-hover:text-blue-600 transition">
                        ${sessionScope.currentUser.username}
                </div>
                <div class="text-xs text-emerald-600 font-medium">
                        ${sessionScope.currentUser.ecoPoints} EcoPoints
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="text-sm font-medium text-red-500 hover:text-red-700 hover:bg-red-50 px-3 py-2 rounded-lg transition">Thoát</a>
        </c:if>

        <c:if test="${sessionScope.currentUser == null}">
            <a href="${pageContext.request.contextPath}/login" class="px-4 py-2 text-sm font-bold text-emerald-600 bg-emerald-50 hover:bg-emerald-100 rounded-lg transition">Đăng nhập</a>
        </c:if>
    </div>
</header>

<!-- Filter Bar -->
<div class="bg-white border-b border-slate-200 px-6 py-2 flex flex-wrap items-center gap-4 z-10 shadow-sm text-sm">
    <div class="flex items-center gap-2">
        <span class="font-bold text-slate-600">Lọc tin:</span>
        <select id="filterCategory" class="border border-slate-300 rounded px-2 py-1 text-slate-700 focus:outline-none focus:border-emerald-500" onchange="reloadMapData()">
            <option value="">-- Tất cả danh mục --</option>
        </select>
    </div>
    <div class="h-4 w-px bg-slate-300 mx-2 hidden md:block"></div>
    <div class="flex items-center gap-4">
        <label class="flex items-center gap-2 cursor-pointer select-none">
            <input type="checkbox" id="filterPublicPoint" class="accent-emerald-600 w-4 h-4" checked onchange="reloadMapData()">
            <span class="text-slate-700">♻️ Điểm công cộng</span>
        </label>
        <label class="flex items-center gap-2 cursor-pointer select-none">
            <input type="checkbox" id="filterCompanyPoint" class="accent-yellow-500 w-4 h-4" checked onchange="reloadMapData()">
            <span class="text-slate-700">🏢 Điểm doanh nghiệp</span>
        </label>
    </div>
</div>

<div id="map" class="flex-1 z-0 w-full h-full"></div>

<div id="congratsModal" class="fixed inset-0 hidden bg-black bg-opacity-70 flex items-center justify-center p-4 z-[60]">
    <div class="bg-white p-8 rounded-2xl w-full max-w-sm shadow-2xl text-center gift-popup relative">
        <button onclick="document.getElementById('congratsModal').classList.add('hidden')" class="absolute top-4 right-4 text-gray-400 hover:text-gray-600">✕</button>
        <div class="text-6xl mb-4">🎉</div>
        <h2 class="text-2xl font-bold text-emerald-600 mb-2">Chúc mừng bạn!</h2>
        <p class="text-gray-700 mb-2" id="congratsText">Bạn vừa được xác nhận tặng quà.</p>
        <div class="text-xs text-gray-500 bg-gray-100 p-2 rounded">Trạng thái: <b>CONFIRMED</b>. Hãy liên hệ nhận đồ nhé!</div>
        <button onclick="document.getElementById('congratsModal').classList.add('hidden')" class="mt-4 w-full bg-emerald-600 text-white font-bold py-2 rounded-lg hover:bg-emerald-700">Tuyệt vời</button>
    </div>
</div>

<div id="ratingModal" class="fixed inset-0 hidden bg-black bg-opacity-70 flex items-center justify-center p-4 z-[70]">
    <div class="bg-white p-6 rounded-xl w-full max-w-sm shadow-2xl relative">
        <h2 class="text-xl font-bold text-slate-800 text-center mb-4">Đánh giá người tặng</h2>
        <p class="text-xs text-gray-500 text-center mb-4">Xác nhận bạn đã nhận được món đồ và đánh giá trải nghiệm.</p>
        <div class="flex justify-center gap-2 mb-4">
            <select id="ratingValue" class="p-2 border rounded bg-yellow-50 text-yellow-700 font-bold w-full text-center">
                <option value="5">⭐⭐⭐⭐⭐ (Tuyệt vời)</option>
                <option value="4">⭐⭐⭐⭐ (Tốt)</option>
                <option value="3">⭐⭐⭐ (Bình thường)</option>
                <option value="2">⭐⭐ (Tệ)</option>
                <option value="1">⭐ (Rất tệ)</option>
            </select>
        </div>
        <textarea id="ratingComment" rows="3" class="w-full p-3 border rounded-lg text-sm mb-4 focus:ring-emerald-500" placeholder="Viết lời cảm ơn hoặc nhận xét..."></textarea>
        <div class="flex gap-2">
            <button onclick="document.getElementById('ratingModal').classList.add('hidden')" class="flex-1 bg-gray-200 text-gray-700 py-2 rounded-lg font-bold hover:bg-gray-300 transition">Hủy</button>
            <button onclick="submitRating()" class="flex-1 bg-emerald-600 text-white py-2 rounded-lg font-bold hover:bg-emerald-700 transition shadow-md">Gửi đánh giá</button>
        </div>
    </div>
</div>

<div id="giveAwayModal" class="fixed inset-0 hidden bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
    <div class="bg-white p-6 rounded-xl w-full max-w-lg shadow-2xl relative">
        <button onclick="closeModal('giveAwayModal')" class="absolute top-4 right-4 text-gray-400 hover:text-gray-600">✕</button>
        <h2 class="text-2xl font-bold mb-6 text-emerald-700 text-center">Đăng tin Tặng đồ</h2>
        <div id="step1" class="modal-step">
            <input type="text" id="itemName" placeholder="Tên vật phẩm" class="w-full p-3 mb-3 border rounded-lg" required />
            <select id="itemCategory" class="w-full p-3 mb-3 border rounded-lg bg-white" required onchange="updateEcoPoints()">
                <option value="" disabled selected>-- Chọn danh mục --</option>
            </select>
            <div class="relative">
                <input type="number" id="itemEcoPoints" placeholder="Điểm EcoPoints thưởng" class="w-full p-3 mb-3 border rounded-lg bg-gray-100 text-gray-600 cursor-not-allowed" readonly />
                <span class="absolute right-4 top-3 text-gray-400 text-sm font-bold">🌱</span>
            </div>
            <textarea id="itemDescription" placeholder="Mô tả..." rows="3" class="w-full p-3 mb-4 border rounded-lg" required></textarea>
            <button onclick="nextStep(2)" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold">Tiếp tục</button>
        </div>
        <div id="step2" class="modal-step hidden">
            <input type="file" id="itemPhoto" accept="image/*" class="w-full p-3 mb-4 border rounded-lg" required />
            <button onclick="nextStep(3)" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold">Tiếp tục</button>
        </div>
        <div id="step3" class="modal-step hidden">
            <div class="flex gap-2 mb-3 relative">
                <div class="flex-1 relative">
                    <input type="text" id="itemAddress" placeholder="Nhập địa chỉ (VD: 123 Lê Lợi...)" class="w-full p-2 border rounded-lg" autocomplete="off" />
                    <!-- Autocomplete Dropdown: Tăng z-index lên 9999 -->
                    <ul id="suggestionList" class="absolute left-0 right-0 top-full bg-white border border-gray-200 rounded-lg shadow-lg z-[9999] max-h-60 overflow-y-auto hidden mt-1"></ul>
                </div>
                <button onclick="searchAddress()" class="bg-blue-600 text-white px-4 py-2 rounded-lg font-bold hover:bg-blue-700 h-full">Tìm</button>
            </div>
            <div id="miniMap" class="h-64 w-full rounded-lg mb-4 border"></div>
            <button onclick="submitItem()" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold">Đăng tin</button>
        </div>
    </div>
</div>

<div id="addPointModal" class="fixed inset-0 hidden bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
    <div class="bg-white p-6 rounded-xl w-full max-w-lg shadow-2xl relative">
        <button onclick="document.getElementById('addPointModal').classList.add('hidden')" class="absolute top-4 right-4 text-gray-400 hover:text-gray-600">✕</button>
        <h2 class="text-2xl font-bold mb-6 text-green-700 text-center">Thêm Điểm Tập Kết</h2>
        <div class="space-y-3">
            <input type="text" id="pointName" placeholder="Tên điểm (VD: Trạm Pin Q1)" class="w-full p-2 border rounded-lg" required />
            <select id="pointType" class="w-full p-2 border rounded-lg bg-white">
                <option value="BATTERY">🔋 Thu gom Pin</option>
                <option value="E_WASTE">💻 Rác thải điện tử</option>
                <option value="TEXTILE">👕 Quần áo cũ</option>
            </select>
            <input type="text" id="pointAddress" placeholder="Địa chỉ hiển thị..." class="w-full p-2 border rounded-lg" required />
            <div>
                <label class="block text-xs font-bold text-gray-700 mb-1">Vị trí (Kéo để chỉnh)</label>
                <div id="pointMiniMap" class="h-48 w-full rounded-lg border z-0"></div>
            </div>
            <button onclick="submitCollectionPoint()" class="w-full bg-green-600 text-white p-3 rounded-lg font-bold hover:bg-green-700">Xác nhận Thêm</button>
        </div>
    </div>
</div>

<button id="btnOpenInbox" onclick="toggleChatModal(false)" class="fixed bottom-6 right-6 bg-emerald-600 hover:bg-emerald-700 text-white p-4 rounded-full shadow-2xl z-50 transition hover:scale-105 flex items-center justify-center gap-2">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
    <span class="font-bold">Tin nhắn</span>
    <span id="msgBadge" class="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full hidden"></span>
</button>

<div id="chatModal" class="fixed bottom-24 right-6 w-[95vw] md:w-[800px] h-[500px] bg-white rounded-xl shadow-2xl border border-slate-200 hidden z-50 flex overflow-hidden">
    <div id="inboxPanel" class="w-full md:w-1/3 bg-slate-50 border-r border-slate-200 flex flex-col md:flex">
        <div class="p-4 bg-white border-b font-bold text-slate-700 flex justify-between items-center">
            <span>Hộp thư</span>
            <button onclick="toggleChatModal(true)" class="text-gray-400 hover:text-gray-600">✕</button>
        </div>
        <div id="inboxList" class="flex-1 overflow-y-auto p-2 space-y-1"></div>
    </div>
    <div id="chatDetailPanel" class="w-full md:w-2/3 flex flex-col bg-white hidden md:flex">
        <div class="p-3 border-b flex justify-between items-center bg-white shadow-sm z-10">
            <div class="flex items-center gap-3">
                <button onclick="backToInbox()" class="md:hidden text-emerald-600 font-bold mr-2">⬅</button>
                <div class="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 font-bold" id="chatHeaderAvatar">?</div>
                <div>
                    <div id="chatTitle" class="font-bold text-slate-700 text-sm">Chọn người chat</div>
                    <div id="chatItemInfo" class="hidden text-[11px] text-gray-500 flex items-center gap-1 bg-gray-100 px-2 py-0.5 rounded mt-1">
                        📦 <span id="chatItemName" class="font-bold text-emerald-600 truncate max-w-[120px]">...</span>
                    </div>
                </div>
            </div>
            <div class="flex items-center gap-2">
                <!-- Nút cho người cho -->
                <button id="btnGiverConfirm" onclick="confirmTransaction('giver_confirm')" class="hidden bg-emerald-600 text-white text-xs font-bold px-3 py-1.5 rounded hover:bg-emerald-700 shadow-md animate-pulse">
                    🎁 Xác nhận đã tặng
                </button>
                <!-- Nút cho người nhận -->
                <button id="btnReceiverConfirm" onclick="confirmTransaction('receiver_confirm')" class="hidden bg-blue-600 text-white text-xs font-bold px-3 py-1.5 rounded hover:bg-blue-700 shadow-md animate-bounce">
                    ✅ Xác nhận đã nhận
                </button>

                <button onclick="toggleChatModal(true)" class="hidden md:block text-slate-400 hover:text-slate-600">✕</button>
            </div>
        </div>
        <div id="chatMessages" class="flex-1 p-4 overflow-y-auto bg-slate-50 text-sm space-y-3">
            <div class="text-center text-xs text-gray-400 mt-20">Chọn hội thoại hoặc bấm Nhận trên bản đồ</div>
        </div>

        <!-- MỚI: Khu vực tin nhắn nhanh -->
        <div id="quickReplies" class="px-3 py-2 bg-gray-50 flex gap-2 overflow-x-auto border-t border-gray-100 hidden">
            <!-- Nút cho Giver -->
            <button id="qrGiver" onclick="confirmTransaction('giver_confirm')"
                    class="hidden whitespace-nowrap bg-white border border-emerald-200 text-emerald-700 text-xs px-3 py-1.5 rounded-full hover:bg-emerald-50 transition shadow-sm">
                🎁 Xác nhận đã tặng
            </button>

            <!-- Nút cho Receiver -->
            <button id="qrReceiver1" onclick="confirmTransaction('receiver_confirm')"
                    class="hidden whitespace-nowrap bg-white border border-blue-200 text-blue-700 text-xs px-3 py-1.5 rounded-full hover:bg-blue-50 transition shadow-sm">
                ✅ Xác nhận đã nhận
            </button>
            <button id="qrReceiver2" onclick="sendQuickReply('Bạn ơi, khi nào mình có thể qua lấy đồ được ạ?')"
                    class="hidden whitespace-nowrap bg-white border border-gray-200 text-gray-600 text-xs px-3 py-1.5 rounded-full hover:bg-gray-100 transition shadow-sm">
                🕒 Hẹn lịch nhận
            </button>
        </div>
        <!-- --------------------------- -->

        <div class="p-3 border-t bg-white flex gap-2">
            <input type="text" id="chatInput" disabled class="flex-1 border rounded-full px-4 py-2 text-sm bg-gray-50" placeholder="Nhập tin nhắn...">
            <button onclick="sendMessage()" id="btnSend" disabled class="bg-emerald-600 text-white rounded-full w-10 h-10 flex items-center justify-center hover:bg-emerald-700">➤</button>
        </div>
    </div>
</div>

<!-- SỬA ĐỔI: Giảm z-index xuống z-40 -->
<button onclick="toggleAiModal()" class="fixed bottom-24 right-6 bg-blue-600 hover:bg-blue-700 text-white p-4 rounded-full shadow-2xl z-40 transition transform hover:scale-110 flex items-center justify-center border-4 border-white" > <span class="text-2xl">🤖</span>
</button>

<!-- SỬA ĐỔI: Giảm z-index xuống z-40 -->
<div id="aiModal" class="fixed bottom-40 right-6 w-80 h-[450px] bg-white rounded-2xl shadow-2xl border border-slate-200 hidden z-40 flex flex-col overflow-hidden font-sans" >
    <div class="bg-gradient-to-r from-blue-600 to-blue-500 p-4 flex justify-between items-center text-white">
        <div class="flex items-center gap-2">
            <span class="text-2xl">🤖</span>
            <div>
                <h3 class="font-bold text-sm">Trợ lý EcoBot</h3>
                <p class="text-[10px] opacity-90">Hỏi tôi về cách xử lý rác!</p>
            </div>
        </div>
        <button onclick="toggleAiModal()" class="text-white hover:text-blue-200 font-bold">✕</button>
    </div>
    <div id="aiChatBody" class="flex-1 p-4 overflow-y-auto bg-slate-50 space-y-3 text-sm">
        <div class="flex items-start gap-2">
            <div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-xs shrink-0">🤖</div>
            <div class="bg-white border p-3 rounded-2xl rounded-tl-none shadow-sm max-w-[85%] text-slate-700">
                Xin chào! Bạn đang có loại rác thải nào cần xử lý? (VD: Pin cũ, thuốc hết hạn, đồ điện tử...)
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 gap-2 mt-2 px-2">
            <button onclick="quickAction('name')" class="text-left text-xs bg-blue-50 hover:bg-blue-100 text-blue-700 py-2 px-3 rounded-lg border border-blue-100 transition">
                🔍 Tìm sản phẩm theo tên...
            </button>
            <button onclick="quickAction('category')" class="text-left text-xs bg-blue-50 hover:bg-blue-100 text-blue-700 py-2 px-3 rounded-lg border border-blue-100 transition">
                📂 Tìm sản phẩm theo danh mục...
            </button>
            <button onclick="quickAction('point')" class="text-left text-xs bg-blue-50 hover:bg-blue-100 text-blue-700 py-2 px-3 rounded-lg border border-blue-100 transition">
                📍 Tìm điểm thu gom gần đây
            </button>
            <button onclick="quickAction('guide')" class="text-left text-xs bg-blue-50 hover:bg-blue-100 text-blue-700 py-2 px-3 rounded-lg border border-blue-100 transition">
                ❓ Cách tích điểm EcoPoints?
            </button>
        </div>
    </div>
    <div class="p-3 border-t bg-white">
        <div class="flex gap-2">
            <input type="text" id="aiInput" class="flex-1 border rounded-full px-4 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Nhập câu hỏi...">
            <button onclick="sendAiQuestion()" class="bg-blue-600 text-white w-9 h-9 rounded-full flex items-center justify-center hover:bg-blue-700">➤</button>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
<script>
    // --- KHỞI TẠO ---
    const currentUserIdStr = "${sessionScope.currentUser != null ? sessionScope.currentUser.userId : ''}";
    const currentUserName = "${sessionScope.currentUser != null ? sessionScope.currentUser.username : ''}";
    const currentUserRole = "${sessionScope.currentUser != null ? sessionScope.currentUser.role : ''}";
    const currentUserId = currentUserIdStr ? Number(currentUserIdStr) : null;
    const MAPTILER_API_KEY = 'N9qb9p6GF8fszXu3BPWt'; // Thay thế bằng API Key của bạn

    let chatSocket = null;
    let currentReceiverId = null;
    let currentDiscussingItemId = null;
    let isOwnerOfCurrentItem = false;
    let miniMap, locationMarker;
    let pointMap, pointMarker;
    let pointLatLng = { lat: 10.7769, lng: 106.7009 };
    let currentLatLng = { lat: 10.7769, lng: 106.7009 };
    let loadedItemIds = new Set();

    // Lưu trữ các layer để quản lý (xóa/thêm lại)
    let itemLayers = [];
    let pointLayers = [];

    // --- ICONS ---
    var greenIcon = new L.Icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
    });

    var yellowIcon = new L.Icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-yellow.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
    });

    var blueIcon = new L.Icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
    });

    document.addEventListener("DOMContentLoaded", function() {
        if (currentUserId) {
            connectWebSocket();
            loadInboxList();
        }
        loadCategoriesForFilter(); // Load danh mục vào dropdown filter
        loadItems();
        loadCollectionPoints();

        // Tải thêm dữ liệu khi di chuyển bản đồ
        map.on('moveend', loadItems);

        // --- MỚI: Lắng nghe sự kiện click để ẩn gợi ý ---
        document.addEventListener('click', function(e) {
            const suggestionList = document.getElementById('suggestionList');
            const itemAddress = document.getElementById('itemAddress');
            if (suggestionList && !suggestionList.contains(e.target) && e.target !== itemAddress) {
                suggestionList.classList.add('hidden');
            }
        });
        // ------------------------------------------------
    });

    // --- 1. MAP & LOAD DATA ---
    const map = L.map('map').setView([10.7769, 106.7009], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OSM' }).addTo(map);

    // Hàm reload khi thay đổi filter
    function reloadMapData() {
        // Xóa các layer cũ
        itemLayers.forEach(layer => map.removeLayer(layer));
        itemLayers = [];
        loadedItemIds.clear();

        pointLayers.forEach(layer => map.removeLayer(layer));
        pointLayers = [];

        // Load lại dữ liệu mới
        loadItems();
        loadCollectionPoints();
    }

    async function loadItems() {
        try {
            const bounds = map.getBounds();
            const categoryId = document.getElementById('filterCategory').value;

            const params = new URLSearchParams({
                minLat: bounds.getSouth(),
                maxLat: bounds.getNorth(),
                minLng: bounds.getWest(),
                maxLng: bounds.getEast()
            });

            if (categoryId) {
                params.append('categoryId', categoryId);
            }

            const response = await fetch('${pageContext.request.contextPath}/api/items?' + params.toString());
            const items = await response.json();

            items.forEach(item => {
                if (item.location && !loadedItemIds.has(item.itemId)) {
                    loadedItemIds.add(item.itemId);

                    // --- SỬA ĐỔI: Logic hiển thị ảnh ---
                    let imgUrl;
                    if (item.imageUrl && item.imageUrl.startsWith('http')) {
                        imgUrl = item.imageUrl; // Dùng trực tiếp nếu là link Cloudinary/Internet
                    } else if (item.imageUrl) {
                        imgUrl = '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(item.imageUrl); // Logic cũ
                    } else {
                        imgUrl = 'https://placehold.co/200x150'; // Ảnh mặc định
                    }
                    // -----------------------------------

                    let actionBtn = '';

                    if (currentUserId) {
                        if (item.giverId === currentUserId) {
                            actionBtn = `<button onclick="openManageChat(\${item.itemId}, '\${item.title}')" class="w-full bg-slate-100 text-slate-700 text-xs font-bold py-1.5 rounded hover:bg-slate-200 border border-slate-300">Quản lý & Chốt đơn 📩</button>`;
                        } else {
                            actionBtn = `<button onclick="requestItem(\${item.itemId}, \${item.giverId}, '\${item.giverName || 'Người tặng'}', '\${item.title}')" class="w-full bg-emerald-600 text-white text-xs font-bold py-1.5 rounded hover:bg-emerald-700 shadow-sm">Xin món này 🎁</button>`;
                        }
                    } else {
                        actionBtn = `<a href="${pageContext.request.contextPath}/login" class="block w-full text-center bg-gray-100 text-gray-700 text-xs font-bold py-1.5 rounded hover:bg-gray-200">Đăng nhập để nhận</a>`;
                    }

                    // --- MỚI: Thêm nút chỉ đường ---
                    const directionsBtn = `<a href="https://www.google.com/maps/search/?api=1&query=\${item.location.latitude},\${item.location.longitude}" target="_blank" class="block w-full bg-slate-100 text-slate-600 text-xs font-bold py-1.5 rounded hover:bg-slate-200 border border-slate-300 mt-2 text-center">🗺️ Chỉ đường</a>`;
                    // -------------------------------

                    // --- MỚI: Hiển thị địa chỉ nếu có ---
                    let addressHtml = '';
                    if (item.address) {
                        addressHtml = `<p class="text-xs text-gray-500 mb-1">📍 \${item.address}</p>`;
                    }
                    // ------------------------------------

                    const content = `<div><img src="\${imgUrl}" class="custom-popup-img"><div class="custom-popup-body"><h3 class="font-bold text-sm">\${item.title}</h3><p class="text-xs text-gray-500 mb-2">Người tặng: \${item.giverName}</p>\${addressHtml}\${actionBtn}\${directionsBtn}</div></div>`;
                    const marker = L.marker([item.location.latitude, item.location.longitude], {icon: blueIcon}).addTo(map).bindPopup(content);
                    itemLayers.push(marker);
                }
            });
        } catch (e) { console.error(e); }
    }

    async function loadCollectionPoints() {
        try {
            const showPublic = document.getElementById('filterPublicPoint').checked;
            const showCompany = document.getElementById('filterCompanyPoint').checked;

            if (!showPublic && !showCompany) return; // Không hiển thị gì cả

            const response = await fetch('${pageContext.request.contextPath}/api/collection-points');
            const points = await response.json();

            // Xóa các layer cũ (nếu chưa xóa ở reloadMapData)
            // map.eachLayer((layer) => { if (layer.options.icon === greenIcon || layer.options.icon === yellowIcon) map.removeLayer(layer); });

            points.forEach(p => {
                let icon;
                let popupHeader;
                let shouldShow = false;

                if (p.ownerRole === 'COLLECTOR_COMPANY') {
                    if (showCompany) {
                        icon = yellowIcon;
                        popupHeader = `<div class="bg-yellow-100 text-yellow-800 text-xs font-bold px-2 py-1 rounded mb-2 inline-block">🏢 Điểm thu gom Doanh nghiệp</div>`;
                        shouldShow = true;
                    }
                } else {
                    if (showPublic) {
                        icon = greenIcon;
                        popupHeader = `<div class="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded mb-2 inline-block">♻️ Điểm tập kết công cộng</div>`;
                        shouldShow = true;
                    }
                }

                if (shouldShow) {
                    const content = `
                        <div class="text-center p-2">
                            \${popupHeader}
                            <h3 class="font-bold text-slate-800 text-sm mb-1">\${p.name}</h3>
                            <p class="text-xs text-gray-500 mb-2">📍 \${p.address}</p>
                            <a href="https://www.google.com/maps/search/?api=1&query=\${p.latitude},\${p.longitude}" target="_blank" class="block w-full bg-slate-100 text-slate-600 text-xs font-bold py-1.5 rounded hover:bg-slate-200 border border-slate-300">🗺️ Chỉ đường</a>
                        </div>`;
                    const marker = L.marker([p.latitude, p.longitude], {icon: icon}).addTo(map).bindPopup(content);
                    pointLayers.push(marker);
                }
            });
        } catch (e) { console.error(e); }
    }

    // --- 2. LOGIC NÚT BẤM (User Items) ---
    async function requestItem(itemId, giverId, giverName, itemTitle) {
        if (!currentUserId) { window.location.href = '${pageContext.request.contextPath}/login'; return; }
        currentDiscussingItemId = itemId;
        isOwnerOfCurrentItem = false;
        try {
            const fd = new URLSearchParams(); fd.append('itemId', itemId);
            fetch('${pageContext.request.contextPath}/request-item', { method: 'POST', body: fd });
        } catch(e){}
        openChatWindow();
        await loadInboxList();
        selectUserChat(giverId, giverName, itemId, itemTitle, giverId); // Truyền thêm tham số
        setTimeout(() => sendMessageAuto("Chào bạn, mình muốn xin món '" + itemTitle + "'. Nó còn không ạ?"), 500);
    }

    async function openManageChat(itemId, itemTitle) {
        currentDiscussingItemId = itemId;
        isOwnerOfCurrentItem = true;
        openChatWindow();
        updateHeaderInfo(itemTitle);
        document.getElementById('chatTitle').innerText = 'Chọn người nhận';
        document.getElementById('chatHeaderAvatar').innerText = '?';
        document.getElementById('chatMessages').innerHTML = '<div class="text-center text-xs text-gray-400 mt-20">⬅️ Chọn một người trong danh sách bên trái<br>để tặng món <b>' + itemTitle + '</b></div>';
        document.getElementById('chatInput').disabled = true;
        document.getElementById('btnSend').disabled = true;
        document.getElementById('btnGiverConfirm').classList.add('hidden');
        document.getElementById('btnReceiverConfirm').classList.add('hidden');
        loadInboxList();
    }

    // --- 3. CHAT UI LOGIC ---
    function openChatWindow() {
        document.getElementById('chatModal').classList.remove('hidden');
        document.getElementById('msgBadge').classList.add('hidden');
    }

    function toggleChatModal(forceClose) {
        const modal = document.getElementById('chatModal');
        if (forceClose) {
            modal.classList.add('hidden');
            currentDiscussingItemId = null;
            isOwnerOfCurrentItem = false;
            currentReceiverId = null;
        } else {
            modal.classList.toggle('hidden');
            if (!modal.classList.contains('hidden')) loadInboxList();
        }
    }

    async function loadInboxList() {
        try {
            const res = await fetch('${pageContext.request.contextPath}/api/chat?action=inbox');
            const users = await res.json();
            const listEl = document.getElementById('inboxList');
            listEl.innerHTML = '';
            if (users.length === 0) { listEl.innerHTML = '<div class="text-center text-xs text-gray-400 mt-4">Chưa có tin nhắn</div>'; return; }
            users.forEach(u => {
                const activeClass = (u.userId == currentReceiverId) ? 'bg-emerald-50 border-emerald-500' : 'border-transparent hover:bg-gray-50';

                // SỬA ĐỔI: Lưu thông tin item vào data attributes
                const itemId = u.itemId || '';
                const itemName = u.itemName || '';
                const giverId = u.giverId || '';

                listEl.innerHTML += `
                    <div onclick="selectUserChat(\${u.userId}, '\${u.username}', '\${itemId}', '\${itemName}', '\${giverId}')"
                         class="cursor-pointer p-3 border-l-4 \${activeClass} transition flex items-center gap-3 border-b border-gray-100">
                        <div class="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center font-bold text-slate-600">\${u.username.charAt(0).toUpperCase()}</div>
                        <div class="flex-1 min-w-0">
                            <div class="font-bold text-sm truncate">\${u.username}</div>
                            <div class="text-xs text-gray-500 truncate">\${u.lastMsg || '...'}</div>
                        </div>
                    </div>`;
            });
        } catch (e) {}
    }

    // SỬA ĐỔI: Nhận thêm tham số itemId, itemName, giverId
    async function selectUserChat(userId, username, itemId, itemName, giverId) {
        currentReceiverId = userId;
        document.getElementById('chatTitle').innerText = username;
        document.getElementById('chatHeaderAvatar').innerText = username.charAt(0).toUpperCase();
        const input = document.getElementById('chatInput');
        input.disabled = false; input.classList.remove('bg-gray-50');
        document.getElementById('btnSend').disabled = false;
        document.getElementById('inboxPanel').classList.add('hidden');
        const detailPanel = document.getElementById('chatDetailPanel');
        detailPanel.classList.remove('hidden');
        detailPanel.classList.add('flex');

        // Ẩn các nút xác nhận trước khi load logic
        const btnGiver = document.getElementById('btnGiverConfirm');
        const btnReceiver = document.getElementById('btnReceiverConfirm');
        btnGiver.classList.add('hidden');
        btnReceiver.classList.add('hidden');

        // MỚI: Hiển thị Quick Replies
        document.getElementById('quickReplies').classList.remove('hidden');

        // Reset trạng thái Quick Replies về ẩn hết trước khi loadHistory quyết định
        document.getElementById('qrGiver').classList.add('hidden');
        document.getElementById('qrReceiver1').classList.add('hidden');
        document.getElementById('qrReceiver2').classList.add('hidden');

        // Cập nhật thông tin item nếu có
        if (itemId && itemId !== 'undefined') {
            currentDiscussingItemId = itemId;
            updateHeaderInfo(itemName);

            // Xác định vai trò
            if (giverId && giverId != 'undefined') {
                isOwnerOfCurrentItem = (Number(giverId) === currentUserId);
            } else {
                // Fallback nếu không có giverId (ít xảy ra nếu API đúng)
                isOwnerOfCurrentItem = false;
            }

            // Mặc định hiển thị trạng thái PENDING (sẽ bị override bởi loadHistory nếu có lịch sử)
            if (isOwnerOfCurrentItem) {
                document.getElementById('qrGiver').classList.remove('hidden');
            } else {
                document.getElementById('qrReceiver2').classList.remove('hidden');
            }

        } else {
            // Nếu không có item info (chat thông thường), ẩn header item
            document.getElementById('chatItemInfo').classList.add('hidden');
            currentDiscussingItemId = null;
        }

        loadHistory(userId);
        loadInboxList();
    }

    function backToInbox() {
        document.getElementById('chatDetailPanel').classList.add('hidden');
        document.getElementById('chatDetailPanel').classList.remove('flex');
        document.getElementById('inboxPanel').classList.remove('hidden');
    }

    // --- 4. LOGIC ĐÁNH GIÁ & HOÀN TẤT ---
    function openRatingModal() {
        document.getElementById('ratingModal').classList.remove('hidden');
    }

    async function submitRating() {
        const rating = document.getElementById('ratingValue').value;
        const comment = document.getElementById('ratingComment').value;
        if (!comment) { alert("Hãy viết vài lời nhận xét!"); return; }
        try {
            const fd = new URLSearchParams();
            fd.append('itemId', currentDiscussingItemId);
            fd.append('rating', rating);
            fd.append('comment', comment);
            const res = await fetch('${pageContext.request.contextPath}/api/rate-transaction', { method: 'POST', body: fd });
            const data = await res.json();
            if (data.status === 'success') {
                alert("🎉 Cảm ơn bạn! Giao dịch hoàn tất.");
                document.getElementById('ratingModal').classList.add('hidden');
                document.getElementById('btnReceiverConfirm').classList.add('hidden');
                sendMessageAuto("✅ Mình đã nhận được đồ và đánh giá " + rating + " sao. Cảm ơn bạn!");
                currentDiscussingItemId = null;
                loadItems();
            } else {
                alert("Lỗi: " + data.message);
            }
        } catch (e) { alert("Lỗi kết nối"); }
    }

    async function loadHistory(userId) {
        const chatBox = document.getElementById('chatMessages');
        chatBox.innerHTML = '<div class="text-center text-xs text-gray-400 mt-10">Đang tải...</div>';
        try {
            const res = await fetch('${pageContext.request.contextPath}/api/chat?action=history&partnerId=' + userId);
            const msgs = await res.json();
            chatBox.innerHTML = '';

            // Logic check status từ tin nhắn hệ thống (tạm thời) hoặc cần API riêng lấy status transaction
            // Để đơn giản, ta sẽ dựa vào tin nhắn hệ thống mới nhất
            let lastSystemMsg = "";

            msgs.forEach(m => {
                if (m.content.startsWith("SYSTEM_GIFT:")) {
                    // SỬA ĐỔI QUAN TRỌNG: Chỉ cập nhật trạng thái nếu tin nhắn thuộc về item đang thảo luận
                    if (currentDiscussingItemId && m.itemId == currentDiscussingItemId) {
                        lastSystemMsg = m.content;
                    }
                    let cleanText = m.content.replace("SYSTEM_GIFT:", "");
                    appendSystemMessage(cleanText);
                } else {
                    appendMessage(m.content, m.senderId === currentUserId ? 'outgoing' : 'incoming');
                }
            });

            // Cập nhật nút dựa trên tin nhắn hệ thống cuối cùng
            const btnGiver = document.getElementById('btnGiverConfirm');
            const btnReceiver = document.getElementById('btnReceiverConfirm');

            // Quick Replies Elements
            const qrGiver = document.getElementById('qrGiver');
            const qrReceiver1 = document.getElementById('qrReceiver1');
            const qrReceiver2 = document.getElementById('qrReceiver2');

            if (currentDiscussingItemId) {
                if (isOwnerOfCurrentItem) {
                    // --- GIVER LOGIC ---
                    if (!lastSystemMsg.includes("CONFIRMED") && !lastSystemMsg.includes("COMPLETED")) {
                        // PENDING: Hiện nút xác nhận cho
                        btnGiver.classList.remove('hidden');
                        qrGiver.classList.remove('hidden');
                    } else {
                        // CONFIRMED/COMPLETED: Ẩn nút xác nhận cho
                        btnGiver.classList.add('hidden');
                        qrGiver.classList.add('hidden');
                    }
                } else {
                    // --- RECEIVER LOGIC ---
                    if (lastSystemMsg.includes("CONFIRMED") && !lastSystemMsg.includes("COMPLETED")) {
                        // CONFIRMED: Hiện nút nhận, Ẩn nút hẹn
                        btnReceiver.classList.remove('hidden');
                        qrReceiver1.classList.remove('hidden');
                        qrReceiver2.classList.add('hidden');
                    } else if (!lastSystemMsg.includes("CONFIRMED") && !lastSystemMsg.includes("COMPLETED")) {
                        // PENDING: Ẩn nút nhận, Hiện nút hẹn
                        btnReceiver.classList.add('hidden');
                        qrReceiver1.classList.add('hidden');
                        qrReceiver2.classList.remove('hidden');
                    } else {
                        // COMPLETED: Ẩn hết
                        btnReceiver.classList.add('hidden');
                        qrReceiver1.classList.add('hidden');
                        qrReceiver2.classList.add('hidden');
                    }
                }
            }

            chatBox.scrollTop = chatBox.scrollHeight;
        } catch(e) { chatBox.innerHTML = 'Lỗi tải tin nhắn'; }
    }

    // --- 5. CONFIRM TRANSACTION (2-WAY) ---
    async function confirmTransaction(action) {
        const receiverName = document.getElementById('chatTitle').innerText;
        let confirmMsg = "";
        if (action === 'giver_confirm') confirmMsg = "Bạn xác nhận đã giao món đồ này cho " + receiverName + "?\n(Người nhận sẽ có 3 ngày để xác nhận)";
        else confirmMsg = "Bạn xác nhận đã nhận được món đồ này?";

        if (!confirm(confirmMsg)) return;

        try {
            const fd = new URLSearchParams();
            fd.append('itemId', currentDiscussingItemId);

            // SỬA ĐỔI: Logic chọn receiverId
            // Nếu tôi là Giver, receiverId là currentReceiverId (đối tác)
            // Nếu tôi là Receiver, receiverId là currentUserId (chính tôi)
            let targetReceiverId;
            if (isOwnerOfCurrentItem) {
                targetReceiverId = currentReceiverId;
            } else {
                targetReceiverId = currentUserId;
            }
            fd.append('receiverId', targetReceiverId);

            fd.append('action', action); // giver_confirm hoặc receiver_confirm

            const res = await fetch('${pageContext.request.contextPath}/api/confirm-transaction', { method: 'POST', body: fd });
            const data = await res.json();

            if (data.status === 'success') {
                alert("✅ " + data.message);

                // Gửi tin nhắn hệ thống
                let sysMsg = "";
                if (action === 'giver_confirm') {
                    // SỬA ĐỔI: Trạng thái CONFIRMED
                    sysMsg = "SYSTEM_GIFT:Người tặng đã xác nhận giao đồ. Trạng thái: CONFIRMED. Bạn hãy xác nhận khi đã nhận được nhé!";
                    document.getElementById('btnGiverConfirm').classList.add('hidden');
                    document.getElementById('qrGiver').classList.add('hidden');
                } else {
                    sysMsg = "SYSTEM_GIFT:Người nhận đã xác nhận nhận đồ. Trạng thái: COMPLETED. Giao dịch hoàn tất!";
                    document.getElementById('btnReceiverConfirm').classList.add('hidden');
                    document.getElementById('qrReceiver1').classList.add('hidden');
                    openRatingModal(); // Mở đánh giá ngay sau khi nhận
                }

                if (chatSocket && currentReceiverId) {
                    chatSocket.send(JSON.stringify({ receiverId: currentReceiverId, content: sysMsg }));
                }
                appendSystemMessage(sysMsg.replace("SYSTEM_GIFT:", ""));

                loadItems();
                setTimeout(loadInboxList, 500);
            } else {
                alert("❌ Lỗi: " + data.message);
            }
        } catch (e) { alert("❌ Lỗi kết nối"); }
    }

    // --- MỚI: Hàm gửi tin nhắn nhanh ---
    function sendQuickReply(text) {
        sendMessageAuto(text);
    }
    // ----------------------------------

    // --- UTILS & WS ---
    function updateHeaderInfo(title) {
        document.getElementById('chatItemInfo').classList.remove('hidden');
        document.getElementById('chatItemName').innerText = title;
    }

    function connectWebSocket() {
        if (chatSocket && chatSocket.readyState === WebSocket.OPEN) return;
        const wsUrl = (window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.host + '${pageContext.request.contextPath}/chat/' + currentUserId;
        chatSocket = new WebSocket(wsUrl);
        chatSocket.onmessage = (e) => {
            const data = JSON.parse(e.data);
            if (data.content.startsWith("SYSTEM_GIFT:")) {
                const msgText = data.content.replace("SYSTEM_GIFT:", "");
                appendSystemMessage(msgText);

                // Cập nhật nút khi nhận tin nhắn hệ thống
                // SỬA ĐỔI: Kiểm tra CONFIRMED
                if (data.content.includes("CONFIRMED") && !isOwnerOfCurrentItem) {
                    document.getElementById('btnReceiverConfirm').classList.remove('hidden');
                    document.getElementById('qrReceiver1').classList.remove('hidden');
                    document.getElementById('qrReceiver2').classList.add('hidden');
                }

                loadInboxList();
                loadItems();
                return;
            }
            if (data.senderId == currentReceiverId) appendMessage(data.content, 'incoming');
            else document.getElementById('msgBadge').classList.remove('hidden');
            loadInboxList();
        };
        chatSocket.onclose = () => setTimeout(connectWebSocket, 3000);
    }

    function sendMessage() { const inp = document.getElementById('chatInput'); if (inp.value.trim()) { sendMessageAuto(inp.value.trim()); inp.value = ''; } }
    function sendMessageAuto(txt) {
        if (chatSocket && currentReceiverId) {
            chatSocket.send(JSON.stringify({ receiverId: currentReceiverId, content: txt }));
            if (txt.startsWith("SYSTEM_GIFT:")) appendSystemMessage(txt.replace("SYSTEM_GIFT:", ""));
            else appendMessage(txt, 'outgoing');
            setTimeout(loadInboxList, 500);
        }
    }
    function appendMessage(txt, type) {
        const box = document.getElementById('chatMessages');
        const cls = type === 'outgoing' ? 'bg-emerald-600 text-white ml-auto rounded-tr-none' : 'bg-white border text-gray-700 mr-auto rounded-tl-none';
        box.innerHTML += `<div class="w-fit max-w-[80%] px-4 py-2 rounded-xl mb-2 text-sm shadow-sm \${cls}">\${txt}</div>`;
        box.scrollTop = box.scrollHeight;
    }
    function appendSystemMessage(txt) {
        const box = document.getElementById('chatMessages');
        box.innerHTML += `<div class="text-center my-4"><span class="bg-yellow-100 text-yellow-800 text-xs font-bold px-3 py-1 rounded-full border border-yellow-200">🎁 \${txt}</span></div>`;
        box.scrollTop = box.scrollHeight;
    }
    document.getElementById('chatInput').addEventListener('keypress', (e) => { if(e.key==='Enter') sendMessage(); });

    // --- AI BOT LOGIC ---
    function toggleAiModal() { const modal = document.getElementById('aiModal'); modal.classList.toggle('hidden'); if(!modal.classList.contains('hidden')) { document.getElementById('aiInput').focus(); } }
    document.getElementById('aiInput').addEventListener('keypress', function(e) { if(e.key === 'Enter') sendAiQuestion(); });

    // --- MỚI: Hàm xử lý Quick Action ---
    function quickAction(type) {
        const input = document.getElementById('aiInput');
        if (type === 'name') {
            input.value = "Tìm sản phẩm tên: ";
            input.focus();
        } else if (type === 'category') {
            input.value = "Tìm sản phẩm thuộc danh mục: ";
            input.focus();
        } else if (type === 'point') {
            input.value = "Tìm điểm thu gom gần đây";
            sendAiQuestion();
        } else if (type === 'guide') {
            input.value = "Làm thế nào để tích điểm EcoPoints?";
            sendAiQuestion();
        }
    }
    // -----------------------------------

    async function sendAiQuestion() {
        const input = document.getElementById('aiInput');
        const question = input.value.trim();
        if(!question) return;
        appendAiMessage(question, 'user');
        input.value = '';
        const loadingId = appendAiMessage("Đang suy nghĩ...", 'bot', true);
        try {
            const formData = new URLSearchParams(); formData.append('question', question);
            const res = await fetch('${pageContext.request.contextPath}/api/ai-assistant', { method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: formData });
            const data = await res.json();
            document.getElementById(loadingId).remove();
            appendAiMessage(data.answer, 'bot');

            // --- SỬA ĐỔI: Hiển thị lại Quick Replies ---
            if (data.quickReplies && data.quickReplies.length > 0) {
                let html = '<div class="grid grid-cols-1 gap-2 mt-2 px-2">';

                // Map các text trả về thành action type tương ứng
                data.quickReplies.forEach(text => {
                    let actionType = '';
                    if (text.includes("tên")) actionType = 'name';
                    else if (text.includes("danh mục")) actionType = 'category';
                    else if (text.includes("điểm thu gom")) actionType = 'point';
                    else if (text.includes("tích điểm")) actionType = 'guide';

                    if (actionType) {
                        html += `<button onclick="quickAction('\${actionType}')" class="text-left text-xs bg-blue-50 hover:bg-blue-100 text-blue-700 py-2 px-3 rounded-lg border border-blue-100 transition">\${text}</button>`;
                    }
                });

                html += '</div>';
                appendAiHtml(html);
            }
            // -------------------------------------------

            if (data.suggestions && data.suggestions.length > 0) {
                let html = '<div class="flex flex-col gap-2 mt-2">';
                data.suggestions.forEach(s => {
                    html += `<div class="bg-blue-50 p-2 rounded-lg border border-blue-100 cursor-pointer hover:bg-blue-100 transition flex items-center gap-2" onclick="flyToLocation(\${s.lat}, \${s.lng}, '\${s.name}')"><div class="text-xl">📍</div><div class="overflow-hidden"><div class="font-bold text-blue-800 text-xs truncate">\${s.name}</div><div class="text-[10px] text-slate-500 truncate">\${s.address}</div></div></div>`;
                });
                html += '</div>';
                appendAiHtml(html);
            }
        } catch (e) { document.getElementById(loadingId).innerText = "Lỗi kết nối server!"; }
    }
    function appendAiMessage(text, type, isTemp = false) {
        const chatBox = document.getElementById('aiChatBody');
        const id = 'msg-' + Date.now() + '-' + Math.floor(Math.random() * 1000);
        const align = type === 'user' ? 'justify-end' : 'justify-start';
        const bg = type === 'user' ? 'bg-blue-600 text-white rounded-tr-none' : 'bg-white border text-slate-700 rounded-tl-none';
        const avatar = type === 'bot' ? '<div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-xs shrink-0">🤖</div>' : '';
        const html = `<div id="\${id}" class="flex items-start gap-2 \${align}">\${avatar}<div class="\${bg} p-3 rounded-2xl shadow-sm max-w-[85%]">\${text}</div></div>`;
        chatBox.insertAdjacentHTML('beforeend', html);
        chatBox.scrollTop = chatBox.scrollHeight;
        return id;
    }
    function appendAiHtml(htmlContent) { const chatBox = document.getElementById('aiChatBody'); const wrapper = `<div class="flex items-start gap-2 justify-start"><div class="w-8 h-8"></div><div class="w-[85%]">\${htmlContent}</div></div>`; chatBox.insertAdjacentHTML('beforeend', wrapper); chatBox.scrollTop = chatBox.scrollHeight; }
    function flyToLocation(lat, lng, name) { map.flyTo([lat, lng], 16, { animate: true, duration: 1.5 }); L.popup().setLatLng([lat, lng]).setContent(`<div class="text-center font-bold text-sm">📍 \${name}</div>`).openOn(map); if (window.innerWidth < 768) { document.getElementById('aiModal').classList.add('hidden'); } }

    // --- LOGIC ADMIN/COMPANY ---
    const btnAddPoint = document.getElementById('btnAddPoint');
    if (btnAddPoint) {
        btnAddPoint.addEventListener('click', () => {
            document.getElementById('addPointModal').classList.remove('hidden');
            setTimeout(() => {
                const markerIcon = (currentUserRole === 'COLLECTOR_COMPANY') ? yellowIcon : greenIcon;
                if (!pointMap) {
                    pointMap = L.map('pointMiniMap').setView([pointLatLng.lat, pointLatLng.lng], 15);
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OSM' }).addTo(pointMap);
                    pointMarker = L.marker([pointLatLng.lat, pointLatLng.lng], { draggable: true, icon: markerIcon }).addTo(pointMap);
                    pointMarker.on('dragend', function(event) { pointLatLng = event.target.getLatLng(); });
                } else {
                    pointMap.invalidateSize();
                    if(pointMarker) pointMarker.setIcon(markerIcon);
                }
            }, 200);
        });
    }

    async function submitCollectionPoint() {
        const name = document.getElementById('pointName').value;
        const type = document.getElementById('pointType').value;
        const address = document.getElementById('pointAddress').value;
        if (!name || !address) { alert("Vui lòng nhập đủ thông tin!"); return; }
        if (!confirm("Xác nhận tạo điểm tập kết này?")) return;
        const formData = new URLSearchParams();
        formData.append("name", name); formData.append("type", type);
        formData.append("address", address);
        formData.append("latitude", pointLatLng.lat); formData.append("longitude", pointLatLng.lng);
        try {
            const res = await fetch('${pageContext.request.contextPath}/api/create-collection-point', {
                method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: formData
            });
            const data = await res.json();
            if (data.status === 'success') {
                alert("✅ " + data.message);
                document.getElementById('addPointModal').classList.add('hidden');
                loadCollectionPoints();
            } else { alert("❌ Lỗi: " + data.message); }
        } catch (e) { alert("❌ Lỗi kết nối server"); }
    }

    // --- ĐĂNG TIN ---
    document.getElementById('btnPostItem').addEventListener('click', () => { document.getElementById('giveAwayModal').classList.remove('hidden'); document.getElementById('step1').classList.remove('hidden'); });
    function closeModal(id) { document.getElementById(id).classList.add('hidden'); }
    function nextStep(n) { document.querySelectorAll('.modal-step').forEach(e=>e.classList.add('hidden')); document.getElementById('step'+n).classList.remove('hidden'); if(n===3) setTimeout(()=>{ if(!miniMap) {miniMap=L.map('miniMap').setView([currentLatLng.lat, currentLatLng.lng], 15); L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'OSM'}).addTo(miniMap); locationMarker=L.marker([currentLatLng.lat,currentLatLng.lng],{draggable:true}).addTo(miniMap); locationMarker.on('dragend',e=>currentLatLng=e.target.getLatLng()); } else miniMap.invalidateSize(); },200); }

    // --- MỚI: Hàm cập nhật điểm EcoPoints khi chọn danh mục ---
    function updateEcoPoints() {
        const select = document.getElementById('itemCategory');
        const selectedOption = select.options[select.selectedIndex];
        const points = selectedOption.getAttribute('data-points');
        document.getElementById('itemEcoPoints').value = points ? points : '';
    }
    // ---------------------------------------------------------

    async function loadCategories() { try { const r = await fetch('${pageContext.request.contextPath}/api/categories'); (await r.json()).forEach(c => document.getElementById('itemCategory').innerHTML += `<option value="\${c.categoryId}" data-points="\${c.fixedPoints}">\${c.name}</option>`); } catch(e){} }
    loadCategories();

    // --- MỚI: Load danh mục cho bộ lọc ---
    async function loadCategoriesForFilter() {
        try {
            const r = await fetch('${pageContext.request.contextPath}/api/categories');
            const categories = await r.json();
            const filterSelect = document.getElementById('filterCategory');
            categories.forEach(c => {
                filterSelect.innerHTML += `<option value="\${c.categoryId}">\${c.name}</option>`;
            });
        } catch(e){}
    }
    // -------------------------------------

    // --- MỚI: Tìm kiếm địa chỉ bằng MapTiler API ---
    async function searchAddress() {
        const address = document.getElementById('itemAddress').value;
        if (!address) return;

        try {
            const response = await fetch(`https://api.maptiler.com/geocoding/\${encodeURIComponent(address)}.json?key=\${MAPTILER_API_KEY}`);
            const data = await response.json();

            if (data.features && data.features.length > 0) {
                const [lng, lat] = data.features[0].center;
                currentLatLng = { lat, lng };

                // Cập nhật bản đồ mini
                miniMap.setView([lat, lng], 15);
                locationMarker.setLatLng([lat, lng]);
            } else {
                alert("Không tìm thấy địa chỉ này!");
            }
        } catch (e) {
            console.error(e);
            alert("Lỗi khi tìm kiếm địa chỉ.");
        }
    }
    // -----------------------------------------------

    // --- MỚI: Autocomplete Logic ---
    let debounceTimer;
    const addressInput = document.getElementById('itemAddress');
    const suggestionList = document.getElementById('suggestionList');

    addressInput.addEventListener('input', function() {
        clearTimeout(debounceTimer);
        const query = this.value.trim();

        if (query.length < 3) {
            suggestionList.classList.add('hidden');
            return;
        }

        debounceTimer = setTimeout(async () => {
            try {
                // SỬA ĐỔI: Dùng cộng chuỗi thay vì template literal để tránh lỗi JSP
                const url = 'https://api.maptiler.com/geocoding/' + encodeURIComponent(query) + '.json?key=' + MAPTILER_API_KEY + '&autocomplete=true&limit=5';
                const response = await fetch(url);
                const data = await response.json();

                suggestionList.innerHTML = '';
                if (data.features && data.features.length > 0) {
                    data.features.forEach(feature => {
                        const li = document.createElement('li');
                        li.className = 'px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm text-gray-700 border-b last:border-0';
                        li.innerText = feature.place_name;
                        li.onclick = () => {
                            // Tự động điền và sửa lỗi địa chỉ
                            addressInput.value = feature.place_name;

                            // Cập nhật tọa độ
                            const [lng, lat] = feature.center;
                            currentLatLng = { lat, lng };
                            miniMap.setView([lat, lng], 15);
                            locationMarker.setLatLng([lat, lng]);

                            suggestionList.classList.add('hidden');
                        };
                        suggestionList.appendChild(li);
                    });
                    suggestionList.classList.remove('hidden');
                } else {
                    suggestionList.classList.add('hidden');
                }
            } catch (e) {
                console.error(e);
            }
        }, 300); // Debounce 300ms
    });
    // -------------------------------

    async function submitItem() {
        const fd = new FormData();
        fd.append("title", document.getElementById('itemName').value);
        fd.append("description", document.getElementById('itemDescription').value);
        fd.append("category", document.getElementById('itemCategory').value);
        fd.append("ecoPoints", document.getElementById('itemEcoPoints').value);
        fd.append("itemPhoto", document.getElementById('itemPhoto').files[0]);
        fd.append("latitude", currentLatLng.lat);
        fd.append("longitude", currentLatLng.lng);
        fd.append("address", document.getElementById('itemAddress').value); // Gửi thêm địa chỉ

        try {
            const res = await fetch('${pageContext.request.contextPath}/post-item', {method:'POST', body:fd});
            const data = await res.json();
            if(res.ok && data.success) {
                alert(data.message);
                location.reload();
            } else {
                alert("Lỗi: " + (data.error || "Không thể đăng tin"));
            }
        } catch(e){
            alert("Lỗi kết nối khi đăng tin.");
        }
    }
</script>
</body>
</html>