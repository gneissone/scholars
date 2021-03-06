/*******************************************************************************
 * 
 * Define the structures that embed the visualization into HTML
 *   simple for one department, no controls.
 *   full (multiple views and export buttons), for one department, no controls.
 *   full (multiple views and export buttons), for the site, with controls.
 * 
 * Also, define the functions that another site might want to override.
 *
 ******************************************************************************/

ScholarsVis["GrantsBubbleChart"] = {
        transform: transformGrantsData,
        display: displayGrantsWithoutControls,
        closer: closeGrantsVis,
        
        DepartmentVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/grants_bubble_chart",
                    transform : transformGrantsData,
                    display : displayGrantsWithoutControls,
                    closer : closeGrantsVis
            };
            return new ScholarsVis.Visualization(options, defaults);
        },

        FullDepartmentVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/grants_bubble_chart",
                    transform : transformGrantsData,
                    views : {
                        vis : {
                            display : displayGrantsWithoutControls,
                            closer : closeGrantsVis,
                            export : {
                                json : {
                                    filename: "departmentGrants.json",
                                    call: exportDepartmentGrantsVisAsJson
                                },
                                svg : {
                                    filename: "departmentGrants.svg",
                                    call: exportDepartmentGrantsVisAsSvg
                                }
                            }
                        },
                        table: {
                            display : drawDepartmentGrantsTable,
                            closer : closeDepartmentGrantsTable,
                            export : {
                                csv : {
                                    filename: "departmentGrantsTable.csv",
                                    call: exportDepartmentGrantsTableAsCsv,
                                },
                                json : {
                                    filename: "departmentGrantsCloudTable.json",
                                    call: exportDepartmentGrantsTableAsJson
                                }
                            }
                        }
                    }
            };
            return new ScholarsVis.Visualization(options, defaults);
        },
        
        FullSiteVisualization: function(options) {
            var defaults = {
                    url : ScholarsVis.Utilities.baseUrl + "api/dataRequest/grants_bubble_chart",
                    transform : transformGrantsData,
                    views : {
                        vis : {
                            display : displayGrantsWithControls,
                            closer : closeGrantsVis,
                            export : {
                                json : {
                                    filename: "siteGrants.json",
                                    call: exportSiteGrantsVisAsJson
                                },
                                svg : {
                                    filename: "siteGrants.svg",
                                    call: exportSiteGrantsVisAsSvg
                                }
                            }
                        },
                        table: {
                            display : drawSiteGrantsTable,
                            closer : closeSiteGrantsTable,
                            export : {
                                csv : {
                                    filename: "siteGrantsTable.csv",
                                    call: exportSiteGrantsTableAsCsv,
                                },
                                json : {
                                    filename: "siteGrantsCloudTable.json",
                                    call: exportSiteGrantsTableAsJson
                                }
                            }
                        }
                    }
            };
            return new ScholarsVis.Visualization(options, defaults);
        }
}

/*****************************************************************************/

var grantsController;

function displayGrantsWithControls(json, target, options){
    var mainDiv = options.mainDiv || target;
    var display = new GrantsDisplay(mainDiv, options.legendDiv);
    if (!grantsController) {
        grantsController = new GrantsController(json, display, options);
    }
    display.draw(json);
} 

function displayGrantsWithoutControls(json, target, options){
    var mainDiv = options.mainDiv || target;
    var display = new GrantsDisplay(mainDiv, options.legendDiv);
    display.draw(json);
} 

function GrantsController(grants, display, options) {
    var personFilter = new AccordionControls.Selector(options.personFilter, personChanged);
    personFilter.loadData(getPersonData());
    
    var unitFilter = new AccordionControls.Selector(options.unitFilter, unitChanged);
    unitFilter.loadData(getUnitData());
    
    var agencyFilter = new AccordionControls.Selector(options.agencyFilter, agencyChanged);
    agencyFilter.loadData(getAgencyData());
    
    var dateRange = new AccordionControls.RangeSlider(options.dateRangePanel, yearChanged);
    dateRange.setRange(getYearsRange());
    
    $(options.resetLink).click(resetFilters);
    
    resetFilters();
	grantCount = grants.length.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
    setToolbarText(grantCount + " grants");
    display.draw(grants);

    function getPersonData() {
        return grants.reduce(addPeople, []).sort(ignoreCaseSort).filter(uniqueUris);
        
        function addPeople(people, grant) {
            return people.concat(grant.people.map(personNode));
            
            function personNode(p) {
                return {
                    label: p.name, 
                    uri: p.uri
                };
            }
            
        }
    }
    
    function getUnitData() {
        return grants.map(unitNode).sort(ignoreCaseSort).filter(uniqueUris);
        
        function unitNode(grant) {
            return {
                label: grant.dept.name, 
                uri: grant.dept.uri
            };
        }
    }
    
    function getAgencyData() {
        return grants.map(agencyNode).sort(ignoreCaseSort).filter(uniqueUris);
        
        function agencyNode(grant) {
            return {
                label: grant.funagen.name, 
                uri: grant.funagen.uri
            };
        }
    }
    
    function ignoreCaseSort(a, b) {
        var al = a.label.toUpperCase();
        var bl = b.label.toUpperCase();
        return (al < bl) ? -1 : 
            (al > bl) ? 1 : 
                (a.uri < b.uri) ? -1 : 
                    (a.uri > b.uri) ? 1 : 
                        0;
    }
    
    function uniqueUris(element, index, array) {
        return index == 0 || element.uri != array[index - 1].uri;
    }
    
    function getYearsRange() {
        var minYear = d3.min(grants, g=>Number(g.Start));
        var maxYear = d3.max(grants, g=>Number(g.End));
        return [minYear, maxYear];
    }
    
    function personChanged(selectedPerson) {
        unitFilter.clearSelection();
        agencyFilter.clearSelection();
        dateRange.reset();

        var filtered = grants.filter(peopleFilter);
        setToolbarText(pluralize(filtered.length, "grant") + " involving " + selectedPerson.label);
        display.draw(filtered);
        
        function peopleFilter(g) {
            return g.people.some(p => selectedPerson.uri == p.uri);
        }
    }
    
    function unitChanged(selectedUnit) {
        personFilter.clearSelection();
        agencyFilter.clearSelection();
        dateRange.reset();
        
        var filtered = grants.filter(g => g.dept.uri == selectedUnit.uri)
        setToolbarText(pluralize(filtered.length, "grant") + " involving " + selectedUnit.label);
        display.draw(filtered);
    }
    
    function agencyChanged(selectedAgency) {
        personFilter.clearSelection();
        unitFilter.clearSelection();
        dateRange.reset();
        
        var filtered = grants.filter(g => g.funagen.uri == selectedAgency.uri);
        setToolbarText(pluralize(filtered.length, "grant") + " from " + selectedAgency.label);
        display.draw(filtered);
    }
    
    function yearChanged() {
        personFilter.clearSelection();
        unitFilter.clearSelection();
        agencyFilter.clearSelection();

        var currentDates = dateRange.getCurrentValues();
        var filtered = grants.filter(yearFilter);
        setToolbarText(pluralize(filtered.length, "grant") + " from " + currentDates[0] + " to " + currentDates[1]);
        display.draw(filtered);
        
        function yearFilter(g) {
            return Number(g.Start) <= currentDates[1] && Number(g.End) >= currentDates[0] ;
        }
    }
    
    function pluralize(count, text) {
        if (count == 1) {
            return count + " " + text;
        } else {
			formattedCount = count.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
            return formattedCount + " " + text + "s"
        }
    }
    
    function resetFilters() {
        personFilter.collapse();
        personFilter.clearSelection();
        unitFilter.collapse();
        unitFilter.clearSelection();
        agencyFilter.collapse();
        agencyFilter.clearSelection();
        dateRange.collapse();
        dateRange.reset();

		grantCount = grants.length.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
        setToolbarText(grantCount + " grants");
        display.draw(grants);
    }
    
    function setToolbarText(text) {
        $("[data-view-id='vis'] #title_bar .heading").html(text);
    }
}

/**
 * @param target
 *                may be a selector or a JQuery selection. Get the element
 *                either way, so we know what we are working with.
 * @param legend
 *                similar
 */
function GrantsDisplay(target, legend) {
    var targetElem = $(target).get(0);
    var legendElem = $(legend).get(0);

    var height = Math.floor($(targetElem).height());
    var width = Math.floor($(targetElem).width());

    var fillColor = d3.scale.ordinal()
        .domain(['unknown','low', 'medium', 'high'])
        .range(["#41B3A7","#81F7F3", "#819FF7", "#BE81F7"]);

    var force = d3.layout.force()
        .size([width, height])
        .charge(charge)
        .gravity(-0.01)
        .friction(0.9);

    //Used when setting up force and moving around nodes
    var damper = 0.102;

    //tooltip for mouseover functionality
    var tooltip = GrantsTooltip("grants_tooltip", 400);
    
    function charge(d) {
        return -Math.pow(d.radius, 2.0) / 8;
    }

    return {
        clear: clear,
        draw: draw
    }
    
    function clear() {
        d3.select(targetElem).select("svg").remove();
    }
    
    function draw(rawData) {
        clear();
        tooltip.hideTooltip();

        drawLegend();

        var nodes = createGrantNodes(rawData);
        force.nodes(nodes);
        
        var svg = d3.select(targetElem)
            .append('svg')
            .attr('width', width)
            .attr('height', height);
        
        // Bind nodes data to what will become DOM elements to represent them.
        var bubbles = svg.selectAll('.bubble').data(nodes, d => d.id );

        // Create new circle elements each with class `bubble`.
        // There will be one circle.bubble for each object in the nodes array.
        // Initially, their radius (r attribute) will be 0.
        bubbles
            .enter()
            .append('circle')
            .classed('bubble', true)
            .attr('r', 0)
            .attr('fill', d => fillColor(d.group))
            .attr('stroke', d => d3.rgb(fillColor(d.group)).darker())
            .attr('stroke-width', 2)
            .on('mouseover', hoverOverBubble)
            .on('mouseout', leaveBubble)
            .on('click', clickOnBubble);

        // Fancy transition to make bubbles appear, ending with the correct radius
        bubbles.transition()
            .duration(500)
            .attr('r', d => d.radius);

        groupBubbles();

        function drawLegend() {
            var legendHeight = Math.floor($(legendElem).height());
            var legendWidth = Math.floor($(legendElem).width());

            d3.select(legendElem).selectAll("svg").remove();
            var legend = d3.select(legendElem)
                .append("svg")
                .attr("width", legendWidth)
                .attr("height", legendHeight);
            legend
                .append('text')
                .attr('x',5)
                .attr('y', 12)
                .style("font-weight", "bold")
                .style("margin-bottom","20px")
                .text("Color Scheme");
            fillColor
                .range()
                .forEach(drawLegendBar);
            
            function drawLegendBar(color, i) {
                var domainValues = ["Unknown", "< $100,000", "$100,000 - $1,000,000", "> $1,000,000"];
                legend
                    .append('rect')
                    .attr("width", 20)
                    .attr("height", 20)
                    .attr("x", 5)
                    .attr("y", 25 + i*25)
                    .style("fill", color);
                legend
                    .append('text')
                    .attr("x", 42)
                    .attr("y", 20 + 20 + i*25)
                    .attr("text-anchor", "start")
                    .style("font-size", 16)
                    .text(domainValues[i]);
            }
        }
        
        function createGrantNodes(data) {
            var radiusScaler = createRadiusScaler();
            return data.map(nodeBuilder).sort(nodeSorter);

            function createRadiusScaler() {
                //Sizes bubbles based on their area instead of raw radius
                return d3.scale.pow()
                    .exponent(0.5)
                    .range([2, 15])
                    .domain([0, d3.max(data, d => +d.Cost)]); 
            }
            
            function nodeBuilder(d) {
                return {
                    id: d.id,
                    radius: radiusScaler(+d.Cost),
                    dept: d.dept,
                    value: d.Cost,
                    start: d.Start,
                    grant: d.grant,
                    end: d.End,
                    people: d.people,
                    name: d.grant.title,
                    group: d.group,
                    x: Math.random() * 900,
                    y: Math.random() * 800,
                    funagen : d.funagen
                };
            }
            
            // sort them to prevent occlusion of smaller nodes.
            function nodeSorter(a, b) { 
                return b.value - a.value; 
            }
            
        } 
        
        function groupBubbles() {
            force.on('tick', function (e) {
                bubbles.each(moveToCenter(e.alpha))
                    .attr('cx', d => d.x)
                    .attr('cy', d => d.y);
            });
            force.start();
            
            function moveToCenter(alpha) {
                return function (d) {
                    d.x = d.x + (width / 2 - d.x) * damper * alpha;
                    d.y = d.y + (height / 2 - d.y) * damper * alpha;
                };
            }
        }
        
        function hoverOverBubble(data) {
            addHighlight(this);
            tooltip.showName(data)
        }
        
        function clickOnBubble(data) {
            tooltip.showDetails(data);
        }
        
        function leaveBubble(data) {
            removeHighlight(this, data);
            tooltip.hideName();
        }
        
        function addHighlight(bubble) {
            d3.select(bubble).attr('stroke', 'black');
        }
        
        function removeHighlight(bubble, data) {
            if (data && ('group' in data)) {
                d3.select(bubble).attr('stroke', d3.rgb(fillColor(data.group)).darker());
            }
        }
    }
}

/*******************************************************************************
 * 
 * Export the Site visualization data.
 * 
 ******************************************************************************/
function exportSiteGrantsVisAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, filterCost());
    
    function filterCost() {
        return data.map(cutCosts);
        
        function cutCosts(item) {
            var itemCopy = jQuery.extend(true, {}, item);
            delete itemCopy.Cost;
            return itemCopy;
        }
    }
}

function exportSiteGrantsVisAsSvg(data, filename, options) {
    ScholarsVis.Utilities.exportAsSvg(filename, $(options.target).find("svg")[0]);
}

/*******************************************************************************
 * 
 * Fill the Site Grants table with data, draw it, export it.
 * 
 ******************************************************************************/
function drawSiteGrantsTable(data, target, options) {
    var tableElement = $(target).find(".vis_table").get(0);
    var table = new ScholarsVis.VisTable(tableElement);
    var tableData = transformAgainForSiteGrantsTable(data);
    tableData.forEach(addRowToTable);
    table.complete();
    
    function addRowToTable(rowData) {
        table.addRow(rowData.grantType, 
                createLink(rowData.grantTitle, rowData.grantUri),
                createLink(rowData.deptName + " (" + rowData.deptCode + ")", rowData.deptUri),
                createLink(rowData.fundingAgencyName, rowData.fundingAgencyUri),
                rowData.people, rowData.startYear, rowData.endYear);
        
        function createLink(text, uri) {
            return "<a href='" + uri + "'>" + text + "</a>"
        }
    }
}

function closeSiteGrantsTable(target) {
    $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
}

function exportSiteGrantsTableAsCsv(data, filename) {
    ScholarsVis.Utilities.exportAsCsv(filename, transformAgainForSiteGrantsTable(data));
}

function exportSiteGrantsTableAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, transformAgainForSiteGrantsTable(data));
}

function transformAgainForSiteGrantsTable(data) {
    var tableData = [];
    data.forEach(doGrant);
    return tableData;
    
    function doGrant(gd) {
        var row = {
            grantType: gd.grant.type,
            grantTitle: gd.grant.title,
            grantUri: gd.grant.uri,
            deptCode: gd.dept.code,
            deptName: gd.dept.name,
            deptUri: gd.dept.uri,
            fundingAgencyName: gd.funagen.name,
            fundingAgencyUri: gd.funagen.uri,
            people: formatPeopleForTable(gd.people),
            startYear: gd.Start,
            endYear: gd.End
        };
        tableData.push(row);
    }
}

/*******************************************************************************
 * 
 * Export the Department visualization data.
 * 
 ******************************************************************************/
function exportDepartmentGrantsVisAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, filterCost());
    
    function filterCost() {
        return data.map(cutCosts);
        
        function cutCosts(item) {
            var itemCopy = jQuery.extend(true, {}, item);
            delete itemCopy.Cost;
            return itemCopy;
        }
    }
}

function exportDepartmentGrantsVisAsSvg(data, filename, options) {
    ScholarsVis.Utilities.exportAsSvg(filename, $(options.target).find("svg")[0]);
}

/*******************************************************************************
 * 
 * Fill the Department Grants table with data, draw it, export it.
 * 
 ******************************************************************************/
function drawDepartmentGrantsTable(data, target, options) {
    var tableElement = $(target).find(".vis_table").get(0);
    var table = new ScholarsVis.VisTable(tableElement);
    var tableData = transformAgainForSiteGrantsTable(data);
    tableData.forEach(addRowToTable);
    table.complete();
    
    function addRowToTable(rowData) {
        table.addRow(rowData.grantType, 
                createLink(rowData.grantTitle, rowData.grantUri),
                createLink(rowData.fundingAgencyName, rowData.fundingAgencyUri),
                rowData.people, rowData.startYear, rowData.endYear);
        
        function createLink(text, uri) {
            return "<a href='" + uri + "'>" + text + "</a>"
        }
    }
}

function closeDepartmentGrantsTable(target) {
    $(target).find("table").each(t => ScholarsVis.Utilities.disableVisTable(t));
}

function exportDepartmentGrantsTableAsCsv(data, filename) {
    ScholarsVis.Utilities.exportAsCsv(filename, transformAgainForDepartmentGrantsTable(data));
}

function exportDepartmentGrantsTableAsJson(data, filename) {
    ScholarsVis.Utilities.exportAsJson(filename, transformAgainForDepartmentGrantsTable(data));
}

function transformAgainForDepartmentGrantsTable(data) {
    var tableData = [];
    data.forEach(doGrant);
    return tableData;
    
    function doGrant(gd) {
        var row = {
                grantType: gd.grant.type,
                grantTitle: gd.grant.title,
                grantUri: gd.grant.uri,
                fundingAgencyName: gd.funagen.name,
                fundingAgencyUri: gd.funagen.uri,
                people: formatPeopleForTable(gd.people),
                startYear: gd.Start,
                endYear: gd.End
        };
        tableData.push(row);
    }
}

function formatPeopleForTable(people) {
    return people.sort(sorter).map(formatter).join("; ");
    
    function sorter(personA, personB) {
        // PIs before Co-PIs
        if (personA.role > personB.role) {
            return -1;
        }
        if (personA.role < personB.role) {
            return 1;
        }
        // Then alpha by name
        if (personA.name < personB.name) {
            return -1;
        }
        if (personA.name > personB.name) {
            return 1;
        }
        // Or equal
        return 0;
    }
    
    function formatter(person) {
        return person.name + (person.role == "PI" ? " (PI)" : " (Co-PI)");
    }
}
