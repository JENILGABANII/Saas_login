<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String contextPath = request.getContextPath();
    if (contextPath.equals("/")) {
        contextPath = "";
    }
%>
<html>
<head>
    <title>Forgot Password - SaaS System</title>
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
        <h2>Forgot Password</h2>

        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            String emailParam = request.getParameter("email");
        %>

        <% if ("1".equals(success)) { %>
            <div class="alert success">
                ✅ Password reset link has been sent to your email!<br>
                <small>Check your inbox and spam folder. The link expires in 15 minutes.</small>
            </div>
        <% } %>

        <% if ("empty".equals(error)) { %>
            <div class="alert error">❌ Please enter your email address.</div>
        <% } else if ("notfound".equals(error)) { %>
            <div class="alert error">❌ Email not found in our system.</div>
        <% } else if ("emailfail".equals(error)) { %>
            <div class="alert error">❌ Failed to send email. Please try again later.</div>
        <% } else if ("db".equals(error)) { %>
            <div class="alert error">❌ Database error. Please try again.</div>
        <% } else if ("server".equals(error)) { %>
            <div class="alert error">❌ Server error. Please try again.</div>
        <% } %>

        <form action="<%= contextPath %>/forgot-password" method="post">
            <div class="input-group">
                <label>Enter your registered email</label>
                <input type="email" name="email" required
                       placeholder="your.email@example.com"
                       value="<%= emailParam != null ? emailParam : "" %>">
            </div>

            <button type="submit" class="btn">Send Reset Link</button>
        </form>

        <div class="links">
            <a href="<%= contextPath %>/login.jsp">← Back to Login</a>
        </div>

        <div style="margin-top: 20px; font-size: 12px; color: #666; text-align: center;">
        </div>
    </div>
</body>
</html>