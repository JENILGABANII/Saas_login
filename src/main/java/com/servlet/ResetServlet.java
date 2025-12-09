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
import java.sql.ResultSet;

@WebServlet("/saaslogin/reset-password")
public class ResetServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String newPassword = request.getParameter("password");
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        try (Connection connection = dbcon.getConnection()) {
            if (connection == null) {
                response.sendRedirect("reset-password.jsp?error=db&token=" + token);
                return;
            }

            String query = "SELECT email FROM password_resets WHERE token=? AND expires_at >= NOW()";
            try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
                preparedStatement.setString(1, token);
                try (ResultSet resultSet = preparedStatement.executeQuery()) {
                    if (resultSet.next()) {
                        String email = resultSet.getString("email");

                        // Update password
                        try (PreparedStatement update = connection.prepareStatement(
                                "UPDATE users SET password_hash = ? WHERE email = ?")) {
                            update.setString(1, hashedPassword);
                            update.setString(2, email);
                            update.executeUpdate();
                        }

                        // Delete token
                        try (PreparedStatement delete = connection.prepareStatement(
                                "DELETE FROM password_resets WHERE token = ?")) {
                            delete.setString(1, token);
                            delete.executeUpdate();
                        }

                        response.sendRedirect("login.jsp?reset=success");
                        return;
                    }
                }
            }
            response.sendRedirect("reset-password.jsp?error=invalid&token=" + token);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("reset-password.jsp?error=server&token=" + token);
        }
    }
}