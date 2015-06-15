CREATE PROCEDURE [dbo].[uspSMGenerateDynamicXML]
	@intImportFileHeaderId Int,
	@strWhereClause nvarchar(max),
	@blnLayoutPreview bit, 
	@strGeneratedXML XML OUTPUT
AS
BEGIN

	-- ==========> Get the list of primary columns <==========
DECLARE @tblPKColumns TABLE (PKColumnName nvarchar(200))

DECLARE @strMainTable nvarchar(200)
SELECT @strMainTable = strTable FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1

INSERT INTO @tblPKColumns SELECT COLUMN_NAME as primarykeycolumn
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
INNER JOIN
INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU
ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND
TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
and KU.TABLE_NAME=@strMainTable
ORDER BY KU.TABLE_NAME, KU.ORDINAL_POSITION;

-- ============> Generate Where clause when this procedure is called for preview of layout <================
IF ISNULL(@strWhereClause,'') = ''
BEGIN
	SET @strWhereClause = ''
	IF @blnLayoutPreview = 1
	BEGIN
		print ''
		SELECT @strWhereClause = @strWhereClause + ' ' + PKColumnName + ' IN (SELECT TOP 1 ' + PKColumnName + ' FROM ' + @strMainTable + ') AND '  
		FROM    @tblPKColumns
		
		SELECT @strWhereClause = LEFT(@strWhereClause,LEN(@strWhereClause)-3) 
		
	END
END	


-- ==============> Generate PK where clause for internal statements <=================
DECLARE @Txt1 VARCHAR(MAX), @PKColumnCondition nvarchar(max)
SET @Txt1='' 
SELECT  @Txt1 = @Txt1 + 'main.' + PKColumnName +' = sub.' + PKColumnName + ' AND '
FROM    @tblPKColumns

SELECT @PKColumnCondition = LEFT(@Txt1,LEN(@Txt1)-3) 

--SELECT @PKColumnCondition

DECLARE @tblXML TABLE (intImportFileColumnDetailId int, intLevel int, intLength int, intPosition int, strXMLTag nvarchar(200), strTable nvarchar(200), strColumnName nvarchar(200), strDefaultValue nvarchar(200))
DECLARE @intParent Int, @strMainSQL nvarchar(max), @intRootChild Int

SELECT @intRootChild = COUNT(intLevel) FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLength = 1

SET @strMainSQL = ''

Select @intParent = MAX(intLength) From dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId


WHILE (@intParent >= 1)
BEGIN
	
	DELETE FROM @tblXML
	
	INSERT INTO @tblXML
	SELECT intImportFileColumnDetailId, intLevel, intLength, intPosition, strXMLTag, strTable, strColumnName, strDefaultValue FROM dbo.tblSMImportFileColumnDetail 
	WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLength = @intParent Order By intPosition
	
--SELECT * FROM @tblXML
	
	DECLARE @intMinPosition Int, @intMaxPosition Int
	SELECT @intMinPosition = MIN(intPosition), @intMaxPosition = MAX(intPosition) FROM @tblXML
--SELECT @intMinPosition, @intMaxPosition
	
	WHILE(@intMinPosition <= @intMaxPosition)
	BEGIN
		DECLARE @intImportFileColumnDetailId int, @intLevel int, @strXMLTag nvarchar(200), @strTable nvarchar(200), @strColumnName nvarchar(200), @strDefaultValue nvarchar(200)
		DECLARE @strTagAttribute nvarchar(max), @strParentTag nvarchar(200), @strParentTable nvarchar(200), @intParentLevel Int, @intParentChild Int
		
		SET @strTagAttribute = ''
		
		SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId, @intLevel = intLevel,  @strXMLTag = strXMLTag
		, @strTable = strTable, @strColumnName = strColumnName, @strDefaultValue = strDefaultValue 
		FROM @tblXML WHERE intPosition = @intMinPosition
		
--SELECT @strXMLTag '@strXMLTag'
		IF (CHARINDEX(':' ,@strXMLTag) > 0	)		
		SET @strXMLTag = REPLACE(SUBSTRING(@strXMLTag, CHARINDEX(':', @strXMLTag), LEN(@strXMLTag)), ':', '')
		

		SELECT @strParentTag = strXMLTag, @strParentTable = ISNULL(strTable,''), @intParentLevel = intLevel 
		FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = @intParent
--SELECT @strParentTag '@strParentTag', @intParentLevel
	
		IF (CHARINDEX(':' ,@strParentTag) > 0	)		
		SET @strParentTag = REPLACE(SUBSTRING(@strParentTag, CHARINDEX(':', @strParentTag), LEN(@strParentTag)), ':', '')
		
		SELECT @intParentChild = MAX(intLength) FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLength = @intParentLevel 
		
		If @intParentLevel = 1 AND @intParentChild > 1 -- =========> Break if root level and has more than 1 child, else continue. <===============
			BREAK;
		--SELECT @strXMLTag, @strParentTag
		
		SET @strParentTag = REPLACE(@strParentTag, '-', '')
					
		-- ===========> Form attributes format <================
		IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId)
		BEGIN
			DECLARE @intMinTagPosition Int, @intMaxTagPosition Int
			SELECT @intMinTagPosition = MIN(intSequence), @intMaxTagPosition = MAX(intSequence) FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
			SET @strTagAttribute = ''
			WHILE (@intMinTagPosition <= @intMaxTagPosition)
			BEGIN
				SET @strTagAttribute =  (SELECT @strTagAttribute + ' ''''' + strDefaultValue + ''''' [' + strTagAttribute + '],' FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence = @intMinTagPosition)
				
				SET @intMinTagPosition = @intMinTagPosition + 1
			END
			
			SET @strTagAttribute = SUBSTRING(@strTagAttribute, 0, LEN(@strTagAttribute))
		END
		
--SELECT @strXMLTag '@strXMLTag', @strTable, @intLevel	
	
		--===========> Start forming xml <================
		IF (ISNULL(@strTable, '') = '' AND ISNULL(@strColumnName, '') = '')
		BEGIN -- =============> No table and column name <=================
		
			IF (ISNULL(@strDefaultValue,'') <> '' )
			BEGIN
				IF (CHARINDEX('@' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + '',@strMainSQL) = 0	) --AND (CHARINDEX('' + @strTable + '',@strMainSQL) = 0	)
				BEGIN
					SET @strMainSQL = @strMainSQL + ' DECLARE @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' nvarchar(max) SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = '''' '
				END
				SET @strMainSQL = @strMainSQL  + ' SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + 
				' + '' ''''' + @strDefaultValue + ''''' [' + @strXMLTag + ']'' '
			END
				
			IF (ISNULL(@strTagAttribute, '') <> '') -- ===========> Has attributes <=============
			BEGIN
				
									
				IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLength = @intLevel)
				BEGIN
					print '@strTable, @strColumnName'
				END
				ELSE
				BEGIN	
					--IF CHARINDEX('@' + @strParentTag + '',@strMainSQL) = 0				
					SET @strMainSQL = @strMainSQL + ' DECLARE @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' nvarchar(max) SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = '''' '
						
					SET @strMainSQL = @strMainSQL + ' SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' + '' ( select ' + @strTagAttribute + '
					 for xml raw(''''' + @strXMLTag + '''''), type
					)'' '
				END
			END
			ELSE -- ==========> no table, column name and no attributes <======================
			BEGIN
				
				IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLength = @intLevel)
				BEGIN -- ==========> Has child <====================
					DECLARE @intMinPos1 Int, @intMaxPos1 Int, @strCurrentTag1 nvarchar(200)
					SELECT @intMinPos1 = MIN(intPosition), @intMaxPos1 = MAX(intPosition) FROM dbo.tblSMImportFileColumnDetail WHERE intLength = @intLevel AND intImportFileHeaderId = @intImportFileHeaderId
				
					WHILE (@intMinPos1 <= @intMaxPos1)
					BEGIN
						IF (CHARINDEX('@' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + '',@strMainSQL) = 0	) --AND (CHARINDEX('' + @strTable + '',@strMainSQL) = 0	)
						BEGIN--SELECT * FROM @tblXML WHERE intLength = @intLevel
							SET @strMainSQL = @strMainSQL + ' DECLARE @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' nvarchar(max) SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = '''' '
							SET @strMainSQL = @strMainSQL + ' SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = '' ( SELECT '' '
						END
						SET @strMainSQL = @strMainSQL  + ' SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + 
							' + @' + @strXMLTag + CAST(@intMinPos1 as nvarchar(5)) + ' + '','' '
						
						SET @intMinPos1 = @intMinPos1 + 1
					END
					SET @strMainSQL = LEFT(@strMainSQL,LEN(@strMainSQL)-3)
					
					SET @strMainSQL = @strMainSQL  + ' '' FOR XML RAW (''''' + @strXMLTag + ''''') , TYPE ) '' '
					
				END
			END
					
			
		END
		ELSE IF (ISNULL(@strTable, '') <> '' AND ISNULL(@strColumnName, '') = '')
		BEGIN -- =========> Has table and  No column name <===============
				
			IF EXISTS(SELECT 1 FROM dbo.tblSMImportFileColumnDetail WHERE	intImportFileHeaderId = @intImportFileHeaderId AND intLength = @intLevel)
			BEGIN -- ===============> has child nodes <==========

--SELECT @strXMLTag '@strXMLTag', @strTable, @intLevel
				
				DECLARE @intMinPos Int, @intMaxPos Int, @strCurrentTag nvarchar(200)
				SELECT @intMinPos = MIN(intPosition), @intMaxPos = MAX(intPosition) FROM dbo.tblSMImportFileColumnDetail WHERE intLength = @intLevel AND intImportFileHeaderId = @intImportFileHeaderId
			
				WHILE (@intMinPos <= @intMaxPos)
				BEGIN
					IF (CHARINDEX('@' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + '',@strMainSQL) = 0	) --AND (CHARINDEX('' + @strTable + '',@strMainSQL) = 0	)
					BEGIN--SELECT * FROM @tblXML WHERE intLength = @intLevel
						SET @strMainSQL = @strMainSQL + ' DECLARE @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' nvarchar(max) SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = '''' '
						SET @strMainSQL = @strMainSQL + ' SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = '' ( SELECT '' '
					END
					SET @strMainSQL = @strMainSQL  + ' SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + 
						' + @' + @strXMLTag + CAST(@intMinPos as nvarchar(5)) + ' + '','' '
					
					SET @intMinPos = @intMinPos + 1
				END
				SET @strMainSQL = LEFT(@strMainSQL,LEN(@strMainSQL)-3)
				
				DECLARE @strParentParentTable nvarchar(200), @intParentParentLevel Int, @intCurrentLength Int
				SELECT @intCurrentLength = intLength FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = @intLevel
				SELECT @intParentParentLevel = intLevel, @strParentParentTable = strTable FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel = @intCurrentLength
				IF ((ISNULL(@strParentParentTable,'') = '' ) OR (@intParentLevel = 1 AND @intParentChild = 1))
				BEGIN
					SET @strMainSQL = @strMainSQL  + ' '' FROM [dbo].[' + @strMainTable + '] main ' + 
					CASE WHEN ISNULL(@strWhereClause, '') = '' THEN ' '' ' ELSE ' WHERE ' + REPLACE(@strWhereClause, '''','''''')  + ' '' ' END 										
				END
				
				SET @strMainSQL = @strMainSQL  + ' + '' FOR XML RAW (''''' + @strXMLTag + '''''), TYPE, ELEMENTS ' + CASE WHEN @intRootChild > 1 THEN ' ) ' ELSE ' ) ' END + ' '' ' 
				
			END
		END
		ELSE IF (ISNULL(@strTable, '') <> '' AND ISNULL(@strColumnName, '') <> '')
		BEGIN -- ===============> Has Table and Column Name <===============
			IF (CHARINDEX('@' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + '',@strMainSQL) = 0	) --AND (CHARINDEX('' + @strTable + '',@strMainSQL) = 0	)
			BEGIN	-- =========> first loop <=========
								
				SET @strMainSQL = @strMainSQL + ' DECLARE @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' nvarchar(max) SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = '''' '
					
				SET @strMainSQL = @strMainSQL  + ' SET @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + ' = @' + @strParentTag + CAST(@intMinPosition as nvarchar(5)) + 
				' + ''( SELECT ' + CASE WHEN (ISNULL(@strTagAttribute, '') <> '') THEN @strTagAttribute + ' , ' ELSE '' END + ' CAST(CAST(''''<![CDATA['''' + CAST(' + @strColumnName + ' as nvarchar(200)) + '''']]>'''' as nvarchar(200))  as XML) 		
				FROM [dbo].[' + @strTable + '] ' + @strXMLTag + ' ' +
				CASE WHEN @strMainTable = @strTable THEN ' WHERE ' + REPLACE(@PKColumnCondition, 'sub', @strXMLTag) ELSE ' ' END
				+ ' FOR XML AUTO, TYPE ) '' '
			END			
			ELSE
			BEGIN -- =========> Has Table and Column Name , next tags
				DECLARE @oldText nvarchar(max), @newText nvarchar(max)
				SET @oldText = ' FROM [dbo].[' + @strTable + '] ' + @strParentTag + ''
				
				SET @newText = ',' + @strColumnName + ' [' + @strXMLTag + ']		
				FROM [dbo].[' + @strTable + '] ' + @strParentTag + ''
				
				SET @strMainSQL = REPLACE(@strMainSQL, @oldText, @newText)
			END
		END
	
		SET @intMinPosition = @intMinPosition + 1
	END
	-- ==========> Get next max parent key <==============
	Select @intParent = MAX(intLength) From dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLength < @intParent
	
END

-- ==========> Root level tags <==============
DECLARE @intMinPosFin Int, @intMaxPosFin Int, @strCurrentTagFin nvarchar(200)
SELECT @intMinPosFin = MIN(intPosition), @intMaxPosFin = MAX(intPosition) 
FROM dbo.tblSMImportFileColumnDetail WHERE intLength = 1 AND intImportFileHeaderId = @intImportFileHeaderId

SET @strMainSQL = @strMainSQL + ' DECLARE @strResult nvarchar(max)  SET @strResult = '''' '

IF @intMinPosFin <> @intMaxPosFin
BEGIN -- =================> root has more than 1 children <================
	WHILE (@intMinPosFin <= @intMaxPosFin)
	BEGIN	
		
		DECLARE @intStart Int, @intEnd Int
		SELECT @intLevel = intLevel, @strParentTag = strXMLTag FROM dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLength = 1 AND intPosition = @intMinPosFin
		SELECT @intStart = MIN(intPosition), @intEnd = MAX(intPosition) FROM dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLength = @intLevel 
		
		IF (CHARINDEX(':' ,@strParentTag) > 0	)		
		SET @strParentTag = REPLACE(SUBSTRING(@strParentTag, CHARINDEX(':', @strParentTag), LEN(@strParentTag)), ':', '')			
			
		IF (@intStart = 1)
		BEGIN--SELECT * FROM @tblXML WHERE intLength = @intLevel
			SET @strMainSQL = @strMainSQL + ' DECLARE  @' + @strParentTag +  ' nvarchar(max) SET @' + @strParentTag + ' = '''' '
			SET @strMainSQL = @strMainSQL + ' SET @' + @strParentTag + ' =  '' SELECT '' '
		END		

		WHILE (@intStart <= @intEnd)
		BEGIN	
			SET @strMainSQL = @strMainSQL + CASE WHEN @intStart = 0 THEN '' ELSE ' + ' END + ' @' + @strParentTag + CAST(@intStart as nvarchar(5)) + ' + '','' '
			
			SET @intStart = @intStart + 1
			
		END
		SET @strMainSQL = LEFT(@strMainSQL,LEN(@strMainSQL)-6)
		SET @strMainSQL = @strMainSQL + ' + '' FOR XML RAW (''''' + @strParentTag + ''''') '' '
		
		SET @strMainSQL = @strMainSQL + '   SET @' + @strParentTag + ' = @' + @strParentTag + ' + ''
							DECLARE @xmlSample XML
							SET @xmlSample = 
							(
							 '' + @' + @strParentTag + ' + ''
							)

							SELECT @strResult = @strResult + Cast(@xmlSample as nvarchar(max)) 
							'' exec sp_executesql @' + @strParentTag + ', N''@strResult nvarchar(max) out'', @strResult out
							'--SELECT @strResult
							
		
		SET @intMinPosFin = @intMinPosFin + 1
	END

END
ELSE
BEGIN -- =================> root has 1 child <================
	SELECT @intLevel = intLevel, @strParentTag = strXMLTag FROM dbo.tblSMImportFileColumnDetail 
	Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1 
	
	IF (CHARINDEX(':' ,@strParentTag) > 0	)		
	SET @strParentTag = REPLACE(SUBSTRING(@strParentTag, CHARINDEX(':', @strParentTag), LEN(@strParentTag)), ':', '')
	
	SET @strMainSQL = @strMainSQL + '   SET @' + @strParentTag + CAST(@intLevel as nvarchar(5)) + ' =  ''
							DECLARE @xmlSample XML
							SET @xmlSample = 
							( '' + @' + @strParentTag + CAST(@intLevel as nvarchar(5)) + ' + '')
							SELECT @strResult = @strResult + Cast(@xmlSample as nvarchar(max))
							'' exec sp_executesql @' + @strParentTag + CAST(@intLevel as nvarchar(5)) + ', N''@strResult nvarchar(max) out'', @strResult out
							' --SELECT @strResult
							
	
END

--SELECT @strMainSQL '@strMainSQL'

SET @strMainSQL = @strMainSQL + ' SELECT @xmlResult = @strResult'

DECLARE @xmlResult nvarchar(max)
SET @xmlResult = ''

EXEC sp_executesql @strMainSQL, N'@xmlResult nvarchar(max) out', @xmlResult out

DECLARE @Result xml

SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId, @intLevel = intLevel, @strParentTag = strXMLTag FROM dbo.tblSMImportFileColumnDetail 
	Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel = 1 
	
IF EXISTS(SELECT 1 FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId)
BEGIN
	SELECT @intMinTagPosition = MIN(intSequence), @intMaxTagPosition = MAX(intSequence) FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId
	SET @strTagAttribute = ''
	WHILE (@intMinTagPosition <= @intMaxTagPosition)
	BEGIN
		SET @strTagAttribute =  (SELECT @strTagAttribute + ' ' + strTagAttribute + '="' + strDefaultValue + '"  ' FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence = @intMinTagPosition)
		
		SET @intMinTagPosition = @intMinTagPosition + 1
	END
	
END

SET @xmlResult = '<' + @strParentTag + @strTagAttribute + '>' + @xmlResult + '</' + @strParentTag + '>'

SET @Result = CAST(@xmlResult as xml)

SELECT @strGeneratedXML = @Result  

END
