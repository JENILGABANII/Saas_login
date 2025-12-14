package com.servlet;

import com.dao.dbcon;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/deleteUser")
public class DeleteServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
String id=request.getParameter("id");
try(Connection connection = dbcon.getConnection()){
    PreparedStatement preparedStatement = connection.prepareStatement("delete from user where id=?");
    preparedStatement.setString(1,id);
    preparedStatement.executeUpdate();
    response.sendRedirect("user-panel.jsp?success=deleted");

} catch (Exception e) {
    response.sendRedirect("user-panel.jsp?error=delete_failed");
}
    }
}
