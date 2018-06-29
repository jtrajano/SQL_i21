CREATE PROCEDURE [dbo].[uspCTGenerateWhereClause]
	@strDataXML		NVARCHAR(MAX),
	@strMappingXML	NVARCHAR(MAX),
	@strClause		NVARCHAR(MAX) OUTPUT
AS
/*	EXAMPLE
	DECLARE @strClause NVARCHAR(MAX)

	EXEC	uspCTGenerateWhereClause
			@strDataXML= '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>ContractDate</fieldname><condition>Between</condition><from>2017-07-01</from><to>2017-07-31</to><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter><filter><fieldname>Position</fieldname><condition>Equal To</condition><from>Arrival</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>Vendor</fieldname><condition>Equal To</condition><from>A. Tosh &amp; Sons (India) Limited</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>ProductType</fieldname><condition>Equal To</condition><from>Unwashed Arabica</from><join>AND</join><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>StartDate</fieldname><condition>Equal To</condition><from>10/06/2017</from><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter><filter><fieldname>EndDate</fieldname><condition>Equal To</condition><from>10/06/2017</from><join>AND</join><begingroup /><endgroup /><datatype>DateTime</datatype></filter></filters><sorts /></xmlparam>'
		   ,@strMappingXML = '<mappings><mapping><fieldname>ContractDate</fieldname><fromField>dtmContractDate</fromField><toField></toField><ignoreTime>1</ignoreTime></mapping><mapping><fieldname>StartDate</fieldname><fromField>dtmStartDate</fromField><toField>dtmEndDate</toField><ignoreTime>1</ignoreTime></mapping><mapping><fieldname>EndDate</fieldname><fromField>dtmStartDate</fromField><toField>dtmEndDate</toField><ignoreTime>1</ignoreTime></mapping><mapping><fieldname>Position</fieldname><fromField>Position</fromField><toField></toField><ignoreTime></ignoreTime></mapping><mapping><fieldname>Vendor</fieldname><fromField>strCustomerVendor</fromField><toField></toField><ignoreTime></ignoreTime></mapping><mapping><fieldname>ProductType</fieldname><fromField>strProductType</fromField><toField></toField><ignoreTime></ignoreTime></mapping></mappings>'
		   ,@strClause = @strClause OUTPUT

	SELECT  @strClause
*/
BEGIN TRY
	
	DECLARE @ErrMsg			NVARCHAR(MAX)
	DECLARE @intId			INT,
			@strFieldName	NVARCHAR(50),  
			@strCondition	NVARCHAR(20),        
			@strFrom		NVARCHAR(MAX), 
			@strTo			NVARCHAR(MAX),  			
			@strDatatype	NVARCHAR(50),
			@strFromField	NVARCHAR(20),        
			@strToField		NVARCHAR(MAX),
			@ysnIgnoreTime	BIT,
			@xmlDocumentId	INT,
			@strOperator	NVARCHAR(50)

	DECLARE @temp_xml_table TABLE 
	(  
			intId			INT IDENTITY(1,1),
			strFieldName	NVARCHAR(50),  
			strCondition	NVARCHAR(20),        
			strFrom			NVARCHAR(MAX), 
			strTo			NVARCHAR(MAX),  
			strJoin			NVARCHAR(10),  
			strBegingroup	NVARCHAR(50),  
			strEndgroup		NVARCHAR(50),  
			strDatatype		NVARCHAR(50),

			strFromField	NVARCHAR(20),        
			strToField		NVARCHAR(MAX),
			ysnIgnoreTime	BIT 
	)  

	EXEC sp_xml_preparedocument @xmlDocumentId output, @strDataXML  

	INSERT INTO @temp_xml_table(strFieldName, strCondition, strFrom, strTo, strJoin, strBegingroup, strEndgroup, strDatatype)
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(MAX), 
				[to]			NVARCHAR(MAX),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  

	EXEC sp_xml_preparedocument @xmlDocumentId output, @strMappingXML  

	UPDATE	X
	SET		X.strFromField = fromField,
			X.strToField = toField,
			X.ysnIgnoreTime = ignoreTime
	FROM	@temp_xml_table X
	JOIN	OPENXML(@xmlDocumentId, 'mappings/mapping', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				fromField		NVARCHAR(20),        
				toField			NVARCHAR(MAX),
				ignoreTime		BIT
	) M ON X.strFieldName = M.fieldname

	SELECT @strClause = '' 
	SELECT @intId = MIN(intId) FROM @temp_xml_table

	WHILE ISNULL(@intId,0) > 0 
	BEGIN
		SELECT	@strFieldName	=	strFieldName,  
				@strCondition	=	strCondition,        
				@strFrom		=	strFrom, 
				@strTo			=	strTo,  			
				@strDatatype	=	strDatatype,
				@strFromField	=	strFromField,        
				@strToField		=	ISNULL(strToField,strFromField),
				@ysnIgnoreTime	=	ysnIgnoreTime

		FROM	@temp_xml_table WHERE intId = @intId

		IF @strDatatype = 'DateTime'
		BEGIN
			IF @strFrom IS NOT NULL AND @strTo IS NOT NULL
			BEGIN
				SELECT  @strFrom = CASE WHEN @ysnIgnoreTime = 1 THEN CONVERT(NVARCHAR(20), CAST(@strFrom AS DATETIME),101) ELSE @strFrom END
				SELECT  @strTo = CASE WHEN @ysnIgnoreTime = 1 THEN CONVERT(NVARCHAR(20), CAST(@strTo AS DATETIME),101) ELSE @strTo END
				SET @strClause += @strClause +  ' ('+@strFromField+' BETWEEN ''' + @strFrom  + ''' AND ''' + @strTo +''') '
			END
			ELSE IF @strFrom IS NOT NULL AND @strTo IS NULL
			BEGIN
				SELECT  @strFrom = CASE WHEN @ysnIgnoreTime = 1 THEN CONVERT(NVARCHAR(20), CAST(@strFrom AS DATETIME),101) ELSE @strFrom END
				IF	@strFromField = @strToField
					SET @strClause += @strClause +  ' ('+@strFromField+' = ''' + @strFrom + ''') '
				ELSE	
					SET @strClause = @strClause +  ' (' + @strFromField  + ' BETWEEN '''+@strFrom+''' AND '''+@strFrom +''')'
			END
			ELSE IF @strFrom IS  NULL AND @strTo IS NOT NULL
			BEGIN
				SELECT  @strTo = CASE WHEN @ysnIgnoreTime = 1 THEN CONVERT(NVARCHAR(20), CAST(@strTo AS DATETIME),101) ELSE @strTo END
				IF	@strFromField = @strToField
					SET @strClause += @strClause +  ' ('+@strFromField+' = ''' + @strTo + ''') '
				ELSE
					SET @strClause = @strClause + ' (' + @strToField  + ' BETWEEN '''+@strTo+''' AND '''+@strTo +''')'  
			END
			ELSE
			BEGIN
				IF LTRIM(RTRIM(ISNULL(@strClause,''))) <> ''
					SET @strClause += SUBSTRING(@strClause,0,LEN(@strClause) -3)
			END
		END
		ELSE
		BEGIN
			SELECT @strOperator = CASE WHEN @strCondition LIKE '%Not%' THEN 'NOT IN' ELSE 'IN' END
			IF RTRIM(LTRIM(ISNULL(@strFrom,''))) <> '' AND RTRIM(LTRIM(ISNULL(@strTo,''))) <> ''
			BEGIN
				SELECT @strFrom = CASE WHEN @strDatatype = 'String' THEN ''''+@strFrom+'''' ELSE @strFrom END
				SELECT @strTo = CASE WHEN @strDatatype = 'String' THEN ''''+@strTo+'''' ELSE @strTo END
				SET @strClause += ' ('+@strFromField+' '+@strOperator+' (' + @strFrom + ','+ @strTo +')) '
			END
			ELSE IF RTRIM(LTRIM(ISNULL(@strFrom,''))) <> ''
			BEGIN
				SELECT @strFrom = CASE WHEN @strDatatype = 'String' THEN ''''+@strFrom+'''' ELSE @strFrom END
				SET @strClause += ' ('+@strFromField+' '+@strOperator+' (' + @strFrom + ')) '
			END
			ELSE
			BEGIN
				IF LTRIM(RTRIM(ISNULL(@strClause,''))) <> ''
					SET @strClause += SUBSTRING(@strClause,0,LEN(@strClause) -3)
			END
		END

		IF LEN(@strClause) > 0 AND @intId < (SELECT MAX(intId) FROM @temp_xml_table)
		BEGIN
			SET @strClause = @strClause + ' AND '
		END

		SELECT @intId = MIN(intId) FROM @temp_xml_table WHERE intId > @intId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
