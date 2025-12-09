package com.servlet;

import com.dao.dbcon;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;

@WebServlet("/saaslogin/login")
public class loginservlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        System.out.println("Login attempt for: " + email);

        try (Connection connection = dbcon.getConnection()) {
            if (connection == null) {
                response.sendRedirect("login.jsp?error=db");
                return;
            }

            String sql = "SELECT * FROM users WHERE email = ?";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("login.jsp?error=notfound");
                return;
            }

            String storedHash = rs.getString("password_hash");

            if (!BCrypt.checkpw(password, storedHash)) {
                response.sendRedirect("login.jsp?error=invalid");
                return;
            }

            LocalDate planEnd = rs.getDate("plan_end").toLocalDate();

            if (planEnd.isBefore(LocalDate.now())) {
                PreparedStatement upd = connection.prepareStatement(
                        "UPDATE users SET status = 'EXPIRED' WHERE email = ?");
                upd.setString(1, email);
                upd.executeUpdate();

                response.sendRedirect("login.jsp?error=expired");
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("userEmail", email);
            session.setAttribute("userName", rs.getString("full_name"));

            System.out.println("Login successful for: " + email);
            response.sendRedirect("dashboard.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=server");
        }
    }
}