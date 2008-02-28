<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="java.util.HashMap" %>
<%
    /* this is just a hard code fisrt attempt, we could get the info out of the model */

    /* *************************************
    Parameters:
        subjectUri
        predicateUri
        default (true|false)
      ************************************** */
    
    final String DEFAULT_OBJ_FORM =  "defaultObjPropForm.jsp";
    final String DEFAULT_DATA_FORM = "defaultDataProp.jsp";
    final String DEFAULT_EDIT_THEME_DIR = "themes/default";

    HashMap<String,String> propUriToForm = null;
    propUriToForm = new HashMap<String,String>();
    propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#PersonTeacherOfSemesterCourse", "personTeacherOfSemesterCourse.jsp");
    propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#authorOf", "personAuthorOf.jsp");
    
    /* ********************************************************** */

    if( EditConfiguration.getEditKey( request ) == null ){
        request.setAttribute("editKey",EditConfiguration.newEditKey(session));
    }else{
        request.setAttribute("editKey", EditConfiguration.getEditKey( request ));
    }

     /* Figure out what type of edit is being requested,
        setup for that type of edit OR forward to some 
        thing that can do the setup  */

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    String defaultParam = request.getParameter("defaultForm");
    String command      = request.getParameter("cmd");

    if( subjectUri == null || subjectUri.trim().length() == 0 )
        throw new Error("subjectUri was empty, it is required by editRequestDispatch");
    if( predicateUri == null || predicateUri.trim().length() == 0)
        throw new Error("predicateUri was empty, it is required by editRequestDispatch");

//    if( "true".equalsIgnoreCase( request.getParameter("clearEditConfig"))){
//        EditConfiguration.clearAllConfigsInSession(session);
//        EditSubmission.clearAllEditSubmissionsInSession(session);
//        session.removeAttribute("editjson");
//    }

    String url= "/edit/editRequestDispatch.jsp"; //I'd like to get this from the request but...
    request.setAttribute("formUrl", url + "?" + request.getQueryString());
    System.out.println("query url from editRequestDispatch: " + url);

    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    request.setAttribute("themeDir", "themes/editdefault/");
    request.setAttribute("preForm", "/edit/formPrefix.jsp");
    request.setAttribute("postForm", "/edit/formSuffix.jsp");

    if( "delete".equals(command) ){ %>
      <jsp:forward page="/edit/forms/propDelete.jsp"/>
    <%
        return;
    }

    String form = null;
    if( propUriToForm.containsKey( predicateUri )){
        form = propUriToForm.get( predicateUri );
        request.setAttribute("hasCustomForm","true");
    }
    if( form == null || "true".equalsIgnoreCase(defaultParam) ){        			
       	ObjectProperty prop = wdf.getObjectPropertyDao().getObjectPropertyByURI( predicateUri );
       	if( prop != null )
           	form = DEFAULT_OBJ_FORM;
       	else
           	form = DEFAULT_DATA_FORM;  
    }
    request.setAttribute("form" ,form);
    
    if( session.getAttribute("requestedFromEntity") == null )
    	session.setAttribute("requestedFromEntity", subjectUri );
%>
<jsp:forward page="/edit/forms/${form}"  />