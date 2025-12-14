<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    Integer userId = (Integer) session.getAttribute("userId");
    String entryBy = userName != null ? userName + " (Admin)" : "System Admin";  // Default for new users

    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String avatarLetter = userName != null ? userName.substring(0, 1).toUpperCase() : "U";

    // DB Connection for Users List (with pagination and search)
    List<Map<String, String>> users = new ArrayList<>();
    int totalUsers = 0;
    String searchName = request.getParameter("search_name");
    String searchMobile = request.getParameter("search_mobile");
    String searchStatus = request.getParameter("status");

    String whereClause = "WHERE 1=1";
    List<String> params = new ArrayList<>();
    if (searchName != null && !searchName.trim().isEmpty()) {
        whereClause += " AND full_name LIKE ?";
        params.add("%" + searchName.trim() + "%");
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
            "root",
            "6677"
        );

        // Total count for pagination
        String countSql = "SELECT COUNT(*) FROM users " + whereClause;
        PreparedStatement psCount = con.prepareStatement(countSql);
        for (int i = 0; i < params.size(); i++) {
            psCount.setString(i + 1, params.get(i));
        }
        ResultSet rsCount = psCount.executeQuery();
        if (rsCount.next()) totalUsers = rsCount.getInt(1);

        // Paginated list
        String sql = "SELECT id, full_name AS name, mobile, email,password, DATE_FORMAT(entry_date, '%Y-%m-%d') AS entry_date, " +
                     "DATE_FORMAT(plan_end, '%Y-%m-%d') AS planend, status, entry_by " +
                     "FROM user " + whereClause + " ORDER BY entry_date DESC LIMIT ? OFFSET ?";
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
            u.put("mobile", rs.getString("mobile"));
            u.put("email", rs.getString("email"));

            u.put("entry_date", rs.getString("entry_date"));
            u.put("planend", rs.getString("planend"));
            u.put("status", rs.getString("status"));
            u.put("entry_by", rs.getString("entry_by"));
            users.add(u);
        }
        con.close();
    } catch (Exception e) {
        // Handle DB error gracefully
        users = new ArrayList<>();  // Empty list on error
        totalUsers = 0;
        // out.println("<p style='color:red;'>DB Error: " + e.getMessage() + "</p>");  // Uncomment for debugging
    }

    String context = request.getContextPath();
    if (context.equals("/")) context = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Panel - Orange SaaS</title>
    <link rel="stylesheet" href="<%= context %>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Enhanced styles for clean, modern look matching the image */
        body { background: #f8f9fa; }
        .main-content { padding: 20px; }
        .header-section { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .header-title { font-size: 24px; font-weight: 600; color: #333; }
        .add-user-btn { background: linear-gradient(135deg, #FF6B35, #E55A2B); color: white; padding: 12px 24px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: transform 0.2s; }
        .add-user-btn:hover { transform: translateY(-2px); }
        .search-section { background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; }
        .search-form { display: flex; gap: 15px; align-items: center; flex-wrap: wrap; }
        .search-input, .search-select { padding: 10px 15px; border: 1px solid #e0e0e0; border-radius: 8px; font-size: 14px; min-width: 200px; }
        .search-btn, .reset-btn { padding: 10px 20px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .search-btn { background: #FF6B35; color: white; }
        .search-btn:hover { background: #E55A2B; }
        .reset-btn { background: #f0f0f0; color: #666; }
        .reset-btn:hover { background: #e0e0e0; }
        .users-table { width: 100%; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.05); border-collapse: collapse; }
        .users-table th { background: #FFF1EB; padding: 15px; text-align: left; font-weight: 600; color: #FF6B35; border-bottom: 1px solid #f0f0f0; }
        .users-table td { padding: 15px; border-bottom: 1px solid #f0f0f0; }
        .users-table tr:hover { background: #FFF9F5; }
        .status-active { background: #d4edda; color: #155724; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .status-inactive { background: #f8d7da; color: #721c24; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .action-icons { display: flex; gap: 10px; }
        .action-icons i { padding: 8px; border-radius: 50%; cursor: pointer; transition: all 0.2s; font-size: 14px; }
        .action-icons .edit { background: #d1ecf1; color: #0c5460; }
        .action-icons .delete { background: #f8d7da; color: #721c24; }
        .action-icons i:hover { background: #FF6B35; color: white; transform: scale(1.1); }
        .no-data { text-align: center; padding: 40px; color: #999; font-style: italic; }
        .pagination-section { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; background: white; padding: 15px 20px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .pagination-info { color: #666; font-size: 14px; }
        .pagination-nav { display: flex; gap: 5px; }
        .pagination-btn { padding: 8px 12px; border: 1px solid #e0e0e0; background: white; border-radius: 6px; cursor: pointer; color: #333; transition: all 0.2s; }
        .pagination-btn:hover, .pagination-btn.active { background: #FF6B35; color: white; border-color: #FF6B35; }
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: none; justify-content: center; align-items: center; z-index: 1000; }
        .modal-content { background: white; padding: 30px; border-radius: 12px; width: 90%; max-width: 500px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .modal-title { font-size: 20px; font-weight: 600; color: #333; }
        .close-modal { background: none; border: none; font-size: 24px; cursor: pointer; color: #999; }
        .modal-form input, .modal-form select { width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #e0e0e0; border-radius: 8px; font-size: 14px; box-sizing: border-box; }
        .modal-form .btn { width: 100%; padding: 12px; margin-bottom: 10px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .save-btn { background: #FF6B35; color: white; }
        .save-btn:hover { background: #E55A2B; }
        .close-btn { background: #f0f0f0; color: #666; }
        .close-btn:hover { background: #e0e0e0; }
        @media (max-width: 768px) { .search-form { flex-direction: column; align-items: stretch; } .search-input, .search-select { min-width: auto; } }
    </style>
    <script>
        function openAddModal() { document.getElementById("addModal").style.display = "flex"; }
        function closeAddModal() { document.getElementById("addModal").style.display = "none"; }
        function openEditModal(id, name, mobile, email, validity, status) {
            document.getElementById("editId").value = id;
            document.getElementById("editName").value = name;
            document.getElementById("editMobile").value = mobile || '';
            document.getElementById("editEmail").value = email;
            document.getElementById("editValidity").value = validity;
            document.getElementById("editStatus").value = status;
            document.getElementById("editModal").style.display = "flex";
        }
        function closeEditModal() { document.getElementById("editModal").style.display = "none"; }
        function deleteUser(id, name) {
            if (confirm(`Are you sure you want to delete user "${name}"?`)) {
                document.getElementById("deleteForm_" + id).submit();
            }
        }
    </script>
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <a href="<%= context %>/dashboard.jsp" class="logo">
                    <div class="logo-icon"><i class="fas fa-cloud"></i></div>
                    <span>Orange SaaS</span>
                </a>
            </div>
            <div class="user-profile">
                <div class="user-avatar"><%= avatarLetter %></div>
                <div class="user-info">
                    <h4><%= userName %></h4>
                    <p><%= userEmail %></p>
                    <span class="status-badge"><i class="fas fa-circle" style="font-size:8px; color: #28a745;"></i> Active</span>
                </div>
            </div>
            <nav class="nav-menu">
                <ul>
                    <li class="nav-item"><a href="<%= context %>/dashboard.jsp" class="nav-link"><i class="fas fa-tachometer-alt nav-icon"></i><span>Dashboard</span></a></li>
                    <li class="nav-item"><a href="<%= context %>/user-panel.jsp" class="nav-link active"><i class="fas fa-users nav-icon"></i><span>User Panel</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-chart-line nav-icon"></i><span>Analytics</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-cog nav-icon"></i><span>Settings</span></a></li>
                    <li class="nav-item"><a href="<%= context %>/logout" class="nav-link"><i class="fas fa-sign-out-alt nav-icon"></i><span>Logout</span></a></li>
                </ul>
            </nav>
            <div class="plan-info">
                <h4>Professional Plan</h4>
                <p>15 days remaining</p>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <div class="header-section">
                <div class="header-title">User Management</div>
                <button class="add-user-btn" onclick="openAddModal()">
                    <i class="fas fa-user-plus"></i> Add User
                </button>
            </div>

            <!-- Search Section -->
            <div class="search-section">
                <form method="get" action="<%= context %>/user-panel.jsp" class="search-form">
                    <input type="text" class="search-input" placeholder="Search by Name" name="search_name" value="<%= searchName != null ? searchName : "" %>">
                    <input type="text" class="search-input" placeholder="Search by Mobile" name="search_mobile" value="<%= searchMobile != null ? searchMobile : "" %>">
                    <select class="search-select" name="status">
                        <option value="">All Status</option>
                        <option value="ACTIVE" <%= "ACTIVE".equals(searchStatus) ? "selected" : "" %>>Active</option>
                        <option value="INACTIVE" <%= "INACTIVE".equals(searchStatus) ? "selected" : "" %>>Inactive</option>
                    </select>
                    <input type="hidden" name="page" value="1">
                    <button type="submit" class="search-btn">Search</button>
                    <button type="button" class="reset-btn" onclick="window.location.href='<%= context %>/user-panel.jsp'">Reset</button>
                </form>
            </div>

            <!-- Users Table -->
            <table class="users-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Mobile</th>
                        <th>Email</th>
                        <th>Entry Date</th>
                        <th>planend</th>
                        <th>Status</th>
                        <th>Entry By</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (users.isEmpty()) { %>
                        <tr><td colspan="9" class="no-data">No users found.</td></tr>
                    <% } else { for (Map<String, String> u : users) { %>
                        <tr>
                            <td><%= u.get("id") %></td>
                            <td><%= u.get("name") %></td>
                            <td><%= u.get("mobile") != null ? u.get("mobile") : "-" %></td>
                            <td><%= u.get("email") %></td>
                            <td><%= u.get("entry_date") %></td>
                            <td><%= u.get("planend") %></td>
                            <td><span class="status-<%= u.get("status").toLowerCase() %>"><%= u.get("status") %></span></td>
                            <td><%= u.get("entry_by") %></td>
                            <td>
                                <div class="action-icons">
                                    <i class="fas fa-edit edit" onclick="openEditModal('<%= u.get("id") %>', '<%= u.get("name") %>', '<%= u.get("mobile") %>', '<%= u.get("email") %>', '<%= u.get("validity") %>', '<%= u.get("status") %>')" title="Edit"></i>
                                    <i class="fas fa-trash delete" onclick="deleteUser('<%= u.get("id") %>', '<%= u.get("name") %>')" title="Delete"></i>
                                </div>
                                <form id="deleteForm_<%= u.get("id") %>" action="<%= context %>/deleteUser" method="post" style="display: inline;">
                                    <input type="hidden" name="id" value="<%= u.get("id") %>">
                                </form>
                            </td>
                        </tr>
                    <% } } %>
                </tbody>
            </table>

            <!-- Pagination Section -->
            <% if (totalUsers > limit) { %>
            <div class="pagination-section">
                <div class="pagination-info">
                    Showing <%= offset + 1 %> to <%= Math.min(offset + limit, totalUsers) %> of <%= totalUsers %> entries
                </div>
                <div class="pagination-nav">
                    <% int totalPages = (int) Math.ceil((double) totalUsers / limit);
                    if (currentPage > 1) { %>
                        <a href="<%= context %>/user-panel.jsp?page=<%= currentPage - 1 %><%= !params.isEmpty() ? "&search_name=" + (searchName != null ? searchName : "") + "&search_mobile=" + (searchMobile != null ? searchMobile : "") + "&status=" + (searchStatus != null ? searchStatus : "") : "" %>">
                            <button class="pagination-btn">&laquo; Prev</button>
                        </a>
                    <% }
                    for (int i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) { %>
                        <a href="<%= context %>/user-panel.jsp?page=<%= i %><%= !params.isEmpty() ? "&search_name=" + (searchName != null ? searchName : "") + "&search_mobile=" + (searchMobile != null ? searchMobile : "") + "&status=" + (searchStatus != null ? searchStatus : "") : "" %>">
                            <button class="pagination-btn <%= i == currentPage ? "active" : "" %>"><%= i %></button>
                        </a>
                    <% }
                    if (currentPage < totalPages) { %>
                        <a href="<%= context %>/user-panel.jsp?page=<%= currentPage + 1 %><%= !params.isEmpty() ? "&search_name=" + (searchName != null ? searchName : "") + "&search_mobile=" + (searchMobile != null ? searchMobile : "") + "&status=" + (searchStatus != null ? searchStatus : "") : "" %>">
                            <button class="pagination-btn">Next &raquo;</button>
                        </a>
                    <% } %>
                </div>
            </div>
            <% } %>
        </main>
    </div>

    <!-- Add User Modal -->
    <div id="addModal" class="modal-overlay">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Add New User</h3>
                <button class="close-modal" onclick="closeAddModal()">&times;</button>
            </div>
            <form action="<%= context %>/addUser" method="post" class="modal-form">
                <input type="text" name="full_name" placeholder="Full Name" required>
                <input type="text" name="mobile" placeholder="Mobile (Optional)">
                <input type="email" name="email" placeholder="Email" required>
                <input type="date" name="plan_end" required>
                <select name="status" required>
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                </select>
                <input type="password" name="password" placeholder="Password" required>
                <input type="hidden" name="entry_by" value="<%= entryBy %>">
                <button type="submit" class="btn save-btn">Save User</button>
            </form>
            <button class="btn close-btn" onclick="closeAddModal()">Close</button>
        </div>
    </div>

    <!-- Edit User Modal -->
    <div id="editModal" class="modal-overlay">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Edit User</h3>
                <button class="close-modal" onclick="closeEditModal()">&times;</button>
            </div>
            <form action="<%= context %>/editUser" method="post" class="modal-form">
                <input type="hidden" name="id" id="editId">
                <input type="text" name="full_name" id="editName" placeholder="Full Name" required>
                <input type="text" name="mobile" id="editMobile" placeholder="Mobile (Optional)">
                <input type="email" name="email" id="editEmail" placeholder="Email" required>
                <input type="date" name="plan_end" id="editValidity" required>
                <select name="status" id="editStatus" required>
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                </select>
                <button type="submit" class="btn save-btn">Update User</button>
            </form>
            <button class="btn close-btn" onclick="closeEditModal()">Close</button>
        </div>
    </div>
</body>
</html>