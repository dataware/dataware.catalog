<!-- HEADER ------------------------------------------------------------------>
%include header user=user, REALM=REALM

<!---------------------------------------------------------------- 
	PAGE SCRIPTS
------------------------------------------------------------------>

<!-- Include required JS files -->
<script type="text/javascript" src="static/shCore.js"></script>
<script type="text/javascript" src="static/shBrushPython.js"></script>
<script type="text/javascript" src="static/jquery-impromptu.3.2.js"></script>

<!-- Include *at least* the core style and default theme -->
<link href="static/shCore.css" rel="stylesheet" type="text/css" />
<link href="static/impromptu.css" rel="stylesheet" type="text/css" />
<link href="static/shThemeDefault.css" rel="stylesheet" type="text/css" />
 
<script>

	function resource_error_box( error ) {
		msg = "<span class='resource_error_box'>RESOURCE ERROR:</span>&nbsp;&nbsp;" + error
		$.prompt( msg,  {  buttons: { Continue: true }	} )
	}

	////////////////////////////////////////////////////
	
	function forwarding_box( error, redirect ) {
		msg = "<span class='resource_error_box'>RESOURCE SAYS:</span>&nbsp;&nbsp;<i>\"" + error + "\"</i><br/>";
		msg += "<span class='resource_error_box'>There is no choice but to reject the processing request.</span>";
		$.prompt( msg,  {  
			buttons: { Continue: true },
			callback: function ( v, m, f ) { 
				window.location = redirect;
			}
		} )
	}

	////////////////////////////////////////////////////

	function error_box( error ) {
		msg = "<span class='error_box'>ERROR:</span>&nbsp;&nbsp;" + error
		$.prompt( msg,  {  buttons: { Continue: true }, } )
	}

	////////////////////////////////////////////////////

	function authorize_request( processor_id ) {
		$.prompt(
			'Are you sure you want to authorize this processing request?', 
			{ 
				buttons: { Yes: true, Cancel: false },
				callback: function ( v, m, f ) { 
					if ( v == false ) return;
					else authorize_request_ajax( processor_id )
				}
			}
		)
	}

	////////////////////////////////////////////////////

	function reject_request( processor_id ) {
		$.prompt(
			'Are you sure you want to reject this processing request?', 
			{ 
				buttons: { Yes: true, Cancel: false },
				callback: function ( v, m, f ) { 
					if ( v == false ) return;
					else reject_request_ajax( processor_id )
				}
			}
		)
	}

	////////////////////////////////////////////////////

	function revoke_request( processor_id ) {
		$.prompt(
			'Are you sure you want to revoke this processing request?', 
			{ 
				buttons: { Yes: true, Cancel: false },
				callback: function ( v, m, f ) { 
					if ( v == false ) return;
					else revoke_request_ajax( processor_id )
				}
			}
		)
	}

	////////////////////////////////////////////////////

	function authorize_request_ajax( processor_id ) {
		$.ajax({
			type: 'POST',
			url: "/client_authorize",
			data: "processor_id=" + processor_id,
			success: function( data, status  ) {
				data = eval( '(' + data + ')' );
				if ( data.success ) {
					window.location = data.redirect;
				} else if ( data.cause == "resource_provider" ) {
					forwarding_box( data.error, data.redirect );
				} else {
					error_box( data.error );
				}
			},
			error: function( data, status ) {
				error_box( "Unable to contact server at this time. Please try again later." );
			}
		});
	}

	////////////////////////////////////////////////////

	function reject_request_ajax( processor_id ) {
		$.ajax({
			type: 'POST',
			url: "/client_reject",
			data: "processor_id=" + processor_id,
			success: function( data, status ) {
				data = eval('(' + data + ')');
				if ( data.success ) {
					window.location = data.redirect;
				} else {
					error_box( data.error );
				}
			},
			error: function( data, status ) {
				error_box( "Unable to contact server at this time. Please try again later." );
			}
		});		
	}
	

	////////////////////////////////////////////////////

	function revoke_request_ajax( processor_id ) {
		$.ajax({
			type: 'POST',
			url: "/client_revoke",
			data: "processor_id=" + processor_id,
			success: function( data, status  ) {
				data = eval( '(' + data + ')' );
				if ( data.success ) {
					window.location = data.redirect;
				} else if ( data.cause == "resource_provider" ) {
	 				resource_error_box( data.error )
				} else {
					error_box( data.error )
				}
			},
			error: function( data, status ) {
				error_box( "Unable to contact server at this time. Please try again later." );
			}
		});
	}
	
	
	function test_query( resource_uri, query, parameters ) {
		$.ajax({
			type: 'POST',
			url: "/test_query",
			dataType: "json",
			data: {
			    resource_uri: resource_uri,
			    query: query,
			    parameters: parameters
			},
			success: function( data, status  ) {
				console.log(data)
			},
			error: function( data, status ) {
				error_box( "Unable to contact resource at this time. Please try again later." );
			}
		});
	}

	////////////////////////////////////////////////////

	function toggle( processor_id ) {
		full = $( "#request_" + processor_id + "_full" );
		preview = $( "#request_" + processor_id + "_preview" );

		if ( full.css( "display" ) == "none" ) {
			full.css( "display", "block" );
			preview.css( "display", "none" );
		} else {
			full.css( "display", "none" );
			preview.css( "display", "block" );
		}
	}
	
	
	function test_uri(resource_uri, query, parameters){
	    window.location = resource_uri + "/test_query?query=" + encodeURIComponent(query) + "&parameters=" + encodeURIComponent(parameters); 
	}
	
	function showtoken(token){
	    console.log(token);
	    console.log("subscribing");
	    channel = new goog.appengine.Channel(token);
	    socket = channel.open();
	    socket.onopen = function(){console.log("opened")};
	    socket.onmessage = function(data){console.log(data);alert(data)}
	}
	
	function sendmessage(){
	    $.ajax({
			type: 'POST',
			url: "/sendmessage",
			data: "",
			success: function( data, status  ) {
				
			},
			error: function( data, status ) {
				error_box( "Unable to contact server at this time. Please try again later." );
			}
		});
	}
	
</script>

<!---------------------------------------------------------------- 
	HEADER SECTION
------------------------------------------------------------------>




<!---------------------------------------------------------------- 
	CONTENT SECTION
------------------------------------------------------------------>
<div class="container">
    
    
    <h4>AUDIT</h4>
    
    <a class="btn btn-primary" href="javascript:showtoken('{{user.channel_token}}')">see token</a> 
    <a class="btn btn-primary" href="javascript:sendmessage()">send message</a> 
    
    <table class="table table-condensed table-striped table-bordered">
    
       <thead>
            <tr>
                <th>id</th>
                <th>initiator</th>
                <th>resource</th>
                <th>status</th>
                <th>expiry</th>
                <th>code</th>
                <th>action</th>
            </tr>   
        </thead>  
        
        <tbody> 
            %for processor in processors:
            <tr>
                <td>{{processor.key().id()}}</td>
                <td><a href="{{processor.client.client_domain}}">{{processor.client.client_name}}</a></td>
                <td>{{processor.resource.resource_name}}</td> 
                <td>{{processor.request_status}}</td> 
                %import time
                <td>{{time.strftime( "%d %b %Y %H:%M", time.gmtime( processor.expiry_time) )}}</td> 
                <td><code class="brush: python; toolbar: false">{{processor.query}}</code></td>
                <td>
                    %if processor.request_status == "PENDING":
                        <div class="btn-group">
                            <a class="btn btn-primary" href='javascript:authorize_request({{processor.key().id() }})'>authorize</a> 
                            <a class="btn btn-primary" href='javascript:reject_request({{processor.key().id() }})'>reject</a>
						    <a class="btn btn-primary" href='javascript:test_uri("{{processor.resource.resource_uri}}","{{processor.query}}","{}")'>test</a>
                        </div>
						
						
					%elif processor.request_status == "ACCEPTED":
						<a href='javascript:revoke_request({{processor.key().id()}})'>revoke</a>
					%end
                </td> 
            </tr> 
            %end
        </tbody>
    </table>  
<!-- Finally, to actually run the highlighter, you need to include this JS on your page -->
<script type="text/javascript">
	SyntaxHighlighter.config.tagName = "code";
    SyntaxHighlighter.all()
</script>

<script type="text/javascript">
    
    function CatalogModel(){
        console.log('creating new catalog model...');
        this.processors = ko.observableArray({{!processorjson}});
        console.log(this.processors());
    }

    var cm = new CatalogModel();
    ko.applyBindings(cm);    

</script>
<!-- FOOTER ------------------------------------------------------------------>
%include footer

