CREATE PROCEDURE [dbo].[uspCTImportFromXML]
	@intImportFileHeaderId INT,
	@strXML NVARCHAR(MAX),
	@strProc NVARCHAR(100)
AS
BEGIN

	DECLARE @XML XML;
 
	IF (CHARINDEX(':' ,@strXML) > 0	)		
		SET @strXML = REPLACE(@strXML, ':', '');

	SET @XML = CAST(@strXML AS XML);

	DECLARE @strRootTag NVARCHAR(200);
	SELECT @strRootTag = strXMLTag FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel <= 1;

	DECLARE @tblXML TABLE (intImportFileColumnDetailId INT, intLevel INT, intLength INT, intPosition INT, strXMLTag NVARCHAR(200), strDataType NVARCHAR(50), strTable NVARCHAR(200));
	DECLARE @tblRecursiveTags TABLE (intLevelRec INT, intLengthRec INT, strXMLTagRec NVARCHAR(200));

	INSERT INTO @tblXML
	SELECT intImportFileColumnDetailId, intLevel, intLength, intPosition, strXMLTag, strDataType, strTable
	FROM dbo.tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel > 1 ORDER BY intLevel;
	
	INSERT INTO @tblXML
	SELECT CD.intImportFileColumnDetailId, intLevel, intLength, intPosition, TA.strTagAttribute [strXMLTag], 'TagAttribute' [strDataType], TA.strTable
	FROM dbo.tblSMImportFileColumnDetail CD
	JOIN dbo.tblSMXMLTagAttribute TA ON CD.intImportFileColumnDetailId = TA.intImportFileColumnDetailId 
	WHERE intImportFileHeaderId = @intImportFileHeaderId AND intLevel > 1 ORDER BY intLevel;

	DECLARE @intLevelMin INT, @intLevelMax INT;
	SELECT  @intLevelMin = MIN(intLevel), @intLevelMax = MAX(intLevel) FROM @tblXML; 

	DECLARE @strXMLPath NVARCHAR(MAX), @strColumnsList NVARCHAR(MAX), @strHeader NVARCHAR(150), @strColumnPath NVARCHAR(MAX)
			, @intRec INT , @intRecCnt INT; 
	SET @strXMLPath = @strRootTag;
	SET @strColumnsList = '';
	SET @strHeader = '';
	SET @strColumnPath = '';

	DECLARE @intMinTemp INT, @intMaxTemp INT;

	DECLARE @SQL NVARCHAR(MAX);

	SET @SQL = '
	DECLARE @DocumentID Int
	DECLARE @XML XML
	DECLARE @strXML nvarchar(max)

	SET @strXML = ''' + @strXML + '''

	SET @strXML = REPLACE(@strXML, ''' + ISNULL((SELECT strXMLInitiater FROM dbo.tblSMImportFileHeader WHERE intImportFileHeaderId = @intImportFileHeaderId), '') + ''', '''')

	SET @XML = CONVERT(XML, @strXML, 1)
	EXEC sp_xml_preparedocument @DocumentID OUTPUT, @XML;


	SELECT *
	INTO #tmpXMLTable FROM ';

	WHILE(@intLevelMin <= @intLevelMax)
	BEGIN

		DECLARE @tagName NVARCHAR(50);

		IF EXISTS (SELECT 1 FROM @tblXML WHERE intLevel = @intLevelMin)
		BEGIN
			DECLARE @intImportFileColumnDetailId INT, @intLength INT, @intPosition INT, @strXMLTag NVARCHAR(200)
					, @strDataType NVARCHAR(50), @strTable NVARCHAR(200);
				
			SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId
			, @intLength = intLength
			, @intPosition = intPosition
			, @strXMLTag = strXMLTag
			, @strDataType = ISNULL(strDataType, '') 
			, @strTable = ISNULL(strTable, '')
			FROM @tblXML WHERE intLevel = @intLevelMin AND ISNULL(strDataType, '') <> 'TagAttribute';
		
			DECLARE @strCompareTagName NVARCHAR(200);
			SET @strCompareTagName = @strXMLTag + '>';
		
			IF (CHARINDEX(':' ,@strXMLTag) > 0	)		
				SET @strXMLTag = REPLACE(@strXMLTag, ':', '');
		
			--SET @strXML =
		
			IF ((((LEN(@strXML)-LEN(REPLACE(@strXML, @strCompareTagName, ''))) / LEN(@strCompareTagName) ) > 2) 
					AND 
				((SELECT COUNT(1) FROM @tblRecursiveTags WHERE strXMLTagRec = @strXMLTag) <= 0) AND @strDataType = 'Header')
			BEGIN
				WITH tableR (intLevel, intLength, strXMLTag)
				AS
				(
				-- Anchor member definition
					SELECT e.intLevel, e.intLength, e.strXMLTag
					FROM tblSMImportFileColumnDetail AS e   
					WHERE intLength IN (@intLevelMin) AND intImportFileHeaderId = @intImportFileHeaderId
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
				FROM tableR;  
			
				DECLARE @strParentBeforeRec NVARCHAR(100);
				SELECT @strParentBeforeRec = strXMLTag FROM @tblXML WHERE intLevel = @intLength;
			
				IF @strDataType = 'Header'
				BEGIN
					IF CHARINDEX(@strParentBeforeRec, @strXMLPath) = 0
						SET @strXMLPath = @strXMLPath + '/' + @strParentBeforeRec;
				
					SET @strXMLPath = @strXMLPath + '/' + @strXMLTag;
					SET @strHeader = @strXMLTag;
				END;
				SET @intRec = 0;
				SET @intRecCnt = (SELECT COUNT(*) FROM @tblRecursiveTags);
				SET @intLevelMin = @intLevelMin + 1;
			
				CONTINUE;
			END;
		
			IF ((SELECT COUNT(1) FROM @tblRecursiveTags WHERE strXMLTagRec = @strXMLTag) > 0)
			BEGIN
				SET @intRec = @intRec + 1;
				IF @strDataType = 'Header'
				BEGIN
					IF @strColumnPath <> ''
					BEGIN
						DECLARE @strParent NVARCHAR(200);
						SELECT @strParent = strXMLTag FROM @tblXML WHERE intLevel = @intLength;
						IF CHARINDEX(@strParent, @strColumnPath, 0) <= 0 
							SET @strColumnPath = '';
					END;
					SET @strColumnPath = @strColumnPath + @strXMLTag + '/';
				END;
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
					
					SELECT @strColumnPath = ISNULL(@strColumnPath,'') + '/' + strXMLTagRec FROM  tblParent
						WHERE intLevelRec <> @intLevelMin
						ORDER BY intLevelRec ASC
					OPTION(MAXRECURSION 20);

					SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + ' nvarchar(200) ''.' + ISNULL(@strColumnPath, '') + '/' + @strXMLTag + '/text()'' ,';

					IF EXISTS(SELECT 1 FROM @tblXML WHERE intLevel = @intLevelMin AND strDataType = 'TagAttribute')
					BEGIN
						SELECT @tagName = strXMLTag FROM @tblXML WHERE intLevel = @intLevelMin AND strDataType = 'TagAttribute';
						SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + @tagName + ' nvarchar(200) ''.' + ISNULL(@strColumnPath, '') + '/' + @strXMLTag + '/@' + @tagName + '/text()'' ,';
					END;

				END;
			
				IF ( (@intRec = @intRecCnt) OR (@intLevelMin = @intLevelMax) )
				BEGIN
					IF (CHARINDEX('OPENXML' ,@SQL) > 0	) 
					BEGIN
						SET @SQL = @SQL + ' OUTER APPLY ';
					END;
				
					SET @strColumnsList = SUBSTRING(@strColumnsList, 0, LEN(@strColumnsList));
				
				
					SET @SQL = @SQL + ' OPENXML(@DocumentID, ''' + @strXMLPath + ''',2) 
										WITH( ' + @strColumnsList + ' ) ' + @strHeader;
				
					SET @strXMLPath = @strRootTag;
					SET @strColumnsList = '';
					SET @strHeader = '';
					SET @strColumnPath = '';
					SET @intRec = 0;
					SET @intRecCnt = 0;
					SET @strParentBeforeRec = '';
					DELETE FROM @tblRecursiveTags;
				END;
			
			END;
			ELSE
			BEGIN
				IF @strDataType = 'Header'
				BEGIN
					IF @strTable = ''
					BEGIN
						SET @strColumnPath = @strColumnPath + @strXMLTag + '/'; 
					END;
					ELSE
					BEGIN
						SET @strXMLPath = @strXMLPath + '/' + @strXMLTag;
						SET @strHeader = @strXMLTag;
					END;
				END;
				ELSE
				BEGIN
				
					SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + ' nvarchar(200) ''./' + ISNULL(@strColumnPath, '') + @strXMLTag + '/text()'' ,';

					
					IF EXISTS(SELECT 1 FROM @tblXML WHERE intLevel = @intLevelMin AND strDataType = 'TagAttribute')
					BEGIN
						SELECT @tagName = strXMLTag FROM @tblXML WHERE intLevel = @intLevelMin AND strDataType = 'TagAttribute';
						SET @strColumnsList = @strColumnsList + ' ' + @strXMLTag + @tagName + ' nvarchar(200) ''.' + ISNULL(@strColumnPath, '') + '/' + @strXMLTag + '/@' + @tagName + '/text()'' ,';
					END;


				END;
			
				DECLARE @strNextHeader NVARCHAR(200);
				SET @strNextHeader = (SELECT TOP 1 strDataType FROM @tblXML WHERE intLevel > @intLevelMin ORDER BY intLevel);
			
				IF (((ISNULL(@strNextHeader,'') = 'Header') AND (ISNULL(@strDataType ,'') <> 'Header') ) OR (@intLevelMin = @intLevelMax)) 
				BEGIN
					IF (CHARINDEX('OPENXML' ,@SQL) > 0	) 
					BEGIN
						SET @SQL = @SQL + ' OUTER APPLY ';
					END;
				
					SET @strColumnsList = SUBSTRING(@strColumnsList, 0, LEN(@strColumnsList));
				
					SET @SQL = @SQL + ' OPENXML(@DocumentID, ''' + @strXMLPath + ''',2) 
										WITH( ' + @strColumnsList + ' ) ' + @strHeader;
				
					SET @strXMLPath = @strRootTag;
					SET @strColumnsList = '';
					SET @strHeader = '';
					SET @strColumnPath = '';
				END;
			END;
		
		
		END;
	
		SET @intLevelMin = @intLevelMin + 1;

	END;

	SET @SQL =	@SQL + '
				EXEC sp_xml_removedocument @DocumentID
				EXEC ' + @strProc + ' @strXML 
				DROP TABLE #tmpXMLTable'
	
	EXECUTE sp_executesql @SQL;

END