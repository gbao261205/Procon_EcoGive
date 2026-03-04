<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setBundle basename="messages" scope="session" />

<!DOCTYPE html>
<html lang="${sessionScope.lang != null ? sessionScope.lang : 'vi'}">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="admin.rewards.title" /> - EcoGive Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <style>
        body { font-family: 'Inter', sans-serif; }
        .custom-scrollbar::-webkit-scrollbar { height: 6px; width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: #f1f5f9; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#05976a',
                        'primary-hover': '#047857',
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-slate-50 text-slate-600">

<div class="flex h-screen overflow-hidden">
    <!-- Sidebar -->
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <!-- Main Content -->
    <div class="flex-1 flex flex-col md:ml-64 transition-all duration-300">
        <!-- Header -->
        <header class="bg-white border-b border-slate-200 h-16 flex items-center justify-between px-6 md:px-8 shrink-0">
            <div class="flex items-center gap-4">
                <button class="md:hidden text-slate-500 hover:text-slate-700">
                    <span class="material-symbols-outlined">menu</span>
                </button>
                <h1 class="text-xl font-bold text-slate-800"><fmt:message key="admin.rewards.title" /></h1>
            </div>
            <div class="flex items-center gap-4">
                <div class="text-right hidden sm:block">
                    <div class="text-sm font-bold text-slate-800">Admin</div>
                    <div class="text-xs text-slate-500">System Administrator</div>
                </div>
                <div class="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 font-bold">A</div>
            </div>
        </header>

        <!-- Content -->
        <main class="flex-1 overflow-y-auto p-6 md:p-8 custom-scrollbar">
            <!-- Actions -->
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
                <div class="relative w-full sm:w-64">
                    <span class="absolute left-3 top-2.5 text-slate-400 material-symbols-outlined text-lg">search</span>
                    <fmt:message key="admin.common.search" var="searchPlaceholder" />
                    <input type="text" placeholder="${searchPlaceholder}" class="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-primary outline-none text-sm">
                </div>
                <button onclick="openAddModal()" class="flex items-center gap-2 px-4 py-2 bg-primary text-white text-sm font-bold rounded-lg hover:bg-primary-hover transition shadow-sm">
                    <span class="material-symbols-outlined text-lg">add</span>
                    <fmt:message key="admin.common.add" />
                </button>
            </div>

            <!-- Table -->
            <div class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider border-b border-slate-200">
                            <tr>
                                <th class="px-6 py-4">ID</th>
                                <th class="px-6 py-4"><fmt:message key="admin.rewards.image" /></th>
                                <th class="px-6 py-4"><fmt:message key="admin.rewards.name" /></th>
                                <th class="px-6 py-4"><fmt:message key="admin.rewards.cost" /></th>
                                <th class="px-6 py-4"><fmt:message key="admin.rewards.stock" /></th>
                                <th class="px-6 py-4"><fmt:message key="admin.rewards.type" /></th>
                                <th class="px-6 py-4"><fmt:message key="admin.rewards.status" /></th>
                                <th class="px-6 py-4 text-right"><fmt:message key="admin.common.action" /></th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-sm">
                            <c:forEach var="r" items="${rewards}">
                                <tr class="hover:bg-slate-50 transition-colors group">
                                    <td class="px-6 py-4 font-mono text-slate-400">#${r.rewardId}</td>
                                    <td class="px-6 py-4">
                                        <div class="w-12 h-12 rounded-lg bg-slate-100 overflow-hidden border border-slate-200">
                                            <img src="${r.imageUrl}" class="w-full h-full object-cover" onerror="this.src='https://placehold.co/100x100?text=No+Image'">
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 font-bold text-slate-700">${r.name}</td>
                                    <td class="px-6 py-4 font-bold text-emerald-600">${r.pointCost}</td>
                                    <td class="px-6 py-4">
                                        <span class="${r.stock > 0 ? 'text-slate-700' : 'text-red-500 font-bold'}">${r.stock}</span>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2 py-1 rounded text-xs font-bold ${r.type == 'ADMIN' ? 'bg-blue-50 text-blue-700' : 'bg-purple-50 text-purple-700'}">
                                            ${r.type}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2 py-1 rounded-full text-xs font-bold
                                            ${r.status == 'APPROVED' ? 'bg-green-50 text-green-700 border border-green-200' :
                                              (r.status == 'PENDING' ? 'bg-yellow-50 text-yellow-700 border border-yellow-200' : 'bg-red-50 text-red-700 border border-red-200')}">
                                            ${r.status}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-right">
                                        <div class="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <button onclick="openEditModal(${r.rewardId}, '${r.name}', '${r.description}', ${r.pointCost}, ${r.stock}, '${r.type}', '${r.sponsorName}', '${r.status}', '${r.imageUrl}')"
                                                    class="p-1.5 text-blue-600 hover:bg-blue-50 rounded-lg transition" title="<fmt:message key='admin.common.edit' />">
                                                <span class="material-symbols-outlined text-lg">edit</span>
                                            </button>
                                            <button onclick="deleteReward(${r.rewardId})"
                                                    class="p-1.5 text-red-600 hover:bg-red-50 rounded-lg transition" title="<fmt:message key='admin.common.delete' />">
                                                <span class="material-symbols-outlined text-lg">delete</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty rewards}">
                                <tr>
                                    <td colspan="8" class="text-center py-12 text-slate-400"><fmt:message key="admin.common.no_data" /></td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Modal Thêm/Sửa -->
<div id="rewardModal" class="fixed inset-0 hidden bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
    <div class="bg-white rounded-2xl w-full max-w-lg shadow-2xl flex flex-col max-h-[90vh] overflow-hidden animate-fade-in">
        <div class="p-5 border-b border-slate-100 flex justify-between items-center bg-white shrink-0">
            <h3 class="font-bold text-xl text-slate-800" id="modalTitle"><fmt:message key="admin.rewards.add_modal" /></h3>
            <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600 p-1 rounded-full hover:bg-slate-100 transition">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>

        <div class="p-6 overflow-y-auto custom-scrollbar space-y-4">
            <form id="rewardForm" class="space-y-4">
                <input type="hidden" id="rewardId" name="id">

                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.name" /></label>
                    <input type="text" id="rewardName" name="name" required class="w-full px-3 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary outline-none transition">
                </div>

                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.desc" /></label>
                    <textarea id="rewardDesc" name="description" rows="3" class="w-full px-3 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary outline-none transition resize-none"></textarea>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.cost" /></label>
                        <input type="number" id="rewardCost" name="pointCost" required class="w-full px-3 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary outline-none transition">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.stock" /></label>
                        <input type="number" id="rewardStock" name="stock" required class="w-full px-3 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary outline-none transition">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.type" /></label>
                        <select id="rewardType" name="type" class="w-full px-3 py-2 border border-slate-200 rounded-lg bg-white focus:ring-2 focus:ring-primary outline-none transition">
                            <option value="ADMIN">ADMIN (Hệ thống)</option>
                            <option value="SPONSOR">SPONSOR (Tài trợ)</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.status" /></label>
                        <select id="rewardStatus" name="status" class="w-full px-3 py-2 border border-slate-200 rounded-lg bg-white focus:ring-2 focus:ring-primary outline-none transition">
                            <option value="APPROVED">Đang hiển thị</option>
                            <option value="HIDDEN">Ẩn</option>
                            <option value="PENDING">Chờ duyệt</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.sponsor" /></label>
                    <input type="text" id="rewardSponsor" name="sponsorName" class="w-full px-3 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary outline-none transition">
                </div>

                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1"><fmt:message key="admin.rewards.image" /></label>
                    <input type="file" id="rewardImage" name="image" accept="image/*" class="w-full px-3 py-2 border border-slate-200 rounded-lg file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-emerald-50 file:text-primary hover:file:bg-emerald-100 transition">
                    <div id="previewContainer" class="mt-2 hidden">
                        <img id="imagePreview" src="" class="h-20 w-20 object-cover rounded-lg border border-slate-200">
                    </div>
                </div>
            </form>
        </div>

        <div class="p-5 border-t border-slate-100 bg-slate-50 flex justify-end gap-3 shrink-0">
            <button onclick="closeModal()" class="px-4 py-2 text-sm font-bold text-slate-600 hover:bg-slate-200 rounded-lg transition"><fmt:message key="admin.common.cancel" /></button>
            <button onclick="saveReward()" class="px-4 py-2 text-sm font-bold text-white bg-primary hover:bg-primary-hover rounded-lg transition shadow-sm"><fmt:message key="admin.common.save" /></button>
        </div>
    </div>
</div>

<script>
    let isEditMode = false;

    function openAddModal() {
        isEditMode = false;
        document.getElementById('modalTitle').innerText = "<fmt:message key='admin.rewards.add_modal' />";
        document.getElementById('rewardForm').reset();
        document.getElementById('rewardId').value = "";
        document.getElementById('previewContainer').classList.add('hidden');
        document.getElementById('rewardModal').classList.remove('hidden');
    }

    function openEditModal(id, name, desc, cost, stock, type, sponsor, status, imgUrl) {
        isEditMode = true;
        document.getElementById('modalTitle').innerText = "<fmt:message key='admin.rewards.edit_modal' />";

        document.getElementById('rewardId').value = id;
        document.getElementById('rewardName').value = name;
        document.getElementById('rewardDesc').value = desc;
        document.getElementById('rewardCost').value = cost;
        document.getElementById('rewardStock').value = stock;
        document.getElementById('rewardType').value = type;
        document.getElementById('rewardSponsor').value = sponsor === 'null' ? '' : sponsor;
        document.getElementById('rewardStatus').value = status;

        if (imgUrl && imgUrl !== 'null') {
            document.getElementById('imagePreview').src = imgUrl;
            document.getElementById('previewContainer').classList.remove('hidden');
        } else {
            document.getElementById('previewContainer').classList.add('hidden');
        }

        document.getElementById('rewardModal').classList.remove('hidden');
    }

    function closeModal() {
        document.getElementById('rewardModal').classList.add('hidden');
    }

    async function saveReward() {
        const form = document.getElementById('rewardForm');
        const formData = new FormData(form);

        // Append action
        formData.append('action', isEditMode ? 'update' : 'add');

        try {
            const res = await fetch('${pageContext.request.contextPath}/admin/rewards', {
                method: 'POST',
                body: formData
            });
            const data = await res.json();

            if (data.status === 'success') {
                alert(data.message);
                location.reload();
            } else {
                alert("Lỗi: " + data.message);
            }
        } catch (e) {
            console.error(e);
            alert("Lỗi kết nối server!");
        }
    }

    async function deleteReward(id) {
        if (!confirm("<fmt:message key='admin.common.confirm_delete' />")) return;

        const formData = new FormData();
        formData.append('action', 'delete');
        formData.append('id', id);

        try {
            const res = await fetch('${pageContext.request.contextPath}/admin/rewards', {
                method: 'POST',
                body: formData
            });
            const data = await res.json();

            if (data.status === 'success') {
                alert(data.message);
                location.reload();
            } else {
                alert("Lỗi: " + data.message);
            }
        } catch (e) {
            console.error(e);
            alert("Lỗi kết nối server!");
        }
    }
</script>

</body>
</html>
