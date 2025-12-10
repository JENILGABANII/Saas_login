package com.servlet;

import com.dao.dbcon;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ResetServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String newPassword = request.getParameter("password");

        if (newPassword == null || newPassword.length() < 8) {
            response.sendRedirect("reset-password.jsp?error=weak&token=" + token);
            return;
        }

        try (Connection conn = dbcon.getConnection()) {
            if (conn == null) {
                response.sendRedirect("reset-password.jsp?error=db&token=" + token);
                return;
            }

            // Check if token is valid and not expired
            String tokenSql = "SELECT email FROM password_resets WHERE token = ? AND expires_at > NOW()";
            PreparedStatement preparedStatement = conn.prepareStatement(tokenSql);
            preparedStatement.setString(1, token);
            ResultSet rs = preparedStatement.executeQuery();

            if (!rs.next()) {
                System.out.println("Invalid or expired token: " + token);
                response.sendRedirect("reset-password.jsp?error=invalid");
                return;
            }

            String email = rs.getString("email");
            System.out.println("Valid token for email: " + email);

            // Hash new password
            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

            // Update user's password
            String updateSql = "UPDATE users SET password_hash = ? WHERE email = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, hashedPassword);
            updateStmt.setString(2, email);
            int updated = updateStmt.executeUpdate();

            if (updated > 0) {
                // Delete used token
                String deleteSql = "DELETE FROM password_resets WHERE token = ?";
                PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
                deleteStmt.setString(1, token);
                deleteStmt.executeUpdate();

                System.out.println("Password reset successful for: " + email);
                response.sendRedirect("login.jsp?reset=success");
            } else {
                response.sendRedirect("reset-password.jsp?error=update&token=" + token);
            }

        } catch (Exception e) {
            System.err.println("Reset password error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("reset-password.jsp?error=server&token=" + token);
        }
    }
}