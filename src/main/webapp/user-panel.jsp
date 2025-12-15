<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
String userEmail = (String) session.getAttribute("userEmail");
String userName = (String) session.getAttribute("userName");
Integer userId = (Integer) session.getAttribute("userId");
String entryBy = userName != null ? userName + " (Admin)" : "System Admin";
if (userEmail == null) {
    response.sendRedirect("login.jsp");
    return;
}
// Check if form was submitted to add or edit user
if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("action") != null) {
    String action = request.getParameter("action");
    if ("add".equals(action)) {
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String mobile = request.getParameter("mobile");
        String password = request.getParameter("password");
        String planEnd = request.getParameter("plan_end");
        String status = request.getParameter("status");
        String entryByParam = request.getParameter("entry_by");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/saas_auth_system?useSSL=false&allowPublicKeyRetrieval=true",
                "root", "6677"
            );
            // Check if user already exists
            String checkSql = "SELECT COUNT(*) FROM user WHERE email = ?";
            PreparedStatement psCheck = con.prepareStatement(checkSql);
            psCheck.setString(1, email);
            ResultSet rsCheck = psCheck.executeQuery();
            if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                // User already exists
                session.setAttribute("errorMessage", "User with this email already exists!");
            } else {
                // Insert new user
                String insertSql = "INSERT INTO user (full_name, email, mobile, password, plan_end, status, entry_by, entry_date) " +
                                   "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
                PreparedStatement psInsert = con.prepareStatement(insertSql);
                psInsert.setString(1, fullName);
                psInsert.setString(2, email);
                psInsert.setString(3, mobile);
                psInsert.setString(4, password);
                psInsert.setString(5, planEnd);
                psInsert.setString(6, status);
                psInsert.setString(7, entryByParam);
                int rowsAffected = psInsert.executeUpdate();
                if (rowsAffected > 0) {
                    session.setAttribute("successMessage", "User added successfully!");
                } else {
                    session.setAttribute("errorMessage", "Failed to add user!");
                }
            }
            con.close();
            // Redirect to avoid form resubmission
            response.sendRedirect(request.getContextPath() + "/user-panel.jsp");
            return;
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user-panel.jsp");
            return;
        }
    }
    else if ("edit".equals(action)) {
        String id = request.getParameter("id");
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String mobile = request.getParameter("mobile");
        String planEnd = request.getParameter("plan_end");
        String status = request.getParameter("status");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/saas_auth_system?useSSL=false&allowPublicKeyRetrieval=true",
                "root", "6677"
            );
            // Update user
            String updateSql = "UPDATE user SET full_name = ?, email = ?, mobile = ?, plan_end = ?, status = ?, updated_at = NOW() WHERE id = ?";
            PreparedStatement psUpdate = con.prepareStatement(updateSql);
            psUpdate.setString(1, fullName);
            psUpdate.setString(2, email);
            psUpdate.setString(3, mobile);
            psUpdate.setString(4, planEnd);
            psUpdate.setString(5, status);
            psUpdate.setString(6, id);
            int rowsAffected = psUpdate.executeUpdate();
            if (rowsAffected > 0) {
                session.setAttribute("successMessage", "User updated successfully!");
            } else {
                session.setAttribute("errorMessage", "Failed to update user!");
            }
            con.close();
            // Redirect to avoid form resubmission
            response.sendRedirect(request.getContextPath() + "/user-panel.jsp");
            return;
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user-panel.jsp");
            return;
        }
    }
    else if ("delete".equals(action)) {
        String id = request.getParameter("id");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/saas_auth_system?useSSL=false&allowPublicKeyRetrieval=true",
                "root", "6677"
            );
            // Delete user
            String deleteSql = "DELETE FROM user WHERE id = ?";
            PreparedStatement psDelete = con.prepareStatement(deleteSql);
            psDelete.setString(1, id);
            int rowsAffected = psDelete.executeUpdate();
            if (rowsAffected > 0) {
                session.setAttribute("successMessage", "User deleted successfully!");
            } else {
                session.setAttribute("errorMessage", "Failed to delete user!");
            }
            con.close();
            // Redirect to avoid form resubmission
            response.sendRedirect(request.getContextPath() + "/user-panel.jsp");
            return;
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user-panel.jsp");
            return;
        }
    }
}
// DB Connection for Users List
List<Map<String, String>> users = new ArrayList<>();
int totalUsers = 0;
String searchName = request.getParameter("search_name");
String searchEmail = request.getParameter("search_email");
String searchMobile = request.getParameter("search_mobile");
String searchStatus = request.getParameter("status");
String whereClause = "WHERE 1=1";
List<String> params = new ArrayList<>();
if (searchName != null && !searchName.trim().isEmpty()) {
    whereClause += " AND full_name LIKE ?";
    params.add("%" + searchName.trim() + "%");
}
if (searchEmail != null && !searchEmail.trim().isEmpty()) {
    whereClause += " AND email LIKE ?";
    params.add("%" + searchEmail.trim() + "%");
}
if (searchMobile != null && !searchMobile.trim().isEmpty()) {
    whereClause += " AND mobile LIKE ?";
    params.add("%" + searchMobile.trim() + "%");
}
if (searchStatus != null && !searchStatus.trim().isEmpty()) {
    whereClause += " AND status = ?";
    params.add(searchStatus);
}
// Pagination
String pageStr = request.getParameter("page");
int currentPage = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;
int limit = 10;
int offset = (currentPage - 1) * limit;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/saas_auth_system?useSSL=false&allowPublicKeyRetrieval=true",
        "root", "6677"
    );
    // Check if mobile column exists
    boolean mobileExists = false;
    ResultSet checkMobile = con.createStatement().executeQuery(
        "SHOW COLUMNS FROM user WHERE Field = 'mobile'"
    );
    if (checkMobile.next()) {
        mobileExists = true;
    }
    // Total count for pagination
    String countSql = "SELECT COUNT(*) FROM user " + whereClause;
    PreparedStatement psCount = con.prepareStatement(countSql);
    for (int i = 0; i < params.size(); i++) {
        psCount.setString(i + 1, params.get(i));
    }
    ResultSet rsCount = psCount.executeQuery();
    if (rsCount.next()) totalUsers = rsCount.getInt(1);
    // Paginated list
    String selectColumns = "id, full_name AS name, email, ";
    if (mobileExists) {
        selectColumns += "mobile, ";
    }
    selectColumns += "DATE_FORMAT(entry_date, '%d-%m-%Y %h:%i %p') AS entry_date, " +
                     "DATE_FORMAT(plan_end, '%Y-%m-%d %H:%i:%s') AS plan_end, " +
                     "status, entry_by";
    String sql = "SELECT " + selectColumns + " FROM user " + whereClause +
                 " ORDER BY entry_date DESC LIMIT ? OFFSET ?";
    PreparedStatement ps = con.prepareStatement(sql);
    for (int i = 0; i < params.size(); i++) {
        ps.setString(i + 1, params.get(i));
    }
    ps.setInt(params.size() + 1, limit);
    ps.setInt(params.size() + 2, offset);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        Map<String, String> u = new HashMap<>();
        u.put("id", rs.getString("id"));
        u.put("name", rs.getString("name"));
        u.put("email", rs.getString("email"));
        if (mobileExists) {
            u.put("mobile", rs.getString("mobile"));
        } else {
            u.put("mobile", "-");
        }
        u.put("entry_date", rs.getString("entry_date"));
        u.put("plan_end", rs.getString("plan_end"));
        u.put("status", rs.getString("status"));
        u.put("entry_by", rs.getString("entry_by"));
        users.add(u);
    }
    con.close();
} catch (Exception e) {
    session.setAttribute("errorMessage", "Database error: " + e.getMessage());
    users = new ArrayList<>();
    totalUsers = 0;
}
String context = request.getContextPath();
if (context.equals("/")) context = "";
// Check for success/error messages
String successMessage = (String) session.getAttribute("successMessage");
String errorMessage = (String) session.getAttribute("errorMessage");
String infoMessage = (String) session.getAttribute("infoMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>GO ACCOUNT - User Panel</title>
    <link rel="stylesheet" href="<%= context %>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: var(--bg-light);
            color: var(--text-primary);
            line-height: 1.5;
        }
        .app-wrapper {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
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
        /* Main Layout */
        .main-layout {
            display: flex;
            flex: 1;
        }
        /* Sidebar - matching dashboard */
        .sidebar {
            width: 250px;
            background: var(--bg-white);
            border-right: 1px solid var(--border-color);
            padding: 1.5rem 0;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .sidebar-nav ul {
            list-style: none;
        }
        .nav-link {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.875rem 1.5rem;
            color: var(--text-secondary);
            text-decoration: none;
            transition: var(--transition-ease);
            margin: 0.25rem 0;
        }
        .nav-link:hover {
            background: var(--orange-bg);
            color: var(--primary-orange);
            border-right: 3px solid var(--primary-orange);
        }
        .nav-link.active {
            background: var(--orange-bg);
            color: var(--primary-orange);
            border-right: 3px solid var(--primary-orange);
            font-weight: 600;
        }
        .nav-link i {
            width: 20px;
            text-align: center;
        }
        .plan-section {
            padding: 1.5rem;
            background: var(--orange-bg);
            margin: 1.5rem;
            border-radius: var(--border-radius);
            text-align: center;
        }
        .plan-section h4 {
            color: var(--primary-orange);
            margin-bottom: 0.5rem;
        }
        .plan-section p {
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
        /* Main Content */
        .main-content {
            flex: 1;
            padding: 2rem;
            overflow-y: auto;
        }
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 1.5rem;
            display: none; /* Hide since title is now in top bar */
        }
        /* Search Section */
        .search-section {
            background: var(--bg-white);
            padding: 1.5rem;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            margin-bottom: 1.5rem;
        }
        .search-form {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        .search-input, .search-select {
            padding: 0.75rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: 0.5rem;
            font-size: 0.875rem;
            transition: var(--transition-ease);
        }
        .search-input:focus, .search-select:focus {
            outline: none;
            border-color: var(--primary-orange);
            box-shadow: 0 0 0 3px rgba(255, 107, 53, 0.1);
        }
        .search-btn, .reset-btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 0.5rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition-ease);
            font-size: 0.875rem;
        }
        .search-btn {
            background: var(--primary-orange);
            color: white;
        }
        .search-btn:hover {
            background: var(--orange-light);
            transform: translateY(-1px);
        }
        .reset-btn {
            background: var(--bg-light);
            color: var(--text-secondary);
            border: 1px solid var(--border-color);
        }
        .reset-btn:hover {
            background: var(--border-color);
        }
        .action-buttons {
            display: flex;
            gap: 1rem;
            padding-top: 1.5rem;
            border-top: 1px solid var(--border-color);
        }
        .action-button {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 0.5rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            transition: var(--transition-ease);
            font-size: 0.875rem;
        }
        .add-user-btn {
            background: var(--primary-orange);
            color: white;
        }
        .add-user-btn:hover {
            background: var(--orange-light);
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(255, 107, 53, 0.2);
        }
        .all-users-btn {
            background: var(--bg-white);
            color: var(--text-secondary);
            border: 1px solid var(--border-color);
        }
        .all-users-btn:hover {
            background: var(--bg-light);
            border-color: var(--primary-orange);
            color: var(--primary-orange);
        }
        /* Users Table */
        .users-table-container {
            background: var(--bg-white);
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--box-shadow);
            margin-bottom: 1.5rem;
        }
        .users-table {
            width: 100%;
            border-collapse: collapse;
        }
        .users-table th {
            background: var(--orange-bg);
            padding: 1rem 1.5rem;
            text-align: left;
            font-weight: 600;
            color: var(--primary-orange);
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .users-table td {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
            font-size: 0.875rem;
        }
        .users-table tbody tr:hover {
            background: var(--bg-light);
        }
        .status-active {
            background: #DCFCE7;
            color: #166534;
            padding: 0.375rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .status-inactive {
            background: #FEE2E2;
            color: #991B1B;
            padding: 0.375rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .action-icons {
            display: flex;
            gap: 0.5rem;
        }
        .action-btn {
            width: 2rem;
            height: 2rem;
            border-radius: 0.375rem;
            border: none;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition-ease);
        }
        .edit-btn {
            background: var(--orange-bg);
            color: var(--primary-orange);
        }
        .edit-btn:hover {
            background: var(--primary-orange);
            color: white;
            transform: scale(1.1);
        }
        .delete-btn {
            background: #FEE2E2;
            color: #DC2626;
        }
        .delete-btn:hover {
            background: #DC2626;
            color: white;
            transform: scale(1.1);
        }
        /* Pagination */
        .pagination-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.5rem;
            background: var(--bg-white);
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            margin-bottom: 1.5rem;
        }
        .pagination-info {
            color: var(--text-secondary);
            font-size: 0.875rem;
            font-weight: 600;
        }
        .pagination-nav {
            display: flex;
            gap: 0.25rem;
        }
        .pagination-btn {
            padding: 0.5rem 0.75rem;
            border: 1px solid var(--border-color);
            background: var(--bg-white);
            border-radius: 0.375rem;
            cursor: pointer;
            color: var(--text-primary);
            transition: var(--transition-ease);
            font-size: 0.875rem;
        }
        .pagination-btn:hover {
            background: var(--orange-bg);
            border-color: var(--primary-orange);
            color: var(--primary-orange);
        }
        .pagination-btn.active {
            background: var(--primary-orange);
            color: white;
            border-color: var(--primary-orange);
        }
        /* Notes Section */
        .notes-section {
            background: var(--orange-bg);
            padding: 1rem 1.5rem;
            border-radius: var(--border-radius);
            border-left: 4px solid var(--primary-orange);
            font-size: 0.875rem;
            color: var(--text-primary);
        }
        .no-data {
            text-align: center;
            padding: 3rem;
            color: var(--text-secondary);
            font-style: italic;
        }
        /* Modals */
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
            box-shadow: var(--box-shadow-lg);
        }
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .modal-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
        }
        .close-modal {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--text-secondary);
            transition: color 0.3s;
        }
        .close-modal:hover {
            color: var(--primary-orange);
        }
        .modal-form input, .modal-form select {
            width: 100%;
            padding: 0.75rem 1rem;
            margin-bottom: 1rem;
            border: 1px solid var(--border-color);
            border-radius: 0.5rem;
            font-size: 0.875rem;
            transition: var(--transition-ease);
        }
        .modal-form input:focus, .modal-form select:focus {
            outline: none;
            border-color: var(--primary-orange);
            box-shadow: 0 0 0 3px rgba(255, 107, 53, 0.1);
        }
        .modal-buttons {
            display: flex;
            gap: 0.75rem;
            margin-top: 1rem;
        }
        .save-btn, .close-btn {
            flex: 1;
            padding: 0.75rem;
            border: none;
            border-radius: 0.5rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition-ease);
            font-size: 0.875rem;
        }
        .save-btn {
            background: var(--primary-orange);
            color: white;
        }
        .save-btn:hover {
            background: var(--orange-light);
            transform: translateY(-1px);
        }
        .close-btn {
            background: var(--bg-light);
            color: var(--text-secondary);
            border: 1px solid var(--border-color);
        }
        .close-btn:hover {
            background: var(--border-color);
        }
        /* Messages */
        .message-container {
            position: fixed;
            top: 1rem;
            right: 1rem;
            z-index: 1001;
            max-width: 400px;
        }
        .alert {
            padding: 1rem 1.25rem;
            border-radius: 0.5rem;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            animation: slideIn 0.3s ease-out;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .alert-success {
            background: #DCFCE7;
            color: #166534;
            border-left: 4px solid #22C55E;
        }
        .alert-error {
            background: #FEE2E2;
            color: #991B1B;
            border-left: 4px solid #EF4444;
        }
        .alert-info {
            background: #E0F2FE;
            color: #075985;
            border-left: 4px solid #0EA5E9;
        }
        .alert-close {
            background: none;
            border: none;
            font-size: 1.25rem;
            cursor: pointer;
            color: inherit;
            opacity: 0.7;
            margin-left: 0.75rem;
        }
        .alert-close:hover {
            opacity: 1;
        }
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        /* Responsive */
        @media (max-width: 768px) {
            .main-layout {
                flex-direction: column;
            }
            .sidebar {
                width: 100%;
                padding: 1rem 0;
            }
            .main-content {
                padding: 1rem;
            }
            .search-form {
                grid-template-columns: 1fr;
            }
            .action-buttons {
                flex-direction: column;
            }
            .users-table {
                display: block;
                overflow-x: auto;
            }
            .modal-content {
                width: 95%;
                padding: 1rem;
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
        function openAddModal() {
            document.getElementById("addModal").style.display = "flex";
        }
        function closeAddModal() {
            document.getElementById("addModal").style.display = "none";
        }
        function openEditModal(id, name, mobile, email, planEnd, status) {
            document.getElementById("editId").value = id;
            document.getElementById("editName").value = name;
            document.getElementById("editMobile").value = mobile;
            document.getElementById("editEmail").value = email;
            document.getElementById("editValidity").value = planEnd ? planEnd.split(' ')[0] : '';
            document.getElementById("editStatus").value = status;
            document.getElementById("editModal").style.display = "flex";
        }
        function closeEditModal() {
            document.getElementById("editModal").style.display = "none";
        }
        function deleteUser(id, name) {
            if (confirm(`Are you sure you want to delete user "${name}"?`)) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= context %>/user-panel.jsp';
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'delete';
                form.appendChild(actionInput);
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = id;
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }
        window.onclick = function(event) {
            const addModal = document.getElementById('addModal');
            const editModal = document.getElementById('editModal');
            if (event.target === addModal) closeAddModal();
            if (event.target === editModal) closeEditModal();
        }
        function showAllUsers() {
            window.location.href = '<%= context %>/user-panel.jsp';
        }
        function closeAlert(element) {
            element.parentElement.style.display = 'none';
        }
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.display = 'none';
            });
        }, 5000);
        function toggleSidebar() {
            const sidebar = document.querySelector('.sidebar');
            sidebar.style.transform = sidebar.style.transform === 'translateX(-100%)' ? 'translateX(0)' : 'translateX(-100%)';
        }
    </script>
</head>
<body>
    <!-- Message Container -->
    <% if (successMessage != null || errorMessage != null || infoMessage != null) { %>
    <div class="message-container">
        <% if (successMessage != null) { %>
        <div class="alert alert-success">
            <span><%= successMessage %></span>
            <button class="alert-close" onclick="closeAlert(this)">×</button>
        </div>
        <% session.removeAttribute("successMessage"); } %>
        <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <span><%= errorMessage %></span>
            <button class="alert-close" onclick="closeAlert(this)">×</button>
        </div>
        <% session.removeAttribute("errorMessage"); } %>
        <% if (infoMessage != null) { %>
        <div class="alert alert-info">
            <span><%= infoMessage %></span>
            <button class="alert-close" onclick="closeAlert(this)">×</button>
        </div>
        <% session.removeAttribute("infoMessage"); } %>
    </div>
    <% } %>
    <div class="app-wrapper">
        <!-- Top Bar - Orange Title Bar -->
        <header class="top-bar">
            <div class="top-bar-left">
                <a href="<%= context %>/dashboard.jsp" class="logo">
                    <i class="fas fa-cloud"></i>
                    <span>GO ACCOUNT</span>
                </a>
                <button class="hamburger" onclick="toggleSidebar()">
                    <i class="fas fa-bars"></i>
                </button>
            </div>
            <div class="top-bar-center">
                <h1>All Users</h1>
            </div>
            <div class="top-bar-right">
                <div class="top-bar-icon">
                    <i class="fas fa-bell"></i>
                </div>
                <div class="date-info">
                    <%= java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("EEEE, MMM dd, yyyy")) %>
                </div>
                <div class="top-bar-icon">
                    <i class="fas fa-user-circle"></i>
                </div>
            </div>
        </header>
        <div class="main-layout">
            <!-- Sidebar - matching dashboard -->
            <aside class="sidebar">
                <nav class="sidebar-nav">
                    <ul>
                        <li><a href="<%= context %>/dashboard.jsp" class="nav-link"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                        <li><a href="<%= context %>/user-panel.jsp" class="nav-link active"><i class="fas fa-users"></i> Users</a></li>
                        <li><a href="#" class="nav-link"><i class="fas fa-chart-line"></i> Analytics</a></li>
                        <li><a href="#" class="nav-link"><i class="fas fa-credit-card"></i> Subscriptions</a></li>
                        <li><a href="#" class="nav-link"><i class="fas fa-cog"></i> Settings</a></li>
                        <li><a href="<%= context %>/logout" class="nav-link"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                    </ul>
                </nav>
                <div class="plan-section">
                    <h4>Professional Plan</h4>
                    <p>15 days remaining</p>
                </div>
            </aside>
            <!-- Main Content -->
            <main class="main-content">
                <!-- Search Section -->
                <div class="search-section">
                    <form method="get" action="<%= context %>/user-panel.jsp" class="search-form">
                        <input type="text" class="search-input" placeholder="Search by name" name="search_name" value="<%= searchName != null ? searchName : "" %>">
                        <input type="text" class="search-input" placeholder="Search by email" name="search_email" value="<%= searchEmail != null ? searchEmail : "" %>">
                        <input type="text" class="search-input" placeholder="Search by mobile" name="search_mobile" value="<%= searchMobile != null ? searchMobile : "" %>">
                        <select class="search-select" name="status">
                            <option value="">All Status</option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(searchStatus) ? "selected" : "" %>>Active</option>
                            <option value="INACTIVE" <%= "INACTIVE".equals(searchStatus) ? "selected" : "" %>>Inactive</option>
                        </select>
                        <input type="hidden" name="page" value="1">
                        <button type="submit" class="search-btn">
                            <i class="fas fa-search"></i> Search
                        </button>
                        <button type="button" class="reset-btn" onclick="showAllUsers()">
                            <i class="fas fa-redo"></i> Reset
                        </button>
                    </form>
                    <div class="action-buttons">
                        <button class="action-button add-user-btn" onclick="openAddModal()">
                            <i class="fas fa-user-plus"></i> Add User
                        </button>
                        <button class="action-button all-users-btn" onclick="showAllUsers()">
                            <i class="fas fa-users"></i> All Users
                        </button>
                    </div>
                </div>
                <!-- Users Table -->
                <div class="users-table-container">
                    <table class="users-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Mobile</th>
                                <th>Email</th>
                                <th>Entry Date</th>
                                <th>Validity</th>
                                <th>Status</th>
                                <th>Entry By</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users.isEmpty()) { %>
                                <tr><td colspan="8" class="no-data">No users found. Click "Add User" to create your first user.</td></tr>
                            <% } else {
                                for (Map<String, String> u : users) {
                            %>
                                <tr>
                                    <td><%= u.get("name") %></td>
                                    <td><%= u.get("mobile") != null ? u.get("mobile") : "-" %></td>
                                    <td><%= u.get("email") %></td>
                                    <td><%= u.get("entry_date") %></td>
                                    <td><%= u.get("plan_end") %></td>
                                    <td>
                                        <span class="status-<%= u.get("status").toLowerCase() %>">
                                            <%= u.get("status") %>
                                        </span>
                                    </td>
                                    <td><%= u.get("entry_by") %></td>
                                    <td>
                                        <div class="action-icons">
                                            <button class="action-btn edit-btn" onclick="openEditModal('<%= u.get("id") %>', '<%= u.get("name").replace("'", "\\'") %>', '<%= u.get("mobile") != null ? u.get("mobile").replace("'", "\\'") : "" %>', '<%= u.get("email").replace("'", "\\'") %>', '<%= u.get("plan_end") != null ? u.get("plan_end").replace("'", "\\'") : "" %>', '<%= u.get("status") %>')" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button class="action-btn delete-btn" onclick="deleteUser('<%= u.get("id") %>', '<%= u.get("name").replace("'", "\\'") %>')" title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
                <!-- Pagination -->
                <% if (totalUsers > 0) { %>
                    <div class="pagination-section">
                        <div class="pagination-info">
                            SHOWING <%= Math.min(limit, users.size()) %> OUT OF <%= totalUsers %> ENTRIES
                        </div>
                        <div class="pagination-nav">
                            <%
                                int totalPages = (int) Math.ceil((double) totalUsers / limit);
                                if (currentPage > 1) {
                            %>
                                <a href="<%= context %>/user-panel.jsp?page=<%= currentPage - 1 %><%= searchName != null ? "&search_name=" + java.net.URLEncoder.encode(searchName, "UTF-8") : "" %><%= searchEmail != null ? "&search_email=" + java.net.URLEncoder.encode(searchEmail, "UTF-8") : "" %><%= searchMobile != null ? "&search_mobile=" + java.net.URLEncoder.encode(searchMobile, "UTF-8") : "" %><%= searchStatus != null ? "&status=" + searchStatus : "" %>">
                                    <button class="pagination-btn">« Prev</button>
                                </a>
                            <% } %>
                            <%
                                int startPage = Math.max(1, currentPage - 2);
                                int endPage = Math.min(totalPages, currentPage + 2);
                                for (int i = startPage; i <= endPage; i++) {
                            %>
                                <a href="<%= context %>/user-panel.jsp?page=<%= i %><%= searchName != null ? "&search_name=" + java.net.URLEncoder.encode(searchName, "UTF-8") : "" %><%= searchEmail != null ? "&search_email=" + java.net.URLEncoder.encode(searchEmail, "UTF-8") : "" %><%= searchMobile != null ? "&search_mobile=" + java.net.URLEncoder.encode(searchMobile, "UTF-8") : "" %><%= searchStatus != null ? "&status=" + searchStatus : "" %>">
                                    <button class="pagination-btn <%= i == currentPage ? "active" : "" %>"><%= i %></button>
                                </a>
                            <% } %>
                            <% if (currentPage < totalPages) { %>
                                <a href="<%= context %>/user-panel.jsp?page=<%= currentPage + 1 %><%= searchName != null ? "&search_name=" + java.net.URLEncoder.encode(searchName, "UTF-8") : "" %><%= searchEmail != null ? "&search_email=" + java.net.URLEncoder.encode(searchEmail, "UTF-8") : "" %><%= searchMobile != null ? "&search_mobile=" + java.net.URLEncoder.encode(searchMobile, "UTF-8") : "" %><%= searchStatus != null ? "&status=" + searchStatus : "" %>">
                                    <button class="pagination-btn">Next »</button>
                                </a>
                            <% } %>
                        </div>
                    </div>
                <% } %>
                <!-- Notes Section -->
                <div class="notes-section">
                    <strong>Notes:</strong> This panel displays all registered users. You can search, filter, and manage user accounts from here.
                </div>
            </main>
        </div>
    </div>
    <!-- Add User Modal -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Add New User</h3>
                <button class="close-modal" onclick="closeAddModal()">×</button>
            </div>
            <form method="post" action="<%= context %>/user-panel.jsp" class="modal-form">
                <input type="hidden" name="action" value="add">
                <input type="text" name="full_name" placeholder="Full Name" required>
                <input type="email" name="email" placeholder="Email" required>
                <input type="tel" name="mobile" placeholder="Mobile Number">
                <input type="date" name="plan_end" required>
                <select name="status" required>
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                </select>
                <input type="password" name="password" placeholder="Password" required>
                <input type="hidden" name="entry_by" value="<%= entryBy %>">
                <div class="modal-buttons">
                    <button type="submit" class="save-btn">Save User</button>
                    <button type="button" class="close-btn" onclick="closeAddModal()">Close</button>
                </div>
            </form>
        </div>
    </div>
    <!-- Edit User Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Edit User</h3>
                <button class="close-modal" onclick="closeEditModal()">×</button>
            </div>
            <form method="post" action="<%= context %>/user-panel.jsp" class="modal-form">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editId">
                <input type="text" name="full_name" id="editName" placeholder="Full Name" required>
                <input type="email" name="email" id="editEmail" placeholder="Email" required>
                <input type="tel" name="mobile" id="editMobile" placeholder="Mobile Number">
                <input type="date" name="plan_end" id="editValidity" required>
                <select name="status" id="editStatus" required>
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                </select>
                <div class="modal-buttons">
                    <button type="submit" class="save-btn">Update User</button>
                    <button type="button" class="close-btn" onclick="closeEditModal()">Close</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>