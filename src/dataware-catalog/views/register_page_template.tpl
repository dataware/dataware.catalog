<!-- HEADER ------------------------------------------------------------------>
%include header user=user, REALM=REALM

<!---------------------------------------------------------------- 
	PAGE SCRIPTS
------------------------------------------------------------------>
<script type="text/javascript">
	/**
	 * Function that redirects the user to the server's openid login
	 */ 
	function login( provider ) {
		window.open( "login?provider=" + provider, "_self" )
	}

</script>


<!---------------------------------------------------------------- 
	HEADER SECTION
------------------------------------------------------------------>


<!---------------------------------------------------------------- 
	CONTENT SECTION
------------------------------------------------------------------>
<div class="main">

	<div style="margin:25px auto; padding:15px; border:1px dotted #cccccc; width:230px;">
		<div> 
			<img src="./static/cataloglogo.png" width="220px"/>
		</div>
		<div style="text-align:left; font-style:italic; font-family:georgia; font-size:12px; color: #888888; margin:10px 0px 18px 7px;">
			This seems to be the first time you have logged in. To activate your account
			please pick a user name, and register an email address:
		</div>
		<!--<div id="loggedOutBox" >-->
			<div style="padding:0 10 0 8; height:auto; border:0px dotted; font-size:12px; font-family:georgia; color:#555555;">
        <form action="register" method="GET" >
		
	            <div>Screen Name:
				%if "user_name" in errors:
					<span class="loginMessage"> {{errors[ "user_name" ]}}</span>
				%end
				</div>
		        <div>
			        <input id="jid" name="user_name" value="{{user_name}}" type="text" style="height:25px" />
				</div>

	            <div style="margin-top:5px;">
					Email:
					%if "email" in errors:
						<span class="loginMessage"> {{errors[ "email" ]}}</span>
					%end
				</div>
		        <div class="right">
			        <input id="email" name="email" value="{{email}}"  type="text" style="height:25px" />
				</div>
				<input type="submit" class="btn btn-info" style="margin:10 0 0 10;" value="Register" />
				<input type="hidden" name="submission" value="True" />
			
		</form>
		</div>
	</div>	
</div>

<!-- FOOTER ------------------------------------------------------------------>
%include footer
