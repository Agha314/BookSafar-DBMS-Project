<%@page import="java.sql.*" %>
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
%>
<!DOCTYPE html>
<html>
<head>
  <%@ include file="header.jspf" %>
  <title>Manage Users</title>
  <link rel="stylesheet" href="../assets/css/style.css" />
    
</head>
<body>
  <div class="container">
    <h2>Users</h2>
    <% if (msg != null) { %>
      <div class="success-msg"><%= msg %></div>
    <% } %>
    <% if (err != null) { %>
      <div class="error"><%= err %></div>
    <% } %>
    <table>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Created</th>
      </tr>
      <%
        Connection c = null;
        PreparedStatement p = null;
        ResultSet r = null;
        try {
          c = getConnection();
          p = c.prepareStatement("SELECT DISTINCT u.userid, u.name, u.email, u.phone, u.createdate FROM Users u JOIN booking b   ON u.userid = b.userid JOIN package pk  ON b.packageid = pk.packageid JOIN admin ad    ON pk.createdby = ad.adminid WHERE ad.adminid = ? ORDER BY u.createdate DESC");
          p.setInt(1, aid);
          r = p.executeQuery();
          while (r.next()) {
      %>
      <tr>
        <td><%= r.getInt(1) %></td>
        <td><%= r.getString(2) %></td>
        <td><%= r.getString(3) %></td>
        <td><%= r.getString(4) %></td>
        <td><%= r.getTimestamp(5) %></td>
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
            logIgnoredException("admin/users.jsp: closing ResultSet", ig);
          }
          try {
            if (p != null) p.close();
          } catch (Exception ig) {
            logIgnoredException("admin/users.jsp: closing PreparedStatement", ig);
          }
          try {
            if (c != null) c.close();
          } catch (Exception ig) {
            logIgnoredException("admin/users.jsp: closing Connection", ig);
          }
        }
      %>
    </table>
    <p>
      <a href="dashboard.jsp" class="btn secondary">Back</a>
    </p>
  </div>
    
</body>
</html>