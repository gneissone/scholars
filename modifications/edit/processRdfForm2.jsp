<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ModelFactory" %>
<%@ page import="com.hp.hpl.jena.rdf.model.Resource" %>
<%@ page import="com.hp.hpl.jena.rdf.model.ResourceFactory" %>
<%@ page import="com.hp.hpl.jena.shared.Lock" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vedit.beans.LoginFormBean" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.Field" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.filters.VitroRequestPrep" %>
<%@ page import="java.io.StringReader" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>

<%-- 2nd prototype of processing.

This one takes two lists of n3, on required and one optional.  If
all of the variables in the required n3 are not bound or it cannot
be processed as n3 by Jena then it is an error in processing the form.
The optional n3 blocks will proccessed if their variables are bound and
are well formed.
--%>
<%
    System.out.println("************** in processRdfForm2.jsp ****************");
    if( session == null)
        throw new Error("need to have session");
%>
<%
    if (!VitroRequestPrep.isSelfEditing(request) && !LoginFormBean.loggedIn(request, LoginFormBean.CURATOR)) {
        %><c:redirect url="/about.jsp"></c:redirect>      <%
    }

    List<String>  errorMessages = new ArrayList<String>();
    Model jenaOntModel =  (Model)application.getAttribute("jenaOntModel");
    Model persistentOntModel = (Model)application.getAttribute("persistentOntModel");

    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    EditSubmission submission = new EditSubmission(request,jenaOntModel,editConfig);

    dump("EditConfiguration" , editConfig);

    Map<String,String> errors =  submission.getValidationErrors();
    EditSubmission.putEditSubmissionInSession(session,submission);

    if(  errors != null && ! errors.isEmpty() ){
        System.out.println("seems to be a validation error");
        String form = editConfig.getFormUrl();
        request.setAttribute("formUrl", form);
        %><jsp:forward page="${formUrl}"/><%
      	return;
    }

    List<String> n3Required = editConfig.getN3Required();
    List<String> n3Optional = editConfig.getN3Optional();

    Map<String,List<String>> fieldAssertions = null;
    if( editConfig.getObjectUri() != null && editConfig.getObjectUri().length() > 0){
        fieldAssertions = fieldsToAssertionMap(editConfig.getFields());
    }else{
        fieldAssertions = new HashMap<String,List<String>>();
    }

    Map<String,List<String>> fieldRetractions = null;
    if( editConfig.getObjectUri() != null && editConfig.getObjectUri().length() > 0){
        fieldRetractions = fieldsToRetractionMap(editConfig.getFields());
    }else{
        fieldRetractions = new HashMap<String,List<String>>();
    }
    
    /* ********** URIs and Literals on Form/Parameters *********** */
    //sub in resource uris off form
    n3Required = subInUris(submission.getUrisFromForm(), n3Required);
    n3Optional = subInUris(submission.getUrisFromForm(), n3Optional);

    //sub in literals from form
    n3Required = subInLiterals(submission.getLiteralsFromForm(), n3Required);
    n3Optional = subInLiterals(submission.getLiteralsFromForm(), n3Optional);

    fieldAssertions = substituteIntoValues(  submission.getUrisFromForm(), submission.getLiteralsFromForm(), fieldAssertions);
    //fieldRetractions does NOT get values from form.

    /* ****************** URIs and Literals in Scope ************** */
    SparqlEvaluate sparqlEval = new SparqlEvaluate((Model)application.getAttribute("jenaOntModel"));
    editConfig.runSparqlForAdditional(sparqlEval);

    Map<String,String> urisInScope = editConfig.getUrisInScope();
    n3Required = subInUris( urisInScope, n3Required);
    n3Optional = subInUris( urisInScope, n3Optional);

    Map<String,String> literalsInScope = editConfig.getLiteralsInScope();
    n3Required = subInLiterals( literalsInScope, n3Required);
    n3Optional = subInLiterals( literalsInScope, n3Optional);

    fieldAssertions = substituteIntoValues(urisInScope, literalsInScope, fieldAssertions );
    fieldRetractions = substituteIntoValues(urisInScope, literalsInScope, fieldRetractions);

    /* ****************** New Resources ********************** */
    Map<String,String> varToNewResource = newToUriMap(editConfig.getNewResources(),jenaOntModel);

    //if we are editing an existing prop, no new resources will be substituted since the var will
    //have already been substituted in by urisInScope.
    n3Required = subInUris( varToNewResource, n3Required);
    n3Optional = subInUris( varToNewResource, n3Optional);
    fieldAssertions = substituteIntoValues(varToNewResource, null, fieldAssertions);
    //fieldRetractions does NOT get values from form.

    dump("n3Required" , n3Required);
    dump("n3Optional" , n3Optional);
    dump("fieldAssertions" , fieldAssertions);
    dump("fieldRetractions" , fieldRetractions);

    /* ***************** Build Models ******************* */
    /* bdc34: we should dcheck if this is an edit of an existing
    or a new individual.  If this is a edit of an existing then
    we don't need to do the n3required or the n3optional; only the
    the assertions and retractions from the fields are needed.
     */
    List<Model> requiredAssertions  = null;
    List<Model> requiredRetractions = null;
    List<Model> optionalAssertions  = null;

    if( editConfig.getObjectUri() != null && editConfig.getObjectUri().trim().length() > 0 ){
        System.out.println(" doing an update of an existing '" +  editConfig.getObjectUri() + "'");
        //editing an existing statement
        List<Model> requiredFieldAssertions  = new ArrayList<Model>();
        List<Model> requiredFieldRetractions = new ArrayList<Model>();
        for(String fieldName: fieldAssertions.keySet()){
            Field field = editConfig.getFields().get(fieldName);
            /* CHECK that field changed, then add assertions and retractions */
            if( hasFieldChanged(fieldName, editConfig, submission) ){
                System.out.println( "field " + fieldName + " has changed " );

                /* if the field was a checkbox then we need to something special */
                
                List<String> assertions = fieldAssertions.get(fieldName);
                List<String> retractions = fieldRetractions.get(fieldName);
                for( String n3 : assertions){
                    try{
                        Model model = ModelFactory.createDefaultModel();
                        StringReader reader = new StringReader(n3);
                        model.read(reader, "", "N3");
                        requiredFieldAssertions.add(model);
                    }catch(Throwable t){
                        errorMessages.add("error processing N3 assertion string from field " + fieldName + "\n"+
                                t.getMessage() + '\n' +
                                "n3: \n" + n3 );
                    }
                    System.out.println("processRdfform2.jsp change field assertions" + n3);
                }
                for( String n3 : retractions ){
                    try{
                        Model model = ModelFactory.createDefaultModel();
                        StringReader reader = new StringReader(n3);
                        model.read(reader, "", "N3");
                        requiredFieldRetractions.add(model);
                    }catch(Throwable t){
                        errorMessages.add("error processing N3 retraction string from field " + fieldName + "\n"+
                                t.getMessage() + '\n' +
                                "n3: \n" + n3 );
                    }
                    System.out.println("processRdfform2.jsp change field retractions" + n3);
                }
            }
        }
        requiredAssertions = requiredFieldAssertions;
        requiredRetractions = requiredFieldRetractions;
        optionalAssertions = Collections.EMPTY_LIST;

    } else {
        System.out.println("making a new individual");

        //editing a new statement

        //deal with required N3
        List<Model> requiredNewModels = new ArrayList<Model>();
         for(String n3 : n3Required){
             try{
                 Model model = ModelFactory.createDefaultModel();
                 StringReader reader = new StringReader(n3);
                 model.read(reader, "", "N3");
                 requiredNewModels.add( model );
             }catch(Throwable t){
                 errorMessages.add("error processing required n3 string \n"+
                         t.getMessage() + '\n' +
                         "n3: \n" + n3 );
             }
         }
        if( !errorMessages.isEmpty() ){
            System.out.println("problems processing required n3: \n" );
            for( String error : errorMessages){
                System.out.println(error);
            }
            throw new JspException("errors processing required N3, check logs for details");
        }
        requiredAssertions = requiredNewModels;
        requiredRetractions = Collections.EMPTY_LIST;

        //deal with optional N3
        List<Model> optionalNewModels = new ArrayList<Model>();
        for(String n3 : n3Optional){
            try{
                Model model = ModelFactory.createDefaultModel();
                StringReader reader = new StringReader(n3);
                model.read(reader, "", "N3");
                optionalNewModels.add(model);
            }catch(Throwable t){
                errorMessages.add("error processing optional n3 string  \n"+
                        t.getMessage() + '\n' +
                        "n3: \n" + n3);
            }
        }
        if( !errorMessages.isEmpty() ){
            System.out.println("problems processing optional n3: \n" );
            for( String error : errorMessages){
                System.out.println(error);
            }
        }
        optionalAssertions = optionalNewModels;
    }

    //The requiredNewModels and the optionalNewModels could be handled differently
    //but for now we'll just do them the same
    requiredAssertions.addAll(optionalAssertions);

    System.out.println("here are " + requiredAssertions.size() + " models in required");
    System.out.println("here are " + optionalAssertions.size() + " models in optional");
    System.out.println("here are " + requiredRetractions.size() + " models in retractions");
    
    Lock lock = null;
    try{
        lock =  persistentOntModel.getLock();
        lock.enterCriticalSection(Lock.WRITE);
        for( Model model : requiredAssertions ) {
            persistentOntModel.add(model);
        }
        for(Model model : requiredRetractions ){
            persistentOntModel.remove( model );
        }
    }catch(Throwable t){
        errorMessages.add("error adding edit change n3required model to persistent model \n"+ t.getMessage() );
    }finally{
        lock.leaveCriticalSection();
    }

    try{
        lock =  jenaOntModel.getLock();
        lock.enterCriticalSection(Lock.WRITE);
        for( Model model : requiredAssertions) {
            jenaOntModel.add(model);
        }
        for(Model model : requiredRetractions ){
            jenaOntModel.remove( model );
        }
    }catch(Throwable t){
        errorMessages.add("error adding edit change n3required model to in memory model \n"+ t.getMessage() );
    }finally{
        lock.leaveCriticalSection();
    }
%>

<jsp:forward page="postEditCleanUp.jsp"/>

<%!

    /* ********************************************************* */
    /* ******************** utility functions ****************** */
    /* ********************************************************* */

    public Map<String,List<String>> fieldsToAssertionMap( Map<String,Field> fields){
        Map<String,List<String>> out = new HashMap<String,List<String>>();
        for( String fieldName : fields.keySet()){
            Field field = fields.get(fieldName);

            List<String> copyOfN3 = new ArrayList<String>();
            for( String str : field.getAssertions()){
                copyOfN3.add(str);
            }
            out.put( fieldName, copyOfN3 );
        }
        return out;
    }

     public Map<String,List<String>> fieldsToRetractionMap( Map<String,Field> fields){
        Map<String,List<String>> out = new HashMap<String,List<String>>();
        for( String fieldName : fields.keySet()){
            Field field = fields.get(fieldName);

            List<String> copyOfN3 = new ArrayList<String>();
            for( String str : field.getRetractions()){
                copyOfN3.add(str);
            }
            out.put( fieldName, copyOfN3 );
        }
        return out;
    }

    public Map<String,List<String>> substituteIntoValues(Map<String,String> varsToUris,
                                                      Map<String,String> varsToLiterals,
                                                      Map<String,List<String>> namesToN3 ){

        Map<String,List<String>> outHash = new HashMap<String,List<String>>();

        for(String fieldName : namesToN3.keySet()){
            List<String> n3strings = namesToN3.get(fieldName);
            List<String> newList  = new ArrayList<String>();
            if( varsToUris != null)
                newList = subInUris(varsToUris, n3strings);
            if( varsToLiterals != null)
                newList = subInLiterals(varsToLiterals, newList);
            outHash.put(fieldName, newList);
        }
        return outHash;
    }

    public List<String> subInUris(Map<String,String> varsToVals, List<String> targets){
        if( varsToVals == null || varsToVals.isEmpty() ) return targets;
        ArrayList<String> outv = new ArrayList<String>();
        for( String target : targets){
            String temp = target;
            for( String key : varsToVals.keySet()) {
                temp = subInUris( key, varsToVals.get(key), temp)  ;
            }
            outv.add(temp);
        }
        return outv;
    }


    public String subInUris(String var, String value, String target){
        if( var == null || var.length() == 0 || value==null )
            return target;
        String varRegex = "\\?" + var;
        String out = target.replaceAll(varRegex,"<"+value+">");
        if( out != null && out.length() > 0 )
            return out;
        else
            return target;
    }

    public List<String>subInUris(String var, String value, List<String> targets){
        ArrayList<String> outv =new ArrayList<String>();
        for( String target : targets){
            outv.add( subInUris( var,value, target) ) ;
        }
        return outv;
    }

    public List<String> subInLiterals(Map<String,String> varsToVals, List<String> targets){
        if( varsToVals == null || varsToVals.isEmpty()) return targets;

        ArrayList<String> outv =new ArrayList<String>();
        for( String target : targets){
            String temp = target;
            for( String key : varsToVals.keySet()) {
                temp = subInLiterals( key, varsToVals.get(key), temp);
            }
            outv.add(temp);
        }
        return outv;
    }

    public List<String>subInLiterals(String var, String value, List<String> targets){
        ArrayList<String> outv =new ArrayList<String>();
        for( String target : targets){
            outv.add( subInLiterals( var,value, target) ) ;
        }
        return outv;
    }

    public String subInLiterals(String var, String value, String target){
        String varRegex = "\\?" + var;
        String out = target.replaceAll(varRegex,'"'+value+'"');  //*** THIS  NEEDS TO BE ESCAPED!
        if( out != null && out.length() > 0 )
            return out    ;
        else
            return target;
    }

    public Map<String,String> newToUriMap(Map<String,String> newResources, Model model){
        HashMap<String,String> newUris = new HashMap<String,String>();
        for( String key : newResources.keySet()){
            newUris.put(key,makeNewUri(newResources.get(key), model));
        }
         return newUris;
    }

    public String makeNewUri(String prefix, Model model){
        if( prefix == null || prefix.length() == 0 )
            prefix = defaultUriPrefix;
        
        String uri = prefix + random.nextInt();
        Resource r = ResourceFactory.createResource(uri);
        while( model.containsResource(r) ){
            uri = prefix + random.nextInt();
            r = ResourceFactory.createResource(uri);
        }
        return uri;
    }

    static Random random = new Random();
    static String defaultUriPrefix = "http://vivo.library.cornell.edu/ns/0.1#individual";

//    public String getNewUri(){
//        return "http://vivo.cornell.edu/ns/need/way/to/make/new/uri/bunk#" + random.nextInt();
//    }

%>


<%!
    private boolean hasFieldChanged(String fieldName, EditConfiguration editConfig, EditSubmission submission) {
        String orgValue = editConfig.getUrisInScope().get(fieldName);
        String newValue = submission.getUrisFromForm().get(fieldName);
        if( orgValue != null && newValue != null){
            if( orgValue.equals(newValue))
              return false;
            else
              return true;
        }
        
        orgValue = editConfig.getLiteralsInScope().get(fieldName);
        newValue = submission.getLiteralsFromForm().get(fieldName);
        if( orgValue != null && newValue != null ){
            if( orgValue.equals(newValue))
                return false;
            else
                return true;
        }
        
        System.out.println("***************************8 odd condition in hasFieldchanged() ********************");
        dump("editConfig" ,editConfig);
        dump("submission", submission);
        throw new Error("in hasFieldChanged() for field " + fieldName + ", both old and new values are null, this should not happen");
    }

    private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }
%>