<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt lại mật khẩu - EcoGive</title>
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
            <span class="material-symbols-outlined text-primary" style="font-size: 32px;">key</span>
        </div>
        <h1 class="text-2xl font-bold text-slate-900 mb-2">Đặt lại mật khẩu</h1>
        <p class="text-slate-500 text-sm px-4">Hãy tạo một mật khẩu mới mạnh mẽ và an toàn hơn.</p>
    </div>

    <!-- Thông báo lỗi -->
    <c:if test="${not empty error}">
        <div class="mb-6 p-4 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm flex items-start gap-3">
            <span class="material-symbols-outlined text-lg mt-0.5">error</span>
            <span>${error}</span>
        </div>
    </c:if>

    <form id="resetPasswordForm" method="post" action="${pageContext.request.contextPath}/reset-password" class="space-y-5">
        <input type="hidden" name="token" value="${token}">

        <div>
            <label for="password" class="block text-sm font-medium text-slate-700 mb-1.5">Mật khẩu mới</label>
            <div class="relative">
                <input type="password" id="password" name="password"
                       class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all pr-10"
                       placeholder="••••••••" required minlength="6">
                <button type="button" class="toggle-password absolute inset-y-0 right-0 px-3 flex items-center text-slate-400 hover:text-slate-600 focus:outline-none" data-target="password">
                    <span class="material-symbols-outlined text-[20px]">visibility</span>
                </button>
            </div>
        </div>

        <div>
            <label for="confirmPassword" class="block text-sm font-medium text-slate-700 mb-1.5">Xác nhận mật khẩu</label>
            <div class="relative">
                <input type="password" id="confirmPassword" name="confirmPassword"
                       class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all pr-10"
                       placeholder="••••••••" required minlength="6">
                <button type="button" class="toggle-password absolute inset-y-0 right-0 px-3 flex items-center text-slate-400 hover:text-slate-600 focus:outline-none" data-target="confirmPassword">
                    <span class="material-symbols-outlined text-[20px]">visibility</span>
                </button>
            </div>
            <p id="passwordError" class="text-xs text-red-600 mt-1 hidden flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">error</span>
                Mật khẩu xác nhận không khớp.
            </p>
        </div>

        <button type="submit" id="submitButton"
                class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-primary hover:bg-primary-hover focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition-all transform hover:-translate-y-0.5 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed">
            Đổi mật khẩu
        </button>
    </form>
</div>

<div class="absolute bottom-4 text-center w-full text-slate-400 text-xs z-0">
    © <script>document.write(new Date().getFullYear())</script> EcoGive. All rights reserved.
</div>

<script>
    // Toggle Password Visibility
    document.querySelectorAll('.toggle-password').forEach(button => {
        button.addEventListener('click', function() {
            const targetId = this.getAttribute('data-target');
            const input = document.getElementById(targetId);
            const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
            input.setAttribute('type', type);

            // Change icon
            if (type === 'text') {
                this.innerHTML = '<span class="material-symbols-outlined text-[20px]">visibility_off</span>';
            } else {
                this.innerHTML = '<span class="material-symbols-outlined text-[20px]">visibility</span>';
            }
        });
    });

    // Validation
    const form = document.getElementById('resetPasswordForm');
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');
    const passwordError = document.getElementById('passwordError');
    const submitButton = document.getElementById('submitButton');

    function validateForm() {
        const isPasswordMatch = password.value === confirmPassword.value;

        if (!isPasswordMatch && confirmPassword.value) {
            passwordError.classList.remove('hidden');
            confirmPassword.classList.add('border-red-300', 'focus:ring-red-500');
            confirmPassword.classList.remove('border-slate-300', 'focus:ring-primary');
            submitButton.disabled = true;
        } else {
            passwordError.classList.add('hidden');
            confirmPassword.classList.remove('border-red-300', 'focus:ring-red-500');
            confirmPassword.classList.add('border-slate-300', 'focus:ring-primary');
            submitButton.disabled = false;
        }
    }

    confirmPassword.addEventListener('input', validateForm);
    password.addEventListener('input', validateForm);
</script>

</body>
</html>
