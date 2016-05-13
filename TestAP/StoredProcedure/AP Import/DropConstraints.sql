CREATE PROCEDURE [AP].[DropConstraints]
	@tableName NVARCHAR(100) = NULL
AS

--DROP ALL CONSTRAINT FIRST ON THE TABLE BEFORE FAKING
DECLARE @sql NVARCHAR(MAX) = N'';
DECLARE @parent_object_id INT;
DECLARE @tempScript TABLE(Id INT IDENTITY(1,1), strScript NVARCHAR(500))
DECLARE @tableReferences TABLE(Id INT);

IF @tableName IS NULL
BEGIN
	INSERT INTO @tempScript(strScript)
	SELECT N'
	ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))
		+ '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
		' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
	FROM sys.foreign_keys
END
ELSE
BEGIN
	
	INSERT INTO @tableReferences(Id)
	SELECT 
		referencing_id 
	FROM sys.sql_expression_dependencies 
	WHERE referenced_entity_name = 'tblSMUserSecurity'

	INSERT INTO @tempScript(strScript)
	SELECT N'
	ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))
		+ '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
		' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
	FROM sys.foreign_keys
	WHERE parent_object_id IN (SELECT Id FROM @tableReferences)

	--SCHEMA BINDING

	INSERT INTO @tempScript(strScript)
	SELECT DISTINCT
		'DROP VIEW ' + O.name
	FROM sys.sql_dependencies D
	JOIN sys.objects O ON O.OBJECT_ID=D.OBJECT_ID
	JOIN sys.objects R ON R.OBJECT_ID=D.referenced_major_id
	WHERE D.class=1
	AND R.name = @tableName
END

WHILE EXISTS(SELECT 1 FROM @tempScript)
BEGIN
	DECLARE @id INT
	SELECT TOP 1 @id = Id, @sql = strScript FROM @tempScript
	EXEC(@sql)
	DELETE FROM @tempScript WHERE Id = @id
END
