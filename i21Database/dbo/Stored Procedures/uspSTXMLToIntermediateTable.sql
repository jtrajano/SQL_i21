CREATE PROCEDURE [dbo].[uspSTXMLToIntermediateTable]
  @intImportFileHeaderId Int
, @intCheckoutId Int
, @strSPName nvarchar(100) 
, @strXML nvarchar(max)
, @strStatusMsg NVARCHAR(250) OUTPUT
, @intCountRows int OUTPUT
AS
BEGIN
Begin Try

--GET ROOT TAG
DECLARE @strRootTag nvarchar(200), @strRootCompressTag nvarchar(200), @intRootLevel int, @intRootImportFileHeaderId int, @intRootImportFileColumnDetailId int
Select @intRootImportFileHeaderId = intImportFileHeaderId, @intRootImportFileColumnDetailId = intImportFileColumnDetailId, @strRootTag = REPLACE(strXMLTag, ' ', ''), @strRootCompressTag = REPLACE(REPLACE(REPLACE(strXMLTag, ' ', ''), ':', ''), '-', ''), @intRootLevel = intLevel 
       from dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId AND intLevel <= 1

--GET XML Initiator
DECLARE @strXMLinitiator nvarchar(200)
Select @strXMLinitiator = strXMLInitiater FROM dbo.tblSMImportFileHeader WHERE intImportFileHeaderId = @intImportFileHeaderId

DECLARE @NamespaceVar NVARCHAR(200) = '', @NamespaceVendor NVARCHAR(200) = ''

--GET ROOT TAG Namespace
DECLARE @strRootTagNamespace nvarchar(MAX) = ''
IF EXISTS (SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intRootImportFileColumnDetailId)
BEGIN
	DECLARE @intTagAttributeIdMin Int, @intTagAttributeIdMax Int
	SELECT  @intTagAttributeIdMin = MIN(intTagAttributeId)
        , @intTagAttributeIdMax = MAX(intTagAttributeId)
	FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intRootImportFileColumnDetailId
		
    DECLARE @intTempTagAttributeId int, @intTempImportFileColumnDetailId int, @strTempTagAttribute NVARCHAR(200), @strTempDefaultValue NVARCHAR(200)

	DECLARE @intLoopTagAttributeCount int = 0

	SET @strRootTagNamespace = @strRootTagNamespace + ';WITH XMLNAMESPACES ' + CHAR(13) + '(' + CHAR(13)

	WHILE(@intTagAttributeIdMin <= @intTagAttributeIdMax)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intTagAttributeId = @intTagAttributeIdMin)
		BEGIN
			SELECT @intTempTagAttributeId = intTagAttributeId, @intTempImportFileColumnDetailId = intImportFileColumnDetailId, @strTempTagAttribute = strTagAttribute, @strTempDefaultValue = strDefaultValue FROM dbo.tblSMXMLTagAttribute WHERE intTagAttributeId = @intTagAttributeIdMin

			IF(@strTempTagAttribute like '%:%')
			BEGIN
				SET @strTempTagAttribute = REPLACE(@strTempTagAttribute, LEFT(@strTempTagAttribute, CHARINDEX(':', @strTempTagAttribute) - 1) + ':', '')
				SET @NamespaceVendor = @strTempTagAttribute + ':';
			END

			ELSE
			BEGIN
				SET @strTempTagAttribute = @strTempTagAttribute + 'VAR'
				SET @NamespaceVar = @strTempTagAttribute + ':';
			END

			IF(@intLoopTagAttributeCount = 0)
			BEGIN
				SET @strRootTagNamespace = @strRootTagNamespace + '	''' + @strTempDefaultValue + '''' + ' as ' + @strTempTagAttribute + CHAR(13)
			END

			ELSE IF(@intLoopTagAttributeCount > 0)
			BEGIN
				SET @strRootTagNamespace = @strRootTagNamespace + '	, ''' + @strTempDefaultValue + '''' + ' as ' + @strTempTagAttribute + CHAR(13)
			END
		END    
 
		SET @intLoopTagAttributeCount = @intLoopTagAttributeCount + 1
		SET @intTagAttributeIdMin = @intTagAttributeIdMin + 1
	END

	SET @strRootTagNamespace = @strRootTagNamespace + ')'
END

DECLARE @tblXML TABLE (intImportFileColumnDetailId int, intLevel int, intParent int, intPosition int, strXMLTag nvarchar(200), strDataType nvarchar(50), strTable nvarchar(200), strCompressTag nvarchar(200))

--GET XML TAG without ROOT tag using this (intLevel > 1)
INSERT INTO @tblXML
SELECT intImportFileColumnDetailId, intLevel, intLength, intPosition, REPLACE(strXMLTag, ' ', ''), strDataType, strTable, REPLACE(REPLACE(REPLACE(strXMLTag, ' ', ''), ':', ''), '-', '')
FROM dbo.tblSMImportFileColumnDetail Where intImportFileHeaderId = @intImportFileHeaderId --AND intLevel > 1 
AND ysnActive = 1 Order By intLevel


DECLARE @SQL NVARCHAR(MAX)
DECLARE @SELECTCOLUMNS NVARCHAR(MAX) = ''
DECLARE @FROMNODES NVARCHAR(MAX) = ''

--GET FROM NODES
DECLARE @intLevelMin Int, @intLevelMax Int
SELECT  @intLevelMin = MIN(intLevel)
        , @intLevelMax = MAX(intLevel)
FROM @tblXML WHERE strDataType = 'Header'

--Declare variable to get Column values
DECLARE @intImportFileColumnDetailId int, @intLevel int, @intParent int, @intPosition int, @strXMLTag nvarchar(200), @strDataType nvarchar(200), @strCompressTag nvarchar(200)

DECLARE @intLoopCount int = 0

DECLARE @ParentTag NVARCHAR(200) = ''

SET @FROMNODES = @FROMNODES + '@xml.nodes(''' + @NamespaceVar + @strRootTag + ''') ' + @strRootCompressTag + '(' + @strRootCompressTag + ')' + CHAR(13)


WHILE(@intLevelMin <= @intLevelMax)
BEGIN
	IF EXISTS (SELECT * FROM @tblXML WHERE intLevel = @intLevelMin AND strDataType = 'Header') 
	BEGIN

		SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId, @intLevel = intLevel, @intParent = intParent, @intPosition = intPosition, @strXMLTag = ISNULL(strXMLTag, ''), @strDataType = ISNULL(strDataType, ''), @strCompressTag = strCompressTag FROM @tblXML WHERE intLevel = @intLevelMin  AND strDataType = 'Header'

		SELECT @ParentTag = strCompressTag FROM @tblXML WHERE intLevel = @intParent
		
		IF(@intImportFileColumnDetailId <> @intRootImportFileColumnDetailId)
		BEGIN
			SET @FROMNODES = @FROMNODES + 'CROSS APPLY ' + REPLACE(@ParentTag, '-', '') + '.nodes(''' + @NamespaceVar + @strXMLTag + ''') ' + @strCompressTag + '(' + @strCompressTag + ')' + CHAR(13)
		END

		
		--GET attributes from Header Tag if has any
		DECLARE @strHeaderTagAttribute NVARCHAR(200)
		IF EXISTS(SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND ysnActive = 1)
		BEGIN
			DECLARE @intHeaderAttributeMin Int, @intHeaderAttributeMax Int
			SELECT  @intHeaderAttributeMin = MIN(intSequence)
			, @intHeaderAttributeMax = MAX(intSequence)
			FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND ysnActive = 1

			WHILE(@intHeaderAttributeMin <= @intHeaderAttributeMax)
			BEGIN
				SELECT @strHeaderTagAttribute = strTagAttribute FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND ysnActive = 1 AND intSequence = @intHeaderAttributeMin

					if(@intLoopCount = 0)
					BEGIN
						IF(@strXMLTag like '%:%')
						BEGIN
							SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @strXMLTag + '.value(''(@' + @strHeaderTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strHeaderTagAttribute + '' + CHAR(13)
						END

						ELSE
						BEGIN
							SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @strXMLTag + '.value(''(@' + @strHeaderTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strHeaderTagAttribute + '' + CHAR(13)
						END
					END

					ELSE if(@intLoopCount > 0)
					BEGIN
						IF(@strXMLTag like '%:%')
						BEGIN
							SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @strXMLTag + '.value(''(@' + @strHeaderTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strHeaderTagAttribute + '' + CHAR(13)
						END

						ELSE
						BEGIN
							SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @strXMLTag + '.value(''(@' + @strHeaderTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strHeaderTagAttribute + '' + CHAR(13)
						END
					END

				SET @intLoopCount = @intLoopCount + 1
				SET @intHeaderAttributeMin = @intHeaderAttributeMin + 1
			END	
		END
		--END of GET attributes from Header Tag if has any

		--GET SELECT COLUMN
		DECLARE @intSubLevelMin Int, @intSubLevelMax Int
		SELECT  @intSubLevelMin = MIN(intLevel)
        , @intSubLevelMax = MAX(intLevel)
		FROM @tblXML WHERE intParent = @intLevelMin AND strDataType IS NULL

		IF EXISTS (SELECT * FROM @tblXML WHERE intParent = @intLevelMin AND strDataType IS NULL)
		BEGIN
			WHILE(@intSubLevelMin <= @intSubLevelMax)
			BEGIN

			    IF EXISTS(SELECT * FROM @tblXML WHERE intParent = @intLevelMin AND strDataType IS NULL AND intLevel = @intSubLevelMin)
				BEGIN
						SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId, @intLevel = intLevel, @intParent = intParent, @intPosition = intPosition, @strXMLTag = ISNULL(strXMLTag, ''), @strDataType = ISNULL(strDataType, ''), @strCompressTag = strCompressTag 
						FROM @tblXML WHERE intParent = @intLevelMin AND strDataType IS NULL AND intLevel = @intSubLevelMin

						SELECT @ParentTag = strCompressTag FROM @tblXML WHERE intLevel = @intParent

						--Loop all attribute in a Tag Field
						DECLARE @strTagAttribute NVARCHAR(200)
						IF EXISTS(SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND ysnActive = 1)
						BEGIN
							DECLARE @intTagAttributeMin Int, @intTagAttributeMax Int
							SELECT  @intTagAttributeMin = MIN(intSequence)
							, @intTagAttributeMax = MAX(intSequence)
							FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND ysnActive = 1
							WHILE(@intTagAttributeMin <= @intTagAttributeMax)
							BEGIN
								IF EXISTS(SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence = @intTagAttributeMin AND ysnActive = 1)
								BEGIN

									SELECT @strTagAttribute = strTagAttribute FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND intSequence = @intTagAttributeMin AND ysnActive = 1

									if(@intLoopCount = 0)
									BEGIN
										IF(@strXMLTag like '%:%')
										BEGIN
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @ParentTag + '.value(''(' + @strXMLTag + '/@' + @strTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strTagAttribute + '' + CHAR(13)
										END

										ELSE
										BEGIN
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @ParentTag + '.value(''(' + @NamespaceVar + @strXMLTag + '/@' + @strTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strTagAttribute + '' + CHAR(13)
										END
									END

									ELSE if(@intLoopCount > 0)
									BEGIN
										IF(@strXMLTag like '%:%')
										BEGIN
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @ParentTag + '.value(''(' + @strXMLTag + '/@' + @strTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strTagAttribute + '' + CHAR(13)
										END

										ELSE
										BEGIN
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @ParentTag + '.value(''(' + @NamespaceVar + @strXMLTag + '/@' + @strTagAttribute + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + @strTagAttribute + '' + CHAR(13)
										END
									END

									SET @intLoopCount = @intLoopCount + 1
								END
						
								SET @intTagAttributeMin = @intTagAttributeMin + 1
							END
						END
				
						if(@intLoopCount = 0)
								BEGIN
									IF(@strXMLTag like '%:%')
									BEGIN
										SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @ParentTag + '.value(''(' + @strXMLTag + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + '' + CHAR(13)
									END

									ELSE
									BEGIN
										SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @ParentTag + '.value(''(' + @NamespaceVar + @strXMLTag + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + '' + CHAR(13)
								END
							END

							ELSE if(@intLoopCount > 0)
								BEGIN
									IF(@strXMLTag like '%:%')
									BEGIN
										SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @ParentTag + '.value(''(' + @strXMLTag + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + '' + CHAR(13)
									END

									ELSE
									BEGIN
										SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @ParentTag + '.value(''(' + @NamespaceVar + @strXMLTag + ')[1]'', ''nvarchar(200)''), '''') as ' + @strCompressTag + '' + CHAR(13)
								END
							END
						END		

					SET @intLoopCount = @intLoopCount + 1
					SET @intSubLevelMin = @intSubLevelMin + 1
				END
		END
	END

SET @intLevelMin = @intLevelMin + 1
END

SET @SQL =
N'
If(OBJECT_ID(''tempdb..#tempCheckoutInsert'') Is Not Null)
Begin
    Drop Table #tempCheckoutInsert
End
Declare @strXML nvarchar(max) 
SET @strXML = ''' + @strXML + '''
SET @strXML = REPLACE(@strXML, ''' + @strXMLinitiator + ''', '''')

--Replace single quote to double quote
SET @strXML = REPLACE(@strXML, '''''''','''')

Declare @xml XML = @strXML
' + @strRootTagNamespace + '

SELECT ' + CHAR(13)
+ @SELECTCOLUMNS
+ ' INTO #tempCheckoutInsert ' + CHAR(13)
+ ' FROM ' + CHAR(13)
+ @FROMNODES + CHAR(13)
+ ' SELECT * FROM #tempCheckoutInsert ' +  CHAR(13)
+ ' EXEC ' + @strSPName + ' ' + CAST(@intCheckoutId as nvarchar(20)) + ', ' + '@strStatusMsg OUTPUT, @intCountRows OUTPUT' +  CHAR(13)
+ ' DROP TABLE #tempCheckoutInsert ' +  CHAR(13)


DECLARE @ParmDef nvarchar(max);

SET @ParmDef = N'@strStatusMsg NVARCHAR(250) OUTPUT'
             + ', @intCountRows INT OUTPUT';

EXEC sp_executesql @SQL, @ParmDef, @strStatusMsg OUTPUT, @intCountRows OUTPUT

End Try

Begin Catch
	SET @intCountRows = 0
	SET @strStatusMsg = ERROR_MESSAGE()
End Catch
END