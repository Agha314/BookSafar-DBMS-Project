<%@page import="java.sql.*" %>
<%@ include file="../config.jspf" %>
<%
  Integer aid = (Integer)session.getAttribute("adminid");
  if(aid == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  
  String msg = null;
  String err = null;
  
  if("POST".equalsIgnoreCase(request.getMethod())) {
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String pass = request.getParameter("password");
    String phone = request.getParameter("phone");
    
    boolean missing = name == null || email == null || pass == null || 
                      name.trim().isEmpty() || email.trim().isEmpty() || pass.trim().isEmpty();
    
    if(missing) {
      err = "All required fields must be filled.";
    } else if(pass.trim().length() < 6) {
      err = "Password must be at least 6 characters.";
    } else {
      Connection c = null;
      PreparedStatement p = null;
      try {
        c = getConnection();
        p = c.prepareStatement("INSERT INTO Admin(name,email,password,phone) VALUES(?,?,?,?)");
        p.setString(1, name.trim());
        p.setString(2, email.trim());
        p.setString(3, pass.trim());
        p.setString(4, phone);
        p.executeUpdate();
        msg = "Admin added.";
      } catch(Exception e) {
        err = e.getMessage();
      } finally {
        try {
          if(p != null) p.close();
        } catch(Exception ig) {
          logIgnoredException("admin/addAdmin.jsp: closing PreparedStatement", ig);
        }
        try {
          if(c != null) c.close();
        } catch(Exception ig) {
          logIgnoredException("admin/addAdmin.jsp: closing Connection", ig);
        }
      }
    }
  }
%>
<!DOCTYPE html>
<html>
  <head>
    <%@ include file="header.jspf" %>
    <title>Add Admin</title>
    <link rel="stylesheet" href="../assets/css/style.css" />
  </head>
  <body>
    <div class="container">
      <h2>Add Admin</h2>
      <% if(msg != null) { %>
        <div class="success-msg"><%=msg%></div>
      <% } %>
      <% if(err != null) { %>
        <div class="error"><%=err%></div>
      <% } %>
      <form method="post">
        <label>Name</label><input name="name" />
        <label>Email</label><input name="email" type="email" />
        <label>Password</label><input name="password" type="password" />
        <label>Phone</label><input name="phone" />
        <button class="btn" type="submit">Add</button>
      </form>
      <p><a href="dashboard.jsp" class="btn secondary">Back</a></p>
    </div>
  </body>
</html>