<!-- HEADER ------------------------------------------------------------------>
%include header user=user, REALM=REALM

<!---------------------------------------------------------------- 
	PAGE SCRIPTS
------------------------------------------------------------------>
<script type="text/javascript">
</script>


<!---------------------------------------------------------------- 
	HEADER SECTION
------------------------------------------------------------------>
<div class="container">
    
    %if user:
        
            %if resources:
            <h4> You are sharing the following resources with this catalog: </h4>
            <table class="table table-condensed table-striped table-bordered">
               <thead>
                    <tr>
                        <th>shared</th>
                        <th>resource name</th>
                        <th>location</th>
                    </tr>   
                </thead>  
                <tbody>
                    %for resource in resources:
                    <tr>
                        <td> {{resource['created']}}</td>
                        <td> {{resource['name']}}</td>
                        <td> <a href="{{resource['uri']}}">{{resource['uri']}}</a></td>
                    </tr>
                    %end 
                </tbody>
            </table>
            %else:
                <div class="alert alert-info">
                You currently have no resources registered with your catalog.  To register a resource, go to your resource's url and click on 'share data'.  You will be prompted for your catalog's url (use this one) and to confirm that you wish to add the resource to this catalog.
                 </div>
            %end
       
	%else:
        <div class="hero-unit">
            <h1>Welcome to the dataware catalog.</h1>
            <p> Manage access to your data </p>
            <p>
                <a class="btn btn-primary btn-large">
                    Learn more
                </a>
            </p>
            <p>
             <a href="/login">Login </a>to get started
            </p>
        </div>
	%end
</div>

<!-- FOOTER ------------------------------------------------------------------>
%include footer