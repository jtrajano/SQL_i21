﻿
CREATE PROCEDURE [dbo].[uspCFInvoiceReport](
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
		,intOdometer			   = 0
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
		,strVehicleNumber		   = ''
		,strVehicleDescription	   = ''
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

		DECLARE @tblCFTableCardIds TABLE ([intCardId]	INT)
		DECLARE @tblCFTableTransationIds TABLE ([intTransactionId]	INT)
		DECLARE @tblCFFilterIds TABLE ([intTransactionId]	INT)
		DECLARE @CFID NVARCHAR(50)
		DECLARE @tblCFTempTableQuery nvarchar(MAX)


		DECLARE @intTempCardCounter INT
		DECLARE @intTempCardId	INT
		DECLARE @tblCFInvoiceNunber TABLE (
			[intCardId]	INT,
			[strInvoiceNumber]	NVARCHAR(MAX)
		)

		---------GET DISTINCT CARD ID---------
		SET @tblCFTempTableQuery = 'SELECT DISTINCT intCardId FROM vyuCFInvoiceReport ' + @whereClause

		INSERT INTO  @tblCFTableCardIds (intCardId)
		EXEC (@tblCFTempTableQuery)
		---------GET DISTINCT CARD ID---------

		---------CREATE ID WITH INVOICE NUMBER--------
		WHILE (EXISTS(SELECT 1 FROM @tblCFTableCardIds))
		BEGIN

			SELECT @intTempCardCounter = [intCardId] FROM @tblCFTableCardIds
			SELECT @intTempCardId = [intCardId] FROM @tblCFTableCardIds WHERE [intCardId] = @intTempCardCounter

			EXEC uspSMGetStartingNumber 53, @CFID OUT

			INSERT INTO @tblCFInvoiceNunber (
					[intCardId]
				,[strInvoiceNumber]
			)
			VALUES(
					@intTempCardId
				,@CFID
			)

			DELETE FROM @tblCFTableCardIds WHERE [intCardId] = @intTempCardCounter

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
				SELECT @strInvoiceNumber = strInvoiceNumber from @tblCFInvoiceNunber where intCardId = (SELECT TOP 1 intCardId FROM tblCFTransaction WHERE intTransactionId = @intTempTransactionId)

				---------UPDATE INVOICE REPORT NUMBER ID---------
				IF(@CFID IS NOT NULL)
				BEGIN
				
					EXEC('UPDATE tblCFTransaction SET strInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
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
				SELECT @strInvoiceNumber = strInvoiceNumber from @tblCFInvoiceNunber where intCardId = (SELECT TOP 1 intCardId FROM tblCFTransaction WHERE intTransactionId = @intTempTransactionId)

				---------UPDATE INVOICE REPORT NUMBER ID---------
				IF(@CFID IS NOT NULL)
				BEGIN
				
					EXEC('UPDATE tblCFTransaction SET strInvoiceReportNumber = ' + '''' + @strInvoiceNumber + '''' + ' WHERE intTransactionId = ' + @intTempTransactionId)
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
		SELECT * FROM vyuCFInvoiceReport where intTransactionId in (SELECT intTransactionId FROM @tblCFFilterIds)
	END
    
END