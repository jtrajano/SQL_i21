CREATE PROCEDURE [dbo].[uspCFInvoiceReport](
	@xmlParam NVARCHAR(MAX)=null
)
AS
BEGIN
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
	SELECT 
		 intCustomerGroupId		   = 0
		,intTransactionId		   = 0
		,intInvoiceId			   = 0
		,intProductId			   = 0
		,intCardId				   = 0
		,intOdometer			   = 0
		,EXPR18					   = 0
		,intAccountId			   = 0
		,intInvoiceCycle		   = 0
		,intOdometerAging		   = 0
		,strGroupName			   = ''
		,strCustomerNumber		   = ''
		,strDepartment			   = ''
		,strShipTo				   = ''
		,strBillTo				   = ''
		,strCompanyName			   = ''
		,strCompanyAddress		   = ''
		,strType				   = ''
		,strCustomerName		   = ''
		,strLocationName		   = ''
		,strInvoiceReportNumber	   = ''
		,strTempInvoiceReportNumber= ''
		,strInvoiceNumber		   = ''
		,strTransactionId		   = ''
		,strTransactionType		   = ''
		,strMiscellaneous		   = ''
		,strName				   = ''
		,strCardNumber			   = ''
		,strCardDescription		   = ''
		,strNetwork				   = ''
		,strPrimarySortOptions	   = ''
		,strSecondarySortOptions   = ''
		,strPrintRemittancePage	   = ''
		,strPrintPricePerGallon	   = ''
		,strPrintSiteAddress	   = ''
		,strSiteNumber			   = ''
		,strSiteName			   = ''
		,strProductNumber		   = ''
		,strItemNo				   = ''
		,strDescription			   = ''
		,strVehicleNumber		   = ''
		,strVehicleDescription	   = ''
		,dblTotalMiles			   = 0.0
		,dblQuantity			   = 0.0
		,dblCalculatedTotalAmount  = 0.0
		,dblOriginalTotalAmount	   = 0.0
		,dblCalculatedGrossAmount  = 0.0
		,dblOriginalGrossAmount	   = 0.0
		,dblCalculatedNetAmount	   = 0.0
		,dblOriginalNetAmount	   = 0.0
		,dblMargin				   = 0.0
		,dblTotalTax			   = 0.0
		,dtmDate				   = GetDate()
		,dtmPostDate			   = GetDate()
		,dtmTransactionDate		   = GetDate()
		,ysnInvalid				   = CAST(0 AS BIT)
		,ysnPosted				   = CAST(0 AS BIT)
		,ysnPrintMiscellaneous	   = CAST(0 AS BIT)
		,ysnSummaryByCard		   = CAST(0 AS BIT)
		,ysnSummaryByDepartment	   = CAST(0 AS BIT)
		,ysnSummaryByMiscellaneous = CAST(0 AS BIT)
		,ysnSummaryByProduct	   = CAST(0 AS BIT)
		,ysnSummaryByVehicle	   = CAST(0 AS BIT)
		,ysnPrintTimeOnInvoices	   = CAST(0 AS BIT)
		,ysnPrintTimeOnReports	   = CAST(0 AS BIT)
		,strSiteCity			   = ''
		,strSiteAddress			   = ''
		,strState				   = ''
		,strSiteType			   = ''
		RETURN;
	END
	ELSE
	BEGIN 
		DECLARE @idoc INT
		DECLARE @whereClause NVARCHAR(MAX)
		
		DECLARE @From NVARCHAR(MAX)
		DECLARE @To NVARCHAR(MAX)
		DECLARE @Condition NVARCHAR(MAX)
		DECLARE @Fieldname NVARCHAR(MAX)

		DECLARE @tblCFFieldList TABLE
		(
			[intFieldId]   INT , 
			[strFieldId]   NVARCHAR(MAX)   
		)
		
		SET @whereClause = ''

		INSERT INTO @tblCFFieldList(
			 [intFieldId]
			,[strFieldId]
		)
		SELECT 
			 RecordKey
			,Record
		FROM [fnCFSplitString]('intAccountId,strNetwork,strCustomerName,dtmTransactionDate,dtmPostedDate,strInvoiceCycle,strInvoiceReportNumber',',') 

		--READ XML
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam

		--TEMP TABLE FOR PARAMETERS
		DECLARE @temp_params TABLE (
			 [fieldname] NVARCHAR(MAX)
			,[condition] NVARCHAR(MAX)      
			,[from] NVARCHAR(MAX)
			,[to] NVARCHAR(MAX)
			,[join] NVARCHAR(MAX)
			,[begingroup] NVARCHAR(MAX)
			,[endgroup] NVARCHAR(MAX) 
			,[datatype] NVARCHAR(MAX)
		) 

		--XML DATA TO TABLE
		INSERT INTO @temp_params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH ([fieldname] NVARCHAR(MAX)
			, [condition] NVARCHAR(MAX)
			, [from] NVARCHAR(MAX)
			, [to] NVARCHAR(MAX)
			, [join] NVARCHAR(MAX)
			, [begingroup] NVARCHAR(MAX)
			, [endgroup] NVARCHAR(MAX)
			, [datatype] NVARCHAR(MAX))



		DECLARE @intCounter INT
		DECLARE @strField	NVARCHAR(MAX)

		WHILE (EXISTS(SELECT 1 FROM @tblCFFieldList))
		BEGIN
			SELECT @intCounter = [intFieldId] FROM @tblCFFieldList
			SELECT @strField = [strFieldId] FROM @tblCFFieldList WHERE [intFieldId] = @intCounter
				
		--MAIN LOOP			
		SELECT TOP 1
			 @From = [from]
			,@To = [to]
			,@Condition = [condition]
			,@Fieldname = [fieldname]
		FROM @temp_params WHERE [fieldname] = @strField
		IF (UPPER(@Condition) = 'BETWEEN')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
			' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
		END
		ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','='))
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
			' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
		END
		ELSE IF (UPPER(@Condition) = 'IN')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
			' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
		END
		ELSE IF (UPPER(@Condition) = 'GREATER THAN')
		BEGIN
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'
			END
		END
		ELSE IF (UPPER(@Condition) = 'LESS THAN')
		BEGIN
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'
			END
		END

		SET @From = ''
		SET @To = ''
		SET @Condition = ''
		SET @Fieldname = ''


		--MAIN LOOP

			DELETE FROM @tblCFFieldList WHERE [intFieldId] = @intCounter
		END

		DECLARE @strPrintTimeStamp NVARCHAR(MAX)
		SELECT TOP 1
			 @strPrintTimeStamp = [from]
		FROM @temp_params WHERE [fieldname] = 'strPrintTimeStamp'


		DECLARE @InvoiceDate NVARCHAR(MAX)
		SELECT TOP 1
			 @InvoiceDate = [from]
		FROM @temp_params WHERE [fieldname] = 'dtmInvoiceDate'
		

		--NON DISTRIBUTION LIST
		SELECT TOP 1
			 @From = [from]
			,@To = [to]
			,@Condition = [condition]
			,@Fieldname = [fieldname]
		FROM @temp_params WHERE [fieldname] = 'ysnNonDistibutionList'

		IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'TRUE' OR @From = 1))
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				N' NOT (strEmailDistributionOption like ''%CF Invoice%'' AND (strEmail IS NOT NULL AND strEmail != ''''))'
		END

		SET @From = ''
		SET @To = ''
		SET @Condition = ''
		SET @Fieldname = ''

		--INCLUDE PRINTED TRANSACTION
		SELECT TOP 1
			 @From = [from]
			,@To = [to]
			,@Condition = [condition]
			,@Fieldname = [fieldname]
		FROM @temp_params WHERE [fieldname] = 'ysnIncludePrintedTransaction'

		DECLARE @tblCFTableCardIds TABLE ([intAccountId]	INT)
		DECLARE @tblCFTableTransationIds TABLE ([intTransactionId]	INT)
		DECLARE @tblCFFilterIds TABLE ([intTransactionId]	INT)
		DECLARE @CFID NVARCHAR(MAX)
		DECLARE @tblCFTempTableQuery nvarchar(MAX)


		DECLARE @intTempCardCounter INT
		DECLARE @intTempCardId	INT
		DECLARE @tblCFInvoiceNunber TABLE (
			[intAccountId]	INT,
			[strInvoiceNumber]	NVARCHAR(MAX)
		)

		---------GET DISTINCT CARD ID---------
		SET @tblCFTempTableQuery = 'SELECT DISTINCT intAccountId FROM vyuCFInvoiceReport ' + @whereClause

		INSERT INTO  @tblCFTableCardIds (intAccountId)
		EXEC (@tblCFTempTableQuery)
		---------GET DISTINCT CARD ID---------

		---------CREATE ID WITH INVOICE NUMBER--------
		WHILE (EXISTS(SELECT 1 FROM @tblCFTableCardIds))
		BEGIN

			SELECT @intTempCardCounter = [intAccountId] FROM @tblCFTableCardIds
			SELECT @intTempCardId = [intAccountId] FROM @tblCFTableCardIds WHERE [intAccountId] = @intTempCardCounter

			EXEC uspSMGetStartingNumber 53, @CFID OUT

			INSERT INTO @tblCFInvoiceNunber (
				[intAccountId]
				,[strInvoiceNumber]
			)
			VALUES(
				@intTempCardId
				,@CFID
			)

			DELETE FROM @tblCFTableCardIds WHERE [intAccountId] = @intTempCardCounter

			-----------UPDATE INVOICE REPORT NUMBER ID---------
			--EXEC uspSMGetStartingNumber 53, @CFID OUT
			--IF(@CFID IS NOT NULL)
			--BEGIN
				
			--	EXEC('UPDATE tblCFTransaction SET strInvoiceReportNumber = ' + '''' + @CFID + '''' + ' WHERE intCardId = ' + @intTempAccountId)
			--END
			-----------UPDATE INVOICE REPORT NUMBER ID---------

		END
		---------CREATE ID WITH INVOICE NUMBER--------

		DECLARE @intTempTransactionCounter INT
		DECLARE @intTempTransactionId INT
		DECLARE @strInvoiceNumber NVARCHAR(MAX)
		IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'FALSE' OR @From = 0))
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' ( strInvoiceReportNumber  IS NULL )'

			---------GET DISTINCT TRANSACTION ID---------
			SET @tblCFTempTableQuery = 'SELECT DISTINCT intTransactionId FROM vyuCFInvoiceReport ' + @whereClause

			INSERT INTO  @tblCFTableTransationIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)

			INSERT INTO  @tblCFFilterIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)
			---------GET DISTINCT TRANSACTION ID---------


			WHILE (EXISTS(SELECT 1 FROM @tblCFTableTransationIds))
			BEGIN

				SELECT @intTempTransactionCounter = [intTransactionId] FROM @tblCFTableTransationIds
				SELECT @intTempTransactionId = [intTransactionId] FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
				SELECT @strInvoiceNumber = strInvoiceNumber from @tblCFInvoiceNunber where intAccountId = (SELECT TOP 1 cfCardAcct.intAccountId FROM tblCFTransaction as cfTrans
																											INNER JOIN vyuCFCardAccount as cfCardAcct
																											ON cfTrans.intCardId = cfCardAcct.intCardId
																											WHERE cfTrans.intTransactionId = @intTempTransactionId)

				---------UPDATE INVOICE REPORT NUMBER ID---------
				IF(@CFID IS NOT NULL)
				BEGIN
					EXEC('UPDATE tblCFTransaction SET strTempInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					EXEC('UPDATE tblCFTransaction SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					EXEC('UPDATE tblCFTransaction SET dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
				END
				---------UPDATE INVOICE REPORT NUMBER ID---------


				DELETE FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
			END

		END
		ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'TRUE' OR @From = 1))
		BEGIN

			---------GET DISTINCT TRANSACTION ID---------
			SET @tblCFTempTableQuery = 'SELECT DISTINCT intTransactionId FROM vyuCFInvoiceReport ' + @whereClause

			INSERT INTO  @tblCFTableTransationIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)

			INSERT INTO  @tblCFFilterIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)
			---------GET DISTINCT TRANSACTION ID---------

			WHILE (EXISTS(SELECT 1 FROM @tblCFTableTransationIds))
			BEGIN

				SELECT @intTempTransactionCounter = [intTransactionId] FROM @tblCFTableTransationIds
				SELECT @intTempTransactionId = [intTransactionId] FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
				SELECT @strInvoiceNumber = strInvoiceNumber from @tblCFInvoiceNunber where intAccountId = (SELECT TOP 1 cfCardAcct.intAccountId FROM tblCFTransaction as cfTrans
																											INNER JOIN vyuCFCardAccount as cfCardAcct
																											ON cfTrans.intCardId = cfCardAcct.intCardId
																											WHERE cfTrans.intTransactionId = @intTempTransactionId)

				---------UPDATE INVOICE REPORT NUMBER ID---------
				IF(@CFID IS NOT NULL)
				BEGIN

					EXEC('UPDATE tblCFTransaction SET strTempInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					EXEC('UPDATE tblCFTransaction SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					EXEC('UPDATE tblCFTransaction SET dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)

				END
				---------UPDATE INVOICE REPORT NUMBER ID---------


				DELETE FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
			END

		END
		ELSE
		BEGIN
			---------GET DISTINCT TRANSACTION ID---------
			SET @tblCFTempTableQuery = 'SELECT DISTINCT intTransactionId FROM vyuCFInvoiceReport ' + @whereClause

			INSERT INTO  @tblCFFilterIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)
			---------GET DISTINCT TRANSACTION ID---------
		END

		--EXEC('SELECT * FROM vyuCFInvoiceReport ' + @whereClause)
		--SELECT * FROM vyuCFInvoiceReport where intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)

		INSERT INTO tblCFInvoiceReportTempTable (
		intCustomerGroupId			
		,intTransactionId			
		,intOdometer				
		,intOdometerAging			
		,intInvoiceId				
		,intProductId				
		,intCardId					
		,main.intAccountId				
		,intInvoiceCycle			
		,intSubAccountId			
		,intCustomerId				
		,strGroupName				
		,strCustomerNumber			
		,strShipTo					
		,strBillTo					
		,strCompanyName				
		,strCompanyAddress			
		,strType					
		,strCustomerName			
		,strLocationName			
		,main.strInvoiceNumber			
		,strTransactionId			
		,strTransactionType			
		,strInvoiceReportNumber		
		,strTempInvoiceReportNumber	
		,strMiscellaneous			
		,strName					
		,strCardNumber				
		,strCardDescription			
		,strNetwork					
		,strInvoiceCycle			
		,strPrimarySortOptions		
		,strSecondarySortOptions	
		,strPrintRemittancePage		
		,strPrintPricePerGallon		
		,strPrintSiteAddress		
		,strSiteNumber				
		,strSiteName				
		,strProductNumber			
		,strItemNo					
		,strDescription				
		,strVehicleNumber			
		,strVehicleDescription		
		,strTaxState				
		,strDepartment				
		,strSiteType				
		,strState					
		,strSiteAddress				
		,strSiteCity				
		,strPrintTimeStamp			
		,strEmailDistributionOption	
		,strEmail					
		,dtmTransactionDate			
		,dtmDate					
		,dtmPostedDate				
		,dblTotalMiles				
		,dblQuantity				
		,dblCalculatedTotalAmount	
		,dblOriginalTotalAmount		
		,dblCalculatedGrossAmount	
		,dblOriginalGrossAmount		
		,dblCalculatedNetAmount		
		,dblOriginalNetAmount		
		,dblMargin					
		,dblTotalTax				
		,dblTotalSST				
		,dblTaxExceptSST			
		,dblInvoiceTotal			
		,ysnPrintMiscellaneous		
		,ysnSummaryByCard			
		,ysnSummaryByDepartment		
		,ysnSummaryByMiscellaneous	
		,ysnSummaryByProduct		
		,ysnSummaryByVehicle		
		,ysnPrintTimeOnInvoices		
		,ysnPrintTimeOnReports		
		,ysnInvalid					
		,ysnPosted)
		SELECT
		 intCustomerGroupId			
		,intTransactionId			
		,intOdometer				
		,intOdometerAging			
		,intInvoiceId				
		,intProductId				
		,intCardId					
		,main.intAccountId				
		,intInvoiceCycle			
		,intSubAccountId			
		,intCustomerId				
		,strGroupName				
		,strCustomerNumber			
		,strShipTo					
		,strBillTo					
		,strCompanyName				
		,strCompanyAddress			
		,strType					
		,strCustomerName			
		,strLocationName			
		,main.strInvoiceNumber			
		,strTransactionId			
		,strTransactionType			
		,strInvoiceReportNumber		
		,strTempInvoiceReportNumber	
		,strMiscellaneous			
		,strName					
		,strCardNumber				
		,strCardDescription			
		,strNetwork					
		,strInvoiceCycle			
		,strPrimarySortOptions		
		,strSecondarySortOptions	
		,strPrintRemittancePage		
		,strPrintPricePerGallon		
		,strPrintSiteAddress		
		,strSiteNumber				
		,strSiteName				
		,strProductNumber			
		,strItemNo					
		,strDescription				
		,strVehicleNumber			
		,strVehicleDescription		
		,strTaxState				
		,strDepartment				
		,strSiteType				
		,strState					
		,strSiteAddress				
		,strSiteCity				
		,strPrintTimeStamp			
		,strEmailDistributionOption	
		,strEmail					
		,dtmTransactionDate			
		,dtmDate					
		,dtmPostedDate				
		,dblTotalMiles				
		,dblQuantity				
		,dblCalculatedTotalAmount	
		,dblOriginalTotalAmount		
		,dblCalculatedGrossAmount	
		,dblOriginalGrossAmount		
		,dblCalculatedNetAmount		
		,dblOriginalNetAmount		
		,dblMargin					
		,dblTotalTax				
		,dblTotalSST				
		,dblTaxExceptSST			
		,dblInvoiceTotal			
		,ysnPrintMiscellaneous		
		,ysnSummaryByCard			
		,ysnSummaryByDepartment		
		,ysnSummaryByMiscellaneous	
		,ysnSummaryByProduct		
		,ysnSummaryByVehicle		
		,ysnPrintTimeOnInvoices		
		,ysnPrintTimeOnReports		
		,ysnInvalid					
		,ysnPosted					
	    FROM vyuCFInvoiceReport AS main 
		INNER JOIN @tblCFInvoiceNunber as cfInvRptNo
		on main.intAccountId = cfInvRptNo.intAccountId
		INNER JOIN 
		(	SELECT intAccountId AS intSubAccountId,SUM(dblCalculatedTotalAmount) AS dblInvoiceTotal 
			FROM vyuCFInvoiceReport
			WHERE intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)
			GROUP BY intAccountId 
		) AS sub
		ON main.intAccountId = sub.intSubAccountId 
		where intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)

		--SELECT * FROM tblCFInvoiceReportTempTable

	END
    
END
