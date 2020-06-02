CREATE PROCEDURE [dbo].[uspSTXMLToIntermediateTable]
  @intImportFileHeaderId INT
, @intRegisterFileConfigId INT
, @intCheckoutId INT
, @strSPName NVARCHAR(100) 
, @strXML NVARCHAR(max)
, @strStatusMsg NVARCHAR(250) OUTPUT
, @intCountRows INT OUTPUT
AS
BEGIN
	BEGIN TRY

	SET NOCOUNT ON;

--PRINT '@intImportFileHeaderId: ' + CAST(@intImportFileHeaderId AS NVARCHAR(50))
--PRINT '@intRegisterFileConfigId: ' + CAST(@intRegisterFileConfigId AS NVARCHAR(50))
--PRINT '@intCheckoutId: ' + CAST(@intCheckoutId AS NVARCHAR(50))
--PRINT '@strSPName: ' + CAST(@strSPName AS NVARCHAR(50))
--PRINT '@intImportFileHeaderId: ' + CAST(@intImportFileHeaderId AS NVARCHAR(50))

	-- XML Layout version
	DECLARE @strXmlLayoutVersion AS NVARCHAR(20) = ''

	-- GET ROOT TAG
	DECLARE @strRootTag NVARCHAR(200), 
			@strRootCompressTag NVARCHAR(200), 
			@intRootLevel INT, 
			@intRootImportFileHeaderId INT, 
			@intRootImportFileColumnDetailId INT

	-- Get the Header element
	SELECT @intRootImportFileHeaderId = intImportFileHeaderId, 
	       @intRootImportFileColumnDetailId = intImportFileColumnDetailId, 
		   @strRootTag = REPLACE(strXMLTag, ' ', ''), 
		   @strRootCompressTag = REPLACE(REPLACE(REPLACE(strXMLTag, ' ', ''), ':', ''), '-', ''), 
		   @intRootLevel = intLevel 
    FROM dbo.tblSMImportFileColumnDetail 
	WHERE intImportFileHeaderId = @intImportFileHeaderId 
	AND intLevel <= 1

	--GET XML Initiator
	DECLARE @strXMLinitiator nvarchar(200) = ''
	SELECT @strXMLinitiator = strXMLInitiater FROM dbo.tblSMImportFileHeader WHERE intImportFileHeaderId = @intImportFileHeaderId
	SET @strXMLinitiator = ISNULL(@strXMLinitiator, '')

	DECLARE @NamespaceVar NVARCHAR(200) = '', @NamespaceVendor NVARCHAR(200) = ''

	-- GET FILE PREFIX
	DECLARE @strFilePrefix AS NVARCHAR(50) = (
												SELECT strFilePrefix 
												FROM tblSTRegisterFileConfiguration 
												WHERE intRegisterFileConfigId = @intRegisterFileConfigId
											 )

	-- ===============================================================================================================================================================
	-- START GET ROOT TAG Namespace
	-- Table tblSMXMLTagAttribute has two sttribute flag for version and xml namespace
	-- If has only 'version' attribute it means that there is no xml namespace
	DECLARE @strRootTagNamespace nvarchar(MAX) = ''
	IF EXISTS (SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intRootImportFileColumnDetailId AND strTagAttribute != 'version')
		BEGIN
			DECLARE @intTagAttributeIdMin Int, 
					@intTagAttributeIdMax Int

			SELECT  @intTagAttributeIdMin = MIN(intTagAttributeId)
				  , @intTagAttributeIdMax = MAX(intTagAttributeId)
			FROM dbo.tblSMXMLTagAttribute 
			WHERE intImportFileColumnDetailId = @intRootImportFileColumnDetailId
		
			DECLARE @intTempTagAttributeId int, 
			        @intTempImportFileColumnDetailId int, 
					@strTempTagAttribute NVARCHAR(200), 
					@strTempDefaultValue NVARCHAR(200)

			DECLARE @intLoopTagAttributeCount int = 0

			SET @strRootTagNamespace = @strRootTagNamespace + ';WITH XMLNAMESPACES ' + CHAR(13) + '(' + CHAR(13)

			WHILE(@intTagAttributeIdMin <= @intTagAttributeIdMax)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intRootImportFileColumnDetailId AND intTagAttributeId = @intTagAttributeIdMin)
				BEGIN
					SELECT @intTempTagAttributeId = intTagAttributeId, 
						   @intTempImportFileColumnDetailId = intImportFileColumnDetailId, 
						   @strTempTagAttribute = strTagAttribute, 
						   @strTempDefaultValue = strDefaultValue 
					FROM dbo.tblSMXMLTagAttribute 
					WHERE intTagAttributeId = @intTagAttributeIdMin
					
					IF(@strTempTagAttribute != 'version')
						BEGIN
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
					--ELSE IF(@strTempTagAttribute = 'version')
					--	BEGIN
					--		SET @strXmlLayoutVersion = @strTempDefaultValue
					--	END
				END    
 
				SET @intLoopTagAttributeCount = @intLoopTagAttributeCount + 1
				SET @intTagAttributeIdMin = @intTagAttributeIdMin + 1
			END

			SET @strRootTagNamespace = @strRootTagNamespace + ')'
		END
	-- END GET ROOT TAG Namespace
	-- ===============================================================================================================================================================



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
				DECLARE @strRegisterClassName AS NVARCHAR(50) = ''
				SET @strRegisterClassName = (SELECT strRegisterClass FROM tblSTRegister 
											WHERE intRegisterId = 
											(
												SELECT intRegisterId FROM tblSTStore
												WHERE intStoreId = 
												(
													SELECT intStoreId 
													FROM tblSTCheckoutHeader
													WHERE intCheckoutId = @intCheckoutId
												)
											))

				IF(@strRegisterClassName IN ('RADIANT', 'PASSPORT', 'SAPPHIRE', 'SAPPHIRE/COMMANDER'))
					BEGIN
						IF(@strFilePrefix = 'vtransset-tlog')
							BEGIN
								SET @FROMNODES = @FROMNODES + 'OUTER APPLY ' + REPLACE(@ParentTag, '-', '') + '.nodes(''' + @NamespaceVar + @strXMLTag + ''') ' + @strCompressTag + '(' + @strCompressTag + ')' + CHAR(13)
							END
						ELSE
							BEGIN
								SET @FROMNODES = @FROMNODES + 'CROSS APPLY ' + REPLACE(@ParentTag, '-', '') + '.nodes(''' + @NamespaceVar + @strXMLTag + ''') ' + @strCompressTag + '(' + @strCompressTag + ')' + CHAR(13)
							END
					END
				--ELSE --IF(@strRegisterClassName <> 'RADIANT')
				--	BEGIN
				--		SET @FROMNODES = @FROMNODES + 'OUTER APPLY ' + REPLACE(@ParentTag, '-', '') + '.nodes(''' + @NamespaceVar + @strXMLTag + ''') ' + @strCompressTag + '(' + @strCompressTag + ')' + CHAR(13)
				--	END
			END

		
			--GET attributes from Header Tag if has any
			DECLARE @strHeaderTagAttribute NVARCHAR(200)
			IF EXISTS(SELECT * FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND ysnActive = 1)
			BEGIN
				DECLARE @intHeaderAttributeMin Int, @intHeaderAttributeMax Int
				SELECT  @intHeaderAttributeMin = MIN(intSequence)
				      , @intHeaderAttributeMax = MAX(intSequence)
				FROM dbo.tblSMXMLTagAttribute 
				WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId 
				AND ysnActive = 1

				WHILE(@intHeaderAttributeMin <= @intHeaderAttributeMax)
				BEGIN
					SELECT @strHeaderTagAttribute = strTagAttribute FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intImportFileColumnDetailId AND ysnActive = 1 AND intSequence = @intHeaderAttributeMin

						IF(@intLoopCount = 0)
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
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @ParentTag + '.value(''(' + @strXMLTag + ')[1]'', ''NVARCHAR(200)''), '''') AS ' + @ParentTag + @strCompressTag + '' + CHAR(13)
										END

										ELSE
										BEGIN
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + 'ISNULL(' + @ParentTag + '.value(''(' + @NamespaceVar + @strXMLTag + ')[1]'', ''NVARCHAR(200)''), '''') AS ' + @ParentTag + @strCompressTag + '' + CHAR(13)
									END
								END

								ELSE if(@intLoopCount > 0)
									BEGIN
										IF(@strXMLTag like '%:%')
										BEGIN
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @ParentTag + '.value(''(' + @strXMLTag + ')[1]'', ''NVARCHAR(200)''), '''') AS ' + @ParentTag + @strCompressTag + '' + CHAR(13)
										END

										ELSE
										BEGIN
											SET @SELECTCOLUMNS = @SELECTCOLUMNS + ', ISNULL(' + @ParentTag + '.value(''(' + @NamespaceVar + @strXMLTag + ')[1]'', ''NVARCHAR(200)''), '''') AS ' + @ParentTag + @strCompressTag + '' + CHAR(13)
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

	--PRINT '@strRegisterClassName: ' + ISNULL(@strRegisterClassName, 'NULL')

	-- =========================================================================================================== 
	-- Start Validate Xml version
	-- ===========================================================================================================
	IF(@strRegisterClassName = 'PASSPORT' OR @strRegisterClassName = 'RADIANT')
		BEGIN
			-- COMMANDER and SAPPHIRE has no versioning

		    ------------------------------------------------------------------------------------------------------------------------
			-- XML Version
			DECLARE @strXmlVersion AS NVARCHAR(20)
			DECLARE @strXmlForVersion AS NVARCHAR(MAX) = @strXML
			SET @strXmlForVersion = REPLACE(@strXmlForVersion, '<?xml version="1.0" encoding="ISO-8859-1"?>', '')   
			SET @strXmlForVersion = REPLACE(@strXmlForVersion, '<?xml version="1.0" encoding="UTF-8"?>', '')

			--Replace single quote to double quote  
			SET @strXmlForVersion = REPLACE(@strXmlForVersion, '''','')    
			Declare @xmlVersion XML = @strXmlForVersion

			SELECT @strXmlVersion = ISNULL(NAXMLMovementReport.value('(@version)[1]', 'NVARCHAR(200)'), '0')
			FROM  @xmlVersion.nodes('NAXML-MovementReport') NAXMLMovementReport(NAXMLMovementReport)
			------------------------------------------------------------------------------------------------------------------------


			SET @strXmlLayoutVersion = (SELECT strDefaultValue FROM dbo.tblSMXMLTagAttribute WHERE intImportFileColumnDetailId = @intRootImportFileColumnDetailId AND strTagAttribute = 'version')

			IF(@strXmlVersion != @strXmlLayoutVersion)
				BEGIN
					
					SET @intCountRows = 0
					SET @strStatusMsg = 'ERROR: ' + @strFilePrefix + ' - Cannot map xml content to table. Version did not match. Layout setup is ' + @strXmlLayoutVersion + ' while Register xml is ' + @strXmlVersion

					-- Add to error logging
					INSERT INTO tblSTCheckoutErrorLogs 
					(
						strErrorType
						, strErrorMessage 
						, strRegisterTag
						, strRegisterTagValue
						, intCheckoutId
						, intConcurrencyId
					)
					VALUES
					(
						'XML VERSION'
						, @strStatusMsg
						, ''
						, ''
						, @intCheckoutId
						, 1
					)

					RETURN
				END
		END
    -- =========================================================================================================== 
	-- End Validate Xml version
	-- ===========================================================================================================


	--TEMPORARY FIX--
	--ALTER THIS LINE "OUTER APPLY trPaylines.nodes('trPayline') trPayline(trPayline)" to become this "OUTER APPLY trPaylines.nodes('trPayline[0]') trPayline(trPayline)"
	IF(LOWER(@strSPName) = 'uspstcheckoutcommandertranslog')
	BEGIN
			
		SET @FROMNODES = REPLACE(@FROMNODES,'OUTER APPLY trPaylines.nodes(''trPayline'') trPayline(trPayline)','OUTER APPLY trPaylines.nodes(''trPayline[1]'') trPayline(trPayline)')

	END

	-- ===========================================================================================================
	-- START - ORIGINAL CODE
	-- ===========================================================================================================
	SET @SQL =
	N'
	If(OBJECT_ID(''tempdb..#tempCheckoutInsert'') Is Not Null)
		BEGIN
			DROP TABLE #tempCheckoutInsert
		END

	DECLARE @strXML NVARCHAR(max) 
	SET @strXML = @strXMLParam
	SET @strXML = REPLACE(@strXML, @strXMLinitiatorParam, '''')

	--Replace single quote to double quote
	SET @strXML = REPLACE(@strXML, '''''''','''')

	Declare @xml XML = @strXML 
	' + @strRootTagNamespace + '


	 BEGIN TRY

	 SELECT ' + CHAR(13)
	+ ' IDENTITY(int, 1, 1) AS intRowCount, ' + CHAR(13)
	+ @SELECTCOLUMNS
	+ ' INTO #tempCheckoutInsert ' + CHAR(13)
	+ ' FROM ' + CHAR(13)
	+ @FROMNODES + CHAR(13)
	+ ' ORDER BY intRowCount ASC ' + CHAR(13) + CHAR(13)

	+ ' END TRY ' + CHAR(13)
	+ ' BEGIN CATCH ' + CHAR(13)

	+ '		SET @strStatusMsg = ERROR_MESSAGE() ' + CHAR(13)
	+ '		SET @intCountRows = 0 ' + CHAR(13)
	+ '		RETURN' + CHAR(13)

	+ ' END CATCH ' + CHAR(13)


	--+ ' -- SELECT * FROM #tempCheckoutInsert ' +  CHAR(13)
	+ ' EXEC @strSPNameParam @intCheckoutIdParam, @strStatusMsg OUTPUT, @intCountRows OUTPUT ' +  CHAR(13)
	+ ' DROP TABLE #tempCheckoutInsert ' +  CHAR(13)
	
	DECLARE @ParmDef NVARCHAR(MAX);

	SET @ParmDef = N'@strXMLParam NVARCHAR(MAX)'
	             + ', @strXMLinitiatorParam NVARCHAR(MAX)'
				 + ', @strRootTagNamespaceParam NVARCHAR(MAX)'
				 + ', @strSPNameParam NVARCHAR(250)'
				 + ', @intCheckoutIdParam INT'
	             + ', @strStatusMsg NVARCHAR(250) OUTPUT'
	             + ', @intCountRows INT OUTPUT';

	--EXEC CopierDB.dbo.LongPrint @SQL
	--EXEC CopierDB.dbo.LongPrint @strXML
	--PRINT @SQL
	--PRINT @strXML

	EXEC sp_executesql @SQL, @ParmDef, @strXML, @strXMLinitiator, @strRootTagNamespace, @strSPName, @intCheckoutId, @strStatusMsg OUTPUT, @intCountRows OUTPUT
	-- ===========================================================================================================
	-- END - ORIGINAL CODE
	-- ===========================================================================================================

	

	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END