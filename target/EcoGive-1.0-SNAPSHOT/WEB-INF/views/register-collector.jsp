<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký Doanh nghiệp - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 flex items-center justify-center py-12">

<div class="w-full max-w-md mx-4">
    <div class="bg-white shadow-lg rounded-2xl px-8 py-10">
        <div class="mb-6 text-center">
            <h1 class="text-2xl font-bold text-emerald-600 mb-1">Đăng ký Doanh nghiệp Thu gom</h1>
            <p class="text-slate-500 text-sm">Chung tay xây dựng mạng lưới thu gom bền vững</p>
        </div>

        <c:if test="${not empty error}">
            <div class="mb-4 px-4 py-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm">
                ${error}
            </div>
        </c:if>

        <form id="registerCompanyForm" method="post" action="${pageContext.request.contextPath}/register/collector-company" class="space-y-5">
            <div>
                <label for="companyName" class="block text-sm font-medium text-slate-700 mb-1">Tên doanh nghiệp</label>
                <input type="text" id="companyName" name="companyName" value="${companyName}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Công ty TNHH Môi trường Xanh" required>
            </div>

            <div>
                <label for="email" class="block text-sm font-medium text-slate-700 mb-1">Email doanh nghiệp</label>
                <input type="email" id="email" name="email" value="${email}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="contact@tencongty.com" required>
            </div>

            <div>
                <label for="phoneNumber" class="block text-sm font-medium text-slate-700 mb-1">Số điện thoại</label>
                <input type="tel" id="phoneNumber" name="phoneNumber" value="${phoneNumber}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Chỉ nhập số, ví dụ: 0912345678" required pattern="[0-9]+">
            </div>

            <div>
                <label for="address" class="block text-sm font-medium text-slate-700 mb-1">Địa chỉ</label>
                <input type="text" id="address" name="address" value="${address}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Số 1, Đường ABC, Phường XYZ, Quận 1, TP. HCM" required>
            </div>

            <div>
                <label for="password" class="block text-sm font-medium text-slate-700 mb-1">Mật khẩu</label>
                <input type="password" id="password" name="password"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Tối thiểu 6 ký tự" required minlength="6">
            </div>

            <div>
                <label for="confirmPassword" class="block text-sm font-medium text-slate-700 mb-1">Xác nhận mật khẩu</label>
                <input type="password" id="confirmPassword" name="confirmPassword"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Nhập lại mật khẩu" required minlength="6">
                <p id="passwordError" class="text-xs text-red-600 mt-1 hidden">Mật khẩu xác nhận không khớp.</p>
            </div>

            <button type="submit" id="submitButton"
                    class="w-full mt-2 inline-flex items-center justify-center rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 disabled:bg-slate-400 disabled:cursor-not-allowed">
                <span id="buttonText">Đăng ký</span>
                <svg id="loadingSpinner" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white hidden" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
            </button>
        </form>

        <div class="mt-6 text-center text-xs text-slate-500">
            Đã có tài khoản?
            <a href="${pageContext.request.contextPath}/login" class="text-emerald-600 font-medium hover:underline">
                Đăng nhập ngay
            </a>
        </div>
    </div>
</div>

<script>
    const form = document.getElementById('registerCompanyForm');
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');
    const passwordError = document.getElementById('passwordError');
    const submitButton = document.getElementById('submitButton');
    const buttonText = document.getElementById('buttonText');
    const loadingSpinner = document.getElementById('loadingSpinner');

    function validateForm() {
        const isPasswordMatch = password.value === confirmPassword.value;
        const isPasswordValid = password.value.length >= 6;

        if (!isPasswordMatch && confirmPassword.value) {
            passwordError.classList.remove('hidden');
        } else {
            passwordError.classList.add('hidden');
        }

        // Kiểm tra tất cả các trường required
        const allFieldsFilled = [...form.querySelectorAll('input[required]')].every(input => input.value.trim() !== '');

        submitButton.disabled = !(isPasswordMatch && isPasswordValid && allFieldsFilled);
    }

    form.addEventListener('input', validateForm);

    form.addEventListener('submit', function(e) {
        // Validate lần cuối trước khi submit
        validateForm();
        if (submitButton.disabled) {
            e.preventDefault();
            return;
        }

        // Hiển thị loading state
        submitButton.disabled = true;
        buttonText.classList.add('hidden');
        loadingSpinner.classList.remove('hidden');
    });

    // Chạy validate lần đầu khi load trang để xử lý giá trị cũ (nếu có)
    validateForm();
</script>

</body>
</html>
