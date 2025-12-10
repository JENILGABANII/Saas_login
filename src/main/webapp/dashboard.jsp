<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");

    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String contextPath = request.getContextPath();
    if (contextPath.equals("/")) {
        contextPath = "";
    }
%>
<html>
<head>
    <title>Dashboard - SaaS System</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
</head>
<body>
    <div class="container">
        <h2>Welcome to Dashboard</h2>

        <div class="user-info">
            <p><strong>Name:</strong> <%= userName %></p>
            <p><strong>Email:</strong> <%= userEmail %></p>
            <p><strong>Status:</strong> Active</p>
        </div>

        <div class="actions">
            <form action="<%= contextPath %>/logout" method="get">
                <button type="submit" class="btn logout">Logout</button>
            </form>
        </div>

        <div style="margin-top: 20px; font-size: 12px; color: #666;">
            <p><strong>Debug Info:</strong></p>
            <p>Context Path: <%= contextPath %></p>
            <p>Session ID: <%= session.getId() %></p>
        </div>
    </div>
</body>
</html>