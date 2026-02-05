package ecogive.util;

import io.github.cdimascio.dotenv.Dotenv;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtility {
    private static final String HOST = "smtp.gmail.com";
    private static final String PORT = "587";
    
    // Tải biến môi trường
    private static final Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
    private static final String USERNAME = dotenv.get("EMAIL_USERNAME");
    private static final String PASSWORD = dotenv.get("EMAIL_PASSWORD");

    public static void sendEmail(String toAddress, String subject, String messageContent) throws MessagingException {
        if (USERNAME == null || PASSWORD == null) {
            System.err.println("Email configuration is missing in .env file");
            throw new MessagingException("Server configuration error: Email credentials missing.");
        }

        // Thiết lập thuộc tính SMTP
        Properties properties = new Properties();
        properties.put("mail.smtp.host", HOST);
        properties.put("mail.smtp.port", PORT);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        // Tạo phiên làm việc với xác thực
        Authenticator auth = new Authenticator() {
            public PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        };

        Session session = Session.getInstance(properties, auth);

        // Tạo tin nhắn email
        MimeMessage msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(USERNAME));
        InternetAddress[] toAddresses = { new InternetAddress(toAddress) };
        msg.setRecipients(Message.RecipientType.TO, toAddresses);
        
        // Sửa lỗi font chữ tiêu đề bằng cách chỉ định charset UTF-8
        msg.setSubject(subject, "UTF-8");

        msg.setSentDate(new java.util.Date());
        msg.setContent(messageContent, "text/html; charset=UTF-8");

        // Gửi email
        Transport.send(msg);
    }
}
