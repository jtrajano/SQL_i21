--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE uspSMBuildCustomTable
	@customFieldId AS INT = 0,
	@tableName AS NVARCHAR(50) = ''
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpCustomFieldDetail (
	[intCustomFieldDetailId] [int] PRIMARY KEY,
	[strFieldName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[strFieldType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,  
	[strFieldSize] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL  
);

DECLARE @addColumnStatement AS NVARCHAR(MAX)
DECLARE @alterColumnStatement AS NVARCHAR(MAX)
DECLARE @addCommaValue AS NVARCHAR(1) = ''
DECLARE @alterCommaValue AS NVARCHAR(1) = ''
DECLARE @addColumnCount AS INT = 0
DECLARE @alterColumnCount AS INT = 0

SET @addColumnStatement = 'ALTER TABLE dbo.' + @tableName + CHAR(13) + 'ADD '
SET @alterColumnStatement = ''

INSERT INTO #tmpCustomFieldDetail 
	SELECT [intCustomFieldDetailId],
		[strFieldName],
		[strFieldType],
		[strFieldSize]
	FROM tblSMCustomFieldDetail WHERE intCustomFieldId = @customFieldId AND ysnModified = 1

WHILE EXISTS(SELECT TOP (1) 1 FROM #tmpCustomFieldDetail)
BEGIN
	DECLARE @fieldName AS NVARCHAR(50)
	DECLARE @fieldType AS NVARCHAR(50)
	DECLARE @existingCount AS INT = 0

	SELECT TOP 1 
		@fieldName = strFieldName,
		@fieldType = CASE WHEN strFieldType = 'TEXT'	THEN 'NVARCHAR(' + strFieldSize + ') COLLATE Latin1_General_CI_AS'
						  WHEN strFieldType = 'INTEGER' THEN 'INT'
						  WHEN strFieldType = 'DECIMAL' THEN 'DECIMAL(18,' + strFieldSize + ')'
						  WHEN strFieldType = 'DATE'	THEN 'DATETIME'
						  WHEN strFieldType = 'BIT'		THEN 'BIT'
					 END
	FROM #tmpCustomFieldDetail
	
	SELECT @existingCount = COUNT(*) FROM sys.columns 
	WHERE OBJECT_ID = ( SELECT OBJECT_ID FROM sys.tables 
						WHERE NAME = @tableName) AND NAME = @fieldName
	
	IF (@existingCount = 0)
		BEGIN
			SELECT @addColumnStatement = @addColumnStatement + @addCommaValue + @fieldName + ' ' + @fieldType + ' NULL' + CHAR(13)
			SELECT @addCommaValue = ','	
			SELECT @addColumnCount = @addColumnCount + 1	
		END
	ELSE
		BEGIN
			SELECT @alterColumnStatement = @alterColumnStatement + 'ALTER TABLE dbo.' + @tableName + CHAR(13) + 'ALTER COLUMN ' + @fieldName + ' ' + @fieldType + ';' + CHAR(13)
			SELECT @alterColumnCount = @alterColumnCount + 1
		END
	
	DELETE TOP (1) FROM #tmpCustomFieldDetail
END

PRINT(@addColumnStatement)
PRINT(@alterColumnStatement)

IF (@addColumnCount > 0 OR @alterColumnCount > 0)
BEGIN
	IF (@addColumnCount > 0)
	BEGIN
		EXEC(@addColumnStatement)
	END
	
	IF (@alterColumnCount > 0)
	BEGIN
		EXEC(@alterColumnStatement)
	END
	
	UPDATE tblSMCustomFieldDetail 
	SET ysnBuild = 1, ysnModified = 0
	WHERE intCustomFieldId = @customFieldId
	
	UPDATE tblSMCustomField
	SET ysnBuild = 1
	WHERE intCustomFieldId = @customFieldId
END

DROP TABLE #tmpCustomFieldDetail

GO




