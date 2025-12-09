package com.servlet;

import com.dao.dbcon;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDate;

@WebServlet("/saaslogin/register")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("full_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String hashpassword = BCrypt.hashpw(password, BCrypt.gensalt());
        LocalDate startdate = LocalDate.now();
        LocalDate enddate = startdate.plusDays(30);

        try (Connection connection = dbcon.getConnection()) {
            if (connection == null) {
                response.sendRedirect("register.jsp?error=db");
                return;
            }

            String sql = "INSERT INTO users (full_name, email, password_hash, plan_start, plan_end, status) VALUES (?, ?, ?, ?, ?, 'ACTIVE')";
            try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
                preparedStatement.setString(1, username);
                preparedStatement.setString(2, email);
                preparedStatement.setString(3, hashpassword);
                preparedStatement.setDate(4, java.sql.Date.valueOf(startdate));
                preparedStatement.setDate(5, java.sql.Date.valueOf(enddate));
                preparedStatement.executeUpdate();
                response.sendRedirect("login.jsp?registered=1");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=server");
        }
    }
}