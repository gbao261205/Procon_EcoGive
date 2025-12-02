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
            // Load .env file from the project root.
            // Dotenv will automatically search for it.
            dotenv = Dotenv.load();

            System.out.println("Attempting to load database configuration from .env file...");

            url = dotenv.get("DB_URL");
            username = dotenv.get("DB_USERNAME");
            password = dotenv.get("DB_PASSWORD");
            String driver = dotenv.get("DB_DRIVER");

            // --- Diagnostic Logging ---
            System.out.println("DB_URL: " + url);
            System.out.println("DB_USERNAME: " + username);
            System.out.println("DB_DRIVER: " + driver);

            if (url == null || username == null || password == null || driver == null) {
                System.err.println("ERROR: One or more required database variables are missing. Check your .env file and its location.");
                throw new Exception("Missing database configuration.");
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
