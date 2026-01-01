<%@page import="java.sql.*,java.time.*,java.time.temporal.ChronoUnit" %>
<%@ include file="config.jspf" %>
<%
    Integer uid = (Integer) session.getAttribute("userid");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int id = 0;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
    }
    String msg = null;
    String err = null;
    Connection c = null;
    PreparedStatement p = null;
    ResultSet r = null;
    Timestamp btime = null;
    String status = null;
    Integer packageId = null;
    try {
        c = getConnection();
        p = c.prepareStatement("SELECT bookingdate,status,packageid FROM Booking WHERE bookingid=? AND userid=?");
        p.setInt(1, id);
        p.setInt(2, uid);
        r = p.executeQuery();
        if (r.next()) {
            btime = r.getTimestamp(1);
            status = r.getString(2);
            packageId = r.getInt(3);
        }
    } catch (Exception e) {
        err = e.getMessage();
    }
    finally {
        try {
            if (r != null)
                r.close();
        } catch (Exception ig) {
            logIgnoredException("cancelBooking.jsp: closing ResultSet", ig);
        }
        try {
            if (p != null)
                p.close();
        } catch (Exception ig) {
            logIgnoredException("cancelBooking.jsp: closing PreparedStatement", ig);
        }
    }
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String reason = request.getParameter("reason");
        if (btime != null && status != null && "Booked".equals(status)) {
            long hours = ChronoUnit.HOURS.between(btime.toInstant(), Instant.now());
            if (hours <= 48) {
                PreparedStatement upd = null;
                PreparedStatement updPay = null;
                PreparedStatement updSeats = null;
                try {
                    c.setAutoCommit(false);
                    upd = c.prepareStatement("UPDATE Booking SET status='Cancelled', cancelreason=?, canceldate=CURRENT_TIMESTAMP WHERE bookingid=?");
                    upd.setString(1, reason);
                    upd.setInt(2, id);
                    upd.executeUpdate();

                    updPay = c.prepareStatement("UPDATE Payment SET paystatus='Refunded' WHERE bookingid=?");
                    updPay.setInt(1, id);
                    updPay.executeUpdate();

                    if (packageId != null) {
                        updSeats = c.prepareStatement("UPDATE Package SET seats = seats + 1 WHERE packageid=?");
                        updSeats.setInt(1, packageId);
                        updSeats.executeUpdate();
                    }

                    c.commit();
                    msg = "Booking cancelled.";
                } catch (Exception e) {
                    try { if (c != null) c.rollback(); } catch (Exception ig) { logIgnoredException("cancelBooking.jsp: rollback", ig); }
                    err = e.getMessage();
                } finally {
                  try {
                    if (updSeats != null)
                      updSeats.close();
                  } catch (Exception ig) {
                    logIgnoredException("cancelBooking.jsp: closing PreparedStatement updSeats", ig);
                  }
                  try {
                    if (updPay != null)
                      updPay.close();
                  } catch (Exception ig) {
                    logIgnoredException("cancelBooking.jsp: closing PreparedStatement updPay", ig);
                  }
                  try {
                    if (upd != null)
                      upd.close();
                  } catch (Exception ig) {
                    logIgnoredException("cancelBooking.jsp: closing PreparedStatement upd", ig);
                  }
                  try {
                    if (c != null)
                      c.setAutoCommit(true);
                  } catch (Exception ig) {
                    logIgnoredException("cancelBooking.jsp: restoring autocommit", ig);
                  }
                }
              } else
                err = "Cancellation window (48h) passed.";
        } else
            err = "Invalid booking.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Cancel Booking</title>
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <%@ include file="header.jspf" %>
    <div class="container">
        <h2>Cancel Booking #<%= id %></h2>
        <% if (msg != null) { %>
            <div class="success-msg"><%= msg %></div>
        <% } %>
        <% if (err != null) { %>
            <div class="error"><%= err %></div>
        <% } %>
        <% if (btime != null && "Booked".equals(status)) { %>
            <form method="post">
                <label>Reason</label>
                <textarea name="reason"></textarea>
                <button class="btn danger" type="submit">Confirm Cancel</button>
            </form>
        <% } %>
        <p><a href="myBookings.jsp" class="btn secondary">Back</a></p>
    </div>
    <footer>BookSafar &copy; 2025</footer>
    <%
        try {
            if (c != null)
                c.close();
        } catch (Exception ig) {
            logIgnoredException("cancelBooking.jsp: closing Connection", ig);
        }
    %>
</body>
</html>