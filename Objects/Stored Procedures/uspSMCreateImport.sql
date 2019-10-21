--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE uspSMCreateImport
	@id				AS INT = 0,
	@executeImport	AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpColumnDictionary (
	[intColumnDictionaryId]		INT,
	[strFieldName]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[strFieldType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[intSize]					INT,
	[ysnKey]					BIT,
	[ysnAllowNull]				BIT,
	[intSort]					INT	
);

CREATE TABLE #tmpMappingDictionary (
	[intMappingDictionaryId]	INT,
	[intColumnDictionaryId]		INT,
	[strSourceTable]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[strFieldName]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[strFieldType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[strDelimeter]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSize]					INT,
	[intSort]					INT	
);

CREATE TABLE #tmpSourceTable (
	[strSourceTable]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
);

CREATE TABLE #tmpInsertScripts(
	[intRow]					INT,
	[strScript]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strMessage]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
);

--=====================================================================================================================================
-- 	DECLARE GLOBAL VARIABLES
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @tableName				AS NVARCHAR(50)
DECLARE @tableExist				AS BIT
DECLARE @insertScript			AS NVARCHAR(MAX) = ''
DECLARE @selectScript			AS NVARCHAR(MAX) = ''
DECLARE @insertCount			AS INT = 0
DECLARE @alterColumnCount		AS INT = 0
DECLARE @counter				AS INT = 1
DECLARE @finalInsert			AS NVARCHAR(MAX) = ''

SELECT	@tableName  = strTableName,
		@tableExist = ISNULL((SELECT 1 FROM sys.tables WHERE name = strTableName COLLATE Latin1_General_CI_AS), 0)
FROM tblSMTableDictionary WHERE [intTableDictionaryId] = @id							 

INSERT INTO #tmpSourceTable
	SELECT DISTINCT strSourceTable 
	FROM tblSMMappingDictionary 
	WHERE intColumnDictionaryId IN (SELECT intColumnDictionaryId 
									FROM  tblSMColumnDictionary 
									WHERE intTableDictionaryId = @id AND ISNULL(ysnKey, 0) = 0 )

--=====================================================================================================================================
-- 	LOOP ALL DISTINCT SOURCE TABLE 
---------------------------------------------------------------------------------------------------------------------------------------
WHILE EXISTS(SELECT TOP (1) 1 FROM #tmpSourceTable)
BEGIN		
	DECLARE @sourceTable	AS NVARCHAR(50)	
	DECLARE @addCommaValue	AS NVARCHAR(1) = ''
	
	SELECT TOP (1) @sourceTable  = strSourceTable 
	FROM #tmpSourceTable
	
	INSERT INTO #tmpColumnDictionary 
		SELECT [intColumnDictionaryId],
			[strFieldName],
			[strFieldType],
			[intSize],
			[ysnKey],
			[ysnAllowNull],
			[intSort]
		FROM tblSMColumnDictionary 
		WHERE intTableDictionaryId = @id AND ISNULL(ysnKey, 0) = 0 

	INSERT INTO #tmpMappingDictionary 
		SELECT [intMappingDictionaryId],
			[intColumnDictionaryId],
			[strSourceTable],
			[strFieldName],
			[strFieldType],
			[strDelimiter],
			[intSize],
			[intSort]
		FROM tblSMMappingDictionary 
		WHERE intColumnDictionaryId IN (SELECT intColumnDictionaryId FROM  #tmpColumnDictionary) AND
			  strSourceTable = @sourceTable
			 
			  
	SET @insertScript = 'INSERT INTO dbo.' + @tableName + '(' + CHAR(13) + CHAR(10)
	SET @selectScript = 'SELECT' + CHAR(13) + CHAR(10)
			  
	--=====================================================================================================================================
	-- 	LOOP ALL COLUMN DICTIONARY
	---------------------------------------------------------------------------------------------------------------------------------------
	WHILE EXISTS(SELECT TOP (1) 1 FROM #tmpColumnDictionary)
	BEGIN
		DECLARE @columnId		AS INT
		DECLARE @fieldName		AS NVARCHAR(50)
		DECLARE @fieldType		AS NVARCHAR(50)
		DECLARE @allowNull		AS BIT
		DECLARE @fieldExisting	AS BIT
		DECLARE @selectValue	AS NVARCHAR(MAX) = ''
		DECLARE @delimeter		AS NVARCHAR(50)  = ''
		DECLARE @excess			AS NVARCHAR(50)	 = ''
		DECLARE @executeScript	AS NVARCHAR(MAX) = ''

		SELECT TOP 1 @columnId  = intColumnDictionaryId,
					 @fieldName = strFieldName,
					 @fieldType = strFieldType,
					 @allowNull = ISNULL(ysnAllowNull, 0)
		FROM #tmpColumnDictionary
		
		SELECT @fieldExisting = ISNULL(( SELECT 1
										 FROM sys.columns 
										 WHERE object_id =( SELECT object_id
															FROM sys.tables 
															WHERE name = @tableName COLLATE Latin1_General_CI_AS) AND 
											   name = @fieldName COLLATE Latin1_General_CI_AS), 0)
						
		-- Check if the field is existing in the database OR the import is just for generating script before composing the script 					   										
		IF (@fieldExisting = 1 OR @executeImport = 0)
			BEGIN		
				SELECT @selectValue = @selectValue + ISNULL('[' + A.strFieldName + '] ' + '+ ''' + ISNULL(strDelimeter, '') + ''' + ', ''),
					   @delimeter	= ISNULL(strDelimeter, ''),
					   @excess		= '+ ''' + ISNULL(strDelimeter, '') + ''' + '
				FROM #tmpMappingDictionary A 
				INNER JOIN (SELECT name AS strFieldName 
							FROM sys.columns 
							WHERE object_id = ( SELECT object_id
												FROM sys.tables 
												WHERE name = @sourceTable COLLATE Latin1_General_CI_AS)) B
				ON A.strFieldName = B.strFieldName COLLATE Latin1_General_CI_AS
				WHERE intColumnDictionaryId = @columnId ORDER BY intSort		
				
				IF @selectValue <> '' OR @allowNull = 0
					BEGIN
						SET @insertScript = @insertScript + @addCommaValue + '[' + @fieldName + '] ' + CHAR(13) + CHAR(10)									
						
						IF @selectValue <> ''
							BEGIN
								SET @selectValue = REVERSE(SUBSTRING(REVERSE(@selectValue), LEN(@excess) + 1, LEN(@selectValue)))
								SET @selectScript = @selectScript + @addCommaValue + SUBSTRING(@selectValue, 0, LEN(@selectValue)) + CHAR(13) + CHAR(10)
							END
						ELSE
							BEGIN
								SET @selectScript = @selectScript + 
													@addCommaValue + CASE	WHEN @fieldType = 'nvarchar' THEN ''''''
																			WHEN @fieldType = 'int'		 THEN '0'
																			WHEN @fieldType = 'numeric'  THEN '0'
																			WHEN @fieldType = 'bit'		 THEN '0'
																			WHEN @fieldType = 'date'	 THEN 'GETDATE()'
																			ELSE ''''''
																	 END + CHAR(13) + CHAR(10)												 																			 
							END
							
					    SET @addCommaValue = ','
					    SET @insertCount = @insertCount + 1	
					END
			END
		
		DELETE TOP (1) FROM #tmpColumnDictionary
	END	  
	
	SET @insertScript = @insertScript + ')'
	SET @selectScript = @selectScript + 'FROM dbo.' + @sourceTable
	
	SET @executeScript = CASE WHEN @insertCount > 0 THEN	
							@insertScript + CHAR(13) + CHAR(10) + @selectScript + CHAR(13) + CHAR(10)
						 ELSE '' END
	
	INSERT INTO #tmpInsertScripts
		SELECT @counter, @executeScript, ''
		
	IF @executeImport = 1 AND @executeScript <> ''
	BEGIN
		BEGIN TRANSACTION

		EXEC(@executeScript)
		--
		--UPDATE #tmpInsertScripts
		--SET strMessage = ''
		--WHERE intRow = @counter
		----
		COMMIT TRANSACTION
	END
	
	SET @counter = @counter + 1
	
	DELETE FROM #tmpColumnDictionary
	DELETE FROM #tmpMappingDictionary	  
	DELETE TOP(1) FROM #tmpSourceTable
END


SELECT @finalInsert = @finalInsert + strScript + CHAR(13) + CHAR(10)
FROM #tmpInsertScripts

SELECT @finalInsert AS strScript,
		''			AS strMessage

DROP TABLE #tmpColumnDictionary
DROP TABLE #tmpMappingDictionary
DROP TABLE #tmpSourceTable

GO