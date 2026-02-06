package ecogive.Controller;

import ecogive.Model.User;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/leaderboard")
public class LeaderboardApiServlet extends HttpServlet {
    private UserDAO userDAO;
    private Gson gson;

    @Override
    public void init() {
        userDAO = new UserDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            List<User> topUsers = userDAO.getTopUsers(10);
            List<Map<String, Object>> result = new ArrayList<>();

            for (User user : topUsers) {
                Map<String, Object> map = new HashMap<>();
                map.put("userId", user.getUserId());
                map.put("username", user.getUsername());
                map.put("ecoPoints", user.getEcoPoints());
                map.put("reputationScore", user.getReputationScore());
                result.add(map);
            }

            response.getWriter().write(gson.toJson(result));
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Database error\"}");
        }
    }
}
