<%@ page import="java.sql.*" %>
<%@ include file="../config.jspf" %>

<%
Integer aid = (Integer) session.getAttribute("adminid");
if (aid == null) {
    response.sendRedirect("login.jsp");
    return;
}

long users = 0, packages = 0, bookings = 0, myPackages = 0, myBookings = 0, myUsers=0, activePackages = 0;
double revenue = 0.0, myRevenue = 0.0;

Connection c = null;
Statement s = null;
ResultSet r = null;
PreparedStatement ps = null;

try {
    c = getConnection();
    s = c.createStatement();

    r = s.executeQuery("SELECT COUNT(*) FROM Users");
    if (r.next()) users = r.getInt(1);
    r.close();

    r = s.executeQuery("SELECT COUNT(*) FROM Package WHERE deletedate IS NULL");
    if (r.next()) packages = r.getInt(1);
    r.close();

    r = s.executeQuery("SELECT COUNT(*) FROM Booking WHERE status<>'Cancelled'");
    if (r.next()) bookings = r.getInt(1);
    r.close();

    r = s.executeQuery("SELECT NVL(SUM(amount),0) FROM Payment WHERE paystatus='Completed'");
    if (r.next()) revenue = r.getDouble(1);
    r.close();

    // Current admin's insights
    ps = c.prepareStatement("SELECT COUNT(DISTINCT u.userid) FROM Users u JOIN Booking b ON u.userid = b.userid JOIN Package p ON b.packageid = p.packageid WHERE p.createdby = ?");
    ps.setInt(1, aid);
    r = ps.executeQuery();
    if (r.next()) myUsers = r.getInt(1);
    r.close();
    ps.close();

    ps = c.prepareStatement("SELECT COUNT(*) FROM Package WHERE createdby = ? AND deletedate IS NULL");
    ps.setInt(1, aid);
    r = ps.executeQuery();
    if (r.next()) myPackages = r.getInt(1);
    r.close();
    ps.close();

    ps = c.prepareStatement("SELECT COUNT(*) FROM Booking b JOIN Package p ON b.packageid = p.packageid WHERE p.createdby = ? AND b.status<>'Cancelled'");
    ps.setInt(1, aid); 
    r = ps.executeQuery();
    if (r.next()) myBookings = r.getInt(1);
    r.close();
    ps.close();

    ps = c.prepareStatement("SELECT NVL(SUM(p.amount),0) FROM Payment p JOIN Booking b ON p.bookingid = b.bookingid JOIN Package pk ON b.packageid = pk.packageid WHERE pk.createdby = ? AND p.paystatus='Completed'");
    ps.setInt(1, aid);
    r = ps.executeQuery();
    if (r.next()) myRevenue = r.getDouble(1);
    r.close();
    ps.close();


    // Count current admin's active packages (travel date in future)
    ps = c.prepareStatement("SELECT COUNT(*) FROM Package WHERE createdby = ? AND deletedate IS NULL AND traveldate >= TRUNC(SYSDATE)");
    ps.setInt(1, aid);
    r = ps.executeQuery();
    if (r.next()) activePackages = r.getInt(1);
    r.close();
    ps.close();

} catch (Exception e) {
    // ignore
} finally {
    try {
        if (r != null) r.close();
    } catch (Exception ig) {
        logIgnoredException("admin/dashboard.jsp: closing ResultSet", ig);
    }
    try {
        if (ps != null) ps.close();
    } catch (Exception ig) {
        logIgnoredException("admin/dashboard.jsp: closing PreparedStatement", ig);
    }
    try {
        if (s != null) s.close();
    } catch (Exception ig) {
        logIgnoredException("admin/dashboard.jsp: closing Statement", ig);
    }
    try {
        if (c != null) c.close();
    } catch (Exception ig) {
        logIgnoredException("admin/dashboard.jsp: closing Connection", ig);
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="header.jspf" %>
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="../assets/css/style.css" />
</head>
<body>
    <div class="container">
        <h1>Welcome to Admin Dashboard</h1>
    <div class="container">
        <h2>Overall Dashboard</h2>

        <div class="grid">
            <div class="card">
                <h3>Total Users</h3>
                <p><%= users %></p>
            </div>
            <div class="card">
                <h3>Total Packages</h3>
                <p><%= packages %></p>
            </div>
            <div class="card">
                <h3> Total Bookings</h3>
                <p><%= bookings %></p>
            </div>
            <div class="card">
                <h3>Total Revenue</h3>
                <p>RS <%= revenue %></p>
            </div>
        </div>
    </div>
    <div class="container">
        <h2>My Packages Overview</h2>

        <div class="grid">
            <div class="card">
                <h3>Users</h3>
                <p><%= myUsers %></p>
            </div>
            <div class="card">
                <h3>Packages</h3>
                <p><%= myPackages %></p>
            </div>
            <div class="card">
                <h3>Bookings</h3>
                <p><%= myBookings %></p>
            </div>
            <div class="card">
                <h3>Revenue</h3>
                <p>RS <%= myRevenue %></p>
            </div>
        </div>
    </div>
    
        <%
        // Fetch active package details for current admin
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null, rsCount = null;
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(
                "SELECT packageid, title, location, price, duration, seats, traveldate, startpoint, endpoint " +
                "FROM Package WHERE createdby = ? AND deletedate IS NULL AND availabletill >= TRUNC(SYSDATE) " +
                "ORDER BY traveldate ASC"
            );
            pstmt.setInt(1, aid);
            rs = pstmt.executeQuery();
        %>

        <div class="card" style="margin-top:30px;">
            <h3>My Active Packages Details</h3>
            <% if (!rs.next()){ %>
            <p style="text-align:center; color:#64748b; padding:20px;">You have no active packages scheduled for future dates.</p>
            <% } else { 

        
            %>
            <table>
                <thead>
                    <tr>
                        <th>Package ID</th>
                        <th>Title</th>
                        <th>Location</th>
                        <th>Price(Rs)</th>
                        <th>Duration</th>
                        <th>Seats</th>
                        <th>Travel Date</th>
                        <th>Bookings</th>
                    </tr>
                </thead>
                <tbody>
                    <% do{ 
                    pstmt = conn.prepareStatement(
                        "SELECT COUNT(*) FROM Booking WHERE packageid = ? AND status<>'Cancelled'"
                    );
                    pstmt.setInt(1, rs.getInt("packageid"));
                    rsCount = pstmt.executeQuery();
                    int bookedSeats = 0;
                    if (rsCount.next()) {
                        bookedSeats = rsCount.getInt(1);
                    }
                    String seatsBooked = bookedSeats + "/" + rs.getInt("seats");
                     %>
                    <tr>
                        <td><%= rs.getInt("packageid") %></td>
                        <td><%= rs.getString("title") %></td>
                        <td><%= rs.getString("location") %></td>
                        <td><%= String.format("%.2f", rs.getDouble("price")) %></td>
                        <td><%= rs.getString("duration") != null ? rs.getString("duration") : "N/A" %></td>
                        <td><%= rs.getInt("seats") %></td>
                        <td><%= rs.getDate("traveldate") %></td>
                        <td><%= seatsBooked  %></td>
                    </tr>
                    <% } while (rs.next()); %>
                </tbody>
            </table>
            <% } %>
        </div>

        <%
        } catch (Exception e) {
            out.println("<div class='error'>Error loading package details: " + e.getMessage() + "</div>");
        } finally {
            try {
            if (rs != null) rs.close();
            } catch (Exception ig) {
            logIgnoredException("admin/dashboard.jsp: closing ResultSet rs", ig);
            }
            try {
            if (pstmt != null) pstmt.close();
            } catch (Exception ig) {
            logIgnoredException("admin/dashboard.jsp: closing PreparedStatement pstmt", ig);
            }
            try {
            if (conn != null) conn.close();
            } catch (Exception ig) {
            logIgnoredException("admin/dashboard.jsp: closing Connection conn", ig);
            }
        }
        %>

        <nav style="margin-top:20px">
            <a class="btn" href="addAdmin.jsp">Add Admin</a>
            <a class="btn" href="packages.jsp">Manage Packages</a>
            <a class="btn" href="users.jsp">Users</a>
            <a class="btn" href="bookings.jsp">View Bookings</a>
            <a class="btn" href="reviews.jsp">Manage Reviews</a>
            <a class="btn danger" href="logout.jsp">Logout</a>
        </nav>
    </div>
</body>
</html>