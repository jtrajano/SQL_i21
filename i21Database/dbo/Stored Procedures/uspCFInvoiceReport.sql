CREATE PROCEDURE [dbo].[uspCFInvoiceReport](
	 @xmlParam NVARCHAR(MAX)=null
	,@UserId NVARCHAR(MAX)
	,@StatementType NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
		SELECT 'invalid xmlparam'
		RETURN;
	END
	ELSE
	BEGIN 

		-- EXTRACT XML PARAMETERS--
		DECLARE @idoc INT
		
		DECLARE @From NVARCHAR(MAX)
		DECLARE @To NVARCHAR(MAX)
		DECLARE @Condition NVARCHAR(MAX)
		DECLARE @Fieldname NVARCHAR(MAX)

		DECLARE @tblCFFieldList TABLE
		(
			[intFieldId]   INT , 
			[strFieldId]   NVARCHAR(MAX)   
		)

		--INSERT ALLOWED TABLE PARAMETER
		INSERT INTO @tblCFFieldList([intFieldId],[strFieldId])
		SELECT RecordKey,Record
		FROM [fnCFSplitString]('intAccountId,strNetwork,strCustomerNumber,dtmTransactionDate,dtmCreatedDate,dtmPostedDate,strInvoiceCycle,strInvoiceReportNumber,dtmBillingDate',',') 

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




		DECLARE @filterGuid NVARCHAR(MAX)
		SET @filterGuid = NEWID()

		
		DECLARE @intCounter			INT
		DECLARE @strField			NVARCHAR(MAX)
		DECLARE @strParameterType	NVARCHAR(MAX)
		WHILE (EXISTS(SELECT 1 FROM @tblCFFieldList))
			BEGIN
				SELECT TOP 1 @intCounter = [intFieldId] , @strField = [strFieldId] FROM @tblCFFieldList
				
				--MAIN LOOP			
				SELECT TOP 1
					 @From = [from]
					,@To = [to]
					,@Condition = [condition]
					,@Fieldname = [fieldname]
				FROM @temp_params WHERE [fieldname] = @strField

				SET @strParameterType = SUBSTRING(@Fieldname,1,3)
				SET @strParameterType = (CASE 
					WHEN @strParameterType = 'str'
						THEN 'string'
					WHEN @strParameterType = 'dtm'
						THEN 'date'
					WHEN @strParameterType = 'ysn'
						THEN 'boolean'
					WHEN @strParameterType = 'int'
						THEN 'int'
				END)

			IF (UPPER(@Condition) = 'BETWEEN')
			BEGIN
				IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
				BEGIN
					--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					--' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'

					INSERT INTO tblCFOptFilterParam (
					 strFilter
					,strDataType
					,strGuid
					)
					SELECT 
					' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
					,@strParameterType
					,@filterGuid


				END
				ELSE
				BEGIN
					--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					--' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'

					INSERT INTO tblCFOptFilterParam (
					 strFilter
					,strDataType
					,strGuid
					)
					SELECT 
					' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
					,@strParameterType
					,@filterGuid
					
				END
			END
			ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','='))
			BEGIN
			

				IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
				BEGIN
						--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						--' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'

						INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
						,@strParameterType
						,@filterGuid
				END
				ELSE
				BEGIN
						--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						--' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' = ' + '''' + @From + '''' + ' )'

						INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' = ' + '''' + @From + '''' + ' )'
						,@strParameterType
						,@filterGuid

				END

			END
			ELSE IF (UPPER(@Condition) = 'IN')
			BEGIN
				
				IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
				BEGIN
					--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					--' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'

					INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
						,@strParameterType
						,@filterGuid

				END
				ELSE
				BEGIN
					--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					--' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'

					INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
						,@strParameterType
						,@filterGuid

				END
			END
			ELSE IF (UPPER(@Condition) = 'GREATER THAN')
			BEGIN
				BEGIN
					
					IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
					BEGIN
						--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						--' (' + @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'


						INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'
						,@strParameterType
						,@filterGuid

					END
					ELSE
					BEGIN
						--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						--' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' >= ' + '''' + @From + '''' + ' )'


						INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' >= ' + '''' + @From + '''' + ' )'
						,@strParameterType
						,@filterGuid

					END
				END
			END
			ELSE IF (UPPER(@Condition) = 'LESS THAN')
			BEGIN
				BEGIN
					
					IF(@Fieldname NOT IN ('dtmTransactionDate','dtmCreatedDate','dtmPostedDate'))
					BEGIN
						--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						--' (' + @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'

						
						INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'
						,@strParameterType
						,@filterGuid


					END
					ELSE
					BEGIN
						--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
						--' (' + 'DATEADD(dd, DATEDIFF(dd, 0, '+@Fieldname+'), 0)'  + ' <= ' + '''' + @To + '''' + ' )'

						INSERT INTO tblCFOptFilterParam (
						 strFilter
						,strDataType
						,strGuid
						)
						SELECT 
						' (' + @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'
						,@strParameterType
						,@filterGuid


					END
				END
			END

			SET @From = ''
			SET @To = ''
			SET @Condition = ''
			SET @Fieldname = ''
			SET @strParameterType = ''


		--MAIN LOOP

			DELETE FROM @tblCFFieldList WHERE [intFieldId] = @intCounter
		END

		--EXTRACT PARAM MANUALLY
		DECLARE @strPrintTimeStamp NVARCHAR(MAX)
		SELECT TOP 1
			 @strPrintTimeStamp = [from]
		FROM @temp_params WHERE [fieldname] = 'strPrintTimeStamp'

		DECLARE @ysnReprintInvoice NVARCHAR(MAX)
		SELECT TOP 1
			 @ysnReprintInvoice = [from]
		FROM @temp_params WHERE [fieldname] = 'ysnReprintInvoice'

		DECLARE @dtmInvoiceDate NVARCHAR(MAX)
		SELECT TOP 1
			 @dtmInvoiceDate = [from]
		FROM @temp_params WHERE [fieldname] = 'dtmInvoiceDate'

		DECLARE @strCustomerNumber NVARCHAR(MAX)
		SELECT TOP 1
			 @strCustomerNumber = [from]
		FROM @temp_params WHERE [fieldname] = 'strCustomerNumber'

		DECLARE @ysnNonDistibutionList NVARCHAR(MAX)
		SELECT TOP 1
			 @ysnNonDistibutionList = [from]
		FROM @temp_params WHERE [fieldname] = 'ysnNonDistibutionList'

		DECLARE @ysnIncludePrintedTransaction NVARCHAR(MAX)
		SELECT TOP 1
			 @ysnIncludePrintedTransaction = [from]
		FROM @temp_params WHERE [fieldname] = 'ysnIncludePrintedTransaction'

		

		IF (ISNULL(@ysnNonDistibutionList,0) = 1)
		BEGIN

			INSERT INTO tblCFOptFilterParam (
			 strFilter
			,strDataType
			,strGuid
			)
			SELECT 
			' NOT (strEmailDistributionOption like ''%CF Invoice%'' AND (strEmail IS NOT NULL AND strEmail != ''''))'
			,'string'
			,@filterGuid

		END


		IF(ISNULL(@ysnReprintInvoice,0) = 1 AND @dtmInvoiceDate IS NOT NULL)
		BEGIN
			
			--DELETE PREVIOUS FILTER
			DELETE FROM tblCFOptFilterParam WHERE strGuid = @filterGuid

			--INSERT FILTER FOR REPRINT
			INSERT INTO tblCFOptFilterParam (
				 strFilter
				,strDataType
				,strGuid
			)
			SELECT 
				'( dtmInvoiceDate = ' + '''' + @dtmInvoiceDate + '''' + ' )'
				,'date'
				,@filterGuid

			INSERT INTO tblCFOptFilterParam (
				strFilter
				,strDataType
				,strGuid
			)
			SELECT 
				'( ISNULL(ysnInvoiced,0) = 1 )'
				,'boolean'
				,@filterGuid

			IF (ISNULL(@strCustomerNumber,'') != '')
			BEGIN
				--SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' + 
				--' (' + @CustomerNameValue  + ' = ' + '''' + @CustomerName + '''' + ' )' END

				INSERT INTO tblCFOptFilterParam (
				strFilter
				,strDataType
				,strGuid
				)
				SELECT 
				' ( strCustomerNumber = ' + '''' + @strCustomerNumber + '''' + ' )' 
				,'string'
				,@filterGuid

			END
		END
		ELSE IF (ISNULL(@ysnIncludePrintedTransaction,0) = 0)
		BEGIN
			
			--APPEND FILTER FOR NON REPRINT
			INSERT INTO tblCFOptFilterParam (
				 strFilter
				,strDataType
				,strGuid
			)
			SELECT 
				'( ISNULL(ysnInvoiced,0) = 0 )'
				,'boolean'
				,@filterGuid

		END

		DECLARE @tblCFTransactionIds TABLE ([intTransactionId]	INT)
		DECLARE @tblCFAccountIds TABLE ([intAccountId]	INT)
		DECLARE @tblCFInvoiceNumbers TABLE (
			[intAccountId]	INT,
			[strInvoiceNumber]	NVARCHAR(MAX)
		)


		BEGIN TRY
			DECLARE @guid NVARCHAR(MAX)
			DECLARE @tableName NVARCHAR(MAX)
			DECLARE @field NVARCHAR(MAX)
			DECLARE @dynamicsql NVARCHAR(MAX)
			DECLARE @temptable NVARCHAR(MAX)

			SET @guid = @filterGuid
			
			SET @field = 'intTransactionId'
			SET @temptable = '##'+REPLACE(@guid,'-','')

			IF(ISNULL(@ysnReprintInvoice,0) = 1 AND @dtmInvoiceDate IS NOT NULL)
			BEGIN
				SET @tableName = 'vyuCFInvoiceReportForReprint'
			END
			ELSE IF (ISNULL(@ysnIncludePrintedTransaction,0) = 1)
			BEGIN
				SET @tableName = 'vyuCFInvoiceReportAllTrans'
			END
			ELSE
			BEGIN
				SET @tableName = 'vyuCFInvoiceReportForNewPrint'
			END


			IF OBJECT_ID('tempdb..' + @temptable) IS NOT NULL
			BEGIN
				SET @dynamicsql = 'DROP TABLE ' + @temptable
				EXEC(@dynamicsql)
			END

			--GET DATA USING CUSTOMER EXECUTE PLAN--
			--RESULT STORED IN @temptable
			EXEC uspCFOptimizeFiltering 
			 @tableName = @tableName
			,@field = @field
			,@guid = @guid
			,@outTable = @temptable

			SET @dynamicsql = 'SELECT ' + @field + ' FROM ' + @temptable

			INSERT INTO @tblCFTransactionIds
			EXEC(@dynamicsql)

			IF OBJECT_ID('tempdb..' + @temptable) IS NOT NULL
			BEGIN
				SET @dynamicsql = 'DROP TABLE ' + @temptable
				EXEC(@dynamicsql)
			END
		END TRY
		BEGIN CATCH
			IF OBJECT_ID('tempdb..' + @temptable) IS NOT NULL
			BEGIN
				SET @dynamicsql = 'DROP TABLE ' + @temptable
				EXEC(@dynamicsql)
			END
		END CATCH 

		--INSERT INTO @tblCFTransactionIds
		--EXEC uspCFOptimizeFiltering @tableName = 'vyuCFInvoiceReport',@field = 'intTransactionId', @guid = @filterGuid

		DECLARE  @tblCFTempInvoiceReport  TABLE
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
			,intVehicleId					INT
			,intDriverPinId					INT
			----------------------------------------------------
			,dtmTransactionDate				DATETIME
			,dtmInvoiceDate					DATETIME
			,dtmPostedDate					DATETIME
			,dtmCreatedDate					DATETIME
			,dtmDate						DATETIME
			,dtmBillingDate					DATETIME
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
			,strDetailDisplay				NVARCHAR(MAX)
			,strDriverPinNumber				NVARCHAR(MAX)
			,strDriverDescription			NVARCHAR(MAX)
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
			,ysnInvalid							BIT
			,ysnPosted							BIT
			,ysnPostedCSV						BIT
			,ysnPrintMiscellaneous				BIT
			,ysnSummaryByCard					BIT
			,ysnSummaryByDepartmentProduct		BIT
			,ysnSummaryByDepartment				BIT
			,ysnSummaryByMiscellaneous			BIT
			,ysnSummaryByProduct				BIT
			,ysnSummaryByVehicle				BIT
			,ysnSummaryByCardProd				BIT
			,ysnSummaryByDeptCardProd			BIT
			,ysnPrintTimeOnInvoices				BIT
			,ysnPrintTimeOnReports				BIT
			,ysnSummaryByDeptVehicleProd		BIT
			,ysnDepartmentGrouping				BIT
			,ysnPostForeignSales				BIT
			,ysnExpensed						BIT
			,ysnSummaryByDriverPin				BIT
			,ysnMPGCalculation					BIT
			,ysnShowVehicleDescriptionOnly		BIT
			,ysnShowDriverPinDescriptionOnly	BIT
			,ysnPageBreakByPrimarySortOrder		BIT
			,ysnSummaryByDeptDriverPinProd		BIT
			,strDepartmentGrouping				NVARCHAR(MAX)
		)
		INSERT INTO @tblCFTempInvoiceReport(
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
			,intVehicleId	
			,intDriverPinId			
			----------------------------
			,dtmTransactionDate			
			,dtmInvoiceDate				
			,dtmPostedDate				
			,dtmCreatedDate				
			,dtmDate		
			,dtmBillingDate			
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
			,strDetailDisplay				
			,strDriverPinNumber				
			,strDriverDescription		
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
			,ysnSummaryByDepartmentProduct
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
			,ysnExpensed				
			,ysnSummaryByDriverPin		
			,ysnMPGCalculation
			,ysnShowVehicleDescriptionOnly	
			,ysnShowDriverPinDescriptionOnly
			,ysnPageBreakByPrimarySortOrder
			,ysnSummaryByDeptDriverPinProd
			,strDepartmentGrouping
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
			,intVehicleId	
			,intDriverPinId			
			----------------------------
			,dtmTransactionDate			
			,dtmInvoiceDate				
			,dtmPostedDate				
			,dtmCreatedDate				
			,dtmDate		
			,dtmBillingDate			
			----------------------------
			,strTransactionId			
			,strTransactionType			
			,strInvoiceReportNumber		
			,strInvoiceReportNumber	
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
			,strDetailDisplay				
			,strDriverPinNumber				
			,strDriverDescription		
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
			,ysnSummaryByDepartmentProduct	
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
			,ysnExpensed				
			,ysnSummaryByDriverPin		
			,ysnMPGCalculation
			,ysnShowVehicleDescriptionOnly	
			,ysnShowDriverPinDescriptionOnly
			,ysnPageBreakByPrimarySortOrder
			,ysnSummaryByDeptDriverPinProd
			,strDepartmentGrouping
		FROM vyuCFInvoiceReport
		WHERE intTransactionId IN (SELECT intTransactionId FROM @tblCFTransactionIds)
		

		IF(ISNULL(@ysnReprintInvoice,0) = 0 OR ISNULL(@ysnIncludePrintedTransaction,0) = 1) 
		BEGIN 
			-----------CREATE ID WITH INVOICE NUMBER--------

			INSERT INTO  @tblCFAccountIds (intAccountId)
			SELECT DISTINCT ISNULL(intAccountId,0) FROM @tblCFTempInvoiceReport

			DECLARE @intTempAccountCounter INT
			DECLARE @intTempAccountId	INT
			DECLARE @CFID NVARCHAR(MAX)
			WHILE (EXISTS(SELECT 1 FROM @tblCFAccountIds))
			BEGIN

				SELECT TOP 1 @intTempAccountCounter = [intAccountId] , @intTempAccountId = [intAccountId]  FROM @tblCFAccountIds

				EXEC uspSMGetStartingNumber 53, @CFID OUT

				INSERT INTO @tblCFInvoiceNumbers (
					 [intAccountId]
					,[strInvoiceNumber]
				)
				VALUES(
					 @intTempAccountId
					,@CFID
				)

				DELETE FROM @tblCFAccountIds WHERE [intAccountId] = @intTempAccountId

			END
			-----------CREATE ID WITH INVOICE NUMBER--------

		
			--UPDATE INVOICE NUMBER
			UPDATE @tblCFTempInvoiceReport 
			SET 
				 strPrintTimeStamp = @strPrintTimeStamp 
				,dtmInvoiceDate = @dtmInvoiceDate
				,strTempInvoiceReportNumber = tblCFInvoiceNumbers.strInvoiceNumber
				FROM @tblCFInvoiceNumbers AS tblCFInvoiceNumbers
				WHERE [@tblCFTempInvoiceReport].intAccountId = tblCFInvoiceNumbers.intAccountId
		END
		
		---------GET DISTINCT TRANSACTION ID FOR LOOPING---------
		
		INSERT INTO tblCFInvoiceReportTempTable (
		intCustomerGroupId			
		,intTransactionId			
		,intOdometer				
		,intOdometerAging			
		,intVehicleId		
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
		,strDepartmentDescription			
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
		,ysnSummaryByDepartmentProduct
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
		,ysnExpensed
		,intDriverPinId		
		,ysnSummaryByDriverPin
		,strDetailDisplay			
		,strDriverPinNumber			
		,strDriverDescription
		,ysnMPGCalculation
		,ysnShowVehicleDescriptionOnly	
		,ysnShowDriverPinDescriptionOnly
		,ysnPageBreakByPrimarySortOrder
		,ysnSummaryByDeptDriverPinProd
		,strDepartmentGrouping
		,strStatementType
		)
		SELECT
		 intCustomerGroupId			
		,intTransactionId			
		,intOdometer				
		,intOdometerAging	
		,intVehicleId				
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
		,strDepartmentDescription				
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
		,ysnSummaryByDepartmentProduct
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
		,ysnExpensed
		,intDriverPinId		
		,ysnSummaryByDriverPin
		,strDetailDisplay			
		,strDriverPinNumber			
		,strDriverDescription
		,ysnMPGCalculation
		,ysnShowVehicleDescriptionOnly	
		,ysnShowDriverPinDescriptionOnly
		,ysnPageBreakByPrimarySortOrder
		,ysnSummaryByDeptDriverPinProd
		,strDepartmentGrouping
		,@StatementType
		FROM @tblCFTempInvoiceReport

	END
    
END