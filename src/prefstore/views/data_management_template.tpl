<html>
<head>
	<title>
		Prefstore - Data Analysis
	</title>

	<script type="text/javascript" src="http://www.google.com/jsapi">
	</script>
	
	<script type="text/javascript" src="./static/jquery-1.6.min.js">
	</script> 

	<script type="text/javascript">
		google.load('visualization', '1', {packages: ['table']});
	</script>


	<style type='text/css'>

		.table-header {
			font-size: 13px;
			font-weight:bold;
			background-image:url("./static/titleBack.png");
		}

		.table-row {
			font-size: 11px;
		}

		.table-odd-row {
			font-size: 11px;
			background-color: #fafafa;
		}

		.table-selected {
			font-size: 11px;
			background-color: #ddddff;
		}

		.table-hover {
			font-size: 11px;
			background-color: #eeeeff;
		}
	</style>

	<script type="text/javascript">
	var termTable;
	var data;
	var selection;

	var options = {'showRowNumber': true};

	/**
	 *
	 */
	function drawVisualization() {
    	
		var dataAsJson = {
			cols:[
				{id:'A',label:'Term',type:'string'},
				{id:'B',label:'Appearances',type:'number'},
				{id:'C',label:'In Docs',type:'number'},
				{id:'D',label:'Frequency', type:'number'},
				{id:'E',label:'Web Importance', type:'number'},
				{id:'F',label:'Relevance', type:'number'},
				{id:'G',label:'Last Seen (GMT)', type:'timeofday'}],
			rows:[{{data}}]
		};

		data = new google.visualization.DataTable( dataAsJson );
		
		var cssClassNames = {
			'headerRow': 'table-header',
			'tableRow': 'table-row',
			'oddTableRow': 'table-odd-row',
			'selectedTableRow': 'table-selected',
			'hoverTableRow': 'table-hover'
		};

		options[ "page" ] = "enable";
		options[ "pageSize" ] = 25;
		options[ "pagingSymbols" ] = { prev: 'prev', next: 'next' };
		options[ "pagingButtonsConfiguration" ] = "auto";      
		options[ "cssClassNames" ] = cssClassNames;

		termTable = new google.visualization.Table(document.getElementById( "termTable" ));
		termTable.draw( data, options );  

		google.visualization.events.addListener( termTable, 'select', function() {
			selection = termTable.getSelection();
			list = "";
			for ( i = 0; i < selection.length; i++ ) {
				if ( list.length>0 ) list+="</br>"
				list +=  data.getValue( selection[ i ].row, 0 );
			}
			$("#selectedList").html( list ); 
		});
    }
    
    google.setOnLoadCallback( drawVisualization );

    //-- sets the number of pages according to the user selection.
    function setPagination( numPages ) {
		if ( numPages ) {
			options[ "page" ] = "enable";
			options[ "pageSize" ] = parseInt( numPages, 10 );
		} else {
			options[ "page" ] = null;  
			options[ "pageSize" ] = null;
		}
		termTable.draw( data, options );  
    }
	
	</script>
</head>

<body style="font-family: georgia; font-size:12px;">
<div style="margin: auto; height:768px; width:1020px; text-align:middle;">
	<div style="float:left; width:800px;">
		<div style="font-size:12px; margin-bottom:10px;">
			<div style="margin-top:15px; float:right; font-size:11px; vertical-align:bottom">
				{{message}}
			</div>
			<div>
				<span >Number rows/page:</span>
				<select style="font-size: 12px;" onchange="setPagination( this.value )">
					<option value="10">10</option>
					<option selected="selected" value="25">25</option>
					<option value="50">50</option>
					<option value="100">100</option>
					<option value="">all</option>
				</select>
			</div>
			
		</div>

		<div id="termTable" style="width:800;">next</div>
	</div>

	<div style="text-align:center; margin:34 0 0 20; float:left; border:1px solid #fafafa; width:175px;">
		<div style="padding-top: 5px; height:23px; font-weight:bold; border:1px solid #dadada;"> 
			Selected Terms:
		</div>
		<div id="selectedList" style="min-height:50px; border:1px solid #eaeaea; background-color: #fafafa; padding:5px; font-size:11px;"> 
		</div>
		
		<div style="margin-top:15px; padding-top: 5px; height:23px; font-weight:bold; border:1px solid #dadada;"> 
			Search For:
		</div>
		<div style="text-align:right; border:1px solid #eaeaea; background-color: #fafafa; padding:10 10 0 0;"> 
			<form name="searchForm" action="/data" method="GET" enctype="multipart/form-data">

				<select name="match_type" style="width:150px; font-size:11px;">
					%if match_type == 'contains':
					<option selected="selected" value="contains">A term containing...</option>
					%else:
					<option value="contains">A term containing...</option>
					%end

					%if match_type == 'exact':
					<option selected="selected" value="exact">The exact term...</option>
					%else:
					<option value="exact">The exact term...</option>
					%end

					%if match_type == 'starts':
					<option selected="selected" value="starts">A term starting with...</option>
					%else:
					<option value="starts">A term starting with...</option>
					%end

					%if match_type == 'ends':
					<option selected="selected" value="ends">A term ending with...</option>
					%else:
					<option value="ends">A term ending with...</option>
					%end
				</select>		
				
				<input type="text" name="search_term" value="{{search_term}}" style="width:150px;"/><br/>
				<input type="hidden" name="type" value="search"/>
				<span><a href="javascript:document.searchForm.submit();">Search</a></span>
			</form>
		</div>

		<div style="margin-top:15px; padding-top: 5px; height:23px; font-weight:bold; border:1px solid #dadada;"> 
			Filter Terms:
		</div>
		<div style="text-align:right; border:1px solid #eaeaea; background-color: #fafafa; padding:10 10 0 0;"> 
			<form name="filterForm" action="/data" method="GET" enctype="multipart/form-data">
				
				<select name="direction" style="width:150px; font-size:11px;">

					%if direction == 'ASC':
					<option value="DESC">top 1000 terms</option>
					<option selected="selected" value="ASC">bottom 1000 terms</option>
					%else:
					<option selected="selected" value="DESC">top 1000 terms</option>
					<option value="ASC">bottom 1000 terms</option>
					%end
				</select><br/>

				<select name="order_by" style="width:150px; font-size:11px;">
					%if order_by == 'alphabetical order':
					<option selected="selected" value="alphabetical order">by alphabetical order</option>
					%else:
					<option value="alphabetical order">by alphabetical order</option>
					%end

					%if order_by == 'total appearances':
					<option selected="selected" value="total appearances">by total appearances</option>
					%else:
					<option value="total appearances">by total appearances</option>
					%end

					%if order_by == 'doc appearances':
					<option selected="selected" value="doc appearances">by doc appearances</option>
					%else:
					<option value="doc appearances">by doc appearances</option>
					%end

					%if order_by == 'frequency':
					<option selected="selected" value="frequency">by overall frequency</option>
					%else:
					<option value="frequency">by overall frequency</option>
					%end

					%if order_by == 'web importance':
					<option selected="selected" value="web importance">by importance on web</option>
					%else:
					<option value="web importance">by importance on web</option>
					%end

					%if order_by == 'relevance':
					<option selected="selected" value="relevance">by relevance to you</option>
					%else:
					<option value="relevance">by relevance to you</option>
					%end

					%if order_by == 'last seen':
					<option selected="selected" value="last seen">by time last seen</option>
					%else:
					<option value="last seen">by time last seen</option>
					%end
				</select><br/>

				<input type="hidden" name="type" value="filter"/>
				<span><a href="javascript:document.filterForm.submit();">Fetch</a></span>
			</form>
		</div>

		
	</div>
</div>
</body>

</html>