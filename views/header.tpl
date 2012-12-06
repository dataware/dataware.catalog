<html>
<head>
<title>Dataware - Catalog</title>

<link rel="stylesheet" type="text/css" href="./static/bootstrap/css/bootstrap.css" /> 
<script type="text/javascript" src="./static/jquery-1.6.min.js"></script> 
<script type="text/javascript" src="./static/knockout-2.2.0.js"></script>
<script type="text/javascript" src="/_ah/channel/jsapi"></script>

 
<script>	
	$( document ).ready( function() {
		$( 'a.menu_button' ).click( function() {
			self.parent.location = "{{REALM}}/" + $( this ).attr('id');
		});

	});
</script>
</head>

<body>
    <div class="navbar">
        <div class="navbar-inner">
            <a class="brand" href="#">My dataware catalog</a>
            <ul class="nav">
               
                %if user:
                <li><a href="#" class="menu_button" id="audit">home</a></li>
                <li><a href="#" class="menu_button" id="logout">logout</a></li>
                %else:
                <li><a href="#" class="menu_button" id="home">home</a></li>
                <li><a href="#" class="menu_button" id="login">login/register</a></li>
                %end
            </ul>
        </div>
    </div>

