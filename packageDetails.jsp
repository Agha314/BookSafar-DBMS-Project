<%@page import="java.sql.*,java.time.*" %>
<%@ include file="config.jspf" %>
<%
  Integer aid = (Integer) session.getAttribute("adminid");
  boolean adminloggedin = true;
  if (aid == null) {
    adminloggedin = false;
    }
    String sid = request.getParameter("id");
    int id = 0;
    try {
        id = Integer.parseInt(sid);
    } catch (Exception e) {
    }
    Connection c = null;
    PreparedStatement p = null;
    ResultSet r = null;
    ResultSet rev = null;
    String title = null;
    String location = null;
    Double price = null;
    String duration = null;
    Integer seats = null;
    String desc = null;
    String image = null;
    LocalDate travelDate = null;
    LocalDate availableTill = null;
    String startpoint = null;
    String endpoint = null;
    try {
        c = getConnection();
        p = c.prepareStatement("SELECT title,location,price,duration,seats,description,imageurl,traveldate,startpoint,endpoint,availabletill FROM Package WHERE packageid=? AND deletedate IS NULL");
        p.setInt(1, id);
        r = p.executeQuery();
        if (r.next()) {
            title = r.getString(1);
            location = r.getString(2);
            price = r.getDouble(3);
            duration = r.getString(4);
            seats = r.getInt(5);
            desc = r.getString(6);
            image = r.getString(7);
            travelDate = r.getDate(8).toLocalDate();
            startpoint = r.getString(9);
            endpoint = r.getString(10);
            availableTill = r.getDate(11).toLocalDate();
        }
        r.close();
        p.close();
        p = c.prepareStatement("SELECT rating,reviewcomment,reviewdate FROM Review WHERE packageid=? ORDER BY reviewdate DESC");
        p.setInt(1, id);
        rev = p.executeQuery();
    } catch (Exception e) {
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= title != null ? title : "Package Details" %> | BookSafar</title>
    <link rel="stylesheet" href="assets/css/style.css" />
    <link rel="stylesheet" href="assets/css/active-link.css" />
</head>
<body>
    <%@ include file="header.jspf" %>
    <div class="container">
        <% if (title == null) { %>
            <div class="error pkg-not-found">Package not found.</div>
        <% } else { %>
            <div class="pkg-header">
                <h1><%= title %></h1>
                <div class="pkg-badges">
                    <span class="pkg-badge location"> <%= location %></span>
                    <span class="pkg-badge price">RS <%= String.format("%.2f", price) %></span>
                </div>
            </div>

            <div class="pkg-details-container">
                <div class="pkg-image-section">
                    <% if (image != null) { %>
                        <img src="<%= image %>" alt="<%= title %>" class="pkg-main-image" />
                    <% } else { %>
                        <div class="pkg-image-placeholder">image</div>
                    <% } %>
                </div>

                <div class="pkg-info-section">
                    <h3>Package Information</h3>
                    <div class="pkg-info-item">
                        <strong> Duration:        <%=duration%></strong>
                    </div>
                    <div class="pkg-info-item">
                        <strong> Travel Date:         <%=travelDate%></strong>
                    </div>
                    <div class="pkg-info-item">
                        <strong> Seats Available:         <%=seats%></strong>
                    </div>
                    <div class="pkg-info-item">
                        <strong> Available Till:          <%=availableTill%></strong>
                    </div>
                    <% if (startpoint != null || endpoint != null) { %>
                        <div class="pkg-info-item">
                            <strong> Route:           <%=startpoint%> To <%=endpoint%></strong>
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="pkg-description">
                <h3>Description</h3>
                <p><%= desc != null ? desc : "No description available." %></p>
            </div>

            <%
                boolean canBook = seats!=null && seats>=0 && travelDate!=null && !travelDate.isBefore(LocalDate.now()) && (availableTill==null || !availableTill.isBefore(LocalDate.now()));
            if(!adminloggedin) { %>
            <div class="pkg-booking-section">
                <% if (canBook) { %>
                    <h3>Ready to Book?</h3>
                    <a class="btn success pkg-book-btn" href="book.jsp?id=<%=id%>"> Book Now - RS <%= String.format("%.2f", price) %></a>
                    <p class="pkg-booking-note">Only <%= seats %> <%= seats == 1 ? "seat" : "seats" %> remaining!</p>
                <% } else { %>
                    <div class="error"> Booking closed for this package.</div>
                <% } %>
            </div>
            <% } %>
            <div class="pkg-reviews-section">
                <h2> Customer Reviews</h2>
                <div class="reviews-list">
                    <%
                        boolean any = false;
                        while (rev.next()) {
                            any = true;
                            int rating = rev.getInt(1);
                    %>
                    <div class="review-card">
                        <div class="review-header">
                            <span class="review-rating"><%= rating %>/5</span>
                            <small class="review-date"><%= rev.getTimestamp(3) %></small>
                        </div>
                        <p class="review-comment">"<%= rev.getString(2) != null ? rev.getString(2) : "No comment" %>"</p>
                    </div>
                    <%
                        }
                        if (!any) {
                    %>
                    <div class="no-reviews"> No reviews yet. Be the first to review!</div>
                    <%
                        }
                    %>
                </div>
            </div>
        <% } %>
    </div>
    <footer>BookSafar &copy; 2025</footer>
    <%
        try {
            if (rev != null) rev.close();
            if (p != null) p.close();
            if (c != null) c.close();
        } catch (Exception ig) {
            logIgnoredException("packageDetails.jsp: closing DB resources", ig);
        }
    %>
</body>
</html>