package com.servlet;

import com.dao.dbcon;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/addUser")
public class AddUser extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String full_name = request.getParameter("full_name");
        String mobile = request.getParameter("mobile");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String plan_end = request.getParameter("plan_end");
        String status = request.getParameter("status");
        String entry_by = request.getParameter("entry_by");

        if (full_name.isEmpty() || email.isEmpty() || password.isEmpty()) {
            response.sendRedirect("user-panel.jsp?error=missing_fields");
            return;
        }

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        try (Connection con = dbcon.getConnection()) {
            String sql = "INSERT INTO user (full_name, mobile, email, password, plan_end, status, entry_by) VALUES (?,?,?,?,?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, full_name);
            ps.setString(2, mobile);
            ps.setString(3, email);
            ps.setString(4, hashedPassword);
            ps.setString(5, plan_end);
            ps.setString(6, status);
            ps.setString(7, entry_by);
            ps.executeUpdate();

            response.sendRedirect("user-panel.jsp?success=added");
        } catch (Exception e) {
            response.sendRedirect("user-panel.jsp?error=db_error");
        }
    }
}
