<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.TabMenu" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Portal" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.BreadCrumbsUtil" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>

<%
    /***********************************************
    Include the theme logo and navigation, which want to live in one div element
    and may in fact overlap
     

    bdc34 2006-01-03 created
    **********************************************/
    final Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.web.header.jsp");

    Portal portal = (Portal)request.getAttribute("portalBean");
    int portalId = -1;
    if (portal==null) {
        log.error("Attribute 'portalBean' missing or null; portalId defaulted to 1");
        portalId=1;
    } else {
        portalId=portal.getPortalId();
    }

    String fixedTabStr=(fixedTabStr=request.getParameter("fixed"))==null?null:fixedTabStr.equals("")? null:fixedTabStr;    
%>


<div id="header"> <!--  generated by clones/vivo/modifications/themes/vivo/jsp/menu.jsp -->
    <!-- ************************ Theme logo ********************** generated in menu.jsp **** -->
    <%-- <c:url value="/edit/login.jsp" var="loginUrl"/> --%>
    <%-- nac26: 080422 - changed login url to handle temporary login via self editing for CAS demo --%>
    
    <a class="image login" href="<c:url value="/admin/temporaryLogin.jsp" />" title="Edit Your Profile">
       <img src="<c:url value="/themes/vivo/site_icons/login.gif"/>" alt="Edit Your Profile" /></a>
       
    <a class="image vivoLogo" href="<%= request.getContextPath() + "/index.jsp?home=" + portalId %>" title="Home">
       <img src="<c:url value="/themes/vivo/site_icons/vivo_logo.gif"/>" alt="VIVO: Virtual Life Sciences Library" /></a>
       
    <em class="portal"><%=portal.getShortHand()%></em>
    
    <!-- ************************ Navigation ********************** generated in menu.jsp **** -->
    <div id="menu">
<%      VitroRequest vreq = new VitroRequest(request);%>
        <!-- include primary menu list elements from TabMenu.java -->
        <%=TabMenu.getPrimaryTabMenu(vreq)%>
    </div> <!-- menu -->
    <div id="secondaryMenu">
    <%=BreadCrumbsUtil.getBreadCrumbsDiv(request)%>
    <!-- now render the standard Index, About, and Contact Us navigation  --> 
        <ul id="otherMenu">
<%          if ("browse".equalsIgnoreCase(fixedTabStr)) {%>
                <li class="activeTab"><a href="<c:url value="/browsecontroller"/>" title="list all contents by type">Index</a></li>
<%          } else {%>
                <li><a href="<c:url value="/browsecontroller"><c:param name="home" value="${portalBean.portalId}"/></c:url>" title="list all contents by type">Index</a></li>
<%          }
            if ("about".equalsIgnoreCase(fixedTabStr)) {%>
                <li><a class="activeTab" href="<c:url value="/about"><c:param name="home" value="${portalBean.portalId}"/><c:param name="login" value="none"/></c:url>" title="more about this web site">About</a></li>
<%          } else {%>
                <li><a href="<c:url value="/about"><c:param name="home" value="${portalBean.portalId}"/><c:param name="login" value="none"/></c:url>" title="more about this web site">About</a></li>
<%          }                                                    %>
<%          if ("comments".equalsIgnoreCase(fixedTabStr)) { %>
                <li class="activeTab"><a href="<c:url value="/comments"><c:param name="home" value="${portalBean.portalId }"/></c:url>">Contact Us</a></li>
<%          } else {%>
                <li><a href="<c:url value="/comments"><c:param name="home" value="${portalBean.portalId }"/></c:url>">Contact Us</a></li>
<%          }%>
        </ul>
    </div> <!-- secondaryMenu -->
</div> <!-- header -->
<!-- ********** END menu.jsp FROM /themes/vivo/jsp/ ************* -->
