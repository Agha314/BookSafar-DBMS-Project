<%@page import="java.sql.*" %>
<%@page import="java.sql.Date" %>
<%@ include file="../config.jspf" %>
<%
Integer aid=(Integer)session.getAttribute("adminid");
if(aid==null){
  response.sendRedirect("login.jsp");
  return;
}
int id=0;
try{
  id=Integer.parseInt(request.getParameter("id"));
}catch(Exception e){
  response.sendRedirect("packages.jsp");
  return;
}
String msg=null;
String err=null;
if("POST".equalsIgnoreCase(request.getMethod())) {
  Connection c = null;
  PreparedStatement p = null;
  try {
    c = getConnection();
    p = c.prepareStatement("UPDATE Package SET title=?,location=?,price=?,duration=?,seats=?,description=?,imageurl=?,traveldate=?,startpoint=?,endpoint=?,availabletill=? WHERE packageid=? AND createdby=? AND deletedate IS NULL");
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
    p.setInt(12, id);
    p.setInt(13, aid);
    int updated = p.executeUpdate();
    if(updated > 0) {
      msg = "Package updated successfully!";
    } else {
      err = "Package not found or you don't have permission to edit it.";
    }
  } catch(Exception e) {
    err = e.getMessage();
  } finally {
    try {
      if(p != null)
        p.close();
    } catch(Exception ig) { 
      logIgnoredException("admin/editpackage.jsp: closing PreparedStatement (update)", ig); 
    }
    try {
      if(c != null)
        c.close();
    } catch(Exception ig) { 
      logIgnoredException("admin/editpackage.jsp: closing Connection (update)", ig); 
    }
  }
}
// Load package data
String title="",location="",duration="",description="",imageurl="",startpoint="",endpoint="";
double price=0;
int seats=0;
String traveldate="",availabletill="";
Connection c=null;
PreparedStatement p=null;
ResultSet r=null;
try{
  c=getConnection();
  p=c.prepareStatement("SELECT title,location,price,duration,seats,description,imageurl,traveldate,startpoint,endpoint,availabletill FROM Package WHERE packageid=? AND createdby=? AND deletedate IS NULL");
  p.setInt(1,id);
  p.setInt(2,aid);
  r=p.executeQuery();
  if(r.next()){
    title=r.getString(1);
    location=r.getString(2);
    price=r.getDouble(3);
    duration=r.getString(4);
    seats=r.getInt(5);
    description=r.getString(6);
    imageurl=r.getString(7);
    traveldate=r.getString(8);
    startpoint=r.getString(9);
    endpoint=r.getString(10);
    availabletill=r.getString(11);
    
  } else {
    err="Package not found or you don't have permission to edit it.";
  }
}catch(Exception e){
  err=e.getMessage();
}finally{
  try{
    if(r!=null)
      r.close();
  }catch(Exception ig){ logIgnoredException("admin/editpackage.jsp: closing ResultSet", ig); }
  try{
    if(p!=null)
      p.close();
  }catch(Exception ig){ logIgnoredException("admin/editpackage.jsp: closing PreparedStatement (load)", ig); }
  try{
    if(c!=null)
      c.close();
  }catch(Exception ig){ logIgnoredException("admin/editpackage.jsp: closing Connection (load)", ig); }
}
%>
<!DOCTYPE html>
<html>
<head>
  <%@ include file="header.jspf" %>
  <title>Edit Package</title>
  <link rel="stylesheet" href="../assets/css/style.css" />
</head>
<body>
<div class="container">
<h2>Edit Package</h2>
<% if(msg!=null){ %><div class="success-msg"><%=msg%></div><% } %>
<% if(err!=null){ %><div class="error"><%=err%></div><% } %>
<% if(err==null || msg!=null){ %>
<form method="post" action="editpackage.jsp?id=<%=id%>">
  <label>Title</label>
  <input name="title" placeholder="Title" value="<%=title%>" required />
  
  <label>Location</label>
  <input name="location" placeholder="Location" value="<%=location%>" required />
  
  <label>Price (RS)</label>
  <input name="price" type="number" step="0.01" placeholder="Price" value="<%=price%>" required />
  
  <label>Duration</label>
  <input name="duration" placeholder="Duration (Days,Nights)" value="<%=duration%>" required />
  
  <label>Seats</label>
  <input name="seats" type="number" placeholder="Seats" value="<%=seats%>" required />
  
  <label>Travel Date</label>
  <input name="traveldate" type="date" value="<%=traveldate%>" required />
  
  <label>Available Till</label>
  <input name="availabletill" type="date" value="<%=availabletill%>" />
  
  <label>Image URL</label>
  <input name="imageurl" placeholder="Image URL" value="<%=imageurl%>" />
  
  <label>Start Point</label>
  <input name="startpoint" placeholder="Start Point" value="<%=startpoint%>" required />
  
  <label>End Point</label>
  <input name="endpoint" placeholder="End Point" value="<%=endpoint%>" required />
  
  <label>Description</label>
  <textarea name="description" placeholder="Description" rows="5"><%=description%></textarea>
  
  <button class="btn" type="submit">Update Package</button>
</form>
<% } %>
<p><a href="packages.jsp" class="btn secondary">Back to Packages</a></p>
</div>
</body>
</html>
