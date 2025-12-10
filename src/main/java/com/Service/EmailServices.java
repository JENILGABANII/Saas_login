package com.Service;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailServices {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SENDER_EMAIL = "jenilgabani92@gmail.com";
    private static final String SENDER_PASSWORD = "gjoiosiijaonunfp";

    public static boolean sendResetEmail(String toEmail, String resetUrl) {
        try {
            System.out.println("=== EMAIL SENDING STARTED ===");
            System.out.println("To: " + toEmail);
            System.out.println("Reset URL: " + resetUrl);

            // SMTP Properties
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.ssl.trust", SMTP_HOST);
            props.put("mail.debug", "true");

            // Create session with authentication
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
                }
            });

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Password Reset Request - SaaS Login System");

            // HTML Email Content
            String htmlContent = "<!DOCTYPE html>"
                    + "<html>"
                    + "<head>"
                    + "<style>"
                    + "body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }"
                    + ".container { max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }"
                    + ".header { background: #007bff; color: white; padding: 10px; text-align: center; border-radius: 5px 5px 0 0; }"
                    + ".content { padding: 20px; }"
                    + ".button { display: inline-block; background: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 15px 0; }"
                    + ".footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee; color: #666; font-size: 12px; }"
                    + "</style>"
                    + "</head>"
                    + "<body>"
                    + "<div class='container'>"
                    + "<div class='header'><h2>SaaS Login System</h2></div>"
                    + "<div class='content'>"
                    + "<h3>Password Reset Request</h3>"
                    + "<p>Hello,</p>"
                    + "<p>You requested to reset your password. Click the button below to create a new password:</p>"
                    + "<p style='text-align: center;'>"
                    + "<a href='" + resetUrl + "' class='button'>Reset Password</a>"
                    + "</p>"
                    + "<p>Or copy and paste this link in your browser:<br>"
                    + "<code>" + resetUrl + "</code>"
                    + "</p>"
                    + "<p><strong>Note:</strong> This link will expire in 15 minutes.</p>"
                    + "<p>If you didn't request this password reset, please ignore this email.</p>"
                    + "</div>"
                    + "<div class='footer'>"
                    + "<p>SaaS Login System<br>"
                    + "This is an automated email, please do not reply.</p>"
                    + "</div>"
                    + "</div>"
                    + "</body>"
                    + "</html>";

            message.setContent(htmlContent, "text/html");

            // Send email
            Transport.send(message);

            System.out.println("=== EMAIL SENT SUCCESSFULLY TO: " + toEmail + " ===");
            return true;

        } catch (Exception e) {
            System.err.println("=== EMAIL SENDING FAILED ===");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}