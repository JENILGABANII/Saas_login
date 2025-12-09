package com.Service;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.net.Authenticator;
import java.net.PasswordAuthentication;
import java.util.Properties;

public class EmailServices {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SENDER_EMAIL = "jenilgabani92@gmail.com"; // Your Gmail
    private static final String SENDER_PASSWORD = "gjoiosiijaonunfp"; // Your App Password

    public static boolean sendResetEmail(String toEmail, String resetUrl) {
        try {
            System.out.println("=== EMAIL SENDING STARTED ===");
            System.out.println("To: " + toEmail);
            System.out.println("From: " + SENDER_EMAIL);
            System.out.println("Reset URL: " + resetUrl);

            // Configure SMTP properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");
            props.put("mail.smtp.starttls.required", "true");

            // Debugging enable karo
            props.put("mail.debug", "true");

            // Session create karo
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    System.out.println("Authenticating with: " + SENDER_EMAIL);
                    return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
                }
            });

            // Message create karo
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Password Reset Request - SaaS Login");

            // Email content
            String emailContent = """
                <html>
                <body>
                    <h2>Password Reset Request</h2>
                    <p>You have requested to reset your password for SaaS Login.</p>
                    <p>Please click the link below to reset your password:</p>
                    <p><a href="%s" style="background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a></p>
                    <p>Or copy this link: %s</p>
                    <p><strong>This link will expire in 15 minutes.</strong></p>
                    <p>If you didn't request this, please ignore this email.</p>
                    <hr>
                    <p>SaaS Login System</p>
                </body>
                </html>
                """.formatted(resetUrl, resetUrl);

            message.setContent(emailContent, "text/html");

            // Send email
            Transport.send(message);

            System.out.println("=== EMAIL SENT SUCCESSFULLY ===");
            return true;

        } catch (Exception e) {
            System.err.println("=== EMAIL SENDING FAILED ===");
            e.printStackTrace();
            return false;
        }
    }
}