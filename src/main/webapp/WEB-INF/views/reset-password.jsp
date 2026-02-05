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
</head>
<body class="min-h-screen bg-slate-100 flex items-center justify-center">

<div class="w-full max-w-md mx-4">
    <div class="bg-white shadow-lg rounded-2xl px-8 py-10">
        <div class="mb-6 text-center">
            <h1 class="text-2xl font-bold text-emerald-600 mb-1">Đặt lại mật khẩu</h1>
            <p class="text-slate-500 text-sm">Nhập mật khẩu mới của bạn</p>
        </div>

        <!-- Thông báo lỗi -->
        <c:if test="${not empty error}">
            <div class="mb-4 px-4 py-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm">
                ${error}
            </div>
        </c:if>

        <form id="resetPasswordForm" method="post" action="${pageContext.request.contextPath}/reset-password" class="space-y-5">
            <input type="hidden" name="token" value="${token}">

            <div>
                <label for="password" class="block text-sm font-medium text-slate-700 mb-1">Mật khẩu mới</label>
                <input type="password" id="password" name="password"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Tối thiểu 6 ký tự" required>
            </div>

            <div>
                <label for="confirmPassword" class="block text-sm font-medium text-slate-700 mb-1">Xác nhận mật khẩu</label>
                <input type="password" id="confirmPassword" name="confirmPassword"
                       class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                       placeholder="Nhập lại mật khẩu" required>
            </div>

            <button type="submit"
                    class="w-full mt-2 inline-flex items-center justify-center rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2">
                Đặt lại mật khẩu
            </button>
        </form>
    </div>
</div>

</body>
</html>
