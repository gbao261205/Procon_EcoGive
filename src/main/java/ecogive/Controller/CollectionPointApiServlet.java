package ecogive.Controller;

import com.google.gson.Gson;
import ecogive.Model.CollectionPoint;
import ecogive.dao.CollectionPointDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/collection-points")
public class CollectionPointApiServlet extends HttpServlet {

    private final CollectionPointDAO stationDAO = new CollectionPointDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            List<CollectionPoint> points = stationDAO.findAll();

            List<StationDTO> dtos = new ArrayList<>();
            for (CollectionPoint p : points) {
                dtos.add(new StationDTO(p));
            }

            resp.getWriter().write(new Gson().toJson(dtos));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // Sửa DTO để thêm ownerRole
    private static class StationDTO {
        long pointId;
        String name;
        String type;
        String address;
        double latitude;
        double longitude;
        String ownerRole; // Thêm trường này

        public StationDTO(CollectionPoint p) {
            this.pointId = p.getPointId();
            this.name = p.getName();
            this.type = p.getType().name();
            this.address = p.getAddress();
            this.ownerRole = p.getOwnerRole(); // Lấy dữ liệu từ model
            if (p.getLocation() != null) {
                this.latitude = p.getLocation().getLatitude();
                this.longitude = p.getLocation().getLongitude();
            }
        }
    }
}
