<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Register - SaaS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="container">
    <h2>Create Account</h2>

    <form action="saaslogin/register" method="post" autocomplete="off">
        <div class="input-group">
            <label>Full Name</label>
            <input type="text" name="full_name" required>
        </div>

        <div class="input-group">
            <label>Email</label>
            <input type="email" name="email" required>
        </div>

        <div class="input-group">
            <label>Password</label>
            <input type="password" name="password" required>
        </div>

        <button type="submit" class="btn">Register</button>
    </form>

    <div class="link">
        <a href="login.jsp">Already have an account?</a>
    </div>
</div>

</body>
</html>