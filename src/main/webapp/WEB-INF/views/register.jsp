<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Inter', sans-serif; }
        .bg-pattern-2 {
            background-color: #05976a;
            background-image: url("data:image/svg+xml,%3Csvg width='52' height='26' viewBox='0 0 52 26' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%2306a876' fill-opacity='0.2'%3E%3Cpath d='M10 10c0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6h2c0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4v2c-3.314 0-6-2.686-6-6 0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6zm25.464-1.95l8.486 8.486-1.414 1.414-8.486-8.486 1.414-1.414z' /%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        }
    </style>
</head>
<body class="min-h-screen bg-gray-50 flex items-center justify-center p-4">

<!-- Mobile Logo (Absolute) -->
<div class="lg:hidden absolute top-6 left-6 flex items-center gap-2 z-50">
    <span class="material-symbols-outlined text-primary" style="font-size: 32px;">spa</span>
    <span class="text-xl font-bold tracking-tight text-[#111816]">EcoGive</span>
</div>

<div class="w-full max-w-5xl bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col md:flex-row">

    <!-- Left Side: Image & Branding (Hidden on Mobile) -->
    <div class="hidden md:flex md:w-1/2 bg-pattern-2 flex-col justify-between p-12 text-white relative overflow-hidden">
        <div class="relative z-10">
            <div class="flex items-center gap-2 font-bold text-2xl tracking-tight mb-2">
                <span class="material-symbols-outlined text-white" style="font-size: 36px;">spa</span>
                EcoGive
            </div>
            <p class="text-emerald-100 text-sm">Kết nối - Chia sẻ - Tái tạo</p>
        </div>

        <div class="relative z-10">
            <h2 class="text-3xl font-bold mb-4 leading-tight">"Tham gia cộng đồng xanh."</h2>
            <ul class="space-y-3 text-emerald-100 opacity-90">
                <li class="flex items-center gap-2">
                    <span class="material-symbols-outlined text-emerald-200">check_circle</span>
                    Tích điểm đổi quà hấp dẫn
                </li>
                <li class="flex items-center gap-2">
                    <span class="material-symbols-outlined text-emerald-200">check_circle</span>
                    Theo dõi hành trình bảo vệ môi trường
                </li>
                <li class="flex items-center gap-2">
                    <span class="material-symbols-outlined text-emerald-200">check_circle</span>
                    Kết nối với các điểm thu gom uy tín
                </li>
            </ul>
        </div>

        <!-- Decorative Shapes -->
        <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-white opacity-5 rounded-full blur-3xl"></div>
    </div>

    <!-- Right Side: Register Form -->
    <div class="w-full md:w-1/2 p-8 md:p-12 lg:p-16 flex flex-col justify-center items-center md:items-start">
        <div class="w-full max-w-[440px] flex flex-col gap-6">

            <!-- Desktop Header Logo & Welcome -->
            <div class="flex flex-col gap-2 mb-2">
                <div class="hidden lg:flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary" style="font-size: 40px;">spa</span>
                    <span class="text-2xl font-bold tracking-tight text-[#111816]">EcoGive</span>
                </div>
                <h1 class="text-3xl font-bold text-slate-900">Tạo tài khoản mới 🚀</h1>
                <p class="text-slate-500">Bắt đầu hành trình sống xanh của bạn ngay hôm nay.</p>
            </div>

            <c:if test="${not empty error}">
                <div class="p-4 rounded-lg bg-red-50 border-l-4 border-red-500 text-red-700 text-sm flex items-start gap-3">
                    <span class="material-symbols-outlined text-lg">error</span>
                    <span>${error}</span>
                </div>
            </c:if>

            <form id="registerForm" method="post" action="${pageContext.request.contextPath}/register" class="space-y-4">
                <div>
                    <label for="username" class="block text-sm font-medium text-slate-700 mb-1.5">Tên đăng nhập</label>
                    <input type="text" id="username" name="username" value="${username}"
                           class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                           placeholder="Ví dụ: nguyenvanan" required>
                </div>

                <div>
                    <label for="email" class="block text-sm font-medium text-slate-700 mb-1.5">Email</label>
                    <input type="email" id="email" name="email" value="${email}"
                           class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                           placeholder="email@example.com" required>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="password" class="block text-sm font-medium text-slate-700 mb-1.5">Mật khẩu</label>
                        <input type="password" id="password" name="password"
                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                               placeholder="••••••••" required>
                    </div>
                    <div>
                        <label for="confirmPassword" class="block text-sm font-medium text-slate-700 mb-1.5">Xác nhận mật khẩu</label>
                        <input type="password" id="confirmPassword" name="confirmPassword"
                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                               placeholder="••••••••" required>
                    </div>
                </div>

                <div class="pt-2">
                    <button type="submit"
                            class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-primary hover:bg-primary-hover focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition-all transform hover:-translate-y-0.5 active:scale-95">
                        Đăng ký tài khoản
                    </button>
                </div>
            </form>

            <div class="space-y-4 text-center">
                <p class="text-sm text-slate-600">
                    Đã có tài khoản?
                    <a href="${pageContext.request.contextPath}/login" class="font-semibold text-primary hover:text-primary-hover hover:underline ml-1">
                        Đăng nhập ngay
                    </a>
                </p>

                <div class="relative">
                    <div class="absolute inset-0 flex items-center">
                        <div class="w-full border-t border-gray-200"></div>
                    </div>
                    <div class="relative flex justify-center text-sm">
                        <span class="px-2 bg-white text-slate-500">Hoặc</span>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/register-collector" class="inline-flex items-center justify-center w-full px-4 py-2.5 border border-slate-300 rounded-lg shadow-sm text-sm font-medium text-slate-700 bg-white hover:bg-slate-50 transition-colors">
                    <span class="material-symbols-outlined text-slate-500 mr-2">business</span>
                    Đăng ký cho Doanh nghiệp / Điểm thu gom
                </a>
            </div>
        </div>
    </div>
</div>

</body>
</html>
