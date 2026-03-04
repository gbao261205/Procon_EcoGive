package ecogive.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;

@WebServlet("/language")
public class LanguageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String lang = request.getParameter("lang");
        if (lang != null && (lang.equals("vi") || lang.equals("en"))) {
            HttpSession session = request.getSession();
            session.setAttribute("lang", lang);
            
            // Cập nhật Locale cho JSTL fmt
            // Lưu ý: Sử dụng đúng package jakarta.servlet.jsp.jstl.core
            Locale locale = new Locale(lang);
            jakarta.servlet.jsp.jstl.core.Config.set(session, jakarta.servlet.jsp.jstl.core.Config.FMT_LOCALE, locale);
        }
        
        // Quay lại trang trước đó
        String referer = request.getHeader("Referer");
        response.sendRedirect(referer != null ? referer : request.getContextPath() + "/");
    }
}