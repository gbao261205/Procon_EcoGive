package ecogive.util;

import io.github.cdimascio.dotenv.Dotenv;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static String url;
    private static String username;
    private static String password;
    private static Dotenv dotenv;

    static {
        try {
            // Print working directory for diagnostics (helps locate .env at runtime)
            String userDir = System.getProperty("user.dir");
            System.out.println("[DatabaseConnection] user.dir=" + userDir);

            // Try to load .env if present, but don't fail if missing - we'll fallback to other sources
            dotenv = Dotenv.configure().ignoreIfMissing().load();
            System.out.println("[DatabaseConnection] Attempting to load database configuration from .env (if present)...");

            // First try dotenv values
            url = (dotenv != null) ? dotenv.get("DB_URL") : null;
            username = (dotenv != null) ? dotenv.get("DB_USERNAME") : null;
            password = (dotenv != null) ? dotenv.get("DB_PASSWORD") : null;
            String driver = (dotenv != null) ? dotenv.get("DB_DRIVER") : null;

            // If any required value is missing, fallback to OS environment variables
            if (url == null) url = System.getenv("DB_URL");
            if (username == null) username = System.getenv("DB_USERNAME");
            if (password == null) password = System.getenv("DB_PASSWORD");
            if (driver == null) driver = System.getenv("DB_DRIVER");

            // Also try common Tomcat system property / env (useful when running under Tomcat)
            if (url == null) {
                String catalinaBase = System.getProperty("catalina.base");
                if (catalinaBase == null) catalinaBase = System.getenv("CATALINA_BASE");
                if (catalinaBase != null) {
                    java.io.File f = new java.io.File(catalinaBase, ".env");
                    if (f.exists()) {
                        System.out.println("[DatabaseConnection] Found .env under catalina.base: " + f.getAbsolutePath());
                        Dotenv alt = Dotenv.configure().directory(f.getParent()).filename(f.getName()).load();
                        url = (url == null) ? alt.get("DB_URL") : url;
                        username = (username == null) ? alt.get("DB_USERNAME") : username;
                        password = (password == null) ? alt.get("DB_PASSWORD") : password;
                        driver = (driver == null) ? alt.get("DB_DRIVER") : driver;
                    }
                }
            }

            // --- Diagnostic Logging ---
            System.out.println("[DatabaseConnection] DB_URL: " + url);
            System.out.println("[DatabaseConnection] DB_USERNAME: " + username);
            System.out.println("[DatabaseConnection] DB_DRIVER: " + (driver != null ? driver : "(null)"));

            if (url == null || username == null || password == null || driver == null) {
                System.err.println("ERROR: One or more required database variables are missing. Check your .env file, environment vars, or Tomcat config.");
                throw new Exception("Missing database configuration.");
            }

            // Append useful connection properties if not present
            if (url.contains("mysql")) {
                if (!url.contains("?")) {
                    url += "?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true&connectTimeout=10000&socketTimeout=10000";
                } else {
                    if (!url.contains("autoReconnect")) url += "&autoReconnect=true";
                    if (!url.contains("useSSL")) url += "&useSSL=false";
                    if (!url.contains("allowPublicKeyRetrieval")) url += "&allowPublicKeyRetrieval=true";
                    if (!url.contains("connectTimeout")) url += "&connectTimeout=10000";
                    if (!url.contains("socketTimeout")) url += "&socketTimeout=10000";
                }
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
            throw new SQLException("Database URL is null. Configuration failed. Ensure the .env file is in the project root.");
        }
        return DriverManager.getConnection(url, username, password);
    }
}
