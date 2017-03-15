CREATE PROCEDURE [dbo].[uspSTXMLToIntermediateTable]
  @intImportFileHeaderId Int
, @intCheckoutId Int
, @strSPName nvarchar(100) 
, @strXML nvarchar(max)
AS
BEGIN

	DECLARE @XML XML --,  @strXML nvarchar(max)

	--START For passing xml string to uspSTCheckout stored proc
	Declare @getStrXML nvarchar(MAX)
	SET @getStrXML = @strXML
	--END

	--SET @XML = CAST(@XML1 as xml)

	If(ISNULL(@intCheckoutId, 0) = 0)
	BEGIN
		RAISERROR('Checkout transaction needs to be carried out first.',16,1)
	END

	--DECLARE @intStoreId Int
	--Select @intStoreId = intStoreId FROM dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	--Select @strSPName = RFC.strStoredProcedure 
	--FROM dbo.tblSTRegisterFileConfiguration RFC
	--JOIN dbo.tblSTRegister R ON R.intRegisterId = RFC.intRegisterId
	----JOIN dbo.tblSTStore S ON S.intStoreId = R.intStoreId
	----JOIN dbo.tblSTCheckoutHeader CH ON CH.intStoreId = S.intStoreId
	--Where R.intStoreId = @intStoreId AND RFC.intImportFileHeaderId = @intImportFileHeaderId

	--If(ISNULL(@strSPName, '') = '')
	--BEGIN
	--	RAISERROR('Please set Stored Procedure in Register configuration.',16,1)
	--END

	--SET @strXML = @XML1 -- CAST(@XML as nvarchar(max))

	--SELECT LEN(@strXML) 'Len of strXML'
 
	IF (CHARINDEX(':' ,@strXML) > 0	)		
		SET @strXML = REPLACE(@strXML, ':', '')
	--SELECT @strXML

	SET @XML = CAST(@strXML as XML)

	DECLARE @strRootTag nvarchar(200)
	Select @strRootTag = strXMLTag from dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel <= 1

	DECLARE @tblXML TABLE (intImportFileColumnDetailId int, intLevel int, intLength int, intPosition int, strXMLTag nvarchar(200), strDataType nvarchar(50), strTable nvarchar(200))
	DECLARE @tblRecursiveTags TABLE (intLevelRec int, intLengthRec int, strXMLTagRec nvarchar(200))

	INSERT INTO @tblXML
	SELECT intImportFileColumnDetailId, intLevel, intLength, intPosition, strXMLTag, strDataType, strTable
	FROM dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel > 1 Order By intLevel
	
	INSERT INTO @tblXML
	SELECT CD.intImportFileColumnDetailId, intLevel, intLength, intPosition, TA.strTagAttribute [strXMLTag], 'TagAttribute' [strDataType], TA.strTable
	FROM dbo.tblSMImportFileColumnDetail CD
	JOIN dbo.tblSMXMLTagAttribute TA ON CD.intImportFileColumnDetailId = TA.intImportFileColumnDetailId 
	Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel > 1 Order By intLevel

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
	INTO #tempCheckoutInsert FROM '

	WHILE(@intLevelMin <= @intLevelMax)
	BEGIN

		DECLARE @tagName nvarchar(50)

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
			FROM @tblXML WHERE intLevel = @intLevelMin and ISNULL(strDataType, '') <> 'TagAttribute'
		
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

					IF EXISTS(Select 1 FROM @tblXML Where intLevel = @intLevelMin and strDataType = 'TagAttribute')
					BEGIN
						SELECT @tagName = strXMLTag FROM @tblXML Where intLevel = @intLevelMin and strDataType = 'TagAttribute'
						SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + @tagName + ' nvarchar(200) ''.' + ISNULL(@strColumnPath, '') + '/' + @strXMLTag + '/@' + @tagName + '/text()'' ,'
					END

				END
			
				IF ( (@intRec = @intRecCnt) OR (@intLevelMin = @intLevelMax) )
				BEGIN
					IF (CHARINDEX('OPENXML' ,@SQL) > 0	) 
					BEGIN
						SET @SQL = @SQL + ' OUTER APPLY '
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

					
					IF EXISTS(Select 1 FROM @tblXML Where intLevel = @intLevelMin and strDataType = 'TagAttribute')
					BEGIN
						SELECT @tagName = strXMLTag FROM @tblXML Where intLevel = @intLevelMin and strDataType = 'TagAttribute'
						SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + @tagName + ' nvarchar(200) ''.' + ISNULL(@strColumnPath, '') + '/' + @strXMLTag + '/@' + @tagName + '/text()'' ,'
					END


				END
			
				DECLARE @strNextHeader nvarchar(200)
				SET @strNextHeader = (SELECT TOP 1 strDataType FROM @tblXML Where intLevel > @intLevelMin Order by intLevel)
			
				IF (((ISNULL(@strNextHeader,'') = 'Header') AND (ISNULL(@strDataType ,'') <> 'Header') ) OR (@intLevelMin = @intLevelMax)) --AND @strTable <> ''
				BEGIN
					IF (CHARINDEX('OPENXML' ,@SQL) > 0	) 
					BEGIN
						SET @SQL = @SQL + ' OUTER APPLY '
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
			SELECT * FROM #tempCheckoutInsert
		EXEC ' + @strSPName + ' ' + CAST(@intCheckoutId as nvarchar(20))  + ', ' + '''' + @getStrXML + '''' + '
		DROP TABLE #tempCheckoutInsert
	'

	SELECT @SQL

	EXEC sp_executesql @SQL


END