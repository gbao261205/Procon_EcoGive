<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quên mật khẩu - EcoGive</title>
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
    </style>
</head>
<body class="min-h-screen bg-gray-50 flex items-center justify-center p-4 relative overflow-hidden">

<!-- Mobile Logo (Absolute) -->
<div class="lg:hidden absolute top-6 left-6 flex items-center gap-2 z-50">
    <span class="material-symbols-outlined text-primary" style="font-size: 32px;">spa</span>
    <span class="text-xl font-bold tracking-tight text-[#111816]">EcoGive</span>
</div>

<!-- Background Decoration -->
<div class="absolute top-10 left-10 w-20 h-20 bg-white opacity-10 rounded-full blur-xl z-0"></div>
<div class="absolute top-20 right-20 w-32 h-32 bg-white opacity-10 rounded-full blur-xl z-0"></div>

<div class="w-full max-w-md bg-white rounded-2xl shadow-xl p-8 relative z-10">
    <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-emerald-50 mb-4">
            <span class="material-symbols-outlined text-primary" style="font-size: 32px;">lock_reset</span>
        </div>
        <h1 class="text-2xl font-bold text-slate-900 mb-2">Quên mật khẩu?</h1>
        <p class="text-slate-500 text-sm px-4">Đừng lo lắng! Hãy nhập email đã đăng ký, chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu cho bạn.</p>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty message}">
        <div class="mb-6 p-4 rounded-lg bg-green-50 border border-green-200 text-green-700 text-sm flex items-start gap-3">
            <span class="material-symbols-outlined text-lg mt-0.5">check_circle</span>
            <span>${message}</span>
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="mb-6 p-4 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm flex items-start gap-3">
            <span class="material-symbols-outlined text-lg mt-0.5">error</span>
            <span>${error}</span>
        </div>
    </c:if>

    <form id="forgotPasswordForm" method="post" action="${pageContext.request.contextPath}/forgot-password" class="space-y-6">
        <div>
            <label for="email" class="block text-sm font-medium text-slate-700 mb-1.5">Email đăng ký</label>
            <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span class="material-symbols-outlined text-slate-400 text-[20px]">mail</span>
                </div>
                <input type="email" id="email" name="email"
                       class="w-full pl-10 pr-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                       placeholder="nhapemail@example.com" required>
            </div>
        </div>

        <button type="submit"
                class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-primary hover:bg-primary-hover focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition-all transform hover:-translate-y-0.5 active:scale-95">
            Gửi liên kết đặt lại mật khẩu
        </button>
    </form>

    <div class="mt-8 text-center">
        <a href="${pageContext.request.contextPath}/login" class="inline-flex items-center text-sm font-medium text-slate-500 hover:text-primary transition-colors">
            <span class="material-symbols-outlined text-sm mr-2">arrow_back</span>
            Quay lại đăng nhập
        </a>
    </div>
</div>

<div class="absolute bottom-4 text-center w-full text-slate-400 text-xs z-0">
    © <script>document.write(new Date().getFullYear())</script> EcoGive. All rights reserved.
</div>

</body>
</html>
