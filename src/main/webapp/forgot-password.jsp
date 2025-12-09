<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Forgot Password</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .alert { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
    </style>
</head>
<body>

<div class="container">
    <h2>Forgot Password</h2>

    <!-- Success Message -->
    <% if ("1".equals(request.getParameter("success"))) { %>
        <div class="alert success">
            ✅ Password reset link has been sent to your email!<br>
            <small>Check your inbox (and spam folder).</small>
        </div>
    <% } %>

    <!-- Error Messages -->
    <%
        String error = request.getParameter("error");
        if (error != null) {
            if ("notfound".equals(error)) { %>
                <div class="alert error">❌ Email not found in our system.</div>
            <% } else if ("sendfailed".equals(error)) { %>
                <div class="alert error">
                    ❌ Failed to send email.<br>
                    <small>Please check your email address or try again later.</small>
                </div>
            <% } else if ("db".equals(error)) { %>
                <div class="alert error">❌ Database connection error.</div>
            <% } else if ("server".equals(error)) { %>
                <div class="alert error">❌ Server error occurred. Please try again.</div>
            <% } else { %>
                <div class="alert error">❌ Something went wrong. Error: <%= error %></div>
            <% }
        }
    %>

    <form action="saaslogin/forgot-password" method="post">
        <div class="input-group">
            <label>Enter your email address</label>
            <input type="email" name="email" required
                   placeholder="your.email@example.com"
                   value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
        </div>

        <button type="submit" class="btn">Send Reset Link</button>
    </form>

    <div class="link">
        <a href="login.jsp">← Back to Login</a>
    </div>
</div>

</body>
</html>