<%@ page import="java.net.URLEncoder" %>
<%
    String qs = request.getQueryString();
    if (qs != null && !qs.isEmpty()) {
        response.sendRedirect("index.jsp?" + qs);
    } else {
        response.sendRedirect("index.jsp");
    }
    return;
%>
