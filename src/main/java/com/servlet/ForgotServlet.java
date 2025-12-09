package com.servlet;

import com.dao.dbcon;
import com.Service.EmailServices;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

@WebServlet("/saaslogin/forgot-password")
public class ForgotServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String token = UUID.randomUUID().toString();
        String resetUrl = "http://localhost:8080/saaslogin/reset-password.jsp?token=" + token;

        System.out.println("\n=== FORGOT PASSWORD REQUEST ===");
        System.out.println("Email: " + email);
        System.out.println("Token: " + token);
        System.out.println("Reset URL: " + resetUrl);

        try (Connection con = dbcon.getConnection()) {
            if (con == null) {
                System.err.println("Database connection failed!");
                resp.sendRedirect("forgot-password.jsp?error=db");
                return;
            }

            System.out.println("Database connected successfully!");

            // Check if email exists
            PreparedStatement checkStmt = con.prepareStatement("SELECT id, full_name FROM users WHERE email=?");
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (!rs.next()) {
                System.out.println("User not found with email: " + email);
                resp.sendRedirect("forgot-password.jsp?error=notfound");
                return;
            }

            String userName = rs.getString("full_name");
            System.out.println("User found: " + userName);

            // Delete any existing tokens for this email
            PreparedStatement deleteStmt = con.prepareStatement(
                    "DELETE FROM password_resets WHERE email=?");
            deleteStmt.setString(1, email);
            int deleted = deleteStmt.executeUpdate();
            System.out.println("Deleted old tokens: " + deleted);

            // Insert new token
            PreparedStatement insertStmt = con.prepareStatement(
                    "INSERT INTO password_resets (email, token, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))");
            insertStmt.setString(1, email);
            insertStmt.setString(2, token);
            int inserted = insertStmt.executeUpdate();
            System.out.println("Token inserted: " + inserted);

            // Send email
            boolean emailSent = EmailServices.sendResetEmail(email, resetUrl);

            if (emailSent) {
                System.out.println("Email sent successfully!");
                resp.sendRedirect("forgot-password.jsp?success=1");
            } else {
                System.err.println("Failed to send email!");
                resp.sendRedirect("forgot-password.jsp?error=sendfailed");
            }

        } catch (Exception e) {
            System.err.println("Exception in ForgotServlet:");
            e.printStackTrace();
            resp.sendRedirect("forgot-password.jsp?error=server");
        }
    }
}