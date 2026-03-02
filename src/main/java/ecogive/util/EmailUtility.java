package ecogive.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtility {
    private static final String HOST = "smtp.gmail.com";
    private static final String PORT = "587";
    
    private static final String USERNAME = EnvUtils.get("EMAIL_USERNAME");
    private static final String PASSWORD = EnvUtils.get("EMAIL_PASSWORD");

    public static void sendEmail(String toAddress, String subject, String messageContent) throws MessagingException {
        System.out.println("--- START SENDING EMAIL ---");
        System.out.println("To: " + toAddress);
        System.out.println("Subject: " + subject);

        if (USERNAME == null || PASSWORD == null || USERNAME.isEmpty() || PASSWORD.isEmpty()) {
            System.err.println("ERROR: Email configuration is missing in .env file or environment variables!");
            throw new MessagingException("Server configuration error: Email credentials missing.");
        }

        Properties properties = new Properties();
        properties.put("mail.smtp.host", HOST);
        properties.put("mail.smtp.port", PORT);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        
        System.out.println("Connecting to SMTP server: " + HOST + ":" + PORT);

        Authenticator auth = new Authenticator() {
            public PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        };

        Session session = Session.getInstance(properties, auth);

        try {
            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(USERNAME));
            InternetAddress[] toAddresses = { new InternetAddress(toAddress) };
            msg.setRecipients(Message.RecipientType.TO, toAddresses);
            
            msg.setSubject(subject, "UTF-8");
            msg.setSentDate(new java.util.Date());
            msg.setContent(messageContent, "text/html; charset=UTF-8");

            Transport.send(msg);
            System.out.println("--- EMAIL SENT SUCCESSFULLY ---");
        } catch (MessagingException e) {
            System.err.println("--- FAILED TO SEND EMAIL ---");
            e.printStackTrace();
            throw e;
        }
    }
}
