<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 flex items-center justify-center">

<div class="w-full max-w-md mx-4">
    <div class="bg-white shadow-lg rounded-2xl px-8 py-10">
        <div class="mb-6 text-center">
            <h1 class="text-2xl font-bold text-emerald-600 mb-1">EcoGive</h1>
            <p class="text-slate-500 text-sm">Đăng nhập để chia sẻ và nhận đồ tái sử dụng</p>
        </div>

        <!-- Thông báo lỗi -->
        <%
            String error = (String) request.getAttribute("error");
        %>
        <c:if test="${not empty error}">
            <div class="mb-4 px-4 py-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm">
                    ${error}
            </div>
        </c:if>

        <!-- Form login -->
        <form id="loginForm" method="post" action="${pageContext.request.contextPath}/login" class="space-y-5">
            <!-- Username -->
            <div>
                <label for="username" class="block text-sm font-medium text-slate-700 mb-1">
                    Tên đăng nhập
                </label>
                <input
                        type="text"
                        id="username"
                        name="username"
                        value="${username}"
                        class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                        placeholder="Nhập tên đăng nhập"
                        required
                />
            </div>

            <!-- Password -->
            <div>
                <label for="password" class="block text-sm font-medium text-slate-700 mb-1">
                    Mật khẩu
                </label>
                <div class="relative">
                    <input
                            type="password"
                            id="password"
                            name="password"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 pr-10 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                            placeholder="Nhập mật khẩu"
                            required
                    />
                    <button
                            type="button"
                            id="togglePassword"
                            class="absolute inset-y-0 right-0 px-3 flex items-center text-slate-400 hover:text-slate-600 text-xs"
                            tabindex="-1"
                    >
                        Hiện
                    </button>
                </div>
            </div>

            <!-- Remember + Forgot -->
            <div class="flex items-center justify-between text-xs text-slate-500">
                <label class="inline-flex items-center gap-2">
                    <input type="checkbox" class="rounded border-slate-300 text-emerald-600">
                    Ghi nhớ đăng nhập
                </label>
                <a href="#" class="hover:text-emerald-600">Quên mật khẩu?</a>
            </div>

            <!-- Submit -->
            <button
                    type="submit"
                    class="w-full mt-2 inline-flex items-center justify-center rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2"
            >
                Đăng nhập
            </button>
        </form>

        <!-- Đăng ký -->
        <div class="mt-6 text-center text-xs text-slate-500">
            Chưa có tài khoản?
            <a href="${pageContext.request.contextPath}/register" class="text-emerald-600 font-medium hover:underline">
                Đăng ký ngay
            </a>
        </div>
    </div>

    <p class="mt-4 text-center text-[11px] text-slate-400">
        © <script>document.write(new Date().getFullYear())</script> EcoGive – Chung tay vì môi trường xanh 🌱
    </p>
</div>

<!-- JS: validate + toggle password -->
<script>
    const form = document.getElementById('loginForm');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    const togglePasswordBtn = document.getElementById('togglePassword');

    // Client-side validate đơn giản
    form.addEventListener('submit', function (e) {
        let valid = true;

        if (!usernameInput.value.trim()) {
            usernameInput.classList.add('border-red-400', 'focus:ring-red-400', 'focus:border-red-400');
            valid = false;
        } else {
            usernameInput.classList.remove('border-red-400', 'focus:ring-red-400', 'focus:border-red-400');
        }

        if (!passwordInput.value.trim()) {
            passwordInput.classList.add('border-red-400', 'focus:ring-red-400', 'focus:border-red-400');
            valid = false;
        } else {
            passwordInput.classList.remove('border-red-400', 'focus:ring-red-400', 'focus:border-red-400');
        }

        if (!valid) {
            e.preventDefault();
        }
    });

    // Toggle show/hide password
    togglePasswordBtn.addEventListener('click', function () {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        togglePasswordBtn.textContent = type === 'password' ? 'Hiện' : 'Ẩn';
    });
</script>

</body>
</html>
