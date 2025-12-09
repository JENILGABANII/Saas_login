<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Login - SaaS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="container">
    <h2>Login</h2>

    <!-- Error & Success Messages -->
    <% if ("expired".equals(request.getParameter("error"))) { %>
        <div class="alert">Your account has expired</div>
    <% } %>

    <% if ("invalid".equals(request.getParameter("error"))) { %>
        <div class="alert">Invalid email or password</div>
    <% } %>

    <% if ("notfound".equals(request.getParameter("error"))) { %>
        <div class="alert">User not found</div>
    <% } %>

    <% if ("success".equals(request.getParameter("reset"))) { %>
        <div class="alert success">Password reset successful</div>
    <% } %>

    <% if ("1".equals(request.getParameter("registered"))) { %>
        <div class="alert success">Registration successful! Please login.</div>
    <% } %>

    <!-- Login Form -->
    <form action="saaslogin/login" method="post" autocomplete="off">
        <div class="input-group">
            <label>Email</label>
            <input type="email" name="email" autocomplete="off" placeholder="Enter your email" required>
        </div>

        <div class="input-group">
            <label>Password</label>
            <input type="password" name="password" autocomplete="new-password" placeholder="Enter your password" required>
        </div>

        <button type="submit" class="btn">Login</button>
    </form>

    <!-- Links -->
    <div class="link">
        <a href="register.jsp">Create Account</a> |
        <a href="forgot-password.jsp">Forgot Password?</a>
    </div>
</div>

</body>
</html>