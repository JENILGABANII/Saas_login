<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");

    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    LocalDate currentDate = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("EEEE");

    String avatarLetter = userName != null ? userName.substring(0, 1).toUpperCase() : "U";

    // DB Connection for Stats & Reminders
    int totalUsers = 0, activeUsers = 0, inactiveUsers = 0, totalSubscriptions = 0;
    List<Map<String, String>> reminders = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/saas_auth_system?useSSL=false&allowPublicKeyRetrieval=true",
            "root",
            "6677"
        );

        // Total Users
        PreparedStatement psTotal = con.prepareStatement("SELECT COUNT(*) FROM users");
        ResultSet rsTotal = psTotal.executeQuery();
        if (rsTotal.next()) totalUsers = rsTotal.getInt(1);

        // Active/Inactive
        PreparedStatement psActive = con.prepareStatement("SELECT COUNT(*) FROM users WHERE status = 'ACTIVE'");
        ResultSet rsActive = psActive.executeQuery();
        if (rsActive.next()) activeUsers = rsActive.getInt(1);
        inactiveUsers = totalUsers - activeUsers;

        // Total Subscriptions (assuming plan_end > now)
        PreparedStatement psSubs = con.prepareStatement("SELECT COUNT(*) FROM users WHERE plan_end > CURDATE()");
        ResultSet rsSubs = psSubs.executeQuery();
        if (rsSubs.next()) totalSubscriptions = rsSubs.getInt(1);

        // Upcoming Reminders (expiring in 30 days)
        PreparedStatement psRem = con.prepareStatement(
            "SELECT full_name, email, plan_end AS reminder_date FROM users WHERE plan_end <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) AND plan_end > CURDATE() ORDER BY plan_end LIMIT 5"
        );
        ResultSet rsRem = psRem.executeQuery();
        while (rsRem.next()) {
            Map<String, String> rem = new HashMap<>();
            rem.put("name", rsRem.getString("full_name"));
            rem.put("email", rsRem.getString("email"));
            rem.put("date", rsRem.getString("reminder_date"));
            reminders.add(rem);
        }
        con.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>DB Error: " + e.getMessage() + "</p>");
    }

    String contextPath = request.getContextPath();
    if (contextPath.equals("/")) contextPath = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Orange SaaS</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar (GoAccount-style: Icons for sections) -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <a href="<%= contextPath %>/dashboard.jsp" class="logo">
                    <div class="logo-icon"><i class="fas fa-cloud"></i></div>
                    <span>Orange SaaS</span>
                </a>
            </div>
            <div class="user-profile">
                <div class="user-avatar"><%= avatarLetter %></div>
                <div class="user-info">
                    <h4><%= userName %></h4>
                    <p><%= userEmail %></p>
                    <span class="status-badge"><i class="fas fa-circle" style="font-size:8px;"></i> Active</span>
                </div>
            </div>
            <nav class="nav-menu">
                <ul>
                    <li class="nav-item"><a href="<%= contextPath %>/dashboard.jsp" class="nav-link active"><i class="fas fa-tachometer-alt nav-icon"></i><span>Dashboard</span></a></li>
                    <li class="nav-item"><a href="<%= contextPath %>/user-panel.jsp" class="nav-link"><i class="fas fa-users nav-icon"></i><span>Users</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-chart-line nav-icon"></i><span>Analytics</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-credit-card nav-icon"></i><span>Billing</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-cog nav-icon"></i><span>Settings</span></a></li>
                    <li class="nav-item"><a href="<%= contextPath %>/logout" class="nav-link"><i class="fas fa-sign-out-alt nav-icon"></i><span>Logout</span></a></li>
                </ul>
            </nav>
            <div class="plan-info">
                <h4>Professional Plan</h4>
                <p>15 days remaining</p>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <!-- Top Nav -->
            <div class="top-nav">
                <div class="search-box">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" placeholder="Search users, subscriptions...">
                </div>
                <div class="user-actions">
                    <div class="notification-icon"><i class="fas fa-bell"></i><span class="notification-badge">3</span></div>
                    <div class="date-display">
                        <i class="far fa-calendar-alt"></i>
                        <span><%= currentDate.format(dayFormatter) %>, <%= currentDate.format(formatter) %></span>
                    </div>
                </div>
            </div>

            <!-- Welcome & Balance -->
            <div style="background: white; padding: 25px; border-radius: var(--radius); box-shadow: var(--shadow); margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h2>Welcome back, <%= userName %>! 👋</h2>
                    <p>Your balance: $3,489.37</p>
                </div>
                <div style="background: #E8F5E8; padding: 10px 20px; border-radius: 25px; color: #2E7D32;">Login: 04/12/2025 18:03</div>
            </div>

            <!-- Total Stats -->
            <div class="stats-totals">
                <div class="total-card">
                    <div class="total-value" style="color: var(--primary);">776,064</div>
                    <div class="total-label">Total Users</div>
                </div>
                <div class="total-card">
                    <div class="total-value" style="color: green;">6,670</div>
                    <div class="total-label">Active Subscriptions</div>
                </div>
                <div class="total-card">
                    <div class="total-value" style="color: blue;">37,292</div>
                    <div class="total-label">Total Income</div>
                </div>
                <div class="total-card">
                    <div class="total-value" style="color: #D32F2F;">2,364</div>
                    <div class="total-label">Total Expenses</div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="action-buttons">
                <div class="action-card" onclick="location.href='user-panel.jsp'">
                    <i class="fas fa-user-plus action-icon"></i>
                    <div class="action-label">Add User</div>
                </div>
                <div class="action-card" onclick="location.href='#add-subscription'">
                    <i class="fas fa-credit-card action-icon"></i>
                    <div class="action-label">Add Subscription</div>
                </div>
                <div class="action-card" onclick="location.href='#add-income'">
                    <i class="fas fa-plus-circle action-icon"></i>
                    <div class="action-label">Add Income</div>
                </div>
                <div class="action-card" onclick="location.href='#add-expense'">
                    <i class="fas fa-minus-circle action-icon"></i>
                    <div class="action-label">Add Expense</div>
                </div>
            </div>

            <!-- Upcoming Reminders -->
            <div style="background: white; padding: 25px; border-radius: var(--radius); box-shadow: var(--shadow); margin-bottom: 30px;">
                <h3 style="margin-bottom: 20px; color: var(--secondary);">Upcoming Reminders</h3>
                <table class="reminders-table">
                    <tr>
                        <th>User Name</th>
                        <th>Email</th>
                        <th>Reminder Date</th>
                        <th>Amount</th>
                        <th>Due</th>
                    </tr>
                    <% if (reminders.isEmpty()) { %>
                        <tr><td colspan="5" class="no-data">No upcoming reminders</td></tr>
                    <% } else { for (Map<String, String> rem : reminders) { %>
                        <tr>
                            <td><%= rem.get("name") %></td>
                            <td><%= rem.get("email") %></td>
                            <td><%= rem.get("date") %></td>
                            <td>$99.99</td>
                            <td>Overdue</td>
                        </tr>
                    <% } } %>
                </table>
                <button style="margin-top: 15px; background: var(--primary); color: white; padding: 10px 20px; border: none; border-radius: 8px;">View All</button>
            </div>

            <!-- Charts -->
            <div class="charts-row">
                <div class="chart-container">
                    <div class="chart-title">Income Statistics</div>
                    <canvas id="incomeChart" width="400" height="200"></canvas>
                </div>
                <div class="chart-container">
                    <div class="chart-title">Expense Statistics</div>
                    <canvas id="expenseChart" width="400" height="200"></canvas>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Semi-circle Charts (doughnut with rotation for semi-circle effect)
        const incomeCtx = document.getElementById('incomeChart').getContext('2d');
        new Chart(incomeCtx, {
            type: 'doughnut',
            data: { labels: ['Income', 'Other'], datasets: [{ data: [37292, 10000], backgroundColor: ['#FF6B35', '#FFE0CC'] }] },
            options: { cutout: '50%', rotation: -90, circumference: 180, plugins: { legend: { display: false } } }
        });

        const expenseCtx = document.getElementById('expenseChart').getContext('2d');
        new Chart(expenseCtx, {
            type: 'doughnut',
            data: { labels: ['Expense', 'Other'], datasets: [{ data: [2364, 5000], backgroundColor: ['#FF6B35', '#FFE0CC'] }] },
            options: { cutout: '50%', rotation: -90, circumference: 180, plugins: { legend: { display: false } } }
        });
    </script>
</body>
</html>