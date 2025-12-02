package ecogive.filter;

import ecogive.Model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/admin/*")
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        boolean isAuthorized = false;

        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");

            if ("ADMIN".equals(user.getRole())) {
                isAuthorized = true;
            }
        }

        if (isAuthorized) {
            chain.doFilter(request, response);
        } else {
            // Nếu không phải admin -> Đẩy về trang Login hoặc trang Lỗi 403
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
}