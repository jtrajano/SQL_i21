﻿CREATE PROCEDURE [dbo].[uspCFTopCardLockCustomerReport](
	@xmlParam NVARCHAR(MAX)=null
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 

	IF (ISNULL(@xmlParam,'') = '')

	BEGIN 
		SELECT 
		 intEntityCustomerId			= 0
		,strCustomerNumber				= ''
		,strName						= ''
		,dblQtyShipped					= 0.0
		,dblQtyOrdered					= 0.0
		,dblInvoiceTotal				= 0.0
		RETURN;
	END
	ELSE
	BEGIN 
		DECLARE @idoc INT
		DECLARE @YTDwhereClause NVARCHAR(MAX)
		DECLARE @PYTDwhereClause NVARCHAR(MAX)
		
		DECLARE @From NVARCHAR(MAX)
		DECLARE @To NVARCHAR(MAX)
		DECLARE @Condition NVARCHAR(MAX)
		DECLARE @Fieldname NVARCHAR(MAX)

		DECLARE @tblCFFieldList TABLE
		(
			[intFieldId]   INT , 
			[strFieldId]   NVARCHAR(MAX)   
		)
		
		SET @YTDwhereClause = ''
		SET @PYTDwhereClause = ''

		INSERT INTO @tblCFFieldList(
			 [intFieldId]
			,[strFieldId]
		)
		SELECT 
			 RecordKey
			,Record
		FROM [fnCFSplitString]('strCustomerNumber,intEntityCustomerId,dtmDate',',') 

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
				IF(@Fieldname = 'dtmDate')
				BEGIN
					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) ' + @Condition + ' ' + '''' + CONVERT(varchar, DATEADD(year, -1, @From), 120) + '''' + ' AND ' +  '''' + CONVERT(varchar, DATEADD(year, -1, @To), 120) + '''' + ' )'

					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'

					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
				END
			END
			ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','='))
			BEGIN
				IF(@Fieldname = 'dtmDate')
				BEGIN
					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) ' + ' = ' + '''' + @From  + '''' + ' )'

					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) '  + ' = ' + '''' + CONVERT(varchar, DATEADD(year, -1, @From), 120)  + '''' + ' )'
				END
				ELSE
					BEGIN
					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'

					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
				END
			END
			ELSE IF (UPPER(@Condition) = 'IN')
			BEGIN
					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'

					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
			END
			ELSE IF (UPPER(@Condition) = 'GREATER THAN')
			BEGIN
				IF(@Fieldname = 'dtmDate')
				BEGIN
					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) '  + ' >= ' + '''' + @From + '''' + ' )'

					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) '  + ' >= ' + '''' + CONVERT(varchar, DATEADD(year, -1, @From), 120) + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'

					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'
				END
			END
			ELSE IF (UPPER(@Condition) = 'LESS THAN')
			BEGIN
				IF(@Fieldname = 'dtmDate')
				BEGIN
					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) '  + ' <= ' + '''' + @From + '''' + ' )'

					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					'( DATEADD(dd, DATEDIFF(dd, 0, '  + @Fieldname + ' ), 0) '  + ' <= ' + '''' + CONVERT(varchar, DATEADD(year, -1, @To), 120) + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @YTDwhereClause = @YTDwhereClause + CASE WHEN RTRIM(@YTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'

					SET @PYTDwhereClause = @PYTDwhereClause + CASE WHEN RTRIM(@PYTDwhereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
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

		DECLARE @tblYTD TABLE
		(
			 intEntityCustomerId		INT
			,dtmDate					DATETIME
			,strCustomerNumber			NVARCHAR(MAX)
			,strName					NVARCHAR(MAX)
			,strContactName				NVARCHAR(MAX)
			,strPhoneNumber				NVARCHAR(MAX)
			,dblQtyShipped				NUMERIC(18,6)
			,dblQtyOrdered				NUMERIC(18,6)
			,dblInvoiceTotal			NUMERIC(18,6)
		)

		DECLARE @tblPYTD TABLE
		(
			 intEntityCustomerId		INT
			,dtmDate					DATETIME
			,strCustomerNumber			NVARCHAR(MAX)
			,strName					NVARCHAR(MAX)
			,dblQtyShipped				NUMERIC(18,6)
			,dblQtyOrdered				NUMERIC(18,6)
			,dblInvoiceTotal			NUMERIC(18,6)
		)


		DECLARE @dblTotal NUMERIC(18,6)

		DECLARE @q NVARCHAR(max)


		INSERT INTO @tblYTD
		(
			 intEntityCustomerId
			,strCustomerNumber	
			,strName			
			,strPhoneNumber		
			,strContactName		
			,dblQtyShipped		
			,dblQtyOrdered		
			,dblInvoiceTotal	
		)
		EXEC('
		SELECT 
			intEntityCustomerId
			,strCustomerNumber
			,strName
			,strPhoneNumber
			,strContactName
			,SUM(dblQtyShipped) dblQtyShipped
			,SUM(dblQtyOrdered) dblQtyOrdered
			,SUM(dblInvoiceTotal) dblInvoiceTotal
		FROM [vyuCFTopCardLockCustomer]'
		+ @YTDwhereClause + 
		'GROUP BY 
		intEntityCustomerId
		,strCustomerNumber
		,strName
		,strPhoneNumber
		,strContactName')


		
		INSERT INTO @tblPYTD
		(
			 intEntityCustomerId
			,strCustomerNumber	
			,strName			
			,dblQtyShipped		
			,dblQtyOrdered		
			,dblInvoiceTotal	
		)
		EXEC('
		SELECT 
			intEntityCustomerId
			,strCustomerNumber
			,strName
			,SUM(dblQtyShipped) dblQtyShipped
			,SUM(dblQtyOrdered) dblQtyOrdered
			,SUM(dblInvoiceTotal) dblInvoiceTotal
		FROM [vyuCFTopCardLockCustomer]'
		+ @PYTDwhereClause +
		'GROUP BY 
		intEntityCustomerId
		,strCustomerNumber
		,strName')

		SELECT @dblTotal = SUM(dblInvoiceTotal)
		FROM @tblYTD


		SELECT 
		row_number() OVER (order by ytd.dblInvoiceTotal desc) as intRankId
		,ytd.intEntityCustomerId
		,ytd.strCustomerNumber
		,ytd.strName 
		,ytd.dblQtyShipped as dblYTDQtyShipped
		,ytd.dblQtyOrdered as dblYTDQtyOrdered
		,ytd.dblInvoiceTotal as dblYTDInvoiceTotal
		,ytd.dblInvoiceTotal / ISNULL(@dblTotal,0) as dblPercentOfTotal
		,pytd.dblQtyShipped as dblPYTDQtyShipped
		,pytd.dblQtyOrdered as dblPYTDQtyOrdered
		,pytd.dblInvoiceTotal as dblPYTDInvoiceTotal
		,ytd.strContactName 
		,ytd.strPhoneNumber
		FROM 
		@tblYTD as ytd
		LEFT JOIN
		@tblPYTD as pytd
		on 
		ytd.intEntityCustomerId = pytd.intEntityCustomerId


	END

	

	

	END TRY
	BEGIN CATCH

		SELECT ERROR_MESSAGE()


	END CATCH 
    
END