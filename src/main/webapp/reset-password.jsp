<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Reset Password</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="container">
    <h2>Reset Password</h2>

    <form action="saaslogin/reset-password" method="post">
        <input type="hidden" name="token" value="<%= request.getParameter("token") %>">

        <div class="input-group">
            <label>New Password</label>
            <input type="password" name="password" required>
        </div>

        <button type="submit" class="btn">Reset Password</button>
    </form>

    <div class="link">
        <a href="login.jsp">Back to Login</a>
    </div>
</div>

</body>
</html>