<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataProperty" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.DataPropertyStatement" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="java.util.HashMap" %>
<%
    // Decide which form to forward to, set subjectUri, subjectUriJson, predicateUri, predicateUriJson in request
    // Also get the Individual for the subjectUri and put it in the request scope
    // If a datapropKey is sent it as an http parameter, then set datapropKey and datapropKeyJson in request, and
    // also get the DataPropertyStatement matching the key and put it in the request scope
    /* *************************************
    Parameters:
        subjectUri
        predicateUri
        datapropKey (optional)
        cmd (optional -- deletion)
        default (true|false)
      ************************************** */
    
    final String DEFAULT_DATA_FORM = "defaultDatapropForm.jsp";
    final String DEFAULT_ERROR_FORM = "error.jsp";
    final String DEFAULT_EDIT_THEME_DIR = "themes/default";

    HashMap<String,String> propUriToForm = null;
    propUriToForm = new HashMap<String,String>();
    // may not need these -- depends on where we go with ordering data property statements in Javascript vs stub entities
    // propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#researchFocus", "personResearchFocus.jsp");
    // propUriToForm.put("http://vivo.library.cornell.edu/ns/0.1#teachingFocus", "personTeachingFocus.jsp");
    
    /* ********************************************************** */

    if( EditConfiguration.getEditKey( request ) == null ){
        request.setAttribute("editKey",EditConfiguration.newEditKey(session));
    }else{
        request.setAttribute("editKey", EditConfiguration.getEditKey( request ));
    }

    String subjectUri   = request.getParameter("subjectUri");
    String predicateUri = request.getParameter("predicateUri");
    String defaultParam = request.getParameter("defaultForm");
    String command      = request.getParameter("cmd");

    if( subjectUri == null || subjectUri.trim().length() == 0 )
        throw new Error("subjectUri was empty, it is required by editDatapropStmtRequestDispatch");
    if( predicateUri == null || predicateUri.trim().length() == 0)
        throw new Error("predicateUri was empty, it is required by editDatapropStmtRequestDispatch");

    request.setAttribute("subjectUri", subjectUri);
    request.setAttribute("subjectUriJson", MiscWebUtils.escape(subjectUri));
    request.setAttribute("predicateUri", predicateUri);
    request.setAttribute("predicateUriJson", MiscWebUtils.escape(predicateUri));
    
    String datapropKey = request.getParameter("datapropKey");
	if( datapropKey != null && datapropKey.trim().length()>0 ){
	    request.setAttribute("datapropKey",datapropKey);
	    request.setAttribute("datapropKeyJson",MiscWebUtils.escape(datapropKey));
	} // else creating a new data property

    /* since we have the URIs let's put the individual, data property, and optional data property statement in the request */
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("editDatapropStmtRequest.jsp: Could not find subject Individual in model: '" + subjectUri + "'");
    request.setAttribute("subject", subject);

    DataProperty dataproperty = wdf.getDataPropertyDao().getDataPropertyByURI( predicateUri );
    if( dataproperty == null ) throw new Error("editDatapropStmtRequest.jsp: Could not find DataProperty in model: " + predicateUri);
    request.setAttribute("predicate", dataproperty);
    
    if( datapropKey != null ) {
        int hash = 0;
        try {
            hash = Integer.parseInt(datapropKey);
        } catch (NumberFormatException ex) {
            throw new JspException("Cannot decode incoming datapropKey value "+datapropKey+" as an integer hash in editRequestDispatch.jsp");
        }
        DataPropertyStatement dps=EditConfiguration.findDataPropertyStatementViaHashcode(subject,predicateUri,hash);
        if (dps==null) throw new Error("In editRequestDispatch.jsp, no match to existing data property \""+predicateUri+"\" statement for subject \""+subjectUri+"\" via key "+datapropKey+"\n");
        request.setAttribute("dataprop", dps );
    }

    String url= "/edit/editDatapropStmtRequestDispatch.jsp"; //I'd like to get this from the request but...
    request.setAttribute("formUrl", url + "?" + request.getQueryString());
    System.out.println("query url from editDatapropStmtRequestDispatch.jsp: " + url);

    request.setAttribute("themeDir", "themes/editdefault/");
    request.setAttribute("preForm", "/edit/formPrefix.jsp");
    request.setAttribute("postForm", "/edit/formSuffix.jsp");

    if( "delete".equals(command) ){ %>
        <jsp:forward page="/edit/forms/datapropStmtDelete.jsp"/>
<%      return;
    }

    String form = null;
    if( propUriToForm.containsKey( predicateUri )){
        form = propUriToForm.get( predicateUri );
        request.setAttribute("hasCustomForm","true");
    }
    if( form == null || "true".equalsIgnoreCase(defaultParam) ){        			
       	if( dataproperty != null ) {
           	form = DEFAULT_DATA_FORM; //System.out.println("Setting up editing for datatprop "+predicateUri);
       	} else {
           	form = DEFAULT_ERROR_FORM;
           	System.out.println("Could not retrieve data property object for predicateUri "+predicateUri);
       	}
    }
    request.setAttribute("form" ,form);
    
    if( session.getAttribute("requestedFromEntity") == null )
    	session.setAttribute("requestedFromEntity", subjectUri );
%>
<jsp:forward page="/edit/forms/${form}"  />