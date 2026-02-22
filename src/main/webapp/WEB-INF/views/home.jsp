<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Bản đồ EcoGive - Chia sẻ & Tái chế</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                        secondary: '#1e293b',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                    animation: {
                        'scale-in': 'scaleIn 0.2s ease-out forwards',
                        'slide-up': 'slideUp 0.3s ease-out forwards',
                    },
                    keyframes: {
                        scaleIn: {
                            '0%': { transform: 'scale(0.9)', opacity: '0' },
                            '100%': { transform: 'scale(1)', opacity: '1' },
                        },
                        slideUp: {
                            '0%': { transform: 'translateY(100%)' },
                            '100%': { transform: 'translateY(0)' },
                        }
                    }
                }
            }
        }
    </script>

    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>

    <style>
        body { font-family: 'Inter', sans-serif; }

        /* Custom Scrollbar */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

        /* Leaflet Popup Customization */
        .leaflet-popup-content-wrapper {
            border-radius: 16px;
            overflow: hidden;
            padding: 0;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        .leaflet-popup-content { margin: 0; width: 260px !important; }
        .custom-popup-img {
            width: 100%;
            height: 160px;
            object-fit: cover;
            background-color: #f8fafc;
        }
        .custom-popup-body { padding: 16px; }

        /* Animations */
        @keyframes popIn {
            0% { transform: scale(0.9); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
        .modal-animate { animation: popIn 0.2s cubic-bezier(0.16, 1, 0.3, 1); }

        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

        /* Mobile specific adjustments */
        @media (max-width: 768px) {
            .leaflet-control-container .leaflet-top { top: 70px; } /* Tránh header */
        }
    </style>
</head>

<body class="h-screen flex flex-col bg-slate-50 relative overflow-hidden">

<!-- HEADER -->
<header class="bg-white shadow-sm z-30 px-4 md:px-6 h-16 flex justify-between items-center flex-shrink-0 border-b border-slate-100 relative">
    <!-- Logo Section -->
    <div class="flex items-center gap-2">
        <span class="material-symbols-outlined text-primary" style="font-size: 28px; md:32px;">spa</span>
        <h1 class="text-lg md:text-xl font-bold tracking-tight text-slate-800">EcoGive <span class="text-slate-400 font-normal text-sm ml-1 hidden md:inline">Map</span></h1>
    </div>

    <!-- Actions & Profile -->
    <div class="flex items-center gap-2 md:gap-4">
        <!-- Action Buttons Group (Desktop) -->
        <div class="hidden md:flex items-center gap-3 pr-4 border-r border-slate-200">
            <!-- NEW BUTTONS: Show All Items & Points -->
            <button onclick="openAllItemsList()" class="flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-blue-50 hover:text-blue-600 rounded-lg transition-all" title="Danh sách vật phẩm">
                <span class="material-symbols-outlined text-[20px]">inventory_2</span>
                <span>Vật phẩm</span>
            </button>
            <button onclick="openAllPointsList()" class="flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-green-50 hover:text-green-600 rounded-lg transition-all" title="Danh sách điểm tập kết">
                <span class="material-symbols-outlined text-[20px]">recycling</span>
                <span>Điểm tập kết</span>
            </button>
            <div class="w-px h-6 bg-slate-200 mx-1"></div>
            <!-- End New Buttons -->

            <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin?action=dashboard"
                   class="flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-blue-50 hover:text-blue-600 rounded-lg transition-all" title="Trang quản trị">
                    <span class="material-symbols-outlined text-[20px]">analytics</span>
                    <span>Dashboard</span>
                </a>
            </c:if>
            <c:if test="${sessionScope.currentUser.role == 'COLLECTOR_COMPANY'}">
                <a href="${pageContext.request.contextPath}/dashboard/company"
                   class="flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-emerald-50 hover:text-emerald-600 rounded-lg transition-all" title="Quản lý Doanh nghiệp">
                    <span class="material-symbols-outlined text-[20px]">domain</span>
                    <span>Quản lý</span>
                </a>
            </c:if>
             <c:if test="${sessionScope.currentUser.role == 'ADMIN' || sessionScope.currentUser.role == 'COLLECTOR_COMPANY'}">
                <button id="btnAddPoint"
                        class="flex items-center gap-2 px-3 py-2 text-sm font-semibold text-white bg-primary hover:bg-primary-hover rounded-lg shadow-sm transition-all transform active:scale-95" title="Thêm điểm tập kết">
                    <span class="material-symbols-outlined text-[20px]">add_location_alt</span>
                    <span>Thêm điểm</span>
                </button>
            </c:if>
            <button id="btnPostItem"
                    class="flex items-center gap-2 px-4 py-2 text-sm font-bold text-white bg-primary hover:bg-primary-hover rounded-lg shadow-md hover:shadow-lg transition-all transform active:scale-95">
                <span class="material-symbols-outlined text-[20px]">volunteer_activism</span>
                <span>Đăng tin</span>
            </button>
        </div>

        <!-- Mobile Post Button -->
        <button id="btnPostItemMobile" class="md:hidden w-9 h-9 flex items-center justify-center bg-primary text-white rounded-full shadow-md active:scale-95">
            <span class="material-symbols-outlined text-[20px]">add</span>
        </button>

        <!-- User Profile -->
        <c:if test="${sessionScope.currentUser != null}">
            <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-3 group cursor-pointer">
                <div class="text-right hidden md:block">
                    <div class="text-sm font-bold text-slate-700 group-hover:text-primary transition">
                        ${sessionScope.currentUser.username}
                    </div>
                    <div class="text-xs text-primary font-medium flex items-center justify-end gap-1">
                        <span class="material-symbols-outlined text-[14px]">eco</span>
                        ${sessionScope.currentUser.ecoPoints} EcoPoints
                    </div>
                </div>
                <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=${sessionScope.currentUser.username}"
                     alt="Avatar"
                     class="w-8 h-8 md:w-10 md:h-10 rounded-full border-2 border-slate-100 bg-slate-50 shadow-sm group-hover:border-primary transition-colors">
            </a>
            <a href="${pageContext.request.contextPath}/logout"
               class="md:flex hidden items-center justify-center w-9 h-9 rounded-full text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all" title="Đăng xuất">
                <span class="material-symbols-outlined text-[20px]">logout</span>
            </a>
        </c:if>

        <c:if test="${sessionScope.currentUser == null}">
            <a href="${pageContext.request.contextPath}/login" class="px-3 py-1.5 md:px-5 md:py-2 text-xs md:text-sm font-bold text-primary bg-emerald-50 hover:bg-emerald-100 rounded-lg transition-colors">Đăng nhập</a>
        </c:if>
    </div>
</header>

<!-- MAP CONTAINER -->
<div class="flex-1 relative w-full h-full">
    <div id="map" class="absolute inset-0 z-0 bg-slate-100"></div>

    <!-- FILTER BUTTON (Floating - Right Side, Low Z-Index) -->
    <button onclick="toggleFilterPanel()"
            class="absolute top-4 right-4 md:top-6 md:right-6 z-20 w-10 h-10 md:w-12 md:h-12 bg-white text-slate-700 rounded-full shadow-lg hover:text-primary hover:scale-110 transition-all duration-300 flex items-center justify-center border border-slate-100 group"
            title="Bộ lọc bản đồ">
        <span class="material-symbols-outlined group-hover:rotate-180 transition-transform duration-500 text-xl md:text-2xl">filter_alt</span>
    </button>

    <!-- LOCATION BUTTON -->
    <button onclick="map.locate({setView: true, maxZoom: 14})"
            class="absolute top-16 right-4 md:top-20 md:right-6 z-20 w-10 h-10 md:w-12 md:h-12 bg-white text-slate-700 rounded-full shadow-lg hover:text-primary hover:scale-110 transition-all duration-300 flex items-center justify-center border border-slate-100 group"
            title="Vị trí của tôi">
        <span class="material-symbols-outlined text-xl md:text-2xl">my_location</span>
    </button>

    <!-- FILTER PANEL (Right Aligned) -->
    <div id="filterPanel" class="absolute top-16 right-4 md:top-20 md:right-6 z-20 w-64 md:w-72 bg-white rounded-2xl shadow-2xl p-4 md:p-5 hidden border border-slate-100 origin-top-right animate-scale-in">
        <!-- Header -->
        <div class="flex justify-between items-center mb-4 pb-2 border-b border-slate-50">
            <h3 class="font-bold text-slate-800 flex items-center gap-2 text-sm md:text-base">
                <span class="material-symbols-outlined text-primary text-lg">tune</span>
                Bộ lọc hiển thị
            </h3>
            <button onclick="toggleFilterPanel()" class="text-slate-400 hover:text-slate-600 transition">
                <span class="material-symbols-outlined text-lg">close</span>
            </button>
        </div>

        <!-- Content -->
        <div class="space-y-4">
            <!-- Category Select -->
            <div>
                <label class="block text-xs font-bold text-slate-500 uppercase mb-1.5">Danh mục</label>
                <div class="relative">
                    <select id="filterCategory" class="w-full pl-3 pr-8 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium text-slate-700 focus:ring-2 focus:ring-primary focus:border-transparent outline-none appearance-none cursor-pointer transition" onchange="reloadMapData()">
                        <option value="">Tất cả danh mục</option>
                    </select>
                    <span class="absolute right-3 top-2.5 pointer-events-none text-slate-500">
                        <span class="material-symbols-outlined text-lg">expand_more</span>
                    </span>
                </div>
            </div>

            <!-- Checkboxes -->
            <div>
                <label class="block text-xs font-bold text-slate-500 uppercase mb-2">Loại điểm</label>
                <div class="space-y-2">
                    <label class="flex items-center gap-3 cursor-pointer group p-2 hover:bg-slate-50 rounded-lg transition -mx-2">
                        <div class="relative flex items-center">
                            <input type="checkbox" id="filterPublicPoint" class="peer sr-only" checked onchange="reloadMapData()">
                            <div class="w-5 h-5 border-2 border-slate-300 rounded peer-checked:bg-primary peer-checked:border-primary transition-all"></div>
                            <span class="material-symbols-outlined text-white text-[14px] absolute top-0.5 left-0.5 opacity-0 peer-checked:opacity-100">check</span>
                        </div>
                        <span class="text-sm text-slate-700 font-medium group-hover:text-primary transition-colors">♻️ Điểm công cộng</span>
                    </label>

                    <label class="flex items-center gap-3 cursor-pointer group p-2 hover:bg-slate-50 rounded-lg transition -mx-2">
                        <div class="relative flex items-center">
                            <input type="checkbox" id="filterCompanyPoint" class="peer sr-only" checked onchange="reloadMapData()">
                            <div class="w-5 h-5 border-2 border-slate-300 rounded peer-checked:bg-yellow-500 peer-checked:border-yellow-500 transition-all"></div>
                            <span class="material-symbols-outlined text-white text-[14px] absolute top-0.5 left-0.5 opacity-0 peer-checked:opacity-100">check</span>
                        </div>
                        <span class="text-sm text-slate-700 font-medium group-hover:text-yellow-600 transition-colors">🏢 Điểm doanh nghiệp</span>
                    </label>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODALS -->

<!-- 1. All Items List Modal -->
<div id="allItemsModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[80]">
    <div class="bg-white rounded-2xl w-full max-w-2xl shadow-2xl relative flex flex-col max-h-[85vh] overflow-hidden modal-animate">
        <div class="p-4 border-b border-slate-100 flex justify-between items-center bg-white shrink-0">
            <h3 class="font-bold text-lg text-slate-800 flex items-center gap-2">
                <span class="material-symbols-outlined text-primary">inventory_2</span>
                Tất cả vật phẩm
            </h3>
            <button onclick="document.getElementById('allItemsModal').classList.add('hidden')" class="text-slate-400 hover:text-slate-600 p-2 rounded-full hover:bg-slate-100 transition">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="p-3 bg-slate-50 border-b border-slate-100 shrink-0 space-y-2">
            <input type="text" id="searchItemInput" onkeyup="filterList('searchItemInput', 'allItemsList')" placeholder="Tìm kiếm vật phẩm..." class="w-full px-4 py-2 rounded-xl border border-slate-200 text-sm focus:ring-2 focus:ring-primary outline-none">

            <!-- NEW: Filter Dropdown -->
            <select id="filterItemCategory" onchange="openAllItemsList()" class="w-full px-4 py-2 rounded-xl border border-slate-200 text-sm focus:ring-2 focus:ring-primary outline-none bg-white">
                <option value="">Tất cả danh mục</option>
                <!-- Categories will be loaded here -->
            </select>
        </div>
        <div id="allItemsList" class="flex-1 overflow-y-auto p-4 space-y-3 custom-scrollbar bg-slate-50">
            <!-- Items will be injected here -->
            <div class="text-center text-slate-500 py-8">Đang tải...</div>
        </div>
    </div>
</div>

<!-- 2. All Points List Modal -->
<div id="allPointsModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[80]">
    <div class="bg-white rounded-2xl w-full max-w-2xl shadow-2xl relative flex flex-col max-h-[85vh] overflow-hidden modal-animate">
        <div class="p-4 border-b border-slate-100 flex justify-between items-center bg-white shrink-0">
            <h3 class="font-bold text-lg text-slate-800 flex items-center gap-2">
                <span class="material-symbols-outlined text-green-600">recycling</span>
                Tất cả điểm tập kết
            </h3>
            <button onclick="document.getElementById('allPointsModal').classList.add('hidden')" class="text-slate-400 hover:text-slate-600 p-2 rounded-full hover:bg-slate-100 transition">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="p-3 bg-slate-50 border-b border-slate-100 shrink-0 space-y-2">
            <input type="text" id="searchPointInput" onkeyup="filterList('searchPointInput', 'allPointsList')" placeholder="Tìm kiếm điểm tập kết..." class="w-full px-4 py-2 rounded-xl border border-slate-200 text-sm focus:ring-2 focus:ring-primary outline-none">

            <!-- NEW: Filter Dropdowns -->
            <div class="flex gap-2">
                <select id="filterPointType" onchange="openAllPointsList()" class="flex-1 px-3 py-2 rounded-xl border border-slate-200 text-sm focus:ring-2 focus:ring-primary outline-none bg-white">
                    <option value="">Tất cả loại rác</option>
                    <c:forEach var="t" items="${pointTypes}">
                        <option value="${t.typeCode}">${t.displayName}</option>
                    </c:forEach>
                </select>
                <select id="filterPointOwner" onchange="openAllPointsList()" class="flex-1 px-3 py-2 rounded-xl border border-slate-200 text-sm focus:ring-2 focus:ring-primary outline-none bg-white">
                    <option value="">Tất cả nguồn gốc</option>
                    <option value="PUBLIC">♻️ Công cộng</option>
                    <option value="COMPANY">🏢 Doanh nghiệp</option>
                </select>
            </div>
        </div>
        <div id="allPointsList" class="flex-1 overflow-y-auto p-4 space-y-3 custom-scrollbar bg-slate-50">
            <!-- Points will be injected here -->
            <div class="text-center text-slate-500 py-8">Đang tải...</div>
        </div>
    </div>
</div>

<!-- 3. Congrats Modal -->
<div id="congratsModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[60]">
    <div class="bg-white p-8 rounded-2xl w-full max-w-sm shadow-2xl text-center modal-animate relative">
        <button onclick="document.getElementById('congratsModal').classList.add('hidden')" class="absolute top-4 right-4 text-slate-400 hover:text-slate-600 transition">
            <span class="material-symbols-outlined">close</span>
        </button>
        <div class="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span class="text-5xl">🎉</span>
        </div>
        <h2 class="text-2xl font-bold text-primary mb-2">Chúc mừng bạn!</h2>
        <p class="text-slate-600 mb-4" id="congratsText">Bạn vừa được xác nhận tặng quà.</p>
        <div class="inline-flex items-center gap-2 px-3 py-1 bg-green-50 text-green-700 rounded-full text-xs font-bold border border-green-100 mb-6">
            <span class="w-2 h-2 bg-green-500 rounded-full"></span>
            CONFIRMED
        </div>
        <button onclick="document.getElementById('congratsModal').classList.add('hidden')" class="w-full bg-primary text-white font-bold py-3 rounded-xl hover:bg-primary-hover transition shadow-lg shadow-emerald-100">Tuyệt vời</button>
    </div>
</div>

<!-- 4. Rating Modal -->
<div id="ratingModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[70]">
    <div class="bg-white p-6 rounded-2xl w-full max-w-sm shadow-2xl relative modal-animate">
        <h2 class="text-xl font-bold text-slate-800 text-center mb-2">Đánh giá người tặng</h2>
        <p class="text-sm text-slate-500 text-center mb-6">Xác nhận bạn đã nhận được món đồ và đánh giá trải nghiệm.</p>

        <div class="mb-4">
            <label class="block text-xs font-bold text-slate-700 uppercase mb-2">Mức độ hài lòng</label>
            <select id="ratingValue" class="w-full p-3 border border-slate-200 rounded-xl bg-yellow-50 text-yellow-700 font-bold focus:ring-2 focus:ring-yellow-400 outline-none">
                <option value="5">⭐⭐⭐⭐⭐ (Tuyệt vời)</option>
                <option value="4">⭐⭐⭐⭐ (Tốt)</option>
                <option value="3">⭐⭐⭐ (Bình thường)</option>
                <option value="2">⭐⭐ (Tệ)</option>
                <option value="1">⭐ (Rất tệ)</option>
            </select>
        </div>

        <div class="mb-6">
            <label class="block text-xs font-bold text-slate-700 uppercase mb-2">Lời nhắn</label>
            <textarea id="ratingComment" rows="3" class="w-full p-3 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-primary outline-none resize-none" placeholder="Viết lời cảm ơn hoặc nhận xét..."></textarea>
        </div>

        <div class="flex gap-3">
            <button onclick="document.getElementById('ratingModal').classList.add('hidden')" class="flex-1 bg-slate-100 text-slate-700 py-2.5 rounded-xl font-bold hover:bg-slate-200 transition">Hủy</button>
            <button onclick="submitRating()" class="flex-1 bg-primary text-white py-2.5 rounded-xl font-bold hover:bg-primary-hover transition shadow-md">Gửi đánh giá</button>
        </div>
    </div>
</div>

<!-- 5. Give Away Modal (Post Item) -->
<div id="giveAwayModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
    <div class="bg-white p-6 md:p-8 rounded-2xl w-full max-w-lg shadow-2xl relative modal-animate max-h-[90vh] overflow-y-auto">
        <button onclick="closeModal('giveAwayModal')" class="absolute top-5 right-5 text-slate-400 hover:text-slate-600 transition">
            <span class="material-symbols-outlined">close</span>
        </button>
        <h2 class="text-xl md:text-2xl font-bold mb-6 text-slate-800 flex items-center gap-2">
            <span class="material-symbols-outlined text-primary">volunteer_activism</span>
            Đăng tin Tặng đồ
        </h2>

        <!-- Step 1 -->
        <div id="step1" class="modal-step space-y-4">
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Tên vật phẩm</label>
                <input type="text" id="itemName" placeholder="VD: Sách giáo khoa cũ..." class="w-full p-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary outline-none transition" required />
            </div>
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Danh mục</label>
                <select id="itemCategory" class="w-full p-3 border border-slate-200 rounded-xl bg-white focus:ring-2 focus:ring-primary outline-none transition" required onchange="updateEcoPoints()">
                    <option value="" disabled selected>-- Chọn danh mục --</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Điểm thưởng (EcoPoints)</label>
                <div class="relative">
                    <input type="number" id="itemEcoPoints" class="w-full p-3 border border-slate-200 rounded-xl bg-slate-50 text-slate-600 font-bold cursor-not-allowed" readonly />
                    <span class="absolute right-4 top-3.5 text-primary font-bold flex items-center gap-1"><span class="material-symbols-outlined text-sm">eco</span></span>
                </div>
            </div>
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Mô tả chi tiết</label>
                <textarea id="itemDescription" placeholder="Tình trạng, kích thước, lưu ý..." rows="3" class="w-full p-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary outline-none transition resize-none" required></textarea>
            </div>
            <button onclick="nextStep(2)" class="w-full bg-primary text-white p-3 rounded-xl font-bold hover:bg-primary-hover transition shadow-md mt-2">Tiếp tục</button>
        </div>

        <!-- Step 2 -->
        <div id="step2" class="modal-step hidden space-y-4">
            <div class="text-center mb-4">
                <div class="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-2">
                    <span class="material-symbols-outlined text-slate-400 text-3xl">add_a_photo</span>
                </div>
                <p class="text-sm text-slate-500">Chụp ảnh vật phẩm rõ nét để người nhận dễ hình dung</p>
            </div>
            <input type="file" id="itemPhoto" accept="image/*" class="w-full p-3 border border-slate-200 rounded-xl file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-emerald-50 file:text-primary hover:file:bg-emerald-100 transition" required />
            <button onclick="nextStep(3)" class="w-full bg-primary text-white p-3 rounded-xl font-bold hover:bg-primary-hover transition shadow-md mt-4">Tiếp tục</button>
        </div>

        <!-- Step 3 -->
        <div id="step3" class="modal-step hidden space-y-4">
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Địa chỉ lấy đồ</label>
                <div class="flex gap-2 relative">
                    <div class="flex-1 relative">
                        <input type="text" id="itemAddress" placeholder="Nhập địa chỉ (VD: 123 Lê Lợi...)" class="w-full p-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary outline-none" autocomplete="off" />
                        <ul id="suggestionList" class="absolute left-0 right-0 top-full bg-white border border-slate-200 rounded-xl shadow-lg z-[9999] max-h-60 overflow-y-auto hidden mt-1"></ul>
                    </div>
                    <button onclick="searchAddress('itemAddress', 'miniMap', 'locationMarker')" class="bg-blue-600 text-white px-4 rounded-xl font-bold hover:bg-blue-700 transition">
                        <span class="material-symbols-outlined">search</span>
                    </button>
                </div>
            </div>
            <div class="rounded-xl overflow-hidden border border-slate-200">
                <div id="miniMap" class="h-56 w-full"></div>
            </div>
            <button onclick="submitItem()" class="w-full bg-primary text-white p-3 rounded-xl font-bold hover:bg-primary-hover transition shadow-lg mt-2">Đăng tin ngay</button>
        </div>
    </div>
</div>

<!-- 6. Add Point Modal -->
<div id="addPointModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
    <div class="bg-white p-6 md:p-8 rounded-2xl w-full max-w-lg shadow-2xl relative modal-animate max-h-[90vh] overflow-y-auto">
        <button onclick="document.getElementById('addPointModal').classList.add('hidden')" class="absolute top-5 right-5 text-slate-400 hover:text-slate-600 transition">
            <span class="material-symbols-outlined">close</span>
        </button>
        <h2 id="addPointModalTitle" class="text-2xl font-bold mb-6 text-primary text-center">Thêm Điểm Tập Kết</h2>
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Tên điểm</label>
                <input type="text" id="pointName" placeholder="VD: Trạm Pin Q1" class="w-full p-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary outline-none" required />
            </div>
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Loại hình</label>
                <select id="pointType" class="w-full p-3 border border-slate-200 rounded-xl bg-white focus:ring-2 focus:ring-primary outline-none">
                    <c:forEach var="t" items="${pointTypes}">
                        <option value="${t.typeCode}">${t.icon} ${t.displayName}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Địa chỉ</label>
                <div class="flex gap-2 relative">
                    <div class="flex-1 relative">
                        <input type="text" id="pointAddress" placeholder="Nhập địa chỉ..." class="w-full p-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary outline-none" autocomplete="off" />
                        <ul id="pointSuggestionList" class="absolute left-0 right-0 top-full bg-white border border-slate-200 rounded-xl shadow-lg z-[9999] max-h-60 overflow-y-auto hidden mt-1"></ul>
                    </div>
                    <button onclick="searchAddress('pointAddress', 'pointMiniMap', 'pointMarker')" class="bg-blue-600 text-white px-4 rounded-xl font-bold hover:bg-blue-700 transition">
                        <span class="material-symbols-outlined">search</span>
                    </button>
                </div>
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-500 uppercase mb-2">Vị trí (Kéo để chỉnh)</label>
                <div class="rounded-xl overflow-hidden border border-slate-200">
                    <div id="pointMiniMap" class="h-48 w-full z-0"></div>
                </div>
            </div>
            <button onclick="submitCollectionPoint()" class="w-full bg-primary text-white p-3 rounded-xl font-bold hover:bg-primary-hover transition shadow-md mt-2">Xác nhận Thêm</button>
        </div>
    </div>
</div>

<!-- 7. Item Detail Modal -->
<div id="itemDetailModal" class="fixed inset-0 hidden bg-slate-900/70 backdrop-blur-sm flex items-center justify-center p-4 z-[80]">
    <div class="bg-white rounded-2xl w-full max-w-2xl shadow-2xl relative flex flex-col max-h-[90vh] overflow-hidden modal-animate">
        <button onclick="document.getElementById('itemDetailModal').classList.add('hidden')" class="absolute top-4 right-4 z-10 bg-white/80 backdrop-blur rounded-full p-2 text-slate-500 hover:text-slate-800 hover:bg-white transition shadow-sm">
            <span class="material-symbols-outlined text-xl">close</span>
        </button>

        <div class="overflow-y-auto flex-1 custom-scrollbar">
            <!-- Ảnh sản phẩm -->
            <div class="w-full h-64 md:h-72 bg-slate-100 relative">
                <img id="detailImg" src="" class="w-full h-full object-contain" alt="Item Image">
            </div>

            <div class="p-6 md:p-8">
                <!-- Header: Tên & Ngày -->
                <div class="flex flex-col md:flex-row justify-between items-start mb-4 gap-2">
                    <h2 id="detailTitle" class="text-xl md:text-2xl font-bold text-slate-800 leading-tight">Tên sản phẩm</h2>
                    <span id="detailDate" class="text-xs font-medium text-slate-500 bg-slate-100 px-3 py-1 rounded-full whitespace-nowrap">...</span>
                </div>

                <!-- Người đăng & EcoPoints -->
                <div class="flex items-center gap-4 mb-6 pb-6 border-b border-slate-100">
                    <div class="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center text-primary font-bold text-xl shadow-inner">
                        <span id="detailAvatar">?</span>
                    </div>
                    <div>
                        <div class="font-bold text-slate-800" id="detailGiver">Người đăng</div>
                        <div class="text-sm text-primary font-medium flex items-center gap-1">
                            <span class="material-symbols-outlined text-sm">eco</span>
                            <span id="detailGiverPoints">0</span> EcoPoints
                        </div>
                    </div>
                </div>

                <!-- Thông tin chi tiết -->
                <div class="space-y-6 mb-8">
                    <div>
                        <h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Mô tả</h4>
                        <p id="detailDesc" class="text-slate-600 leading-relaxed">...</p>
                    </div>
                    <div>
                        <h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Địa chỉ nhận</h4>
                        <div class="flex items-start gap-2 text-slate-700 font-medium bg-slate-50 p-3 rounded-lg border border-slate-100">
                            <span class="material-symbols-outlined text-slate-400">location_on</span>
                            <span id="detailAddress">...</span>
                        </div>
                    </div>
                </div>

                <!-- Gợi ý sản phẩm -->
                <div id="relatedSection" class="hidden">
                    <h3 class="font-bold text-slate-800 mb-4 text-sm flex items-center gap-2">
                        <span class="material-symbols-outlined text-yellow-500">auto_awesome</span>
                        Có thể bạn cũng thích
                    </h3>
                    <div id="relatedItems" class="grid grid-cols-3 gap-4">
                        <!-- Items will be injected here -->
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer Actions -->
        <div class="p-5 border-t border-slate-100 bg-slate-50 flex justify-end gap-3">
            <button onclick="document.getElementById('itemDetailModal').classList.add('hidden')" class="px-6 py-2.5 text-sm font-bold text-slate-600 hover:bg-slate-200 rounded-xl transition hidden md:block">Đóng</button>
            <div id="detailActionContainer" class="flex-1 md:flex-none min-w-[160px]">
                <!-- Action button will be injected here -->
            </div>
        </div>
    </div>
</div>

<!-- 8. Leaderboard Modal -->
<div id="leaderboardModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[90]">
    <div class="bg-white rounded-2xl w-full max-w-md shadow-2xl relative flex flex-col max-h-[80vh] overflow-hidden modal-animate">
        <div class="bg-gradient-to-r from-yellow-400 to-orange-500 p-4 flex justify-between items-center text-white shadow-md shrink-0 h-16">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center text-xl backdrop-blur-sm">🏆</div>
                <div>
                    <h3 class="font-bold text-lg">Bảng Xếp Hạng</h3>
                    <p class="text-[10px] opacity-90">Top thành viên tích cực nhất</p>
                </div>
            </div>
            <button onclick="toggleLeaderboardModal()" class="text-white/80 hover:text-white transition p-2">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>

        <div class="flex-1 overflow-y-auto p-4 bg-slate-50 custom-scrollbar" id="leaderboardList">
            <!-- Leaderboard items will be injected here -->
            <div class="text-center text-slate-500 py-4">Đang tải dữ liệu...</div>
        </div>
    </div>
</div>

<!-- Floating Buttons -->
<div class="fixed bottom-6 right-4 md:right-6 flex flex-col gap-4 z-40">
    <!-- Leaderboard Button -->
    <button onclick="toggleLeaderboardModal()" class="w-12 h-12 md:w-14 md:h-14 bg-yellow-400 hover:bg-yellow-500 text-white rounded-full shadow-lg shadow-yellow-200 transition transform hover:scale-110 flex items-center justify-center border-2 border-white group relative">
        <span class="text-xl md:text-2xl">🏆</span>
        <span class="absolute right-full mr-3 bg-slate-800 text-white text-xs font-bold px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition whitespace-nowrap pointer-events-none hidden md:block">Bảng xếp hạng</span>
    </button>

    <!-- AI Button -->
    <button onclick="toggleAiModal()" class="w-12 h-12 md:w-14 md:h-14 bg-blue-600 hover:bg-blue-700 text-white rounded-full shadow-lg shadow-blue-200 transition transform hover:scale-110 flex items-center justify-center border-2 border-white group relative">
        <span class="text-xl md:text-2xl">🤖</span>
        <span class="absolute right-full mr-3 bg-slate-800 text-white text-xs font-bold px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition whitespace-nowrap pointer-events-none hidden md:block">Trợ lý AI</span>
    </button>

    <!-- Chat Button -->
    <button id="btnOpenInbox" onclick="toggleChatModal(false)" class="w-12 h-12 md:w-14 md:h-14 bg-primary hover:bg-primary-hover text-white rounded-full shadow-lg shadow-emerald-200 transition transform hover:scale-110 flex items-center justify-center border-2 border-white relative group">
        <span class="material-symbols-outlined text-xl md:text-2xl">chat</span>
        <span id="msgBadge" class="absolute top-0 right-0 w-4 h-4 bg-red-500 border-2 border-white rounded-full hidden"></span>
        <span class="absolute right-full mr-3 bg-slate-800 text-white text-xs font-bold px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition whitespace-nowrap pointer-events-none hidden md:block">Tin nhắn</span>
    </button>
</div>

<!-- CHAT MODAL (RESPONSIVE) -->
<div id="chatModal" class="fixed inset-0 md:inset-auto md:bottom-24 md:right-6 md:w-[850px] md:h-[550px] bg-white md:rounded-2xl shadow-2xl border-0 md:border border-slate-200 hidden z-50 flex overflow-hidden modal-animate flex-col md:flex-row">

    <!-- Inbox List -->
    <div id="inboxPanel" class="w-full md:w-1/3 bg-slate-50 border-r border-slate-200 flex flex-col h-full">
        <div class="p-4 bg-white border-b border-slate-100 font-bold text-slate-700 flex justify-between items-center h-16 shrink-0">
            <span class="flex items-center gap-2"><span class="material-symbols-outlined">inbox</span> Hộp thư</span>
            <button onclick="toggleChatModal(true)" class="text-slate-400 hover:text-slate-600 p-2">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div id="inboxList" class="flex-1 overflow-y-auto p-2 space-y-1 custom-scrollbar"></div>
    </div>

    <!-- Chat Detail -->
    <div id="chatDetailPanel" class="w-full md:w-2/3 flex-col bg-white hidden md:flex relative h-full absolute inset-0 md:static z-10">
        <!-- Chat Header -->
        <div class="p-3 border-b border-slate-100 flex justify-between items-center bg-white shadow-sm z-10 h-16 shrink-0">
            <div class="flex items-center gap-3 overflow-hidden">
                <button onclick="backToInbox()" class="md:hidden text-slate-500 hover:text-primary p-1 -ml-1">
                    <span class="material-symbols-outlined">arrow_back</span>
                </button>
                <div class="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-primary font-bold text-lg shadow-inner shrink-0" id="chatHeaderAvatar">?</div>
                <div class="min-w-0">
                    <div id="chatTitle" class="font-bold text-slate-800 text-sm truncate">Chọn người chat</div>
                    <div id="chatItemInfo" class="hidden text-[11px] text-slate-500 flex items-center gap-1 bg-slate-100 px-2 py-0.5 rounded mt-0.5 truncate">
                        <span>📦</span> <span id="chatItemName" class="font-bold text-primary truncate max-w-[120px]">...</span>
                    </div>
                </div>
            </div>
            <div class="flex items-center gap-1 md:gap-2 shrink-0">
                <!-- Action Buttons -->
                <button id="btnGiverConfirm" onclick="confirmTransaction('giver_confirm')" class="hidden bg-primary text-white text-[10px] md:text-xs font-bold px-2 py-1.5 md:px-3 rounded-lg hover:bg-primary-hover shadow-md animate-pulse flex items-center gap-1">
                    <span>🎁</span> <span class="hidden md:inline">Xác nhận đã cho</span><span class="md:hidden">Đã cho</span>
                </button>
                <button id="btnReceiverConfirm" onclick="confirmTransaction('receiver_confirm')" class="hidden bg-blue-600 text-white text-[10px] md:text-xs font-bold px-2 py-1.5 md:px-3 rounded-lg hover:bg-blue-700 shadow-md animate-bounce flex items-center gap-1">
                    <span>✅</span> <span class="hidden md:inline">Xác nhận đã nhận</span><span class="md:hidden">Đã nhận</span>
                </button>
                <button onclick="backToInbox()" class="hidden md:block text-slate-400 hover:text-slate-600 ml-2">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
        </div>

        <!-- Messages Area -->
        <div id="chatMessages" class="flex-1 p-4 overflow-y-auto bg-slate-50 text-sm space-y-3 custom-scrollbar pb-20 md:pb-4">
            <div class="flex flex-col items-center justify-center h-full text-slate-400 gap-2">
                <span class="material-symbols-outlined text-4xl opacity-50">chat_bubble_outline</span>
                <p class="text-xs">Chọn hội thoại hoặc bấm Nhận trên bản đồ</p>
            </div>
        </div>

        <!-- Quick Replies -->
        <div id="quickReplies" class="px-4 py-2 bg-white flex gap-2 overflow-x-auto border-t border-slate-100 hidden no-scrollbar shrink-0">
            <button id="qrGiver" onclick="confirmTransaction('giver_confirm')"
                    class="hidden whitespace-nowrap bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-medium px-3 py-1.5 rounded-full hover:bg-emerald-100 transition">
                🎁 Xác nhận đã cho
            </button>
            <button id="qrReceiver1" onclick="confirmTransaction('receiver_confirm')"
                    class="hidden whitespace-nowrap bg-blue-50 border border-blue-200 text-blue-700 text-xs font-medium px-3 py-1.5 rounded-full hover:bg-blue-100 transition">
                ✅ Xác nhận đã nhận
            </button>
            <button id="qrReceiver2" onclick="sendQuickReply('Bạn ơi, khi nào mình có thể qua lấy đồ được ạ?')"
                    class="hidden whitespace-nowrap bg-slate-50 border border-slate-200 text-slate-600 text-xs font-medium px-3 py-1.5 rounded-full hover:bg-slate-100 transition">
                🕒 Hẹn lịch nhận
            </button>
        </div>

        <!-- Input Area -->
        <div class="p-3 border-t border-slate-100 bg-white flex gap-2 shrink-0 pb-safe md:pb-3">
            <input type="text" id="chatInput" disabled class="flex-1 border border-slate-200 rounded-full px-4 py-2.5 text-sm bg-slate-50 focus:bg-white focus:ring-2 focus:ring-primary outline-none transition" placeholder="Nhập tin nhắn...">
            <button onclick="sendMessage()" id="btnSend" disabled class="bg-primary text-white rounded-full w-10 h-10 flex items-center justify-center hover:bg-primary-hover transition shadow-sm disabled:opacity-50 disabled:cursor-not-allowed shrink-0">
                <span class="material-symbols-outlined text-[20px]">send</span>
            </button>
        </div>
    </div>
</div>

<!-- AI MODAL (RESPONSIVE) -->
<div id="aiModal" class="fixed inset-0 md:inset-auto md:bottom-24 md:right-20 md:w-96 md:h-[500px] bg-white md:rounded-2xl shadow-2xl border-0 md:border border-slate-200 hidden z-40 flex flex-col overflow-hidden font-sans modal-animate" >
    <div class="bg-gradient-to-r from-blue-600 to-blue-500 p-4 flex justify-between items-center text-white shadow-md shrink-0 h-16">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center text-xl backdrop-blur-sm">🤖</div>
            <div>
                <h3 class="font-bold text-sm">Trợ lý EcoBot</h3>
                <p class="text-[10px] opacity-90">Hỏi tôi về cách xử lý rác!</p>
            </div>
        </div>
        <button onclick="toggleAiModal()" class="text-white/80 hover:text-white transition p-2">
            <span class="material-symbols-outlined">close</span>
        </button>
    </div>
    <div id="aiChatBody" class="flex-1 p-4 overflow-y-auto bg-slate-50 space-y-4 text-sm custom-scrollbar pb-20 md:pb-4">
        <div class="flex items-start gap-2">
            <div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-xs shrink-0 border border-blue-200">🤖</div>
            <div class="bg-white border border-slate-200 p-3 rounded-2xl rounded-tl-none shadow-sm max-w-[85%] text-slate-700">
                Xin chào! Bạn đang có loại rác thải nào cần xử lý? (VD: Pin cũ, thuốc hết hạn, đồ điện tử...)
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 gap-2 mt-2 px-2">
            <button onclick="quickAction('name')" class="text-left text-xs bg-white hover:bg-blue-50 text-blue-600 py-2.5 px-3 rounded-xl border border-blue-100 shadow-sm transition flex items-center gap-2">
                <span class="material-symbols-outlined text-sm">search</span> Tìm sản phẩm theo tên...
            </button>
            <button onclick="quickAction('category')" class="text-left text-xs bg-white hover:bg-blue-50 text-blue-600 py-2.5 px-3 rounded-xl border border-blue-100 shadow-sm transition flex items-center gap-2">
                <span class="material-symbols-outlined text-sm">category</span> Tìm sản phẩm theo danh mục...
            </button>
            <button onclick="quickAction('point')" class="text-left text-xs bg-white hover:bg-blue-50 text-blue-600 py-2.5 px-3 rounded-xl border border-blue-100 shadow-sm transition flex items-center gap-2">
                <span class="material-symbols-outlined text-sm">location_on</span> Tìm điểm thu gom gần đây
            </button>
            <button onclick="quickAction('guide')" class="text-left text-xs bg-white hover:bg-blue-50 text-blue-600 py-2.5 px-3 rounded-xl border border-blue-100 shadow-sm transition flex items-center gap-2">
                <span class="material-symbols-outlined text-sm">help</span> Cách tích điểm EcoPoints?
            </button>
            <button onclick="quickAction('recycle')" class="text-left text-xs bg-white hover:bg-green-50 text-green-600 py-2.5 px-3 rounded-xl border border-green-100 shadow-sm transition flex items-center gap-2">
                <span class="material-symbols-outlined text-sm">recycling</span> Hướng dẫn cách tái chế
            </button>
        </div>
    </div>
    <div class="p-3 border-t border-slate-100 bg-white shrink-0 pb-safe md:pb-3">
        <div class="flex gap-2">
            <input type="text" id="aiInput" class="flex-1 border border-slate-200 rounded-full px-4 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition" placeholder="Nhập câu hỏi...">
            <button onclick="sendAiQuestion()" class="bg-blue-600 text-white w-9 h-9 rounded-full flex items-center justify-center hover:bg-blue-700 transition shadow-sm shrink-0">
                <span class="material-symbols-outlined text-[18px]">send</span>
            </button>
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
    const MAPTILER_API_KEY = 'N9qb9p6GF8fszXu3BPWt';

    let chatSocket = null;
    let currentReceiverId = null;
    let currentDiscussingItemId = null;
    let isOwnerOfCurrentItem = false;
    let miniMap, locationMarker;
    let pointMap, pointMarker;
    let pointLatLng = { lat: 10.7769, lng: 106.7009 };
    let currentLatLng = { lat: 10.7769, lng: 106.7009 };
    let loadedItemIds = new Set();

    let itemLayers = [];
    let pointLayers = [];
    let itemDataCache = {};

    // --- INFINITE SCROLL VARS ---
    let currentPageItems = 1;
    let isLoadingItems = false;
    let hasMoreItems = true;
    let currentPagePoints = 1;
    let isLoadingPoints = false;
    let hasMorePoints = true;
    const ITEMS_PER_PAGE = 10;
    // ----------------------------

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
        loadCategoriesForFilter();
        loadItems();
        loadCollectionPoints();

        map.on('moveend', loadItems);

        document.addEventListener('click', function(e) {
            const suggestionList = document.getElementById('suggestionList');
            const itemAddress = document.getElementById('itemAddress');
            if (suggestionList && !suggestionList.contains(e.target) && e.target !== itemAddress) {
                suggestionList.classList.add('hidden');
            }

            const pointSuggestionList = document.getElementById('pointSuggestionList');
            const pointAddress = document.getElementById('pointAddress');
            if (pointSuggestionList && !pointSuggestionList.contains(e.target) && e.target !== pointAddress) {
                pointSuggestionList.classList.add('hidden');
            }
        });

        // --- INFINITE SCROLL EVENTS ---
        document.getElementById('allItemsList').addEventListener('scroll', function() {
            if (this.scrollTop + this.clientHeight >= this.scrollHeight - 50) {
                loadMoreItems();
            }
        });

        document.getElementById('allPointsList').addEventListener('scroll', function() {
            if (this.scrollTop + this.clientHeight >= this.scrollHeight - 50) {
                loadMorePoints();
            }
        });
    });

    // --- 1. MAP & LOAD DATA ---
    const map = L.map('map').setView([10.7769, 106.7009], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OSM' }).addTo(map);

    // --- Geolocation ---
    map.locate({setView: true, maxZoom: 14, enableHighAccuracy: true});

    let userLocationMarker = null;
    let userLocationCircle = null;

    map.on('locationfound', function(e) {
        // Update variables for modals
        currentLatLng = e.latlng;
        pointLatLng = e.latlng;

        // Remove existing marker/circle if they exist
        if (userLocationMarker) map.removeLayer(userLocationMarker);
        if (userLocationCircle) map.removeLayer(userLocationCircle);

        // Visual feedback
        userLocationCircle = L.circle(e.latlng, {
            color: '#05976a',
            fillColor: '#05976a',
            fillOpacity: 0.1,
            radius: e.accuracy
        }).addTo(map);

        userLocationMarker = L.marker(e.latlng, {
            icon: L.divIcon({
                className: 'bg-primary w-4 h-4 rounded-full border-2 border-white shadow-md',
                iconSize: [16, 16]
            })
        }).addTo(map).bindPopup("Vị trí của bạn");
    });
    // -------------------

    // --- MỚI: Toggle Filter Panel ---
    function toggleFilterPanel() {
        const panel = document.getElementById('filterPanel');
        panel.classList.toggle('hidden');
    }
    // --------------------------------

    function reloadMapData() {
        itemLayers.forEach(layer => map.removeLayer(layer));
        itemLayers = [];
        loadedItemIds.clear();
        itemDataCache = {};

        pointLayers.forEach(layer => map.removeLayer(layer));
        pointLayers = [];

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
                    itemDataCache[item.itemId] = item;

                    let imgUrl;
                    if (item.imageUrl && item.imageUrl.startsWith('http')) {
                        imgUrl = item.imageUrl;
                    } else if (item.imageUrl) {
                        imgUrl = '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(item.imageUrl);
                    } else {
                        imgUrl = 'https://placehold.co/200x150';
                    }

                    let actionBtn = '';

                    if (currentUserId) {
                        if (item.giverId === currentUserId) {
                            actionBtn = `<button onclick="openManageChat(\${item.itemId}, '\${item.title}')" class="w-full bg-slate-100 text-slate-700 text-xs font-bold py-2 rounded-lg hover:bg-slate-200 border border-slate-200 transition">Quản lý & Chốt đơn 📩</button>`;
                        } else {
                            actionBtn = `<button onclick="requestItem(\${item.itemId}, \${item.giverId}, '\${item.giverName || 'Người tặng'}', '\${item.title}')" class="w-full bg-primary text-white text-xs font-bold py-2 rounded-lg hover:bg-primary-hover shadow-md transition">Xin món này 🎁</button>`;
                        }
                    } else {
                        actionBtn = `<a href="${pageContext.request.contextPath}/login" class="block w-full text-center bg-slate-100 text-slate-700 text-xs font-bold py-2 rounded-lg hover:bg-slate-200 transition">Đăng nhập để nhận</a>`;
                    }

                    const directionsBtn = `<a href="https://www.google.com/maps/search/?api=1&query=\${item.location.latitude},\${item.location.longitude}" target="_blank" class="block w-full bg-white text-slate-600 text-xs font-bold py-2 rounded-lg hover:bg-slate-50 border border-slate-200 mt-2 text-center transition">🗺️ Chỉ đường</a>`;

                    let addressHtml = '';
                    if (item.address) {
                        addressHtml = `<p class="text-xs text-slate-500 mb-2 flex items-center gap-1"><span class="text-[10px]">📍</span> \${item.address}</p>`;
                    }

                    const detailBtn = `<button onclick="openItemDetail(\${item.itemId})" class="block w-full bg-white text-primary text-xs font-bold py-2 rounded-lg border border-primary mb-2 hover:bg-emerald-50 transition">🔍 Xem chi tiết</button>`;

                    const content = `
                        <div>
                            <div class="relative">
                                <img src="\${imgUrl}" class="custom-popup-img">
                                <div class="absolute top-2 right-2 bg-white/90 backdrop-blur px-2 py-1 rounded text-[10px] font-bold text-primary shadow-sm">\${item.ecoPoints || 0} Points</div>
                            </div>
                            <div class="custom-popup-body">
                                <h3 class="font-bold text-sm text-slate-800 mb-1 line-clamp-1">\${item.title}</h3>
                                <p class="text-xs text-slate-500 mb-2">Người tặng: <span class="font-medium text-slate-700">\${item.giverName}</span></p>
                                \${addressHtml}
                                \${detailBtn}
                                \${actionBtn}
                                \${directionsBtn}
                            </div>
                        </div>`;
                    const marker = L.marker([item.location.latitude, item.location.longitude], {icon: blueIcon}).addTo(map).bindPopup(content);
                    itemLayers.push(marker);
                }
            });
        } catch (e) { console.error(e); }
    }

    function openItemDetail(itemId) {
        const item = itemDataCache[itemId];
        if (!item) return;

        let imgUrl = item.imageUrl && item.imageUrl.startsWith('http') ? item.imageUrl : (item.imageUrl ? '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(item.imageUrl) : 'https://placehold.co/400x300');
        document.getElementById('detailImg').src = imgUrl;
        document.getElementById('detailTitle').innerText = item.title;
        document.getElementById('detailDesc').innerText = item.description || "Không có mô tả";
        document.getElementById('detailAddress').innerText = item.address || "Chưa cập nhật địa chỉ";
        document.getElementById('detailGiver').innerText = item.giverName || "Ẩn danh";
        document.getElementById('detailAvatar').innerText = (item.giverName || "?").charAt(0).toUpperCase();
        document.getElementById('detailGiverPoints').innerText = item.giverEcoPoints || "0";

        let dateStr = "Vừa xong";
        if (item.postDate) {
            const d = new Date(item.postDate);
            const day = String(d.getDate()).padStart(2, '0');
            const month = String(d.getMonth() + 1).padStart(2, '0');
            const year = d.getFullYear();
            dateStr = day + '/' + month + '/' + year;
        }
        document.getElementById('detailDate').innerText = "Ngày đăng: " + dateStr;

        const actionContainer = document.getElementById('detailActionContainer');
        if (currentUserId) {
            if (item.giverId === currentUserId) {
                actionContainer.innerHTML = `<button onclick="openManageChat(\${item.itemId}, '\${item.title}'); document.getElementById('itemDetailModal').classList.add('hidden');" class="w-full bg-slate-100 text-slate-700 font-bold py-3 px-6 rounded-xl hover:bg-slate-200 border border-slate-200 transition">Quản lý tin đăng</button>`;
            } else {
                actionContainer.innerHTML = `<button onclick="requestItem(\${item.itemId}, \${item.giverId}, '\${item.giverName}', '\${item.title}'); document.getElementById('itemDetailModal').classList.add('hidden');" class="w-full bg-primary text-white font-bold py-3 px-6 rounded-xl hover:bg-primary-hover shadow-lg shadow-emerald-200 transition">Xin món này 🎁</button>`;
            }
        } else {
            actionContainer.innerHTML = `<a href="${pageContext.request.contextPath}/login" class="block w-full text-center bg-primary text-white font-bold py-3 px-6 rounded-xl hover:bg-primary-hover transition">Đăng nhập để xin</a>`;
        }

        const relatedContainer = document.getElementById('relatedItems');
        const relatedSection = document.getElementById('relatedSection');
        relatedContainer.innerHTML = '';

        const related = Object.values(itemDataCache).filter(i => i.categoryId == item.categoryId && i.itemId !== item.itemId);

        if (related.length > 0) {
            const shuffled = related.sort(() => 0.5 - Math.random()).slice(0, 3);

            shuffled.forEach(r => {
                let rImg = r.imageUrl && r.imageUrl.startsWith('http') ? r.imageUrl : (r.imageUrl ? '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(r.imageUrl) : 'https://placehold.co/100x100');
                relatedContainer.innerHTML += `
                    <div class="cursor-pointer group" onclick="openItemDetail(\${r.itemId})">
                        <div class="h-24 bg-slate-100 rounded-xl overflow-hidden mb-2 border border-slate-200 relative">
                            <img src="\${rImg}" class="w-full h-full object-cover group-hover:scale-110 transition duration-500">
                            <div class="absolute bottom-1 right-1 bg-black/50 text-white text-[9px] px-1.5 py-0.5 rounded backdrop-blur">\${r.ecoPoints || 0} pts</div>
                        </div>
                        <div class="text-xs font-bold text-slate-700 truncate group-hover:text-primary transition">\${r.title}</div>
                    </div>
                `;
            });
            relatedSection.classList.remove('hidden');
        } else {
            relatedSection.classList.add('hidden');
        }

        document.getElementById('itemDetailModal').classList.remove('hidden');
    }

    async function loadCollectionPoints() {
        try {
            const showPublic = document.getElementById('filterPublicPoint').checked;
            const showCompany = document.getElementById('filterCompanyPoint').checked;

            if (!showPublic && !showCompany) return;

            const response = await fetch('${pageContext.request.contextPath}/api/collection-points');
            const points = await response.json();

            points.forEach(p => {
                let icon;
                let popupHeader;
                let shouldShow = false;

                if (p.ownerRole === 'COLLECTOR_COMPANY') {
                    if (showCompany) {
                        icon = yellowIcon;
                        popupHeader = `<div class="bg-yellow-100 text-yellow-800 text-[10px] font-bold px-2 py-1 rounded mb-2 inline-block border border-yellow-200">🏢 Điểm thu gom Doanh nghiệp</div>`;
                        shouldShow = true;
                    }
                } else {
                    if (showPublic) {
                        icon = greenIcon;
                        popupHeader = `<div class="bg-green-100 text-green-800 text-[10px] font-bold px-2 py-1 rounded mb-2 inline-block border border-green-200">♻️ Điểm tập kết công cộng</div>`;
                        shouldShow = true;
                    }
                }

                if (shouldShow) {
                    const content = `
                        <div class="text-center p-4">
                            \${popupHeader}
                            <h3 class="font-bold text-slate-800 text-sm mb-1">\${p.name}</h3>
                            <p class="text-xs text-slate-500 mb-3">📍 \${p.address}</p>
                            <a href="https://www.google.com/maps/search/?api=1&query=\${p.latitude},\${p.longitude}" target="_blank" class="block w-full bg-slate-50 text-slate-600 text-xs font-bold py-2 rounded-lg hover:bg-slate-100 border border-slate-200 transition">🗺️ Chỉ đường</a>
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
        selectUserChat(giverId, giverName, itemId, itemTitle, giverId);
        setTimeout(() => sendMessageAuto("Chào bạn, mình muốn xin món '" + itemTitle + "'. Nó còn không ạ?"), 500);
    }

    async function openManageChat(itemId, itemTitle) {
        currentDiscussingItemId = itemId;
        isOwnerOfCurrentItem = true;
        openChatWindow();
        updateHeaderInfo(itemTitle);
        document.getElementById('chatTitle').innerText = 'Chọn người nhận';
        document.getElementById('chatHeaderAvatar').innerText = '?';
        document.getElementById('chatMessages').innerHTML = '<div class="flex flex-col items-center justify-center h-full text-slate-400 gap-2"><span class="material-symbols-outlined text-4xl opacity-50">arrow_back</span><p class="text-xs text-center">Chọn một người trong danh sách bên trái<br>để tặng món <b>' + itemTitle + '</b></p></div>';
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
            if (users.length === 0) { listEl.innerHTML = '<div class="text-center text-xs text-slate-400 mt-8">Chưa có tin nhắn</div>'; return; }
            users.forEach(u => {
                const activeClass = (u.userId == currentReceiverId) ? 'bg-emerald-50 border-primary' : 'border-transparent hover:bg-slate-50';

                const itemId = u.itemId || '';
                const itemName = u.itemName || '';
                const giverId = u.giverId || '';

                listEl.innerHTML += `
                    <div onclick="selectUserChat(\${u.userId}, '\${u.username}', '\${itemId}', '\${itemName}', '\${giverId}')"
                         class="cursor-pointer p-3 border-l-4 \${activeClass} transition flex items-center gap-3 border-b border-slate-100 last:border-0">
                        <div class="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center font-bold text-slate-600 overflow-hidden shrink-0">
                             <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=\${u.username}" class="w-full h-full">
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex justify-between items-center mb-0.5">
                                <div class="font-bold text-sm text-slate-800 truncate">\${u.username}</div>
                                <div class="text-[10px] text-slate-400">Vừa xong</div>
                            </div>
                            <div class="text-xs text-slate-500 truncate">\${u.lastMsg || '...'}</div>
                        </div>
                    </div>`;
            });
        } catch (e) {}
    }

    async function selectUserChat(userId, username, itemId, itemName, giverId) {
        currentReceiverId = userId;
        document.getElementById('chatTitle').innerText = username;
        document.getElementById('chatHeaderAvatar').innerHTML = `<img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=\${username}" class="w-full h-full rounded-full">`;
        const input = document.getElementById('chatInput');
        input.disabled = false; input.classList.remove('bg-slate-50'); input.classList.add('bg-white');
        document.getElementById('btnSend').disabled = false;

        // Mobile Logic: Hide Inbox, Show Detail
        if (window.innerWidth < 768) {
            document.getElementById('inboxPanel').classList.add('hidden');
            document.getElementById('inboxPanel').classList.remove('flex');
        }

        const detailPanel = document.getElementById('chatDetailPanel');
        detailPanel.classList.remove('hidden');
        detailPanel.classList.add('flex');

        const btnGiver = document.getElementById('btnGiverConfirm');
        const btnReceiver = document.getElementById('btnReceiverConfirm');
        btnGiver.classList.add('hidden');
        btnReceiver.classList.add('hidden');

        document.getElementById('quickReplies').classList.remove('hidden');

        document.getElementById('qrGiver').classList.add('hidden');
        document.getElementById('qrReceiver1').classList.add('hidden');
        document.getElementById('qrReceiver2').classList.add('hidden');

        if (itemId && itemId !== 'undefined') {
            currentDiscussingItemId = itemId;
            updateHeaderInfo(itemName);

            if (giverId && giverId != 'undefined') {
                isOwnerOfCurrentItem = (Number(giverId) === currentUserId);
            } else {
                isOwnerOfCurrentItem = false;
            }

            if (isOwnerOfCurrentItem) {
                document.getElementById('qrGiver').classList.remove('hidden');
            } else {
                document.getElementById('qrReceiver2').classList.remove('hidden');
            }

        } else {
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
        document.getElementById('inboxPanel').classList.add('flex');

        currentReceiverId = null;
        currentDiscussingItemId = null;
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
        chatBox.innerHTML = '<div class="text-center text-xs text-slate-400 mt-10">Đang tải...</div>';
        try {
            const res = await fetch('${pageContext.request.contextPath}/api/chat?action=history&partnerId=' + userId);
            const msgs = await res.json();
            chatBox.innerHTML = '';

            let lastSystemMsg = "";

            msgs.forEach(m => {
                if (m.content.startsWith("SYSTEM_GIFT:")) {
                    if (currentDiscussingItemId && m.itemId == currentDiscussingItemId) {
                        lastSystemMsg = m.content;
                    }
                    let cleanText = m.content.replace("SYSTEM_GIFT:", "");
                    appendSystemMessage(cleanText);
                } else {
                    appendMessage(m.content, m.senderId === currentUserId ? 'outgoing' : 'incoming');
                }
            });

            const btnGiver = document.getElementById('btnGiverConfirm');
            const btnReceiver = document.getElementById('btnReceiverConfirm');

            const qrGiver = document.getElementById('qrGiver');
            const qrReceiver1 = document.getElementById('qrReceiver1');
            const qrReceiver2 = document.getElementById('qrReceiver2');

            if (currentDiscussingItemId) {
                if (isOwnerOfCurrentItem) {
                    if (!lastSystemMsg.includes("CONFIRMED") && !lastSystemMsg.includes("COMPLETED")) {
                        btnGiver.classList.remove('hidden');
                        qrGiver.classList.remove('hidden');
                    } else {
                        btnGiver.classList.add('hidden');
                        qrGiver.classList.add('hidden');
                    }
                } else {
                    if (lastSystemMsg.includes("CONFIRMED") && !lastSystemMsg.includes("COMPLETED")) {
                        btnReceiver.classList.remove('hidden');
                        qrReceiver1.classList.remove('hidden');
                        qrReceiver2.classList.add('hidden');
                    } else if (!lastSystemMsg.includes("CONFIRMED") && !lastSystemMsg.includes("COMPLETED")) {
                        btnReceiver.classList.add('hidden');
                        qrReceiver1.classList.add('hidden');
                        qrReceiver2.classList.remove('hidden');
                    } else {
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

            let targetReceiverId;
            if (isOwnerOfCurrentItem) {
                targetReceiverId = currentReceiverId;
            } else {
                targetReceiverId = currentUserId;
            }
            fd.append('receiverId', targetReceiverId);

            fd.append('action', action);

            const res = await fetch('${pageContext.request.contextPath}/api/confirm-transaction', { method: 'POST', body: fd });
            const data = await res.json();

            if (data.status === 'success') {
                alert("✅ " + data.message);

                let sysMsg = "";
                if (action === 'giver_confirm') {
                    sysMsg = "SYSTEM_GIFT:Người tặng đã xác nhận giao đồ. Trạng thái: CONFIRMED. Bạn hãy xác nhận khi đã nhận được nhé!";
                    document.getElementById('btnGiverConfirm').classList.add('hidden');
                    document.getElementById('qrGiver').classList.add('hidden');
                } else {
                    sysMsg = "SYSTEM_GIFT:Người nhận đã xác nhận nhận đồ. Trạng thái: COMPLETED. Giao dịch hoàn tất!";
                    document.getElementById('btnReceiverConfirm').classList.add('hidden');
                    document.getElementById('qrReceiver1').classList.add('hidden');
                    openRatingModal();
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

    function sendQuickReply(text) {
        sendMessageAuto(text);
    }

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
        const cls = type === 'outgoing' ? 'bg-primary text-white ml-auto rounded-tr-none' : 'bg-white border border-slate-200 text-slate-700 mr-auto rounded-tl-none';
        box.innerHTML += `<div class="w-fit max-w-[80%] px-4 py-2.5 rounded-2xl mb-2 text-sm shadow-sm \${cls}">\${txt}</div>`;
        box.scrollTop = box.scrollHeight;
    }
    function appendSystemMessage(txt) {
        const box = document.getElementById('chatMessages');
        box.innerHTML += `<div class="text-center my-4"><span class="bg-yellow-50 text-yellow-800 text-xs font-bold px-3 py-1 rounded-full border border-yellow-100 shadow-sm">🎁 \${txt}</span></div>`;
        box.scrollTop = box.scrollHeight;
    }
    document.getElementById('chatInput').addEventListener('keypress', (e) => { if(e.key==='Enter') sendMessage(); });

    // --- AI BOT LOGIC ---
    function toggleAiModal() { const modal = document.getElementById('aiModal'); modal.classList.toggle('hidden'); if(!modal.classList.contains('hidden')) { document.getElementById('aiInput').focus(); } }
    document.getElementById('aiInput').addEventListener('keypress', function(e) { if(e.key === 'Enter') sendAiQuestion(); });

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
        } else if (type === 'recycle') {
            input.value = "Hướng dẫn cách tái chế: ";
            input.focus();
        }
    }

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

            if (data.quickReplies && data.quickReplies.length > 0) {
                let html = '<div class="grid grid-cols-1 gap-2 mt-2 px-2">';

                data.quickReplies.forEach(text => {
                    let actionType = '';
                    if (text.includes("tên")) actionType = 'name';
                    else if (text.includes("danh mục")) actionType = 'category';
                    else if (text.includes("điểm thu gom")) actionType = 'point';
                    else if (text.includes("tích điểm")) actionType = 'guide';
                    else if (text.includes("tái chế")) actionType = 'recycle';

                    if (actionType) {
                        html += `<button onclick="quickAction('\${actionType}')" class="text-left text-xs bg-white hover:bg-blue-50 text-blue-600 py-2 px-3 rounded-xl border border-blue-100 shadow-sm transition">\${text}</button>`;
                    }
                });

                html += '</div>';
                appendAiHtml(html);
            }

            if (data.suggestions && data.suggestions.length > 0) {
                let html = '<div class="flex flex-col gap-2 mt-2">';
                data.suggestions.forEach(s => {
                    html += `<div class="bg-blue-50 p-2 rounded-xl border border-blue-100 cursor-pointer hover:bg-blue-100 transition flex items-center gap-2" onclick="flyToLocation(\${s.lat}, \${s.lng}, '\${s.name}')"><div class="text-xl">📍</div><div class="overflow-hidden"><div class="font-bold text-blue-800 text-xs truncate">\${s.name}</div><div class="text-[10px] text-slate-500 truncate">\${s.address}</div></div></div>`;
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
        const bg = type === 'user' ? 'bg-blue-600 text-white rounded-tr-none' : 'bg-white border border-slate-200 text-slate-700 rounded-tl-none';
        const avatar = type === 'bot' ? '<div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-xs shrink-0 border border-blue-200">🤖</div>' : '';
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

            // --- MỚI: Đổi tiêu đề modal nếu là COMPANY ---
            if (currentUserRole === 'COLLECTOR_COMPANY') {
                document.getElementById('addPointModalTitle').innerText = "Thêm Điểm Thu Gom Doanh Nghiệp";
            } else {
                document.getElementById('addPointModalTitle').innerText = "Thêm Điểm Tập Kết";
            }
            // ---------------------------------------------

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
    document.getElementById('btnPostItemMobile').addEventListener('click', () => { document.getElementById('giveAwayModal').classList.remove('hidden'); document.getElementById('step1').classList.remove('hidden'); });
    function closeModal(id) { document.getElementById(id).classList.add('hidden'); }
    function nextStep(n) { document.querySelectorAll('.modal-step').forEach(e=>e.classList.add('hidden')); document.getElementById('step'+n).classList.remove('hidden'); if(n===3) setTimeout(()=>{ if(!miniMap) {miniMap=L.map('miniMap').setView([currentLatLng.lat, currentLatLng.lng], 15); L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'OSM'}).addTo(miniMap); locationMarker=L.marker([currentLatLng.lat,currentLatLng.lng],{draggable:true}).addTo(miniMap); locationMarker.on('dragend',e=>currentLatLng=e.target.getLatLng()); } else miniMap.invalidateSize(); },200); }

    function updateEcoPoints() {
        const select = document.getElementById('itemCategory');
        const selectedOption = select.options[select.selectedIndex];
        const points = selectedOption.getAttribute('data-points');
        document.getElementById('itemEcoPoints').value = points ? points : '';
    }

    async function loadCategories() { try { const r = await fetch('${pageContext.request.contextPath}/api/categories'); (await r.json()).forEach(c => document.getElementById('itemCategory').innerHTML += `<option value="\${c.categoryId}" data-points="\${c.fixedPoints}">\${c.name}</option>`); } catch(e){} }
    loadCategories();

    async function loadCategoriesForFilter() {
        try {
            const r = await fetch('${pageContext.request.contextPath}/api/categories');
            const categories = await r.json();
            const filterSelect = document.getElementById('filterCategory');
            const filterItemCategory = document.getElementById('filterItemCategory'); // NEW

            categories.forEach(c => {
                const option = `<option value="\${c.categoryId}">\${c.name}</option>`;
                filterSelect.innerHTML += option;
                if(filterItemCategory) filterItemCategory.innerHTML += option; // NEW
            });
        } catch(e){}
    }

    // --- SỬA ĐỔI: Hàm tìm kiếm địa chỉ dùng chung ---
    async function searchAddress(inputId, mapId, markerVarName) {
        const address = document.getElementById(inputId).value;
        if (!address) return;

        try {
            const response = await fetch(`https://api.maptiler.com/geocoding/\${encodeURIComponent(address)}.json?key=\${MAPTILER_API_KEY}`);
            const data = await response.json();

            if (data.features && data.features.length > 0) {
                const [lng, lat] = data.features[0].center;

                // Cập nhật biến tọa độ tương ứng
                if (markerVarName === 'locationMarker') {
                    currentLatLng = { lat, lng };
                    miniMap.setView([lat, lng], 15);
                    locationMarker.setLatLng([lat, lng]);
                } else if (markerVarName === 'pointMarker') {
                    pointLatLng = { lat, lng };
                    pointMap.setView([lat, lng], 15);
                    pointMarker.setLatLng([lat, lng]);
                }
            } else {
                alert("Không tìm thấy địa chỉ này!");
            }
        } catch (e) {
            console.error(e);
            alert("Lỗi khi tìm kiếm địa chỉ.");
        }
    }

    // --- SỬA ĐỔI: Autocomplete cho ô địa chỉ điểm tập kết ---
    function setupAutocomplete(inputId, mapId, markerVarName) {
        let debounceTimer;
        const input = document.getElementById(inputId);
        const listId = inputId === 'itemAddress' ? 'suggestionList' : 'pointSuggestionList';
        const list = document.getElementById(listId);

        input.addEventListener('input', function() {
            clearTimeout(debounceTimer);
            const query = this.value.trim();

            if (query.length < 3) {
                list.classList.add('hidden');
                return;
            }

            debounceTimer = setTimeout(async () => {
                try {
                    const url = 'https://api.maptiler.com/geocoding/' + encodeURIComponent(query) + '.json?key=' + MAPTILER_API_KEY + '&autocomplete=true&limit=5';
                    const response = await fetch(url);
                    const data = await response.json();

                    list.innerHTML = '';
                    if (data.features && data.features.length > 0) {
                        data.features.forEach(feature => {
                            const li = document.createElement('li');
                            li.className = 'px-4 py-2 hover:bg-slate-100 cursor-pointer text-sm text-slate-700 border-b border-slate-100 last:border-0';
                            li.innerText = feature.place_name;
                            li.onclick = () => {
                                input.value = feature.place_name;
                                const [lng, lat] = feature.center;

                                if (markerVarName === 'locationMarker') {
                                    currentLatLng = { lat, lng };
                                    miniMap.setView([lat, lng], 15);
                                    locationMarker.setLatLng([lat, lng]);
                                } else if (markerVarName === 'pointMarker') {
                                    pointLatLng = { lat, lng };
                                    pointMap.setView([lat, lng], 15);
                                    pointMarker.setLatLng([lat, lng]);
                                }

                                list.classList.add('hidden');
                            };
                            list.appendChild(li);
                        });
                        list.classList.remove('hidden');
                    } else {
                        list.classList.add('hidden');
                    }
                } catch (e) { console.error(e); }
            }, 300);
        });
    }

    // Gọi setup cho cả 2 ô input
    setupAutocomplete('itemAddress', 'miniMap', 'locationMarker');
    setupAutocomplete('pointAddress', 'pointMiniMap', 'pointMarker');

    async function submitItem() {
        const fd = new FormData();
        fd.append("title", document.getElementById('itemName').value);
        fd.append("description", document.getElementById('itemDescription').value);
        fd.append("category", document.getElementById('itemCategory').value);
        fd.append("ecoPoints", document.getElementById('itemEcoPoints').value);
        fd.append("itemPhoto", document.getElementById('itemPhoto').files[0]);
        fd.append("latitude", currentLatLng.lat);
        fd.append("longitude", currentLatLng.lng);
        fd.append("address", document.getElementById('itemAddress').value);

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

    // --- LEADERBOARD LOGIC ---
    function toggleLeaderboardModal() {
        const modal = document.getElementById('leaderboardModal');
        modal.classList.toggle('hidden');
        if (!modal.classList.contains('hidden')) {
            loadLeaderboard();
        }
    }

    async function loadLeaderboard() {
        const listEl = document.getElementById('leaderboardList');
        listEl.innerHTML = '<div class="text-center text-slate-500 py-4">Đang tải dữ liệu...</div>';

        try {
            const res = await fetch('${pageContext.request.contextPath}/api/leaderboard');
            const users = await res.json();

            listEl.innerHTML = '';
            if (users.length === 0) {
                listEl.innerHTML = '<div class="text-center text-slate-500 py-4">Chưa có dữ liệu</div>';
                return;
            }

            users.forEach((u, index) => {
                let rankClass = "bg-slate-100 text-slate-600";
                let rankIcon = "";

                if (index === 0) {
                    rankClass = "bg-yellow-100 text-yellow-700 border border-yellow-200";
                    rankIcon = "👑";
                } else if (index === 1) {
                    rankClass = "bg-slate-200 text-slate-700 border border-slate-300";
                    rankIcon = "🥈";
                } else if (index === 2) {
                    rankClass = "bg-orange-100 text-orange-800 border border-orange-200";
                    rankIcon = "🥉";
                }

                listEl.innerHTML += `
                    <div class="flex items-center gap-3 p-3 mb-2 rounded-xl \${rankClass} transition hover:scale-[1.02]">
                        <div class="font-bold text-lg w-8 text-center">\${rankIcon || (index + 1)}</div>
                        <div class="w-10 h-10 rounded-full bg-white p-0.5 shadow-sm overflow-hidden shrink-0">
                            <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=\${u.username}" class="w-full h-full rounded-full">
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="font-bold text-sm truncate">\${u.username}</div>
                            <div class="text-[10px] opacity-80">Reputation: \${u.reputationScore}</div>
                        </div>
                        <div class="font-bold text-primary flex items-center gap-1 bg-white px-2 py-1 rounded-lg shadow-sm">
                            <span class="material-symbols-outlined text-sm">eco</span>
                            \${u.ecoPoints}
                        </div>
                    </div>
                `;
            });
        } catch (e) {
            listEl.innerHTML = '<div class="text-center text-red-500 py-4">Lỗi tải bảng xếp hạng</div>';
        }
    }

    // --- NEW: ALL ITEMS & POINTS LIST LOGIC (INFINITE SCROLL) ---
    function calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 6371; // km
        const dLat = (lat2 - lat1) * Math.PI / 180;
        const dLon = (lon2 - lon1) * Math.PI / 180;
        const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                  Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                  Math.sin(dLon/2) * Math.sin(dLon/2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c;
    }

    function formatDistance(d) {
        if (d < 1) return Math.round(d * 1000) + " m";
        return d.toFixed(1) + " km";
    }

    async function openAllItemsList() {
        document.getElementById('allItemsModal').classList.remove('hidden');
        const listEl = document.getElementById('allItemsList');
        listEl.innerHTML = ''; // Clear old data
        currentPageItems = 1;
        hasMoreItems = true;
        loadMoreItems();
    }

    async function loadMoreItems() {
        if (isLoadingItems || !hasMoreItems) return;
        isLoadingItems = true;

        const listEl = document.getElementById('allItemsList');
        const loadingDiv = document.createElement('div');
        loadingDiv.className = 'text-center text-slate-500 py-4 text-xs';
        loadingDiv.innerText = 'Đang tải thêm...';
        listEl.appendChild(loadingDiv);

        try {
            const categoryId = document.getElementById('filterItemCategory').value; // NEW

            const params = new URLSearchParams({
                lat: currentLatLng.lat,
                lng: currentLatLng.lng,
                page: currentPageItems,
                limit: ITEMS_PER_PAGE
            });

            if (categoryId) params.append('categoryId', categoryId); // NEW

            const res = await fetch('${pageContext.request.contextPath}/api/items?' + params.toString());
            const items = await res.json();

            loadingDiv.remove();

            if (items.length < ITEMS_PER_PAGE) {
                hasMoreItems = false;
            }

            if (items.length === 0 && currentPageItems === 1) {
                listEl.innerHTML = '<div class="text-center text-slate-500 py-8">Không có vật phẩm nào phù hợp.</div>';
                return;
            }

            items.forEach(item => {
                let imgUrl = item.imageUrl && item.imageUrl.startsWith('http') ? item.imageUrl : (item.imageUrl ? '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(item.imageUrl) : 'https://placehold.co/100x100');

                // Calculate distance client-side for display (backend already sorted)
                const dist = calculateDistance(currentLatLng.lat, currentLatLng.lng, item.location.latitude, item.location.longitude);
                const distStr = formatDistance(dist);

                const itemHtml = `
                    <div class="flex gap-3 p-3 bg-white rounded-xl border border-slate-100 hover:shadow-md transition cursor-pointer group" onclick="flyToLocation(\${item.location.latitude}, \${item.location.longitude}, '\${item.title}'); document.getElementById('allItemsModal').classList.add('hidden');">
                        <div class="w-20 h-20 rounded-lg bg-slate-100 overflow-hidden shrink-0">
                            <img src="\${imgUrl}" class="w-full h-full object-cover group-hover:scale-110 transition duration-500">
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex justify-between items-start">
                                <h4 class="font-bold text-slate-800 text-sm truncate mb-1 group-hover:text-primary transition">\${item.title}</h4>
                                <span class="text-[10px] font-bold text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded whitespace-nowrap">\${distStr}</span>
                            </div>
                            <div class="text-xs text-slate-500 mb-2 flex items-center gap-1">
                                <span class="material-symbols-outlined text-[14px]">person</span> \${item.giverName}
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="bg-emerald-50 text-primary text-[10px] font-bold px-2 py-1 rounded border border-emerald-100">\${item.ecoPoints} pts</span>
                                <span class="text-[10px] text-slate-400 truncate">\${item.address || 'Chưa có địa chỉ'}</span>
                            </div>
                        </div>
                    </div>
                `;
                listEl.insertAdjacentHTML('beforeend', itemHtml);
            });

            currentPageItems++;
        } catch (e) {
            loadingDiv.remove();
            console.error(e);
        } finally {
            isLoadingItems = false;
        }
    }

    async function openAllPointsList() {
        document.getElementById('allPointsModal').classList.remove('hidden');
        const listEl = document.getElementById('allPointsList');
        listEl.innerHTML = '';
        currentPagePoints = 1;
        hasMorePoints = true;
        loadMorePoints();
    }

    async function loadMorePoints() {
        if (isLoadingPoints || !hasMorePoints) return;
        isLoadingPoints = true;

        const listEl = document.getElementById('allPointsList');
        const loadingDiv = document.createElement('div');
        loadingDiv.className = 'text-center text-slate-500 py-4 text-xs';
        loadingDiv.innerText = 'Đang tải thêm...';
        listEl.appendChild(loadingDiv);

        try {
            const typeCode = document.getElementById('filterPointType').value; // NEW
            const ownerRole = document.getElementById('filterPointOwner').value; // NEW

            const params = new URLSearchParams({
                lat: currentLatLng.lat,
                lng: currentLatLng.lng,
                page: currentPagePoints,
                limit: ITEMS_PER_PAGE
            });

            if (typeCode) params.append('type', typeCode); // NEW
            if (ownerRole) params.append('ownerRole', ownerRole); // NEW

            const res = await fetch('${pageContext.request.contextPath}/api/collection-points?' + params.toString());
            const points = await res.json();

            loadingDiv.remove();

            if (points.length < ITEMS_PER_PAGE) {
                hasMorePoints = false;
            }

            if (points.length === 0 && currentPagePoints === 1) {
                listEl.innerHTML = '<div class="text-center text-slate-500 py-8">Không có điểm tập kết nào phù hợp.</div>';
                return;
            }

            points.forEach(p => {
                let typeBadge = '';
                if (p.ownerRole === 'COLLECTOR_COMPANY') {
                    typeBadge = '<span class="bg-yellow-50 text-yellow-700 text-[10px] font-bold px-2 py-1 rounded border border-yellow-100">Doanh nghiệp</span>';
                } else {
                    typeBadge = '<span class="bg-green-50 text-green-700 text-[10px] font-bold px-2 py-1 rounded border border-green-100">Công cộng</span>';
                }

                const dist = calculateDistance(currentLatLng.lat, currentLatLng.lng, p.latitude, p.longitude);
                const distStr = formatDistance(dist);

                const pointHtml = `
                    <div class="p-4 bg-white rounded-xl border border-slate-100 hover:shadow-md transition cursor-pointer group" onclick="flyToLocation(\${p.latitude}, \${p.longitude}, '\${p.name}'); document.getElementById('allPointsModal').classList.add('hidden');">
                        <div class="flex justify-between items-start mb-2">
                            <h4 class="font-bold text-slate-800 text-sm group-hover:text-primary transition">\${p.name}</h4>
                            <div class="flex flex-col items-end gap-1">
                                \${typeBadge}
                                <span class="text-[10px] font-bold text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded">\${distStr}</span>
                            </div>
                        </div>
                        <div class="text-xs text-slate-500 flex items-start gap-1.5">
                            <span class="material-symbols-outlined text-[14px] mt-0.5">location_on</span>
                            <span>\${p.address}</span>
                        </div>
                    </div>
                `;
                listEl.insertAdjacentHTML('beforeend', pointHtml);
            });

            currentPagePoints++;
        } catch (e) {
            loadingDiv.remove();
            console.error(e);
        } finally {
            isLoadingPoints = false;
        }
    }

    function filterList(inputId, listId) {
        const filter = document.getElementById(inputId).value.toUpperCase();
        const list = document.getElementById(listId);
        // Note: This simple filter only works on currently loaded items.
        // For full search, we would need a backend search API.
        // But for UX, filtering loaded items is acceptable for now.
        for (let i = 0; i < list.children.length; i++) {
            const item = list.children[i];
            if (item.tagName === 'DIV') { // Skip loading text if any
                const txtValue = item.textContent || item.innerText;
                if (txtValue.toUpperCase().indexOf(filter) > -1) {
                    item.style.display = "";
                } else {
                    item.style.display = "none";
                }
            }
        }
    }
</script>
</body>
</html>