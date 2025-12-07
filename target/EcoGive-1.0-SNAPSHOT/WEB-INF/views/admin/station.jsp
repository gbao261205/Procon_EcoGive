<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Điểm tập kết - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style> body { font-family: 'Inter', sans-serif; } </style>
</head>
<body class="bg-slate-100 flex h-screen overflow-hidden text-slate-800">

<jsp:include page="sidebar.jsp" />

<div class="flex-1 flex flex-col md:ml-64 transition-all duration-300 h-full">
    <header class="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-8 shrink-0">
        <h1 class="text-2xl font-bold text-slate-800">Quản lý Điểm tập kết</h1>

        <button onclick="openModal()" class="flex items-center gap-2 bg-emerald-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-bold shadow-sm transition">
            Thêm trạm mới
        </button>
    </header>

    <main class="flex-1 overflow-y-auto p-8">
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                    <tr>
                        <th class="px-6 py-4 border-b">ID</th>
                        <th class="px-6 py-4 border-b">Tên trạm</th>
                        <th class="px-6 py-4 border-b">Loại hình</th>
                        <th class="px-6 py-4 border-b">Địa chỉ</th>
                        <th class="px-6 py-4 border-b text-right">Hành động</th>
                    </tr>
                    </thead>
                    <tbody class="text-sm divide-y divide-slate-100">
                    <c:forEach var="st" items="${stations}">
                        <tr class="hover:bg-slate-50 transition-colors">
                            <td class="px-6 py-4 text-slate-500">#${st.pointId}</td>
                            <td class="px-6 py-4 font-medium">${st.name}</td>
                            <td class="px-6 py-4">
                                <c:choose>
                                    <%-- 1. Pin cũ (Vàng) --%>
                                    <c:when test="${st.type == 'BATTERY'}">
        <span class="inline-flex items-center gap-1 bg-yellow-100 text-yellow-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-yellow-200">
            🔋 Pin cũ
        </span>
                                    </c:when>

                                    <%-- 2. Rác điện tử (Xanh dương) --%>
                                    <c:when test="${st.type == 'E_WASTE'}">
        <span class="inline-flex items-center gap-1 bg-blue-100 text-blue-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-blue-200">
            💻 Điện tử
        </span>
                                    </c:when>

                                    <%-- 3. Quần áo/Vải (Tím) --%>
                                    <c:when test="${st.type == 'TEXTILE'}">
        <span class="inline-flex items-center gap-1 bg-purple-100 text-purple-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-purple-200">
            👕 Quần áo
        </span>
                                    </c:when>

                                    <%-- 4. Y tế/Thuốc (Đỏ) --%>
                                    <c:when test="${st.type == 'MEDICAL'}">
        <span class="inline-flex items-center gap-1 bg-red-100 text-red-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-red-200">
            💊 Vật dụng Y tế
        </span>
                                    </c:when>

                                    <%-- 5. Hóa chất (Cam) --%>
                                    <c:when test="${st.type == 'CHEMICAL'}">
        <span class="inline-flex items-center gap-1 bg-orange-100 text-orange-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-orange-200">
            🧪 Hóa chất
        </span>
                                    </c:when>

                                    <%-- 6. Đại lý/Vựa ve chai (Chàm - Indigo) --%>
                                    <c:when test="${st.type == 'DEALER'}">
        <span class="inline-flex items-center gap-1 bg-indigo-100 text-indigo-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-indigo-200">
            🏪 Đại lý ve chai
        </span>
                                    </c:when>

                                    <%-- 7. Cá nhân thu mua (Xanh Teal) --%>
                                    <c:when test="${st.type == 'INDIVIDUAL'}">
        <span class="inline-flex items-center gap-1 bg-teal-100 text-teal-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-teal-200">
            👤 Vật dụng cá nhân
        </span>
                                    </c:when>

                                    <%-- Mặc định (Xám) --%>
                                    <c:otherwise>
        <span class="inline-flex items-center gap-1 bg-gray-100 text-gray-800 px-2.5 py-0.5 rounded-full text-xs font-bold border border-gray-200">
            ❓ Khác
        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-6 py-4 truncate max-w-xs" title="${st.address}">${st.address}</td>
                            <td class="px-6 py-4 text-right flex justify-end gap-2">
                                <button onclick="openModal('${st.pointId}', '${st.name}', '${st.type}', '${st.address}', ${st.location.latitude}, ${st.location.longitude})"
                                        class="text-blue-600 bg-blue-50 hover:bg-blue-100 px-3 py-1 rounded border border-blue-200 font-medium text-xs transition">
                                    Sửa
                                </button>

                                <form action="${pageContext.request.contextPath}/admin" method="POST" onsubmit="return confirm('Xóa trạm này?');">
                                    <input type="hidden" name="action" value="delete-station">
                                    <input type="hidden" name="id" value="${st.pointId}">
                                    <button class="text-red-600 bg-red-50 hover:bg-red-100 px-3 py-1 rounded border border-red-200 font-medium text-xs transition">
                                        Xóa
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<div id="stationModal" class="fixed inset-0 hidden bg-black bg-opacity-60 flex items-center justify-center p-4 z-50">
    <div class="bg-white rounded-xl shadow-2xl w-full max-w-lg overflow-hidden transform transition-all scale-100">
        <div class="bg-emerald-600 px-6 py-4 flex justify-between items-center">
            <h3 id="modalTitle" class="text-lg font-bold text-white">Thêm điểm tập kết</h3>
            <button onclick="closeModal()" class="text-white hover:text-emerald-200 font-bold text-xl">✕</button>
        </div>

        <form action="${pageContext.request.contextPath}/admin" method="POST" class="p-6">
            <input type="hidden" id="formAction" name="action" value="add-station">
            <input type="hidden" id="stationId" name="id" value="">

            <div class="space-y-4">
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Tên trạm</label>
                    <input type="text" id="name" name="name" class="w-full p-2 border rounded focus:ring-emerald-500" required>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Loại hình</label>
                        <select id="type" name="type" class="w-full p-2 border rounded bg-white">
                            <option value="BATTERY">Pin cũ</option>
                            <option value="E_WASTE">Rác điện tử</option>
                            <option value="TEXTILE">Quần áo</option>
                            <option value="MEDICAL">Y tế</option>
                            <option value="CHEMICAL">Hóa chất</option>
                            <option value="DEALER">Đại lý ve chai</option>
                            <option value="INDIVIDUAL">Vật dụng</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 mb-1">Địa chỉ</label>
                        <input type="text" id="address" name="address" class="w-full p-2 border rounded" required>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Vị trí trên bản đồ <span class="text-red-500">*</span></label>
                    <div id="miniMap" class="h-48 w-full rounded border z-0"></div>
                    <input type="hidden" id="lat" name="latitude" value="10.7769">
                    <input type="hidden" id="lng" name="longitude" value="106.7009">
                    <p class="text-[10px] text-slate-500 mt-1">Kéo thả ghim đỏ để chọn vị trí chính xác.</p>
                </div>
            </div>

            <div class="mt-6 flex justify-end gap-3">
                <button type="button" onclick="closeModal()" class="px-4 py-2 bg-gray-200 text-gray-700 rounded font-bold hover:bg-gray-300">Hủy</button>
                <button type="submit" class="px-4 py-2 bg-emerald-600 text-white rounded font-bold hover:bg-emerald-700">Lưu thông tin</button>
            </div>
        </form>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
    let map, marker;
    // Tọa độ mặc định (HCM)
    const defaultLat = 10.7769;
    const defaultLng = 106.7009;

    function initMap() {
        if (map) return;
        map = L.map('miniMap').setView([defaultLat, defaultLng], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OSM' }).addTo(map);

        // Marker
        marker = L.marker([defaultLat, defaultLng], {draggable: true}).addTo(map);

        marker.on('dragend', function(e) {
            const pos = e.target.getLatLng();
            document.getElementById('lat').value = pos.lat;
            document.getElementById('lng').value = pos.lng;
        });
    }

    // Mở Modal (Mode: Add hoặc Edit)
    function openModal(id, name, type, address, lat, lng) {
        document.getElementById('stationModal').classList.remove('hidden');

        // Khởi tạo map sau khi modal hiện (để tránh lỗi size)
        setTimeout(() => {
            initMap();

            if (id) {
                // --- CHẾ ĐỘ SỬA ---
                document.getElementById('modalTitle').innerText = "Cập nhật Điểm tập kết";
                document.getElementById('formAction').value = "update-station";
                document.getElementById('stationId').value = id;

                document.getElementById('name').value = name;
                document.getElementById('type').value = type;
                document.getElementById('address').value = address;
                document.getElementById('lat').value = lat;
                document.getElementById('lng').value = lng;

                // Cập nhật vị trí marker
                const newLatLng = new L.LatLng(lat, lng);
                marker.setLatLng(newLatLng);
                map.setView(newLatLng, 15);
            } else {
                // --- CHẾ ĐỘ THÊM MỚI ---
                document.getElementById('modalTitle').innerText = "Thêm Điểm tập kết";
                document.getElementById('formAction').value = "add-station";
                document.getElementById('stationId').value = "";

                // Reset form
                document.getElementById('name').value = "";
                document.getElementById('address').value = "";

                // Reset marker về mặc định
                const defLatLng = new L.LatLng(defaultLat, defaultLng);
                marker.setLatLng(defLatLng);
                map.setView(defLatLng, 13);
                document.getElementById('lat').value = defaultLat;
                document.getElementById('lng').value = defaultLng;
            }
            map.invalidateSize();
        }, 100);
    }

    function closeModal() {
        document.getElementById('stationModal').classList.add('hidden');
    }
</script>
</body>
</html>