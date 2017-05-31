CREATE PROCEDURE [dbo].[uspCFInvoiceReportSummary](
	@xmlParam NVARCHAR(MAX)=null
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
		FROM [fnCFSplitString]('intAccountId,strNetwork,strCustomerName,dtmTransactionDate,dtmPostedDate,strInvoiceCycle,strPrintTimeStamp',',') 

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
		FROM vyuCFInvoiceReportSummary ' + @whereClause)

		--SELECT  * FROM tblCFInvoiceSummaryTempTable
		---EXEC('SELECT * FROM vyuCFInvoiceReportSummary ' + @whereClause)
	END
    
END