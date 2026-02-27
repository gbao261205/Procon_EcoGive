<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác thực Doanh nghiệp - EcoGive</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-50">

<c:set var="user" value="${sessionScope.currentUser}" />

<!-- Header -->
<header class="bg-white shadow-sm z-30 px-4 md:px-6 h-16 flex justify-between items-center flex-shrink-0 border-b border-slate-100 sticky top-0">
    <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 group">
        <span class="material-symbols-outlined text-primary group-hover:scale-110 transition-transform duration-300" style="font-size: 28px;">spa</span>
        <h1 class="text-lg md:text-xl font-bold tracking-tight text-slate-800">EcoGive</h1>
    </a>
    <div class="flex items-center gap-4">
        <a href="${pageContext.request.contextPath}/dashboard/company" class="hidden md:flex items-center gap-2 px-3 py-2 text-sm font-semibold text-slate-600 bg-slate-50 hover:bg-emerald-50 hover:text-primary rounded-lg transition-all">
            <span class="material-symbols-outlined text-[20px]">dashboard</span>
            <span>Dashboard</span>
        </a>
        <div class="h-6 w-px bg-slate-200 hidden md:block"></div>
        <div class="flex items-center gap-3">
            <div class="text-right hidden sm:block">
                <div class="text-sm font-bold text-slate-800">${user.username}</div>
                <div class="text-xs text-slate-500">Doanh nghiệp</div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center justify-center w-9 h-9 rounded-full text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all" title="Đăng xuất">
                <span class="material-symbols-outlined text-[20px]">logout</span>
            </a>
        </div>
    </div>
</header>

<main class="max-w-3xl mx-auto px-4 py-8">
    <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
        <h1 class="text-2xl font-bold text-slate-800 mb-2 flex items-center gap-2">
            <span class="material-symbols-outlined text-primary">verified_user</span>
            Xác thực tài khoản Doanh nghiệp
        </h1>
        <p class="text-slate-500 mb-6">Tải lên giấy phép kinh doanh hoặc tài liệu tương đương để nhận dấu tích xanh và tăng độ tin cậy.</p>

        <c:if test="${not empty message}">
            <div class="bg-green-50 text-green-700 border border-green-200 p-4 rounded-lg mb-6 text-sm font-medium">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="bg-red-50 text-red-700 border border-red-200 p-4 rounded-lg mb-6 text-sm font-medium">${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${user.companyVerificationStatus == 'PENDING'}">
                <div class="bg-blue-50 text-blue-700 p-6 rounded-xl border border-blue-200 text-center">
                    <h3 class="font-bold mb-2">Đang chờ duyệt</h3>
                    <p class="text-sm">Yêu cầu xác thực của bạn đã được gửi. Chúng tôi sẽ xem xét và phản hồi trong thời gian sớm nhất.</p>
                    <c:if test="${not empty user.verificationDocument}">
                        <a href="${user.verificationDocument}" target="_blank" class="mt-4 inline-block text-sm font-bold text-blue-600 hover:underline">Xem lại tài liệu đã gửi</a>
                    </c:if>
                </div>
            </c:when>
            <c:when test="${user.companyVerificationStatus == 'VERIFIED'}">
                <div class="bg-green-50 text-green-700 p-6 rounded-xl border border-green-200 text-center">
                    <h3 class="font-bold mb-2 flex items-center justify-center gap-1">
                        <span class="material-symbols-outlined">check_circle</span>
                        Đã xác thực
                    </h3>
                    <p class="text-sm">Tài khoản của bạn đã được xác thực thành công!</p>
                </div>
            </c:when>
            <c:otherwise>
                <form action="${pageContext.request.contextPath}/verify-company" method="post" enctype="multipart/form-data">
                    <div class="space-y-4">
                        <div>
                            <label for="documentImage" class="block text-sm font-medium text-slate-700 mb-2">Tài liệu xác thực (Ảnh)</label>
                            <div class="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-slate-300 border-dashed rounded-md">
                                <div class="space-y-1 text-center">
                                    <svg class="mx-auto h-12 w-12 text-slate-400" stroke="currentColor" fill="none" viewBox="0 0 48 48" aria-hidden="true">
                                        <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
                                    </svg>
                                    <div class="flex text-sm text-slate-600">
                                        <label for="documentImage" class="relative cursor-pointer bg-white rounded-md font-medium text-primary hover:text-primary-hover focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-primary">
                                            <span>Tải lên một file</span>
                                            <input id="documentImage" name="documentImage" type="file" class="sr-only" accept="image/*" required>
                                        </label>
                                        <p class="pl-1">hoặc kéo và thả</p>
                                    </div>
                                    <p class="text-xs text-slate-500">PNG, JPG, GIF tối đa 10MB</p>
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="w-full bg-primary text-white p-3 rounded-xl font-bold hover:bg-primary-hover transition shadow-md">Gửi yêu cầu</button>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</main>

</body>
</html>
