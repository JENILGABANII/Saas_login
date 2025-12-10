<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String contextPath = request.getContextPath();
    if (contextPath.equals("/")) {
        contextPath = "";
    }
%>
<html>
<head>
    <title>Reset Password - SaaS System</title>
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
        <h2>Reset Password</h2>

        <%
            String token = request.getParameter("token");
            String error = request.getParameter("error");
        %>

        <% if (token == null || token.trim().isEmpty()) { %>
            <div class="alert error">
                ❌ Invalid reset link. Please request a new password reset.
            </div>
            <div class="links">
                <a href="<%= contextPath %>/forgot-password">Request New Reset Link</a> |
                <a href="<%= contextPath %>/login.jsp">Back to Login</a>
            </div>
        <% } else { %>
            <% if ("weak".equals(error)) { %>
                <div class="alert error">❌ Password must be at least 8 characters.</div>
            <% } else if ("invalid".equals(error)) { %>
                <div class="alert error">❌ Invalid or expired token. Please request a new reset link.</div>
            <% } else if ("update".equals(error)) { %>
                <div class="alert error">❌ Failed to update password. Please try again.</div>
            <% } else if ("db".equals(error)) { %>
                <div class="alert error">❌ Database error. Please try again.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error">❌ Server error. Please try again.</div>
            <% } %>

            <form action="<%= contextPath %>/reset-password" method="post">
                <input type="hidden" name="token" value="<%= token %>">

                <div class="input-group">
                    <label>New Password (min 8 characters)</label>
                    <input type="password" name="password" required minlength="8"
                           placeholder="Enter new password">
                </div>

                <button type="submit" class="btn">Reset Password</button>
            </form>

            <div class="links">
                <a href="<%= contextPath %>/login.jsp">Back to Login</a>
            </div>
        <% } %>
    </div>
</body>
</html>