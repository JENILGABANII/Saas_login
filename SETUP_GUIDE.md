# 🚀 Complete Setup Guide - SaaS Login System

## ✅ Prerequisites Check

Before starting, ensure you have:
- ✅ **Java JDK 8+** installed
- ✅ **Apache Tomcat 9** installed
- ✅ **MySQL 8.0+** running
- ✅ **IDE** (IntelliJ IDEA or Eclipse recommended)

---

## 📋 Step-by-Step Setup

### **STEP 1: Database Setup** ⚡

1. **Start MySQL Server**
   ```powershell
   # Check if MySQL is running
   Get-Service MySQL*
   
   # Or start manually from Services
   ```

2. **Import Database**
   ```powershell
   # Navigate to project folder
   cd "C:\Users\DELL\Downloads\saaslogin"
   
   # Import SQL file
   mysql -u root -p < database.sql
   ```
   
   Or use MySQL Workbench:
   - Open MySQL Workbench
   - File → Run SQL Script
   - Select `database.sql`
   - Click Execute

3. **Verify Database**
   ```sql
   USE saas_auth_system;
   SHOW TABLES;
   SELECT * FROM users;
   ```

### **STEP 2: Configure Database Connection** 🔧

File: `src/main/java/com/dao/dbcon.java`

**Already configured with:**
- Database: `saas_auth_system` ✅
- Username: `root` ✅
- Password: `6677` ✅

If your MySQL password is different, update line 10 in `dbcon.java`

### **STEP 3: Deploy to Tomcat** 🎯

#### **Option A: Using IntelliJ IDEA** (Recommended)

1. **Open Project**
   - File → Open → Select `saaslogin` folder
   - Wait for Maven to download dependencies

2. **Configure Tomcat**
   - Run → Edit Configurations
   - Click **+** → Tomcat Server → Local
   - Application Server: Browse to Tomcat installation (e.g., `C:\Program Files\Apache Tomcat 9.0`)
   - Click **Fix** button at bottom
   - Select `saaslogin:war exploded`
   - Set Application context to `/saaslogin`

3. **Run Application**
   - Click **Run** button (Green play icon)
   - Wait for "Artifact saaslogin:war exploded: Artifact is deployed successfully"
   - Browser opens automatically at `http://localhost:8080/saaslogin`

#### **Option B: Using Eclipse**

1. **Import Project**
   - File → Import → Existing Maven Projects
   - Browse to `saaslogin` folder
   - Click Finish

2. **Add Tomcat Server**
   - Window → Preferences → Server → Runtime Environments
   - Add → Apache Tomcat v9.0
   - Browse to Tomcat directory

3. **Deploy**
   - Right-click project → Run As → Run on Server
   - Select Tomcat v9.0 Server
   - Click Finish

#### **Option C: Manual WAR Deployment**

1. **Build WAR file**
   ```powershell
   cd "C:\Users\DELL\Downloads\saaslogin"
   
   # If Maven installed:
   mvn clean package
   
   # WAR file created at: target/saaslogin.war
   ```

2. **Deploy to Tomcat**
   ```powershell
   # Copy WAR to Tomcat
   copy target\saaslogin.war "C:\Program Files\Apache Tomcat 9.0\webapps\"
   
   # Start Tomcat
   cd "C:\Program Files\Apache Tomcat 9.0\bin"
   .\startup.bat
   ```

3. **Check Deployment**
   - Wait 10-15 seconds for deployment
   - Check `webapps` folder for `saaslogin` directory
   - Open: `http://localhost:8080/saaslogin`

### **STEP 4: Test Application** 🧪

1. **Access Application**
   ```
   http://localhost:8080/saaslogin/login.jsp
   ```

2. **Test with Demo User**
   - Email: `test@example.com`
   - Password: `password123`

3. **Test Registration**
   - Click "Create New Account"
   - Fill form with new details
   - Password must be 8+ characters

4. **Test Password Reset**
   - Click "Forgot Password?"
   - Enter registered email
   - Check email for reset link (if email configured)

---

## 🔥 Common Issues & Solutions

### ❌ Issue: "Cannot connect to database"
**Solution:**
1. Check MySQL is running: `Get-Service MySQL*`
2. Verify credentials in `dbcon.java`
3. Test connection:
   ```powershell
   mysql -u root -p6677
   ```

### ❌ Issue: "404 Not Found"
**Solution:**
- Check URL has correct context path: `/saaslogin/`
- Correct: `http://localhost:8080/saaslogin/login.jsp`
- Wrong: `http://localhost:8080/login.jsp`

### ❌ Issue: "ClassNotFoundException: com.mysql.cj.jdbc.Driver"
**Solution:**
- Maven dependencies missing
- Run in IDE: Right-click `pom.xml` → Maven → Reimport
- Or: `mvn clean install`

### ❌ Issue: "Port 8080 already in use"
**Solution:**
```powershell
# Find process using port 8080
netstat -ano | findstr :8080

# Kill process (replace PID)
taskkill /PID <PID> /F

# Or change Tomcat port in server.xml
```

### ❌ Issue: Email not sending
**Solution:**
1. Check `EmailServices.java` credentials
2. For Gmail:
   - Enable 2-Step Verification
   - Generate App Password: https://myaccount.google.com/apppasswords
   - Use App Password in `SENDER_PASSWORD`

---

## 📁 Project Structure

```
saaslogin/
├── src/main/
│   ├── java/com/
│   │   ├── dao/
│   │   │   └── dbcon.java          # Database connection
│   │   ├── Model/
│   │   │   └── User.java           # User model
│   │   ├── Service/
│   │   │   └── EmailServices.java  # Email sender
│   │   └── servlet/
│   │       ├── RegisterServlet.java
│   │       ├── LoginServlet.java
│   │       ├── ForgotServlet.java
│   │       ├── ResetServlet.java
│   │       └── LogoutServlet.java
│   └── webapp/
│       ├── *.jsp                    # Web pages
│       ├── css/style.css            # Styles
│       └── WEB-INF/
│           └── web.xml              # Servlet config
├── pom.xml                          # Maven config
├── database.sql                     # Database setup
└── SETUP_GUIDE.md                   # This file
```

---

## 🔒 Security Notes

1. **Password Hashing**: BCrypt with salt ✅
2. **SQL Injection**: Using PreparedStatements ✅
3. **Session Management**: HttpSession with proper invalidation ✅
4. **Reset Token Expiry**: 15 minutes ✅

**Production Recommendations:**
- Change database password
- Use environment variables for sensitive data
- Enable HTTPS
- Add CSRF protection
- Implement rate limiting

---

## 🎯 Features Implemented

- ✅ User Registration with email validation
- ✅ Secure Login with BCrypt password hashing
- ✅ Password Reset via email with time-limited tokens
- ✅ Session Management
- ✅ Account expiration tracking (30-day trial)
- ✅ Dashboard with user info
- ✅ Logout functionality

---

## 📞 Support

**Logs Location:**
- Tomcat Logs: `<TOMCAT_HOME>/logs/catalina.out`
- Application Logs: Check console output

**Debug Mode:**
- All servlets have `System.out.println()` statements
- Check console for detailed execution flow

**Database Issues:**
```sql
-- Check users table
SELECT * FROM users;

-- Check reset tokens
SELECT * FROM password_resets;

-- Clear expired tokens
DELETE FROM password_resets WHERE expires_at < NOW();
```

---

## ✅ Verification Checklist

Before reporting issues, verify:
- [ ] MySQL service is running
- [ ] Database `saas_auth_system` exists
- [ ] Tables `users` and `password_resets` exist
- [ ] Tomcat is running on port 8080
- [ ] WAR/Exploded artifact is deployed
- [ ] No errors in `catalogs.out` log
- [ ] URL includes `/saaslogin/` context path
- [ ] Browser cache cleared if testing changes

---

## 🚀 Quick Start Commands

```powershell
# 1. Import Database
mysql -u root -p6677 < database.sql

# 2. Build Project
mvn clean package

# 3. Deploy to Tomcat
copy target\saaslogin.war "C:\Program Files\Apache Tomcat 9.0\webapps\"

# 4. Start Tomcat
cd "C:\Program Files\Apache Tomcat 9.0\bin"
.\startup.bat

# 5. Open Browser
start http://localhost:8080/saaslogin/login.jsp
```

---

**🎉 You're all set! The application should now be running successfully.**

If you encounter any issues, check the logs and refer to the troubleshooting section above.
