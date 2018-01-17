<div class="row scholars-row">
  <div id="wc-vis-container" class="col-md-12 scholars-container">
    <div class="col-md-4 kwcloud-selector">

      <div id="legendDiv" class="center-block">
         <h2 style="padding:0;color:#5f5858;font-size:20px">
            Browse research keywords
         </h2>
      </div>
      
      <div class="panel-group" id="accordion">

        <div id="journalSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
			  <span class="start">Select:</span> 
              <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseJournal">
               Journal
             </a>
          </div>
          <div id="collapseJournal" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>
        
        <div id="proceedingsSelectionPanel" class="panel panel-default selection-list">
          <div class="panel-heading panel-title facet-panel-heading">
              <span class="start">Select:</span>
				<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseProceedings">
                 Proceedings
              </a>
          </div>
          <div id="collapseProceedings" class="panel-collapse collapse">
            <div class="panel-body" id="selector">
              <input id="searcher" type="text" class="form-control" placeholder="Search"/>
            </div>
          </div>
        </div>
      </div> 

      <div id="unit-help-text">
        <font size="2">
          <span><i>* Some publications are co-authored by scholars of multiple academic units.</i></span>
        </font>
      </div>
      <div id="person-help-text" style="display:none;">
        <font size="2">
          <span><i>Click on a keyword to view the list of publications associated with the keyword.</i></span>
        </font>
      </div>

    </div>

    <div class="col-md-8">
      <div id="selectedWordCloudLabel"></div>
      
      <#-- 
      =======================================================================
      Journal bar chart - swiped from individual--bibo-journal.ftl
      ======================================================================= 
      -->

	<div id="bar_chart_vis" class="scholars_vis_container" style="height: 600px; margin-bottom: 20px;">
	  <div id="title_bar">
	    <span class="heading">Journal/Proceedings Insights</span>
	    <span class="glyphicon glyphicon-info-sign"></span>
	    <a data-view-selector="vis" href="#" style="display: none">Show visualization</a>
	    <a data-view-selector="table" href="#" >Show table format</a>
	  </div>
	  
	  <div id="title_bar_info_text">
	    <p>
	      This visualization displays the research keywords for an entire academic unit, 
	      and is an aggregation of the keywords found in all the articles authored by all 
	      faculty and researchers of an academic unit. The size of the keyword indicates 
	      the frequency with which the keyword appears in the author's publications, 
	      indicating which subjects the author published on most (or least) frequently. 
	    </p>
	    <p>
	      To interact with the visualization, click on any keyword to see the list of 
	      authors that have this keyword associated with one of more of their articles. 
	      One can click on the author's name in the list to go to the author's page, 
	      which contains the full list of author's publications in Scholars.
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
	      <a href="#" data-export-id="json">Export as JSON</a>
	      <a href="#" data-export-id="svg">Export as SVG</a>
		</div>
        <div class="nowShowing">Now showing: <span class="selection"><span></div>
	    <font size="2">
	      <span><i>
	          Click on a bar to view the list of publications for an academic unit. 
	          Click on an academic unit name to filter the data in view.
	      </i></span>
	    </font>
	  </div>
	
	  <div data-view-id="table">
	    <div id="exports_panel">
	      <a href="#" data-export-id="json">Export as JSON</a>
	      <a href="#" data-export-id="csv"">Export as CSV</a>
	    </div>
        <div class="nowShowing">Now showing: <span class="selection"><span></div>
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
	</div>

	<!-- End of bar chart visualization -->
	
  </div>
</div>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/utils/accordion-controls.css" />',
                  '<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">',
                  '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	              '<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

${scripts.add('<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/journalbarchart/journal-bar-chart.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/embed/journal_bar_chart.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/utils/accordion-controls.js"></script>')}

<script>
$().ready(function() {
    /*
     * - Create the selectors and populate them
     * - Show a featured journal
     */
    var journalControl = new AccordionControls.Selector("#journalSelectionPanel", showBarChart);
    journalControl.loadFromDataRequest("orderedJournalList", mapPubVenueResult, sortByCount);
    
    var proceedingsControl = new AccordionControls.Selector("#proceedingsSelectionPanel", showBarChart);
    proceedingsControl.loadFromDataRequest("orderedProceedingsList", mapPubVenueResult, sortByCount);
    
    function mapPubVenueResult(d) {
        return {
            uri: d.uri.value,
            label: d.label.value,
            count: parseInt(d.count.value)
        }
    }
    
    // Descending by count, alphabetical if counts are equal.
    function sortByCount(a, b) {
        if (a.count != b.count) {
            return b.count - a.count;
        } else {
            return a.label.toLowerCase().localeCompare(b.label.toLowerCase());
        }
    }
    
    /*
     * When a Journal or Proceedings is selected, show it.
     */
    var barChart = null;
    showFeaturedJournal();
    
    function showBarChart(journal) {
        $(".nowShowing .selection").html("<a href=\"" + ScholarsVis.Utilities.toDisplayUrl(journal.uri) + "\">" + journal.label + "</a>");
        if (barChart != null) {
            barChart.hide();
        }
        barChart = new ScholarsVis.JournalBarChart.FullVisualization({
            target : '#bar_chart_vis',
            journal : journal.uri
        });
        barChart.show();
    }
    
    /*
     * Start by displaying one of our featured journals. 
     */
    function showFeaturedJournal() {
        // This array should contain uris and labels for all of the featured departments.
        var featuredJournals = [
            {
                uri: "http://scholars.cornell.edu/individual/jrnl-0000343",
                label: "Journal of Dairy Science"
            },
            {
                uri: "http://scholars.cornell.edu/individual/jrnl-0000481",
                label: "Proceedings of the National Academy of Sciences of the United States of America"
            },
            {
                uri: "http://scholars.cornell.edu/individual/jrnl-0000073",
                label: "Applied Physics Letters"
            },
            {
                uri: "http://scholars.cornell.edu/individual/jrnl-0000237",
                label: "Genetics"
            },
            {
                uri: "http://scholars.cornell.edu/individual/jrnl-0002728",
                label: "PLoS One 6"
            }
            ];
        
        showBarChart(randomArrayEntry(featuredJournals));
        
        function randomArrayEntry(array) {
            return array[getRandomInt(0, array.length - 1)];
            
            function getRandomInt(min, max) {
                return Math.floor(Math.random() * (max - min + 1)) + min;
            }
        }
    }
});
</script>