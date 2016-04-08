
CREATE PROCEDURE uspCFInvoiceReport(
	@xmlParam NVARCHAR(MAX)=null
)
AS
BEGIN
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
	SELECT 
		 intTransactionId		   = 0
		,intInvoiceId			   = 0
		,intProductId			   = 0
		,intCardId				   = 0
		,EXPR18					   = 0
		,intAccountId			   = 0
		,intInvoiceCycle		   = 0
		,strCustomerNumber		   = ''
		,strShipTo				   = ''
		,strBillTo				   = ''
		,strCompanyName			   = ''
		,strCompanyAddress		   = ''
		,strType				   = ''
		,strCustomerName		   = ''
		,strLocationName		   = ''
		,strInvoiceReportNumber	   = ''
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
		RETURN;
	END
	ELSE
	BEGIN 
		DECLARE @idoc INT
		DECLARE @whereClause NVARCHAR(MAX)
		
		DECLARE @From NVARCHAR(50)
		DECLARE @To NVARCHAR(50)
		DECLARE @Condition NVARCHAR(50)
		DECLARE @Fieldname NVARCHAR(50)

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
		FROM [fnCFSplitString]('intAccountId,strNetwork,strCustomerName,dtmTransactionDate,dtmPostedDate,strInvoiceCylcle',',') 

		--READ XML
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam

		--TEMP TABLE FOR PARAMETERS
		DECLARE @temp_params TABLE (
			 [fieldname] NVARCHAR(50)
			,[condition] NVARCHAR(20)      
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50) 
			,[datatype] NVARCHAR(50)
		) 

		--XML DATA TO TABLE
		INSERT INTO @temp_params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH ([fieldname] NVARCHAR(50)
			, [condition] NVARCHAR(20)
			, [from] NVARCHAR(50)
			, [to] NVARCHAR(50)
			, [join] NVARCHAR(10)
			, [begingroup] NVARCHAR(50)
			, [endgroup] NVARCHAR(50)
			, [datatype] NVARCHAR(50))



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

		SET @From = ''
		SET @To = ''
		SET @Condition = ''
		SET @Fieldname = ''

		--MAIN LOOP

			DELETE FROM @tblCFFieldList WHERE [intFieldId] = @intCounter
		END


		--INCLUDE PRINTED TRANSACTION
		SELECT TOP 1
			 @From = [from]
			,@To = [to]
			,@Condition = [condition]
			,@Fieldname = [fieldname]
		FROM @temp_params WHERE [fieldname] = 'ysnIncludePrintedTransaction'

		IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'FALSE' OR @From = 0))
		BEGIN
			SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' ( strInvoiceReportNumber  IS NULL )'
		END
		ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','=') AND (@From = 'TRUE' OR @From = 1))
		BEGIN

			DECLARE @tblCFTempTable TABLE
			(
				[intAccountId] INT
			)

			DECLARE @intTempCounter INT
			DECLARE @intTempAccountId	INT
			DECLARE @CFID NVARCHAR(50)
			DECLARE @tblCFTempTableQuery nvarchar(MAX)

			---------GET DISTINCT ACCOUNT ID---------
			SET @tblCFTempTableQuery = 'SELECT DISTINCT intAccountId FROM vyuCFInvoiceReport ' + @whereClause

			INSERT INTO  @tblCFTempTable (intAccountId)
			EXEC (@tblCFTempTableQuery)
			---------GET DISTINCT ACCOUNT ID---------

			WHILE (EXISTS(SELECT 1 FROM @tblCFTempTable))
			BEGIN

				SELECT @intTempCounter = [intAccountId] FROM @tblCFTempTable
				SELECT @intTempAccountId = [intAccountId] FROM @tblCFTempTable WHERE [intAccountId] = @intTempCounter

				---------UPDATE INVOICE REPORT NUMBER ID---------
				EXEC uspSMGetStartingNumber 53, @CFID OUT
				IF(@CFID IS NOT NULL)
				BEGIN
				
					EXEC('UPDATE tblCFTransaction SET strInvoiceReportNumber = ' + '''' + @CFID + '''' + ' WHERE intCardId = (SELECT TOP 1 intCardId FROM tblCFCard WHERE intAccountId =' + @intTempAccountId + ')')
				END
				---------UPDATE INVOICE REPORT NUMBER ID---------


				DELETE FROM @tblCFTempTable WHERE [intAccountId] = @intTempCounter
			END

		END

		EXEC('SELECT * FROM vyuCFInvoiceReport ' + @whereClause)

	END
    
END