<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setBundle basename="messages" scope="session" />

<!DOCTYPE html>
<html lang="${sessionScope.lang != null ? sessionScope.lang : 'vi'}">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="admin.types.title" /> - EcoGive Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style> body { font-family: 'Inter', sans-serif; } </style>
</head>
<body class="bg-slate-50 text-slate-800 antialiased">

<jsp:include page="sidebar.jsp" />

<main class="md:ml-64 min-h-screen transition-all duration-300 flex flex-col">
    <header class="bg-white border-b border-slate-200 sticky top-0 z-10 px-8 py-4 flex justify-between items-center shadow-sm">
        <div>
            <h1 class="text-2xl font-bold text-slate-800 tracking-tight"><fmt:message key="admin.types.title" /></h1>
            <p class="text-sm text-slate-500 mt-1"><fmt:message key="admin.types.subtitle" /></p>
        </div>
    </header>

    <div class="p-8 max-w-6xl mx-auto w-full grid grid-cols-1 lg:grid-cols-3 gap-8">

        <!-- Left Column: Form -->
        <div class="lg:col-span-1">
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 sticky top-24">
                <h3 id="form-title" class="text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
                    <span class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm">✨</span>
                    <fmt:message key="admin.types.add_modal" />
                </h3>

                <form id="type-form" action="${pageContext.request.contextPath}/admin" method="POST" class="space-y-4">
                    <input type="hidden" id="form-action" name="action" value="add-station-type">
                    <input type="hidden" id="is-update" value="false">

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5"><fmt:message key="admin.types.code" /> <span class="text-red-500">*</span></label>
                        <input type="text" id="code" name="code" required
                               class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400 uppercase font-mono"
                               placeholder="VD: PLASTIC">
                        <p class="text-[10px] text-slate-400 mt-1"><fmt:message key="admin.types.help_code" /></p>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5"><fmt:message key="admin.types.name" /> <span class="text-red-500">*</span></label>
                        <fmt:message key="admin.types.placeholder_name" var="typeNamePlaceholder" />
                        <input type="text" id="name" name="name" required
                               class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                               placeholder="${typeNamePlaceholder}">
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5"><fmt:message key="admin.types.icon" /></label>
                        <input type="text" id="icon" name="icon"
                               class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                               placeholder="VD: ♻️">
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-1.5"><fmt:message key="admin.types.desc" /></label>
                        <fmt:message key="admin.types.placeholder_desc" var="typeDescPlaceholder" />
                        <textarea id="description" name="description" rows="3"
                                  class="w-full rounded-xl border-slate-200 bg-slate-50 px-4 py-2.5 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 transition-all placeholder:text-slate-400"
                                  placeholder="${typeDescPlaceholder}"></textarea>
                    </div>

                    <div class="pt-2 flex gap-2">
                        <button id="cancel-button" type="button" onclick="cancelEdit()" class="hidden flex-1 px-4 py-2.5 rounded-xl text-sm font-semibold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">
                            <fmt:message key="admin.common.cancel" />
                        </button>
                        <button id="submit-button" type="submit" class="flex-1 px-4 py-2.5 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 shadow-lg shadow-emerald-200 transition-all active:scale-95">
                            <fmt:message key="admin.common.add" />
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Right Column: List -->
        <div class="lg:col-span-2">
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
                    <h2 class="font-bold text-slate-700"><fmt:message key="admin.types.list_title" /></h2>
                    <fmt:message key="admin.types.count" var="typeCount">
                        <fmt:param value="${types.size()}" />
                    </fmt:message>
                    <span class="text-xs font-bold text-slate-500 bg-white border border-slate-200 px-2.5 py-1 rounded-lg shadow-sm">${typeCount}</span>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-slate-50 text-slate-500 text-xs uppercase font-bold tracking-wider">
                        <tr>
                            <th class="px-6 py-4 border-b border-slate-100"><fmt:message key="admin.types.code" /></th>
                            <th class="px-6 py-4 border-b border-slate-100"><fmt:message key="admin.types.name" /></th>
                            <th class="px-6 py-4 border-b border-slate-100"><fmt:message key="admin.types.desc" /></th>
                            <th class="px-6 py-4 border-b border-slate-100 text-right"><fmt:message key="admin.common.action" /></th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-sm">
                        <c:forEach var="t" items="${types}">
                            <tr class="group hover:bg-slate-50 transition-colors">
                                <td class="px-6 py-4 font-mono text-xs font-bold text-slate-500">${t.typeCode}</td>
                                <td class="px-6 py-4 font-semibold text-slate-800">
                                    <span class="mr-2">${t.icon}</span>
                                    <!-- SỬA ĐỔI: Dùng fmt:message với prefix type. -->
                                    <c:set var="typeKey" value="type.${t.typeCode}" />
                                    <fmt:message key="${typeKey}" var="translatedType" />
                                    <c:out value="${!fn:contains(translatedType, '???') ? translatedType : t.displayName}" />
                                </td>
                                <td class="px-6 py-4 text-slate-500 text-xs max-w-xs truncate">
                                    ${t.description}
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button onclick="editType('${t.typeCode}', '${t.displayName}', '${t.icon}', '${t.description}')"
                                                class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="<fmt:message key='admin.common.edit' />">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                        </button>

                                        <fmt:message key="admin.common.confirm_delete" var="confirmDelete" />
                                        <a href="${pageContext.request.contextPath}/admin?action=delete-station-type&code=${t.typeCode}"
                                           class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="<fmt:message key='admin.common.delete' />"
                                           onclick="return confirm('${confirmDelete}');">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty types}">
                            <tr>
                                <td colspan="4" class="px-6 py-12 text-center text-slate-400 italic">
                                    <div class="flex flex-col items-center">
                                        <span class="text-2xl mb-2 opacity-50">🗂️</span>
                                        <span><fmt:message key="admin.common.no_data" /></span>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    function editType(code, name, icon, desc) {
        document.getElementById('form-action').value = 'update-station-type';
        document.getElementById('is-update').value = 'true';

        const codeInput = document.getElementById('code');
        codeInput.value = code;
        codeInput.readOnly = true;
        codeInput.classList.add('bg-slate-100', 'text-slate-500');

        document.getElementById('name').value = name;
        document.getElementById('icon').value = icon;
        document.getElementById('description').value = desc;

        // UI Updates
        document.getElementById('form-title').innerHTML = '<span class="w-8 h-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center text-sm">✏️</span> <fmt:message key="admin.types.edit_modal" />';
        const btn = document.getElementById('submit-button');
        btn.innerText = '<fmt:message key="admin.common.save" />';
        btn.classList.remove('bg-emerald-600', 'hover:bg-emerald-700', 'shadow-emerald-200');
        btn.classList.add('bg-blue-600', 'hover:bg-blue-700', 'shadow-blue-200');

        document.getElementById('cancel-button').classList.remove('hidden');
        document.getElementById('name').focus();
    }

    function cancelEdit() {
        document.getElementById('form-action').value = 'add-station-type';
        document.getElementById('is-update').value = 'false';
        document.getElementById('type-form').reset();

        const codeInput = document.getElementById('code');
        codeInput.readOnly = false;
        codeInput.classList.remove('bg-slate-100', 'text-slate-500');

        // UI Reset
        document.getElementById('form-title').innerHTML = '<span class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-600 flex items-center justify-center text-sm">✨</span> <fmt:message key="admin.types.add_modal" />';
        const btn = document.getElementById('submit-button');
        btn.innerText = '<fmt:message key="admin.common.add" />';
        btn.classList.add('bg-emerald-600', 'hover:bg-emerald-700', 'shadow-emerald-200');
        btn.classList.remove('bg-blue-600', 'hover:bg-blue-700', 'shadow-blue-200');

        document.getElementById('cancel-button').classList.add('hidden');
    }
</script>

</body>
</html>