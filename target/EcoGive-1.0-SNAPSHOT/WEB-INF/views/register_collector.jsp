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

<div class="w-full max-w-lg mx-4">
    <div class="bg-white shadow-lg rounded-2xl px-8 py-10">
        <div class="mb-6 text-center">
            <h1 class="text-2xl font-bold text-emerald-600 mb-1">EcoGive</h1>
            <p class="text-slate-500 text-sm">Đăng ký tài khoản Doanh nghiệp Thu gom</p>
        </div>

        <!-- Backend Error Display -->
        <c:if test="${not empty error}">
            <div class="mb-4 px-4 py-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm">
                ${error}
            </div>
        </c:if>

        <form id="registerForm" method="post" action="${pageContext.request.contextPath}/register/collector-company" class="space-y-4">
            
            <div>
                <label for="companyName" class="block text-sm font-medium text-slate-700 mb-1">Tên doanh nghiệp</label>
                <input type="text" id="companyName" name="companyName" value="${companyName}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Ví dụ: Công ty Môi trường Xanh" required>
            </div>

            <div>
                <label for="email" class="block text-sm font-medium text-slate-700 mb-1">Email doanh nghiệp</label>
                <input type="email" id="email" name="email" value="${email}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="contact@company.com" required>
                <p id="emailError" class="text-xs text-red-500 mt-1 hidden"></p>
            </div>

            <div>
                <label for="phone" class="block text-sm font-medium text-slate-700 mb-1">Số điện thoại</label>
                <input type="tel" id="phone" name="phone" value="${phone}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Chỉ nhập số" required>
                <p id="phoneError" class="text-xs text-red-500 mt-1 hidden"></p>
            </div>

            <div>
                <label for="address" class="block text-sm font-medium text-slate-700 mb-1">Địa chỉ</label>
                <input type="text" id="address" name="address" value="${address}"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố" required>
            </div>

            <div>
                <label for="password" class="block text-sm font-medium text-slate-700 mb-1">Mật khẩu</label>
                <input type="password" id="password" name="password"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Ít nhất 6 ký tự" required>
                <p id="passwordError" class="text-xs text-red-500 mt-1 hidden"></p>
            </div>

            <div>
                <label for="confirmPassword" class="block text-sm font-medium text-slate-700 mb-1">Xác nhận mật khẩu</label>
                <input type="password" id="confirmPassword" name="confirmPassword"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Nhập lại mật khẩu" required>
                <p id="confirmPasswordError" class="text-xs text-red-500 mt-1 hidden"></p>
            </div>

            <button type="submit" id="submitButton"
                    class="w-full mt-2 inline-flex items-center justify-center rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 disabled:bg-slate-400 disabled:cursor-not-allowed">
                <span id="buttonText">Đăng ký</span>
                <span id="loadingSpinner" class="hidden animate-spin rounded-full h-4 w-4 border-b-2 border-white ml-2"></span>
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
    const form = document.getElementById('registerForm');
    const emailInput = document.getElementById('email');
    const phoneInput = document.getElementById('phone');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const submitButton = document.getElementById('submitButton');

    const emailError = document.getElementById('emailError');
    const phoneError = document.getElementById('phoneError');
    const passwordError = document.getElementById('passwordError');
    const confirmPasswordError = document.getElementById('confirmPasswordError');

    const validateEmail = (email) => {
        const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(email).toLowerCase());
    };

    const validatePhone = (phone) => {
        const re = /^[0-9]+$/;
        return re.test(phone);
    };

    function validateForm() {
        let isValid = true;

        // Email validation
        if (!validateEmail(emailInput.value)) {
            emailError.textContent = 'Email không đúng định dạng.';
            emailError.classList.remove('hidden');
            isValid = false;
        } else {
            emailError.classList.add('hidden');
        }

        // Phone validation
        if (!validatePhone(phoneInput.value)) {
            phoneError.textContent = 'Số điện thoại chỉ được chứa số.';
            phoneError.classList.remove('hidden');
            isValid = false;
        } else {
            phoneError.classList.add('hidden');
        }

        // Password length validation
        if (passwordInput.value.length < 6) {
            passwordError.textContent = 'Mật khẩu phải có ít nhất 6 ký tự.';
            passwordError.classList.remove('hidden');
            isValid = false;
        } else {
            passwordError.classList.add('hidden');
        }

        // Confirm password validation
        if (passwordInput.value !== confirmPasswordInput.value) {
            confirmPasswordError.textContent = 'Mật khẩu xác nhận không khớp.';
            confirmPasswordError.classList.remove('hidden');
            isValid = false;
        } else {
            confirmPasswordError.classList.add('hidden');
        }
        
        // Check for empty required fields
        const requiredInputs = form.querySelectorAll('[required]');
        requiredInputs.forEach(input => {
            if (!input.value.trim()) {
                isValid = false;
            }
        });

        submitButton.disabled = !isValid;
        return isValid;
    }

    // Add event listeners to all inputs for real-time validation
    form.querySelectorAll('input').forEach(input => {
        input.addEventListener('keyup', validateForm);
        input.addEventListener('change', validateForm);
    });

    form.addEventListener('submit', function(e) {
        if (!validateForm()) {
            e.preventDefault(); // Stop submission if validation fails
        } else {
            // Show loading state
            submitButton.disabled = true;
            document.getElementById('buttonText').classList.add('hidden');
            document.getElementById('loadingSpinner').classList.remove('hidden');
        }
    });

    // Initial validation check on page load
    validateForm();
</script>

</body>
</html>
