--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE uspSMBuildTable
	@id				AS INT = 0,
	@executeBuild	AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpColumnDictionary (
	[intColumnDictionaryId] INT,
	[strFieldName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[strFieldType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[intSize]	   INT,
	[ysnKey]	   BIT,
	[ysnAllowNull] BIT,
	[intSort]	   INT	
);

--=====================================================================================================================================
-- 	DECLARE GLOBAL VARIABLES
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @tableName				AS NVARCHAR(50)
DECLARE @tableExist				AS BIT
DECLARE @keyField				AS NVARCHAR(50)
DECLARE @generateTableScript	AS NVARCHAR(MAX)
DECLARE @alterColumnStatement	AS NVARCHAR(MAX) = ''
DECLARE @addCommaValue			AS NVARCHAR(1) = ''
DECLARE @addColumnCount			AS INT = 0
DECLARE @alterColumnCount		AS INT = 0

SELECT	@tableName  = strTableName,
		@tableExist = ISNULL((SELECT 1 FROM sys.tables WHERE name = strTableName COLLATE Latin1_General_CI_AS), 0)
FROM tblSMTableDictionary WHERE [intTableDictionaryId] = @id

SET @generateTableScript =  CASE WHEN @tableExist = 0 THEN 
								'CREATE' 
							ELSE 
								'ALTER' 
							END 
								+ ' TABLE dbo.' + @tableName + 
							CASE WHEN @tableExist = 0 THEN 
								'(' + CHAR(13) + CHAR(10)
							ELSE 
								CHAR(13) + CHAR(10) + 'ADD ' 
							END  
								 
INSERT INTO #tmpColumnDictionary 
	SELECT [intColumnDictionaryId],
		[strFieldName],
		[strFieldType],
		[intSize],
		[ysnKey],
		[ysnAllowNull],
		[intSort]
	FROM tblSMColumnDictionary 
	WHERE intTableDictionaryId = @id AND ysnModified = 1
	ORDER BY intSort ASC
	
WHILE EXISTS(SELECT TOP (1) 1 FROM #tmpColumnDictionary)
BEGIN
	DECLARE @fieldName		AS NVARCHAR(50)
	DECLARE @fieldType		AS NVARCHAR(50)
	DECLARE @allowNull		AS NVARCHAR(50)
	DECLARE @fieldExisting	AS BIT

	SELECT TOP 1 
		@fieldName = strFieldName,
		@fieldType = CASE WHEN strFieldType = 'nvarchar'	THEN 'NVARCHAR(' + CASE WHEN CAST(ISNULL(intSize, -1) AS NVARCHAR(25)) = -1 THEN 'MAX' ELSE CAST(ISNULL(intSize, -1) AS NVARCHAR(25)) END + ') COLLATE Latin1_General_CI_AS'
						  WHEN strFieldType = 'numeric'		THEN 'NUMERIC(18,' + CAST(ISNULL(intSize, 6) AS NVARCHAR(25)) + ')'
						  WHEN strFieldType = 'decimal'		THEN 'NUMERIC(18,' + CAST(ISNULL(intSize, 6) AS NVARCHAR(25)) + ')'
						  WHEN strFieldType = 'varbinary'	THEN 'VARBINARY(MAX)'
						  ELSE UPPER(strFieldType)
					 END + 
					 CASE WHEN ISNULL(ysnKey, 0) = 1 THEN ' IDENTITY (1, 1)'
						  ELSE ''
					 END,
		@allowNull = CASE WHEN ISNULL(ysnAllowNull, 0) = 1 THEN 'NULL'
						  ELSE 'NOT NULL'
					 END,
		@keyField  = CASE WHEN ISNULL(ysnKey, 0) = 1 THEN strFieldName
						  ELSE @keyField
					 END
	FROM #tmpColumnDictionary
	
	SELECT @fieldExisting = ISNULL(( SELECT 1
									 FROM sys.columns 
									 WHERE object_id =( SELECT object_id
														FROM sys.tables 
														WHERE name = @tableName COLLATE Latin1_General_CI_AS) AND 
										   name = @fieldName COLLATE Latin1_General_CI_AS), 0)
												
	IF (@fieldExisting = 0)
		BEGIN
			SELECT @generateTableScript = @generateTableScript + @addCommaValue + '[' + @fieldName + '] ' +  @fieldType + ' ' + @allowNull + CHAR(13) + CHAR(10)
			SELECT @addCommaValue = ','	
			SELECT @addColumnCount = @addColumnCount + 1	
		END
	ELSE
		BEGIN
			SELECT @alterColumnStatement = @alterColumnStatement + 'ALTER TABLE dbo.' + @tableName + CHAR(13) + CHAR(10) + 'ALTER COLUMN ' +  '[' + @fieldName + '] ' + @fieldType + ';' + CHAR(13) + CHAR(10)
			SELECT @alterColumnCount = @alterColumnCount + 1
		END
	
	DELETE TOP (1) FROM #tmpColumnDictionary 
END

SELECT @generateTableScript = @generateTableScript +  
									CASE WHEN @tableExist = 0 THEN 
										',' + 'CONSTRAINT [PK_' + @tableName + '] PRIMARY KEY CLUSTERED ([' + @keyField + '] ASC)' + CHAR(13) + CHAR(10) + ');'
									ELSE ''
									END 

IF (@addColumnCount > 0 OR @alterColumnCount > 0)
BEGIN
	IF (@addColumnCount > 0 AND @executeBuild = 1)
		BEGIN
			EXEC(@generateTableScript)
		END
	
	IF (@alterColumnCount > 0 AND @executeBuild = 1)
		BEGIN
			EXEC(@alterColumnStatement)
		END
		
	IF @executeBuild = 1 AND @@ERROR = 0
	BEGIN
		UPDATE tblSMColumnDictionary 
		SET ysnModified = 0
		WHERE intTableDictionaryId = @id
		
		UPDATE tblSMTableDictionary
		SET ysnCreated = 1
		WHERE intTableDictionaryId = @id
	END
END

DROP TABLE #tmpColumnDictionary

SELECT @generateTableScript		AS [strCreateScript],
	   @alterColumnStatement	AS [strAlterScript],
	   ''						As [strMessage]

GO