package ecogive.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get the current session, but don't create a new one if it doesn't exist.
        HttpSession session = request.getSession(false);

        if (session != null) {
            // Invalidate the session, which removes all attributes bound to it.
            session.invalidate();
        }

        // Redirect the user to the login page.
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
