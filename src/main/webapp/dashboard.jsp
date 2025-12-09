<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("userEmail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<html>
<head>
    <title>Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="container">
    <h2>Dashboard</h2>
    <p>Welcome, <%= session.getAttribute("userEmail") %></p>

    <form action="saaslogin/logout" method="get">
        <button class="btn">Logout</button>
    </form>
</div>

</body>
</html>