<%@ page import="java.sql.*" %>
<%@ page import="java.sql.Date" %>
<%@ include file="config.jspf" %>

<%
    Integer uid = (Integer) session.getAttribute("userid");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = null;
    String err = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int bookingId = 0;
        try {
            bookingId = Integer.parseInt(request.getParameter("bookingid"));
        } catch (Exception e) {
        }

        int rating = 0;
        try {
            rating = Integer.parseInt(request.getParameter("rating"));
        } catch (Exception e) {
        }

        String comment = request.getParameter("comment");

        if (bookingId <= 0 || rating < 1 || rating > 5) {
            err = "Provide a valid booking id and rating (1-5).";
        } else {
            Connection c = null;
            PreparedStatement checkBooking = null;
            PreparedStatement checkReview = null;
            PreparedStatement insert = null;
            ResultSet brs = null;
            ResultSet rrs = null;

            try {
                c = getConnection();
                checkBooking = c.prepareStatement(
                    "SELECT b.packageid, b.status, pk.traveldate " +
                    "FROM Booking b JOIN Package pk ON pk.packageid=b.packageid " +
                    "WHERE b.bookingid=? AND b.userid=?"
                );
                checkBooking.setInt(1, bookingId);
                checkBooking.setInt(2, uid);
                brs = checkBooking.executeQuery();
                if (!brs.next()) {
                    throw new Exception("Booking not found.");
                }
                int pkgId = brs.getInt(1);
                String bstatus = brs.getString(2);
                Date tdate = brs.getDate(3);
                boolean travelDone = tdate != null && !tdate.toLocalDate().isAfter(java.time.LocalDate.now());
                if ("Cancelled".equals(bstatus) || !("Completed".equals(bstatus) || travelDone)) {
                    throw new Exception("Reviews are allowed after travel date or completion only.");
                }

                checkReview = c.prepareStatement("SELECT 1 FROM Review WHERE bookingid=?");
                checkReview.setInt(1, bookingId);
                rrs = checkReview.executeQuery();
                if (rrs.next()) {
                    throw new Exception("This booking is already reviewed.");
                }

                insert = c.prepareStatement(
                    "INSERT INTO Review(userid, packageid, bookingid, rating, reviewcomment) VALUES(?,?,?,?,?)"
                );
                insert.setInt(1, uid);
                insert.setInt(2, pkgId);
                insert.setInt(3, bookingId);
                insert.setInt(4, rating);
                insert.setString(5, comment);
                insert.executeUpdate();
                msg = "Review submitted.";
            } catch (Exception e) {
                err = e.getMessage();
            } finally {
                try {
                    if (rrs != null) rrs.close();
                } catch (Exception ig) {
                    logIgnoredException("addReview.jsp: closing ResultSet rrs", ig);
                }
                try {
                    if (brs != null) brs.close();
                } catch (Exception ig) {
                    logIgnoredException("addReview.jsp: closing ResultSet brs", ig);
                }
                try {
                    if (insert != null) insert.close();
                } catch (Exception ig) {
                    logIgnoredException("addReview.jsp: closing PreparedStatement insert", ig);
                }
                try {
                    if (checkReview != null) checkReview.close();
                } catch (Exception ig) {
                    logIgnoredException("addReview.jsp: closing PreparedStatement checkReview", ig);
                }
                try {
                    if (checkBooking != null) checkBooking.close();
                } catch (Exception ig) {
                    logIgnoredException("addReview.jsp: closing PreparedStatement checkBooking", ig);
                }
                try {
                    if (c != null) c.close();
                } catch (Exception ig) {
                    logIgnoredException("addReview.jsp: closing Connection", ig);
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Add Review</title>
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <%@ include file="header.jspf" %>

    <div class="container">
        <h2>Submit Review</h2>

        <% if (msg != null) { %>
            <div class="success-msg"><%= msg %></div>
        <% } %>

        <% if (err != null) { %>
            <div class="error"><%= err %></div>
        <% } %>

        <form method="post">
            <label>Booking ID</label>
            <input name="bookingid" />

            <label>Rating (1-5)</label>
            <input name="rating" />

            <label>Comment</label>
            <textarea name="comment"></textarea>

            <button class="btn" type="submit">Submit</button>
        </form>
    </div>

    <footer>
        BookSafar &copy; 2025
    </footer>
</body>
</html>