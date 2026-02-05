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
        .bg-pattern-business {
            background-color: #0f172a; /* Dark slate for business feel */
            background-image: radial-gradient(#05976a 1px, transparent 1px);
            background-size: 32px 32px;
        }
    </style>
</head>
<body class="min-h-screen bg-gray-50 flex items-center justify-center p-4">

<!-- Mobile Logo (Absolute) -->
<div class="lg:hidden absolute top-6 left-6 flex items-center gap-2 z-50">
    <span class="material-symbols-outlined text-primary" style="font-size: 32px;">spa</span>
    <span class="text-xl font-bold tracking-tight text-[#111816]">EcoGive</span>
</div>

<div class="w-full max-w-6xl bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col md:flex-row">

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
    <div class="w-full md:w-7/12 p-8 md:p-12 lg:p-16 flex flex-col justify-center items-center md:items-start overflow-y-auto max-h-screen">
        <div class="w-full max-w-[500px] flex flex-col gap-6">

            <!-- Desktop Header Logo & Welcome -->
            <div class="flex flex-col gap-2 mb-2">
                <div class="hidden lg:flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined text-primary" style="font-size: 40px;">spa</span>
                    <span class="text-2xl font-bold tracking-tight text-[#111816]">EcoGive</span>
                </div>
                <h1 class="text-2xl md:text-3xl font-bold text-slate-900">Đăng ký Đối tác 🤝</h1>
                <p class="text-slate-500">Điền thông tin doanh nghiệp để tham gia mạng lưới EcoGive.</p>
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
                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                               placeholder="Ví dụ: Công ty TNHH Môi trường Xanh" required>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label for="email" class="block text-sm font-medium text-slate-700 mb-1.5">Email liên hệ</label>
                            <input type="email" id="email" name="email" value="${email}"
                                   class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                                   placeholder="contact@company.com" required>
                        </div>
                        <div>
                            <label for="phoneNumber" class="block text-sm font-medium text-slate-700 mb-1.5">Số điện thoại</label>
                            <input type="tel" id="phoneNumber" name="phoneNumber" value="${phoneNumber}"
                                   class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                                   placeholder="0912345678" required pattern="[0-9]+">
                        </div>
                    </div>

                    <div>
                        <label for="address" class="block text-sm font-medium text-slate-700 mb-1.5">Địa chỉ trụ sở</label>
                        <input type="text" id="address" name="address" value="${address}"
                               class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
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
                                   class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
                                   placeholder="Tối thiểu 6 ký tự" required minlength="6">
                        </div>
                        <div>
                            <label for="confirmPassword" class="block text-sm font-medium text-slate-700 mb-1.5">Xác nhận mật khẩu</label>
                            <input type="password" id="confirmPassword" name="confirmPassword"
                                   class="w-full px-4 py-2.5 rounded-lg border border-slate-300 text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all"
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
</script>

</body>
</html>
