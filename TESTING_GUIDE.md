# 🧪 Testing & Troubleshooting Guide

## ✅ Pre-Deployment Checklist

Run these checks before deploying:

### 1. Database Check
```sql
-- Login to MySQL
mysql -u root -p6677

-- Verify database exists
SHOW DATABASES LIKE 'saas_auth_system';

-- Check tables
USE saas_auth_system;
SHOW TABLES;

-- Verify test user
SELECT * FROM users;
```

Expected output:
- Database: `saas_auth_system` exists
- Tables: `users`, `password_resets` exist
- At least 1 test user present

### 2. File Structure Check
```powershell
# From project root
tree /F

# Should see:
# - src/main/java/com/dao/dbcon.java
# - src/main/java/com/servlet/*.java (5 files)
# - src/main/webapp/*.jsp (6 files)
# - src/main/webapp/WEB-INF/web.xml
# - pom.xml
```

### 3. Dependency Check
```powershell
# Check Maven dependencies
mvn dependency:tree

# Should include:
# - javax.servlet-api:4.0.1
# - mysql-connector-java:8.0.33
# - jbcrypt:0.4
# - javax.mail:1.6.2
```

---

## 🔧 Common Tomcat Errors & Fixes

### ❌ Error: "Failed to start component [StandardEngine[Catalina].StandardHost[localhost].StandardContext[/saaslogin]]"

**Cause:** Compilation errors or missing dependencies

**Fix:**
```powershell
# Clean and rebuild
mvn clean compile
mvn clean package

# Check for Java syntax errors
# Verify all servlet files use javax.servlet (not jakarta.servlet)
```

### ❌ Error: "ClassNotFoundException: com.mysql.cj.jdbc.Driver"

**Cause:** MySQL connector not in WAR file

**Fix:**
```xml
<!-- In pom.xml, ensure this dependency exists: -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
    <!-- IMPORTANT: No <scope>provided</scope> -->
</dependency>
```

Then rebuild:
```powershell
mvn clean package
```

### ❌ Error: "HTTP Status 404 – Not Found"

**Possible Causes & Fixes:**

**A. Wrong URL**
```
❌ Wrong: http://localhost:8080/login.jsp
✅ Correct: http://localhost:8080/saaslogin/login.jsp
                                    ^^^^^^^^^^
                                    context path required!
```

**B. Application not deployed**
```powershell
# Check Tomcat webapps folder
ls "C:\Program Files\Apache Tomcat 9.0\webapps"

# Should see: saaslogin.war OR saaslogin folder
# If not, redeploy
```

**C. Deployment failed**
```powershell
# Check Tomcat logs
cat "C:\Program Files\Apache Tomcat 9.0\logs\catalina.out"

# Look for:
# - "Deployment of web application directory ... has finished"
# - Any error messages
```

### ❌ Error: "HTTP Status 500 – Internal Server Error"

**Check Tomcat logs for specific error:**

**A. NullPointerException from dbcon**
```
Caused by: java.sql.SQLException: Access denied for user 'root'@'localhost'
```
**Fix:** Update password in `dbcon.java`

**B. Table doesn't exist**
```
Caused by: Table 'saas_auth_system.users' doesn't exist
```
**Fix:** Re-run `database.sql`

**C. BCrypt class not found**
```
Caused by: java.lang.NoClassDefFoundError: org/mindrot/jbcrypt/BCrypt
```
**Fix:** Maven dependency issue
```powershell
mvn clean install
```

---

## 🧪 Manual Testing Steps

### Test 1: Registration Flow

1. **Access Registration Page**
   ```
   http://localhost:8080/saaslogin/register.jsp
   ```

2. **Fill Form**
   - Full Name: John Doe
   - Email: john@example.com
   - Password: password123

3. **Submit & Verify**
   - Should redirect to `login.jsp?registered=1`
   - Green success message displayed
   
4. **Database Verification**
   ```sql
   SELECT * FROM users WHERE email = 'john@example.com';
   -- Should return 1 row with BCrypt hashed password
   ```

### Test 2: Login Flow

1. **Access Login Page**
   ```
   http://localhost:8080/saaslogin/login.jsp
   ```

2. **Login with Test User**
   - Email: test@example.com
   - Password: password123

3. **Verify Success**
   - Should redirect to `dashboard.jsp`
   - See "Welcome to Dashboard"
   - User name and email displayed

4. **Check Console Logs**
   ```
   === LOGIN ATTEMPT ===
   Email: test@example.com
   Login successful for: test@example.com
   ```

### Test 3: Failed Login

1. **Try Invalid Credentials**
   - Email: test@example.com
   - Password: wrongpassword

2. **Expected Result**
   - Redirect to `login.jsp?error=invalid`
   - Red error message: "Invalid email or password"

3. **Console Log**
   ```
   === LOGIN ATTEMPT ===
   Email: test@example.com
   Invalid password for: test@example.com
   ```

### Test 4: Password Reset Flow

1. **Request Reset**
   ```
   http://localhost:8080/saaslogin/forgot-password.jsp
   ```
   - Enter: test@example.com
   - Click "Send Reset Link"

2. **Verify Token Created**
   ```sql
   SELECT * FROM password_resets WHERE email = 'test@example.com';
   -- Should show token and expires_at (15 min from now)
   ```

3. **Console Output**
   ```
   === FORGOT PASSWORD REQUEST ===
   Email: test@example.com
   User found: Test User
   Reset URL: http://localhost:8080/saaslogin/reset-password.jsp?token=xxx
   Reset email sent successfully to: test@example.com
   ```

4. **Test Reset Link**
   - Copy reset URL from console
   - Open in browser
   - Enter new password (min 8 chars)
   - Submit

5. **Verify Password Changed**
   - Try logging in with NEW password
   - Should succeed

### Test 5: Session Management

1. **Login Successfully**
   ```
   http://localhost:8080/saaslogin/login.jsp
   ```

2. **Verify Session**
   - Go to `dashboard.jsp`
   - User info displayed
   - Session ID shown in debug info

3. **Test Logout**
   - Click "Logout" button
   - Should redirect to `login.jsp`
   - Try accessing `dashboard.jsp` directly
   - Should redirect back to `login.jsp`

4. **Console Log**
   ```
   Logout for user: test@example.com
   ```

---

## 🐛 Debug Mode

### Enable Detailed Logging

All servlets already have debug logging. Check console output:

**Registration:**
```
=== REGISTRATION REQUEST ===
Name: John Doe
Email: john@example.com
User registered successfully: john@example.com
```

**Login:**
```
=== LOGIN ATTEMPT ===
Email: test@example.com
Login successful for: test@example.com
```

**Password Reset:**
```
=== FORGOT PASSWORD REQUEST ===
Email: test@example.com
User found: Test User
Reset URL: http://localhost:8080/saaslogin/reset-password.jsp?token=...
Reset email sent successfully to: test@example.com
```

### Test Database Connection Directly

Create test file: `src/main/java/com/dao/TestConnection.java`

```java
package com.dao;

import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        Connection conn = dbcon.getConnection();
        if (conn != null) {
            System.out.println("✅ Database connection successful!");
            System.out.println("Connection: " + conn);
        } else {
            System.out.println("❌ Database connection failed!");
        }
    }
}
```

Run this class to test DB connectivity.

---

## 🔍 Tomcat Log Analysis

### Check Deployment Status

```powershell
# View recent logs
cat "C:\Program Files\Apache Tomcat 9.0\logs\catalina.out" | Select-Object -Last 50

# Look for:
```

**✅ Successful Deployment:**
```
INFO: Deployment of web application directory [C:\...\webapps\saaslogin] has finished in [X] ms
INFO: Starting service [Catalina]
INFO: Server startup in [X] milliseconds
```

**❌ Failed Deployment:**
```
SEVERE: Exception starting filter
SEVERE: Context initialization failed
SEVERE: Error listenerStart
```

### Common Log Errors

**1. Port Already in Use**
```
SEVERE: Failed to initialize end point associated with ProtocolHandler ["http-nio-8080"]
java.net.BindException: Address already in use: bind
```
**Fix:**
```powershell
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

**2. Permission Denied**
```
java.io.FileNotFoundException: ...\webapps\saaslogin\... (Access is denied)
```
**Fix:** Run Tomcat as Administrator

**3. Out of Memory**
```
java.lang.OutOfMemoryError: Java heap space
```
**Fix:** Increase Tomcat memory in `setenv.bat`:
```batch
set JAVA_OPTS=-Xms512m -Xmx1024m
```

---

## 📊 Health Check Endpoints

### Create a Status Page (Optional)

`src/main/webapp/status.jsp`:
```jsp
<%@ page import="com.dao.dbcon" %>
<%@ page import="java.sql.Connection" %>
<%
    response.setContentType("application/json");
    
    Connection conn = dbcon.getConnection();
    boolean dbOk = (conn != null);
    
    if (dbOk) conn.close();
%>
{
  "status": "<%= dbOk ? "OK" : "ERROR" %>",
  "database": "<%= dbOk ? "Connected" : "Disconnected" %>",
  "timestamp": "<%= new java.util.Date() %>"
}
```

Access: `http://localhost:8080/saaslogin/status.jsp`

---

## ✅ Final Verification

Run all tests in order:

- [ ] Database connection works
- [ ] Registration creates user
- [ ] Login with correct credentials succeeds
- [ ] Login with wrong credentials fails
- [ ] Dashboard accessible after login
- [ ] Dashboard redirects to login when not authenticated
- [ ] Forgot password generates token
- [ ] Reset link works and updates password
- [ ] Logout invalidates session
- [ ] No errors in Tomcat logs

---

## 🆘 Still Not Working?

### Collect Debug Information

```powershell
# 1. Check Java version
java -version

# 2. Check Tomcat version
cat "C:\Program Files\Apache Tomcat 9.0\RELEASE-NOTES" | Select-Object -First 5

# 3. Check MySQL version
mysql --version

# 4. List running processes
Get-Process | Where-Object {$_.ProcessName -match "java|mysql"}

# 5. Check port usage
netstat -ano | findstr "8080 3306"

# 6. Get recent Tomcat logs
cat "C:\Program Files\Apache Tomcat 9.0\logs\catalina.out" | Select-Object -Last 100
```

### Create Minimal Test

Test if Tomcat works at all:

`src/main/webapp/test.jsp`:
```jsp
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<body>
<h1>✅ Tomcat is working!</h1>
<p>Current time: <%= new java.util.Date() %></p>
</body>
</html>
```

Access: `http://localhost:8080/saaslogin/test.jsp`

If this works, issue is with servlets/database.
If this doesn't work, issue is with Tomcat/deployment.

---

**Need more help? Check:**
- Tomcat logs in `<TOMCAT_HOME>/logs/`
- Console output in IDE
- MySQL error log
- Windows Event Viewer for system errors
