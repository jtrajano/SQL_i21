CREATE PROCEDURE [dbo].[uspCFInvoiceReportSummary](
	@xmlParam NVARCHAR(MAX)=null
	,@UserId NVARCHAR(MAX)
)
AS
BEGIN 
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
	SELECT 


		 strVehicleNumber				 = ''
		,strMiscellaneous				 = ''
		,strDepartment					 = ''
		,strVehicleDescription			 = ''
		,strTaxState					 = ''
		,strCardNumber					 = ''
		,strProductNumber				 = ''
		,strProductDescription			 = ''
		,strCardDescription				 = ''
		,intDiscountScheduleId			 = 0
		,intTermsCode					 = 0
		,intTermsId						 = 0
		,intCardId						 = 0
		,intProductId					 = 0
		,intARItemId					 = 0
		,intTransactionId				 = 0
		,dblTotalQuantity				 = 0.0
		,dblTotalGrossAmount			 = 0.0
		,dblTotalAmount					 = 0.0
		,TotalFET						 = 0.0
		,TotalSET						 = 0.0
		,TotalSST						 = 0.0
		,TotalLC						 = 0.0
		,dblTotalNetAmount				 = 0.0
		,ysnIncludeInQuantityDiscount	 = CAST(0 AS BIT)

		-- FILTER COLUMNS--
		,intAccountId					 = 0
		,strNetwork						 = ''
		,strCustomerName				 = ''
		,dtmTransactionDate				 = GetDate()
		,dtmPostedDate					 = GetDate()
		,strInvoiceCycle				 = ''
		-- FILTER COLUMNS--

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
		FROM [fnCFSplitString]('intAccountId,strNetwork,strCustomerNumber,dtmTransactionDate,dtmCreatedDate,dtmPostedDate,strInvoiceCycle,strPrintTimeStamp',',') 

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



		IF OBJECT_ID('tempdb..#tblCFTempInvoiceReportSummary') IS NOT NULL
			BEGIN
				DROP TABLE #tblCFTempInvoiceReportSummary
			END

		DECLARE @ysnIncludePrintedTransaction AS BIT
		SELECT TOP 1
				 @ysnIncludePrintedTransaction = [from]
			FROM @temp_params WHERE [fieldname] = 'ysnIncludePrintedTransaction'
			
					
		IF(@ysnReprintInvoice = 1 AND @InvoiceDate IS NOT NULL)
		BEGIN
			SET @whereClause = 'WHERE ( dtmInvoiceDate = ' + '''' + @InvoiceDate + '''' + ' ) AND ( strUpdateInvoiceReportNumber IS NOT NULL AND strUpdateInvoiceReportNumber != '''' )'
			IF (ISNULL(@CustomerName,'') != '')
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' + 
				' (' + @CustomerNameValue  + ' = ' + '''' + @CustomerName + '''' + ' )' END
			END
		END 
		ELSE IF(ISNULL(@ysnIncludePrintedTransaction,0) = 0)
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' ( ISNULL(strUpdateInvoiceReportNumber,'''') = '''')'
		END


		CREATE TABLE #tblCFTempInvoiceReportSummary(
			 intCustomerId						INT
			,intOdometer						INT
			,intCardId							INT
			,intProductId						INT
			,intARItemId						INT
			,intTransactionId					INT
			,intAccountId						INT
			,intDiscountScheduleId				INT
			,intTermsCode						INT
			,intTermsId							INT
			-------------------------------------------------------
			,strMiscellaneous					NVARCHAR(MAX)
			,strTransactionId					NVARCHAR(MAX)
			,strPrintTimeStamp					NVARCHAR(MAX)
			,strUpdateInvoiceReportNumber		NVARCHAR(MAX)
			,strInvoiceReportNumber				NVARCHAR(MAX)
			,strCustomerName					NVARCHAR(MAX)
			,strName							NVARCHAR(MAX)
			,strCustomerNumber					NVARCHAR(MAX)
			,strBillTo							NVARCHAR(MAX)
			,strCardNumber						NVARCHAR(MAX)
			,strCardDescription					NVARCHAR(MAX)
			,strVehicleNumber					NVARCHAR(MAX)
			,strVehicleDescription				NVARCHAR(MAX)
			,strShortName						NVARCHAR(MAX)
			,strItemNumber						NVARCHAR(MAX)
			,strItemDescription					NVARCHAR(MAX)
			,strNetwork							NVARCHAR(MAX)
			,strProductNumber					NVARCHAR(MAX)
			,strProductDescription				NVARCHAR(MAX)
			,strSiteNumber						NVARCHAR(MAX)
			,strSiteAddress						NVARCHAR(MAX)
			,strTaxState						NVARCHAR(MAX)
			,strInvoiceCycle					NVARCHAR(MAX)
			,strDepartment						NVARCHAR(MAX)
			,strDepartmentDescription			NVARCHAR(MAX)
			,strEmailDistributionOption			NVARCHAR(MAX)
			,strEmail							NVARCHAR(MAX)
			-------------------------------------------------------
			,dtmTransactionDate					DATETIME
			,dtmCreatedDate						DATETIME
			,dtmInvoiceDate						DATETIME
			,dtmPostedDate						DATETIME
			-------------------------------------------------------
			,ysnPostedCSV						BIT
			,ysnIncludeInQuantityDiscount		BIT
			-------------------------------------------------------
			,dblTotalQuantity				    NUMERIC(18,6)
			,dblTotalGrossAmount			    NUMERIC(18,6)
			,dblTotalNetAmount				    NUMERIC(18,6)
			,dblTotalAmount					    NUMERIC(18,6)
			,dblTotalTaxAmount				    NUMERIC(18,6)
			,TotalFET						    NUMERIC(18,6)
			,TotalSET						    NUMERIC(18,6)
			,TotalSST						    NUMERIC(18,6)
			,TotalLC						    NUMERIC(18,6)
			-------------------------------------------------------
		)

		IF(ISNULL(@ysnReprintInvoice,0) = 1 OR ISNULL(@ysnIncludePrintedTransaction,0) = 1)
		BEGIN
			INSERT INTO #tblCFTempInvoiceReportSummary(
				 intCustomerId					
				,intOdometer					
				,intCardId						
				,intProductId					
				,intARItemId					
				,intTransactionId				
				,intAccountId					
				,intDiscountScheduleId			
				,intTermsCode					
				,intTermsId						
				--------------------------------
				,strMiscellaneous				
				,strTransactionId				
				,strPrintTimeStamp				
				,strUpdateInvoiceReportNumber	
				,strInvoiceReportNumber			
				,strCustomerName				
				,strName						
				,strCustomerNumber				
				,strBillTo						
				,strCardNumber					
				,strCardDescription				
				,strVehicleNumber				
				,strVehicleDescription			
				,strShortName					
				,strItemNumber					
				,strItemDescription				
				,strNetwork						
				,strProductNumber				
				,strProductDescription			
				,strSiteNumber					
				,strSiteAddress					
				,strTaxState					
				,strInvoiceCycle				
				,strDepartment					
				,strDepartmentDescription		
				,strEmailDistributionOption		
				,strEmail						
				--------------------------------
				,dtmTransactionDate				
				,dtmCreatedDate					
				,dtmInvoiceDate					
				,dtmPostedDate					
				--------------------------------
				,ysnPostedCSV					
				,ysnIncludeInQuantityDiscount	
				--------------------------------
				,dblTotalQuantity				
				,dblTotalGrossAmount			
				,dblTotalNetAmount				
				,dblTotalAmount					
				,dblTotalTaxAmount				
				,TotalFET						
				,TotalSET						
				,TotalSST						
				,TotalLC						
			)
			SELECT 
				 intCustomerId					
				,intOdometer					
				,intCardId						
				,intProductId					
				,intARItemId					
				,intTransactionId				
				,intAccountId					
				,intDiscountScheduleId			
				,intTermsCode					
				,intTermsId						
				--------------------------------
				,strMiscellaneous				
				,strTransactionId				
				,strPrintTimeStamp				
				,strUpdateInvoiceReportNumber	
				,strInvoiceReportNumber			
				,strCustomerName				
				,strName						
				,strCustomerNumber				
				,strBillTo						
				,strCardNumber					
				,strCardDescription				
				,strVehicleNumber				
				,strVehicleDescription			
				,strShortName					
				,strItemNumber					
				,strItemDescription				
				,strNetwork						
				,strProductNumber				
				,strProductDescription			
				,strSiteNumber					
				,strSiteAddress					
				,strTaxState					
				,strInvoiceCycle				
				,strDepartment					
				,strDepartmentDescription		
				,strEmailDistributionOption		
				,strEmail						
				--------------------------------
				,dtmTransactionDate				
				,dtmCreatedDate					
				,dtmInvoiceDate					
				,dtmPostedDate					
				--------------------------------
				,ysnPostedCSV					
				,ysnIncludeInQuantityDiscount	
				--------------------------------
				,dblTotalQuantity				
				,dblTotalGrossAmount			
				,dblTotalNetAmount				
				,dblTotalAmount					
				,dblTotalTaxAmount				
				,TotalFET						
				,TotalSET						
				,TotalSST						
				,TotalLC						
			FROM
			vyuCFInvoiceReportSummary
		END
		ELSE
		BEGIN
			INSERT INTO #tblCFTempInvoiceReportSummary(
				 intCustomerId					
				,intOdometer					
				,intCardId						
				,intProductId					
				,intARItemId					
				,intTransactionId				
				,intAccountId					
				,intDiscountScheduleId			
				,intTermsCode					
				,intTermsId						
				--------------------------------
				,strMiscellaneous				
				,strTransactionId				
				,strPrintTimeStamp				
				,strUpdateInvoiceReportNumber	
				,strInvoiceReportNumber			
				,strCustomerName				
				,strName						
				,strCustomerNumber				
				,strBillTo						
				,strCardNumber					
				,strCardDescription				
				,strVehicleNumber				
				,strVehicleDescription			
				,strShortName					
				,strItemNumber					
				,strItemDescription				
				,strNetwork						
				,strProductNumber				
				,strProductDescription			
				,strSiteNumber					
				,strSiteAddress					
				,strTaxState					
				,strInvoiceCycle				
				,strDepartment					
				,strDepartmentDescription		
				,strEmailDistributionOption		
				,strEmail						
				--------------------------------
				,dtmTransactionDate				
				,dtmCreatedDate					
				,dtmInvoiceDate					
				,dtmPostedDate					
				--------------------------------
				,ysnPostedCSV					
				,ysnIncludeInQuantityDiscount	
				--------------------------------
				,dblTotalQuantity				
				,dblTotalGrossAmount			
				,dblTotalNetAmount				
				,dblTotalAmount					
				,dblTotalTaxAmount				
				,TotalFET						
				,TotalSET						
				,TotalSST						
				,TotalLC						
			)
			SELECT 
				 intCustomerId					
				,intOdometer					
				,intCardId						
				,intProductId					
				,intARItemId					
				,intTransactionId				
				,intAccountId					
				,intDiscountScheduleId			
				,intTermsCode					
				,intTermsId						
				--------------------------------
				,strMiscellaneous				
				,strTransactionId				
				,strPrintTimeStamp				
				,strUpdateInvoiceReportNumber	
				,strInvoiceReportNumber			
				,strCustomerName				
				,strName						
				,strCustomerNumber				
				,strBillTo						
				,strCardNumber					
				,strCardDescription				
				,strVehicleNumber				
				,strVehicleDescription			
				,strShortName					
				,strItemNumber					
				,strItemDescription				
				,strNetwork						
				,strProductNumber				
				,strProductDescription			
				,strSiteNumber					
				,strSiteAddress					
				,strTaxState					
				,strInvoiceCycle				
				,strDepartment					
				,strDepartmentDescription		
				,strEmailDistributionOption		
				,strEmail						
				--------------------------------
				,dtmTransactionDate				
				,dtmCreatedDate					
				,dtmInvoiceDate					
				,dtmPostedDate					
				--------------------------------
				,ysnPostedCSV					
				,ysnIncludeInQuantityDiscount	
				--------------------------------
				,dblTotalQuantity				
				,dblTotalGrossAmount			
				,dblTotalNetAmount				
				,dblTotalAmount					
				,dblTotalTaxAmount				
				,TotalFET						
				,TotalSET						
				,TotalSST						
				,TotalLC						
			FROM
			vyuCFInvoiceReportSummary
			WHERE ISNULL(ysnInvoiced,0) = 0
		END

		--SELECT * INTO #tblCFTempInvoiceReportSummary FROM vyuCFInvoiceReportSummary

		BEGIN TRY
			EXEC('
			INSERT INTO tblCFInvoiceSummaryTempTable
			(
				 intDiscountScheduleId
				,intTermsCode
				,intTermsId
				,intARItemId
				,strDepartmentDescription
				,strShortName
				,strProductDescription
				,strItemNumber
				,strItemDescription
				,dblTotalQuantity
				,dblTotalGrossAmount
				,dblTotalNetAmount
				,dblTotalAmount
				,dblTotalTaxAmount
				,TotalFET
				,TotalSET
				,TotalSST
				,TotalLC
				,ysnIncludeInQuantityDiscount
				,intAccountId
				,intTransactionId
				,strUserId
			)
			SELECT 
				intDiscountScheduleId
				,intTermsCode
				,intTermsId
				,intARItemId
				,strDepartmentDescription
				,strShortName
				,strProductDescription
				,strItemNumber
				,strItemDescription
				,dblTotalQuantity
				,dblTotalGrossAmount
				,dblTotalNetAmount
				,dblTotalAmount
				,dblTotalTaxAmount
				,TotalFET
				,TotalSET
				,TotalSST
				,TotalLC
				,ysnIncludeInQuantityDiscount
				,intAccountId
				,intTransactionId
				,''' +@UserId+'''
			FROM #tblCFTempInvoiceReportSummary ' + @whereClause)

			IF OBJECT_ID('tempdb..#tblCFTempInvoiceReportSummary') IS NOT NULL
			BEGIN
				DROP TABLE #tblCFTempInvoiceReportSummary
			END

		END TRY 
		BEGIN CATCH

			IF OBJECT_ID('tempdb..#tblCFTempInvoiceReportSummary') IS NOT NULL
			BEGIN
				DROP TABLE #tblCFTempInvoiceReportSummary
			END
			
		END CATCH

		
	END
    
END