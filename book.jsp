<%@page import="java.sql.*" %>
<%@ include file="config.jspf" %>
<%
    Integer uid = (Integer) session.getAttribute("userid");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int pid = 0;
    try {
        pid = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
    }

    Connection c = null;
    PreparedStatement p = null;
    ResultSet r = null;
    String title = null;
    Double price = null;
    Integer seats = null;
    java.time.LocalDate travelDate = null;
    java.time.LocalDate availableTill = null;
    try {
        c = getConnection();
        p = c.prepareStatement("SELECT title,price,seats,traveldate,availabletill FROM Package WHERE packageid=? AND deletedate IS NULL");
        p.setInt(1, pid);
        r = p.executeQuery();
        if (r.next()) {
            title = r.getString(1);
            price = r.getDouble(2);
            seats = r.getInt(3);
            travelDate = r.getDate(4).toLocalDate();
            availableTill = r.getDate(5).toLocalDate();
        }
    } catch (Exception e) {
    } finally {
        try {
            if (r != null)
                r.close();
        } catch (Exception ig) {
            logIgnoredException("book.jsp: closing ResultSet", ig);
        }
        try {
            if (p != null)
                p.close();
        } catch (Exception ig) {
            logIgnoredException("book.jsp: closing PreparedStatement", ig);
        }
    }

    String msg = null;
    String err = null;
    boolean available = seats != null && seats > 0 && travelDate != null && !travelDate.isBefore(java.time.LocalDate.now()) && (availableTill == null || !availableTill.isBefore(java.time.LocalDate.now()));
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            if (!available) {
                err = "Package is no longer available.";
            } else {
                session.setAttribute("pendingPackageId", pid);
                session.setAttribute("pendingPackagePrice", price);
                session.setAttribute("pendingPackageTitle", title);
                response.sendRedirect("processPayment.jsp");
                return;
            }
        } catch (Exception e) {
            err = e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Book Package</title>
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <%@ include file="header.jspf" %>
    <div class="container">
        <h2>Book: <%= title %></h2>
        <% if (err != null) { %>
            <div class="error"><%= err %></div>
        <% } %>
        <p>
            Travel Date: <strong><%= travelDate %></strong> | Seats left: <strong><%= seats %></strong>
        </p>
        <form method="post">
            <p>Confirm booking for <strong><%= title %></strong> at price $<%= price %></p>
            <button class="btn" type="submit" <%= available ? "" : "disabled" %>>Proceed to Payment</button>
        </form>
    </div>
    <footer>BookSafar &copy; 2025</footer>
<%
    try {
        if (c != null)
            c.close();
    } catch (Exception ig) {
        logIgnoredException("book.jsp: closing Connection", ig);
    }
%>
</body>
</html>