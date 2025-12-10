<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String contextPath = request.getContextPath();
    if (contextPath.equals("/")) {
        contextPath = "";
    }
%>
<html>
<head>
    <title>Login - SaaS System</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <style>
        .alert {
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-size: 14px;
        }
        .alert.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>SaaS Login System</h2>

        <%
            String error = request.getParameter("error");
            String success = request.getParameter("registered");
            String reset = request.getParameter("reset");
        %>

        <% if ("1".equals(success)) { %>
            <div class="alert success">✅ Registration successful! Please login.</div>
        <% } %>

        <% if ("success".equals(reset)) { %>
            <div class="alert success">✅ Password reset successful! Please login with your new password.</div>
        <% } %>

        <% if ("notfound".equals(error)) { %>
            <div class="alert error">❌ User not found. Please register first.</div>
        <% } else if ("invalid".equals(error)) { %>
            <div class="alert error">❌ Invalid email or password.</div>
        <% } else if ("expired".equals(error)) { %>
            <div class="alert error">❌ Your account has expired. Please contact support.</div>
        <% } else if ("db".equals(error)) { %>
            <div class="alert error">❌ Database error. Please try again later.</div>
        <% } else if ("server".equals(error)) { %>
            <div class="alert error">❌ Server error. Please try again.</div>
        <% } %>

        <form action="<%= contextPath %>/login" method="post">
            <div class="input-group">
                <label>Email</label>
                <input type="email" name="email" required placeholder="Enter your email">
            </div>

            <div class="input-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="Enter your password">
            </div>

            <button type="submit" class="btn">Login</button>
        </form>

        <div class="links">
            <a href="<%= contextPath %>/register.jsp">Create New Account</a> |
            <a href="<%= contextPath %>/forgot-password.jsp">Forgot Password?</a>
        </div>

        <div style="margin-top: 20px; font-size: 12px; color: #666; text-align: center;">
            <p><strong>Debug Info:</strong></p>
            <p>Context Path: <%= contextPath %></p>
            <p>Current URL: <%= request.getRequestURL() %></p>
        </div>
    </div>
</body>
</html>