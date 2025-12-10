package com.servlet;

import com.dao.dbcon;
import com.Service.EmailServices;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

public class ForgotServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Show forgot password page
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        System.out.println("=== FORGOT PASSWORD REQUEST ===");
        System.out.println("Email: " + email);

        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect("forgot-password.jsp?error=empty");
            return;
        }

        try (Connection conn = dbcon.getConnection()) {
            if (conn == null) {
                response.sendRedirect("forgot-password.jsp?error=db");
                return;
            }

            // Check if email exists in users table
            String checkSql = "SELECT id, full_name FROM users WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (!rs.next()) {
                System.out.println("Email not found: " + email);
                response.sendRedirect("forgot-password.jsp?error=notfound");
                return;
            }

            String userName = rs.getString("full_name");
            System.out.println("User found: " + userName);

            // Generate unique token
            String token = UUID.randomUUID().toString();

            // Delete any existing tokens for this email
            String deleteSql = "DELETE FROM password_resets WHERE email = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setString(1, email);
            deleteStmt.executeUpdate();

            // Insert new token (valid for 15 minutes)
            String insertSql = "INSERT INTO password_resets (email, token, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, email);
            insertStmt.setString(2, token);
            insertStmt.executeUpdate();

            // Generate reset URL
            String baseUrl = request.getRequestURL().toString()
                    .replace(request.getServletPath(), "");
            String resetUrl = baseUrl + "/reset-password.jsp?token=" + token;

            System.out.println("Reset URL: " + resetUrl);

            // Send email
            boolean emailSent = EmailServices.sendResetEmail(email, resetUrl);

            if (emailSent) {
                System.out.println("Reset email sent successfully to: " + email);
                response.sendRedirect("forgot-password.jsp?success=1");
            } else {
                System.err.println("Failed to send email to: " + email);
                response.sendRedirect("forgot-password.jsp?error=emailfail");
            }

        } catch (Exception e) {
            System.err.println("Forgot password error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("forgot-password.jsp?error=server");
        }
    }
}