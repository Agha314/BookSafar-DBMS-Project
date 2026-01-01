<%@page import="java.sql.*" %>
<%@ include file="../config.jspf" %>
<%
Integer aid=(Integer)session.getAttribute("adminid");
if(aid==null){
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="header.jspf" %>
    <title>Bookings</title>
    <link rel="stylesheet" href="../assets/css/style.css" />
</head>
<body>
    <div class="container">
        <h2>Bookings</h2>
        <table><tr><th>ID</th><th>User</th><th>Package</th><th>Date</th><th>Status</th><th>Payment</th><th>Amount</th></tr>
        <%
        Connection c=null;
        PreparedStatement p=null;
        PreparedStatement upd=null;
        ResultSet r=null;
        try{
            c=getConnection();

            // Auto-complete: mark bookings as Completed if booked more than 2 days ago
            upd=c.prepareStatement(
                "UPDATE Booking SET status='Completed' " +
                "WHERE status='Booked' AND bookingdate < (SYSTIMESTAMP - INTERVAL '2' DAY)"
            );
            upd.executeUpdate();

            p=c.prepareStatement("SELECT b.bookingid,u.name,pk.title,b.bookingdate,b.status,p.paystatus,p.amount FROM Booking b JOIN Users u ON b.userid = u.userid JOIN Package pk ON b.packageid = pk.packageid JOIN Payment p ON p.bookingid = b.bookingid WHERE pk.createdby = ? ORDER BY pk.title,b.bookingdate DESC");
            p.setInt(1, aid);
            r=p.executeQuery();
            while(r.next()){ %>
                <tr>
                <td><%=r.getInt(1)%></td>
                <td><%=r.getString(2)%></td>
                <td><%=r.getString(3)%></td>
                <td><%=r.getTimestamp(4)%></td>
                <td><%=r.getString(5)%></td>
                <td><%=r.getString(6)%></td>
                <td>RS <%=r.getObject(7)%></td>
                </tr>
                <%}
        }catch(Exception e){ %>
        <tr><td colspan="7" class="error"><%=e.getMessage()%></td></tr><% 
        }finally{
            try{
                if(r!=null) 
                    r.close();
            }catch(Exception ig){
                logIgnoredException("admin/bookings.jsp: closing ResultSet", ig);

            }try{
                if(p!=null)
                    p.close();
            }catch(Exception ig){
                logIgnoredException("admin/bookings.jsp: closing PreparedStatement p", ig);

            }try{
                if(upd!=null)
                    upd.close();
            }catch(Exception ig){
                logIgnoredException("admin/bookings.jsp: closing PreparedStatement upd", ig);

            }try{
                if(c!=null)
                    c.close();
            }catch(Exception ig){
                logIgnoredException("admin/bookings.jsp: closing Connection", ig);

            }} %>
        </table>
        <p><a href="dashboard.jsp" class="btn secondary">Back</a></p>
    </div>
</body>
</html>