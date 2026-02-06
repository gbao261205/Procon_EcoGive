<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký Doanh nghiệp - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;700;900&display=swap" rel="stylesheet">

    <!-- Icons -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                        darkEarth: '#4a3832',
                        polluted: '#78716c',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        game: ['Outfit', 'sans-serif'],
                    },
                    boxShadow: {
                        'neon': '0 0 20px rgba(52, 211, 153, 0.6)',
                    }
                }
            }
        }
    </script>

    <style>
        body { font-family: 'Inter', sans-serif; }

        /* --- GAME & ANIMATIONS STYLES --- */
        @keyframes float-slow {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(2deg); }
        }
        @keyframes float-medium {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
        }
        @keyframes sway {
            0%, 100% { transform: rotate(-3deg); }
            50% { transform: rotate(3deg); }
        }
        @keyframes grow-up {
            0% { transform: scale(0) translateY(10px); opacity: 0; }
            100% { transform: scale(1) translateY(0); opacity: 1; }
        }

        .animate-float-slow { animation: float-slow 6s ease-in-out infinite; }
        .animate-float-medium { animation: float-medium 4s ease-in-out infinite; }
        .animate-sway { animation: sway 6s ease-in-out infinite; }
        .grow-up { animation: grow-up 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; }

        /* Glassmorphism Card */
        .glass-premium {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.8);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15);
        }

        /* Game Textures */
        .bg-pattern-dots {
            background-image: radial-gradient(#000000 1px, transparent 1px);
            background-size: 20px 20px;
        }

        /* Dragging State */
        .is-dragging {
            transition: none !important;
            transform: scale(1.1) rotate(0deg) !important;
            cursor: grabbing !important;
            z-index: 9999 !important;
            filter: drop-shadow(0 10px 15px rgba(0,0,0,0.3));
        }

        /* Existing Business Pattern */
        .bg-pattern-business {
            background-color: #0f172a; /* Dark slate for business feel */
            background-image: radial-gradient(#05976a 1px, transparent 1px);
            background-size: 32px 32px;
        }
    </style>
</head>
<body class="h-screen w-screen overflow-hidden select-none bg-slate-50 relative text-base">

    <!-- 1. STATIC BACKGROUND (Ẩn mặc định - Dành cho chế độ tĩnh) -->
    <div id="static-bg" class="absolute inset-0 z-0 hidden bg-[#f1f5f9] transform scale-105 transition-opacity duration-500"></div>

    <!-- 2. DYNAMIC SKY (Hiển thị mặc định - Bầu trời động) -->
    <div id="dynamic-sky" class="absolute inset-0 z-0 pointer-events-none overflow-hidden bg-gradient-to-br from-sky-300 via-indigo-50 to-emerald-50">
        <!-- Sun Win Effect -->
        <div id="success-sun" class="absolute top-16 left -translate-x-1/2 opacity-0 transition-all duration-1000 transform scale-50 translate-y-10">
            <div class="absolute inset-0 bg-yellow-300 rounded-full blur-[80px] opacity-60 animate-pulse"></div>
            <span class="material-symbols-rounded text-yellow-400 drop-shadow-[0_0_30px_rgba(250,204,21,1)] animate-[spin_20s_linear_infinite]" style="font-size: 120px; font-variation-settings: 'FILL' 1;">wb_sunny</span>
        </div>

        <!-- Decor Orbs & Light -->
        <div class="absolute top-[-10%] left-[-10%] w-[500px] h-[500px] bg-purple-300/30 rounded-full blur-[100px] animate-float-slow"></div>
        <div class="absolute bottom-[-10%] right-[-5%] w-[600px] h-[600px] bg-emerald-300/20 rounded-full blur-[120px] animate-float-slow" style="animation-delay: 2s;"></div>
        <div class="absolute top-10 left-10 w-32 h-32 bg-yellow-200/40 rounded-full blur-[60px] animate-pulse"></div>

        <!-- Clouds -->
        <div class="absolute top-24 right-[10%] text-white/80 drop-shadow-xl animate-float-medium opacity-80" style="animation-delay: 1s;">
            <span class="material-symbols-rounded" style="font-size: 140px; font-variation-settings: 'FILL' 1;">cloud</span>
        </div>
        <div class="absolute top-40 left-[15%] text-white/60 drop-shadow-lg animate-float-medium" style="animation-delay: 3s;">
            <span class="material-symbols-rounded" style="font-size: 90px; font-variation-settings: 'FILL' 1;">cloud</span>
        </div>
    </div>

    <!-- 3. DYNAMIC GAME LAND (Lớp Game Tương tác - Ẩn trên Mobile) -->
    <div id="dynamic-game" class="hidden md:block absolute inset-0 z-10 pointer-events-none overflow-hidden">

        <!-- CÂY CỐI -->
        <div class="absolute bottom-[75px] left-0 w-[50%] h-[400px] pointer-events-none flex items-end">
            <div class="absolute bottom-10 left-[-20px] text-emerald-800/20 blur-[2px] transform scale-125"><span class="material-symbols-rounded" style="font-size: 280px;">forest</span></div>
            <div class="absolute bottom-0 left-6 text-emerald-600 drop-shadow-lg animate-sway origin-bottom"><span class="material-symbols-rounded" style="font-size: 160px; font-variation-settings: 'FILL' 1;">forest</span></div>
            <div class="absolute bottom-[-10px] left-44 text-emerald-500 drop-shadow-md origin-bottom transform scale-x-[-1]"><span class="material-symbols-rounded" style="font-size: 120px; font-variation-settings: 'FILL' 1;">nature</span></div>
            <div class="absolute bottom-2 left-[30%] text-pink-400 drop-shadow-md animate-bounce"><span class="material-symbols-rounded" style="font-size: 40px;">local_florist</span></div>
            <div class="absolute bottom-0 left-[42%] text-yellow-400 drop-shadow-md animate-bounce" style="animation-delay: 0.5s;"><span class="material-symbols-rounded" style="font-size: 32px;">local_florist</span></div>
        </div>

        <!-- RÁC THẢI -->
        <div id="trash-container" class="absolute bottom-[100px] right-[20%] w-[300px] h-40 z-50">
            <div class="draggable-trash absolute bottom-4 left-10 text-sky-500/80 rotate-12 cursor-grab pointer-events-auto filter drop-shadow-lg hover:scale-110 transition-transform duration-300" data-id="1">
                <span class="material-symbols-rounded" style="font-size: 42px; font-variation-settings: 'FILL' 0, 'wght' 600;">water_bottle</span>
            </div>
            <div class="draggable-trash absolute bottom-2 left-32 text-slate-400 -rotate-12 cursor-grab pointer-events-auto filter drop-shadow-lg hover:scale-110 transition-transform duration-300" data-id="2">
                <span class="material-symbols-rounded" style="font-size: 38px;">newspaper</span>
            </div>
            <div class="draggable-trash absolute bottom-6 left-52 text-amber-700/80 rotate-[30deg] cursor-grab pointer-events-auto filter drop-shadow-lg hover:scale-110 transition-transform duration-300" data-id="3">
                <span class="material-symbols-rounded" style="font-size: 34px;">egg</span>
            </div>
            <div class="draggable-trash absolute bottom-0 left-64 text-red-500/60 rotate-6 cursor-grab pointer-events-auto filter drop-shadow-lg hover:scale-110 transition-transform duration-300" data-id="4">
                <span class="material-symbols-rounded" style="font-size: 30px;">shopping_bag</span>
            </div>
        </div>

        <!-- MÁY TÁI CHẾ -->
        <div id="recycling-machine" class="absolute bottom-[60px] right-[4%] z-40 pointer-events-auto transition-transform duration-300 group">
            <div id="tutorial-arrow" class="absolute -top-32 left -translate-x-1/2 w-48 flex flex-col items-center animate-bounce z-50 pointer-events-none opacity-80">
                <div class="flex items-center gap-2 text-slate-600 font-extrabold text-xs tracking-widest uppercase bg-white/60 px-4 py-2 rounded-full backdrop-blur-md border border-white/80 shadow-lg">
                    <span class="material-symbols-rounded text-primary text-base">pan_tool_alt</span> Kéo rác vào đây
                </div>
                <div class="w-0.5 h-8 bg-gradient-to-b from-white to-transparent mt-2"></div>
                <span class="material-symbols-rounded text-white drop-shadow-lg text-4xl -mt-1">keyboard_arrow_down</span>
            </div>

            <div class="relative flex flex-col items-center">
                <div class="absolute -top-16 w-32 h-32 bg-primary/5 rounded-full blur-xl group-hover:bg-primary/20 transition-colors"></div>
                <div class="w-44 h-52 glass-premium rounded-[2rem] flex flex-col items-center relative overflow-hidden shadow-2xl shadow-emerald-900/10 border-t-2 border-white/90">
                    <div class="w-full h-12 bg-gradient-to-r from-emerald-500 to-teal-500 flex items-center justify-center shadow-lg z-10">
                        <span class="text-[10px] text-white font-black tracking-[0.2em] uppercase flex items-center gap-1">
                            <span class="material-symbols-rounded text-sm">recycling</span> Eco-Cycle
                        </span>
                    </div>
                    <div class="relative mt-4 w-28 h-28 bg-slate-800 rounded-2xl flex items-center justify-center shadow-inner border border-slate-600 group-hover:border-primary transition-colors duration-300">
                        <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')] opacity-30"></div>
                        <div class="absolute inset-0 bg-primary/0 group-hover:bg-primary/10 rounded-2xl transition-all duration-300"></div>
                        <span class="material-symbols-rounded text-emerald-400 animate-pulse group-hover:text-white transition-colors drop-shadow-[0_0_10px_rgba(52,211,153,0.8)]" style="font-size: 48px;">arrow_downward</span>
                    </div>
                    <div class="mt-auto mb-4 w-full px-4 relative flex items-center justify-center">
                        <div class="flex gap-1.5 absolute left-4">
                            <div class="w-2 h-2 rounded-full bg-green-400 shadow-[0_0_8px_#4ade80] animate-pulse"></div>
                            <div class="w-2 h-2 rounded-full bg-slate-300"></div>
                        </div>
                        <div class="h-1.5 w-20 bg-slate-200 rounded-full overflow-hidden">
                            <div id="progress-bar" class="h-full bg-primary w-0 transition-all duration-500"></div>
                        </div>
                    </div>
                </div>
                <div class="w-36 h-4 bg-black/20 blur-md rounded-[100%] -mt-2 z-[-1]"></div>
            </div>
        </div>

        <!-- MẶT ĐẤT -->
        <div class="absolute bottom-0 w-full h-[80px] flex items-stretch z-20 pointer-events-auto shadow-[0_-10px_40px_rgba(0,0,0,0.1)]">
            <div class="flex-grow bg-[#5D4037] relative overflow-hidden rounded-tr-3xl border-t-4 border-emerald-500">
                <div class="absolute inset-0 bg-pattern-dots opacity-10"></div>
                <div class="absolute -top-3 left-0 w-full h-4 bg-emerald-500 blur-[2px]"></div>
            </div>

            <div id="polluted-land" class="w-[450px] bg-[#6D4C41] relative flex justify-center transition-all duration-1000 ease-in-out border-t-4 border-[#8D6E63] mx-[-10px] rounded-t-lg z-10">
                <div class="absolute inset-0 bg-pattern-dots opacity-20 mix-blend-overlay"></div>
                <svg id="land-cracks" class="absolute top-2 left-1/2 -translate-x-1/2 w-[90%] h-full opacity-30 text-[#3E2723] transition-opacity duration-1000" preserveAspectRatio="none" viewBox="0 0 400 80">
                    <path d="M50,0 L60,20 L55,35 M200,0 L190,15 L205,25 M350,0 L340,30" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"></path>
                </svg>
                <div id="success-flowers" class="absolute inset-0 w-full h-full hidden opacity-0 transition-opacity duration-1000 z-50">
                    <div class="absolute -top-10 left-10 text-pink-500 drop-shadow-md"><span class="material-symbols-rounded grow-up" style="font-size: 40px; animation-delay: 0.1s;">local_florist</span></div>
                    <div class="absolute -top-6 left-32 text-emerald-400 drop-shadow-sm"><span class="material-symbols-rounded grow-up" style="font-size: 28px; animation-delay: 0.2s;">grass</span></div>
                    <div class="absolute -top-10 right-32 text-purple-500 drop-shadow-md"><span class="material-symbols-rounded grow-up" style="font-size: 36px; animation-delay: 0.4s;">local_florist</span></div>
                    <div class="absolute -top-6 right-10 text-emerald-400 drop-shadow-sm"><span class="material-symbols-rounded grow-up" style="font-size: 28px; animation-delay: 0.5s;">grass</span></div>
                    <div class="absolute -top-4 left-1/2 -translate-x-1/2 text-red-400 drop-shadow-sm"><span class="material-symbols-rounded grow-up" style="font-size: 20px; animation-delay: 0.3s;">emoji_nature</span></div>
                </div>
            </div>

            <div class="flex-grow bg-[#5D4037] relative overflow-hidden rounded-tl-3xl border-t-4 border-emerald-500">
                <div class="absolute inset-0 bg-pattern-dots opacity-10"></div>
                 <div class="absolute -top-3 left-0 w-full h-4 bg-emerald-500 blur-[2px]"></div>
            </div>
        </div>
    </div>

    <!-- TOGGLE BG BUTTON -->
    <button onclick="toggleBackgroundMode()"
            id="btnToggleBg"
            class="absolute top-6 right-6 z-50 w-12 h-12 bg-white text-slate-700 rounded-full shadow-lg hover:text-purple-600 hover:scale-110 transition-all duration-300 flex items-center justify-center border border-slate-100 group cursor-pointer"
            title="Chế độ nền: Động/Tĩnh">
        <span class="material-symbols-rounded group-hover:rotate-12 transition-transform duration-500 text-2xl">wallpaper</span>
    </button>

    <!-- REGISTER COMPANY FORM OVERLAY (Scrollable on Mobile) -->
    <div class="absolute inset-0 z-40 overflow-y-auto pointer-events-none">
        <div class="min-h-full w-full flex flex-col items-center justify-center p-4 md:p-8">

            <!-- Mobile Logo (Visible only on mobile, in flow) -->
            <div class="lg:hidden flex items-center gap-2 mb-6 pointer-events-auto animate-float-medium">
                <span class="material-symbols-outlined text-primary drop-shadow-md" style="font-size: 40px;">spa</span>
                <span class="text-2xl font-bold tracking-tight text-[#111816]">EcoGive</span>
            </div>

            <div class="w-full max-w-6xl bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col md:flex-row pointer-events-auto relative">

                <!-- Left Side: Business Branding (Hidden on Mobile) -->
                <div class="hidden md:flex md:w-5/12 bg-pattern-business flex-col justify-between p-12 text-white relative overflow-hidden">
                    <div class="relative z-10">
                        <div class="flex items-center gap-2 font-bold text-2xl tracking-tight mb-2">
                            <span class="material-symbols-outlined text-primary" style="font-size: 36px;">spa</span>
                            EcoGive <span class="text-primary font-light">Partner</span>
                        </div>
                        <p class="text-slate-400 text-sm">Dành cho Doanh nghiệp & Điểm thu gom</p>
                    </div>

                    <div class="relative z-10">
                        <h2 class="text-3xl font-bold mb-6 leading-tight">"Mở rộng mạng lưới,<br>Kiến tạo tương lai."</h2>
                        <div class="space-y-6">
                            <div class="flex gap-4">
                                <div class="w-12 h-12 rounded-lg bg-primary/20 flex items-center justify-center text-primary flex-shrink-0">
                                    <span class="material-symbols-outlined">map</span>
                                </div>
                                <div>
                                    <h3 class="font-semibold text-white">Quản lý điểm thu gom</h3>
                                    <p class="text-sm text-slate-400 mt-1">Dễ dàng thêm và quản lý các địa điểm thu gom trên bản đồ số.</p>
                                </div>
                            </div>

                            <div class="flex gap-4">
                                <div class="w-12 h-12 rounded-lg bg-primary/20 flex items-center justify-center text-primary flex-shrink-0">
                                    <span class="material-symbols-outlined">bar_chart</span>
                                </div>
                                <div>
                                    <h3 class="font-semibold text-white">Thống kê & Báo cáo</h3>
                                    <p class="text-sm text-slate-400 mt-1">Theo dõi hiệu quả thu gom và tác động môi trường theo thời gian thực.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Decorative Gradient -->
                    <div class="absolute bottom-0 left-0 w-full h-1/2 bg-gradient-to-t from-slate-900 to-transparent opacity-80"></div>
                </div>

                <!-- Right Side: Registration Form -->
                <div class="w-full md:w-7/12 p-6 md:p-12 lg:p-16 flex flex-col justify-center items-center md:items-start">
                    <div class="w-full max-w-[500px] flex flex-col gap-6">

                        <!-- Desktop Header Logo & Welcome -->
                        <div class="flex flex-col gap-2 mb-2">
                            <div class="hidden lg:flex items-center gap-2 mb-4">
                                <span class="material-symbols-outlined text-primary" style="font-size: 40px;">spa</span>
                                <span class="text-2xl font-bold tracking-tight text-[#111816]">EcoGive</span>
                            </div>
                            <h1 class="text-2xl md:text-3xl font-bold text-slate-900">Đăng ký Đối tác 🤝</h1>
                            <p class="text-slate-500 text-sm md:text-base">Điền thông tin doanh nghiệp để tham gia mạng lưới EcoGive.</p>
                        </div>

                        <c:if test="${not empty error}">
                            <div class="p-4 rounded-lg bg-red-50 border-l-4 border-red-500 text-red-700 text-sm flex items-start gap-3">
                                <span class="material-symbols-outlined text-lg">error</span>
                                <span>${error}</span>
                            </div>
                        </c:if>

                        <form id="registerCompanyForm" method="post" action="${pageContext.request.contextPath}/register-collector" class="space-y-5">
                            <!-- Company Info Section -->
                            <div class="space-y-4">
                                <h3 class="text-xs font-bold text-slate-400 uppercase tracking-wider border-b border-gray-100 pb-2 mb-4">Thông tin Doanh nghiệp</h3>

                                <div>
                                    <label for="companyName" class="block text-sm font-medium text-slate-700 mb-1.5">Tên Doanh nghiệp / Tổ chức</label>
                                    <input type="text" id="companyName" name="companyName" value="${companyName}"
                                           class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all text-base md:text-sm"
                                           placeholder="Ví dụ: Công ty TNHH Môi trường Xanh" required>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label for="email" class="block text-sm font-medium text-slate-700 mb-1.5">Email liên hệ</label>
                                        <input type="email" id="email" name="email" value="${email}"
                                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all text-base md:text-sm"
                                               placeholder="contact@company.com" required>
                                    </div>
                                    <div>
                                        <label for="phoneNumber" class="block text-sm font-medium text-slate-700 mb-1.5">Số điện thoại</label>
                                        <input type="tel" id="phoneNumber" name="phoneNumber" value="${phoneNumber}"
                                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all text-base md:text-sm"
                                               placeholder="0912345678" required pattern="[0-9]+">
                                    </div>
                                </div>

                                <div>
                                    <label for="address" class="block text-sm font-medium text-slate-700 mb-1.5">Địa chỉ trụ sở</label>
                                    <input type="text" id="address" name="address" value="${address}"
                                           class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all text-base md:text-sm"
                                           placeholder="Số nhà, Đường, Phường/Xã, Quận/Huyện, Tỉnh/TP" required>
                                </div>
                            </div>

                            <!-- Security Section -->
                            <div class="space-y-4 pt-2">
                                <h3 class="text-xs font-bold text-slate-400 uppercase tracking-wider border-b border-gray-100 pb-2 mb-4">Bảo mật</h3>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label for="password" class="block text-sm font-medium text-slate-700 mb-1.5">Mật khẩu</label>
                                        <input type="password" id="password" name="password"
                                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all text-base md:text-sm"
                                               placeholder="Tối thiểu 6 ký tự" required minlength="6">
                                    </div>
                                    <div>
                                        <label for="confirmPassword" class="block text-sm font-medium text-slate-700 mb-1.5">Xác nhận mật khẩu</label>
                                        <input type="password" id="confirmPassword" name="confirmPassword"
                                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all text-base md:text-sm"
                                               placeholder="Nhập lại mật khẩu" required minlength="6">
                                    </div>
                                </div>
                                <p id="passwordError" class="text-xs text-red-600 font-medium hidden flex items-center gap-1">
                                    <span class="material-symbols-outlined text-sm">error</span>
                                    Mật khẩu xác nhận không khớp.
                                </p>
                            </div>

                            <div class="pt-4">
                                <button type="submit" id="submitButton"
                                        class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-primary hover:bg-primary-hover focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition-all transform hover:-translate-y-0.5 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none">
                                    <span id="buttonText">Đăng ký Đối tác</span>
                                    <svg id="loadingSpinner" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white hidden" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                    </svg>
                                </button>
                            </div>
                        </form>

                        <div class="text-center">
                            <p class="text-sm text-slate-600">
                                Đã có tài khoản?
                                <a href="${pageContext.request.contextPath}/login" class="font-semibold text-primary hover:text-primary-hover hover:underline ml-1">
                                    Đăng nhập ngay
                                </a>
                            </p>
                            <div class="mt-4 pt-4 border-t border-gray-100">
                                <a href="${pageContext.request.contextPath}/register" class="text-xs text-slate-500 hover:text-slate-700 flex items-center justify-center gap-1">
                                    <span class="material-symbols-outlined text-sm">arrow_back</span>
                                    Quay lại đăng ký người dùng cá nhân
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Spacer for bottom scrolling -->
            <div class="h-8 md:hidden"></div>
        </div>
    </div>

    <!-- JAVASCRIPT LOGIC -->
    <script>
        // 1. Logic Toggle Background
        let isDynamicMode = true;
        function toggleBackgroundMode() {
            isDynamicMode = !isDynamicMode;
            const staticBg = document.getElementById('static-bg');
            const dynamicSky = document.getElementById('dynamic-sky');
            const dynamicGame = document.getElementById('dynamic-game');
            const btnIcon = document.querySelector('#btnToggleBg span');

            if (isDynamicMode) {
                staticBg.classList.add('hidden');
                dynamicSky.classList.remove('hidden');
                // Only show game on desktop
                if (window.innerWidth >= 768) {
                    dynamicGame.classList.remove('hidden');
                }
                btnIcon.innerText = 'wallpaper';
                btnIcon.classList.remove('text-purple-600');
            } else {
                staticBg.classList.remove('hidden');
                dynamicSky.classList.add('hidden');
                dynamicGame.classList.add('hidden');
                btnIcon.innerText = 'image';
                btnIcon.classList.add('text-purple-600');
            }
        }

        // Handle resize to show/hide game if in dynamic mode
        window.addEventListener('resize', () => {
            if (isDynamicMode) {
                const dynamicGame = document.getElementById('dynamic-game');
                if (window.innerWidth >= 768) {
                    dynamicGame.classList.remove('hidden');
                } else {
                    dynamicGame.classList.add('hidden');
                }
            }
        });

        // 2. Logic Game (Kéo thả rác)
        document.addEventListener('DOMContentLoaded', () => {
            const draggables = document.querySelectorAll('.draggable-trash');
            const machine = document.getElementById('recycling-machine');
            const pollutedLand = document.getElementById('polluted-land');
            const cracks = document.getElementById('land-cracks');
            const successFlowers = document.getElementById('success-flowers');
            const successSun = document.getElementById('success-sun');
            const progressBar = document.getElementById('progress-bar');
            const skyBg = document.getElementById('dynamic-sky');
            const tutorialArrow = document.getElementById('tutorial-arrow');

            let trashCount = draggables.length;
            let cleanedCount = 0;

            draggables.forEach(trash => {
                trash.addEventListener('mousedown', startDrag);
                trash.addEventListener('touchstart', startDrag, {passive: false});

                function startDrag(e) {
                    // Only allow drag on desktop/larger screens where game is visible
                    if (window.innerWidth < 768) return;

                    e.preventDefault();

                    if (tutorialArrow && tutorialArrow.style.opacity !== '0') {
                        tutorialArrow.style.transition = 'opacity 0.5s';
                        tutorialArrow.style.opacity = '0';
                    }

                    trash.classList.add('is-dragging');
                    const clientX = e.type === 'mousedown' ? e.clientX : e.touches[0].clientX;
                    const clientY = e.type === 'mousedown' ? e.clientY : e.touches[0].clientY;
                    const rect = trash.getBoundingClientRect();
                    const shiftX = clientX - rect.left;
                    const shiftY = clientY - rect.top;

                    trash.style.position = 'fixed';
                    trash.style.left = (clientX - shiftX) + 'px';
                    trash.style.top = (clientY - shiftY) + 'px';
                    trash.style.width = rect.width + 'px';
                    trash.style.height = rect.height + 'px';
                    trash.style.margin = '0';

                    function moveDrag(e) {
                        const curX = e.type === 'mousemove' ? e.clientX : e.touches[0].clientX;
                        const curY = e.type === 'mousemove' ? e.clientY : e.touches[0].clientY;

                        trash.style.left = (curX - shiftX) + 'px';
                        trash.style.top = (curY - shiftY) + 'px';

                        const machineRect = machine.getBoundingClientRect();
                        if (curX > machineRect.left && curX < machineRect.right &&
                            curY > machineRect.top && curY < machineRect.bottom) {
                            machine.style.transform = 'scale(1.15)';
                        } else {
                            machine.style.transform = 'scale(1)';
                        }
                    }

                    function endDrag(e) {
                        document.removeEventListener('mousemove', moveDrag);
                        document.removeEventListener('mouseup', endDrag);
                        document.removeEventListener('touchmove', moveDrag);
                        document.removeEventListener('touchend', endDrag);

                        trash.classList.remove('is-dragging');

                        const machineRect = machine.getBoundingClientRect();
                        const trashRect = trash.getBoundingClientRect();
                        const trashCenterX = trashRect.left + trashRect.width / 2;
                        const trashCenterY = trashRect.top + trashRect.height / 2;

                        if (trashCenterX > machineRect.left && trashCenterX < machineRect.right &&
                            trashCenterY > machineRect.top && trashCenterY < machineRect.bottom) {

                            trash.style.transition = 'all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
                            trash.style.transform = 'scale(0) translateY(50px)';
                            trash.style.opacity = '0';

                            machine.classList.add('animate-bounce');
                            setTimeout(() => machine.classList.remove('animate-bounce'), 800);

                            cleanedCount++;
                            const percent = (cleanedCount / trashCount) * 100;
                            progressBar.style.width = percent + '%';

                            checkWinCondition();
                        } else {
                            trash.style.position = 'fixed';
                            machine.style.transform = 'scale(1)';
                        }
                    }

                    document.addEventListener('mousemove', moveDrag);
                    document.addEventListener('mouseup', endDrag);
                    document.addEventListener('touchmove', moveDrag, {passive: false});
                    document.addEventListener('touchend', endDrag);
                }
            });

            function checkWinCondition() {
                if (cleanedCount === trashCount) {
                    setTimeout(() => {
                        // HIỆU ỨNG CHIẾN THẮNG:
                        // 1. Biến đất nâu thành đất xanh và bỏ viền cũ
                        pollutedLand.classList.remove('bg-[#6D4C41]', 'border-[#8D6E63]');
                        pollutedLand.classList.add('bg-[#5D4037]', 'border-emerald-500');

                        // 2. QUAN TRỌNG: Làm phẳng mặt đất (xóa rounded và tăng z-index đè lên viền 2 bên)
                        pollutedLand.classList.remove('rounded-t-lg');
                        pollutedLand.classList.remove('z-10');
                        pollutedLand.classList.add('z-30');

                        // 3. Ẩn vết nứt, Hiện hoa
                        cracks.style.opacity = '0';
                        successFlowers.classList.remove('hidden');
                        setTimeout(() => successFlowers.style.opacity = '1', 100);

                        // 4. Hiện mặt trời
                        successSun.classList.remove('opacity-0', 'translate-y-10', 'scale-50');
                        successSun.classList.add(
                            'opacity-100',
                            'scale-100',
                            'fixed',          // Hoặc 'absolute' nếu cha có 'relative'
                            'top-1/9',        // Đẩy xuống 50% chiều cao
                            'left-1/2',       // Đẩy sang 50% chiều ngang
                            '-translate-x-1/2', // Kéo ngược lại nửa chiều rộng
                            '-translate-y-1/2'  // Kéo ngược lại nửa chiều cao
                        );

                        // 5. Làm sáng bầu trời
                        const skyOverlay = document.createElement('div');
                        skyOverlay.className = 'absolute inset-0 bg-gradient-to-b from-yellow-200/20 to-transparent pointer-events-none animate-pulse';
                        skyBg.appendChild(skyOverlay);
                    }, 500);
                }
            }
        });

        // Existing Form Validation Logic
        const form = document.getElementById('registerCompanyForm');
        const password = document.getElementById('password');
        const confirmPassword = document.getElementById('confirmPassword');
        const passwordError = document.getElementById('passwordError');
        const submitButton = document.getElementById('submitButton');
        const buttonText = document.getElementById('buttonText');
        const loadingSpinner = document.getElementById('loadingSpinner');

        if (form && password && confirmPassword && passwordError && submitButton) {
            function validateForm() {
                const isPasswordMatch = password.value === confirmPassword.value;
                const isPasswordValid = password.value.length >= 6;

                if (!isPasswordMatch && confirmPassword.value) {
                    passwordError.classList.remove('hidden');
                    confirmPassword.classList.add('border-red-300', 'focus:ring-red-500');
                    confirmPassword.classList.remove('border-slate-300', 'focus:ring-primary');
                } else {
                    passwordError.classList.add('hidden');
                    confirmPassword.classList.remove('border-red-300', 'focus:ring-red-500');
                    confirmPassword.classList.add('border-slate-300', 'focus:ring-primary');
                }

                const allFieldsFilled = [...form.querySelectorAll('input[required]')].every(input => input.value.trim() !== '');
                submitButton.disabled = !(isPasswordMatch && isPasswordValid && allFieldsFilled);
            }

            form.addEventListener('input', validateForm);

            form.addEventListener('submit', function(e) {
                validateForm();
                if (submitButton.disabled) {
                    e.preventDefault();
                    return;
                }
                submitButton.disabled = true;
                buttonText.classList.add('hidden');
                loadingSpinner.classList.remove('hidden');
            });

            validateForm();
        }
    </script>

</body>
</html>
