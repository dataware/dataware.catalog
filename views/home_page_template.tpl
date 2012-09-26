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
        <div class="well">
            Welcome back!		
        </div>
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