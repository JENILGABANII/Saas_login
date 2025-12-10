package com.servlet;

import com.dao.dbcon;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Email: " + email);

        try (Connection conn = dbcon.getConnection()) {
            if (conn == null) {
                response.sendRedirect("login.jsp?error=db");
                return;
            }

            // Get user by email
            String sql = "SELECT * FROM users WHERE email = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (!rs.next()) {
                System.out.println("User not found: " + email);
                response.sendRedirect("login.jsp?error=notfound");
                return;
            }

            // Verify password
            String storedHash = rs.getString("password_hash");
            if (!BCrypt.checkpw(password, storedHash)) {
                System.out.println("Invalid password for: " + email);
                response.sendRedirect("login.jsp?error=invalid");
                return;
            }

            // Check if account is expired
            LocalDate planEnd = rs.getDate("plan_end").toLocalDate();
            if (planEnd.isBefore(LocalDate.now())) {
                // Update status to expired
                String updateSql = "UPDATE users SET status = 'EXPIRED' WHERE email = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, email);
                updateStmt.executeUpdate();

                System.out.println("Account expired: " + email);
                response.sendRedirect("login.jsp?error=expired");
                return;
            }

            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("userEmail", email);
            session.setAttribute("userName", rs.getString("full_name"));
            session.setAttribute("userId", rs.getInt("id"));

            System.out.println("Login successful for: " + email);
            response.sendRedirect("dashboard.jsp");

        } catch (Exception e) {
            System.err.println("Login error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=server");
        }
    }
}