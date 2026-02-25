<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tin nhắn - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

    <!-- Fonts: Plus Jakarta Sans (Modern & Geometric) -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,1,0" />

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'sans-serif'],
                    },
                    colors: {
                        primary: '#05976a',
                        'primary-dark': '#047857',
                        'primary-light': '#34d399',
                        'glass-border': 'rgba(255, 255, 255, 0.5)',
                        'glass-bg': 'rgba(255, 255, 255, 0.7)',
                    },
                    boxShadow: {
                        'glass': '0 8px 32px 0 rgba(31, 38, 135, 0.15)',
                        'glow': '0 0 15px rgba(5, 151, 106, 0.3)',
                    },
                    animation: {
                        'float': 'float 6s ease-in-out infinite',
                        'slide-up': 'slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards',
                        'scale-in': 'scaleIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards',
                    },
                    keyframes: {
                        float: {
                            '0%, 100%': { transform: 'translateY(0)' },
                            '50%': { transform: 'translateY(-20px)' },
                        },
                        slideUp: {
                            '0%': { transform: 'translateY(20px)', opacity: '0' },
                            '100%': { transform: 'translateY(0)', opacity: '1' },
                        },
                        scaleIn: {
                            '0%': { transform: 'scale(0.9)', opacity: '0' },
                            '100%': { transform: 'scale(1)', opacity: '1' },
                        }
                    }
                }
            }
        }
    </script>

    <style>
        /* Custom Scrollbar for Glassmorphism */
        .custom-scrollbar::-webkit-scrollbar { width: 5px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(5, 151, 106, 0.2); border-radius: 10px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(5, 151, 106, 0.5); }

        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

        /* Glassmorphism Utilities */
        .glass-panel {
            background: rgba(255, 255, 255, 0.65);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.5);
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.1);
        }

        .bg-mesh {
            background-color: #e0f2fe;
            background-image:
                radial-gradient(at 0% 0%, hsla(153,96%,45%,1) 0, transparent 50%),
                radial-gradient(at 50% 0%, hsla(180,80%,70%,1) 0, transparent 50%),
                radial-gradient(at 100% 0%, hsla(153,96%,45%,1) 0, transparent 50%);
            background-size: 100% 100%;
        }
    </style>
</head>

<!-- BODY: Vibrant Mesh Gradient Background -->
<body class="h-screen w-screen bg-mesh flex items-center justify-center overflow-hidden p-0 md:p-6 relative">

    <!-- Decorative Blobs (Background Elements) -->
    <div class="absolute top-10 left-10 w-72 h-72 bg-primary/30 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float"></div>
    <div class="absolute bottom-10 right-10 w-72 h-72 bg-blue-400/30 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float" style="animation-delay: 2s"></div>
    <div class="absolute bottom-1/2 left-1/2 w-96 h-96 bg-yellow-200/40 rounded-full mix-blend-multiply filter blur-3xl opacity-60 animate-float" style="animation-delay: 4s"></div>

    <!-- MAIN CONTAINER: Glass Card -->
    <div class="w-full h-full md:w-[90%] md:h-[90%] lg:w-[85%] lg:h-[85%] glass-card md:rounded-[2rem] shadow-glass flex flex-col overflow-hidden relative z-10 transition-all duration-500">

        <!-- HEADER: Transparent & Minimal -->
        <header class="h-16 px-6 flex justify-between items-center shrink-0 border-b border-white/50 bg-white/40 backdrop-blur-sm">
            <div class="flex items-center gap-3">
                <a href="${pageContext.request.contextPath}/home" class="group flex items-center gap-2 transition-transform hover:scale-105">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-emerald-400 flex items-center justify-center text-white shadow-glow">
                        <span class="material-symbols-rounded text-[24px]">spa</span>
                    </div>
                    <div>
                        <h1 class="text-lg font-extrabold tracking-tight text-slate-800 leading-none">EcoGive</h1>
                        <span class="text-[10px] font-bold text-primary uppercase tracking-widest">Messenger</span>
                    </div>
                </a>
            </div>

            <div class="flex items-center gap-4">
                <a href="${pageContext.request.contextPath}/home" class="hidden md:flex items-center gap-2 px-4 py-2 rounded-full bg-white/50 hover:bg-white text-sm font-bold text-slate-600 hover:text-primary transition-all shadow-sm border border-white/60">
                    <span class="material-symbols-rounded text-[18px]">home</span>
                    <span>Trang chủ</span>
                </a>
                <div class="flex items-center gap-3 pl-4 border-l border-slate-300/50">
                    <div class="text-right hidden md:block">
                        <div class="text-sm font-bold text-slate-800">${sessionScope.currentUser.username}</div>
                        <div class="text-[10px] font-semibold text-primary">Online</div>
                    </div>
                    <div class="relative">
                        <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=${sessionScope.currentUser.username}"
                             class="w-10 h-10 rounded-full border-2 border-white shadow-md bg-white">
                        <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></span>
                    </div>
                </div>
            </div>
        </header>

        <!-- CONTENT AREA -->
        <div class="flex-1 flex overflow-hidden relative">

            <!-- LEFT COLUMN: INBOX LIST (Glassy Sidebar) -->
            <div id="inboxPanel" class="w-full md:w-80 lg:w-96 bg-white/40 backdrop-blur-md border-r border-white/50 flex flex-col h-full z-20 absolute md:static transition-transform duration-300 transform translate-x-0">
                <div class="p-5 pb-2">
                    <h2 class="font-bold text-slate-800 text-xl mb-4 flex items-center gap-2">
                        Tin nhắn <span class="bg-primary/10 text-primary text-xs px-2 py-1 rounded-full" id="msgCount">0</span>
                    </h2>
                    <!-- Search Input with Glass Effect -->
                    <div class="relative group">
                        <span class="absolute left-3 top-3 text-slate-400 material-symbols-rounded text-[20px] group-focus-within:text-primary transition-colors">search</span>
                        <input type="text" id="searchInput" oninput="searchFriends()" placeholder="Tìm kiếm bạn bè..." class="w-full pl-10 pr-4 py-2.5 bg-white/60 border border-white/50 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-primary/50 focus:bg-white transition-all shadow-sm placeholder-slate-400">
                    </div>
                </div>

                <div id="inboxList" class="flex-1 overflow-y-auto custom-scrollbar p-3 space-y-2">
                    <!-- Inbox items loaded via JS -->
                    <div class="flex flex-col items-center justify-center h-40 text-slate-400 animate-pulse">
                        <span class="material-symbols-rounded text-4xl mb-2">mark_chat_unread</span>
                        <span class="text-xs font-medium">Đang tải hộp thư...</span>
                    </div>
                </div>
            </div>

            <!-- RIGHT COLUMN: CHAT DETAIL -->
            <div id="chatDetailPanel" class="flex-1 flex flex-col bg-white/30 backdrop-blur-sm h-full w-full absolute md:static z-30 md:z-0 transform translate-x-full md:translate-x-0 transition-transform duration-300">

                <!-- Chat Header -->
                <div class="h-16 px-6 border-b border-white/50 bg-white/60 backdrop-blur-md flex justify-between items-center shrink-0 shadow-sm z-10">
                    <div class="flex items-center gap-4 overflow-hidden">
                        <button onclick="backToInbox()" class="md:hidden w-8 h-8 flex items-center justify-center rounded-full bg-white text-slate-600 shadow-sm hover:text-primary transition">
                            <span class="material-symbols-rounded">arrow_back</span>
                        </button>

                        <div class="relative shrink-0">
                            <div class="w-10 h-10 rounded-full bg-gradient-to-tr from-slate-200 to-slate-100 flex items-center justify-center text-slate-400 font-bold text-lg border-2 border-white shadow-sm overflow-hidden" id="chatHeaderAvatar">
                                <span class="material-symbols-rounded">person</span>
                            </div>
                        </div>

                        <div class="min-w-0 flex-1">
                            <div id="chatTitle" class="font-bold text-slate-800 text-base truncate">Chọn hội thoại</div>

                            <!-- Item Context (Dropdown or Single) -->
                            <div id="chatItemContext" class="hidden mt-0.5">
                                <!-- Single Item -->
                                <div id="singleItemInfo" class="hidden flex items-center gap-2 animate-scale-in">
                                    <span class="bg-primary/10 text-primary text-[10px] font-bold px-2 py-0.5 rounded-full border border-primary/20 flex items-center gap-1">
                                        <span class="material-symbols-rounded text-[12px]">inventory_2</span>
                                        <span id="chatItemName" class="truncate max-w-[150px]">...</span>
                                    </span>
                                </div>

                                <!-- Multiple Items Dropdown -->
                                <div id="multiItemDropdown" class="hidden relative group">
                                    <button class="flex items-center gap-1 bg-yellow-50 text-yellow-700 text-[10px] font-bold px-2 py-0.5 rounded-full border border-yellow-200 hover:bg-yellow-100 transition">
                                        <span class="material-symbols-rounded text-[12px]">layers</span>
                                        <span id="multiItemCount">2 giao dịch</span>
                                        <span class="material-symbols-rounded text-[12px]">expand_more</span>
                                    </button>
                                    <!-- Dropdown Content -->
                                    <div id="dealList" class="absolute top-full left-0 mt-1 w-48 bg-white rounded-xl shadow-xl border border-slate-100 hidden group-hover:block z-50 overflow-hidden">
                                        <!-- Items will be injected here -->
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="flex items-center gap-2 shrink-0">
                        <!-- Action Buttons -->
                        <button id="btnGiverConfirm" onclick="confirmTransaction('giver_confirm')" class="hidden group bg-gradient-to-r from-primary to-emerald-500 text-white text-xs font-bold px-4 py-2 rounded-full hover:shadow-lg hover:shadow-emerald-200/50 transform hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-1.5">
                            <span class="material-symbols-rounded text-[16px] group-hover:animate-bounce">card_giftcard</span>
                            <span class="hidden sm:inline">Xác nhận cho</span><span class="sm:hidden">Cho</span>
                        </button>
                        <button id="btnReceiverConfirm" onclick="confirmTransaction('receiver_confirm')" class="hidden group bg-gradient-to-r from-blue-500 to-indigo-500 text-white text-xs font-bold px-4 py-2 rounded-full hover:shadow-lg hover:shadow-blue-200/50 transform hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-1.5">
                            <span class="material-symbols-rounded text-[16px] group-hover:animate-bounce">check_circle</span>
                            <span class="hidden sm:inline">Đã nhận được</span><span class="sm:hidden">Đã nhận</span>
                        </button>

                        <!-- Nút Hủy Giao Dịch -->
                        <button id="btnCancelTrans" onclick="confirmTransaction('cancel')" class="hidden group bg-white text-red-500 text-xs font-bold px-3 py-2 rounded-full border border-red-200 hover:bg-red-50 hover:shadow-md transition-all duration-300 flex items-center gap-1.5" title="Hủy giao dịch">
                            <span class="material-symbols-rounded text-[16px]">cancel</span>
                            <span class="hidden sm:inline">Hủy</span>
                        </button>

                        <!-- Nút Xin Lại (Mới) -->
                        <button id="btnRequestAgain" onclick="reRequestItem()" class="hidden group bg-gradient-to-r from-primary to-emerald-500 text-white text-xs font-bold px-4 py-2 rounded-full hover:shadow-lg hover:shadow-emerald-200/50 transform hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-1.5">
                            <span class="material-symbols-rounded text-[16px]">volunteer_activism</span>
                            <span class="hidden sm:inline">Xin món này</span><span class="sm:hidden">Xin lại</span>
                        </button>

                        <!-- Nút Batch Confirm (Mới - Màu Vàng) -->
                        <button id="btnBatchAction" onclick="openBatchModal()" class="hidden group bg-yellow-400 text-white text-xs font-bold px-4 py-2 rounded-full hover:bg-yellow-500 hover:shadow-lg hover:shadow-yellow-200/50 transform hover:-translate-y-0.5 transition-all duration-300 flex items-center gap-1.5">
                            <span class="material-symbols-rounded text-[16px]">checklist</span>
                            <span class="hidden sm:inline" id="btnBatchLabel">N giao dịch</span>
                        </button>

                        <!-- Nút Info (Đã đổi thành showUserProfile) -->
                        <button onclick="showUserProfile()" class="w-9 h-9 rounded-full bg-white text-slate-400 hover:text-primary hover:bg-emerald-50 transition flex items-center justify-center shadow-sm border border-slate-100" title="Thông tin người dùng">
                            <span class="material-symbols-rounded text-[20px]">info</span>
                        </button>
                    </div>
                </div>

                <!-- Messages Area -->
                <div id="chatMessages" class="flex-1 p-4 md:p-6 overflow-y-auto space-y-4 custom-scrollbar scroll-smooth relative">
                    <!-- Empty State -->
                    <div class="absolute inset-0 flex flex-col items-center justify-center text-slate-400 gap-4 opacity-40 pointer-events-none">
                        <div class="w-32 h-32 bg-gradient-to-br from-slate-100 to-white rounded-full flex items-center justify-center shadow-inner">
                            <span class="material-symbols-rounded text-6xl text-slate-300">forum</span>
                        </div>
                        <p class="text-sm font-semibold tracking-wide">Bắt đầu cuộc trò chuyện ý nghĩa</p>
                    </div>
                </div>

                <!-- Quick Replies (Floating Pills) -->
                <div id="quickReplies" class="px-6 py-3 flex gap-2 overflow-x-auto hidden no-scrollbar shrink-0 mask-linear-fade">
                    <button id="qrGiver" onclick="confirmTransaction('giver_confirm')"
                            class="hidden whitespace-nowrap bg-emerald-100/80 hover:bg-emerald-200 text-emerald-800 text-xs font-bold px-4 py-2 rounded-full border border-emerald-200 transition shadow-sm backdrop-blur-sm">
                        🎁 Xác nhận cho
                    </button>
                    <button id="qrReceiver1" onclick="confirmTransaction('receiver_confirm')"
                            class="hidden whitespace-nowrap bg-blue-100/80 hover:bg-blue-200 text-blue-800 text-xs font-bold px-4 py-2 rounded-full border border-blue-200 transition shadow-sm backdrop-blur-sm">
                        ✅ Đã nhận được
                    </button>
                    <button id="qrReceiver2" onclick="sendQuickReply('Bạn ơi, khi nào mình có thể qua lấy đồ được ạ?')"
                            class="hidden whitespace-nowrap bg-white/80 hover:bg-white text-slate-700 text-xs font-bold px-4 py-2 rounded-full border border-white/60 transition shadow-sm backdrop-blur-sm hover:text-primary">
                        🕒 Hẹn lịch nhận
                    </button>
                    <button onclick="sendQuickReply('Cảm ơn bạn nhiều nhé! ❤️')"
                            class="whitespace-nowrap bg-white/80 hover:bg-white text-slate-700 text-xs font-bold px-4 py-2 rounded-full border border-white/60 transition shadow-sm backdrop-blur-sm hover:text-red-500">
                        ❤️ Cảm ơn
                    </button>
                    <button onclick="sendQuickReply('Mình đang đến nơi rồi ạ.')"
                            class="whitespace-nowrap bg-white/80 hover:bg-white text-slate-700 text-xs font-bold px-4 py-2 rounded-full border border-white/60 transition shadow-sm backdrop-blur-sm hover:text-blue-600">
                        🛵 Đang đến
                    </button>
                </div>

                <!-- Input Area -->
                <div class="p-4 md:p-5 border-t border-white/50 bg-white/60 backdrop-blur-md flex gap-3 shrink-0 pb-safe rounded-b-[2rem]">
                    <button onclick="document.getElementById('imageInput').click()" class="w-10 h-10 rounded-full bg-white text-slate-400 hover:text-primary hover:bg-emerald-50 transition flex items-center justify-center shadow-sm border border-slate-100 hidden sm:flex">
                        <span class="material-symbols-rounded">add_photo_alternate</span>
                    </button>
                    <div class="flex-1 relative group">
                        <input type="text" id="chatInput" disabled
                               class="w-full border border-white/60 rounded-full pl-5 pr-12 py-3 text-sm bg-white/80 focus:bg-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all shadow-inner placeholder-slate-400"
                               placeholder="Nhập tin nhắn...">
                        <button onclick="sendMessage()" id="btnSend" disabled
                                class="absolute right-1.5 top-1.5 w-9 h-9 rounded-full bg-gradient-to-r from-primary to-emerald-500 text-white flex items-center justify-center shadow-md hover:shadow-lg hover:scale-105 transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100">
                            <span class="material-symbols-rounded text-[20px]">send</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden File Input -->
    <input type="file" id="imageInput" hidden accept="image/*" onchange="uploadImage()">

    <!-- Batch Confirm Modal -->
    <div id="batchConfirmModal" class="fixed inset-0 hidden bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-[80]">
        <div class="bg-white/95 backdrop-blur-xl p-6 rounded-3xl w-full max-w-md shadow-2xl border border-white/50 relative animate-scale-in">
            <h2 class="text-xl font-extrabold text-slate-800 mb-4 flex items-center gap-2">
                <span class="material-symbols-rounded text-yellow-500">checklist</span>
                Xác nhận nhận đồ
            </h2>
            <p class="text-sm text-slate-500 mb-4">Chọn các món đồ bạn đã nhận được từ người tặng:</p>

            <div id="batchList" class="max-h-60 overflow-y-auto custom-scrollbar space-y-2 mb-6">
                <!-- Items will be injected here -->
            </div>

            <div class="flex gap-3">
                <button onclick="document.getElementById('batchConfirmModal').classList.add('hidden')" class="flex-1 bg-slate-100 text-slate-600 py-3 rounded-xl font-bold hover:bg-slate-200 transition">Đóng</button>
                <button onclick="submitBatchConfirm()" class="flex-1 bg-gradient-to-r from-primary to-emerald-500 text-white py-3 rounded-xl font-bold hover:shadow-lg transition">Xác nhận</button>
            </div>
        </div>
    </div>

    <!-- Item Info Modal -->
    <div id="itemInfoModal" class="fixed inset-0 hidden bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-[90]">
        <div class="bg-white/95 backdrop-blur-xl rounded-3xl w-full max-w-md shadow-2xl border border-white/50 relative animate-scale-in overflow-hidden flex flex-col max-h-[85vh]">
            <!-- Header Image -->
            <div class="h-48 bg-slate-100 relative shrink-0">
                <img id="infoImg" src="" class="w-full h-full object-cover">
                <button onclick="document.getElementById('itemInfoModal').classList.add('hidden')" class="absolute top-4 right-4 bg-black/30 hover:bg-black/50 text-white p-2 rounded-full backdrop-blur transition">
                    <span class="material-symbols-rounded text-xl">close</span>
                </button>
                <div class="absolute bottom-4 left-4 bg-white/90 backdrop-blur px-3 py-1 rounded-full text-xs font-bold text-primary shadow-sm flex items-center gap-1">
                    <span class="material-symbols-rounded text-sm">eco</span>
                    <span id="infoPoints">0</span> EcoPoints
                </div>
            </div>

            <!-- Content -->
            <div class="p-6 overflow-y-auto custom-scrollbar">
                <h2 id="infoTitle" class="text-xl font-extrabold text-slate-800 mb-2 leading-tight">Tên sản phẩm</h2>

                <div class="flex items-center gap-2 mb-4 text-xs font-bold text-slate-500">
                    <span class="bg-slate-100 px-2 py-1 rounded border border-slate-200" id="infoCategory">Danh mục</span>
                    <span class="bg-emerald-50 text-emerald-700 px-2 py-1 rounded border border-emerald-100 flex items-center gap-1">
                        <span class="material-symbols-rounded text-sm">person</span> <span id="infoGiver">Người tặng</span>
                    </span>
                </div>

                <div class="space-y-4">
                    <div>
                        <h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Mô tả</h4>
                        <p id="infoDesc" class="text-sm text-slate-600 leading-relaxed">...</p>
                    </div>
                    <div>
                        <h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Địa chỉ nhận</h4>
                        <div class="flex items-start gap-2 text-sm text-slate-700 bg-slate-50 p-3 rounded-xl border border-slate-100">
                            <span class="material-symbols-rounded text-slate-400 mt-0.5">location_on</span>
                            <span id="infoAddress">...</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="p-4 border-t border-slate-100 bg-slate-50/50 shrink-0">
                <button onclick="document.getElementById('itemInfoModal').classList.add('hidden')" class="w-full bg-slate-200 text-slate-700 font-bold py-3 rounded-xl hover:bg-slate-300 transition">Đóng</button>
            </div>
        </div>
    </div>

    <!-- User Profile Modal (MỚI) -->
    <div id="userProfileModal" class="fixed inset-0 hidden bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-[90]">
        <div class="bg-white/95 backdrop-blur-xl rounded-3xl w-full max-w-sm shadow-2xl border border-white/50 relative animate-scale-in overflow-hidden">
            <button onclick="document.getElementById('userProfileModal').classList.add('hidden')" class="absolute top-4 right-4 text-slate-400 hover:text-slate-600 p-2 rounded-full hover:bg-slate-100 transition z-10">
                <span class="material-symbols-rounded text-xl">close</span>
            </button>

            <div class="p-8 flex flex-col items-center text-center">
                <div class="w-24 h-24 rounded-full bg-slate-100 p-1 shadow-lg mb-4 relative">
                    <img id="profileAvatar" src="" class="w-full h-full rounded-full object-cover bg-white">
                    <div class="absolute bottom-1 right-1 bg-green-500 w-5 h-5 rounded-full border-4 border-white"></div>
                </div>

                <h2 id="profileName" class="text-2xl font-extrabold text-slate-800 mb-1">Username</h2>
                <p id="profileEmail" class="text-sm text-slate-500 mb-6">email@example.com</p>

                <div class="grid grid-cols-2 gap-4 w-full mb-6">
                    <div class="bg-emerald-50 p-3 rounded-2xl border border-emerald-100">
                        <div class="text-xs font-bold text-emerald-600 uppercase mb-1">EcoPoints</div>
                        <div class="text-xl font-extrabold text-emerald-700 flex items-center justify-center gap-1">
                            <span class="material-symbols-rounded text-lg">eco</span>
                            <span id="profilePoints">0</span>
                        </div>
                    </div>
                    <div class="bg-blue-50 p-3 rounded-2xl border border-blue-100">
                        <div class="text-xs font-bold text-blue-600 uppercase mb-1">Uy tín</div>
                        <div class="text-xl font-extrabold text-blue-700 flex items-center justify-center gap-1">
                            <span class="material-symbols-rounded text-lg">star</span>
                            <span id="profileReputation">0.0</span>
                        </div>
                    </div>
                </div>

                <div class="w-full space-y-3 text-left">
                    <div class="flex items-center gap-3 text-sm text-slate-600 bg-slate-50 p-3 rounded-xl border border-slate-100">
                        <span class="material-symbols-rounded text-slate-400">volunteer_activism</span>
                        <span>Đã tặng: <b id="profileGivenCount">0</b> món quà</span>
                    </div>
                    <div class="flex items-center gap-3 text-sm text-slate-600 bg-slate-50 p-3 rounded-xl border border-slate-100">
                        <span class="material-symbols-rounded text-slate-400">calendar_month</span>
                        <span>Tham gia: <span id="profileJoinDate">...</span></span>
                    </div>
                </div>

                <a id="profileLink" href="#" class="mt-6 w-full bg-slate-800 text-white font-bold py-3 rounded-xl hover:bg-slate-900 transition shadow-lg">Xem trang cá nhân</a>
            </div>
        </div>
    </div>

    <!-- Rating Modal -->
    <div id="ratingModal" class="fixed inset-0 hidden bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4 z-[70]">
        <div class="bg-white/90 backdrop-blur-xl p-8 rounded-3xl w-full max-w-sm shadow-2xl border border-white/50 relative animate-scale-in">
            <div class="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4 shadow-inner">
                <span class="text-3xl">⭐</span>
            </div>
            <h2 class="text-xl font-extrabold text-slate-800 text-center mb-2">Đánh giá trải nghiệm</h2>
            <p class="text-sm text-slate-500 text-center mb-6 font-medium">Hãy chia sẻ cảm nhận của bạn về người tặng nhé!</p>

            <div class="mb-4">
                <label class="block text-xs font-bold text-slate-700 uppercase mb-2 tracking-wider">Mức độ hài lòng</label>
                <div class="relative">
                    <select id="ratingValue" class="w-full p-3 pl-4 border border-slate-200 rounded-xl bg-white text-slate-700 font-bold focus:ring-2 focus:ring-yellow-400 outline-none appearance-none shadow-sm">
                        <option value="5">⭐⭐⭐⭐⭐ (Tuyệt vời)</option>
                        <option value="4">⭐⭐⭐⭐ (Tốt)</option>
                        <option value="3">⭐⭐⭐ (Bình thường)</option>
                        <option value="2">⭐⭐ (Tệ)</option>
                        <option value="1">⭐ (Rất tệ)</option>
                    </select>
                    <span class="absolute right-4 top-3.5 pointer-events-none text-slate-400 material-symbols-rounded">expand_more</span>
                </div>
            </div>

            <div class="mb-6">
                <label class="block text-xs font-bold text-slate-700 uppercase mb-2 tracking-wider">Lời nhắn</label>
                <textarea id="ratingComment" rows="3" class="w-full p-3 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-primary outline-none resize-none bg-white shadow-inner" placeholder="Viết lời cảm ơn..."></textarea>
            </div>

            <div class="flex gap-3">
                <button onclick="document.getElementById('ratingModal').classList.add('hidden')" class="flex-1 bg-slate-100 text-slate-600 py-3 rounded-xl font-bold hover:bg-slate-200 transition">Hủy</button>
                <button onclick="submitRating()" class="flex-1 bg-gradient-to-r from-primary to-emerald-500 text-white py-3 rounded-xl font-bold hover:shadow-lg hover:shadow-emerald-200/50 transition transform hover:-translate-y-0.5">Gửi đánh giá</button>
            </div>
        </div>
    </div>

    <!-- Lightbox Modal -->
    <div id="lightboxModal" class="fixed inset-0 hidden bg-black/90 backdrop-blur-md z-[100] flex items-center justify-center p-4" onclick="this.classList.add('hidden')">
        <img id="lightboxImg" src="" class="max-w-full max-h-full rounded-lg shadow-2xl animate-scale-in object-contain">
        <button class="absolute top-4 right-4 text-white/70 hover:text-white p-2 rounded-full bg-black/20 hover:bg-black/40 transition">
            <span class="material-symbols-rounded text-3xl">close</span>
        </button>
    </div>

    <!-- JAVASCRIPT LOGIC -->
    <script>
        // --- KHỞI TẠO ---
        const currentUserId = ${sessionScope.currentUser.userId};
        const currentUserName = "${sessionScope.currentUser.username}";
        let chatSocket = null;
        let currentReceiverId = null;
        let currentDiscussingItemId = null;
        let isOwnerOfCurrentItem = false;
        let allInboxUsers = [];
        let activeDeals = []; // Danh sách các giao dịch đang hoạt động

        const urlParams = new URLSearchParams(window.location.search);
        const paramPartnerId = urlParams.get('partnerId');
        const paramItemId = urlParams.get('itemId');

        document.addEventListener("DOMContentLoaded", function() {
            connectWebSocket();
            loadInboxList();
        });

        // --- WEBSOCKET ---
        function connectWebSocket() {
            if (chatSocket && chatSocket.readyState === WebSocket.OPEN) return;
            const wsUrl = (window.location.protocol === 'https:' ? 'wss://' : 'ws://') + window.location.host + '${pageContext.request.contextPath}/chat/' + currentUserId;
            chatSocket = new WebSocket(wsUrl);

            chatSocket.onopen = () => console.log("Connected to Chat WS");

            chatSocket.onmessage = (e) => {
                const data = JSON.parse(e.data);
                if (data.content && data.content.startsWith("SYSTEM_GIFT:")) {
                    const msgText = data.content.replace("SYSTEM_GIFT:", "");
                    appendSystemMessage(msgText);

                    // Reload để cập nhật trạng thái nút
                    if (currentDiscussingItemId) {
                        loadHistory(currentReceiverId);
                    }
                    loadInboxList();
                    loadActiveDeals(currentReceiverId); // Reload deals
                    return;
                }

                if (data.senderId == currentReceiverId) {
                    appendMessage(data.content, data.imageUrl, 'incoming');
                }
                loadInboxList();
            };

            chatSocket.onclose = () => setTimeout(connectWebSocket, 3000);
        }

        // --- INBOX LOGIC ---
        async function loadInboxList() {
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/chat?action=inbox');
                const users = await res.json();
                allInboxUsers = users;
                renderInboxList(allInboxUsers);

                if (paramPartnerId && !currentReceiverId) {
                    const target = users.find(u => u.userId == paramPartnerId);
                    if (target) {
                        selectUserChat(target.userId, target.username, target.itemId, target.itemName, target.giverId);
                    }
                }
            } catch (e) { console.error(e); }
        }

        function searchFriends() {
            const query = document.getElementById('searchInput').value.toLowerCase();
            const filteredUsers = allInboxUsers.filter(u => u.username.toLowerCase().includes(query));
            renderInboxList(filteredUsers);
        }

        function renderInboxList(users) {
            const listEl = document.getElementById('inboxList');
            listEl.innerHTML = '';
            document.getElementById('msgCount').innerText = users.length;

            if (users.length === 0) {
                listEl.innerHTML = '<div class="flex flex-col items-center justify-center h-40 text-slate-400 gap-2 opacity-60"><span class="material-symbols-rounded text-4xl">search_off</span><span class="text-xs font-medium">Không tìm thấy</span></div>';
                return;
            }

            users.forEach(u => {
                const isActive = (u.userId == currentReceiverId);
                const activeClass = isActive
                    ? 'bg-white shadow-md border-l-4 border-primary transform scale-[1.02]'
                    : 'hover:bg-white/50 border-l-4 border-transparent hover:scale-[1.01]';

                const itemId = u.itemId || '';
                const itemName = u.itemName || '';
                const giverId = u.giverId || '';

                let lastMsg = u.lastMsg || '...';
                if (lastMsg.startsWith("SYSTEM_GIFT:")) lastMsg = "🎁 Thông báo hệ thống";

                listEl.innerHTML += `
                    <div onclick="selectUserChat(\${u.userId}, '\${u.username}', '\${itemId}', '\${itemName}', '\${giverId}')"
                         class="cursor-pointer p-3 rounded-xl transition-all duration-300 mb-2 \${activeClass} group">
                        <div class="flex items-center gap-3">
                            <div class="relative shrink-0">
                                <img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=\${u.username}"
                                     class="w-12 h-12 rounded-full bg-white shadow-sm object-cover border border-white">
                                <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full shadow-sm"></span>
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="flex justify-between items-center mb-0.5">
                                    <div class="font-bold text-sm text-slate-800 truncate group-hover:text-primary transition-colors">\${u.username}</div>
                                    <div class="text-[10px] text-slate-400 font-medium">Vừa xong</div>
                                </div>
                                <div class="text-xs text-slate-500 truncate font-medium opacity-80">\${lastMsg}</div>
                                \${itemName ? `<div class="mt-1.5 inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-slate-100/80 text-[10px] font-bold text-slate-600 max-w-full truncate border border-slate-200/50"><span class="material-symbols-rounded text-[12px] text-primary">inventory_2</span> \${itemName}</div>` : ''}
                            </div>
                        </div>
                    </div>`;
            });
        }

        async function selectUserChat(userId, username, itemId, itemName, giverId) {
            currentReceiverId = userId;
            document.getElementById('chatTitle').innerText = username;
            document.getElementById('chatHeaderAvatar').innerHTML = `<img src="https://api.dicebear.com/9.x/notionists-neutral/svg?seed=\${username}" class="w-full h-full object-cover">`;

            const input = document.getElementById('chatInput');
            input.disabled = false; input.focus();
            document.getElementById('btnSend').disabled = false;

            if (window.innerWidth < 768) {
                document.getElementById('inboxPanel').classList.add('-translate-x-full');
                document.getElementById('chatDetailPanel').classList.remove('translate-x-full');
            }

            document.getElementById('quickReplies').classList.remove('hidden');

            // Reset buttons
            const btnGiver = document.getElementById('btnGiverConfirm');
            const btnReceiver = document.getElementById('btnReceiverConfirm');
            const btnCancel = document.getElementById('btnCancelTrans');
            const btnRequestAgain = document.getElementById('btnRequestAgain');
            const btnBatchAction = document.getElementById('btnBatchAction');

            btnGiver.classList.add('hidden');
            btnReceiver.classList.add('hidden');
            btnCancel.classList.add('hidden');
            btnRequestAgain.classList.add('hidden');
            btnBatchAction.classList.add('hidden');

            const qrGiver = document.getElementById('qrGiver');
            const qrReceiver1 = document.getElementById('qrReceiver1');
            const qrReceiver2 = document.getElementById('qrReceiver2');
            qrGiver.classList.add('hidden');
            qrReceiver1.classList.add('hidden');
            qrReceiver2.classList.add('hidden');

            // Load Active Deals
            await loadActiveDeals(userId);

            // Nếu có paramItemId (từ trang chủ), ưu tiên chọn item đó
            if (paramItemId && activeDeals.some(d => d.itemId == paramItemId)) {
                itemId = paramItemId;
                const deal = activeDeals.find(d => d.itemId == paramItemId);
                itemName = deal.itemName;
                giverId = deal.giverId;
            } else if (activeDeals.length > 0) {
                // Nếu không có param, mặc định chọn deal đầu tiên (mới nhất)
                const deal = activeDeals[0];
                itemId = deal.itemId;
                itemName = deal.itemName;
                giverId = deal.giverId;
            }

            if (itemId && itemId !== 'undefined' && itemId !== 'null') {
                switchItemContext(itemId, itemName, giverId);
            } else {
                document.getElementById('chatItemContext').classList.add('hidden');
                currentDiscussingItemId = null;
            }

            loadHistory(userId);
            searchFriends();
        }

        async function loadActiveDeals(partnerId) {
            try {
                const res = await fetch('${pageContext.request.contextPath}/api/chat?action=active_deals&partnerId=' + partnerId);
                activeDeals = await res.json();

                const contextDiv = document.getElementById('chatItemContext');
                const singleInfo = document.getElementById('singleItemInfo');
                const multiDropdown = document.getElementById('multiItemDropdown');
                const dealList = document.getElementById('dealList');

                if (activeDeals.length === 0) {
                    contextDiv.classList.add('hidden');
                } else if (activeDeals.length === 1) {
                    contextDiv.classList.remove('hidden');
                    singleInfo.classList.remove('hidden');
                    multiDropdown.classList.add('hidden');

                    document.getElementById('chatItemName').innerText = activeDeals[0].itemName;
                } else {
                    contextDiv.classList.remove('hidden');
                    singleInfo.classList.add('hidden');
                    multiDropdown.classList.remove('hidden');

                    document.getElementById('multiItemCount').innerText = activeDeals.length + " giao dịch";

                    dealList.innerHTML = '';
                    activeDeals.forEach(d => {
                        dealList.innerHTML += `
                            <div onclick="switchItemContext(\${d.itemId}, '\${d.itemName}', \${d.giverId})"
                                 class="px-4 py-2 hover:bg-slate-50 cursor-pointer text-xs border-b border-slate-50 last:border-0">
                                <div class="font-bold text-slate-700 truncate">\${d.itemName}</div>
                                <div class="text-[10px] text-slate-500">\${d.status}</div>
                            </div>
                        `;
                    });
                }
            } catch(e) { console.error(e); }
        }

        function switchItemContext(itemId, itemName, giverId) {
            currentDiscussingItemId = itemId;

            // Update UI Text
            if (activeDeals.length <= 1) {
                document.getElementById('chatItemName').innerText = itemName;
            }

            if (giverId && giverId != 'undefined') {
                isOwnerOfCurrentItem = (Number(giverId) === currentUserId);
            } else {
                isOwnerOfCurrentItem = false;
            }

            // Update Quick Replies
            if (isOwnerOfCurrentItem) {
                document.getElementById('qrGiver').classList.remove('hidden');
                document.getElementById('qrReceiver2').classList.add('hidden');
            } else {
                document.getElementById('qrGiver').classList.add('hidden');
                document.getElementById('qrReceiver2').classList.remove('hidden');
            }

            // Reload history to update buttons based on this item's status
            loadHistory(currentReceiverId);
        }

        function backToInbox() {
            if (window.innerWidth < 768) {
                document.getElementById('inboxPanel').classList.remove('-translate-x-full');
                document.getElementById('chatDetailPanel').classList.add('translate-x-full');
            }
            currentReceiverId = null;
        }

        async function loadHistory(userId) {
            const chatBox = document.getElementById('chatMessages');
            chatBox.innerHTML = '<div class="flex items-center justify-center h-full"><div class="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div></div>';

            try {
                const res = await fetch('${pageContext.request.contextPath}/api/chat?action=history&partnerId=' + userId);
                const msgs = await res.json();
                chatBox.innerHTML = '';

                let lastSystemMsg = "";

                msgs.forEach(m => {
                    if (m.content && m.content.startsWith("SYSTEM_GIFT:")) {
                        // Chỉ lấy system msg của item đang chọn
                        // Tuy nhiên, message hiện tại chưa lưu itemId, nên ta phải dựa vào nội dung hoặc chấp nhận lấy cái cuối cùng
                        // Tạm thời lấy cái cuối cùng, nhưng logic nút bấm sẽ dựa vào activeDeals
                        lastSystemMsg = m.content;
                        let cleanText = m.content.replace("SYSTEM_GIFT:", "");
                        appendSystemMessage(cleanText);
                    } else {
                        appendMessage(m.content, m.imageUrl, m.senderId === currentUserId ? 'outgoing' : 'incoming');
                    }
                });

                // --- LOGIC HIỂN THỊ NÚT BẤM (DỰA VÀO ACTIVE DEALS) ---
                const btnGiver = document.getElementById('btnGiverConfirm');
                const btnReceiver = document.getElementById('btnReceiverConfirm');
                const btnCancel = document.getElementById('btnCancelTrans');
                const btnRequestAgain = document.getElementById('btnRequestAgain');
                const btnBatchAction = document.getElementById('btnBatchAction');

                // Tìm deal hiện tại trong danh sách activeDeals
                const currentDeal = activeDeals.find(d => d.itemId == currentDiscussingItemId);

                // Reset
                btnGiver.classList.add('hidden');
                btnReceiver.classList.add('hidden');
                btnCancel.classList.add('hidden');
                btnRequestAgain.classList.add('hidden');
                btnBatchAction.classList.add('hidden');

                if (currentDeal) {
                    const status = currentDeal.status; // PENDING, CONFIRMED

                    if (isOwnerOfCurrentItem) {
                        // NGƯỜI CHO
                        if (status === 'PENDING') {
                            btnGiver.classList.remove('hidden');
                            btnCancel.classList.add('hidden');
                        } else if (status === 'CONFIRMED') {
                            btnCancel.classList.remove('hidden');
                        }
                    } else {
                        // NGƯỜI NHẬN
                        if (status === 'CONFIRMED') {
                            // Nếu có nhiều hơn 1 giao dịch đang CONFIRMED -> Hiện nút Batch
                            const confirmedDeals = activeDeals.filter(d => d.status === 'CONFIRMED');
                            if (confirmedDeals.length > 1) {
                                btnBatchAction.classList.remove('hidden');
                                document.getElementById('btnBatchLabel').innerText = confirmedDeals.length + " giao dịch";
                                btnCancel.classList.add('hidden'); // Ẩn nút hủy đơn lẻ
                            } else {
                                btnReceiver.classList.remove('hidden');
                                btnCancel.classList.add('hidden'); // Đã confirm thì không cho hủy nữa
                            }
                        } else if (status === 'PENDING') {
                            btnCancel.classList.remove('hidden'); // Hủy yêu cầu
                        }
                    }
                } else {
                    // Không tìm thấy deal active -> Có thể đã COMPLETED hoặc CANCELED
                    // Kiểm tra lastSystemMsg để biết
                    if (lastSystemMsg.includes("CANCELED") || lastSystemMsg.includes("đã bị hủy")) {
                         if (!isOwnerOfCurrentItem) {
                            btnRequestAgain.classList.remove('hidden');
                        }
                    }
                }

                chatBox.scrollTop = chatBox.scrollHeight;
            } catch(e) {
                chatBox.innerHTML = '<div class="text-center text-red-500 text-sm mt-4 font-medium">Không thể tải tin nhắn</div>';
            }
        }

        // --- BATCH CONFIRM LOGIC ---
        function openBatchModal() {
            const modal = document.getElementById('batchConfirmModal');
            const list = document.getElementById('batchList');
            list.innerHTML = '';

            // Lọc các giao dịch CONFIRMED
            const confirmedDeals = activeDeals.filter(d => d.status === 'CONFIRMED');

            confirmedDeals.forEach(d => {
                list.innerHTML += `
                    <div class="flex items-center gap-2 p-2 bg-slate-50 rounded-xl border border-slate-100 transition hover:bg-slate-100">
                        <label class="flex items-center gap-3 flex-1 cursor-pointer">
                            <input type="checkbox" value="\${d.itemId}" class="w-5 h-5 text-primary rounded focus:ring-primary border-gray-300 batch-checkbox" checked>
                            <div class="flex-1">
                                <div class="font-bold text-slate-800">\${d.itemName}</div>
                                <div class="text-xs text-slate-500">ID: \${d.itemId}</div>
                            </div>
                        </label>
                        <button onclick="showItemInfo(\${d.itemId})" class="p-2 text-slate-400 hover:text-primary rounded-full hover:bg-white transition" title="Xem chi tiết">
                            <span class="material-symbols-rounded">info</span>
                        </button>
                    </div>
                `;
            });

            modal.classList.remove('hidden');
        }

        async function submitBatchConfirm() {
            const checkboxes = document.querySelectorAll('.batch-checkbox:checked');
            if (checkboxes.length === 0) {
                alert("Vui lòng chọn ít nhất 1 món đồ!");
                return;
            }

            const itemIds = Array.from(checkboxes).map(cb => cb.value);

            // Lặp qua từng item để confirm (Tạm thời gọi API nhiều lần, sau này có thể tối ưu backend nhận mảng)
            for (const itemId of itemIds) {
                await confirmSingleItem(itemId);
            }

            document.getElementById('batchConfirmModal').classList.add('hidden');
            alert("Đã xác nhận nhận " + itemIds.length + " món đồ!");

            // Reload
            loadActiveDeals(currentReceiverId);
            loadHistory(currentReceiverId);
        }

        async function confirmSingleItem(itemId) {
            try {
                const fd = new URLSearchParams();
                fd.append('itemId', itemId);
                fd.append('receiverId', currentUserId);
                fd.append('action', 'receiver_confirm');

                const res = await fetch('${pageContext.request.contextPath}/api/confirm-transaction', { method: 'POST', body: fd });
                const data = await res.json();

                if (data.status === 'success') {
                    // Gửi thông báo socket
                    const sysMsg = "SYSTEM_GIFT:Người nhận đã xác nhận nhận đồ (" + data.itemName + "). Trạng thái: COMPLETED.";
                    if (chatSocket && currentReceiverId) {
                        chatSocket.send(JSON.stringify({ receiverId: currentReceiverId, content: sysMsg }));
                    }
                    appendSystemMessage(sysMsg.replace("SYSTEM_GIFT:", ""));
                }
            } catch (e) { console.error(e); }
        }

        // --- ITEM INFO LOGIC (MỚI) ---
        async function showItemInfo(specificItemId) {
            // Use specific ID if provided, otherwise use global current ID
            const targetId = specificItemId || currentDiscussingItemId;

            if (!targetId) {
                alert("Vui lòng chọn một cuộc hội thoại có vật phẩm!");
                return;
            }

            try {
                const res = await fetch('${pageContext.request.contextPath}/api/chat?action=item_detail&itemId=' + targetId);
                const item = await res.json();

                if (item.error) {
                    alert("Không tìm thấy thông tin vật phẩm.");
                    return;
                }

                document.getElementById('infoTitle').innerText = item.title;
                document.getElementById('infoDesc').innerText = item.description || "Không có mô tả";
                document.getElementById('infoAddress').innerText = item.address || "Chưa cập nhật địa chỉ";
                document.getElementById('infoPoints').innerText = item.ecoPoints || 0;
                document.getElementById('infoGiver').innerText = item.giverName || "Ẩn danh";
                document.getElementById('infoCategory').innerText = item.categoryName || "Chung";

                // Xử lý ảnh
                let imgUrl = item.imageUrl;
                if (imgUrl && !imgUrl.startsWith('http')) {
                    imgUrl = '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(imgUrl);
                }
                document.getElementById('infoImg').src = imgUrl || 'https://placehold.co/400x300';

                document.getElementById('itemInfoModal').classList.remove('hidden');

            } catch (e) {
                console.error(e);
                alert("Lỗi tải thông tin vật phẩm.");
            }
        }

        // --- USER PROFILE LOGIC (MỚI) ---
        async function showUserProfile() {
            if (!currentReceiverId) {
                alert("Vui lòng chọn một người dùng!");
                return;
            }

            try {
                const res = await fetch('${pageContext.request.contextPath}/api/chat?action=user_info&userId=' + currentReceiverId);
                const user = await res.json();

                if (user.error) {
                    alert("Không tìm thấy thông tin người dùng.");
                    return;
                }

                document.getElementById('profileName').innerText = user.username;
                document.getElementById('profileEmail').innerText = user.email;
                document.getElementById('profilePoints').innerText = user.ecoPoints || 0;
                document.getElementById('profileReputation').innerText = user.reputationScore || 0;
                document.getElementById('profileGivenCount').innerText = user.givenCount || 0;

                // Format date
                const joinDate = new Date(user.joinDate);
                document.getElementById('profileJoinDate').innerText = joinDate.toLocaleDateString('vi-VN');

                document.getElementById('profileAvatar').src = "https://api.dicebear.com/9.x/notionists-neutral/svg?seed=" + user.username;
                document.getElementById('profileLink').href = "${pageContext.request.contextPath}/profile?userId=" + user.userId;

                document.getElementById('userProfileModal').classList.remove('hidden');

            } catch (e) {
                console.error(e);
                alert("Lỗi tải thông tin người dùng.");
            }
        }

        // --- IMAGE UPLOAD ---
        async function uploadImage() {
            const input = document.getElementById('imageInput');
            if (input.files.length === 0) return;

            const file = input.files[0];
            const formData = new FormData();
            formData.append("image", file);

            try {
                const res = await fetch('${pageContext.request.contextPath}/api/chat/upload-image', {
                    method: 'POST',
                    body: formData
                });
                const data = await res.json();

                if (data.status === 'success') {
                    sendMessageAuto("", data.imageUrl);
                } else {
                    alert("Lỗi upload ảnh: " + data.message);
                }
            } catch (e) {
                alert("Lỗi kết nối khi upload ảnh");
            } finally {
                input.value = '';
            }
        }

        function openLightbox(src) {
            document.getElementById('lightboxImg').src = src;
            document.getElementById('lightboxModal').classList.remove('hidden');
        }

        // --- SEND MESSAGE ---
        function sendMessage() {
            const inp = document.getElementById('chatInput');
            if (inp.value.trim()) {
                sendMessageAuto(inp.value.trim(), null);
                inp.value = '';
                inp.focus();
            }
        }

        function sendQuickReply(text) {
            sendMessageAuto(text, null);
        }

        function sendMessageAuto(txt, imgUrl) {
            if (chatSocket && currentReceiverId) {
                const msgData = { receiverId: currentReceiverId, content: txt };
                if (imgUrl) msgData.imageUrl = imgUrl;

                chatSocket.send(JSON.stringify(msgData));

                if (txt && txt.startsWith("SYSTEM_GIFT:")) appendSystemMessage(txt.replace("SYSTEM_GIFT:", ""));
                else appendMessage(txt, imgUrl, 'outgoing');

                setTimeout(loadInboxList, 500);
            }
        }

        function appendMessage(txt, imgUrl, type) {
            const box = document.getElementById('chatMessages');
            const isOutgoing = type === 'outgoing';
            const wrapperCls = isOutgoing ? 'justify-end' : 'justify-start';

            const bubbleCls = isOutgoing
                ? 'bg-gradient-to-br from-primary to-emerald-500 text-white rounded-tr-none shadow-lg shadow-emerald-200/50'
                : 'bg-white/80 backdrop-blur-sm border border-white text-slate-700 rounded-tl-none shadow-sm';

            let contentHtml = '';

            if (imgUrl) {
                let displayUrl = imgUrl;
                if (!imgUrl.startsWith('http')) {
                    displayUrl = '${pageContext.request.contextPath}/images?path=' + encodeURIComponent(imgUrl);
                }
                contentHtml += `<img src="\${displayUrl}" onclick="openLightbox(this.src)" class="max-w-full w-48 h-auto rounded-lg mb-1 cursor-pointer hover:opacity-90 transition border border-white/20">`;
            }

            if (txt) {
                contentHtml += `<div>\${txt}</div>`;
            }

            const html = `
                <div class="flex \${wrapperCls} mb-3 animate-slide-up">
                    <div class="max-w-[75%] px-4 py-3 rounded-2xl text-sm font-medium leading-relaxed \${bubbleCls}">
                        \${contentHtml}
                    </div>
                </div>`;

            box.insertAdjacentHTML('beforeend', html);
            box.scrollTop = box.scrollHeight;
        }

        function appendSystemMessage(txt) {
            const box = document.getElementById('chatMessages');
            const html = `
                <div class="flex justify-center my-6 animate-scale-in">
                    <span class="bg-yellow-50/90 backdrop-blur-sm text-yellow-800 text-xs font-bold px-4 py-1.5 rounded-full border border-yellow-200 shadow-sm flex items-center gap-1.5">
                        <span class="material-symbols-rounded text-[16px]">card_giftcard</span> \${txt}
                    </span>
                </div>`;
            box.insertAdjacentHTML('beforeend', html);
            box.scrollTop = box.scrollHeight;
        }

        document.getElementById('chatInput').addEventListener('keypress', (e) => { if(e.key==='Enter') sendMessage(); });

        // --- TRANSACTION ACTIONS ---
        async function confirmTransaction(action) {
            const receiverName = document.getElementById('chatTitle').innerText;
            let confirmMsg = "";

            if (action === 'cancel') confirmMsg = "Bạn chắc chắn muốn HỦY giao dịch này?";
            else if (action === 'giver_confirm') confirmMsg = "Bạn xác nhận đã giao món đồ này cho " + receiverName + "?";
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
                    let sysMsg = "";

                    if (action === 'cancel') {
                        sysMsg = "SYSTEM_GIFT:Giao dịch về sản phẩm " + data.itemName + " đã bị hủy!";
                    } else if (action === 'giver_confirm') {
                        // SỬA ĐỔI: Dùng tên người dùng hiện tại (Giver)
                        sysMsg = "SYSTEM_GIFT:" + currentUserName + " đã xác nhận giao đồ. Bạn hãy xác nhận khi nhận được nhé!";
                    } else {
                        sysMsg = "SYSTEM_GIFT:Người nhận đã xác nhận nhận đồ. Trạng thái: COMPLETED. Giao dịch hoàn tất!";
                        openRatingModal();
                    }

                    if (chatSocket && currentReceiverId) {
                        chatSocket.send(JSON.stringify({ receiverId: currentReceiverId, content: sysMsg }));
                    }
                    appendSystemMessage(sysMsg.replace("SYSTEM_GIFT:", ""));

                    // Reload lại lịch sử để cập nhật nút bấm
                    setTimeout(() => loadHistory(currentReceiverId), 500);
                    setTimeout(loadInboxList, 500);
                    setTimeout(() => loadActiveDeals(currentReceiverId), 500); // Reload deals
                } else {
                    alert("❌ Lỗi: " + data.message);
                }
            } catch (e) { alert("❌ Lỗi kết nối"); }
        }

        // --- RE-REQUEST ITEM (XIN LẠI) ---
        async function reRequestItem() {
            if (!currentDiscussingItemId) return;

            try {
                const fd = new URLSearchParams();
                fd.append('itemId', currentDiscussingItemId);

                const res = await fetch('${pageContext.request.contextPath}/request-item', { method: 'POST', body: fd });
                const data = await res.json();

                if (data.status === 'success') {
                    // Gửi tin nhắn thông báo
                    const sysMsg = "SYSTEM_GIFT:Người nhận muốn xin lại món đồ này.";
                    if (chatSocket && currentReceiverId) {
                        chatSocket.send(JSON.stringify({ receiverId: currentReceiverId, content: sysMsg }));
                    }
                    appendSystemMessage("Người nhận muốn xin lại món đồ này.");

                    // Gửi tin nhắn mở đầu (MỚI)
                    const itemName = data.itemName || "món đồ này";
                    const introMsg = "Tôi muốn xin món " + itemName + "!";
                    sendMessageAuto(introMsg, null);

                    // Reload UI
                    setTimeout(() => loadHistory(currentReceiverId), 500);
                    setTimeout(loadInboxList, 500);
                    setTimeout(() => loadActiveDeals(currentReceiverId), 500);
                } else {
                    alert("Lỗi: " + data.message);
                }
            } catch(e) {
                alert("Lỗi kết nối khi xin lại đồ.");
            }
        }

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
                    sendMessageAuto("✅ Mình đã nhận được đồ và đánh giá " + rating + " sao. Cảm ơn bạn!", null);
                    currentDiscussingItemId = null;
                } else {
                    alert("Lỗi: " + data.message);
                }
            } catch (e) { alert("Lỗi kết nối"); }
        }
    </script>

</body>
</html>
