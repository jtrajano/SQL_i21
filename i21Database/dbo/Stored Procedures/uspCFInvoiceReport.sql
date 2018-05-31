CREATE PROCEDURE [dbo].[uspCFInvoiceReport](
	 @xmlParam NVARCHAR(MAX)=null
	,@UserId NVARCHAR(MAX)
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
		,ysnSummaryByCardProd	   = CAST(0 AS BIT)
		,ysnSummaryByDeptCardProd  = CAST(0 AS BIT)
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
		FROM [fnCFSplitString]('intAccountId,strNetwork,strCustomerNumber,dtmTransactionDate,dtmCreatedDate,dtmPostedDate,strInvoiceCycle,strInvoiceReportNumber',',') 

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
				IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
					
				END
			END
			ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','='))
			BEGIN
			

				IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
				BEGIN
						SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
				END
				ELSE
				BEGIN
						SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' = ' + '''' + @From + '''' + ' )'
				END

			END
			ELSE IF (UPPER(@Condition) = 'IN')
			BEGIN
				
				IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'

				END
				ELSE
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'

				END
			END
			ELSE IF (UPPER(@Condition) = 'GREATER THAN')
			BEGIN
				BEGIN
					
					IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
					BEGIN
						SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						' (' + @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'
					END
					ELSE
					BEGIN
						SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' >= ' + '''' + @From + '''' + ' )'
					END
				END
			END
			ELSE IF (UPPER(@Condition) = 'LESS THAN')
			BEGIN
				BEGIN
					
					IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
					BEGIN
						SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						' (' + @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'
					END
					ELSE
					BEGIN
						SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' <= ' + '''' + @To + '''' + ' )'
					END
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

		DECLARE @ysnReprintInvoice NVARCHAR(MAX)
		SELECT TOP 1
			 @ysnReprintInvoice = [from]
		FROM @temp_params WHERE [fieldname] = 'ysnReprintInvoice'

		DECLARE @InvoiceDate NVARCHAR(MAX)
		SELECT TOP 1
			 @InvoiceDate = [from]
		FROM @temp_params WHERE [fieldname] = 'dtmInvoiceDate'

		DECLARE @CustomerName NVARCHAR(MAX)
		DECLARE @CustomerNameValue NVARCHAR(MAX)
		SELECT TOP 1
			 @CustomerName = [from]
			,@CustomerNameValue = [fieldname]
		FROM @temp_params WHERE [fieldname] = 'strCustomerNumber'

		
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

		IF (@ysnReprintInvoice = 1)
		BEGIN
		--INCLUDE PRINTED TRANSACTION
		
			SET @From = ''
			SET @To = ''
			SET @Condition = ''
			SET @Fieldname = ''
		
		END
		ELSE
		BEGIN
			SELECT TOP 1
				 @From = [from]
				,@To = [to]
				,@Condition = [condition]
				,@Fieldname = [fieldname]
			FROM @temp_params WHERE [fieldname] = 'ysnIncludePrintedTransaction'
		END


		IF(@ysnReprintInvoice = 1 AND @InvoiceDate IS NOT NULL)
		BEGIN
			SET @whereClause = 'WHERE ( dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ' ) AND ( strInvoiceReportNumber IS NOT NULL AND strInvoiceReportNumber != '''' )'
			IF (ISNULL(@CustomerName,'') != '')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' + 
				' (' + @CustomerNameValue  + ' = ' + '''' + @CustomerName + '''' + ' )' END
			END
		END
		ELSE IF (ISNULL(@From,'') = '')
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' ( ISNULL(strInvoiceReportNumber,'''') = '''')'
		END


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

		CREATE TABLE #tblCFTempInvoiceReport 
		(
			 intCustomerId					INT
			,intTransactionId				INT
			,intOdometer					INT
			,intProductId					INT
			,intCardId						INT
			,intAccountId					INT
			,intInvoiceCycle				INT
			,intInvoiceId					INT
			,intCustomerGroupId				INT
			,intOdometerAging				INT
			----------------------------------------------------
			,dtmTransactionDate				DATETIME
			,dtmInvoiceDate					DATETIME
			,dtmPostedDate					DATETIME
			,dtmCreatedDate					DATETIME
			,dtmDate						DATETIME
			----------------------------------------------------
			,strTransactionId				NVARCHAR(MAX)
			,strTransactionType				NVARCHAR(MAX)
			,strInvoiceReportNumber			NVARCHAR(MAX)
			,strTempInvoiceReportNumber		NVARCHAR(MAX)
			,strMiscellaneous				NVARCHAR(MAX)
			,strPrintTimeStamp				NVARCHAR(MAX)
			,strPrimarySortOptions			NVARCHAR(MAX)
			,strSecondarySortOptions		NVARCHAR(MAX)
			,strPrintRemittancePage			NVARCHAR(MAX)
			,strPrintPricePerGallon			NVARCHAR(MAX)
			,strPrintSiteAddress			NVARCHAR(MAX)
			,strPrimaryDepartment			NVARCHAR(MAX)
			,strName						NVARCHAR(MAX)
			,strCustomerNumber				NVARCHAR(MAX)
			,strBillTo						NVARCHAR(MAX)
			,strShipTo						NVARCHAR(MAX)
			,strType						NVARCHAR(MAX)
			,strLocationName				NVARCHAR(MAX)
			,strInvoiceNumber				NVARCHAR(MAX)
			,strNetwork						NVARCHAR(MAX)
			,strGroupName					NVARCHAR(MAX)
			,strInvoiceCycle				NVARCHAR(MAX)
			,strCardNumber					NVARCHAR(MAX)
			,strCardDescription				NVARCHAR(MAX)
			,strSiteNumber					NVARCHAR(MAX)
			,strSiteName					NVARCHAR(MAX)
			,strTaxState					NVARCHAR(MAX)
			,strSiteType					NVARCHAR(MAX)
			,strState						NVARCHAR(MAX)
			,strSiteAddress					NVARCHAR(MAX)
			,strSiteCity					NVARCHAR(MAX)
			,strProductNumber				NVARCHAR(MAX)
			,strItemNo						NVARCHAR(MAX)
			,strDescription					NVARCHAR(MAX)
			,strVehicleNumber				NVARCHAR(MAX)
			,strVehicleDescription			NVARCHAR(MAX)
			,strDepartment					NVARCHAR(MAX)
			,strDepartmentDescription		NVARCHAR(MAX)
			,strCompanyName					NVARCHAR(MAX)
			,strCompanyAddress				NVARCHAR(MAX)
			,strEmailDistributionOption		NVARCHAR(MAX)
			,strEmail						NVARCHAR(MAX)
			,strCustomerName				NVARCHAR(MAX)
			----------------------------------------------------
			,dblQuantity					NUMERIC(18,6)
			,dblCalculatedTotalAmount		NUMERIC(18,6)
			,dblOriginalTotalAmount			NUMERIC(18,6)
			,dblCalculatedGrossAmount		NUMERIC(18,6)
			,dblOriginalGrossAmount			NUMERIC(18,6)
			,dblCalculatedNetAmount			NUMERIC(18,6)
			,dblOriginalNetAmount			NUMERIC(18,6)
			,dblMargin						NUMERIC(18,6)
			,dblTotalMiles					NUMERIC(18,6)
			,dblTotalTax					NUMERIC(18,6)
			,dblTotalSST					NUMERIC(18,6)
			,dblTaxExceptSST				NUMERIC(18,6)
			----------------------------------------------------
			,ysnInvalid						BIT
			,ysnPosted						BIT
			,ysnPostedCSV					BIT
			,ysnPrintMiscellaneous			BIT
			,ysnSummaryByCard				BIT
			,ysnSummaryByDepartment			BIT
			,ysnSummaryByMiscellaneous		BIT
			,ysnSummaryByProduct			BIT
			,ysnSummaryByVehicle			BIT
			,ysnSummaryByCardProd			BIT
			,ysnSummaryByDeptCardProd		BIT
			,ysnPrintTimeOnInvoices			BIT
			,ysnPrintTimeOnReports			BIT
			,ysnSummaryByDeptVehicleProd	BIT
			,ysnDepartmentGrouping			BIT
			,ysnPostForeignSales			BIT

		)


		IF(ISNULL(@ysnReprintInvoice,0) = 1 OR ISNULL(@From,0) = 1)
		BEGIN
			INSERT INTO #tblCFTempInvoiceReport(
			 intCustomerId				
			,intTransactionId			
			,intOdometer				
			,intProductId				
			,intCardId					
			,intAccountId				
			,intInvoiceCycle			
			,intInvoiceId				
			,intCustomerGroupId			
			,intOdometerAging			
			----------------------------
			,dtmTransactionDate			
			,dtmInvoiceDate				
			,dtmPostedDate				
			,dtmCreatedDate				
			,dtmDate					
			----------------------------
			,strTransactionId			
			,strTransactionType			
			,strInvoiceReportNumber		
			,strTempInvoiceReportNumber	
			,strMiscellaneous			
			,strPrintTimeStamp			
			,strPrimarySortOptions		
			,strSecondarySortOptions	
			,strPrintRemittancePage		
			,strPrintPricePerGallon		
			,strPrintSiteAddress		
			,strPrimaryDepartment		
			,strName					
			,strCustomerNumber			
			,strBillTo					
			,strShipTo					
			,strType					
			,strLocationName			
			,strInvoiceNumber			
			,strNetwork					
			,strGroupName				
			,strInvoiceCycle			
			,strCardNumber				
			,strCardDescription			
			,strSiteNumber				
			,strSiteName				
			,strTaxState				
			,strSiteType				
			,strState					
			,strSiteAddress				
			,strSiteCity				
			,strProductNumber			
			,strItemNo					
			,strDescription				
			,strVehicleNumber			
			,strVehicleDescription		
			,strDepartment				
			,strDepartmentDescription	
			,strCompanyName				
			,strCompanyAddress			
			,strEmailDistributionOption	
			,strEmail				
			,strCustomerName	
			----------------------------
			,dblQuantity				
			,dblCalculatedTotalAmount	
			,dblOriginalTotalAmount		
			,dblCalculatedGrossAmount	
			,dblOriginalGrossAmount		
			,dblCalculatedNetAmount		
			,dblOriginalNetAmount		
			,dblMargin					
			,dblTotalMiles				
			,dblTotalTax				
			,dblTotalSST				
			,dblTaxExceptSST			
			----------------------------
			,ysnInvalid					
			,ysnPosted					
			,ysnPostedCSV				
			,ysnPrintMiscellaneous		
			,ysnSummaryByCard			
			,ysnSummaryByDepartment		
			,ysnSummaryByMiscellaneous	
			,ysnSummaryByProduct		
			,ysnSummaryByVehicle		
			,ysnSummaryByCardProd		
			,ysnSummaryByDeptCardProd	
			,ysnPrintTimeOnInvoices		
			,ysnPrintTimeOnReports		
			,ysnSummaryByDeptVehicleProd
			,ysnDepartmentGrouping		
			,ysnPostForeignSales		
			)
			SELECT 
			 intCustomerId				
			,intTransactionId			
			,intOdometer				
			,intProductId				
			,intCardId					
			,intAccountId				
			,intInvoiceCycle			
			,intInvoiceId				
			,intCustomerGroupId			
			,intOdometerAging			
			----------------------------
			,dtmTransactionDate			
			,dtmInvoiceDate				
			,dtmPostedDate				
			,dtmCreatedDate				
			,dtmDate					
			----------------------------
			,strTransactionId			
			,strTransactionType			
			,strInvoiceReportNumber		
			,strTempInvoiceReportNumber	
			,strMiscellaneous			
			,strPrintTimeStamp			
			,strPrimarySortOptions		
			,strSecondarySortOptions	
			,strPrintRemittancePage		
			,strPrintPricePerGallon		
			,strPrintSiteAddress		
			,strPrimaryDepartment		
			,strName					
			,strCustomerNumber			
			,strBillTo					
			,strShipTo					
			,strType					
			,strLocationName			
			,strInvoiceNumber			
			,strNetwork					
			,strGroupName				
			,strInvoiceCycle			
			,strCardNumber				
			,strCardDescription			
			,strSiteNumber				
			,strSiteName				
			,strTaxState				
			,strSiteType				
			,strState					
			,strSiteAddress				
			,strSiteCity				
			,strProductNumber			
			,strItemNo					
			,strDescription				
			,strVehicleNumber			
			,strVehicleDescription		
			,strDepartment				
			,strDepartmentDescription	
			,strCompanyName				
			,strCompanyAddress			
			,strEmailDistributionOption	
			,strEmail		
			,strCustomerName			
			----------------------------
			,dblQuantity				
			,dblCalculatedTotalAmount	
			,dblOriginalTotalAmount		
			,dblCalculatedGrossAmount	
			,dblOriginalGrossAmount		
			,dblCalculatedNetAmount		
			,dblOriginalNetAmount		
			,dblMargin					
			,dblTotalMiles				
			,dblTotalTax				
			,dblTotalSST				
			,dblTaxExceptSST			
			----------------------------
			,ysnInvalid					
			,ysnPosted					
			,ysnPostedCSV				
			,ysnPrintMiscellaneous		
			,ysnSummaryByCard			
			,ysnSummaryByDepartment		
			,ysnSummaryByMiscellaneous	
			,ysnSummaryByProduct		
			,ysnSummaryByVehicle		
			,ysnSummaryByCardProd		
			,ysnSummaryByDeptCardProd	
			,ysnPrintTimeOnInvoices		
			,ysnPrintTimeOnReports		
			,ysnSummaryByDeptVehicleProd
			,ysnDepartmentGrouping		
			,ysnPostForeignSales		
			FROM vyuCFInvoiceReport
		END
		ELSE
		BEGIN
			INSERT INTO #tblCFTempInvoiceReport(
			 intCustomerId				
			,intTransactionId			
			,intOdometer				
			,intProductId				
			,intCardId					
			,intAccountId				
			,intInvoiceCycle			
			,intInvoiceId				
			,intCustomerGroupId			
			,intOdometerAging			
			----------------------------
			,dtmTransactionDate			
			,dtmInvoiceDate				
			,dtmPostedDate				
			,dtmCreatedDate				
			,dtmDate					
			----------------------------
			,strTransactionId			
			,strTransactionType			
			,strInvoiceReportNumber		
			,strTempInvoiceReportNumber	
			,strMiscellaneous			
			,strPrintTimeStamp			
			,strPrimarySortOptions		
			,strSecondarySortOptions	
			,strPrintRemittancePage		
			,strPrintPricePerGallon		
			,strPrintSiteAddress		
			,strPrimaryDepartment		
			,strName					
			,strCustomerNumber			
			,strBillTo					
			,strShipTo					
			,strType					
			,strLocationName			
			,strInvoiceNumber			
			,strNetwork					
			,strGroupName				
			,strInvoiceCycle			
			,strCardNumber				
			,strCardDescription			
			,strSiteNumber				
			,strSiteName				
			,strTaxState				
			,strSiteType				
			,strState					
			,strSiteAddress				
			,strSiteCity				
			,strProductNumber			
			,strItemNo					
			,strDescription				
			,strVehicleNumber			
			,strVehicleDescription		
			,strDepartment				
			,strDepartmentDescription	
			,strCompanyName				
			,strCompanyAddress			
			,strEmailDistributionOption	
			,strEmail		
			,strCustomerName				
			----------------------------
			,dblQuantity				
			,dblCalculatedTotalAmount	
			,dblOriginalTotalAmount		
			,dblCalculatedGrossAmount	
			,dblOriginalGrossAmount		
			,dblCalculatedNetAmount		
			,dblOriginalNetAmount		
			,dblMargin					
			,dblTotalMiles				
			,dblTotalTax				
			,dblTotalSST				
			,dblTaxExceptSST			
			----------------------------
			,ysnInvalid					
			,ysnPosted					
			,ysnPostedCSV				
			,ysnPrintMiscellaneous		
			,ysnSummaryByCard			
			,ysnSummaryByDepartment		
			,ysnSummaryByMiscellaneous	
			,ysnSummaryByProduct		
			,ysnSummaryByVehicle		
			,ysnSummaryByCardProd		
			,ysnSummaryByDeptCardProd	
			,ysnPrintTimeOnInvoices		
			,ysnPrintTimeOnReports		
			,ysnSummaryByDeptVehicleProd
			,ysnDepartmentGrouping		
			,ysnPostForeignSales		
			)
			SELECT 
			 intCustomerId				
			,intTransactionId			
			,intOdometer				
			,intProductId				
			,intCardId					
			,intAccountId				
			,intInvoiceCycle			
			,intInvoiceId				
			,intCustomerGroupId			
			,intOdometerAging			
			----------------------------
			,dtmTransactionDate			
			,dtmInvoiceDate				
			,dtmPostedDate				
			,dtmCreatedDate				
			,dtmDate					
			----------------------------
			,strTransactionId			
			,strTransactionType			
			,strInvoiceReportNumber		
			,strTempInvoiceReportNumber	
			,strMiscellaneous			
			,strPrintTimeStamp			
			,strPrimarySortOptions		
			,strSecondarySortOptions	
			,strPrintRemittancePage		
			,strPrintPricePerGallon		
			,strPrintSiteAddress		
			,strPrimaryDepartment		
			,strName					
			,strCustomerNumber			
			,strBillTo					
			,strShipTo					
			,strType					
			,strLocationName			
			,strInvoiceNumber			
			,strNetwork					
			,strGroupName				
			,strInvoiceCycle			
			,strCardNumber				
			,strCardDescription			
			,strSiteNumber				
			,strSiteName				
			,strTaxState				
			,strSiteType				
			,strState					
			,strSiteAddress				
			,strSiteCity				
			,strProductNumber			
			,strItemNo					
			,strDescription				
			,strVehicleNumber			
			,strVehicleDescription		
			,strDepartment				
			,strDepartmentDescription	
			,strCompanyName				
			,strCompanyAddress			
			,strEmailDistributionOption	
			,strEmail			
			,strCustomerName			
			----------------------------
			,dblQuantity				
			,dblCalculatedTotalAmount	
			,dblOriginalTotalAmount		
			,dblCalculatedGrossAmount	
			,dblOriginalGrossAmount		
			,dblCalculatedNetAmount		
			,dblOriginalNetAmount		
			,dblMargin					
			,dblTotalMiles				
			,dblTotalTax				
			,dblTotalSST				
			,dblTaxExceptSST			
			----------------------------
			,ysnInvalid					
			,ysnPosted					
			,ysnPostedCSV				
			,ysnPrintMiscellaneous		
			,ysnSummaryByCard			
			,ysnSummaryByDepartment		
			,ysnSummaryByMiscellaneous	
			,ysnSummaryByProduct		
			,ysnSummaryByVehicle		
			,ysnSummaryByCardProd		
			,ysnSummaryByDeptCardProd	
			,ysnPrintTimeOnInvoices		
			,ysnPrintTimeOnReports		
			,ysnSummaryByDeptVehicleProd
			,ysnDepartmentGrouping		
			,ysnPostForeignSales		
			FROM vyuCFInvoiceReport
			WHERE  ISNULL(ysnInvoiced,0) = 0
		END

		--SELECT * INTO #tblCFTempInvoiceReport FROM vyuCFInvoiceReport

		---------GET DISTINCT CARD ID---------
		SET @tblCFTempTableQuery = 'SELECT DISTINCT ISNULL(intAccountId,0) FROM #tblCFTempInvoiceReport ' + @whereClause

		--SELECT @tblCFTempTableQuery

		INSERT INTO  @tblCFTableCardIds (intAccountId)
		EXEC (@tblCFTempTableQuery)


		--select '@tblCFTableCardIds',* from @tblCFTableCardIds ---------------------------------------------------------------------------------
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
				' ( ISNULL(strInvoiceReportNumber,'''') = '''')'

			---------GET DISTINCT TRANSACTION ID---------
			SET @tblCFTempTableQuery = 'SELECT DISTINCT intTransactionId FROM #tblCFTempInvoiceReport ' + @whereClause

			--SELECT @tblCFTempTableQuery

			INSERT INTO  @tblCFTableTransationIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)

			INSERT INTO  @tblCFFilterIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)

			--SELECT '@tblCFTableTransationIds',* FROM @tblCFTableTransationIds
			SELECT '@tblCFFilterIds',* FROM @tblCFFilterIds -- HERE

			---------GET DISTINCT TRANSACTION ID---------


			--SELECT * FROM @tblCFInvoiceNunber

			WHILE (EXISTS(SELECT 1 FROM @tblCFTableTransationIds))
			BEGIN

				SELECT @intTempTransactionCounter = [intTransactionId] FROM @tblCFTableTransationIds
				SELECT @intTempTransactionId = [intTransactionId] FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
				SELECT @strInvoiceNumber = strInvoiceNumber from @tblCFInvoiceNunber where intAccountId = (SELECT TOP 1
																											intAccountId = (
																											CASE cfTrans.strTransactionType 
																												WHEN 'Foreign Sale' 
																												THEN cfNet.intAccountId

																												ELSE cfCardAcct.intAccountId 
																											END)
																											FROM tblCFTransaction as cfTrans
																											INNER JOIN 
																											(SELECT cfAcct.*,icfNet.intNetworkId FROM tblCFNetwork as icfNet
																											LEFT JOIN tblCFAccount cfAcct 
																											ON icfNet.intCustomerId = 
																											cfAcct.intCustomerId )
																											 as cfNet
																											ON cfTrans.intNetworkId = cfNet.intNetworkId
																											LEFT JOIN vyuCFCardAccount as cfCardAcct
																											ON cfTrans.intCardId = cfCardAcct.intCardId
																											WHERE cfTrans.intTransactionId = @intTempTransactionId)

				---------UPDATE INVOICE REPORT NUMBER ID---------
				IF(@CFID IS NOT NULL)
				BEGIN
					EXEC('UPDATE tblCFTransaction SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ',' + 'dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ',' + 'strTempInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					EXEC('UPDATE #tblCFTempInvoiceReport SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ',' + 'dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ',' + 'strTempInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					
					--EXEC('UPDATE tblCFTransaction SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					--EXEC('UPDATE tblCFTransaction SET dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
				END
				---------UPDATE INVOICE REPORT NUMBER ID---------


				DELETE FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
			END

		END
		ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'TRUE' OR @From = 1))
		BEGIN

			---------GET DISTINCT TRANSACTION ID---------
			SET @tblCFTempTableQuery = 'SELECT DISTINCT intTransactionId FROM #tblCFTempInvoiceReport ' + @whereClause

			INSERT INTO  @tblCFTableTransationIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)

			INSERT INTO  @tblCFFilterIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)
			---------GET DISTINCT TRANSACTION ID---------

			WHILE (EXISTS(SELECT 1 FROM @tblCFTableTransationIds))
			BEGIN

				SELECT @intTempTransactionCounter = [intTransactionId] FROM @tblCFTableTransationIds
				SELECT @intTempTransactionId = [intTransactionId] FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
				SELECT @strInvoiceNumber = strInvoiceNumber from @tblCFInvoiceNunber where intAccountId = (SELECT TOP 1
																											intAccountId = (
																											CASE cfTrans.strTransactionType 
																												WHEN 'Foreign Sale' 
																												THEN cfNet.intAccountId

																												ELSE cfCardAcct.intAccountId 
																											END)
																											FROM tblCFTransaction as cfTrans
																											INNER JOIN 
																											(SELECT cfAcct.*,icfNet.intNetworkId FROM tblCFNetwork as icfNet
																											LEFT JOIN tblCFAccount cfAcct 
																											ON icfNet.intCustomerId = 
																											cfAcct.intCustomerId )
																											 as cfNet
																											ON cfTrans.intNetworkId = cfNet.intNetworkId
																											LEFT JOIN vyuCFCardAccount as cfCardAcct
																											ON cfTrans.intCardId = cfCardAcct.intCardId
																											WHERE cfTrans.intTransactionId = @intTempTransactionId)

				---------UPDATE INVOICE REPORT NUMBER ID---------
				IF(@CFID IS NOT NULL)
				BEGIN

					--EXEC('UPDATE tblCFTransaction SET strTempInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					--EXEC('UPDATE tblCFTransaction SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
					--EXEC('UPDATE tblCFTransaction SET dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)

					EXEC('UPDATE tblCFTransaction SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ',' + 'dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ',' + 'strTempInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)

					EXEC('UPDATE #tblCFTempInvoiceReport SET strPrintTimeStamp = ' + '''' + @strPrintTimeStamp + '''' + ',' + 'dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ',' + 'strTempInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)

				END
				---------UPDATE INVOICE REPORT NUMBER ID---------


				DELETE FROM @tblCFTableTransationIds WHERE [intTransactionId] = @intTempTransactionCounter
			END

		END
		ELSE
		BEGIN
			---------GET DISTINCT TRANSACTION ID---------
			SET @tblCFTempTableQuery = 'SELECT DISTINCT intTransactionId FROM #tblCFTempInvoiceReport ' + @whereClause

			INSERT INTO  @tblCFFilterIds (intTransactionId)
			EXEC (@tblCFTempTableQuery)

			UPDATE tblCFTransaction SET strTempInvoiceReportNumber = strInvoiceReportNumber where intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)
			UPDATE #tblCFTempInvoiceReport SET strTempInvoiceReportNumber = strInvoiceReportNumber where intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)

			---------GET DISTINCT TRANSACTION ID---------
		END

		--EXEC('SELECT * FROM vyuCFInvoiceReport ' + @whereClause)
		--SELECT * FROM vyuCFInvoiceReport where intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)

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
		--,intSubAccountId			
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
		--,dblInvoiceTotal			
		,ysnPrintMiscellaneous		
		,ysnSummaryByCard			
		,ysnSummaryByDepartment		
		,ysnSummaryByMiscellaneous	
		,ysnSummaryByProduct		
		,ysnSummaryByVehicle
		,ysnSummaryByCardProd	 
		,ysnSummaryByDeptCardProd		
		,ysnPrintTimeOnInvoices		
		,ysnPrintTimeOnReports		
		,ysnInvalid					
		,ysnPosted		
		,ysnPostForeignSales	
		,ysnDepartmentGrouping
		,ysnSummaryByDeptVehicleProd	
		,ysnPostedCSV
		INTO #tblCFTempInvoiceReportSummary 
		FROM #tblCFTempInvoiceReport AS main 
		INNER JOIN @tblCFInvoiceNunber as cfInvRptNo
		on main.intAccountId = cfInvRptNo.intAccountId


		SELECT '#tblCFTempInvoiceReportSummary',* FROM #tblCFTempInvoiceReportSummary -- HERE
		SELECT * FROM tblCFInvoiceReportTempTable -- HERE


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
		--,intSubAccountId			
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
		--,dblInvoiceTotal			
		,ysnPrintMiscellaneous		
		,ysnSummaryByCard			
		,ysnSummaryByDepartment		
		,ysnSummaryByMiscellaneous	
		,ysnSummaryByProduct		
		,ysnSummaryByVehicle
		,ysnSummaryByCardProd	 
		,ysnSummaryByDeptCardProd		
		,ysnPrintTimeOnInvoices		
		,ysnPrintTimeOnReports		
		,ysnInvalid					
		,ysnPosted
		,ysnPostForeignSales
		,ysnDepartmentGrouping
		,ysnSummaryByDeptVehicleProd
		,ysnPostedCSV
		,strUserId
		)
		SELECT
		 intCustomerGroupId			
		,intTransactionId			
		,intOdometer				
		,intOdometerAging			
		,intInvoiceId				
		,intProductId				
		,intCardId					
		,intAccountId				
		,intInvoiceCycle			
		--,intSubAccountId			
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
		,strInvoiceNumber			
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
		--,dblInvoiceTotal			
		,ysnPrintMiscellaneous		
		,ysnSummaryByCard			
		,ysnSummaryByDepartment		
		,ysnSummaryByMiscellaneous	
		,ysnSummaryByProduct		
		,ysnSummaryByVehicle
		,ysnSummaryByCardProd	 
		,ysnSummaryByDeptCardProd		
		,ysnPrintTimeOnInvoices		
		,ysnPrintTimeOnReports		
		,ysnInvalid					
		,ysnPosted		
		,ysnPostForeignSales	
		,ysnDepartmentGrouping
		,ysnSummaryByDeptVehicleProd		
		,ysnPostedCSV
		,@UserId
	    FROM #tblCFTempInvoiceReportSummary 
		where intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)

		SELECT * FROM tblCFInvoiceReportTempTable -- HERE

	END
    
END