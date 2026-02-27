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
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@24,400,0,0" />
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                        'primary-light': '#e6fcf5',
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                    boxShadow: {
                        'soft': '0 4px 20px -2px rgba(0, 0, 0, 0.05)',
                        'card': '0 0 0 1px rgba(226, 232, 240, 1), 0 2px 4px rgba(0, 0, 0, 0.05)',
                    }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-rounded { font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-slate-50 text-slate-600 antialiased">

<c:set var="user" value="${sessionScope.currentUser}" />

<div class="flex h-screen overflow-hidden">
    <!-- Sidebar (Consistent with Dashboard) -->
    <aside class="w-72 bg-white border-r border-slate-100 flex flex-col z-20 hidden md:flex shadow-soft">
        <!-- Logo -->
        <div class="h-20 flex items-center px-8 border-b border-slate-50">
            <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 text-primary font-bold text-2xl tracking-tight group">
                <span class="material-symbols-rounded text-3xl group-hover:scale-110 transition-transform">spa</span>
                EcoGive
            </a>
        </div>

        <!-- User Info Card -->
        <div class="p-6">
            <div class="bg-primary-light/40 p-4 rounded-2xl border border-primary/10 flex items-center gap-4">
                <div class="w-12 h-12 rounded-full bg-white flex items-center justify-center text-primary shadow-sm shrink-0">
                    <span class="material-symbols-rounded">business</span>
                </div>
                <div class="min-w-0">
                    <h3 class="text-sm font-bold text-slate-800 truncate">${user.username}</h3>
                    <p class="text-xs text-slate-500 font-medium">Partner Portal</p>
                </div>
            </div>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 px-4 space-y-2 overflow-y-auto">
            <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-2 mt-2">Quản lý</p>

            <a href="${pageContext.request.contextPath}/dashboard/company" class="flex items-center gap-3 px-4 py-3.5 text-slate-500 hover:bg-slate-50 hover:text-primary rounded-xl font-medium transition-all group">
                <span class="material-symbols-rounded group-hover:scale-110 transition-transform">recycling</span>
                Điểm thu gom
            </a>

            <!-- Active State for Verify Page -->
            <a href="#" class="flex items-center gap-3 px-4 py-3.5 text-primary bg-primary-light rounded-xl font-semibold transition-all shadow-sm ring-1 ring-primary/10">
                <span class="material-symbols-rounded">verified_user</span>
                Xác thực tài khoản
            </a>
        </nav>

        <!-- Footer -->
        <div class="p-4 border-t border-slate-50">
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-4 py-3 text-red-500 hover:bg-red-50 rounded-xl font-medium transition-colors">
                <span class="material-symbols-rounded">logout</span>
                Đăng xuất
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col overflow-hidden relative">
        <!-- Mobile Header -->
        <header class="md:hidden bg-white border-b border-slate-100 h-16 flex items-center justify-between px-4 shadow-sm z-10">
            <div class="font-bold text-primary text-xl flex items-center gap-2">
                <span class="material-symbols-rounded">spa</span> EcoGive
            </div>
            <button class="text-slate-500 p-2 rounded-lg hover:bg-slate-50">
                <span class="material-symbols-rounded">menu</span>
            </button>
        </header>

        <!-- Scrollable Area -->
        <div class="flex-1 overflow-y-auto p-4 md:p-8 lg:p-10">
            <div class="max-w-3xl mx-auto">

                <!-- Page Header -->
                <div class="mb-10 text-center md:text-left">
                    <h1 class="text-3xl font-bold text-slate-800 tracking-tight mb-2">Xác thực Doanh nghiệp</h1>
                    <p class="text-slate-500 max-w-2xl">Nâng cao uy tín thương hiệu của bạn bằng cách xác minh danh tính. Tài khoản đã xác thực sẽ nhận được dấu tích xanh và sự tin tưởng từ cộng đồng.</p>
                </div>

                <!-- Status Messages -->
                <c:if test="${not empty message}">
                    <div class="mb-6 bg-emerald-50 border border-emerald-100 text-emerald-700 p-4 rounded-xl flex items-center gap-3 shadow-sm animate-fade-in">
                        <span class="material-symbols-rounded">check_circle</span>
                        <span class="font-medium text-sm">${message}</span>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="mb-6 bg-red-50 border border-red-100 text-red-600 p-4 rounded-xl flex items-center gap-3 shadow-sm animate-shake">
                        <span class="material-symbols-rounded">error</span>
                        <span class="font-medium text-sm">${error}</span>
                    </div>
                </c:if>

                <!-- Main Content Card -->
                <div class="bg-white rounded-3xl shadow-card overflow-hidden relative">

                    <c:choose>
                        <%-- CASE 1: PENDING --%>
                        <c:when test="${user.companyVerificationStatus == 'PENDING'}">
                            <div class="p-10 text-center">
                                <div class="w-24 h-24 bg-blue-50 rounded-full flex items-center justify-center mx-auto mb-6 text-blue-500 animate-pulse">
                                    <span class="material-symbols-rounded text-5xl">hourglass_top</span>
                                </div>
                                <h2 class="text-2xl font-bold text-slate-800 mb-3">Đang chờ xét duyệt</h2>
                                <p class="text-slate-500 mb-8 max-w-md mx-auto leading-relaxed">
                                    Hồ sơ của bạn đã được gửi đi và đang trong quá trình kiểm tra. Chúng tôi sẽ phản hồi trong vòng 24-48 giờ làm việc.
                                </p>
                                <div class="bg-slate-50 rounded-xl p-4 border border-slate-100 inline-block text-left max-w-sm w-full">
                                    <div class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Tài liệu đã gửi</div>
                                    <div class="flex items-center gap-3">
                                        <div class="w-10 h-10 rounded-lg bg-white border border-slate-200 flex items-center justify-center text-red-500">
                                            <span class="material-symbols-rounded">description</span>
                                        </div>
                                        <div class="flex-1 min-w-0">
                                            <div class="text-sm font-bold text-slate-700 truncate">Giấy phép kinh doanh</div>
                                            <c:if test="${not empty user.verificationDocument}">
                                                <a href="${user.verificationDocument}" target="_blank" class="text-xs text-primary hover:underline font-medium">Xem chi tiết</a>
                                            </c:if>
                                        </div>
                                        <span class="material-symbols-rounded text-green-500 text-lg">check_circle</span>
                                    </div>
                                </div>
                            </div>
                        </c:when>

                        <%-- CASE 2: VERIFIED --%>
                        <c:when test="${user.companyVerificationStatus == 'VERIFIED'}">
                            <div class="p-10 text-center relative overflow-hidden">
                                <!-- Confetti decoration (CSS only) -->
                                <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-primary via-emerald-400 to-primary"></div>

                                <div class="w-24 h-24 bg-emerald-50 rounded-full flex items-center justify-center mx-auto mb-6 text-emerald-500 border-4 border-white shadow-lg">
                                    <span class="material-symbols-rounded text-5xl">verified</span>
                                </div>
                                <h2 class="text-2xl font-bold text-slate-800 mb-3">Tài khoản đã xác thực!</h2>
                                <p class="text-slate-500 mb-8 max-w-md mx-auto leading-relaxed">
                                    Chúc mừng! Doanh nghiệp của bạn đã được xác minh danh tính. Giờ đây bạn có thể tận hưởng đầy đủ các quyền lợi trên EcoGive.
                                </p>
                                <a href="${pageContext.request.contextPath}/dashboard/company" class="inline-flex items-center gap-2 bg-slate-800 text-white font-bold py-3 px-6 rounded-xl hover:bg-slate-700 transition-all shadow-lg shadow-slate-200">
                                    <span class="material-symbols-rounded">arrow_back</span>
                                    Quay lại Dashboard
                                </a>
                            </div>
                        </c:when>

                        <%-- CASE 3: NOT VERIFIED (Form) --%>
                        <c:otherwise>
                            <div class="p-8 md:p-10">
                                <form action="${pageContext.request.contextPath}/verify-company" method="post" enctype="multipart/form-data">
                                    <div class="space-y-8">
                                        <!-- Step 1 -->
                                        <div>
                                            <div class="flex items-center gap-3 mb-4">
                                                <div class="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center font-bold text-sm">1</div>
                                                <h3 class="font-bold text-slate-800 text-lg">Tải lên tài liệu</h3>
                                            </div>

                                            <label for="documentImage" class="group relative block w-full border-2 border-slate-300 border-dashed rounded-2xl p-10 text-center hover:bg-slate-50 hover:border-primary/50 transition-all cursor-pointer">
                                                <input id="documentImage" name="documentImage" type="file" class="sr-only" accept="image/*" required onchange="previewFile(this)">

                                                <div id="upload-placeholder" class="space-y-2">
                                                    <div class="w-16 h-16 bg-slate-100 text-slate-400 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300 group-hover:bg-primary-light group-hover:text-primary">
                                                        <span class="material-symbols-rounded text-3xl">cloud_upload</span>
                                                    </div>
                                                    <div class="text-sm font-medium text-slate-700">
                                                        <span class="text-primary font-bold hover:underline">Nhấn để tải lên</span> hoặc kéo thả vào đây
                                                    </div>
                                                    <p class="text-xs text-slate-400">Hỗ trợ: PNG, JPG, PDF (Tối đa 10MB)</p>
                                                </div>

                                                <!-- Preview Area (Hidden by default) -->
                                                <div id="file-preview" class="hidden flex items-center justify-center gap-3 bg-white p-2 rounded-xl shadow-sm border border-slate-100">
                                                    <span class="material-symbols-rounded text-primary">image</span>
                                                    <span id="file-name" class="text-sm font-bold text-slate-700 truncate max-w-[200px]">filename.jpg</span>
                                                    <span class="text-xs text-slate-400" id="file-size">(0 MB)</span>
                                                </div>
                                            </label>
                                        </div>

                                        <!-- Step 2 -->
                                        <div>
                                            <div class="flex items-center gap-3 mb-4">
                                                <div class="w-8 h-8 rounded-full bg-slate-200 text-slate-600 flex items-center justify-center font-bold text-sm">2</div>
                                                <h3 class="font-bold text-slate-800 text-lg">Xác nhận thông tin</h3>
                                            </div>
                                            <div class="bg-slate-50 p-4 rounded-xl text-sm text-slate-600 border border-slate-100">
                                                <p class="flex gap-2 mb-2">
                                                    <span class="material-symbols-rounded text-primary text-lg">check</span>
                                                    Tôi cam kết các thông tin và tài liệu cung cấp là chính xác.
                                                </p>
                                                <p class="flex gap-2">
                                                    <span class="material-symbols-rounded text-primary text-lg">check</span>
                                                    Tôi đồng ý với các điều khoản sử dụng dành cho Đối tác Doanh nghiệp.
                                                </p>
                                            </div>
                                        </div>

                                        <div class="pt-4 border-t border-slate-100 flex justify-end">
                                            <button type="submit" class="bg-primary hover:bg-primary-hover text-white font-bold py-3 px-8 rounded-xl shadow-lg shadow-primary/20 transition-all transform hover:-translate-y-1 active:scale-95 flex items-center gap-2">
                                                <span>Gửi yêu cầu xác thực</span>
                                                <span class="material-symbols-rounded">send</span>
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    function previewFile(input) {
        const placeholder = document.getElementById('upload-placeholder');
        const preview = document.getElementById('file-preview');
        const fileName = document.getElementById('file-name');
        const fileSize = document.getElementById('file-size');

        if (input.files && input.files[0]) {
            const file = input.files[0];
            placeholder.classList.add('hidden');
            preview.classList.remove('hidden');
            preview.classList.add('flex');

            fileName.textContent = file.name;
            fileSize.textContent = '(' + (file.size / 1024 / 1024).toFixed(2) + ' MB)';
        }
    }
</script>

</body>
</html>