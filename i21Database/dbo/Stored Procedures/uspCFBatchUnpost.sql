CREATE PROCEDURE [dbo].[uspCFBatchUnpost](
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
		FROM [fnCFSplitString]('intSiteId,intNetworkId,intCustomerId,dtmTransactionDate,dtmCreatedDate,strTransactionId,intARItemId',',') 

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


		SET @whereClause = ' WHERE (ISNULL(ysnPosted,0) = 1) AND (ISNULL(ysnInvoiced,0) = 0)  AND (ISNULL(ysnPostedCSV,0) = 0) '

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
				IF(@Fieldname = 'strTransactionId')
				BEGIN
					SET @Fieldname = 'CONVERT(int,(REPLACE(t.strTransactionId,''CFDT-'','''')))'
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + 't.' + @Fieldname  + ' ' + @Condition + ' ' + '''' + @From + '''' + ' AND ' +  '''' + @To + '''' + ' )'
				END
				
			END
			ELSE IF (UPPER(@Condition) in ('EQUAL','EQUALS','EQUAL TO','EQUALS TO','='))
			BEGIN
				IF(@Fieldname = 'strTransactionId')
				BEGIN
					SET @Fieldname = 'CONVERT(int,(REPLACE(t.strTransactionId,''CFDT-'','''')))'
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' +  @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + 't.' +  @Fieldname  + ' = ' + '''' + @From + '''' + ' )'
				END
			END
			ELSE IF (UPPER(@Condition) = 'IN')
			BEGIN
				IF(@Fieldname = 'strTransactionId')
				BEGIN
					SET @Fieldname = 'CONVERT(int,(REPLACE(t.strTransactionId,''CFDT-'','''')))'
							SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' +  @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
				END
				ELSE
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + 't.' +  @Fieldname  + ' IN ' + '(' + '''' + REPLACE(@From,'|^|',''',''') + '''' + ')' + ' )'
				END
			END
			ELSE IF (UPPER(@Condition) = 'GREATER THAN')
			BEGIN
				IF(@Fieldname = 'strTransactionId')
				BEGIN
					SET @Fieldname = 'CONVERT(int,(REPLACE(t.strTransactionId,''CFDT-'','''')))'
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' +  @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + 't.' +  @Fieldname  + ' >= ' + '''' + @From + '''' + ' )'
				END
			END
			ELSE IF (UPPER(@Condition) = 'LESS THAN')
			BEGIN
				IF(@Fieldname = 'strTransactionId')
				BEGIN
					SET @Fieldname = 'CONVERT(int,(REPLACE(t.strTransactionId,''CFDT-'','''')))'
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' +  @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'
				END
				ELSE
				BEGIN
					SET @whereClause = @whereClause + CASE WHEN RTRIM(@whereClause) = '' THEN ' WHERE ' ELSE ' AND ' END + 
					' (' + 't.' +  @Fieldname  + ' <= ' + '''' + @To + '''' + ' )'
				END
			END

			SET @From = ''
			SET @To = ''
			SET @Condition = ''
			SET @Fieldname = ''


		--MAIN LOOP

			DELETE FROM @tblCFFieldList WHERE [intFieldId] = @intCounter
		END

		DELETE tblCFBatchUnpostStagingTable
		
		--SELECT @whereClause

		DECLARE @q NVARCHAR(MAX)
		SET @q = ('DECLARE @guid AS NVARCHAR(MAX) = NEWID()
		
		INSERT INTO tblCFBatchUnpostStagingTable
		(
			 intTransactionId
			,strTransactionId
			,dtmTransactionDate
			,dtmPostedDate
			,intNetworkId
			,strNetworkId
			,intSiteId
			,strSiteId
			,intCustomerId
			,strCustomerNumber
			,strCustomerName
			,intItemId
			,strItemId
			,strItemDescription
			,strGuid
			,strResult
		)
		SELECT
			intTransactionId
			,strTransactionId
			,dtmTransactionDate
			,dtmPostedDate
			,n.intNetworkId
			,n.strNetwork
			,s.intSiteId
			,s.strSiteNumber
			,c.intCustomerId
			,c.strCustomerNumber
			,c.strName
			,i.intItemId
			,i.strProductNumber
			,ic.strDescription
			,@guid
			,''Ready''
		FROM tblCFTransaction as t
		INNER JOIN tblCFNetwork as n
		ON t.intNetworkId = n.intNetworkId
		INNER JOIN tblCFSite as s
		ON t.intSiteId = s.intSiteId
		INNER JOIN tblCFItem as i
		ON t.intProductId = i.intItemId
		INNER JOIN tblICItem as ic
		ON ic.intItemId = i.intItemId
		INNER JOIN vyuCFAccountCustomer c
		ON t.intCustomerId = c.intCustomerId' + @whereClause)

		EXEC(@q)

		SELECT * FROM tblCFBatchUnpostStagingTable

		--SELECT @whereClause
		
	END
    
END