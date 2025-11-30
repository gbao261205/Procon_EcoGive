<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Bản đồ EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>

    <style>
        .leaflet-popup-content-wrapper { border-radius: 12px; overflow: hidden; padding: 0; }
        .leaflet-popup-content { margin: 0; width: 220px !important; }
        .custom-popup-img { width: 100%; height: 120px; object-fit: cover; }
        .custom-popup-body { padding: 12px; }
    </style>
</head>

<body class="h-screen flex flex-col bg-slate-50 relative">

<%-- Header remains the same --%>
<header class="bg-white shadow-sm z-20 px-6 py-3 flex justify-between items-center h-16 flex-shrink-0">
    <div class="flex items-center gap-2">
        <h1 class="text-2xl font-bold text-emerald-600 tracking-tight">EcoGive <span class="text-slate-400 font-normal text-sm">Map</span></h1>
    </div>

    <div class="flex items-center gap-4">
        <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/admin?action=dashboard"
               class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-slate-700 bg-slate-200 hover:bg-slate-300 rounded-lg transition">
                <span>⬅</span> Dashboard
            </a>
        </c:if>

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

        <button id="btnPostItem" class="px-4 py-2 text-sm font-bold text-white bg-emerald-600 rounded-lg shadow-md hover:bg-emerald-700 transition flex items-center gap-2">
            <span>＋</span> Đăng tin
        </button>
    </div>
</header>

<div id="map" class="flex-1 z-10 w-full h-full"></div>

<%-- Modal remains the same --%>
<div id="giveAwayModal" class="fixed inset-0 hidden bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
    <div class="bg-white p-6 rounded-xl w-full max-w-lg shadow-2xl relative">
        <button onclick="closeModal('giveAwayModal')" class="absolute top-4 right-4 text-gray-400 hover:text-gray-600">✕</button>
        <h2 class="text-2xl font-bold mb-6 text-emerald-700 text-center">Đăng tin Tặng đồ</h2>
        <div id="step1" class="modal-step">
            <h3 class="text-lg font-semibold mb-3">Bước 1: Thông tin cơ bản</h3>
            <input type="text" id="itemName" placeholder="Tên vật phẩm" class="w-full p-3 mb-3 border rounded-lg focus:ring-emerald-500" required />
            <textarea id="itemDescription" placeholder="Mô tả chi tiết..." rows="3" class="w-full p-3 mb-4 border rounded-lg focus:ring-emerald-500" required></textarea>
            <button onclick="nextStep(2)" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-semibold hover:bg-emerald-700">Tiếp tục (Ảnh)</button>
        </div>
        <div id="step2" class="modal-step hidden">
            <h3 class="text-lg font-semibold mb-3">Bước 2: Hình ảnh</h3>
            <input type="file" id="itemPhoto" accept="image/*" class="w-full p-3 mb-4 border rounded-lg" required />
            <button onclick="nextStep(3)" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-semibold hover:bg-emerald-700 mt-4">Tiếp tục (Vị trí)</button>
        </div>
        <div id="step3" class="modal-step hidden">
            <h3 class="text-lg font-semibold mb-3">Bước 3: Chọn vị trí lấy hàng</h3>
            <div id="miniMap" class="h-64 w-full rounded-lg mb-4 border z-0"></div>
            <p class="text-xs text-gray-500 mb-2">* Kéo ghim đỏ đến vị trí chính xác</p>
            <button onclick="submitItem()" class="w-full bg-emerald-600 text-white p-3 rounded-lg font-semibold hover:bg-emerald-700">Xác nhận Đăng tin</button>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>

<script>
    // --- 1. INITIALIZE MAP ---
    const map = L.map('map').setView([10.7769, 106.7009], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    // --- 2. RENDER ITEMS FROM SERVLET DATA ---
    <c:if test="${not empty items}">
        const items = [
            <c:forEach var="item" items="${items}" varStatus="loop">
                {
                    "id": "${item.itemId}",
                    "title": "${fn:escapeXml(item.title)}",
                    "giverId": "${item.giverId}",
                    // Get the full C:/ path from the database
                    "fullPath": "${fn:escapeXml(item.imageUrl)}",
                    "latitude": ${item.location.latitude},
                    "longitude": ${item.location.longitude}
                }
                <c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        console.log("Raw item data from server:", items);

        items.forEach(item => {
            if (item.latitude && item.longitude) {
                // CORRECT WAY: Build the URL to call ImageServlet
                // Use encodeURIComponent to safely pass the file path as a parameter
                const encodedPath = encodeURIComponent(item.fullPath);
                const imgUrl = '${pageContext.request.contextPath}/images?path=' + encodedPath;
                
                console.log(`Item ${item.id}: DB path='${item.fullPath}', Final URL='${imgUrl}'`);

                const popupContent = `
                    <div>
                        <img src="\${imgUrl}" class="custom-popup-img" onerror="this.src='https://placehold.co/200x150?text=Error'">
                        <div class="custom-popup-body">
                            <h3 class="font-bold text-slate-800 text-sm mb-1">\${item.title}</h3>
                            <p class="text-xs text-slate-500 mb-2">Người tặng: ID \${item.giverId}</p>
                            <button class="w-full bg-emerald-600 text-white text-xs font-bold py-1.5 rounded hover:bg-emerald-700 transition">
                                Xem chi tiết
                            </button>
                        </div>
                    </div>
                `;

                L.marker([item.latitude, item.longitude])
                    .addTo(map)
                    .bindPopup(popupContent);
            }
        });
    </c:if>

    // --- 3. MODAL LOGIC (remains the same) ---
    let miniMap, locationMarker;
    let currentLatLng = { lat: 10.7769, lng: 106.7009 };

    document.getElementById('btnPostItem').addEventListener('click', () => {
        document.getElementById('giveAwayModal').classList.remove('hidden');
        resetModalSteps();
    });

    function closeModal(id) { document.getElementById(id).classList.add('hidden'); }
    function resetModalSteps() {
        document.querySelectorAll('.modal-step').forEach(el => el.classList.add('hidden'));
        document.getElementById('step1').classList.remove('hidden');
    }
    function nextStep(step) {
        document.querySelectorAll('.modal-step').forEach(el => el.classList.add('hidden'));
        document.getElementById('step' + step).classList.remove('hidden');
        if (step === 3) {
            setTimeout(() => {
                if (!miniMap) {
                    miniMap = L.map('miniMap').setView([currentLatLng.lat, currentLatLng.lng], 15);
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OSM' }).addTo(miniMap);
                    locationMarker = L.marker([currentLatLng.lat, currentLatLng.lng], { draggable: true }).addTo(miniMap);
                    locationMarker.on('dragend', function(event) {
                        currentLatLng = { lat: event.target.getLatLng().lat, lng: event.target.getLatLng().lng };
                    });
                } else {
                    miniMap.invalidateSize();
                }
            }, 200);
        }
    }

    // --- 4. SUBMIT ITEM LOGIC (remains the same) ---
    async function submitItem() {
        const title = document.getElementById('itemName').value;
        const description = document.getElementById('itemDescription').value;
        const photo = document.getElementById('itemPhoto').files[0];
        if (!photo) { alert("Vui lòng chọn ảnh!"); return; }

        const formData = new FormData();
        formData.append("title", title);
        formData.append("description", description);
        formData.append("latitude", currentLatLng.lat);
        formData.append("longitude", currentLatLng.lng);
        formData.append("itemPhoto", photo);
        formData.append("category", "1"); // Hardcoded for now

        try {
            const response = await fetch('${pageContext.request.contextPath}/post-item', {
                method: 'POST',
                body: formData
            });
            if (response.ok) {
                alert('Đăng tin thành công! Vật phẩm của bạn đang chờ duyệt.');
                closeModal('giveAwayModal');
                window.location.reload(); // Reload the page to show the new item
            } else {
                const errorData = await response.json().catch(() => ({}));
                alert("Lỗi: " + (errorData.error || "Không thể đăng tin. Mã lỗi: " + response.status));
            }
        } catch (error) {
            console.error(error);
            alert("Lỗi kết nối: " + error.message);
        }
    }
</script>
</body>
</html>
