CREATE PROCEDURE [dbo].[uspSTXMLToIntermediateTable]
	@intImportFileHeaderId Int
, @XML XML
AS
BEGIN

	DECLARE @strXML nvarchar(max)

	SET @strXML = CAST(@XML as nvarchar(max))

	--SELECT LEN(@strXML) 'Len of strXML'
 
	IF (CHARINDEX(':' ,@strXML) > 0	)		
		SET @strXML = REPLACE(@strXML, ':', '') --REPLACE(SUBSTRING(@strXML, CHARINDEX(':', @strXML), LEN(@strXML)), ':', '')

	--DECLARE @strFirstTag nvarchar(200)
	--Select @strFirstTag = strXMLTag from dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = 16 AND intLevel = 1

	--IF ((LEN(@strXML)-LEN(REPLACE(@strXML, @strFirstTag, ''))) / LEN(@strFirstTag) ) <> 2
	--	SET @strXML = '<' + @strFirstTag + ' ' + @strXML

	
	--SELECT @strXML

	SET @XML = CAST(@strXML as XML)

	DECLARE @strRootTag nvarchar(200)
	Select @strRootTag = strXMLTag from dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel <= 1

	DECLARE @tblXML TABLE (intImportFileColumnDetailId int, intLevel int, intLength int, intPosition int, strXMLTag nvarchar(200), strDataType nvarchar(50), strTable nvarchar(200))
	DECLARE @tblRecursiveTags TABLE (intLevelRec int, intLengthRec int, strXMLTagRec nvarchar(200))

	INSERT INTO @tblXML
	SELECT intImportFileColumnDetailId, intLevel, intLength, intPosition, strXMLTag, strDataType, strTable
	FROM dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel > 1 Order By intLevel

	--Select * from @tblXML

	DECLARE @intLevelMin Int, @intLevelMax Int
	SELECT  @intLevelMin = MIN(intLevel), @intLevelMax = MAX(intLevel) FROM @tblXML 

	DECLARE @strXMLPath nvarchar(max), @strColumnsList nvarchar(max), @strHeader nvarchar(150), @strColumnPath nvarchar(max)
			, @intRec Int , @intRecCnt Int 
	SET @strXMLPath = @strRootTag
	SET @strColumnsList = ''
	SET @strHeader = ''
	SET @strColumnPath = ''

	DECLARE @intMinTemp Int, @intMaxTemp Int

	DECLARE @SQL nvarchar(max)

	SET @SQL = '
	DECLARE @DocumentID Int
	DECLARE @XML XML
	DECLARE @strXML nvarchar(max)

	SET @strXML = ''' + @strXML + '''

	SET @strXML = REPLACE(@strXML, ''' + ISNULL((Select strXMLInitiater from dbo.tblSMImportFileHeader Where intImportFileHeaderId = @intImportFileHeaderId), '') + ''', '''')

	SET @strXML = REPLACE(@strXML, SUBSTRING(@strXML, 
					 CHARINDEX('' '', @strXML), 
					 (CHARINDEX(''>'', @strXML) - CHARINDEX('' '', @strXML))), '''')

	SET @XML = CONVERT(XML, @strXML, 1)
	EXEC sp_xml_preparedocument @DocumentID OUTPUT, @XML;


	SELECT *
	INTO #tempRadiantEMC FROM '

	WHILE(@intLevelMin <= @intLevelMax)
	BEGIN

		IF EXISTS (SELECT 1 FROM @tblXML WHERE intLevel = @intLevelMin)
		BEGIN
			DECLARE @intImportFileColumnDetailId int, @intLength int, @intPosition int, @strXMLTag nvarchar(200)
					, @strDataType nvarchar(50), @strTable nvarchar(200)
				
			SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId
			, @intLength = intLength
			, @intPosition = intPosition
			, @strXMLTag = strXMLTag
			, @strDataType = ISNULL(strDataType, '') 
			, @strTable = ISNULL(strTable, '')
			FROM @tblXML WHERE intLevel = @intLevelMin 
		
			DECLARE @strCompareTagName nvarchar(200)
			SET @strCompareTagName = @strXMLTag + '>'
		
			IF (CHARINDEX(':' ,@strXMLTag) > 0	)		
				SET @strXMLTag = REPLACE(@strXMLTag, ':', '') --REPLACE(SUBSTRING(@strXMLTag, CHARINDEX(':', @strXMLTag), LEN(@strXMLTag)), ':', '')
		
			--SET @strXML =
		
			IF ((((LEN(@strXML)-LEN(REPLACE(@strXML, @strCompareTagName, ''))) / LEN(@strCompareTagName) ) > 2) 
					AND 
				((SELECT COUNT(1) FROM @tblRecursiveTags WHERE strXMLTagRec = @strXMLTag) <= 0) AND @strDataType = 'Header') -- If repeating details
			BEGIN
				WITH tableR (intLevel, intLength, strXMLTag)
				AS
				(
				-- Anchor member definition
					SELECT e.intLevel, e.intLength, e.strXMLTag
					FROM tblSMImportFileColumnDetail AS e   
					WHERE intLength in (@intLevelMin) AND intImportFileHeaderId = @intImportFileHeaderId
					UNION ALL
				-- Recursive member definition
					SELECT e.intLevel, e.intLength, e.strXMLTag
					FROM tblSMImportFileColumnDetail AS e
					INNER JOIN tableR AS d
						ON e.intLength = d.intLevel
					   WHERE intImportFileHeaderId = @intImportFileHeaderId
				)
				-- Statement that executes the CTE
				INSERT INTO @tblRecursiveTags
				SELECT intLevel, intLength, strXMLTag
				FROM tableR  
			
				DECLARE @strParentBeforeRec nvarchar(100)
				SELECT @strParentBeforeRec = strXMLTag FROM @tblXML WHERE intLevel = @intLength
			
				If @strDataType = 'Header'
				BEGIN
					IF CHARINDEX(@strParentBeforeRec, @strXMLPath) = 0
						SET @strXMLPath = @strXMLPath + '/' + @strParentBeforeRec
				
					SET @strXMLPath = @strXMLPath + '/' + @strXMLTag
					SET @strHeader = @strXMLTag
				END
				SET @intRec = 0
				SET @intRecCnt = (SELECT COUNT(*) FROM @tblRecursiveTags)
				SET @intLevelMin = @intLevelMin + 1
			
				continue
			END
		
			IF ((SELECT COUNT(1) FROM @tblRecursiveTags WHERE strXMLTagRec = @strXMLTag) > 0)
			BEGIN
				SET @intRec = @intRec + 1
				If @strDataType = 'Header'
				BEGIN
					If @strColumnPath <> ''
					BEGIN
						DECLARE @strParent nvarchar(200)
						SELECT @strParent = strXMLTag FROM @tblXML WHERE intLevel = @intLength
						IF CHARINDEX(@strParent, @strColumnPath, 0) <= 0 
							SET @strColumnPath = ''
					END
					SET @strColumnPath = @strColumnPath + @strXMLTag + '/'
				END
				ELSE
				BEGIN
					SET @strColumnPath = '';
					WITH tblParent AS
					(
						SELECT * FROM @tblRecursiveTags WHERE intLevelRec = @intLevelMin 
						UNION ALL
						SELECT rec.*
							FROM @tblRecursiveTags rec JOIN tblParent  ON rec.intLevelRec = tblParent.intLengthRec 
					)
				
					--SELECT * FROM  tblParent
					--	WHERE intLevelRec <> @intLevelMin
					--	ORDER BY intLevelRec ASC
					
					SELECT @strColumnPath = ISNULL(@strColumnPath,'') + '/' + strXMLTagRec FROM  tblParent
						WHERE intLevelRec <> @intLevelMin
						ORDER BY intLevelRec ASC
					OPTION(MAXRECURSION 20)

	--SELECT @strColumnPath
									
					SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + ' nvarchar(200) ''.' + ISNULL(@strColumnPath, '') + '/' + @strXMLTag + '/text()'' ,'
				END
			
				IF ( (@intRec = @intRecCnt) OR (@intLevelMin = @intLevelMax) )
				BEGIN
					IF (CHARINDEX('OPENXML' ,@SQL) > 0	) 
					BEGIN
						SET @SQL = @SQL + ' CROSS JOIN '
					END
				
					SET @strColumnsList = SUBSTRING(@strColumnsList, 0, LEN(@strColumnsList))
				
				
					SET @SQL = @SQL + ' OPENXML(@DocumentID, ''' + @strXMLPath + ''',2) 
										WITH( ' + @strColumnsList + ' ) ' + @strHeader
				
					SET @strXMLPath = @strRootTag
					SET @strColumnsList = ''
					SET @strHeader = ''
					SET @strColumnPath = ''
					SET @intRec = 0
					SET @intRecCnt = 0
					SET @strParentBeforeRec = ''
					DELETE FROM @tblRecursiveTags
				END
			
			END
			ELSE
			BEGIN
				If @strDataType = 'Header'
				BEGIN
					If @strTable = ''
					BEGIN
						SET @strColumnPath = @strColumnPath + @strXMLTag + '/' 
					END
					ELSE
					BEGIN
						SET @strXMLPath = @strXMLPath + '/' + @strXMLTag
						SET @strHeader = @strXMLTag
					END
				END
				ELSE
				BEGIN
					SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + ' nvarchar(200) ''./' + ISNULL(@strColumnPath, '') + @strXMLTag + '/text()'' ,'
				END
			
				DECLARE @strNextHeader nvarchar(200)
				SET @strNextHeader = (SELECT TOP 1 strDataType FROM @tblXML Where intLevel > @intLevelMin Order by intLevel)
			
				IF (((ISNULL(@strNextHeader,'') = 'Header') AND (ISNULL(@strDataType ,'') <> 'Header') ) OR (@intLevelMin = @intLevelMax)) --AND @strTable <> ''
				BEGIN
					IF (CHARINDEX('OPENXML' ,@SQL) > 0	) 
					BEGIN
						SET @SQL = @SQL + ' CROSS JOIN '
					END
				
					SET @strColumnsList = SUBSTRING(@strColumnsList, 0, LEN(@strColumnsList))
				
					SET @SQL = @SQL + ' OPENXML(@DocumentID, ''' + @strXMLPath + ''',2) 
										WITH( ' + @strColumnsList + ' ) ' + @strHeader
				
					SET @strXMLPath = @strRootTag
					SET @strColumnsList = ''
					SET @strHeader = ''
					SET @strColumnPath = ''
				END
			END
		
		
		END
	
		SET @intLevelMin = @intLevelMin + 1

	END

	SET @SQL = @SQL + '
	 EXEC sp_xml_removedocument @DocumentID  
			SELECT * FROM #tempRadiantEMC
		DROP TABLE #tempRadiantEMC
	'

	SELECT @SQL

	EXEC sp_executesql @SQL

END	

