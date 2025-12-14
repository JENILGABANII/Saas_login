package com.servlet;

import com.dao.dbcon;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/editUser")
public class EditServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String id = req.getParameter("id");
        String fullname = req.getParameter("full_name");
        String mobile = req.getParameter("mobile");
        String email = req.getParameter("email");
        String plan_end = req.getParameter("plan_end");
        String status = req.getParameter("status");

        try (Connection connection = dbcon.getConnection()) {

            String sql = "UPDATE user SET full_name=?, mobile=?, email=?, plan_end=?, status=? WHERE id=?";
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, fullname);
            ps.setString(2, mobile);
            ps.setString(3, email);
            ps.setString(4, plan_end);
            ps.setString(5, status);
            ps.setInt(6, Integer.parseInt(id));

            ps.executeUpdate();

            resp.sendRedirect("user-panel.jsp?success=updated");
        } catch (Exception e) {
            e.printStackTrace(); // remove later
            resp.sendRedirect("user-panel.jsp?error=update_failed");
        }
    }
}
