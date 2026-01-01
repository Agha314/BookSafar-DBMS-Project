<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate"%>
<%@ include file="config.jspf" %>

<%
    Integer uid = (Integer) session.getAttribute("userid");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection c = null;
    PreparedStatement p = null;
    PreparedStatement upd = null;
    ResultSet r = null;
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Bookings</title>
    <link rel="stylesheet" href="assets/css/style.css" />
+</head>
<body>
    <%@ include file="header.jspf" %>
    <div class="container">
        <h2>My Bookings</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>Package</th>
                <th>Booked At</th>
                <th>Status</th>
                <th>Payment (status/amount)</th>
                <th>Cancel Reason</th>
                <th>Action</th>
            </tr>

            <%
                try {
                    c = getConnection();

                    //Mark bookings as Completed if booked more than 2 days ago
                    upd = c.prepareStatement(
                        "UPDATE Booking SET status='Completed' " +
                        "WHERE userid=? AND status='Booked' AND bookingdate < (SYSTIMESTAMP - INTERVAL '2' DAY)"
                    );
                    upd.setInt(1, uid);
                    upd.executeUpdate();

                    p = c.prepareStatement(
                        "SELECT b.bookingid, pk.title, b.bookingdate, b.status, " +
                        "py.paystatus, py.amount, b.cancelreason " +
                        "FROM Booking b " +
                        "JOIN Package pk ON b.packageid = pk.packageid " +
                        "LEFT JOIN Payment py ON b.bookingid = py.bookingid " +
                        "WHERE b.userid = ? " +
                        "ORDER BY b.bookingdate DESC"
                    );
                    p.setInt(1, uid);
                    r = p.executeQuery();

                    while (r.next()) {
                        int bid = r.getInt(1);
                        LocalDate bookingDate = (r.getTimestamp(3)).toLocalDateTime().toLocalDate();
                        LocalDate twoDaysBefore = (LocalDate.now()).minusDays(2);
            %>
                <tr>
                    <td><%= bid %></td>
                    <td><%= r.getString(2) %></td>
                    <td><%= r.getTimestamp(3) %></td>
                    <td><%= r.getString(4) %></td>
                    <td><%= r.getString(5) + "(RS"+r.getDouble(6)+")"%></td>
                    <td><%= r.getString(7) %></td>
                    <td>
                        <% if ("Booked".equals(r.getString(4)) && !(bookingDate.isBefore(twoDaysBefore))){ %>
                            <a class="btn danger" href="cancelBooking.jsp?id=<%= bid %>">Cancel</a>
                        <% } %>
                    </td>
                </tr>
            <%
                    }
                } catch (Exception e) {
            %>
                <tr>
                    <td colspan="6" class="error"><%= e.getMessage() %></td>
                </tr>
            <%
                } finally {
                    try {
                        if (r != null) r.close();
                    } catch (Exception ig) {
                        logIgnoredException("myBookings.jsp: closing ResultSet", ig);
                    }
                    try {
                        if (p != null) p.close();
                    } catch (Exception ig) {
                        logIgnoredException("myBookings.jsp: closing PreparedStatement p", ig);
                    }
                    try {
                        if (upd != null) upd.close();
                    } catch (Exception ig) {
                        logIgnoredException("myBookings.jsp: closing PreparedStatement upd", ig);
                    }
                    try {
                        if (c != null) c.close();
                    } catch (Exception ig) {
                        logIgnoredException("myBookings.jsp: closing Connection", ig);
                    }
                }
            %>
        </table>
    </div>

    <footer>
        BookSafar &copy; 2025
    </footer>
</body>
</html>