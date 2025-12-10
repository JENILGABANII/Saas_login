@echo off
REM =============================================
REM Quick Deploy Script for SaaS Login System
REM =============================================

echo.
echo ============================================
echo    SaaS Login System - Quick Deploy
echo ============================================
echo.

REM Check if Maven is available
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven is not installed or not in PATH
    echo.
    echo Please install Maven from: https://maven.apache.org/download.cgi
    echo.
    pause
    exit /b 1
)

echo [1/5] Cleaning previous build...
call mvn clean
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Maven clean failed
    pause
    exit /b 1
)

echo.
echo [2/5] Compiling source code...
call mvn compile
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed
    pause
    exit /b 1
)

echo.
echo [3/5] Building WAR file...
call mvn package
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)

echo.
echo [4/5] WAR file created successfully!
echo Location: target\saaslogin.war
echo.

REM Try to find Tomcat
set TOMCAT_HOME=
if exist "C:\Program Files\Apache Tomcat 9.0" set TOMCAT_HOME=C:\Program Files\Apache Tomcat 9.0
if exist "C:\Program Files\Apache Software Foundation\Tomcat 9.0" set TOMCAT_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0
if exist "C:\apache-tomcat-9.0" set TOMCAT_HOME=C:\apache-tomcat-9.0
if exist "%CATALINA_HOME%" set TOMCAT_HOME=%CATALINA_HOME%

if "%TOMCAT_HOME%"=="" (
    echo [WARNING] Tomcat installation not found automatically
    echo.
    echo Please copy manually:
    echo   FROM: %CD%\target\saaslogin.war
    echo   TO:   YOUR_TOMCAT_HOME\webapps\
    echo.
    pause
    exit /b 0
)

echo [5/5] Deploying to Tomcat...
echo Tomcat location: %TOMCAT_HOME%
echo.

REM Copy WAR to Tomcat
copy /Y target\saaslogin.war "%TOMCAT_HOME%\webapps\"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy WAR file
    echo Please copy manually to: %TOMCAT_HOME%\webapps\
    pause
    exit /b 1
)

echo.
echo ============================================
echo         Deployment Successful!
echo ============================================
echo.
echo WAR file deployed to: %TOMCAT_HOME%\webapps\
echo.
echo Next Steps:
echo 1. Make sure MySQL is running
echo 2. Import database.sql if not done already
echo 3. Start Tomcat:
echo    "%TOMCAT_HOME%\bin\startup.bat"
echo 4. Access application:
echo    http://localhost:8080/saaslogin/login.jsp
echo.
echo ============================================
echo.

pause
