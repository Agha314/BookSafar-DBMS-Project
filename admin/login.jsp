<%@ page import="java.sql.*" %>
<%@ include file="../config.jspf" %>

<%
String err = null;
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String pass = request.getParameter("password");

    Connection c = null;
    PreparedStatement p = null;
    ResultSet r = null;

    try {
        c = getConnection();
        p = c.prepareStatement("SELECT adminid, name FROM Admin WHERE email=? AND password=?");
        p.setString(1, email);
        p.setString(2, pass);
        r = p.executeQuery();

        if (r.next()) {
            session.setAttribute("adminid", r.getInt(1));
            session.setAttribute("adminname", r.getString(2));
            response.sendRedirect("dashboard.jsp");
            return;
        } else {
            err = "Invalid credentials.";
        }
    } catch (Exception e) {
        err = e.getMessage();
    } finally {
        try {
            if (r != null) 
                r.close(); 
        } catch (Exception e) { 
            out.println("Error : " + e);
        }
        try { 
            if (p != null) 
                p.close(); 
        } catch (Exception ig) { 
            logIgnoredException("admin/login.jsp: closing PreparedStatement", ig); 
        }
        try { 
            if (c != null) 
                c.close(); 
        } catch (Exception ig) { 
            logIgnoredException("admin/login.jsp: closing Connection", ig); 
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="header.jspf" %>
    <title>Admin Login</title>
    <link rel="stylesheet" href="../assets/css/style.css" />
</head>
<body>
    <div class="container">
        <h2>Admin Login</h2>

        <% if (err != null) { %>
            <div class="error"><%= err %></div>
        <% } %>

        <form method="post">
            <label>Email</label>
            <input name="email" type="email" />

            <label>Password</label>
            <input name="password" type="password" />

            <button class="btn" type="submit">Login</button>
        </form>

        <p><a href="../index.jsp">Back to site</a></p>
    </div>
</body>
</html>