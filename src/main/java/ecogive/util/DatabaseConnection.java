package ecogive.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static String url;
    private static String username;
    private static String password;

    static {
        try {
            // Load config using EnvUtils (supports both .env and System Env)
            url = EnvUtils.get("DB_URL");
            username = EnvUtils.get("DB_USERNAME");
            password = EnvUtils.get("DB_PASSWORD");
            String driver = EnvUtils.get("DB_DRIVER");

            // Default driver if not specified
            if (driver == null || driver.isEmpty()) {
                driver = "com.mysql.cj.jdbc.Driver";
            }

            System.out.println("[DatabaseConnection] DB_URL: " + url);
            System.out.println("[DatabaseConnection] DB_USERNAME: " + username);

            if (url == null || username == null || password == null) {
                throw new Exception("Missing database configuration (DB_URL, DB_USERNAME, DB_PASSWORD).");
            }

            // Append useful connection properties for MySQL
            if (url.contains("mysql") && !url.contains("?")) {
                url += "?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true&connectTimeout=10000&socketTimeout=10000";
            }

            Class.forName(driver);
            System.out.println("Database driver loaded successfully.");

        } catch (Exception e) {
            System.err.println("FATAL: Failed to initialize database connection.");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        if (url == null) {
            throw new SQLException("Database URL is null. Configuration failed.");
        }
        return DriverManager.getConnection(url, username, password);
    }
}
