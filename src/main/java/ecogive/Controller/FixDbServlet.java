package ecogive.Controller;

import ecogive.util.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet("/fix-db")
public class FixDbServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            resp.getWriter().write("<h2>🛠️ Database Fix Tool</h2>");

            // 1. Kiểm tra bảng messages
            resp.getWriter().write("<h3>1. Checking table 'messages'...</h3>");
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet rsColumns = meta.getColumns(null, null, "messages", "image_url");
            
            if (rsColumns.next()) {
                resp.getWriter().write("<p style='color:green'>✅ Column 'image_url' already exists.</p>");
            } else {
                resp.getWriter().write("<p style='color:orange'>⚠️ Column 'image_url' missing. Adding...</p>");
                try {
                    stmt.executeUpdate("ALTER TABLE messages ADD COLUMN image_url VARCHAR(255) NULL");
                    resp.getWriter().write("<p style='color:green'>✅ Added 'image_url' successfully.</p>");
                } catch (Exception e) {
                    resp.getWriter().write("<p style='color:red'>❌ Failed to add 'image_url': " + e.getMessage() + "</p>");
                }
            }

            // 2. Cập nhật ENUM status cho bảng transactions (THÊM TRẠNG THÁI MỚI)
            resp.getWriter().write("<h3>2. Updating 'transactions' status ENUM...</h3>");
            String sqlUpdateEnum = "ALTER TABLE transactions MODIFY COLUMN status " +
                    "ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELED', " +
                    "'PENDING_TRADE', 'WAITING_ADMIN_APPROVAL', 'TRADE_APPROVED', 'TRADE_REJECTED', " +
                    "'CONFIRMED_BY_A', 'CONFIRMED_BY_B') " +
                    "DEFAULT 'PENDING'";
            try {
                stmt.executeUpdate(sqlUpdateEnum);
                resp.getWriter().write("<p style='color:green'>✅ Updated ENUM status (Added ADMIN APPROVAL states).</p>");
            } catch (Exception e) {
                resp.getWriter().write("<p style='color:red'>❌ Failed to update ENUM: " + e.getMessage() + "</p>");
            }

            // 3. Thêm cột transaction_type
            resp.getWriter().write("<h3>3. Checking 'transactions' columns...</h3>");
            
            // Check transaction_type
            ResultSet rsType = meta.getColumns(null, null, "transactions", "transaction_type");
            if (rsType.next()) {
                resp.getWriter().write("<p style='color:green'>✅ Column 'transaction_type' exists.</p>");
            } else {
                try {
                    stmt.executeUpdate("ALTER TABLE transactions ADD COLUMN transaction_type ENUM('GIVE', 'TRADE') DEFAULT 'GIVE'");
                    resp.getWriter().write("<p style='color:green'>✅ Added 'transaction_type'.</p>");
                } catch (Exception e) {
                    resp.getWriter().write("<p style='color:red'>❌ Failed to add 'transaction_type': " + e.getMessage() + "</p>");
                }
            }

            // Check offer_item_id
            ResultSet rsOffer = meta.getColumns(null, null, "transactions", "offer_item_id");
            if (rsOffer.next()) {
                resp.getWriter().write("<p style='color:green'>✅ Column 'offer_item_id' exists.</p>");
            } else {
                try {
                    stmt.executeUpdate("ALTER TABLE transactions ADD COLUMN offer_item_id BIGINT NULL");
                    stmt.executeUpdate("ALTER TABLE transactions ADD CONSTRAINT fk_offer_item FOREIGN KEY (offer_item_id) REFERENCES items(item_id) ON DELETE SET NULL");
                    resp.getWriter().write("<p style='color:green'>✅ Added 'offer_item_id' & FK.</p>");
                } catch (Exception e) {
                    resp.getWriter().write("<p style='color:red'>❌ Failed to add 'offer_item_id': " + e.getMessage() + "</p>");
                }
            }
            
            resp.getWriter().write("<hr>");
            resp.getWriter().write("<a href='" + req.getContextPath() + "/home'>🏠 Về trang chủ</a>");

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("<h1>❌ Lỗi kết nối DB</h1>");
            resp.getWriter().write("<p>" + e.getMessage() + "</p>");
        }
    }
}
