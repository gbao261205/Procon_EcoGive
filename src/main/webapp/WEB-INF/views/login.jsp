<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập - EcoGive</title>
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
        .bg-pattern {
            background-color: #05976a;
            background-image: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%2306a876' fill-opacity='0.2'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
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
    <div class="hidden md:flex md:w-1/2 bg-pattern flex-col justify-between p-12 text-white relative overflow-hidden">
        <div class="relative z-10">
            <div class="flex items-center gap-2 font-bold text-2xl tracking-tight mb-2">
                <span class="material-symbols-outlined text-white" style="font-size: 36px;">spa</span>
                EcoGive
            </div>
            <p class="text-emerald-100 text-sm">Nền tảng chia sẻ & tái chế cộng đồng</p>
        </div>

        <div class="relative z-10">
            <h2 class="text-3xl font-bold mb-4 leading-tight">"Hành động nhỏ,<br>Thay đổi lớn."</h2>
            <p class="text-emerald-100 opacity-90">Tham gia cùng hàng ngàn người khác để biến rác thải thành tài nguyên và lan tỏa lối sống xanh.</p>
        </div>

        <!-- Decorative Circle -->
        <div class="absolute -bottom-24 -right-24 w-64 h-64 bg-emerald-500 rounded-full opacity-20 blur-3xl"></div>
        <div class="absolute top-12 right-12 w-32 h-32 bg-emerald-400 rounded-full opacity-10 blur-2xl"></div>
    </div>

    <!-- Right Side: Login Form -->
    <div class="w-full md:w-1/2 p-8 md:p-12 lg:p-16 flex flex-col justify-center items-center md:items-start">
        <div class="w-full max-w-[440px] flex flex-col gap-6">

            <!-- Desktop Header Logo & Welcome -->
            <div class="flex flex-col gap-2 mb-2">
                <div class="hidden lg:flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary" style="font-size: 40px;">spa</span>
                    <span class="text-2xl font-bold tracking-tight text-[#111816]">EcoGive</span>
                </div>
                <h1 class="text-3xl font-bold text-slate-900">Chào mừng trở lại! 👋</h1>
                <p class="text-slate-500">Vui lòng nhập thông tin để đăng nhập.</p>
            </div>

            <!-- Alerts -->
            <c:if test="${param.success == 'true'}">
                <div class="p-4 rounded-lg bg-green-50 border-l-4 border-green-500 text-green-700 text-sm flex items-start gap-3">
                    <span class="material-symbols-outlined text-lg">check_circle</span>
                    <span>Đăng ký thành công! Vui lòng đăng nhập để tiếp tục.</span>
                </div>
            </c:if>

            <c:if test="${not empty message}">
                <div class="p-4 rounded-lg bg-blue-50 border-l-4 border-blue-500 text-blue-700 text-sm flex items-start gap-3">
                    <span class="material-symbols-outlined text-lg">info</span>
                    <span>${message}</span>
                </div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="p-4 rounded-lg bg-red-50 border-l-4 border-red-500 text-red-700 text-sm flex items-start gap-3">
                    <span class="material-symbols-outlined text-lg">error</span>
                    <span>${error}</span>
                </div>
            </c:if>

            <form id="loginForm" method="post" action="${pageContext.request.contextPath}/login" class="space-y-5">
                <div>
                    <label for="username" class="block text-sm font-medium text-slate-700 mb-1.5">Tên đăng nhập</label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <span class="material-symbols-outlined text-slate-400 text-[20px]">person</span>
                        </div>
                        <input type="text" id="username" name="username" value="${username}"
                               class="w-full pl-10 pr-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                               placeholder="Nhập tên đăng nhập" required>
                    </div>
                </div>

                <div>
                    <div class="flex items-center justify-between mb-1.5">
                        <label for="password" class="block text-sm font-medium text-slate-700">Mật khẩu</label>
                        <a href="${pageContext.request.contextPath}/forgot-password" class="text-sm font-medium text-primary hover:text-primary-hover hover:underline">Quên mật khẩu?</a>
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <span class="material-symbols-outlined text-slate-400 text-[20px]">lock</span>
                        </div>
                        <input type="password" id="password" name="password"
                               class="w-full pl-10 pr-12 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                               placeholder="••••••••" required>
                        <button type="button" id="togglePassword"
                                class="absolute inset-y-0 right-0 px-3 flex items-center text-slate-400 hover:text-slate-600 transition-colors focus:outline-none">
                            <span class="material-symbols-outlined text-[20px]">visibility</span>
                        </button>
                    </div>
                </div>

                <div class="flex items-center">
                    <input id="remember-me" name="remember-me" type="checkbox" class="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded cursor-pointer">
                    <label for="remember-me" class="ml-2 block text-sm text-slate-600 cursor-pointer select-none">Ghi nhớ đăng nhập</label>
                </div>

                <button type="submit"
                        class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-primary hover:bg-primary-hover focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition-all transform hover:-translate-y-0.5 active:scale-95">
                    Đăng nhập
                </button>
            </form>

            <div class="text-center">
                <p class="text-sm text-slate-600">
                    Chưa có tài khoản?
                    <a href="${pageContext.request.contextPath}/register" class="font-semibold text-primary hover:text-primary-hover hover:underline ml-1">
                        Đăng ký ngay
                    </a>
                </p>
            </div>
        </div>
    </div>
</div>

<script>
    const togglePasswordBtn = document.getElementById('togglePassword');
    const passwordInput = document.getElementById('password');

    togglePasswordBtn.addEventListener('click', function () {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);

        if (type === 'text') {
            this.innerHTML = '<span class="material-symbols-outlined text-[20px]">visibility_off</span>';
        } else {
            this.innerHTML = '<span class="material-symbols-outlined text-[20px]">visibility</span>';
        }
    });
</script>

</body>
</html>
