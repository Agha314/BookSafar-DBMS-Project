<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="config.jspf" %>

<!DOCTYPE html>
<html>
<head>
    <title>BookSafar - Packages</title>
    <link rel="stylesheet" href="assets/css/style.css" />
</head>
<body>
    <%@ include file="header.jspf" %>

    <div class="container">
        <h2>Browse Packages</h2>

        <form method="get" action="index.jsp" class="flex" style="gap:10px;flex-wrap:wrap;align-items:center;">
            <input
                type="text"
                name="q"
                placeholder="Search by title/location"
                value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>" />

            <select name="sort" aria-label="Sort by price">
                <option value="">Sort by</option>
                <option value="price_asc" <%= "price_asc".equals(request.getParameter("sort")) ? "selected" : "" %>>Price: Low to High</option>
                <option value="price_desc" <%= "price_desc".equals(request.getParameter("sort")) ? "selected" : "" %>>Price: High to Low</option>
            </select>

            <button type="submit" style="margin-left: auto;" class="btn">Filter</button>
        </form>

        <div class="grid" style="margin-top:20px;">
            <%
                String term = request.getParameter("q");
                String trimmed = term != null ? term.trim() : "";
                boolean hasTerm = trimmed != null && !trimmed.isEmpty();
                String sort = request.getParameter("sort");
                boolean sortPriceAsc = "price_asc".equals(sort);
                boolean sortPriceDesc = "price_desc".equals(sort);

                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;

                try {
                    conn = getConnection();
                    StringBuilder sql = new StringBuilder();
                    sql.append("SELECT packageid, title, location, price, duration, imageurl, description, seats, traveldate, availabletill ");
                    sql.append("FROM Package WHERE deletedate IS NULL ");
                    sql.append("AND availabletill >= TRUNC(SYSDATE) AND seats > 0 ");

                    List<String> params = new ArrayList<String>();

                    if (hasTerm) {
                        sql.append("AND (LOWER(title) LIKE ? OR LOWER(location) LIKE ?) ");
                        String pattern = "%" + trimmed.toLowerCase() + "%";
                        params.add(pattern);
                        params.add(pattern);
                    }


                    sql.append("ORDER BY ");
                    if (sortPriceAsc) {
                        sql.append("price ASC");
                    } else if (sortPriceDesc) {
                        sql.append("price DESC");
                    } else {
                        sql.append("createdate DESC");
                    }

                    ps = conn.prepareStatement(sql.toString());
                    int index = 1;
                    for (String p : params) {
                        ps.setString(index++, p);
                    }

                    rs = ps.executeQuery();

                    while (rs.next()) {
            %>
                <div
                    class="card"
                    style=" padding: 15px; border: solid 1px ##057ee1; border-radius: 8px;">
                    <h3 style="color: black;">
                        <a href="packageDetails.jsp?id=<%= rs.getInt("packageid") %>">
                            <%= rs.getString("title") %>
                        </a>
                    </h3>
                    <%
                        if (rs.getString("imageurl") != null) {
                    %>
                    <img src=" <%=rs.getString("imageurl")%>" alt="image" style="max-height:150px;max-width:230px;border-radius:8px" />
                    <%
                        }
                    %>
                    <p>
                        <strong>Location:</strong> <%= rs.getString("location") %> <br>
                        <strong>Duration:</strong> <%= rs.getString("duration") %> <br>
                        <strong>Travel Date:</strong> <%= rs.getDate("traveldate") %> <br>
                        <strong>Seats Left:</strong> <%= rs.getInt("seats") %> <br>
                        <strong>Available Till:</strong> <%= rs.getDate("availabletill") %> <br>
                        <strong>Price:</strong> RS <%= rs.getDouble("price") %>
                    </p>
                    <p>
                        <%= rs.getString("description") != null
                                ? rs.getString("description").substring(0,
                                  Math.min(120, rs.getString("description").length())) + "..."
                                : "" %>
                    </p>
                    <a class="btn" href="packageDetails.jsp?id=<%= rs.getInt("packageid") %>">View</a>
                </div>
            <%
                    }
                } catch (Exception e) {
            %>
                <div class="error">Error loading packages: <%= e.getMessage() %></div>
            <%
                } finally {
                    try {
                        if (rs != null) rs.close();
                    } catch (Exception ig) {
                        logIgnoredException("index.jsp: closing ResultSet", ig);
                    }
                    try {
                        if (ps != null) ps.close();
                    } catch (Exception ig) {
                        logIgnoredException("index.jsp: closing PreparedStatement", ig);
                    }
                    try {
                        if (conn != null) conn.close();
                    } catch (Exception ig) {
                        logIgnoredException("index.jsp: closing Connection", ig);
                    }
                }
            %>
        </div>
    </div>

    <footer>
        BookSafar &copy; 2025
    </footer>
</body>
</html>