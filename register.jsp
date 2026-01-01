<%@page import="java.sql.*" %>
<%@ include file="config.jspf" %>
<%!
    boolean emailExists(Connection c, String email) throws Exception {
        PreparedStatement p = c.prepareStatement("SELECT 1 FROM Users WHERE email=?");
        p.setString(1, email);
        ResultSet r = p.executeQuery();
        boolean ex = r.next();
        r.close();
        p.close();
        return ex;
    }
%>
<%
    String msg = null;
    String err = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String pass = request.getParameter("password");
        String phone = request.getParameter("phone");
        boolean missing = name == null || email == null || pass == null || name.trim().isEmpty() || email.trim().isEmpty() || pass.trim().isEmpty();
        if (missing) {
            err = "All required fields must be filled.";
        } else if (pass.trim().length() < 6) {
            err = "Password must be at least 6 characters.";
        } else {
            Connection c = null;
            PreparedStatement p = null;
            try {
                c = getConnection();
                if (emailExists(c, email)) {
                    err = "Email already registered.";
                } else {
                    p = c.prepareStatement("INSERT INTO Users(name,email,password,phone) VALUES(?,?,?,?)");
                    p.setString(1, name.trim());
                    p.setString(2, email.trim());
                    p.setString(3, pass.trim());
                    p.setString(4, phone);
                    p.executeUpdate();
                    msg = "Registration successful. Please login.";
                }
            } catch (Exception e) {
                err = e.getMessage();
            } finally {
                try {
                    if (p != null)
                        p.close();
                } catch (Exception ig) {
                    logIgnoredException("register.jsp: closing PreparedStatement", ig);
                }
                try {
                    if (c != null)
                        c.close();
                } catch (Exception ig) {
                    logIgnoredException("register.jsp: closing Connection", ig);
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>User Registration</title>
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <%@ include file="header.jspf" %>
    <div class="container">
        <h2>User Registration</h2>
        <% if (msg != null) { %>
            <div class="success-msg"><%= msg %></div>
        <% } %>
        <% if (err != null) { %>
            <div class="error"><%= err %></div>
        <% } %>
        <form method="post">
            <label>Name*</label>
            <input name="name" />
            <label>Email*</label>
            <input name="email" type="email" />
            <label>Password*</label>
            <input name="password" type="password" />
            <label>Phone</label>
            <input name="phone" />
            <button class="btn" type="submit">Register</button>
        </form>
        <p>Already have an account? <a href="login.jsp">Login</a></p>
    </div>
    <footer>BookSafar &copy; 2025</footer>
</body>
</html>