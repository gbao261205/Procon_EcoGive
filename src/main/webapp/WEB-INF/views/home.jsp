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
        .custom-popup-img { width: 100%; height: 130px; object-fit: cover; }
        .custom-popup-body { padding: 12px; }
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        @keyframes popIn { 0% { transform: scale(0.8); opacity: 0; } 100% { transform: scale(1); opacity: 1; } }
        .gift-popup { animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
    </style>
</head>

<body class="h-screen flex flex-col bg-slate-50 relative">

<header class="bg-white shadow-sm z-20 px-6 py-3 flex justify-between items-center h-16 flex-shrink-0">
    <div class="flex items-center gap-2">
        <h1 class="text-2xl font-bold text-emerald-600 tracking-tight">EcoGive <span class="text-slate-400 font-normal text-sm">Map</span></h1>
    </div>
    <div class="flex items-center gap-4">
        <c:if test="${sessionScope.currentUser != null}">
            <div class="text-right hidden md:block">
                <div class="text-sm font-bold text-slate-700">${sessionScope.currentUser.username}</div>
                <div class="text-xs text-emerald-600">${sessionScope.currentUser.ecoPoints} EcoPoints</div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="text-sm font-medium text-red-500 hover:text-red-700 border border-red-200 px-3 py-1.5 rounded-lg hover:bg-red-50">Thoát</a>
        </c:if>
        <c:if test="${sessionScope.currentUser == null}">
            <a href="${pageContext.request.contextPath}/login" class="px-4 py-2 text-sm font-semibold text-emerald-600 bg-emerald-50 rounded-lg hover:bg-emerald-100 transition">Đăng nhập</a>
        </c:if>
        <button id="btnPostItem" class="px-4 py-2 text-sm font-bold text-white bg-emerald-600 rounded-lg shadow-md hover:bg-emerald-700 transition flex items-center gap-2"><span>＋</span> Đăng tin</button>
    </div>
</header>

<div id="map" class="flex-1 z-10 w-full h-full"></div>

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

<div id="giveAwayModal" class="fixed inset-0 hidden bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
    <div class="bg-white p-6 rounded-xl w-full max-w-lg shadow-2xl relative">
        <button onclick="closeModal('giveAwayModal')" class="absolute top-4 right-4 text-gray-400 hover:text-gray-600">✕</button>
        <h2 class="text-2xl font-bold mb-6 text-emerald-700 text-center">Đăng tin Tặng đồ</h2>
        <div id="step1" class="modal-step">
            <input type="text" id="itemName" placeholder="Tên vật phẩm" class="w-full p-3 mb-3 border rounded-lg" required />
            <select id="itemCategory" class="w-full p-3 mb-3 border rounded-lg bg-white" required><option value="" disabled selected>-- Chọn danh mục --</option></select>
            <textarea id="itemDescription" placeholder="Mô tả..." rows="3" class="w-full p-3 mb-4 border rounded-lg" required></textarea>
            <button onclick="nextStep(2)" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold">Tiếp tục</button>
        </div>
        <div id="step2" class="modal-step hidden">
            <input type="file" id="itemPhoto" accept="image/*" class="w-full p-3 mb-4 border rounded-lg" required />
            <button onclick="nextStep(3)" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold">Tiếp tục</button>
        </div>
        <div id="step3" class="modal-step hidden">
            <div id="miniMap" class="h-64 w-full rounded-lg mb-4 border"></div>
            <button onclick="submitItem()" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-bold">Đăng tin</button>
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
                        📦 Đang trao đổi: <span id="chatItemName" class="font-bold text-emerald-600 truncate max-w-[120px]">...</span>
                    </div>
                </div>
            </div>
            <button id="btnConfirmGive" onclick="confirmGiveItem()" class="hidden bg-emerald-600 text-white text-xs font-bold px-3 py-1.5 rounded hover:bg-emerald-700 shadow-md animate-pulse">
                🎁 Tặng ngay
            </button>
            <button onclick="toggleChatModal(true)" class="hidden md:block text-slate-400 hover:text-slate-600">✕</button>
        </div>

        <div id="chatMessages" class="flex-1 p-4 overflow-y-auto bg-slate-50 text-sm space-y-3">
            <div class="text-center text-xs text-gray-400 mt-20">Chọn hội thoại hoặc bấm Nhận trên bản đồ</div>
        </div>

        <div class="p-3 border-t bg-white flex gap-2">
            <input type="text" id="chatInput" disabled class="flex-1 border rounded-full px-4 py-2 text-sm bg-gray-50" placeholder="Nhập tin nhắn...">
            <button onclick="sendMessage()" id="btnSend" disabled class="bg-emerald-600 text-white rounded-full w-10 h-10 flex items-center justify-center hover:bg-emerald-700">➤</button>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
<script>
    // --- KHỞI TẠO ---
    const currentUserIdStr = "${sessionScope.currentUser != null ? sessionScope.currentUser.userId : ''}";
    const currentUserName = "${sessionScope.currentUser != null ? sessionScope.currentUser.username : ''}";
    const currentUserId = currentUserIdStr ? Number(currentUserIdStr) : null;

    let chatSocket = null;
    let currentReceiverId = null;
    let currentDiscussingItemId = null;
    let isOwnerOfCurrentItem = false;
    let miniMap, locationMarker;
    let currentLatLng = { lat: 10.7769, lng: 106.7009 };

    document.addEventListener("DOMContentLoaded", function() {
        if (currentUserId) {
            connectWebSocket();
            loadInboxList();
        }
        loadItems();
    });

    // --- 1. LOAD ITEMS ---
    const map = L.map('map').setView([10.7769, 106.7009], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OSM' }).addTo(map);

    async function loadItems() {
        try {
            const response = await fetch('${pageContext.request.contextPath}/api/items');
            const items = await response.json();

            map.eachLayer((layer) => { if (layer instanceof L.Marker && layer !== locationMarker) map.removeLayer(layer); });

            items.forEach(item => {
                if (item.location) {
                    let imgUrl = item.imageUrl ? '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(item.imageUrl) : 'https://placehold.co/200x150';
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

                    const content = `<div><img src="\${imgUrl}" class="custom-popup-img"><div class="custom-popup-body"><h3 class="font-bold text-sm">\${item.title}</h3><p class="text-xs text-gray-500 mb-2">Người tặng: \${item.giverName}</p>\${actionBtn}</div></div>`;
                    L.marker([item.location.latitude, item.location.longitude]).addTo(map).bindPopup(content);
                }
            });
        } catch (e) { console.error(e); }
    }

    // --- 2. XỬ LÝ NÚT BẤM (Fix logic UI) ---

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
        selectUserChat(giverId, giverName);
        updateHeaderInfo(itemTitle);

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
        document.getElementById('btnConfirmGive').classList.add('hidden');

        loadInboxList();
    }

    // --- 3. CHAT UI LOGIC (ĐÃ SỬA LỖI MẤT INBOX) ---

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
                listEl.innerHTML += `
                    <div onclick="selectUserChat(\${u.userId}, '\${u.username}')"
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

    // [QUAN TRỌNG] Đã sửa để không làm mất inbox trên Desktop
    async function selectUserChat(userId, username) {
        currentReceiverId = userId;
        document.getElementById('chatTitle').innerText = username;
        document.getElementById('chatHeaderAvatar').innerText = username.charAt(0).toUpperCase();

        const input = document.getElementById('chatInput');
        input.disabled = false; input.classList.remove('bg-gray-50');
        document.getElementById('btnSend').disabled = false;

        // UI Responsive Logic:
        // Mobile: Ẩn Inbox, Hiện Detail
        // Desktop (md): Hiện cả hai (nhờ class md:flex trong HTML)

        // 1. Inbox Panel: Thêm 'hidden' để ẩn trên Mobile.
        // Lưu ý: Class 'md:flex' trong HTML sẽ ghi đè 'hidden' trên Desktop.
        document.getElementById('inboxPanel').classList.add('hidden');

        // 2. Chat Detail Panel: Bỏ 'hidden', thêm 'flex'
        const detailPanel = document.getElementById('chatDetailPanel');
        detailPanel.classList.remove('hidden');
        detailPanel.classList.add('flex');

        // Logic Nút Tặng
        const btnConfirm = document.getElementById('btnConfirmGive');
        if (currentDiscussingItemId && isOwnerOfCurrentItem && userId !== currentUserId) {
            btnConfirm.classList.remove('hidden');
            btnConfirm.innerText = "🎁 Tặng cho " + username;
        } else {
            btnConfirm.classList.add('hidden');
        }

        loadHistory(userId);
        loadInboxList();
    }

    // Nút Back trên Mobile
    function backToInbox() {
        // Ẩn Detail
        document.getElementById('chatDetailPanel').classList.add('hidden');
        document.getElementById('chatDetailPanel').classList.remove('flex');

        // Hiện Inbox (Bỏ class hidden)
        document.getElementById('inboxPanel').classList.remove('hidden');
    }

    // --- 4. CÁC HÀM KHÁC (GIỮ NGUYÊN) ---
    async function loadHistory(userId) {
        const chatBox = document.getElementById('chatMessages');
        chatBox.innerHTML = '<div class="text-center text-xs text-gray-400 mt-10">Đang tải...</div>';
        try {
            const res = await fetch('${pageContext.request.contextPath}/api/chat?action=history&partnerId=' + userId);
            const msgs = await res.json();
            chatBox.innerHTML = '';

            msgs.forEach(m => {
                // Xử lý tin nhắn hệ thống
                if (m.content.startsWith("SYSTEM_GIFT:")) {
                    let cleanText = m.content.replace("SYSTEM_GIFT:", "");

                    // LOGIC QUAN TRỌNG:
                    // Nếu mình là người gửi tin nhắn này (Sender == Me) -> Có nghĩa mình là người tặng.
                    // Nhưng nội dung trong DB lại là "Bạn được tặng..." (do lúc gửi socket ta gửi câu đó).
                    // Nên ta phải đổi lại câu chữ khi hiển thị lịch sử.

                    if (m.senderId === currentUserId) {
                        // Mình là người gửi -> Đổi thành "Bạn đã tặng..."
                        // Regex đơn giản để thay thế text hiển thị (Tuỳ vào format chuỗi bên trên)
                        cleanText = cleanText.replace("Bạn được tặng món", "Bạn đã tặng món");
                        cleanText = cleanText.replace("từ " + currentUserName, ""); // Xóa đoạn "từ [tên mình]"
                    }

                    appendSystemMessage(cleanText);
                } else {
                    appendMessage(m.content, m.senderId === currentUserId ? 'outgoing' : 'incoming');
                }
            });
            chatBox.scrollTop = chatBox.scrollHeight;
        } catch(e) { chatBox.innerHTML = 'Lỗi tải tin nhắn'; }
    }

    async function confirmGiveItem() {
        const receiverName = document.getElementById('chatTitle').innerText;
        if (!confirm("Bạn chắc chắn muốn chốt tặng món đồ này cho " + receiverName + "?\n\n(Trạng thái sẽ chuyển thành CONFIRMED)")) return;

        try {
            const fd = new URLSearchParams();
            fd.append('itemId', currentDiscussingItemId);
            fd.append('receiverId', currentReceiverId);

            const res = await fetch('${pageContext.request.contextPath}/api/confirm-transaction', { method: 'POST', body: fd });
            const data = await res.json();

            if (data.status === 'success') {
                // 1. Thông báo popup cho người tặng (chính mình)
                alert("✅ Thành công! Đã chốt tặng món " + data.itemName + ".");

                // 2. XỬ LÝ TIN NHẮN (TÁCH BIỆT GỬI VÀ HIỆN)

                // A. Nội dung gửi cho người nhận (qua WebSocket & Lưu DB)
                // Lưu ý: Ta lưu vào DB câu này, nên khi load lại lịch sử, người tặng sẽ thấy câu này.
                // Để khắc phục triệt để, ta dùng prefix đặc biệt để xử lý hiển thị sau.
                const msgForReceiver = "SYSTEM_GIFT:Bạn được tặng món " + data.itemName + " từ " + currentUserName + ". (Trạng thái: CONFIRMED)";

                if (chatSocket && currentReceiverId) {
                    chatSocket.send(JSON.stringify({ receiverId: currentReceiverId, content: msgForReceiver }));
                }

                // B. Nội dung hiển thị ngay lập tức cho người tặng (Local)
                const msgForSender = "🎁 Bạn đã tặng món " + data.itemName + " cho " + receiverName + ".";
                appendSystemMessage(msgForSender);

                // 3. Reset UI & Reload Map
                currentDiscussingItemId = null;
                isOwnerOfCurrentItem = false;
                document.getElementById('btnConfirmGive').classList.add('hidden');
                document.getElementById('chatItemInfo').classList.add('hidden');

                loadItems();

                // Reload inbox sau 1 chút để cập nhật last message
                setTimeout(loadInboxList, 500);
            } else {
                alert("❌ Lỗi: " + data.message);
            }
        } catch (e) {
            console.error(e);
            alert("❌ Lỗi kết nối");
        }
    }

    function updateHeaderInfo(title) {
        document.getElementById('chatItemInfo').classList.remove('hidden');
        document.getElementById('chatItemName').innerText = title;
    }

    function connectWebSocket() {
        if (chatSocket && chatSocket.readyState === WebSocket.OPEN) return;
        chatSocket = new WebSocket((window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.host + '${pageContext.request.contextPath}/chat/' + currentUserId);

        chatSocket.onmessage = (e) => {
            const data = JSON.parse(e.data);
            if (data.content.startsWith("SYSTEM_GIFT:")) {
                const msgText = data.content.replace("SYSTEM_GIFT:", "");
                document.getElementById('congratsText').innerText = msgText;
                document.getElementById('congratsModal').classList.remove('hidden');
                if (data.senderId == currentReceiverId) appendSystemMessage(msgText);
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

    // --- ĐĂNG TIN ---
    document.getElementById('btnPostItem').addEventListener('click', () => { document.getElementById('giveAwayModal').classList.remove('hidden'); document.getElementById('step1').classList.remove('hidden'); });
    function closeModal(id) { document.getElementById(id).classList.add('hidden'); }
    function nextStep(n) { document.querySelectorAll('.modal-step').forEach(e=>e.classList.add('hidden')); document.getElementById('step'+n).classList.remove('hidden'); if(n===3) setTimeout(()=>{ if(!miniMap) {miniMap=L.map('miniMap').setView([currentLatLng.lat, currentLatLng.lng], 15); L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'OSM'}).addTo(miniMap); locationMarker=L.marker([currentLatLng.lat,currentLatLng.lng],{draggable:true}).addTo(miniMap); locationMarker.on('dragend',e=>currentLatLng=e.target.getLatLng()); } else miniMap.invalidateSize(); },200); }
    async function loadCategories() { try { const r = await fetch('${pageContext.request.contextPath}/api/categories'); (await r.json()).forEach(c => document.getElementById('itemCategory').innerHTML += `<option value="\${c.categoryId}">\${c.name}</option>`); } catch(e){} }
    loadCategories();
    async function submitItem() {
        const fd = new FormData(); fd.append("title", document.getElementById('itemName').value); fd.append("description", document.getElementById('itemDescription').value); fd.append("category", document.getElementById('itemCategory').value); fd.append("itemPhoto", document.getElementById('itemPhoto').files[0]); fd.append("latitude", currentLatLng.lat); fd.append("longitude", currentLatLng.lng);
        try { if((await fetch('${pageContext.request.contextPath}/post-item', {method:'POST', body:fd})).ok) { alert("Xong!"); location.reload(); } else alert("Lỗi"); } catch(e){}
    }
</script>
</body>
</html>