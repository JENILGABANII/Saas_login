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
import java.time.LocalDate;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        System.out.println("=== REGISTRATION REQUEST ===");
        System.out.println("Name: " + fullName);
        System.out.println("Email: " + email);

        // Validate input
        if (fullName == null || fullName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            response.sendRedirect("register.jsp?error=empty");
            return;
        }

        if (password.length() < 8) {
            response.sendRedirect("register.jsp?error=weak");
            return;
        }

        // Hash password
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        // Set plan dates (30-day trial)
        LocalDate planStart = LocalDate.now();
        LocalDate planEnd = planStart.plusDays(30);

        try (Connection conn = dbcon.getConnection()) {
            if (conn == null) {
                response.sendRedirect("register.jsp?error=db");
                return;
            }

            // Check if email already exists
            String checkSql = "SELECT id FROM users WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                response.sendRedirect("register.jsp?error=exists");
                return;
            }

            // Insert new user
            String insertSql = "INSERT INTO users (full_name, email, password_hash, plan_start, plan_end, status) VALUES (?, ?, ?, ?, ?, 'ACTIVE')";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, fullName);
            insertStmt.setString(2, email);
            insertStmt.setString(3, hashedPassword);
            insertStmt.setDate(4, java.sql.Date.valueOf(planStart));
            insertStmt.setDate(5, java.sql.Date.valueOf(planEnd));

            int rows = insertStmt.executeUpdate();

            if (rows > 0) {
                System.out.println("User registered successfully: " + email);
                response.sendRedirect("login.jsp?registered=1");
            } else {
                response.sendRedirect("register.jsp?error=failed");
            }

        } catch (Exception e) {
            System.err.println("Registration error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=server");
        }
    }
}