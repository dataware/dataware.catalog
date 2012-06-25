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

<div class="sub_header">
	<div class="page-name">HOME</div>
	<div class="page-description">
		WELCOME TO THE DATAWARE CATALOG - HELPING TO MANAGING YOUR DATA LIFE
	</div>
</div>


<style>

.blurb {
	display: table-cell;
	clear: both;
	padding-left: 75px;
}

.blurb_item {
	background-color: #ffffff;
	float: left;
	width:275;
	margin:2px;
	padding:8px;
}

.instructions {
	border: 1px dotted blue;
}

.blurb_header {
	font-size:22; 
	font-weight:bold; 
	color:#994747;
	margin-bottom:4px;
}

.blurb_icon {
	float:left;
	margin-right:5px;
}

.blurb-description {
	float:left;
	color: gray;
	font-size: 13px;
	font-style: italic;
	margin-bottom: 10px;
}

.separator{
	border-top: 1px dotted gray;
	height:18px;
}

.instruction-header {
	font-size:26;
	color:#f0f0ff;
	font-weight:bold; 
	background-color: #994747;
	width:120px;
}

.instruction-description {
	color: #777777;
	font-size: 16px;
}

.extension_out {
	width:185px; 
	vertical-align:text-top
}

</style>


<!---------------------------------------------------------------- 
	CONTENT SECTION
------------------------------------------------------------------>
<div class="main">

	<div class="blurb">
		The Dataware Catalog Blurb will go here
	</div>
	
	<div class="separator"></div>

	<!---------------------------------------------------------------- 
		INSTRUCTIONS SECTION
	------------------------------------------------------------------>
	<div style="float:left; margin-left:85px; width:300px; border:0px dotted gray">
		Instructions will go here
	</div>


	<!---------------------------------------------------------------- 
		SUMMARY SECTION
	------------------------------------------------------------------>
	%if user:
	<div style="margin-left:530px; font-family:georgia; border:0px dotted #cccccc; width:380px;">
		Welcome back		
	</div>	
	%end
</div>

<!-- FOOTER ------------------------------------------------------------------>
%include footer