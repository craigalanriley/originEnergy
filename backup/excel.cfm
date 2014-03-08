

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
        <td>Start Date: <input type="text" id="startDate" name="startDate" value="<cfoutput>#startDate#</cfoutput>"></td>
        <td>End Date: <input type="text" id="endDate" name="endDate" value="<cfoutput>#endDate#</cfoutput>"></td>
        <td><input type="submit" value="Show Prices" name="Prices"></td>
    </tr>
    </table>
    </cfform> 
    
	<cfset excelPath = ExpandPath("prices.xls")>
   	<cfdump var="#excelPath#"> 
    
    <!-- Load Excel Data -->
    <cfspreadsheet 
                action 	="read" 
                src		="#excelPath#" 
                query		="getAllData" 
                sheet		="1"
                columns	="1,2,3,4,5">
    
    <!-- Reorder results by bucket count for chart -->
    <cfquery dbtype="query" name="getBucketCounts">
        select col_5 AS bucket, count(col_5) AS BucketCount from getAllData
        group by bucket
    </cfquery>
   	<cfdump var="#getBucketCounts#">
    
    <!-- Get Bucket Counts based on Selected Date Range -->
    <!---
    <cfquery name="getBucketCounts" datasource="origin">
        select bucket, count(bucket) AS BucketCount from prices 
        where priceDate >= '#DateFormat(startDate, "yyyy-mm-dd")#' AND priceDate <= '#DateFormat(endDate, "yyyy-mm-dd")#'	
        group by bucket
    </cfquery>
	--->
    
    <!-- Add any null counts -->
    <cfloop list="#BucketList#" index="x">
        <!-- Check if bucket is in result set -->
        <cfquery dbtype="query" name="ifBucketExists">
            select * from getBucketCounts
            where bucket = #Evaluate(x)# 
        </cfquery>
        <cfif NOT ifBucketExists.RecordCount><!-- If bucket doesn't exist add to query so shows up on chart x-axis -->
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
    <cfchart format="flash" xaxistitle="Bucket" yaxistitle="Frequency" chartwidth="1400" chartheight="400"> 
    
        <cfchartseries	 type="bar" 
                         query="allBucketCounts" 
                         itemcolumn="bucket" 
                         valuecolumn="BucketCount" />
    </cfchart>
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    <!---
    <cfquery name="getPrices" datasource="origin">
        select priceDate, slot, price, bucket from prices 
        where priceDate >= '#DateFormat(startDate, "yyyy-mm-dd")#' AND priceDate <= '#DateFormat(endDate, "yyyy-mm-dd")#'
        order by priceDate
    </cfquery>
    <cfdump var="#getPrices#" top="50000000">
    --->
    
    <!--- Populate DB from .XLS file --->
    <cfif isDefined("URL.InsertData")>
    
        <cfspreadsheet 
                action 	="read" 
                src		="/Applications/ColdFusion10/cfusion/wwwroot/origin/prices.xls" 
                query		="excelSpreadsheet" 
                sheet		="1" 
                rows		="1-1000000" 
                columns	="1,2,3,4,5">
                            
        <cfoutput query="excelSpreadsheet" startrow="1" maxrows="#excelSpreadsheet.recordcount#">
        
            #excelSpreadsheet.col_1# 
            #excelSpreadsheet.col_2# 
            #excelSpreadsheet.col_3# 
            #excelSpreadsheet.col_4# 
            #excelSpreadsheet.col_5# 
            <br/>
            <cfquery datasource="origin" name="InsertData">
                INSERT INTO prices(state,pricedate,slot,price,bucket)
               VALUES (
                        '#excelSpreadsheet.col_1#',
                        '#excelSpreadsheet.col_2#',
                        #excelSpreadsheet.col_3#,
                        #excelSpreadsheet.col_4#,
                        #excelSpreadsheet.col_5#
                      )
            </cfquery>
            
        </cfoutput>
        
    </cfif>

</body>
</html>
