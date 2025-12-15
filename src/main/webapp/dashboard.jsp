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

// DB Connection for Stats & Recent Users
int totalUsers = 0, activeUsers = 0, totalSubscriptions = 0;
List<Map<String, String>> recentUsers = new ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/saas_auth_system?useSSL=false&allowPublicKeyRetrieval=true",
        "root",
        "6677"
    );

    // Total Users
    PreparedStatement psTotal = con.prepareStatement("SELECT COUNT(*) FROM user");
    ResultSet rsTotal = psTotal.executeQuery();
    if (rsTotal.next()) totalUsers = rsTotal.getInt(1);

    // Active Users
    PreparedStatement psActive = con.prepareStatement("SELECT COUNT(*) FROM user WHERE status = 'ACTIVE'");
    ResultSet rsActive = psActive.executeQuery();
    if (rsActive.next()) activeUsers = rsActive.getInt(1);

    // Active Subscriptions (plan_end > now)
    PreparedStatement psSubs = con.prepareStatement("SELECT COUNT(*) FROM user WHERE plan_end > CURDATE()");
    ResultSet rsSubs = psSubs.executeQuery();
    if (rsSubs.next()) totalSubscriptions = rsSubs.getInt(1);

    // Recent Users (last 5 sign-ups)
    PreparedStatement psRecent = con.prepareStatement(
        "SELECT full_name, email, DATE_FORMAT(entry_date, '%d-%m-%Y %h:%i %p') AS joined FROM user ORDER BY entry_date DESC LIMIT 5"
    );
    ResultSet rsRecent = psRecent.executeQuery();
    while (rsRecent.next()) {
        Map<String, String> ru = new HashMap<>();
        ru.put("name", rsRecent.getString("full_name"));
        ru.put("email", rsRecent.getString("email"));
        ru.put("joined", rsRecent.getString("joined"));
        recentUsers.add(ru);
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
    <title>Dashboard - Sparkera Account </title>
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* CSS Variables matching dashboard */
        :root {
            --primary-orange: #FF6B35;
            --orange-light: #FF8C42;
            --orange-dark: #E55A2B;
            --orange-bg: #FFF5F2;
            --bg-white: #FFFFFF;
            --bg-light: #F9FAFB;
            --text-primary: #1F2937;
            --text-secondary: #6B7280;
            --border-color: #E5E7EB;
            --box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            --box-shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --border-radius: 0.75rem;
            --transition-ease: all 0.3s ease;
        }
        /* Dashboard Specific Styles */
        .overview-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .stat-card {
            background: var(--bg-white);
            padding: 1.5rem;
            border-radius: var(--border-radius);
            text-align: center;
            box-shadow: var(--box-shadow);
            transition: var(--transition-ease);
        }
        .stat-card:hover {
            transform: translateY(-4px);
        }
        .stat-icon {
            font-size: 1.5rem;
            color: var(--primary-orange);
            margin-bottom: 0.5rem;
        }
        .stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }
        .stat-label {
            color: var(--text-secondary);
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .action-btn {
            background: var(--bg-white);
            border: 2px solid var(--border-color);
            padding: 1.25rem;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: var(--transition-ease);
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.5rem;
            color: var(--text-primary);
            text-decoration: none;
            font-weight: 500;
        }
        .action-btn:hover {
            border-color: var(--primary-orange);
            transform: translateY(-2px);
            box-shadow: var(--box-shadow);
        }
        .action-btn i {
            font-size: 1.75rem;
            color: var(--primary-orange);
        }
        .content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 1.5rem;
        }
        .recent-activity-section h3, .charts-section h4 {
            color: var(--text-primary);
            margin-bottom: 1rem;
        }
        .table-container {
            background: var(--bg-white);
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--box-shadow);
            margin-bottom: 1rem;
        }
        .recent-activity-section table th {
            background-color: #FFF5F2;
            color: var(--primary-orange);
            font-weight: 600;
        }
        .status-active {
            color: #4CAF50;
            font-weight: 600;
            background: #d4edda;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
        }
        .view-all-btn {
            background: var(--primary-orange);
            color: var(--bg-white);
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: var(--transition-ease);
            display: block;
            margin: 0 auto;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.025em;
        }
        .view-all-btn:hover {
            background: var(--orange-light);
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(255, 107, 53, 0.2);
        }
        .chart-wrapper {
            background: var(--bg-white);
            padding: 1.5rem;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
        }
        .chart-wrapper h4 {
            text-align: center;
            margin-bottom: 1rem;
        }
        canvas {
            max-height: 300px;
        }
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .modal-content {
            background: var(--bg-white);
            padding: 1.5rem;
            border-radius: var(--border-radius);
            max-width: 400px;
            width: 90%;
            box-shadow: var(--box-shadow);
        }
        /* Top Bar - Orange Title Bar */
        .top-bar {
            background: var(--primary-orange);
            color: white;
            padding: 0.5rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--box-shadow);
            border-bottom: 1px solid var(--orange-dark);
        }
        .top-bar-left {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .logo {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            color: white;
            font-weight: 700;
            font-size: 1.25rem;
        }
        .logo i {
            font-size: 1.5rem;
        }
        .hamburger {
            background: none;
            border: none;
            color: white;
            font-size: 1.25rem;
            cursor: pointer;
            padding: 0.25rem;
            border-radius: 0.25rem;
            transition: var(--transition-ease);
        }
        .hamburger:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        .top-bar-center {
            flex: 1;
            text-align: center;
        }
        .top-bar-center h1 {
            font-size: 1.25rem;
            font-weight: 600;
            margin: 0;
        }
        .top-bar-right {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .top-bar-icon {
            color: white;
            font-size: 1.125rem;
            cursor: pointer;
            padding: 0.25rem;
            border-radius: 0.25rem;
            transition: var(--transition-ease);
        }
        .top-bar-icon:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        .date-info {
            font-size: 0.75rem;
            white-space: nowrap;
        }
        @media (max-width: 768px) {
            .content-grid {
                grid-template-columns: 1fr;
            }
            .overview-stats, .quick-actions {
                grid-template-columns: 1fr;
            }
            .top-bar {
                padding: 0.5rem 1rem;
            }
            .top-bar-left, .top-bar-right {
                gap: 0.5rem;
            }
            .top-bar-center h1 {
                font-size: 1rem;
            }
            .logo {
                font-size: 1rem;
            }
            .logo i {
                font-size: 1.25rem;
            }
        }
    </style>
    <script>
        function openModal(id) {
            document.getElementById(id).style.display = 'flex';
        }
        function closeModal(id) {
            document.getElementById(id).style.display = 'none';
        }
        // Charts
        document.addEventListener('DOMContentLoaded', function() {
            // Revenue Chart
            const revenueCtx = document.getElementById('revenueChart').getContext('2d');
            new Chart(revenueCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Q1', 'Q2', 'Q3', 'Q4'],
                    datasets: [{
                        data: [9000, 10000, 12000, 7292],
                        backgroundColor: ['#FF6B35', '#FF8C42', '#FFB347', '#FFCA28']
                    }]
                },
                options: {
                    responsive: true,
                    cutout: '60%',
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });

            // Subscription Chart
            const subscriptionCtx = document.getElementById('subscriptionChart').getContext('2d');
            new Chart(subscriptionCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Active', 'Expired'],
                    datasets: [{
                        data: [6670, 1000],
                        backgroundColor: ['#4CAF50', '#FF6B35']
                    }]
                },
                options: {
                    responsive: true,
                    cutout: '60%',
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        });
        function toggleSidebar() {
            const sidebar = document.querySelector('.sidebar');
            sidebar.style.transform = sidebar.style.transform === 'translateX(-100%)' ? 'translateX(0)' : 'translateX(-100%)';
        }
    </script>
</head>
<body>
    <div class="app-wrapper">
        <!-- Top Bar - Orange Title Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <a href="<%= contextPath %>/dashboard.jsp" class="logo">
                    <i class="fas fa-cloud"></i>
                    <span>Sparkera Account</span>
                </a>
                <button class="hamburger" onclick="toggleSidebar()">
                    <i class="fas fa-bars"></i>
                </button>
            </div>
            <div class="top-bar-center">
                <h1>Dashboard</h1>
            </div>
            <div class="top-bar-right">
                <div class="top-bar-icon">
                    <i class="fas fa-bell"></i>
                </div>
                <div class="date-info">
                    <%= dayFormatter.format(currentDate) %>, <%= formatter.format(currentDate) %>
                </div>
                <div class="top-bar-icon">
                    <i class="fas fa-user-circle"></i>
                </div>
            </div>
        </header>
        <div class="main-layout">
            <!-- Sidebar -->
            <aside class="sidebar">
                <nav class="sidebar-nav">
                    <ul>
                        <li><a href="<%= contextPath %>/dashboard.jsp" class="nav-link active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                        <li><a href="<%= contextPath %>/user-panel.jsp" class="nav-link"><i class="fas fa-users"></i> Users</a></li>
                        <li><a href="#" class="nav-link"><i class="fas fa-chart-line"></i> Analytics</a></li>
                        <li><a href="#" class="nav-link"><i class="fas fa-credit-card"></i> Subscriptions</a></li>
                        <li><a href="#" class="nav-link"><i class="fas fa-cog"></i> Settings</a></li>
                        <li><a href="<%= contextPath %>/logout" class="nav-link"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                    </ul>
                </nav>
                <div class="plan-section">
                    <h4>Professional Plan</h4>
                    <p>15 days remaining</p>
                </div>
            </aside>
            <!-- Main Content -->
            <main class="main-content">
                <!-- Overview Stats -->
                <section class="overview-stats">
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-users"></i></div>
                        <div class="stat-value"><%= totalUsers %></div>
                        <div class="stat-label">Total Users</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                        <div class="stat-value"><%= activeUsers %></div>
                        <div class="stat-label">Active Users</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-credit-card"></i></div>
                        <div class="stat-value"><%= totalSubscriptions %></div>
                        <div class="stat-label">Subscriptions</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fas fa-dollar-sign"></i></div>
                        <div class="stat-value">$37,292</div>
                        <div class="stat-label">Total Revenue</div>
                    </div>
                </section>
                <!-- Quick Actions -->
                <section class="quick-actions">
                    <button class="action-btn" onclick="location.href='<%= contextPath %>/user-panel.jsp'">
                        <i class="fas fa-user-plus"></i>
                        <span>Add User</span>
                    </button>
                    <button class="action-btn" onclick="openModal('subscription-modal')">
                        <i class="fas fa-plus-square"></i>
                        <span>New Subscription</span>
                    </button>
                    <button class="action-btn" onclick="openModal('income-modal')">
                        <i class="fas fa-arrow-up"></i>
                        <span>Record Income</span>
                    </button>
                    <button class="action-btn" onclick="openModal('expense-modal')">
                        <i class="fas fa-arrow-down"></i>
                        <span>Record Expense</span>
                    </button>
                </section>
                <div class="content-grid">
                    <!-- Revenue Overview Chart in place of Recent Sign-ups -->
                    <section class="recent-activity-section">
                        <h3>Revenue Overview</h3>
                        <div class="chart-wrapper">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </section>
                    <!-- Charts Section -->
                    <section class="charts-section">
                        <div class="chart-wrapper">
                            <h4>Subscription Trends</h4>
                            <canvas id="subscriptionChart"></canvas>
                        </div>
                    </section>
                </div>
            </main>
        </div>
    </div>
    <!-- Modals -->
    <div id="subscription-modal" class="modal">
        <div class="modal-content">
            <h3>New Subscription</h3>
            <p>Modal content for adding subscription...</p>
            <button class="btn" onclick="closeModal('subscription-modal')">Close</button>
        </div>
    </div>
    <div id="income-modal" class="modal">
        <div class="modal-content">
            <h3>Record Income</h3>
            <p>Modal content for recording income...</p>
            <button class="btn" onclick="closeModal('income-modal')">Close</button>
        </div>
    </div>
    <div id="expense-modal" class="modal">
        <div class="modal-content">
            <h3>Record Expense</h3>
            <p>Modal content for recording expense...</p>
            <button class="btn" onclick="closeModal('expense-modal')">Close</button>
        </div>
    </div>
</body>
</html>