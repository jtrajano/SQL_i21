
GO
PRINT 'START OF CREATING uspTMDeliveryFillReport SP'
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMDeliveryFillReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspTMDeliveryFillReport]
GO


CREATE PROCEDURE [dbo].[uspTMDeliveryFillReport](
	@xmlParam NVARCHAR(MAX)=null   )
AS
BEGIN
	
		--	DECLARE @xmlParam NVARCHAR(MAX)
		--	SET @xmlParam=  '<?xml version="1.0" 
		--encoding="utf-16"?><xmlparam><filters><filter><fieldname>strLocation</fieldname><condition>Between</condition><from>074</from><to>074</to><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strFillMethod</fieldname><condition>Between</condition><from 
		--/><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>dblEstimatedPercentLeft</fieldname><condition>Less Than Or Equal</condition><from>30</from><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Decimal</datatype></filter><filter><fieldname>strLocation</fieldname><condition>Between</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strDriverId</fieldname><condition>Between</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strProductId</fieldname><condition>Between</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>strRouteId</fieldname><condition>Between</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>intNextDeliveryDegreeDay</fieldname><condition>Less Than Or Equal</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Integer</datatype></filter><filter><fieldname>dtmNextDeliveryDate</fieldname><condition>Between</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>DateTime</datatype></filter><filter><fieldname>dtmRequestedDate</fieldname><condition>Between</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>DateTime</datatype></filter><filter><fieldname>strFillMethod</fieldname><condition>Equal To</condition><from /><to 
		--/><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>String</datatype></filter><filter><fieldname>dblQuantity</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Decimal</datatype></filter><filter><fieldname>dblEstimatedPercentLeft</fieldname><condition>Less Than Or Equal</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Decimal</datatype></filter><filter><fieldname>dtmForecastedDelivery</fieldname><condition>Between</condition><from /><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>DateTime</datatype></filter><filter><fieldname>ysnOnHold</fieldname><condition>Equal To</condition><from>False</from><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Bool</datatype></filter><filter><fieldname>ysnPending</fieldname><condition>Equal To</condition><from>False</from><to /><join>And</join><begingroup>0</begingroup><endgroup>0</endgroup><datatype>Bool</datatype></filter></filters><options><option><name>List Unit Price</name><enable>True</enable></option><option><name>Print Delivery Address</name><enable>True</enable></option><option><name>Print Tank Info</name><enable>True</enable></option><option><name>Print Customer A/R Balance</name><enable>True</enable></option><option><name>Print Consumption Site Instructions</name><enable>True</enable></option><option><name>Print Consumption Site Comments</name><enable>True</enable></option><option><name>Print Contracts</name><enable>True</enable></option><option><name>Print Regulator Info</name><enable>True</enable></option><option><name>Print On Hold Detail​</name><enable>True</enable></option><option><name>Include Consumption Site in the same Fill Group</name><enable>True</enable></option></options></xmlparam>';

	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
		SELECT 
			intCustomerID = 0
			,dblProductCost = 0.0
			,agcus_last_name = ''
			,agcus_first_name = ''
			,CustomerName = ''
			,agcus_phone = ''
			,agcus_key = ''
			,agcus_tax_state = ''
			,agcus_ar_per1 = 0.0
			,agcus_cred_limit = 0.0
			,agcus_last_stmt_bal = 0.0
			,agcus_budget_amt_due = 0.0
			,agcus_ar_future = 0.0
			,agcus_prc_lvl = 0
			,Terms = ''
			,Credits = 0.0
			,TotalPast = 0.0
			,ARBalance = 0.0
			,dblPastCredit = 0.0
			,intSiteNumber = 0
			,dblLastDeliveredGal = 0.0
			,strSequenceID = ''
			,intLastDeliveryDegreeDay = 0
			,strSiteAddress = ''
			,dtmOnHoldEndDate = GetDate()
			,ysnOnHold = CAST(0 AS BIT)
			,strHoldReason =''
			,strOnHold = ''
			,intFillMethodId = 1
			,strCity = ''
			,strState = ''
			, strZipCode = ''
			, strComment = ''
			, strInstruction = ''
			, dblDegreeDayBetweenDelivery = 0.0
			, dblTotalCapacity = 0.0
			, dblTotalReserve = 0.0
			, strSiteDescription = ''
			, dblLastGalsInTank = 0.0
			, dtmLastDeliveryDate = GETDATE()
			, intSiteID = 0
			, dblEstimatedPercentLeft = 0.0
			, dtmNextDeliveryDate = GETDATE()
			, intNextDeliveryDegreeDay = 0
			, [SiteLabel] = ''
			, dblDailyUse = 0.0
			, strFillGroupCode = ''
			, strDescription = ''
			, ysnActive = ''
			, intFillGroupId = 0
			, strDriverName = ''
			, strDriverId = ''
			, dtmRequestedDate = GETDATE()
			, dblQuantity = 0.0
			, strProductId = ''
			, strProductDescription = ''
			, strRouteId = ''
			, strFillMethod = ''
			, strBetweenDlvry = ''		
			, strLocation = ''
			, dtmForecastedDelivery = GETDATE()
			, ysnPending = CAST(0 AS BIT)
			, vwitm_class = ''
			,dtmCallInDate = getDate()
			,dblCallEntryPrice = 0.0
			,dblCallEntryMinimumQuantity = 0.0
		RETURN;
	END
	ELSE
	BEGIN
		DECLARE @idoc INT
		DECLARE @whereClause NVARCHAR(MAX)
		DECLARE @whereClause1 NVARCHAR(MAX)
		
		SET @whereClause = ''

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
		
		DECLARE @temp_params TABLE ([fieldname] NVARCHAR(50)
				, condition NVARCHAR(20)      
				, [from] NVARCHAR(50)
				, [to] NVARCHAR(50)
				, [join] NVARCHAR(10)
				, [begingroup] NVARCHAR(50)
				, [endgroup] NVARCHAR(50) 
				, [datatype] NVARCHAR(50)) 
        
		INSERT INTO @temp_params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH ([fieldname] NVARCHAR(50)
			, condition NVARCHAR(20)
			, [from] NVARCHAR(50)
			, [to] NVARCHAR(50)
			, [join] NVARCHAR(10)
			, [begingroup] NVARCHAR(50)
			, [endgroup] NVARCHAR(50)
			, [datatype] NVARCHAR(50))
				
		--Location
		DECLARE @FromLocation NVARCHAR(50)
		DECLARE @ToLocation NVARCHAR(50)

		SELECT TOP 1
			@FromLocation = [from]
			,@ToLocation = [to]
		FROM @temp_params WHERE [fieldname] = 'strLocation'
		IF (ISNULL(@FromLocation,'') <> '')
		BEGIN
			SET @whereClause = ' WHERE (strLocation BETWEEN ''' + @FromLocation + ''' AND ''' + @ToLocation + ''')'
		END
		
		--Driver ID
		DECLARE @FromDriverID NVARCHAR(50)
		DECLARE @ToDriverID NVARCHAR(50)
		SELECT TOP 1 @FromDriverID = [from]
			  ,@ToDriverID = [to]
		FROM @temp_params where [fieldname] = 'strDriverId'
		IF (ISNULL(@FromDriverID,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (strDriverId BETWEEN ''' + @FromDriverID + ''' AND ''' + @ToDriverID + ''')'
		END
		
		
		--Product ID
		DECLARE @FromProductId NVARCHAR(50)
		DECLARE @ToProductId NVARCHAR(50)
		SELECT  TOP 1 @FromProductId = [from]
			  ,@ToProductId = [to]
		FROM @temp_params where [fieldname] = 'strProductId'
		IF (ISNULL(@FromProductId,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (strProductId BETWEEN ''' + @FromProductId + ''' AND ''' + @ToProductId + ''')'
		END
		
		--Route ID
		DECLARE @FromRouteId NVARCHAR(50)
		DECLARE @ToRouteId NVARCHAR(50)
		SELECT  TOP 1 @FromRouteId = [from]
			  ,@ToRouteId = [to]
		FROM @temp_params where [fieldname] = 'strRouteId'
		IF (ISNULL(@FromRouteId,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (strRouteId BETWEEN ''' + @FromRouteId + ''' AND ''' + @ToRouteId + ''')'
		END
		
		--Next Delivery Degree Day
		DECLARE @FromNextDeliveryDegreeDay NVARCHAR(50)
		DECLARE @ToNextDeliveryDegreeDay NVARCHAR(50)
		DECLARE @ConditionNextDeliveryDegreeDay NVARCHAR(20)
		SELECT  TOP 1 @FromNextDeliveryDegreeDay = [from]
			  ,@ToNextDeliveryDegreeDay = [to]
			  ,@ConditionNextDeliveryDegreeDay = [condition]
		FROM @temp_params where [fieldname] = 'intNextDeliveryDegreeDay'
		IF (ISNULL(@FromNextDeliveryDegreeDay,'') <> '')
		BEGIN
			IF(@ConditionNextDeliveryDegreeDay = 'Between')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (intNextDeliveryDegreeDay BETWEEN ' + @FromNextDeliveryDegreeDay + ' AND ' + @ToNextDeliveryDegreeDay + ')'
			END
			ELSE IF(@ConditionNextDeliveryDegreeDay = 'Less Than Or Equal')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (intNextDeliveryDegreeDay <= ' + @FromNextDeliveryDegreeDay + ') '
			END
		END
		
		--Next Julian Delivery
		DECLARE @FromNextJulianDelivery NVARCHAR(50)
		DECLARE @ToNextJulianDelivery NVARCHAR(50)
		SELECT  TOP 1 @FromNextJulianDelivery = [from]
			  ,@ToNextJulianDelivery = [to]
		FROM @temp_params where [fieldname] = 'dtmNextDeliveryDate'
		IF (ISNULL(@FromNextJulianDelivery,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (DATEADD(dd, DATEDIFF(dd, 0, dtmNextDeliveryDate), 0) BETWEEN ''' + @FromNextJulianDelivery + ''' AND ''' + @ToNextJulianDelivery + ''')'
		END
		
		--Requested Date
		DECLARE @FromRequestedDate NVARCHAR(50)
		DECLARE @ToRequestedDate NVARCHAR(50)
		SELECT  TOP 1 @FromRequestedDate = [from]
			  ,@ToRequestedDate = [to]
		FROM @temp_params where [fieldname] = 'dtmRequestedDate'
		IF (ISNULL(@FromRequestedDate,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (DATEADD(dd, DATEDIFF(dd, 0, dtmRequestedDate), 0) BETWEEN ''' + @FromRequestedDate + ''' AND ''' + @ToRequestedDate + ''')'
		END
		
		--Fill Method ID
		DECLARE @FromFillMethod NVARCHAR(50)
		DECLARE @ToFillMethod NVARCHAR(50)
		SELECT  TOP 1 @FromFillMethod = [from]
			  ,@ToFillMethod = [to]
		FROM @temp_params where [fieldname] = 'strFillMethod'
		IF (ISNULL(@FromFillMethod,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (strFillMethod = ''' + @FromFillMethod + ''')'
		END
		
		--Quantity
		DECLARE @FromCalculatedQuantity NVARCHAR(50)
		DECLARE @ToCalculatedQuantity NVARCHAR(50)
		SELECT  TOP 1 @FromCalculatedQuantity = [from]
			  ,@ToCalculatedQuantity = [to]
		FROM @temp_params where [fieldname] = 'dblQuantity'
		IF (ISNULL(@FromCalculatedQuantity,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (dblQuantity BETWEEN ' + @FromCalculatedQuantity + ' AND ' + @ToCalculatedQuantity + ')'
		END
		
		--Estimated Percent Left
		DECLARE @FromEstimatedPercentLeft NVARCHAR(50)
		DECLARE @ToEstimatedPercentLeft NVARCHAR(50)
		DECLARE @ConditionEstimatedPercentLeft NVARCHAR(20)
		SELECT  TOP 1 @FromEstimatedPercentLeft = [from]
			  ,@ToEstimatedPercentLeft = [to]
			  ,@ConditionEstimatedPercentLeft = [condition]
		FROM @temp_params where [fieldname] = 'dblEstimatedPercentLeft'
		IF (ISNULL(@FromEstimatedPercentLeft,'') <> '')
		BEGIN
			IF(@ConditionEstimatedPercentLeft = 'Between')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (dblEstimatedPercentLeft BETWEEN ' + @FromEstimatedPercentLeft + ' AND ' + @ToEstimatedPercentLeft + ')'
			END
			ELSE IF(@ConditionEstimatedPercentLeft = 'Less Than Or Equal')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (dblEstimatedPercentLeft <= ' + @FromEstimatedPercentLeft + ') '
			END
		END
		
		--Forecaster Delivery Date
		DECLARE @FromForecastedDelivery NVARCHAR(50)
		DECLARE @ToForecastedDelivery NVARCHAR(50)
		SELECT  TOP 1 @FromForecastedDelivery = [from]
			  ,@ToForecastedDelivery = [to]
		FROM @temp_params where [fieldname] = 'dtmForecastedDelivery'
		IF (ISNULL(@FromForecastedDelivery,'') <> '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + '(DATEADD(dd, DATEDIFF(dd, 0, dtmForecastedDelivery), 0) BETWEEN ''' + @FromForecastedDelivery + ''' AND ''' + @ToForecastedDelivery + ''')'
		END
		
		--On Hold
		DECLARE @FromOnHold NVARCHAR(50)
		DECLARE @ConditionOnHold NVARCHAR(20)
		SELECT  TOP 1 @FromOnHold = CASE WHEN ([from] = '1' OR [from] = 'True') THEN 1 
										WHEN ([from] = '0' OR [from] = 'False') THEN 0
										ELSE [from] END
			  ,@ConditionOnHold = [condition]
		FROM @temp_params where [fieldname] = 'ysnOnHold'
		IF (ISNULL(@FromOnHold,'') <> '')
		BEGIN
			IF(@ConditionOnHold = 'Equal To')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + ' (ysnOnHold = ' + @FromOnHold + ')'
			END
			ELSE IF(@ConditionOnHold = 'Not Equal To')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + '(ysnOnHold <> ' + @FromOnHold + ')'
			END
		END
	
		--On Hold
		DECLARE @FromPending NVARCHAR(50)
		DECLARE @ConditionPending NVARCHAR(20)
		SELECT  TOP 1 @FromPending = CASE WHEN ([from] = '1' OR [from] = 'True') THEN 1 
										WHEN ([from] = '0' OR [from] = 'False') THEN 0
										ELSE [from] END
			  ,@ConditionPending = [condition]
		FROM @temp_params where [fieldname] = 'ysnPending'
		IF (ISNULL(@FromPending,'') <> '')
		BEGIN
			IF(@ConditionPending = 'Equal To')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE '' END + ' AND (ysnPending = ' + @FromPending + ')'
			END
			ELSE IF(@ConditionPending = 'Not Equal To')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE '' END + ' AND (ysnPending <> ' + @FromPending + ')'
			END
		END
		
		EXEC('
		SELECT
			*
		INTO #tmpDeliveryFill
		FROM [vyuTMDeliveryFillReport] ' + @whereClause + '
		
		
		
		SELECT 
			*
			,COALESCE(dblCallEntryPrice,(SELECT MAX(dblPrice) FROM dbo.[fnTMGetSpecialPricingPriceTable](
									agcus_key
									,strProductId
									,CAST(strLocation AS NVARCHAR(5))
									,vwitm_class
									,(CASE WHEN dtmCallInDate IS NULL THEN GETDATE() ELSE dtmCallInDate END)
									,(CASE WHEN dblCallEntryMinimumQuantity IS NULL THEN COALESCE(dblQuantity,1.00) ELSE dblCallEntryMinimumQuantity END)
									,NULL,intSiteID))) AS dblProductCost
		FROM #tmpDeliveryFill
		OPTION (RECOMPILE)
		')
		
	END

END
GO

GO
PRINT 'END OF CREATING uspTMDeliveryFillReport SP'
GO