
<cfset minStartDate = "06/01/2006">
<cfset maxStartDate = "06/01/2007">
<cfset BucketList = "0,10,20,30,40,50,60,70,80,90,100,200,300,400,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000">

<cfparam name="startDate" default="#minStartDate#">
<cfparam name="endDate" default="#maxStartDate#">

<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Origin</title>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css">
    <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
    <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
    <script>
        // jQuery Date Picker
        $(function(){
            $( "#startDate" ).datepicker({ minDate: "<cfoutput>#minStartDate#</cfoutput>", maxDate: "<cfoutput>#maxStartDate#</cfoutput>" });
            $( "#endDate" ).datepicker({ minDate: "<cfoutput>#minStartDate#</cfoutput>", maxDate: "<cfoutput>#maxStartDate#</cfoutput>" });
            });
    </script>
</head>

<body style="font-family:Gotham, 'Helvetica Neue', Helvetica, Arial, sans-serif">	

<!-- UI -->
<cfform action="?Action=1" method="post">
<table cellpadding="10" cellspacing="0" align="center">
<tr>
    <td>Start Date: <input type="text" id="startDate" name="startDate" readonly value="<cfoutput>#startDate#</cfoutput>"></td>
    <td>End Date: <input type="text" id="endDate" name="endDate" readonly value="<cfoutput>#endDate#</cfoutput>"></td>
    <td><input type="submit" value="Show Prices" name="Prices"></td>
</tr>
</table>
</cfform> 

<!-- Get Bucket Counts based on Selected Date Range -->
<cfquery name="getBucketCounts" datasource="origindsn">
    select bucket, count(bucket) AS BucketCount from prices 
    where priceDate >= '#DateFormat(startDate, "yyyy-mm-dd")#' AND priceDate <= '#DateFormat(endDate, "yyyy-mm-dd")#'	
    group by bucket
</cfquery>

<!-- Add any null buckets to record set -->
<cfloop list="#BucketList#" index="x">
    <!-- Check if bucket is in result set -->
    <cfquery dbtype="query" name="ifBucketExists">
        select * from getBucketCounts
        where bucket = #Evaluate(x)# 
    </cfquery>
    <!-- If bucket doesn't exist add to query so shows up on chart x-axis -->
    <cfif NOT ifBucketExists.RecordCount>
        <cfset QueryAddRow(getBucketCounts)/>
        <cfset QuerySetCell(getBucketCounts, "bucket", Evaluate(x))/> 
        <cfset QuerySetCell(getBucketCounts, "BucketCount", 0)/>
    </cfif>
</cfloop>

<!-- Reorder results by bucket count for chart -->
<cfquery dbtype="query" name="allBucketCounts">
    select * from getBucketCounts
    order by bucket 
</cfquery>

<!-- Chart Results -->
<div style="width:1000px; float:left">
	<cfchart format="flash" xaxistitle="Bucket" yaxistitle="Frequency" chartwidth="1200" chartheight="700"> 
	
		<cfchartseries	 type="bar" 
	                 		query="allBucketCounts" 
	                 		itemcolumn="bucket" 
	                 		valuecolumn="BucketCount" serieslabel="yes" />
	</cfchart>
</div>

<!-- Results Table-->
<div style="float:right; padding: 10px 25px 0 0">
    <table cellpadding="3" cellspacing="0" style="font-size:12px">
    <tr>
        <th>Bucket</th>
        <th>Frequency</th>
    </tr>
    <cfoutput query="allBucketCounts">
	    <tr>
	        <td align="right">#Bucket#</td>
	        <td align="right">#BucketCount#</td>
	    </tr>
    </cfoutput>
    </table>
</div>

</body>
</html>
