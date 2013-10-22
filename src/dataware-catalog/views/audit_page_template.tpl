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
	
</script>

<!---------------------------------------------------------------- 
	HEADER SECTION
------------------------------------------------------------------>




<!---------------------------------------------------------------- 
	CONTENT SECTION
------------------------------------------------------------------>
<div class="container">
    
    
    <h4>AUDIT</h4>
    <div class="alert alert-info">
        This page shows all executions that have been registered against your resources.
    </div>
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
        <tbody data-bind="foreach: processors"> 
            <tr>
                <td><span data-bind="text:id"></span></td>
                <td>
                    <a data-bind="attr:{href:client_domain}">
                        <span data-bind="text:client_name"></span>
                    </a>
                </td>
                <td><span data-bind="text:resource_name"></span></td> 
                <td><span data-bind="text:request_status"></span></td> 
                <td><span data-bind="text:expiry_date"></span></td> 
                <td><code class="brush: python; toolbar: false" data-bind="text:query"></code></td>
                <td>
                    <div class="btn-group" data-bind="visible:pending">
                        <a class="btn btn-primary" href="#" data-bind="click:authorise_request">authorise</a> 
                        <a class="btn btn-primary" href="#" data-bind="click:reject_request">reject</a> 
                        <a class="btn btn-primary" href="#" data-bind="click:test">test</a> 
                    </div>
	
					<div data-bind="visible:accepted">
						<a href='#' data-bind="click:revoke_request">revoke</a>
					</div>			
                </td> 
            </tr>
        </tbody>
    </table>  
    
    
    
    
    
<!-- Finally, to actually run the highlighter, you need to include this JS on your page -->
<script type="text/javascript">
	SyntaxHighlighter.config.tagName = "code";
    SyntaxHighlighter.all()
</script>

<script type="text/javascript">
    
    //setup namespace
    var dw = dw || {};
    
    dw.ajaxservice = (function(){
        var
        
            ajaxPostJson = function(url, jsonIn, success_callback, error_callback){
                $.ajax({
                        url: url,
                        contentType: 'json',
                        type: "POST",
                        data: jsonIn,
                        dataType: 'json',
                        success: function(data, status){
                            success_callback(data, status)    
                        },
                        error: function(data, status){
                            if (error_callback){
                                error_callback(data,status);
                            }       
                        }
                });
            }
        
            ajaxGetJson = function(url, jsonIn, success_callback, error_callback){
                $.ajax({
                        url: url,
                        contentType: 'json',
                        type: "GET",
                        timeout: 4000,
                        dataType: 'json',
                        
                        success: function(result){
                            success_callback(result)    
                        },
                        error: function(XMLHttpRequest, textStatus, errorThrown){
                            if (error_callback){
                                error_callback(XMLHttpRequest, textStatus, errorThrown);
                            }       
                        }
                });
            }
            
            return{
                ajaxPostJson: ajaxPostJson,
                ajaxGetJson: ajaxGetJson
            }
    })();
    
    //processor model
    dw.processor = function(){
        
        var self = this;
        
        this.id = ko.observable();
        this.client_name = ko.observable();
        this.client_id = ko.observable();
        this.client_domain = ko.observable();
        this.request_status = ko.observable("PENDING");
        this.query = ko.observable();
        this.created = ko.observable();
        this.expiry_time = ko.observable();
        this.resource_name = ko.observable();
        this.resource_id = ko.observable();
        this.state = ko.observable();
        this.user_id = ko.observable();
        this.accesstoken = ko.observable();
        this.auth_code = ko.observable();
        
        this.expiry_date = ko.computed(function(){
        
            a = new Date(this.expiry_time() * 1000); //date takes milliseconds since epoch!
            months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            year = a.getFullYear();
            month = months[a.getMonth()];
            day = a.getDate();
            hour = a.getUTCHours();
            min = a.getUTCMinutes();
            sec = a.getUTCSeconds();
            return  day+' '+month+' '+year ;
        }, this);
        
        this.accepted = ko.computed(function(){
            return this.request_status() == "ACCEPTED";
        },this);
        
        this.pending = ko.computed(function(){
            return this.request_status() == "PENDING";
        },this);
        
        this.authorise_request = function(){
            $.prompt(
			    'Are you sure you want to authorize this processing request?', 
			    { 
				    buttons: { Yes: true, Cancel: false },
				    callback: function ( v, m, f ) { 
					    if ( v == false ) return;
					    else self.authorise()
				    }
			    }
		    );
        }
        
        this.authorise = function(){
        
            success_callback = function(data, status){
				if ( data.success ) {
					window.location = data.redirect;
				} else if ( data.cause == "resource_provider" ) {
					forwarding_box( data.error, data.redirect );
				} else {
					error_box( data.error );
				}
            };
            
            error_callback = function(data, status){
                error_box( "Unable to contact server at this time. Please try again later." );
            };
            
            console.log("AUTHORIZING AND ID IS " + self.id());
            
            dw.ajaxservice.ajaxPostJson(
                                        '/client_authorize', 
                                        {'processor_id':self.id}, 
                                        success_callback, 
                                        error_callback
                                        );
        };
        
        this.reject_request = function() {
            $.prompt(
                'Are you sure you want to reject this processing request?', 
                { 
                    buttons: { Yes: true, Cancel: false },
                    callback: function ( v, m, f ) { 
                        if ( v == false ) return;
                        else self.reject();
                    }
                }
            )
	    };
	    
        this.reject = function(){
        
            success_callback = function(data, status){
				if ( data.success ) {
					window.location = data.redirect;
				} else if ( data.cause == "resource_provider" ) {
					forwarding_box( data.error, data.redirect );
				} else {
					error_box( data.error );
				}
            };
            
            error_callback = function(data, status){
                error_box( "Unable to contact server at this time. Please try again later." );
            };
            
            dw.ajaxservice.ajaxPostJson(
                                        '/client_reject',
                                        {'processor_id':self.id}, 
                                        success_callback, 
                                        error_callback
                                       );
        };
        
        this.revoke_request = function(){
            $.prompt(
                'Are you sure you want to revoke this processing request?', 
                { 
                    buttons: { Yes: true, Cancel: false },
                    callback: function ( v, m, f ) { 
                        if ( v == false ) return;
                        else self.revoke()
                    }
                }
            )
        };
        
        
        this.revoke = function(){
        
            success_callback = function( data, status  ) {
			
				if ( data.success ) {
					window.location = data.redirect;
				} else if ( data.cause == "resource_provider" ) {
	 				resource_error_box( data.error )
				} else {
					error_box( data.error )
				}
			};
			
			error_callback = function( data, status ) {
				error_box( "Unable to contact server at this time. Please try again later." );
			};
			
            dw.ajaxservice.ajaxPostJson(
                                        '/client_revoke',
                                        {'processor_id':self.id}, 
                                        success_callback, 
                                        error_callback
                                       );
        };
        
        this.test = function(){
            window.location = self.resource().resource_uri + "/test_query?query=" + encodeURIComponent(self.query()) + "&parameters={}"    
        };
        
    }
    
    //main view model
    dw.catalog = (function(){
        var
            processors = ko.observableArray(),
            
            loadData = function(data){
		console.log("loading data " )
		console.log(data);

                $.each(data, function(i,p){
                    processors.push(new dw.processor()
                                    .id(p.processor_id)
                                    .client_name(p.client_name)
                                    .client_id(p.client_id)
                                    .client_domain("")
                                    .request_status(p.request_status)
                                    .query(p.query)
                                    .created(p.created)
                                    .expiry_time(p.expiry_time)
                                    .resource_name(p.resource_name)
                                    .resource_id(p.resource_id)
                                    .state(p.state)
                                    .user_id(p.user_id)
                                    .accesstoken(p.accesstoken)
                                    .auth_code(p.auth_code)
                                    );
                });
                console.log(processors());
            }
            
        return{
            processors: processors,
            loadData: loadData,
        }    
    })();

    $(function(){
        dw.catalog.loadData({{!processorjson}});
        ko.applyBindings(dw.catalog);    
    });
    
</script>
<!-- FOOTER ------------------------------------------------------------------>
%include footer
