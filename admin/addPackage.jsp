<%@page import="java.sql.*" %>
<%@page import="java.sql.Date" %>
<%@ include file="../config.jspf" %>
<%
Integer aid=(Integer)session.getAttribute("adminid");
if(aid==null){
  response.sendRedirect("login.jsp");
  return;
}
String msg=null;
String err=null;
if("POST".equalsIgnoreCase(request.getMethod())) {
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
    p.setString(7, "assets/images/" + request.getParameter("imageurl"));
    p.setDate(8, Date.valueOf(request.getParameter("traveldate")));
    p.setString(9, request.getParameter("startpoint"));
    p.setString(10, request.getParameter("endpoint"));
    String avail = request.getParameter("availabletill");
    if(avail != null && !avail.trim().isEmpty()) {
      p.setDate(11, Date.valueOf(avail));
    } else {
      p.setNull(11, java.sql.Types.DATE);
    }
    p.setInt(12, aid);
    p.executeUpdate();
    msg = "Package added successfully!";
  } catch(Exception e) {
    err = e.getMessage();
  } finally {
    try {
      if(p != null)
        p.close();
    } catch(Exception ig) { 
      logIgnoredException("admin/addPackage.jsp: closing PreparedStatement", ig); 
    }
    try {
      if(c != null)
        c.close();
    } catch(Exception ig) { 
      logIgnoredException("admin/addPackage.jsp: closing Connection", ig); 
    }
  }
}
%>
<!DOCTYPE html>
<html>
<head>
  <%@ include file="header.jspf" %>
  <title>Add Package</title>
  <link rel="stylesheet" href="../assets/css/style.css" />
</head>
<body>
<div class="container">
<h2>Add New Package</h2>
<% if(msg != null) { %>
  <div class="success-msg"><%=msg%></div>
<% } %>
<% if(err != null) { %>
  <div class="error"><%=err%></div>
<% } %>
<form method="post" action="addPackage.jsp">
  <label>Title</label>
  <input name="title" placeholder="Title" required />
  
  <label>Location</label>
  <input name="location" placeholder="Location" required />
  
  <label>Price (RS)</label>
  <input name="price" type="number" step="0.01" placeholder="Price" required />
  
  <label>Duration</label>
  <input name="duration" placeholder="Duration (Days, Nights)" required />
  
  <label>Seats</label>
  <input name="seats" type="number" placeholder="Seats" required />
  
  <label>Travel Date</label>
  <input name="traveldate" type="date" required />
  
  <label>Available Till</label>
  <input name="availabletill" type="date" />
  
  <label>Image URL</label>
  <input name="imageurl" placeholder="image.jpg" />
  
  <label>Start Point</label>
  <input name="startpoint" placeholder="Start Point" required />
  
  <label>End Point</label>
  <input name="endpoint" placeholder="End Point" required />
  
  <label>Description</label>
  <textarea name="description" placeholder="Description" rows="5"></textarea>
  
  <button class="btn" type="submit">Add Package</button>
</form>
<p><a href="packages.jsp" class="btn secondary">Back to Packages</a></p>
</div>
</body>
</html>
