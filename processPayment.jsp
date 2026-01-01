<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Date" %>
<%@ include file="config.jspf" %>

<%
    Integer uid = (Integer) session.getAttribute("userid");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve pending package info from session (set by book.jsp)
    Integer pid = (Integer) session.getAttribute("pendingPackageId");
    Double pkgPrice = (Double) session.getAttribute("pendingPackagePrice");
    String pkgTitle = (String) session.getAttribute("pendingPackageTitle");

    if (pid == null || pkgPrice == null) {
        // No pending package; redirect back to packages or show error
        response.sendRedirect("index.jsp");
        return;
    }

    String msg = null;
    String err = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String method = request.getParameter("method");
        Connection c = null;
        PreparedStatement lockPkg = null;
        PreparedStatement updateSeats = null;
        PreparedStatement createBooking = null;
        PreparedStatement createPayment = null;
        ResultSet pkgRs = null;
        ResultSet gen = null;

        try {
            if (method == null || method.trim().isEmpty()) {
                err = "Select a payment method.";
                throw new Exception("invalid payment method");
            }

            c = getConnection();
            c.setAutoCommit(false);

            lockPkg = c.prepareStatement(
                "SELECT title, price, seats, traveldate, availabletill FROM Package WHERE packageid=? AND deletedate IS NULL FOR UPDATE"
            );
            lockPkg.setInt(1, pid);
            pkgRs = lockPkg.executeQuery();
            if (!pkgRs.next()) {
                throw new Exception("Package is not available.");
            }

            pkgTitle = pkgRs.getString("title");
            double dbPrice = pkgRs.getDouble("price");
            pkgPrice = dbPrice;
            int seats = pkgRs.getInt("seats");
            Date travel = pkgRs.getDate("traveldate");
            Date availTill = pkgRs.getDate("availabletill");

            boolean windowOk = travel != null && !travel.toLocalDate().isBefore(java.time.LocalDate.now());
            if (availTill != null) {
                windowOk = windowOk && !availTill.toLocalDate().isBefore(java.time.LocalDate.now());
            }

            if (seats <= 0 || !windowOk) {
                throw new Exception("Package is fully booked or no longer available.");
            }

            createBooking = c.prepareStatement(
                "INSERT INTO Booking(userid, packageid) VALUES(?,?)",
                new String[]{"bookingid"}
            );
            createBooking.setInt(1, uid);
            createBooking.setInt(2, pid);
            createBooking.executeUpdate();

            gen = createBooking.getGeneratedKeys();
            int bid = 0;
            if (gen.next()) bid = gen.getInt(1);

            updateSeats = c.prepareStatement("UPDATE Package SET seats = seats - 1 WHERE packageid=?");
            updateSeats.setInt(1, pid);
            updateSeats.executeUpdate();

            createPayment = c.prepareStatement(
                "INSERT INTO Payment(bookingid, paymethod, amount, paystatus) VALUES(?,?,?,?)"
            );
            createPayment.setInt(1, bid);
            createPayment.setString(2, method.trim());
            createPayment.setDouble(3, dbPrice);
            createPayment.setString(4, "Completed");
            createPayment.executeUpdate();

            c.commit();
            msg = "Payment successful. Booking confirmed.";

            session.removeAttribute("pendingPackageId");
            session.removeAttribute("pendingPackagePrice");
            session.removeAttribute("pendingPackageTitle");
        } catch (Exception e) {
            try { if (c != null) c.rollback(); } catch (Exception ig) { logIgnoredException("processPayment.jsp: rollback", ig); }
            if (err == null) err = e.getMessage();
        } finally {
            try { 
            if (pkgRs != null) pkgRs.close(); 
            } catch (Exception ig) { 
            logIgnoredException("processPayment.jsp: closing ResultSet pkgRs", ig);
            }
            try { 
            if (gen != null) gen.close(); 
            } catch (Exception ig) { 
            logIgnoredException("processPayment.jsp: closing generated keys", ig); 
            }
            try { 
            if (createPayment != null) createPayment.close(); 
            } catch (Exception ig) { 
            logIgnoredException("processPayment.jsp: closing PreparedStatement createPayment", ig); 
            }
            try { 
            if (updateSeats != null) updateSeats.close(); 
            } catch (Exception ig) { 
            logIgnoredException("processPayment.jsp: closing PreparedStatement updateSeats", ig); 
            }
            try { 
            if (createBooking != null) createBooking.close(); 
            } catch (Exception ig) { 
            logIgnoredException("processPayment.jsp: closing PreparedStatement createBooking", ig); 
            }
            try { 
            if (lockPkg != null) lockPkg.close(); 
            } catch (Exception ig) { 
            logIgnoredException("processPayment.jsp: closing PreparedStatement lockPkg", ig); 
            }
            try { 
            if (c != null) c.close(); 
            } catch (Exception ig) { 
            logIgnoredException("processPayment.jsp: closing Connection", ig); 
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Payment</title>
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <%@ include file="header.jspf" %>
    <div class="container">
        <h2>Payment</h2>
        <p>Package: <strong><%= pkgTitle %></strong></p>
        <p>Amount: RS <%= pkgPrice %></p>

        <% if (msg != null) { %>
            <div class="success-msg"><%= msg %></div>
        <% } %>

        <% if (err != null) { %>
            <div class="error"><%= err %></div>
        <% } %>

        <form method="post">
            <label>Payment Method</label>
            <select name="method">
                <option>CreditCard</option>
                <option>UPI</option>
                <option>NetBanking</option>
            </select>
            <button class="btn" type="submit">Pay</button>
        </form>

        <p>
            <a href="myBookings.jsp" class="btn secondary">Go to My Bookings</a>
        </p>
    </div>

    <footer>
        BookSafar &copy; 2025
    </footer>
</body>
</html>