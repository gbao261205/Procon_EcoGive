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
<body class="bg-slate-50 text-slate-800 antialiased">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 min-h-screen transition-all duration-300 flex flex-col">
    <header class="bg-white border-b border-slate-200 sticky top-0 z-10 px-8 py-4 flex justify-between items-center shadow-sm">
        <div>
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight">Điểm tập kết</h1>
            <p class="text-sm text-slate-500 mt-1">Quản lý các trạm thu gom rác thải tái chế.</p>
        </div>
        <button onclick="openModal()" class="bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2.5 rounded-xl font-semibold shadow-lg shadow-emerald-200 transition-all flex items-center gap-2 active:scale-95">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Thêm trạm mới
        </button>
    </header>

    <div class="p-8 max-w-7xl mx-auto w-full">
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                    <tr>
                        <th class="px-6 py-4 border-b border-slate-100">Tên trạm</th>
                        <th class="px-6 py-4 border-b border-slate-100">Loại hình</th>
                        <th class="px-6 py-4 border-b border-slate-100">Địa chỉ</th>
                        <th class="px-6 py-4 border-b border-slate-100">Chủ sở hữu</th>
                        <th class="px-6 py-4 border-b border-slate-100 text-right">Hành động</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-sm">
                    <c:forEach var="st" items="${stations}">
                        <tr class="group hover:bg-slate-50 transition-colors">
                            <td class="px-6 py-4">
                                <div class="font-bold text-slate-800">${st.name}</div>
                                <div class="text-xs text-slate-400 font-mono mt-0.5">#${st.pointId}</div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-bold bg-slate-100 text-slate-700 border border-slate-200">
                                    <span class="text-base">${st.typeIcon}</span> ${st.typeName}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="max-w-xs truncate text-slate-600" title="${st.address}">
                                    ${st.address}
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <c:choose>
                                    <c:when test="${not empty st.ownerName}">
                                        <div class="flex items-center gap-2">
                                            <div class="w-6 h-6 rounded-full bg-slate-100 flex items-center justify-center text-[10px] font-bold text-slate-500">
                                                ${st.ownerName.substring(0,1)}
                                            </div>
                                            <span class="font-medium text-slate-700">${st.ownerName}</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-slate-400 italic text-xs">Công cộng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-6 py-4 text-right">
                                <div class="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button onclick="openModal('${st.pointId}', '${st.name}', '${st.typeCode}', '${st.address}', ${st.location.latitude}, ${st.location.longitude})"
                                            class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="Sửa">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                    </button>

                                    <form action="${pageContext.request.contextPath}/admin" method="POST" onsubmit="return confirm('Xóa trạm này?');" class="inline">
                                        <input type="hidden" name="action" value="delete-station">
                                        <input type="hidden" name="id" value="${st.pointId}">
                                        <button class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Xóa">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- MODAL -->
<div id="stationModal" class="fixed inset-0 z-50 hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm transition-opacity" onclick="closeModal()"></div>

    <div class="fixed inset-0 z-10 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
            <div class="relative transform overflow-hidden rounded-2xl bg-white text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-lg border border-slate-100">
                <div class="bg-white px-6 py-4 border-b border-slate-100 flex justify-between items-center">
                    <h3 id="modalTitle" class="text-lg font-bold text-slate-800">Thêm điểm tập kết</h3>
                    <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600 bg-slate-50 hover:bg-slate-100 p-2 rounded-full transition-colors">
                        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <form action="${pageContext.request.contextPath}/admin" method="POST" class="p-6 space-y-5">
                    <input type="hidden" id="formAction" name="action" value="add-station">
                    <input type="hidden" id="stationId" name="id" value="">

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Tên trạm <span class="text-red-500">*</span></label>
                        <input type="text" id="name" name="name" required
                               class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                               placeholder="VD: Trạm thu gom Quận 1">
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Loại hình</label>
                            <div class="relative">
                                <select id="type" name="type" class="w-full appearance-none rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all cursor-pointer">
                                    <c:forEach var="t" items="${types}">
                                        <option value="${t.typeCode}">${t.icon} ${t.displayName}</option>
                                    </c:forEach>
                                </select>
                                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-slate-500">
                                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                                </div>
                            </div>
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Địa chỉ <span class="text-red-500">*</span></label>
                            <input type="text" id="address" name="address" required
                                   class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400">
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5">Vị trí bản đồ <span class="text-red-500">*</span></label>
                        <div class="relative rounded-xl overflow-hidden border border-slate-200 shadow-sm">
                            <div id="miniMap" class="h-56 w-full z-0"></div>
                            <div class="absolute bottom-2 right-2 bg-white/90 backdrop-blur px-2 py-1 rounded text-[10px] text-slate-500 shadow-sm z-[400]">
                                Kéo thả ghim để chọn vị trí
                            </div>
                        </div>
                        <input type="hidden" id="lat" name="latitude" value="10.7769">
                        <input type="hidden" id="lng" name="longitude" value="106.7009">
                    </div>

                    <div class="pt-2 flex justify-end gap-3">
                        <button type="button" onclick="closeModal()" class="px-5 py-2.5 rounded-xl text-sm font-semibold text-slate-600 hover:bg-slate-100 transition-colors">
                            Hủy bỏ
                        </button>
                        <button type="submit" class="px-6 py-2.5 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 shadow-lg shadow-emerald-200 transition-all active:scale-95">
                            Lưu thông tin
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
    let map, marker;
    const defaultLat = 10.7769;
    const defaultLng = 106.7009;

    function initMap() {
        if (map) {
            map.invalidateSize();
            return;
        }
        map = L.map('miniMap').setView([defaultLat, defaultLng], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '&copy; OSM' }).addTo(map);
        marker = L.marker([defaultLat, defaultLng], {draggable: true}).addTo(map);

        marker.on('dragend', function(e) {
            const pos = e.target.getLatLng();
            document.getElementById('lat').value = pos.lat;
            document.getElementById('lng').value = pos.lng;
        });
    }

    function openModal(id, name, type, address, lat, lng) {
        document.getElementById('stationModal').classList.remove('hidden');

        // Delay to allow modal to render before initializing map
        setTimeout(() => {
            initMap();
            if (id) {
                document.getElementById('modalTitle').innerText = "Cập nhật Điểm tập kết";
                document.getElementById('formAction').value = "update-station";
                document.getElementById('stationId').value = id;
                document.getElementById('name').value = name;
                document.getElementById('type').value = type;
                document.getElementById('address').value = address;
                document.getElementById('lat').value = lat;
                document.getElementById('lng').value = lng;

                const newLatLng = new L.LatLng(lat, lng);
                marker.setLatLng(newLatLng);
                map.setView(newLatLng, 15);
            } else {
                document.getElementById('modalTitle').innerText = "Thêm Điểm tập kết";
                document.getElementById('formAction').value = "add-station";
                document.getElementById('stationId').value = "";
                document.getElementById('name').value = "";
                document.getElementById('address').value = "";
                document.getElementById('type').selectedIndex = 0;

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