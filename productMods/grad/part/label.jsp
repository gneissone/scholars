<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>

<%-- Given a URI, get a single label for that entity --%>


<sparql:sparql>
  <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" uri="<${param.uri}>">
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    SELECT ?label
    WHERE { 
          SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
            ?uri rdfs:label ?label  
         }
    }
    LIMIT 1
  </listsparql:select>
</sparql:sparql>


<c:out value="${rs[0].label.string}"/>

