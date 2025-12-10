# 🚀 SaaS Login System - Complete Java Web Application

A full-featured authentication system built with Java Servlets, JSP, MySQL, and deployed on Apache Tomcat.

## ✨ Features

- ✅ **User Registration** with email validation
- ✅ **Secure Login** with BCrypt password hashing
- ✅ **Password Reset** via email with time-limited tokens
- ✅ **Session Management** for authenticated users
- ✅ **Account Expiration** tracking (30-day trial)
- ✅ **Responsive Design** with modern CSS
- ✅ **SQL Injection Protection** using PreparedStatements
- ✅ **Comprehensive Error Handling** with user-friendly messages

## 🛠️ Tech Stack

- **Backend:** Java Servlets 4.0 (Java EE 8)
- **Frontend:** JSP, HTML5, CSS3
- **Database:** MySQL 8.0+
- **Server:** Apache Tomcat 9.0
- **Build Tool:** Maven 3.6+
- **Security:** BCrypt password hashing
- **Email:** JavaMail API (SMTP)

## 📁 Project Structure

```
saaslogin/
├── src/main/
│   ├── java/com/
│   │   ├── dao/
│   │   │   └── dbcon.java              # Database connection
│   │   ├── Model/
│   │   │   └── User.java               # User entity
│   │   ├── Service/
│   │   │   └── EmailServices.java      # Email service
│   │   └── servlet/
│   │       ├── RegisterServlet.java    # User registration
│   │       ├── LoginServlet.java       # User authentication
│   │       ├── ForgotServlet.java      # Password reset request
│   │       ├── ResetServlet.java       # Password update
│   │       └── LogoutServlet.java      # Session cleanup
│   └── webapp/
│       ├── css/
│       │   └── style.css               # Styling
│       ├── WEB-INF/
│       │   └── web.xml                 # Servlet configuration
│       ├── index.jsp                   # Entry point
│       ├── login.jsp                   # Login page
│       ├── register.jsp                # Registration page
│       ├── forgot-password.jsp         # Password reset request
│       ├── reset-password.jsp          # Password reset form
│       └── dashboard.jsp               # User dashboard
├── database.sql                        # Database schema
├── pom.xml                             # Maven configuration
├── deploy.bat                          # Quick deployment script
├── SETUP_GUIDE.md                      # Detailed setup instructions
├── TESTING_GUIDE.md                    # Testing and troubleshooting
└── README.md                           # This file
```

## ⚡ Quick Start

### Prerequisites

1. **Java JDK 8+** - [Download](https://www.oracle.com/java/technologies/downloads/)
2. **Apache Tomcat 9** - [Download](https://tomcat.apache.org/download-90.cgi)
3. **MySQL 8.0+** - [Download](https://dev.mysql.com/downloads/mysql/)
4. **Maven 3.6+** (Optional) - [Download](https://maven.apache.org/download.cgi)

### Installation Steps

#### 1️⃣ Setup Database

```powershell
# Start MySQL and import database
mysql -u root -p < database.sql
```

Or use MySQL Workbench:
- File → Run SQL Script
- Select `database.sql`
- Execute

#### 2️⃣ Configure Database Connection

Edit `src/main/java/com/dao/dbcon.java` if needed:
```java
private static final String url = "jdbc:mysql://localhost:3306/saas_auth_system";
private static final String user = "root";
private static final String password = "6677";  // Change if needed
```

#### 3️⃣ Deploy to Tomcat

**Option A: Using IntelliJ IDEA**
1. Open project in IntelliJ IDEA
2. Run → Edit Configurations → + → Tomcat Server → Local
3. Configure Tomcat home directory
4. Deployment tab: Add `saaslogin:war exploded`
5. Click Run ▶️

**Option B: Using Eclipse**
1. Import as Maven project
2. Right-click → Run As → Run on Server
3. Select Tomcat v9.0

**Option C: Quick Deploy Script**
```powershell
# Run the automated deploy script
.\deploy.bat
```

**Option D: Manual Deployment**
```powershell
# Build WAR file
mvn clean package

# Copy to Tomcat
copy target\saaslogin.war "C:\Program Files\Apache Tomcat 9.0\webapps\"

# Start Tomcat
cd "C:\Program Files\Apache Tomcat 9.0\bin"
.\startup.bat
```

#### 4️⃣ Access Application

Open browser: **http://localhost:8080/saaslogin/login.jsp**

## 🧪 Testing

### Test User Credentials
- **Email:** test@example.com
- **Password:** password123

### Test Registration
1. Go to `http://localhost:8080/saaslogin/register.jsp`
2. Fill in the form (password min 8 characters)
3. Submit and verify redirect to login

### Test Password Reset
1. Go to `http://localhost:8080/saaslogin/forgot-password.jsp`
2. Enter registered email
3. Check console for reset URL (or email if configured)
4. Use reset link to set new password

For comprehensive testing guide, see **[TESTING_GUIDE.md](TESTING_GUIDE.md)**

## 🔒 Security Features

- **BCrypt Password Hashing:** Passwords never stored in plain text
- **SQL Injection Prevention:** All queries use PreparedStatements
- **Session Management:** Secure HttpSession with proper invalidation
- **Token Expiry:** Password reset tokens expire in 15 minutes
- **Input Validation:** Server-side and client-side validation
- **XSS Protection:** JSP automatic escaping

## 📡 API Endpoints

| Endpoint | Method | Description | Success Redirect |
|----------|--------|-------------|------------------|
| `/register` | POST | Create new user account | `login.jsp?registered=1` |
| `/login` | POST | Authenticate user | `dashboard.jsp` |
| `/forgot-password` | POST | Request password reset | `forgot-password.jsp?success=1` |
| `/reset-password` | POST | Update password | `login.jsp?reset=success` |
| `/logout` | GET | End user session | `login.jsp` |

## 🗄️ Database Schema

### Users Table
```sql
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
```

### Password Resets Table
```sql
CREATE TABLE password_resets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔧 Configuration

### Email Service (Optional)

To enable password reset emails, update `src/main/java/com/Service/EmailServices.java`:

```java
private static final String SENDER_EMAIL = "your-email@gmail.com";
private static final String SENDER_PASSWORD = "your-app-password";
```

**For Gmail:**
1. Enable 2-Step Verification
2. Generate App Password: https://myaccount.google.com/apppasswords
3. Use the generated password in `SENDER_PASSWORD`

## 🐛 Troubleshooting

### Common Issues

**❌ "Cannot connect to database"**
- Verify MySQL is running: `Get-Service MySQL*`
- Check credentials in `dbcon.java`
- Test: `mysql -u root -p6677`

**❌ "404 Not Found"**
- Use correct URL: `http://localhost:8080/saaslogin/login.jsp`
- Ensure `/saaslogin/` context path is included

**❌ "500 Internal Server Error"**
- Check Tomcat logs: `<TOMCAT_HOME>/logs/catalina.out`
- Verify database tables exist
- Check console output for detailed errors

**❌ "ClassNotFoundException: com.mysql.cj.jdbc.Driver"**
- Maven dependencies issue
- Run: `mvn clean install`
- Rebuild project in IDE

For detailed troubleshooting, see **[TESTING_GUIDE.md](TESTING_GUIDE.md)**

## 📚 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete setup instructions
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testing and troubleshooting
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Deployment options
- **[FILE_LIST.md](FILE_LIST.md)** - Complete file listing and code overview

## 📊 Project Statistics

- **5 Servlets:** Registration, Login, Forgot, Reset, Logout
- **6 JSP Pages:** Index, Login, Register, Forgot, Reset, Dashboard
- **1 Service:** Email service for password reset
- **1 DAO:** Database connection management
- **1 Model:** User entity
- **2 Database Tables:** Users and password resets
- **7 Maven Dependencies:** Servlet, JSP, JSTL, MySQL, BCrypt, JavaMail

## 🎯 Use Cases

1. **SaaS Application Authentication:** Ready-to-use login system
2. **Learning Project:** Complete example of Servlet/JSP application
3. **Starter Template:** Base for building web applications
4. **Portfolio Project:** Demonstrates full-stack Java web development

## 🔄 Workflow

```
User Registration → Email Validation → BCrypt Hashing → Database Storage
                                                                ↓
User Login → Credential Verification → Session Creation → Dashboard Access
     ↓
Forgot Password → Email Verification → Token Generation → Email Sent
                                                                ↓
Reset Link Clicked → Token Validation → New Password → BCrypt → Update DB
                                                                ↓
Login with New Password → Dashboard
```

## ⚠️ Important Notes

1. **This is NOT a standalone Java application** - It's a web application that runs on Tomcat
2. **No `main()` method** - Servlets are invoked by the web container
3. **Context path required** - Always use `/saaslogin/` in URLs
4. **Database must exist** - Run `database.sql` before first use
5. **Email optional** - Password reset works without email (check console for reset link)

## 🚀 Deployment Options

### Development
- IntelliJ IDEA with Tomcat plugin (Recommended)
- Eclipse with WTP
- NetBeans with GlassFish/Tomcat

### Production
- Standalone Tomcat server
- Docker container
- Cloud platforms (AWS, Azure, GCP)
- Managed Tomcat hosting

## 📝 License

This project is for educational purposes. Feel free to use and modify.

## 👤 Author

**Jenil Gabani**
- Email: jenilgabani92@gmail.com
- GitHub: [JENILGABANII](https://github.com/JENILGABANII)

## 🤝 Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues or questions:
1. Check **[TESTING_GUIDE.md](TESTING_GUIDE.md)** for troubleshooting
2. Review Tomcat logs in `<TOMCAT_HOME>/logs/catalina.out`
3. Verify database connection and tables
4. Check console output for detailed error messages

---

## ✅ Verification Checklist

Before running, ensure:
- [ ] MySQL service is running
- [ ] Database `saas_auth_system` created
- [ ] Tables `users` and `password_resets` exist
- [ ] `dbcon.java` has correct credentials
- [ ] Tomcat 9 is installed
- [ ] Project built successfully (`mvn clean package`)
- [ ] WAR deployed to Tomcat webapps
- [ ] Accessing `http://localhost:8080/saaslogin/login.jsp`

---

**🎉 Your complete SaaS Login System is ready to deploy!**

For step-by-step guidance, start with **[SETUP_GUIDE.md](SETUP_GUIDE.md)**
