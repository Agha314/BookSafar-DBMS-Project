<%@ page import="java.sql.*" %>
<%@ include file="config.jspf" %>

<%
String err = null;
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String pass = request.getParameter("password");

    if (email != null && pass != null) {
        Connection c = null;
        PreparedStatement p = null;
        ResultSet r = null;

        try {
            c = getConnection();
            p = c.prepareStatement("SELECT userid, name FROM Users WHERE email=? AND password=?");
            p.setString(1, email);
            p.setString(2, pass);
            r = p.executeQuery();

            if (r.next()) {
                session.setAttribute("userid", r.getInt("userid"));
                session.setAttribute("username", r.getString("name"));
                response.sendRedirect("index.jsp");
                return;
            } else {
                err = "Invalid credentials.";
            }
        } catch (Exception e) {
            err = e.getMessage();
        } finally {
            try {
            if (r != null) r.close();
            } catch (Exception ig) {
            logIgnoredException("login.jsp: closing ResultSet", ig);
            }
            try {
            if (p != null) p.close();
            } catch (Exception ig) {
            logIgnoredException("login.jsp: closing PreparedStatement", ig);
            }
            try {
            if (c != null) c.close();
            } catch (Exception ig) {
            logIgnoredException("login.jsp: closing Connection", ig);
            }
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>User Login</title>
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <%@ include file="header.jspf" %>
    <div class="container">
        <h2>User Login</h2>

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

        <p>No account? <a href="register.jsp" style="color: blue; font-weight: bold;">Register</a></p>
    </div>

    <footer>
        BookSafar &copy; 2025
    </footer>
</body>
</html>