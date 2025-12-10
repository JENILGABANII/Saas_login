# SaaS Login Application - Deployment Guide

## ⚠️ IMPORTANT: This is a Web Application

**Servlets DON'T have a `main()` method!** They run inside a web server (Tomcat).

## Prerequisites

1. **Apache Tomcat 9** - [Download](https://tomcat.apache.org/download-90.cgi)
2. **MySQL Database** - Running on localhost:3306
3. **Java JDK 8 or higher**

## Quick Setup Guide

### 1️⃣ Setup Database

Create the database and tables:

```sql
CREATE DATABASE saas_login;
USE saas_login;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    plan_start DATE NOT NULL,
    plan_end DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE password_resets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2️⃣ Configure Database Connection

Edit `src/main/java/com/dao/dbcon.java` and update:
```java
private static final String URL = "jdbc:mysql://localhost:3306/saas_login";
private static final String USER = "root";
private static final String PASSWORD = "your_password";
```

### 3️⃣ Deploy Using IDE (IntelliJ IDEA / Eclipse)

#### **IntelliJ IDEA:**
1. Click **Run** → **Edit Configurations**
2. Click **+** → **Tomcat Server** → **Local**
3. Configure Tomcat Home directory
4. In **Deployment** tab: Click **+** → **Artifact** → Select `saaslogin:war exploded`
5. Application context: `/saaslogin`
6. Click **Run** ▶️

#### **Eclipse:**
1. Right-click project → **Run As** → **Run on Server**
2. Select **Tomcat v9.0 Server**
3. Click **Finish**

### 4️⃣ Deploy Using WAR File (Manual)

If you have Maven installed:

```bash
# Build WAR file
mvn clean package

# Copy to Tomcat
copy target\saaslogin.war C:\path\to\tomcat\webapps\

# Start Tomcat
cd C:\path\to\tomcat\bin
startup.bat
```

If you DON'T have Maven:
1. Download [Apache Maven](https://maven.apache.org/download.cgi)
2. Extract and add `bin` folder to PATH
3. Run commands above

### 5️⃣ Access Application

Open browser: **http://localhost:8080/saaslogin/login.jsp**

## Testing the Application

1. **Register**: http://localhost:8080/saaslogin/register.jsp
2. **Login**: http://localhost:8080/saaslogin/login.jsp
3. **Forgot Password**: http://localhost:8080/saaslogin/forgot-password.jsp

## Common Issues

### ❌ "Main method not found"
- **Cause**: Trying to run servlet as Java application
- **Fix**: Deploy to Tomcat (see step 3)

### ❌ "Cannot find javax.servlet"
- **Cause**: Missing Tomcat libraries
- **Fix**: Add Tomcat as library in IDE

### ❌ "Connection refused"
- **Cause**: MySQL not running
- **Fix**: Start MySQL service

### ❌ "404 Not Found"
- **Cause**: Wrong URL or context path
- **Fix**: Use `/saaslogin/` prefix in URLs

## Email Configuration

Edit `src/main/java/com/Service/EmailServices.java`:
```java
private static final String EMAIL = "your-email@gmail.com";
private static final String PASSWORD = "your-app-password";
```

For Gmail: Enable "App Passwords" in Google Account settings.

## Project Structure

```
saaslogin/
├── src/main/
│   ├── java/com/
│   │   ├── servlet/      # Your servlets (NO main method needed!)
│   │   ├── dao/          # Database connection
│   │   ├── Model/        # Data models
│   │   └── Service/      # Email service
│   └── webapp/
│       ├── *.jsp         # Web pages
│       ├── css/          # Stylesheets
│       └── WEB-INF/
│           └── web.xml   # Servlet mappings
└── pom.xml               # Maven dependencies
```

## Support

If still not working:
1. Check Tomcat logs: `tomcat/logs/catalina.out`
2. Verify MySQL is running: `mysql -u root -p`
3. Test database connection from dbcon.java
4. Check Tomcat port (default: 8080)

---
✅ **Remember**: Web applications run on servers, not directly in Java!
