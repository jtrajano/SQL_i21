CREATE PROCEDURE [dbo].[uspCFInvoiceReportDiscount](
	@xmlParam NVARCHAR(MAX)=null
)
AS
BEGIN
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
	SELECT 
		 intAccountId				 = 0
		,intInvoiceId				 = 0
		,intTransactionId			 = 0
		,intCustomerGroupId			 = 0
		,intTermID					 = 0
		,intBalanceDue				 = 0
		,intDiscountDay				 = 0
		,intDayofMonthDue			 = 0
		,intDueNextMonth			 = 0
		,intSort					 = 0
		,intConcurrencyId			 = 0
		,ysnAllowEFT				 = CAST(0 AS BIT)
		,ysnActive					 = CAST(0 AS BIT)
		,ysnEnergyTrac				 = CAST(0 AS BIT)
		,dblQuantity				 = 0.0
		,dblTotalQuantity			 = 0.0
		,dblDiscountRate			 = 0.0
		,dblDiscount				 = 0.0
		,dblTotalAmount				 = 0.0
		,dblAccountTotalAmount		 = 0.0
		,dblAccountTotalDiscount	 = 0.0
		,dblAccountTotalLessDiscount = 0.0
		,dblDiscountEP				 = 0.0
		,dblAPR						 = 0.0
		,strInvoiceNumber			 = ''
		,strInvoiceReportNumber		 = ''
		,strTerm					 = ''
		,strType					 = ''
		,strTermCode				 = ''
		,strNetwork					 = ''
		,strCustomerName			 = ''
		,strInvoiceCycle			 = ''
		,strGroupName				 = ''
		,dtmDiscountDate			 = GetDate()
		,dtmDueDate					 = GetDate()
		,dtmTransactionDate			 = GetDate()
		,dtmPostedDate				 = GetDate()
		RETURN;
	END
	ELSE
	BEGIN 
		DECLARE @idoc INT
		DECLARE @whereClause NVARCHAR(MAX)
		DECLARE @endWhereClause NVARCHAR(MAX)
		
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
		SET @endWhereClause = ''

		INSERT INTO @tblCFFieldList(
			 [intFieldId]
			,[strFieldId]
		)
		SELECT 
			 RecordKey
			,Record
		FROM [fnCFSplitString]('intCustomerGroupId,intAccountId,strNetwork,dtmTransactionDate,dtmPostedDate,strInvoiceCycle,strPrintTimeStamp',',') 


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
			IF(@Fieldname = 'intAccountId' OR @Fieldname = 'intCustomerGroupId' OR @Fieldname = 'strInvoiceReportNumber')
			BEGIN
				SET @endWhereClause = @endWhereClause + CASE WHEN RTRIM(@endWhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
			END
			ELSE
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
			END
		END
		ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','='))
		BEGIN
			IF(@Fieldname = 'intAccountId' OR @Fieldname = 'intCustomerGroupId' OR @Fieldname = 'strInvoiceReportNumber')
			BEGIN
				SET @endWhereClause = @endWhereClause + CASE WHEN RTRIM(@endWhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
			END
			ELSE
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
			END
		END
		ELSE IF (UPPER(@Condition) = 'IN')
		BEGIN
			IF(@Fieldname = 'intAccountId' OR @Fieldname = 'intCustomerGroupId' OR @Fieldname = 'strInvoiceReportNumber')
			BEGIN
				SET @endWhereClause = @endWhereClause + CASE WHEN RTRIM(@endWhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
			END
			ELSE
			BEGIN
				SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
				' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
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

		DECLARE @SQL NVARCHAR(MAX)

		-----------------------------------
		--**BEGIN DISCOUNT CALCULATION**---
		-----------------------------------
		
		-------------VARIABLES------------
		DECLARE @dblTotalQuantity NUMERIC(18,6)
		DECLARE @intDistinctDiscountLoop INT

		DECLARE @tblCFGroupVolumeDisctinct TABLE
		(
			 intCustomerGroupId INT
		)
		DECLARE @tblCFAccountVolumeDisctinct TABLE
		(
			 intAccountId INT
		)
		DECLARE @tblCFMergeVolumeDisctinct TABLE
		(
			 intAccountId INT
		)

		DECLARE @tblCFGroupVolumeTemp	TABLE
		(
			  intAccountId				INT
			 ,intSalesPersonId			INT
			 ,dtmInvoiceDate			DATETIME
			 ,intCustomerId				INT
			 ,intInvoiceId				INT
			 ,intTransactionId			INT
			 ,intCustomerGroupId		INT
			 ,intTermID					INT
			 ,intBalanceDue				INT
			 ,intDiscountDay			INT	
			 ,intDayofMonthDue			INT
			 ,intDueNextMonth			INT
			 ,intSort					INT
			 ,intConcurrencyId			INT
			 ,ysnAllowEFT				BIT
			 ,ysnActive					BIT
			 ,ysnEnergyTrac				BIT
			 ,dblQuantity				NUMERIC(18,6)
			 ,dblTotalQuantity			NUMERIC(18,6)
			 ,dblDiscountRate			NUMERIC(18,6)
			 ,dblDiscount				NUMERIC(18,6)
			 ,dblTotalAmount			NUMERIC(18,6)
			 ,dblAccountTotalAmount		NUMERIC(18,6)
			 ,dblDiscountEP				NUMERIC(18,6)
			 ,dblAPR					NUMERIC(18,6)	
			 ,strTerm					NVARCHAR(MAX)
			 ,strType					NVARCHAR(MAX)
			 ,strTermCode				NVARCHAR(MAX)	
			 ,strNetwork				NVARCHAR(MAX)	
			 ,strCustomerName			NVARCHAR(MAX)
			 ,strInvoiceCycle			NVARCHAR(MAX)
			 ,strGroupName				NVARCHAR(MAX)
			 ,strInvoiceNumber			NVARCHAR(MAX)
			 ,strInvoiceReportNumber	NVARCHAR(MAX)
			 ,dtmDiscountDate			DATETIME
			 ,dtmDueDate				DATETIME
			 ,dtmTransactionDate		DATETIME
			 ,dtmPostedDate				DATETIME

		)
		DECLARE @tblCFAccountVolumeTemp TABLE
		(
			  intAccountId				INT
			 ,intSalesPersonId			INT
			 ,dtmInvoiceDate			DATETIME
			 ,intCustomerId				INT
			 ,intInvoiceId				INT
			 ,intTransactionId			INT
			 ,intCustomerGroupId		INT
			 ,intTermID					INT
			 ,intBalanceDue				INT
			 ,intDiscountDay			INT	
			 ,intDayofMonthDue			INT
			 ,intDueNextMonth			INT
			 ,intSort					INT
			 ,intConcurrencyId			INT
			 ,ysnAllowEFT				BIT
			 ,ysnActive					BIT
			 ,ysnEnergyTrac				BIT
			 ,dblQuantity				NUMERIC(18,6)
			 ,dblTotalQuantity			NUMERIC(18,6)
			 ,dblDiscountRate			NUMERIC(18,6)
			 ,dblDiscount				NUMERIC(18,6)
			 ,dblTotalAmount			NUMERIC(18,6)
			 ,dblAccountTotalAmount		NUMERIC(18,6)
			 ,dblDiscountEP				NUMERIC(18,6)
			 ,dblAPR					NUMERIC(18,6)	
			 ,strTerm					NVARCHAR(MAX)
			 ,strType					NVARCHAR(MAX)
			 ,strTermCode				NVARCHAR(MAX)	
			 ,strNetwork				NVARCHAR(MAX)	
			 ,strCustomerName			NVARCHAR(MAX)
			 ,strInvoiceCycle			NVARCHAR(MAX)
			 ,strGroupName				NVARCHAR(MAX)
			 ,strInvoiceNumber			NVARCHAR(MAX)
			 ,strInvoiceReportNumber	NVARCHAR(MAX)
			 ,dtmDiscountDate			DATETIME
			 ,dtmDueDate				DATETIME
			 ,dtmTransactionDate		DATETIME
			 ,dtmPostedDate				DATETIME

		)
		CREATE TABLE ##tblCFInvoiceDiscount	
		(
			  intAccountId					INT
			 ,intSalesPersonId			    INT
			 ,dtmInvoiceDate			    DATETIME
			 ,intCustomerId					INT
			 ,intInvoiceId					INT
			 ,intTransactionId				INT
			 ,intCustomerGroupId			INT
			 ,intTermID						INT
			 ,intBalanceDue					INT
			 ,intDiscountDay				INT	
			 ,intDayofMonthDue				INT
			 ,intDueNextMonth				INT
			 ,intSort						INT
			 ,intConcurrencyId				INT
			 ,ysnAllowEFT					BIT
			 ,ysnActive						BIT
			 ,ysnEnergyTrac					BIT
			 ,dblQuantity					NUMERIC(18,6)
			 ,dblTotalQuantity				NUMERIC(18,6)
			 ,dblDiscountRate				NUMERIC(18,6)
			 ,dblDiscount					NUMERIC(18,6)
			 ,dblTotalAmount				NUMERIC(18,6)
			 ,dblAccountTotalAmount			NUMERIC(18,6)
			 ,dblAccountTotalDiscount		NUMERIC(18,6)
			 ,dblAccountTotalLessDiscount	NUMERIC(18,6)
			 ,dblDiscountEP					NUMERIC(18,6)
			 ,dblAPR						NUMERIC(18,6)	
			 ,strTerm						NVARCHAR(MAX)
			 ,strType						NVARCHAR(MAX)
			 ,strTermCode					NVARCHAR(MAX)	
			 ,strNetwork					NVARCHAR(MAX)	
			 ,strCustomerName				NVARCHAR(MAX)
			 ,strInvoiceCycle				NVARCHAR(MAX)
			 ,strGroupName					NVARCHAR(MAX)
			 ,strInvoiceNumber				NVARCHAR(MAX)
			 ,strInvoiceReportNumber		NVARCHAR(MAX)
			 ,dtmDiscountDate				DATETIME
			 ,dtmDueDate					DATETIME
			 ,dtmTransactionDate			DATETIME
			 ,dtmPostedDate					DATETIME

		)
		-------------VARIABLES------------

		
		----------GET DISCOUNT SCHEDULE------------
		SELECT 
		 intDiscountSchedDetailId
		,intDiscountScheduleId
		,intFromQty
		,intThruQty
		,dblRate
		,intConcurrencyId
		INTO #tmpdiscountschedule
		FROM tblCFDiscountScheduleDetail
		----------GET DISCOUNT SCHEDULE------------


		-----------------MAIN QUERY------------------
		EXEC('SELECT * 
		INTO ##tmpInvoiceDiscount
		FROM vyuCFInvoiceDiscount '+ @whereClause)
		-----------------MAIN QUERY------------------

		
		-------------GROUP VOLUME DISCOUNT---------------
		INSERT @tblCFGroupVolumeDisctinct
		SELECT DISTINCT intCustomerGroupId
		FROM ##tmpInvoiceDiscount
		WHILE (EXISTS(SELECT 1 FROM @tblCFGroupVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intCustomerGroupId FROM @tblCFGroupVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 
			@dblTotalQuantity = SUM(dblQuantity)	
			FROM ##tmpInvoiceDiscount as cfInvoice
			WHERE intCustomerGroupId = @intDistinctDiscountLoop
			GROUP BY intCustomerGroupId

			INSERT @tblCFGroupVolumeTemp(
				 intAccountId		
			    ,intSalesPersonId			
			    ,dtmInvoiceDate			
				,intCustomerId			
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
			)
			SELECT 
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate			
				,intCustomerId
				,intInvoiceId				
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,@dblTotalQuantity		
				,ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM #tmpdiscountschedule
					 WHERE (@dblTotalQuantity >= intFromQty AND @dblTotalQuantity < intThruQty) AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId), 0)
				,ROUND((ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM #tmpdiscountschedule
					 WHERE (@dblTotalQuantity >= intFromQty AND @dblTotalQuantity < intThruQty) AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId), 0) * dblQuantity),2)
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
			FROM ##tmpInvoiceDiscount as cfInvoice
			WHERE intCustomerGroupId = @intDistinctDiscountLoop

			END
			
			DELETE FROM @tblCFGroupVolumeDisctinct WHERE intCustomerGroupId = @intDistinctDiscountLoop
		END
		-------------GROUP VOLUME DISCOUNT---------------


		-------------ACCOUNT VOLUME DISCOUNT---------------
		INSERT @tblCFAccountVolumeDisctinct
		SELECT DISTINCT intAccountId
		FROM ##tmpInvoiceDiscount
		WHILE (EXISTS(SELECT 1 FROM @tblCFAccountVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intAccountId FROM @tblCFAccountVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 
			@dblTotalQuantity = SUM(dblQuantity)	
			FROM ##tmpInvoiceDiscount as cfInvoice
			WHERE intAccountId = @intDistinctDiscountLoop
			GROUP BY intAccountId

			INSERT @tblCFAccountVolumeTemp(
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate			
				,intCustomerId
				,intInvoiceId		
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
			)
			SELECT 
				 intAccountId				
			    ,intSalesPersonId			
			    ,dtmInvoiceDate	
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,@dblTotalQuantity		
				,ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM #tmpdiscountschedule
					 WHERE (@dblTotalQuantity >= intFromQty AND @dblTotalQuantity < intThruQty) AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId), 0)
				,ROUND((ISNULL(
					(SELECT TOP 1 ISNULL(dblRate, 0)
					 FROM #tmpdiscountschedule
					 WHERE (@dblTotalQuantity >= intFromQty AND @dblTotalQuantity < intThruQty) AND intDiscountScheduleId = cfInvoice.intDiscountScheduleId), 0) * dblQuantity),2)	
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
			FROM ##tmpInvoiceDiscount as cfInvoice
			WHERE intAccountId = @intDistinctDiscountLoop AND intCustomerGroupId = 0
			END
			
			DELETE FROM @tblCFAccountVolumeDisctinct WHERE intAccountId = @intDistinctDiscountLoop
		END
		-------------ACCOUNT VOLUME DISCOUNT---------------

		
		-------------MERGE ACCOUNT & GROUP VOLUME DISCOUNT---------------

		DECLARE @totalAccountDiscount				NUMERIC(18,6)
		DECLARE @totalAccountAmount					NUMERIC(18,6)
		DECLARE @totalAccountAmountLessDiscount		NUMERIC(18,6)

		-------------SET GROUP VOLUME TO OUTPUT---------------
		INSERT @tblCFMergeVolumeDisctinct
		SELECT DISTINCT intAccountId
		FROM @tblCFGroupVolumeTemp
		WHILE (EXISTS(SELECT 1 FROM @tblCFMergeVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intAccountId FROM @tblCFMergeVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 						
			 @totalAccountDiscount				= ROUND(ISNULL(SUM(dblDiscount),0),2)
			,@totalAccountAmount				= ISNULL(SUM(dblTotalAmount),0)
			,@totalAccountAmountLessDiscount	= ISNULL(ISNULL(SUM(dblTotalAmount),0) - ISNULL(SUM(dblDiscount),0),0)
			FROM @tblCFGroupVolumeTemp
			WHERE intAccountId = @intDistinctDiscountLoop

			INSERT INTO ##tblCFInvoiceDiscount(
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate		
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,dblAccountTotalAmount		
				,dblAccountTotalDiscount
				,dblAccountTotalLessDiscount	
			)
			SELECT 
				 intAccountId				
			    ,intSalesPersonId			
			    ,dtmInvoiceDate	
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity		
				,dblDiscountRate
				,dblDiscount
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate	
				,@totalAccountAmount		
				,@totalAccountDiscount				
				,@totalAccountAmountLessDiscount
			FROM @tblCFGroupVolumeTemp as cfGroupVolumeDiscount
			WHERE intAccountId = @intDistinctDiscountLoop

			END
			
			DELETE FROM @tblCFMergeVolumeDisctinct WHERE intAccountId = @intDistinctDiscountLoop
		END
		-------------SET GROUP VOLUME TO OUTPUT---------------


		-------------SET ACCOUNT VOLUME TO OUTPUT---------------
		INSERT @tblCFMergeVolumeDisctinct
		SELECT DISTINCT intAccountId
		FROM @tblCFAccountVolumeTemp
		WHILE (EXISTS(SELECT 1 FROM @tblCFMergeVolumeDisctinct))
		BEGIN
	
			SELECT @intDistinctDiscountLoop = intAccountId FROM @tblCFMergeVolumeDisctinct

			IF(@intDistinctDiscountLoop != 0)
			BEGIN

			SELECT 						
			 @totalAccountDiscount				= ROUND(ISNULL(SUM(dblDiscount),0),2)
			,@totalAccountAmount				= ISNULL(SUM(dblTotalAmount),0)
			,@totalAccountAmountLessDiscount	= ISNULL(ISNULL(SUM(dblTotalAmount),0) - ISNULL(SUM(dblDiscount),0),0)
			FROM @tblCFAccountVolumeTemp
			WHERE intAccountId = @intDistinctDiscountLoop

			INSERT INTO ##tblCFInvoiceDiscount(
				 intAccountId				
			    ,intSalesPersonId			
			    ,dtmInvoiceDate	
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity	
				,dblDiscountRate	
				,dblDiscount		
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate		
				,dblAccountTotalAmount		
				,dblAccountTotalDiscount
				,dblAccountTotalLessDiscount	
			)
			SELECT 
				 intAccountId			
			    ,intSalesPersonId			
			    ,dtmInvoiceDate		
				,intCustomerId
				,intInvoiceId			
				,intTransactionId	
				,intCustomerGroupId
				,intTermID			
				,intBalanceDue		
				,intDiscountDay	
				,intDayofMonthDue	
				,intDueNextMonth	
				,intSort			
				,intConcurrencyId	
				,ysnAllowEFT		
				,ysnActive			
				,ysnEnergyTrac		
				,dblQuantity		
				,dblTotalQuantity		
				,dblDiscountRate
				,dblDiscount
				,dblTotalAmount	
				,dblDiscountEP		
				,dblAPR			
				,strTerm			
				,strType			
				,strTermCode		
				,strNetwork		
				,strCustomerName	
				,strInvoiceCycle	
				,strGroupName
				,strInvoiceNumber
				,strInvoiceReportNumber
				,dtmDiscountDate	
				,dtmDueDate		
				,dtmTransactionDate
				,dtmPostedDate	
				,@totalAccountAmount		
				,@totalAccountDiscount				
				,@totalAccountAmountLessDiscount
			FROM @tblCFAccountVolumeTemp as cfAccountVolumeDiscount
			WHERE intAccountId = @intDistinctDiscountLoop

			END
			
			DELETE FROM @tblCFMergeVolumeDisctinct WHERE intAccountId = @intDistinctDiscountLoop
		END
		-------------SET ACCOUNT VOLUME TO OUTPUT---------------

		-------------MERGE ACCOUNT & GROUP VOLUME DISCOUNT---------------


		----------------------------------
		---**END DISCOUNT CALCULATION**---
		----------------------------------

		-------------SELECT MAIN TABLE FOR OUTPUT---------------
		EXEC('
		INSERT INTO tblCFInvoiceDiscountTempTable(
			 intSalesPersonId
			,intTermID
			,intBalanceDue
			,intDiscountDay
			,intDayofMonthDue
			,intDueNextMonth
			,intSort
			,strTerm
			,strTermCode
			,dtmDiscountDate
			,dtmDueDate
			,dtmInvoiceDate
			,dblDiscountRate
			,dblDiscount
			,dblAccountTotalAmount
			,dblAccountTotalDiscount
			,dblAccountTotalLessDiscount
			,dblDiscountEP
			,dblAPR
			,intAccountId
			,intTransactionId)
		SELECT 
			 intSalesPersonId
			,intTermID
			,intBalanceDue
			,intDiscountDay
			,intDayofMonthDue
			,intDueNextMonth
			,intSort
			,strTerm
			,strTermCode
			,dtmDiscountDate
			,dtmDueDate
			,dtmInvoiceDate
			,dblDiscountRate
			,dblDiscount
			,dblAccountTotalAmount
			,dblAccountTotalDiscount
			,dblAccountTotalLessDiscount
			,dblDiscountEP
			,dblAPR
			,intAccountId
			,intTransactionId
	    FROM ##tblCFInvoiceDiscount' + @endWhereClause) 

		--EXEC('SELECT * FROM ##tblCFInvoiceDiscount ' + @endWhereClause) 
		SELECT * FROM tblCFInvoiceDiscountTempTable
		-------------SELECT MAIN TABLE FOR OUTPUT---------------

		-------------DROP TEMPORARY TABLES---------------
		DROP TABLE #tmpdiscountschedule
		DROP TABLE ##tmpInvoiceDiscount
		DROP TABLE ##tblCFInvoiceDiscount
		-------------DROP TEMPORARY TABLES---------------

	END
END