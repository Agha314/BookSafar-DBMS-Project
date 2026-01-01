<%@page import="java.sql.*" %>
<%@page import="java.sql.Date" %>
<%@ include file="../config.jspf" %>
<%
Integer aid = (Integer) session.getAttribute("adminid");
if (aid == null) {
  response.sendRedirect("login.jsp");
  return;
}
String action = request.getParameter("action");
String msg = null;
String err = null;

if ("delete".equals(action)) {
  int id = 0;
  try {
    id = Integer.parseInt(request.getParameter("id"));
  } catch (Exception e) {
    logIgnoredException("admin/packages.jsp: parsing package id for delete", e);
    
  }
  Connection c = null;
  PreparedStatement p = null;
  try {
    c = getConnection();
    p = c.prepareStatement("UPDATE Package SET deletedby=?, deletedate=CURRENT_TIMESTAMP WHERE packageid=? AND deletedate IS NULL");
    p.setInt(1, aid);
    p.setInt(2, id);
    int updated = p.executeUpdate();
    msg = updated > 0 ? "Package deleted successfully!" : "Package already deleted or not found.";
  } catch (Exception e) {
    err = e.getMessage();
  } finally {
    try {
      if (p != null) p.close();
    } catch (Exception ig) {
      logIgnoredException("admin/packages.jsp: closing PreparedStatement (delete)", ig);
    }
    try {
      if (c != null) c.close();
    } catch (Exception ig) {
      logIgnoredException("admin/packages.jsp: closing Connection (delete)", ig);
    }
  }
}

if ("add".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
  Connection c = null;
  PreparedStatement p = null;
  try {
    c = getConnection();
    p = c.prepareStatement("INSERT INTO Package(title,location,price,duration,seats,description,imageurl,traveldate,startpoint,endpoint,availabletill,createdby) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)");
    p.setString(1, request.getParameter("title"));
    p.setString(2, request.getParameter("location"));
    p.setDouble(3, Double.parseDouble(request.getParameter("price")));
    p.setString(4, request.getParameter("duration"));
    p.setInt(5, Integer.parseInt(request.getParameter("seats")));
    p.setString(6, request.getParameter("description"));
    p.setString(7, request.getParameter("imageurl"));
    p.setDate(8, Date.valueOf(request.getParameter("traveldate")));
    p.setString(9, request.getParameter("startpoint"));
    p.setString(10, request.getParameter("endpoint"));
    String avail = request.getParameter("availabletill");
    if (avail != null && !avail.trim().isEmpty()) {
      p.setDate(11, Date.valueOf(avail));
    } else {
      p.setNull(11, java.sql.Types.DATE);
    }
    p.setInt(12, aid);
    p.executeUpdate();
    msg = "Added.";
  } catch (Exception e) {
    err = e.getMessage();
  } finally {
    try {
      if (p != null) p.close();
    } catch (Exception ig) {
      logIgnoredException("admin/packages.jsp: closing PreparedStatement (add)", ig);
    }
    try {
      if (c != null) c.close();
    } catch (Exception ig) {
      logIgnoredException("admin/packages.jsp: closing Connection (add)", ig);
    }
  }
}
%>
<!DOCTYPE html>
<html>
<head>
  <%@ include file="header.jspf" %>
  <title>Manage Packages</title>
  <link rel="stylesheet" href="../assets/css/style.css" />
</head>
<body>
<div class="container">
  <h2>Manage Packages</h2>
  <% if (msg != null) { %>
    <div class="success-msg"><%= msg %></div>
  <% } %>
  <% if (err != null) { %>
    <div class="error"><%= err %></div>
  <% } %>
  <h3>Existing Packages</h3>
  <table>
    <tr>
      <th>ID</th>
      <th>Title</th>
      <th>Location</th>
      <th>Price</th>
      <th>Duration</th>
      <th>Seats</th>
      <th>Travel Date</th>
      <th>Available Till</th>
      <th>Bookings</th>
      <th>Action</th>
    </tr>
    <%
    Connection c = null;
    PreparedStatement p = null;
    ResultSet r = null;
    try {
      c = getConnection();
      p = c.prepareStatement("SELECT packageid,title,location,price,duration,seats,traveldate,availabletill,createdby FROM Package WHERE deletedate IS NULL ORDER BY packageid DESC");
      r = p.executeQuery();
      while (r.next()) {
        int pid = r.getInt("packageid");
        int createdBy = r.getInt("createdby");
    %>
    <tr>
      <td><%= pid %></td>
      <td><%= r.getString("title") %></td>
      <td><%= r.getString("location") %></td>
      <td>RS <%= r.getDouble("price") %></td>
      <td><%= r.getString("duration") %></td>
      <td><%= r.getInt("seats") %></td>
      <td><%= r.getString("traveldate") %></td>
      <td><%= r.getString("availabletill") %></td>
      <td>
        <div class="booking-summary">
          <%
          Connection cb = null;
          PreparedStatement pb = null;
          ResultSet rb = null;
          int booked = 0, completed = 0, cancelled = 0;
          try {
            cb = getConnection();
            pb = cb.prepareStatement("SELECT COUNT(*) as cnt, b.status FROM Booking b WHERE b.packageid=? GROUP BY b.status");
            pb.setInt(1, pid);
            rb = pb.executeQuery();
            while (rb.next()) {
              String status = rb.getString("status");
              int count = rb.getInt("cnt");
              if ("Booked".equalsIgnoreCase(status)) booked = count;
              else if ("Completed".equalsIgnoreCase(status)) completed = count;
              else if ("Cancelled".equalsIgnoreCase(status)) cancelled = count;
            }
          } catch (Exception e) { %>
            <span class="error"><%= e.getMessage() %></span>
          <% } finally {
            try {
              if (rb != null) rb.close();
            } catch (Exception ig) {
              logIgnoredException("admin/packages.jsp: closing ResultSet rb", ig);
            }
            try {
              if (pb != null) pb.close();
            } catch (Exception ig) {
              logIgnoredException("admin/packages.jsp: closing PreparedStatement pb", ig);
            }
            try {
              if (cb != null) cb.close();
            } catch (Exception ig) {
              logIgnoredException("admin/packages.jsp: closing Connection cb", ig);
            }
          } %>
          <span class="booking-badge booked">Booked: <%= booked %></span><br>
          <span class="booking-badge completed">Completed: <%= completed %></span><br>
          <span class="booking-badge cancelled">Cancelled: <%= cancelled %></span>
        </div>
      </td>
      <td>
        <% if (createdBy == aid) { %>
          <a class="btn danger" href="packages.jsp?action=delete&id=<%= pid %>">Delete</a>
          <a class="btn" href="editpackage.jsp?id=<%= pid %>">Edit</a>
        <% } %>
      </td>
    </tr>
    <% }
    } catch (Exception e) { %>
    <tr><td colspan="10" class="error"><%= e.getMessage() %></td></tr>
    <% } finally {
      try {
        if (r != null) r.close();
      } catch (Exception ig) {
        logIgnoredException("admin/packages.jsp: closing ResultSet r", ig);
      }
      try {
        if (p != null) p.close();
      } catch (Exception ig) {
        logIgnoredException("admin/packages.jsp: closing PreparedStatement p", ig);
      }
      try {
        if (c != null) c.close();
      } catch (Exception ig) {
        logIgnoredException("admin/packages.jsp: closing Connection c", ig);
      }
    } %>
  </table>
  <p><a href="dashboard.jsp" class="btn secondary">Back</a></p>
  <p><a href="addPackage.jsp" class="btn">Add New Package</a></p>
</div>
</body>
</html>