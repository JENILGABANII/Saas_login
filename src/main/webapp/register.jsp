<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String contextPath = request.getContextPath();
    if (contextPath.equals("/")) {
        contextPath = "";
    }
%>
<html>
<head>
    <title>Register - SaaS System</title>
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
        <h2>Create Account</h2>

        <% String error = request.getParameter("error"); %>

        <% if ("empty".equals(error)) { %>
            <div class="alert error">❌ All fields are required.</div>
        <% } else if ("weak".equals(error)) { %>
            <div class="alert error">❌ Password must be at least 8 characters.</div>
        <% } else if ("exists".equals(error)) { %>
            <div class="alert error">❌ Email already registered. Please login.</div>
        <% } else if ("db".equals(error)) { %>
            <div class="alert error">❌ Database error. Please try again.</div>
        <% } else if ("server".equals(error)) { %>
            <div class="alert error">❌ Server error. Please try again.</div>
        <% } %>

        <form action="<%= contextPath %>/register" method="post">
            <div class="input-group">
                <label>Full Name</label>
                <input type="text" name="full_name" required placeholder="Enter your full name">
            </div>

            <div class="input-group">
                <label>Email</label>
                <input type="email" name="email" required placeholder="Enter your email">
            </div>

            <div class="input-group">
                <label>Password (min 8 characters)</label>
                <input type="password" name="password" required minlength="8" placeholder="Enter password">
            </div>

            <button type="submit" class="btn">Register</button>
        </form>

        <div class="links">
            <a href="<%= contextPath %>/login.jsp">Already have an account? Login</a>
        </div>
    </div>
</body>
</html>