﻿
CREATE PROCEDURE [dbo].[uspCFBatchRecalculate](
	@xmlParam NVARCHAR(MAX)=null
)
AS
BEGIN
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	BEGIN 
	SELECT 
		 strError		   = 'no parameter'
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
		FROM [fnCFSplitString]('intSiteId,intNetworkId,intEntityId,dtmTransactionDate',',') 

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

		DELETE tblCFBatchRecalculateStagingTable
		
		EXEC ('DECLARE @guid AS NVARCHAR(MAX) = NEWID()
		
		INSERT INTO tblCFBatchRecalculateStagingTable
		(
		 strBatchRecalculateId
		,intTransactionId
		,strTransactionId
		,intSiteId
		,intNetworkId
		,dtmTransactionDate
		,intCustomerId
		,dblTotalAmount
		,strNetwork
		,strPriceMethod
		,strStatus)
		SELECT
		@guid
		,intTransactionId
		,strTransactionId
		,intSiteId
		,intNetworkId
		,dtmTransactionDate
		,intCustomerId
		,dblTotalAmount
		,strNetwork
		,strPriceMethod
		,''Ready''
		FROM vyuCFTransactionForBatchRecalculate' + @whereClause)

		SELECT * FROM tblCFBatchRecalculateStagingTable

		--SELECT @whereClause
		
	END
    
END