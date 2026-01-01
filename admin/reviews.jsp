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
if ("delete".equals(action)) {
  int id = 0;
  try {
    id = Integer.parseInt(request.getParameter("id"));
  } catch (Exception e) {
    // Handle exception
  }
  Connection c = null;
  PreparedStatement p = null;
  try {
    c = getConnection();
    p = c.prepareStatement("DELETE FROM Review WHERE reviewid=?");
    p.setInt(1, id);
    p.executeUpdate();
    msg = "Review deleted.";
  } catch (Exception e) {
    err = e.getMessage();
  } finally {
    try {
      if (p != null)
        p.close();
    } catch (Exception ig) {
      logIgnoredException("admin/reviews.jsp: closing PreparedStatement (delete)", ig);
    }
    try {
      if (c != null)
        c.close();
    } catch (Exception ig) {
      logIgnoredException("admin/reviews.jsp: closing Connection (delete)", ig);
    }
  }
}
%>
<!DOCTYPE html>
<html>
<head>
  <%@ include file="header.jspf" %>
  <title>Manage Reviews</title>
  <link rel="stylesheet" href="../assets/css/style.css" />
</head>
<body>
<div class="container">
<h2>Reviews</h2>
<% if(msg!=null){ %><div class="success-msg"><%=msg%></div><% } %>
<% if(err!=null){ %><div class="error"><%=err%></div><% } %>
<table>
  <tr>
    <th>ID</th><th>Package</th><th>User</th><th>Rating</th><th>Comment</th><th>Date</th><th>Action</th>
  </tr>
<%
Connection c=null;
PreparedStatement p=null;
ResultSet r=null;
try{
  c=getConnection();
  p=c.prepareStatement("SELECT r.reviewid, pk.title, u.name, r.rating, r.reviewcomment, r.reviewdate FROM Review r JOIN Package pk ON r.packageid=pk.packageid JOIN Users u ON r.userid=u.userid WHERE pk.createdby = ? ORDER BY r.reviewdate DESC");
  p.setInt(1, aid);
  r=p.executeQuery();
  while(r.next()){ %>
          <tr>
          <td><%=r.getInt(1)%></td>
          <td><%=r.getString(2)%></td>
          <td><%=r.getString(3)%></td>
          <td><%=r.getInt(4)%></td>
          <td><%=r.getString(5)%></td>
          <td><%=r.getTimestamp(6)%></td>
          <td><a class="btn danger" href="reviews.jsp?action=delete&id=<%=r.getInt(1)%>">Delete</a></td>
          </tr>
  <% } 
}catch(Exception e){ %>
  <tr><td colspan="7" class="error"><%=e.getMessage()%></td>
  </tr>
  <% }finally{
    try{
      if(r!=null)
        r.close();
    }catch(Exception ig){
        logIgnoredException("admin/reviews.jsp: closing ResultSet", ig);
    }try{
      if(p!=null)
        p.close();
    }catch(Exception ig){
        logIgnoredException("admin/reviews.jsp: closing PreparedStatement", ig);
    }try{
        if(c!=null)
          c.close();
    }catch(Exception ig){
        logIgnoredException("admin/reviews.jsp: closing Connection", ig);
    }
  } %>
  </table>
<p><a href="dashboard.jsp" class="btn secondary">Back</a></p>
</div>
</body></html>