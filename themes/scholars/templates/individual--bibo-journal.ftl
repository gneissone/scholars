<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Organization individuals (extends individual.ftl in vivo)-->

<#-- Do not show the link for temporal visualization unless it's enabled -->

<#include "individual-setup.ftl">
<#import "lib-vivo-properties.ftl" as vp>

    

<#import "lib-microformats.ftl" as mf>
<#import "lib-datetime.ftl" as dt>
<#--Number of labels present-->
<#if !labelCount??>
    <#assign labelCount = 0 >
</#if>
<#--Number of available locales-->
<#if !localesCount??>
	<#assign localesCount = 1>
</#if>
<#--Number of distinct languages represented, with no language tag counting as a language, across labels-->
<#if !languageCount??>
	<#assign languageCount = 1>
</#if>	
<#-- pull properties -->
<#assign issnProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/issn")!>
<#assign eissnProp = propertyGroups.pullProperty("http://purl.org/ontology/bibo/eissn")!>
<#assign pubVenueProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#publicationVenueFor")!>
<#assign subjectAreaProp = propertyGroups.pullProperty("http://vivoweb.org/ontology/core#hasSubjectArea")!>

<#if issnProp?has_content && issnProp.statements?has_content>
	<#assign issnStmt = issnProp.statements?first!""/>
	<#assign issn >
		<div class="row profile-sub-row" role="row">
		  <div class="col-sm-2  no-padding align-text-right">
			<span class="profile-label">ISSN</span>
		  </div>
		  <div class="col-sm-7 ">
			<div class="scholars-article-metadata">
				${issnStmt.value!}
			</div>
	  	  </div>
		</div>
	</#assign>
</#if>  
<#if eissnProp?has_content && eissnProp.statements?has_content>
	<#assign eissnStmt = eissnProp.statements?first!""/>
	<#assign eissn >
		<div class="row profile-sub-row" role="row">
		  <div class="col-sm-2  no-padding align-text-right">
			<span class="profile-label">EISSN</span>
		  </div>
		  <div class="col-sm-7 ">
			<div class="scholars-article-metadata">
				${eissnStmt.value!}
			</div>
	  	  </div>
		</div>
	</#assign>
</#if>  
<#if subjectAreaProp?has_content && subjectAreaProp.statements?has_content>
	<#assign subjectAreaList>
		<div class="row profile-sub-row" role="row">
		  <div class="col-sm-4 no-padding align-text-right" >
			<span class="profile-label">Subject Area</span>
		  </div>
		  <div class="col-sm-8 ">
			<div class="scholars-article-metadata">
			<#list subjectAreaProp.statements as statement>
				<span class="hzntl-author-list">
		        	<a href="${profileUrl(statement.uri("concept"))}"">${statement.conceptLabel!}</a>
		        	<#if statement_has_next>,</span><#else></span></#if>
			</#list>
			</div>
		  </div>
		</div>
	</#assign>
</#if>
<#if pubVenueProp?has_content && pubVenueProp.statements?has_content>
	<#assign pubVenueList>
		<div class="row profile-sub-row" role="row">
			<div id="abstract-hdr" class="profile-label">Articles in Scholars@Cornell</div>
			<div class="abstract-text pubvenue-list">
				<@p.objectProperty pubVenueProp false />
			</div>
		</div>
	</#assign>
</#if>
<#-- The row1 div contains the top portion of the profile page: tile, icon controls, authors, key metadata -->
<div id="row1" class="row f1f2f3-bkg">
<div class="col-sm-12 col-md-12 col-lg-12 scholars-container" id="biboDocumentMainColumn">

<section id="individual-info" ${infoClass!} role="region">
    <#include "individual-adminPanel.ftl">

    <#if individualProductExtensionPreHeader??>
        ${individualProductExtensionPreHeader}
    </#if>
	
    <header>
<#--			<#include "individual-altmetric.ftl"> -->
            <h1 class="fn grant-profile-title" itemprop="name">
                <#-- Label -->
                <@p.label individual false labelCount localesCount languageCount/>
                <#--  Most-specific types -->
                <@p.mostSpecificTypes individual />
            </h1>
		<div class="bibo-doc-controls">
			<#include "document-iconControls.ftl" />
		</div>

		<h2 id="bibo-heading-break">  </h2>
    </header>
		<div class="row profile-row fff-bkg header-metadata" role="row">
		
				<div class="col-sm-7 col-md-7 col-lg-7 no-padding">
					${issn!}
					${eissn!}
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5 no-padding">
					${subjectAreaList!}
		
				</div>
		</div>
        </section> <!-- individual-info -->
		<div class="clear-both"></div>

	</div> <!-- biboDocumentMainColumn -->
</div> <!-- row1 -->

<div id="bibo-row-two" class="row f1f2f3-bkg">
  <#if pubVenueList?has_content>
	  <div id="visualization-column" class="col-sm-3 col-md-3 col-lg-3 scholars-container">
		<div id="bar_chart_icon_holder">
	      <a href="#" id="bar_chart_trigger">
	    	<img id="vizIcon" width="152px" src="${urls.base}/themes/scholars/images/articles-bar-chart.png"/>
	      </a>
		  <p>Articles Bar Chart</p>
	    </div>
	  </div>
	  <div id="foafPersonSpacer" class="col-sm-1 col-md-1 col-lg-1"></div>
	  <div class="col-sm-8 col-md-8 col-lg-8 no-padding">
		<div class="row f1f2f3-bkg row-no-margins">
			<div id="abstract" class="col-sm-12 col-md-12 col-lg-12 scholars-container">
				<article class="property" role="article">
		    		<ul id="individual-faculty" class="property-list" role="list" >
		    			${pubVenueList!}
					</ul>
				</article>	
			</div>
		</div>
	  </div>
  </#if>
</div> <!-- row2 div -->

<!-- =============== Bar Chart visualization ======================= -->

<div id="bar_chart_vis" class="scholars_vis_container vis_modal">
  <div id="title_bar">
    <span class="heading">Articles by Year</span>
    <span class="glyphicon glyphicon-info-sign"></span>
    <a data-view-selector="vis" href="#" style="display: none">Show visualization</a>
    <a data-view-selector="table" href="#" >Show table format</a>
  </div>
  
  <div id="title_bar_info_text">
    <p>
      This bar chart demonstrates the frequency of the publications by Cornell scholars
      in a selected journal or proceeding, over the years. 
      Click on a bar to see the list of publications by an academic unit in a specific year. 
      Click on a publication's title to go to the publication's page, which 
      contains the detailed citation data of the publication - including 
      authors list, keywords, abstract and a link to the full text.
    </p>
    <p>
      The data can be filtered by clicking on an academic unit name in the legend. 
      As some publication are co-authored by scholars from multiple academic units, 
      the height of the bar may differ from the actual publication count for a specific year.
    </p>
    <hr>
    <p>
      Note: This information is based solely on publications that have been loaded into the system.
    </p>
  </div>
  
  <div id="time-indicator">
    <img src="${urls.images}/indicator1.gif"/>
  </div>

  <div data-view-id="vis">
    <div id="exports_panel" >
      <a href="#" data-export-id="json" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Journal', 'ExportAsJSON']);">Export as JSON</a>
      <a href="#" data-export-id="svg" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Journal', 'ExportAsSVG']);">Export as SVG</a>
	</div>
    <font size="2">
      <span><i>
        Click on a bar to view the list of publications for an academic unit. 
        Click on an academic unit name to filter the data in view.
      </i></span>
    </font>
  </div>

  <div data-view-id="table">
    <div id="exports_panel">
      <a href="#" data-export-id="json" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Journal', 'ExportAsJSON']);">Export as JSON</a>
      <a href="#" data-export-id="csv" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Journal', 'ExportAsCSV']);">Export as CSV</a>
    </div>
    <table class="vis_table">
      <thead>
        <tr>
          <th data-sort="string-ins">Publication Date</th>
          <th data-sort="string-ins">Author's Academic Unit</th>
          <th data-sort="string-ins">Article</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Template cell</td>
          <td>Template cell</td>
          <td>Template cell</td>
        </tr>
      </tbody>
    </table>
  </div>
  
  <div data-view-id="empty">
    <div style="text-align: center;">
      <img src="${urls.base}/themes/scholars/images/barchart-noData.png"/>
    </div>
  </div>

</div>

<!-- =============== End of Bar Chart visualization ======================= -->


<#assign rdfUrl = individual.rdfUrl>
<#if rdfUrl??>
    <script>
        var individualRdfUrl = '${rdfUrl}';
    </script>
</#if>

<div id="profile-bottom" class="row f1f2f3-bkg"></div>

<script>
    var individualLocalName = "${individual.localName}";
</script>
<script>
var i18nStrings = {
errorProcessingTypeChange: '${i18n().error_processing_type_change}',
displayLess: '${i18n().display_less}',
displayMoreEllipsis: '${i18n().display_more_ellipsis}',
showMoreContent: '${i18n().show_more_content}',
verboseTurnOff: '${i18n().verbose_turn_off}',
standardviewTooltipOne: '${i18n().standardview_tooltip_one}',
standardviewTooltipTwo: '${i18n().standardview_tooltip_two}',
researchAreaTooltipOne: '${i18n().research_area_tooltip_one}',
researchAreaTooltipTwo: '${i18n().research_area_tooltip_two}'
};
var i18nStringsUriRdf = {
    shareProfileUri: '${i18n().share_profile_uri}',
    viewRDFProfile: '${i18n().view_profile_in_rdf}',
    closeString: '${i18n().close}'
};

</script>



${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css?vers=1.5.1" />',
				  '<link rel="stylesheet" href="${urls.base}/css/jquery_plugins/jquery.qtip.min.css" />',
				  '<link rel="stylesheet" href="${urls.base}/css/individual/individual.css?vers=1.5.1" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-3.0.3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>')}
                  
${scripts.add('<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
			  '<script type="text/javascript" src="https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"></script>',
 			  '<script type="text/javascript" src="https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"></script>',
	          '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>')}
              
${scripts.add('<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/journalbarchart/journal-bar-chart.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/embed/journal_bar_chart.js"></script>')}

<script>              
$().ready(function() {
  var barChart = new ScholarsVis.JournalBarChart.FullVisualization({
    target : '#bar_chart_vis',
    modal : true,
    journal : "${individual.uri?url}",
  });
  $('#bar_chart_trigger').click(function() {
    barChart.examineData(function(data) {
        barChart.show();
        if (data && data.units && data.units.length > 0) {
            barChart.showView("vis");
        } else {
            barChart.showView("empty");
        }
    });
  });
});
</script>        
