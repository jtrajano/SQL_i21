
GO
PRINT 'START OF CREATING uspTMGetConsumptionWithGasCheck SP'
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WithGasCheck]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WithGasCheck]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMGetConsumptionWithGasCheck]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspTMGetConsumptionWithGasCheck]
GO



CREATE PROCEDURE [dbo].[uspTMGetConsumptionWithGasCheck](
	@xmlParam NVARCHAR(MAX)=null   )
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
--set @xmlparam = '<filterinfo>
--<parameter>
--<fieldname>strOwnership</fieldname>
--<condition>Equal To</condition>
--<from>Company Owned</from>
--<to></to>
--<join>and</join>
--<begingroup />
--<endgroup />
--<datatype>string</datatype>
--</parameter>
--<parameter>
--<fieldname>SiteStatus</fieldname>
--<condition>Equal To</condition>
--<from>Active</from>
--<to></to>
--<join>and</join>
--<begingroup />
--<endgroup />
--<datatype>string</datatype>
--</parameter>
--</filterinfo>'
	--DECLARE @xmlParam NVARCHAR(MAX)
	--set @xmlParam = '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>strLocation</fieldname><condition>Between</condition><from></from><to></to><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>dtmDate</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Date</datatype></filter><filter><fieldname>CustomerStatus</fieldname><condition>Equal To</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>SiteStatus</fieldname><condition>Equal To</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strOwnership</fieldname><condition>Equal To</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strTankType</fieldname><condition>Equal To</condition><from>D</from><to></to><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter></filters></xmlparam>'
	
	
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
		SELECT 
		  '' AS strCustomerFirstName
		  ,'' AS strCustomerLastName
		  ,'' AS strCustomerStatus
		  ,'' AS strCustomerNumber
		  ,'' AS strCustomerName
		  ,getdate() AS dtmDate
		  ,0 AS intSiteID
		  ,0 AS intSiteNumber
		  ,'' AS strSerialNumber
		  ,0 AS intLocationTotalTanks
		  ,'' AS strSiteStatus
		  ,'' AS strLocation
		  ,'' AS strOwnership
		  ,'' AS strTankType
		  ,0 AS ysnHasLeakGasCheck
		  ,0 AS intGrandTotalTanks
		  ,0.0 AS dblTankSize
		  ,0 AS intLocationTotalWithCheck
		  ,0 AS intGrandTotalWithCheck
		  ,0.0 AS dblGrandPercentWithCheck 
		  ,0.0 AS dblLocationPercentWithCheck
		  ,0.0 AS dblGrandPercentWithOutCheck
		  ,0.0 AS dblLocationPercentWithOutCheck
	RETURN;
	END
	
	DECLARE @idoc int
			,@CustomerActive nvarchar(2)
			,@FromCustomerStat nvarchar(50)
			,@FromSiteStatus nvarchar(50)
			,@SiteActive int
			,@FromTankOwnership nvarchar(50)
			,@ToTankOwnership nvarchar(50)
			,@FromDate nvarchar(50)
			,@ToDate nvarchar(50)
			,@FromLocation nvarchar(50)
			,@ToLocation nvarchar(50)
			,@FromTankType nvarchar(50)
			,@ToTankType nvarchar(50)
			,@Query nvarchar(max)
			,@WhereClause1 nvarchar(MAX) = ''
			,@WhereClause2 nvarchar(MAX) = ''
			,@GrandTotalQuery nvarchar(MAX) = ''
			,@GrandTotalWithCheckQuery nvarchar(MAX) = ''
			
			,@CustomerStatusCondition nvarchar(20)
			,@SiteStatusCondition nvarchar(20)
			,@DateCondition nvarchar(20)
			,@TankOwnershipCondition nvarchar(20)
			,@LocationCondition nvarchar(20)
			,@TankTypeCondition nvarchar(20)
			,@intGrandTotalTanks int
			,@intGrandTotalWithCheck int
			
			exec sp_xml_preparedocument @idoc output, @xmlParam
			
			DECLARE @temp_params table ([fieldname] nvarchar(50)
					, condition nvarchar(20)      
					, [from] nvarchar(50)
					, [to] nvarchar(50)
					, [join] nvarchar(10)
					, [begingroup] nvarchar(50)
					, [endgroup] nvarchar(50) 
					, [datatype] nvarchar(50)) 
            
      insert into @temp_params
      select *
      from openxml(@idoc, 'xmlparam/filters/filter',2)
      with ([fieldname] nvarchar(50)
            , condition nvarchar(20)
            , [from] nvarchar(50)
            , [to] nvarchar(50)
            , [join] nvarchar(10)
            , [begingroup] nvarchar(50)
            , [endgroup] nvarchar(50)
            , [datatype] nvarchar(50))

	--Location
	SELECT @FromLocation = [from]
		  ,@ToLocation = [to]
		  ,@LocationCondition = condition
	FROM @temp_params where [fieldname] = 'strLocation'
	
	--Date
	SELECT @FromDate = [from]
		  ,@ToDate = [to]
		  ,@DateCondition = condition
	FROM @temp_params where [fieldname] = 'dtmDate'
	
	
	--Customer Status
	SELECT @FromCustomerStat = [from]
		  ,@CustomerActive = (CASE [from] WHEN 'Active' THEN 'Y'
				WHEN 'Inactive' THEN  'N' END) 
		  ,@CustomerStatusCondition = condition
	FROM @temp_params where [fieldname] = 'CustomerStatus'
	
	--Site Status
	SELECT @FromSiteStatus = [from]
		  ,@SiteActive = (CASE [from] WHEN 'Active' THEN 1
				WHEN 'Inactive' THEN  0 END) 
		  ,@SiteStatusCondition = condition
	FROM @temp_params where [fieldname] = 'SiteStatus'
	
	--Tank Ownership
	SELECT @FromTankOwnership = [from]
		   ,@ToTankOwnership = [to]
		  ,@TankOwnershipCondition = condition
	FROM @temp_params where [fieldname] = 'strOwnership'
	
	--Tank Type
	SELECT @FromTankType = [from]
		   ,@ToTankType = [to]
		  ,@TankTypeCondition = condition
	FROM @temp_params where [fieldname] = 'strTankType'
	
	--*****************BEGIN For intTotalTanks subquery WHERE CLAUSE
	---Site Status
	IF (ISNULL(@FromSiteStatus,'') != '')
	BEGIN 
		IF (@SiteStatusCondition = 'Not Equal To')
		BEGIN
			SET @WhereClause1 = ' AND Z.ysnActive <> ' + CAST(@SiteActive AS NVARCHAR(1))
		END
		ELSE
		BEGIN
			SET @WhereClause1 = ' AND Z.SiteStatus = ' + CAST(@SiteActive AS NVARCHAR(1))
		END
	END
	
	---Customer Status
	IF (ISNULL(@FromCustomerStat,'') != '')
	BEGIN
		IF (@CustomerStatusCondition = 'Not Equal To')
		BEGIN
			SET @WhereClause1 = @WhereClause1 + ' AND X.vwcus_active_yn <> ''' + CAST(@CustomerActive AS NVARCHAR(1)) + ''''
		END
		ELSE
		BEGIN
			SET @WhereClause1 = @WhereClause1 + ' AND X.vwcus_active_yn = ''' + CAST(@CustomerActive AS NVARCHAR(1)) + ''''
		END
	END
	
	---TankOwnership
	IF (ISNULL(@FromTankOwnership,'') != '')
	BEGIN 
		 
         IF(@TankOwnershipCondition = 'Not Equal To') BEGIN SET @WhereClause1 = @WhereClause1 + ' AND V.strOwnership <> ''' + @FromTankOwnership + '''' END
         IF(@TankOwnershipCondition = 'Like' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND V.strOwnership LIKE ''%' + @FromTankOwnership + '%''' END
         IF(@TankOwnershipCondition = 'Between' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND (V.strOwnership BETWEEN ''' + @FromTankOwnership + ''' AND ''' +  @ToTankOwnership + ''')'END
         IF(@TankOwnershipCondition = 'Starts With' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND V.strOwnership LIKE ''' + @FromTankOwnership + '%''' END
         IF(@TankOwnershipCondition = 'Ends With' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND V.strOwnership LIKE ''%' + @FromTankOwnership + '''' END
         IF(@TankOwnershipCondition = 'Equal To' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND V.strOwnership = ''' + @FromTankOwnership + '''' END
		 
	END
	
	---Location
	IF (ISNULL(@FromLocation,'') != '')
	BEGIN 
		 
         IF(@LocationCondition = 'Not Equal To') BEGIN SET @WhereClause1 = @WhereClause1 + ' AND Z.strLocation <> ''' + @FromLocation + '''' END
         IF(@LocationCondition = 'Like' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND Z.strLocation LIKE ''%' + @FromLocation + '%''' END
         IF(@LocationCondition = 'Between' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND (Z.strLocation BETWEEN ''' + @FromLocation + ''' AND ''' +  @ToLocation + ''')'END
         IF(@LocationCondition = 'Starts With' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND Z.strLocation LIKE ''' + @FromLocation + '%''' END
         IF(@LocationCondition = 'Ends With' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND Z.strLocation LIKE ''%' + @FromLocation + '''' END
         IF(@LocationCondition = 'Equal To' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND Z.strLocation = ''' + @FromLocation + '''' END
		 
	END
	
	---Tank Type
	IF (ISNULL(@FromTankType,'') != '')
	BEGIN 
		 
         IF(@TankTypeCondition = 'Not Equal To') BEGIN SET @WhereClause1 = @WhereClause1 + ' AND T.strTankType <> ''' + @FromTankType + '''' END
         IF(@TankTypeCondition = 'Like' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND T.strTankType LIKE ''%' + @FromTankType + '%''' END
         IF(@TankTypeCondition = 'Between' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND (T.strTankType BETWEEN ''' + @FromTankType + ''' AND ''' +  @ToTankType + ''')'END
         IF(@TankTypeCondition = 'Starts With' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND T.strTankType LIKE ''' + @FromTankType + '%''' END
         IF(@TankTypeCondition = 'Ends With' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND T.strTankType LIKE ''%' + @FromTankType + '''' END
         IF(@TankTypeCondition = 'Equal To' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND T.strTankType = ''' + @FromTankType + '''' END
		 
	END

	----Date
	--IF (ISNULL(@FromDate,'') != '')
	--BEGIN 
		 
 --        IF(@DateCondition = 'Not Equal To') BEGIN SET @WhereClause1 = @WhereClause1 + ' AND dtmDate <> ''' + @FromDate + '''' END
 --        IF(@DateCondition = 'Between' ) BEGIN SET @WhereClause1 = @WhereClause1 + ' AND (dtmDate BETWEEN ''' + @FromDate + ''' AND ''' +  @ToDate + ''')'END
 --        ELSE BEGIN SET @WhereClause1 = @WhereClause1 + ' AND Z.dtmDate = ''' + @FromDate + '''' END
	--END

	
	
	--*****************************************END For intTotalTanks subquery WHERE CLAUSE
	
	
	--***************************************** BEGIN For Main Query WHERE CLAUSE
	
	--IF (ISNULL(@FromLocation,'') != '')
	--BEGIN SET @WhereClause2 = 'AND strLocation BETWEEN ''' + @FromLocation + ''' AND ''' + @ToLocation + '''' END
	--IF (ISNULL(@FromSiteStatus,'') != '')
	--BEGIN SET @WhereClause2 = @WhereClause2 + ' AND SiteStatus = ''' + @FromSiteStatus + ''''   END
	--IF (ISNULL(@FromCustomerStat,'') != '')
	--BEGIN SET @WhereClause2 = @WhereClause2 + ' AND CustomerStatus = ''' + @FromCustomerStat + ''''   END
	--IF (ISNULL(@FromTankOwnership,'') != '')
	--BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strOwnership = ''' + @FromTankOwnership + '''' END
	
	---Site Status
	IF (ISNULL(@FromSiteStatus,'') != '')
	BEGIN 
		IF (@SiteStatusCondition = 'Not Equal To')
		BEGIN
			SET @WhereClause2 = ' AND SiteStatus <> ''' + @FromSiteStatus + '''' 
		END
		ELSE
		BEGIN
			SET @WhereClause2 = ' AND SiteStatus = ''' + @FromSiteStatus + '''' 
		END
	END
	
	---Customer Status
	IF (ISNULL(@FromCustomerStat,'') != '')
	BEGIN
		IF (@CustomerStatusCondition = 'Not Equal To')
		BEGIN
			SET @WhereClause2 = @WhereClause2 + ' AND CustomerStatus <> ''' + @FromCustomerStat + '''' 
		END
		ELSE
		BEGIN
			SET @WhereClause2 = @WhereClause2 + ' AND CustomerStatus = ''' + @FromCustomerStat + '''' 
		END
	END
	
	---TankOwnership
	IF (ISNULL(@FromTankOwnership,'') != '')
	BEGIN 
		 
         IF(@TankOwnershipCondition = 'Not Equal To') BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strOwnership <> ''' + @FromTankOwnership + '''' END
         IF(@TankOwnershipCondition = 'Like' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strOwnership LIKE ''%' + @FromTankOwnership + '%''' END
         IF(@TankOwnershipCondition = 'Between' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND (strOwnership BETWEEN ''' + @FromTankOwnership + ''' AND ''' +  @ToTankOwnership + ''')'END
         IF(@TankOwnershipCondition = 'Starts With' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strOwnership LIKE ''' + @FromTankOwnership + '%''' END
         IF(@TankOwnershipCondition = 'Ends With' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strOwnership LIKE ''%' + @FromTankOwnership + '''' END
         IF(@TankOwnershipCondition = 'Equal To' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strOwnership = ''' + @FromTankOwnership + '''' END
		 
	END
	
	---Location
	IF (ISNULL(@FromLocation,'') != '')
	BEGIN 
		 
         IF(@LocationCondition = 'Not Equal To') BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strLocation <> ''' + @FromLocation + '''' END
         IF(@LocationCondition = 'Like' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strLocation LIKE ''%' + @FromLocation + '%''' END
         IF(@LocationCondition = 'Between' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND (strLocation BETWEEN ''' + @FromLocation + ''' AND ''' +  @ToLocation + ''')'END
         IF(@LocationCondition = 'Starts With' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strLocation LIKE ''' + @FromLocation + '%''' END
         IF(@LocationCondition = 'Ends With' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strLocation LIKE ''%' + @FromLocation + '''' END
         IF(@LocationCondition = 'Equal To' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strLocation = ''' + @FromLocation + '''' END
		 
	END
	
	
	--Date
	IF (ISNULL(@FromDate,'') != '')
	BEGIN 
		 
         IF(@DateCondition = 'Not Equal To') BEGIN SET @WhereClause2 = @WhereClause2 + ' AND dtmDate <> ''' + @FromDate + '''' END
         IF(@DateCondition = 'Between' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND (dtmDate BETWEEN ''' + @FromDate + ''' AND ''' +  @ToDate + ''')'END
         IF(@DateCondition = 'Equal To' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND dtmDate = ''' + @FromDate + '''' END
	END
	
	--Tank Type
	IF (ISNULL(@FromTankType,'') != '')
	BEGIN 
		 
         IF(@TankTypeCondition = 'Not Equal To') BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strTankType <> ''' + @FromTankType + '''' END
         IF(@TankTypeCondition = 'Like' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strTankType LIKE ''%' + @FromTankType + '%''' END
         IF(@TankTypeCondition = 'Between' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND (strTankType BETWEEN ''' + @FromTankType + ''' AND ''' +  @ToTankType + ''')'END
         IF(@TankTypeCondition = 'Starts With' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strTankType LIKE ''' + @FromTankType + '%''' END
         IF(@TankTypeCondition = 'Ends With' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strTankType LIKE ''%' + @FromTankType + '''' END
         IF(@TankTypeCondition = 'Equal To' ) BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strTankType = ''' + @FromTankType + '''' END
		 
	END
	
	--***************************************** END For Main Query WHERE CLAUSE

---*******************BEGIN Get the GrandTotalTanks
CREATE TABLE #tmpGrandTotal (intGrandTotal INT)
SET @GrandTotalQuery = 
		'	INSERT INTO #tmpGrandTotal  
			SELECT TOP 1 intGrandTotal = COUNT(Z.strLocation)  
			FROM tblTMSite Z
			INNER JOIN tblTMCustomer Y ON Z.intCustomerID = Y.intCustomerID
			INNER JOIN vwcusmst X on Y.intCustomerNumber = X.A4GLIdentity
			INNER JOIN tblTMSiteDevice W ON Z.intSiteID =W.intSiteID
			INNER JOIN tblTMDevice V ON W.intDeviceId = V.intDeviceId
			INNER JOIN tblTMDeviceType U ON ISNULL(V.intDeviceTypeId,0) = ISNULL(U.intDeviceTypeId,-1)
			LEFT JOIN tblTMTankType T ON ISNULL(V.intTankTypeId,0) = ISNULL(T.intTankTypeId,-1)
			WHERE
				V.ysnAppliance = 0
				AND V.intInventoryStatusTypeId = (SELECT TOP 1 intInventoryStatusTypeId FROM tblTMInventoryStatusType WHERE strInventoryStatusType = ''Out'' AND ysnDefault = 1) 
				AND U.strDeviceType = ''Tank''  
				' + ISNULL(@WhereClause1,'') 

EXEC(@GrandTotalQuery)	

SET @intGrandTotalTanks = (SELECT TOP 1 intGrandTotal FROM #tmpGrandTotal)
print 'intGrandTotalTanks' 
print @intGrandTotalTanks

---*******************END  Get the GrandTotalTanks

---*******************BEGIN Get the GrandTotal With Check
CREATE TABLE #tmpGrandTotalWithCheck (intGrandTotalWithCheck INT)
SET @GrandTotalWithCheckQuery = 
		'	INSERT INTO #tmpGrandTotalWithCheck  
			SELECT TOP 1 intGrandTotalWithCheck = COUNT(Z.strLocation)  
			FROM tblTMSite Z
			INNER JOIN tblTMCustomer Y ON Z.intCustomerID = Y.intCustomerID
			INNER JOIN vwcusmst X on Y.intCustomerNumber = X.A4GLIdentity
			INNER JOIN tblTMSiteDevice W ON Z.intSiteID =W.intSiteID
			INNER JOIN tblTMDevice V ON W.intDeviceId = V.intDeviceId
			INNER JOIN tblTMDeviceType U ON ISNULL(V.intDeviceTypeId,0) = ISNULL(U.intDeviceTypeId,-1)
			LEFT JOIN tblTMTankType T ON ISNULL(V.intTankTypeId,0) = ISNULL(T.intTankTypeId,-1)
			WHERE
				V.ysnAppliance = 0
				AND V.intInventoryStatusTypeId = (SELECT TOP 1 intInventoryStatusTypeId FROM tblTMInventoryStatusType WHERE strInventoryStatusType = ''Out'' AND ysnDefault = 1) 
				AND U.strDeviceType = ''Tank''
				AND (EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE tblTMEvent.intDeviceId = V.intDeviceId AND tblTMEvent.intEventTypeID = (SELECT intEventTypeID FROM tblTMEventType WHERE strEventType = ''Event-003'' AND ysnDefault = 1)))  
				' + ISNULL(@WhereClause1,'') 

EXEC(@GrandTotalWithCheckQuery)	

SET @intGrandTotalWithCheck = (SELECT TOP 1 intGrandTotalWithCheck FROM #tmpGrandTotalWithCheck)

print 'intGrandTotalWithCheck' 
print @intGrandTotalWithCheck

---*******************END  Get the GrandTotal With Check
IF (@intGrandTotalTanks = 0)
BEGIN 
	SELECT 
	TOP 0
	  '' AS strCustomerFirstName
	  ,'' AS strCustomerLastName
	  ,'' AS strCustomerStatus
	  ,'' AS strCustomerNumber
	  ,'' AS strCustomerName
	  ,getdate() AS dtmDate
	  ,0 AS intSiteID
	  ,0 AS intSiteNumber
	  ,'' AS strSerialNumber
	  ,0 AS intLocationTotalTanks
	  ,'' AS strSiteStatus
	  ,'' AS strLocation
	  ,'' AS strOwnership
	  ,'' AS strTankType
	  ,0 AS ysnHasLeakGasCheck
	  ,0 AS intGrandTotalTanks
	  ,0.0 AS dblTankSize
	  ,0 AS intLocationTotalWithCheck
	  ,0 AS intGrandTotalWithCheck
	  ,0.0 AS dblGrandPercentWithCheck 
	  ,0.0 AS dblLocationPercentWithCheck
	  ,0.0 AS dblGrandPercentWithOutCheck
	  ,0.0 AS dblLocationPercentWithOutCheck
RETURN;
END
		
Set @Query = '
SELECT 
 *
 ,intGrandTotalTanks = ' + CAST(@intGrandTotalTanks AS NVARCHAR(20)) + '
 ,intGrandTotalWithCheck = ' + CAST(@intGrandTotalWithCheck AS NVARCHAR(20)) + '
 ,dblGrandPercentWithCheck = ' + CAST((CAST(@intGrandTotalWithCheck AS NUMERIC(5,2)) / CAST(@intGrandTotalTanks AS NUMERIC(5,2))) AS NVARCHAR(20))  + '
 ,dblGrandPercentWithOutCheck = ' + CAST(1 - (CAST(@intGrandTotalWithCheck AS NUMERIC(5,2)) / CAST(@intGrandTotalTanks AS NUMERIC(5,2))) AS NVARCHAR(20))  + '
 ,dblLocationPercentWithCheck = CAST(intLocationTotalWithCheck AS NUMERIC(5,2)) / CAST(intLocationTotalTanks AS NUMERIC(5,2))
 ,dblLocationPercentWithOutCheck = 1 - (CAST(intLocationTotalWithCheck AS NUMERIC(5,2)) / CAST(intLocationTotalTanks AS NUMERIC(5,2)))
FROM
(
	SELECT 
	 C.strLocation
	, B.vwcus_key AS strCustomerNumber
	, rtrim(ltrim(B.vwcus_last_name)) as strCustomerLastName
	, rtrim(ltrim(B.vwcus_first_name)) as strCustomerFirstName
	,(Case WHEN B.vwcus_first_name IS NULL OR B.vwcus_first_name = ''''  THEN
		RTRIM(B.vwcus_last_name)
		ELSE
		RTRIM(B.vwcus_last_name) + '', '' + RTRIM(B.vwcus_first_name)
	 END) as strCustomerName
	, C.intSiteID
	, C.intSiteNumber
	, E.strSerialNumber
	, E.dblTankSize
	, E.strOwnership
	,(Select Top 1 tt.strTankType From tblTMTankType tt Where tt.intTankTypeId = E.intTankTypeId) AS [strTankType]
	, (Case C.ysnActive
		When 1 then
			''Active''
		When 0 then
			''Inactive''
		End) as SiteStatus
	, (Case B.vwcus_active_yn
		When ''Y'' then
			''Active''
		When ''N'' then
			''Inactive''
		End) as CustomerStatus
	,(CASE WHEN (EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE tblTMEvent.intSiteID = C.intSiteID 
															AND intDeviceId = E.intDeviceId
															AND tblTMEvent.intEventTypeID = (SELECT intEventTypeID FROM tblTMEventType WHERE strEventType = ''Event-003'' AND ysnDefault = 1)))
					THEN 1 ELSE 0 END)as ysnHasLeakGasCheck
	,(SELECT Top 1 dtmDate FROM tblTMEvent WHERE tblTMEvent.intDeviceId = D.intDeviceId AND tblTMEvent.intEventTypeID = (SELECT intEventTypeID FROM tblTMEventType WHERE strEventType = ''Event-003'' AND ysnDefault = 1) order by dtmDate Desc)as dtmDate
	,intLocationTotalTanks = (	SELECT TOP 1 COUNT(Z.strLocation)
						FROM tblTMSite Z
						INNER JOIN tblTMCustomer Y ON Z.intCustomerID = Y.intCustomerID
						INNER JOIN vwcusmst X on Y.intCustomerNumber = X.A4GLIdentity
						INNER JOIN tblTMSiteDevice W ON Z.intSiteID =W.intSiteID
						INNER JOIN tblTMDevice V ON W.intDeviceId = V.intDeviceId
						INNER JOIN tblTMDeviceType U ON ISNULL(V.intDeviceTypeId,0) = ISNULL(U.intDeviceTypeId,-1)
						LEFT JOIN tblTMTankType T ON ISNULL(V.intTankTypeId,0) = ISNULL(T.intTankTypeId,-1)
						WHERE
							V.ysnAppliance = 0
							AND V.intInventoryStatusTypeId = (SELECT TOP 1 intInventoryStatusTypeId FROM tblTMInventoryStatusType WHERE strInventoryStatusType = ''Out'' AND ysnDefault = 1) 
							AND U.strDeviceType = ''Tank'' 
							AND Z.strLocation = C.strLocation 
							' + ISNULL(@WhereClause1,'') + '
					 )
	,intLocationTotalWithCheck = (	SELECT TOP 1 COUNT(Z.strLocation)
						FROM tblTMSite Z
						INNER JOIN tblTMCustomer Y ON Z.intCustomerID = Y.intCustomerID
						INNER JOIN vwcusmst X on Y.intCustomerNumber = X.A4GLIdentity
						INNER JOIN tblTMSiteDevice W ON Z.intSiteID =W.intSiteID
						INNER JOIN tblTMDevice V ON W.intDeviceId = V.intDeviceId
						INNER JOIN tblTMDeviceType U ON ISNULL(V.intDeviceTypeId,0) = ISNULL(U.intDeviceTypeId,-1)
						LEFT JOIN tblTMTankType T ON ISNULL(V.intTankTypeId,0) = ISNULL(T.intTankTypeId,-1)
						WHERE
							V.ysnAppliance = 0
							AND V.intInventoryStatusTypeId = (SELECT TOP 1 intInventoryStatusTypeId FROM tblTMInventoryStatusType WHERE strInventoryStatusType = ''Out'' AND ysnDefault = 1) 
							AND U.strDeviceType = ''Tank'' 
							AND Z.strLocation = C.strLocation 
							AND (EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE tblTMEvent.intDeviceId = V.intDeviceId AND tblTMEvent.intEventTypeID = (SELECT intEventTypeID FROM tblTMEventType WHERE strEventType = ''Event-003'' AND ysnDefault = 1)))
							' + ISNULL(@WhereClause1,'') + '
					 )
	FROM tblTMSite C
	INNER JOIN tblTMCustomer A ON C.intCustomerID = A.intCustomerID
	INNER JOIN vwcusmst B on A.intCustomerNumber = B.A4GLIdentity
	INNER JOIN tblTMSiteDevice D ON C.intSiteID =D.intSiteID
	INNER JOIN tblTMDevice E ON D.intDeviceId = E.intDeviceId 
	INNER JOIN tblTMDeviceType G ON ISNULL(E.intDeviceTypeId,0) = ISNULL(G.intDeviceTypeId,-1) 
	WHERE
	E.ysnAppliance = 0
	and E.intInventoryStatusTypeId = (SELECT TOP 1 intInventoryStatusTypeId FROM tblTMInventoryStatusType WHERE strInventoryStatusType = ''Out'' AND ysnDefault = 1) 
	AND G.strDeviceType = ''Tank''
) Z 
where	ysnHasLeakGasCheck = 1 '
	
		
	--Append main Where Clause to main query
	IF(ISNULL(@WhereClause2,'') != '')
	BEGIN SET @Query = @Query + @WhereClause2 END
	
	EXEC(@Query)
	
	
	
	
END

GO

GO
PRINT 'END OF CREATING uspTMGetConsumptionWithGasCheck SP'
GO