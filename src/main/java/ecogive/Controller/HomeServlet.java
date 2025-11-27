package ecogive.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/")
public class HomeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if the user is logged in
        if (session == null || session.getAttribute("currentUser") == null) {
            // If not logged in, redirect to the login page
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // If logged in, forward to the home page view
        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}
