package ecogive.filter;

import ecogive.Model.Role;
import ecogive.Model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

// Middleware bảo vệ các route của doanh nghiệp
@WebFilter(urlPatterns = {"/company/*", "/dashboard/company"})
public class CompanyFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        boolean isAuthorized = false;

        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            // Chỉ cho phép Role COLLECTOR_COMPANY
            if (user.getRole() == Role.COLLECTOR_COMPANY) {
                isAuthorized = true;
            }
        }

        if (isAuthorized) {
            chain.doFilter(request, response);
        } else {
            // Nếu là request API (AJAX) trả về JSON lỗi
            String path = req.getRequestURI();
            if (path.contains("/api/") || path.contains("/company/collect-point/")) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"status\":\"error\", \"message\":\"Truy cập bị từ chối. Yêu cầu quyền Doanh nghiệp.\"}");
            } else {
                // Nếu là request trang thường -> Redirect login
                resp.sendRedirect(req.getContextPath() + "/login");
            }
        }
    }
}
