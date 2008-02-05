<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>Graduate Programs in the Life Sciences</title>
	<link rel="stylesheet" href="style/screen.css" type="text/css" />
</head>

<body>
	<div id="skipnav">
		<a href="#content">Skip to main content</a>
	</div>
	<hr />
	<div id="wrap">
		<!-- The following div contains the Cornell University logo with unit signature -->
		<div id="cu-identity"> 
			<div id="cu-logo">
				<a href="http://www.cornell.edu/" title="Cornell University"><img src="images/cu_logo_unstyled.gif" alt="Cornell University" width="180" height="45" /></a>
			</div><!-- cu-logo -->
			<div id="cu-search">
				<a href="http://www.cornell.edu/search/" title="Search Cornell University">Search Cornell</a>
			</div><!-- cu-search -->
		</div> <!-- cu-identity -->
		
		<hr />
		
		<div id="header">
			<a class="image" href="/vivo/grad" title="Home"><img id="title" src="images/gradprogram_title.gif" alt="Graduate Program in the Life Sciences" /></a>
			
			<div id="navigation">
				<ul>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'index.jsp')}">class="currentTab" </c:if>href="/vivo/grad" title="Home">Home</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'fields.jsp')}">class="currentTab" </c:if>href="fields.jsp" title="Graduate Fields">Graduate Fields</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'faculty.jsp')}">class="currentTab" </c:if>href="faculty.jsp" title="Faculty">Faculty</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'facilities.jsp')}">class="currentTab" </c:if>href="facilities.jsp" title="Research Facilities">Research Facilities</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'departments.jsp')}">class="currentTab" </c:if>href="departments.jsp" title="Departments">Departments</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'events.jsp')}">class="currentTab" </c:if>href="events.jsp" title="Events">Events</a></li>
					<li><a <c:if test="${fn:contains(pageContext.request.servletPath, 'search.jsp')}">class="currentTab" </c:if>href="search.jsp" title="Search">Search</a></li>
				</ul>
			</div><!-- navigation -->
		</div><!-- header -->