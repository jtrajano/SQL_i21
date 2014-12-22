CREATE PROCEDURE [tSQLt].[PrepareTableForFaking]
    @TableName NVARCHAR(MAX),
    @SchemaName NVARCHAR(MAX)
AS
BEGIN
	--remove brackets
	SELECT @TableName = (REPLACE(REPLACE(@TableName, '[', ''), ']', ''));
	SELECT @SchemaName = (REPLACE(REPLACE(@SchemaName, '[', ''), ']', ''));
	
	-- delete temptable
	IF EXISTS(SELECT * FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb.dbo.#TEMP'))
		DROP TABLE #TEMP
 
	-- recursively get all referencing dependencies
	-- then add all the selected objects that is referencing this table in reverse level order into a temp table
	BEGIN 
		;WITH ReferencedDependencies (parentId, name, LEVEL)
		AS(
			SELECT DISTINCT o.object_id AS parentId, o.name, 0 AS LEVEL
			FROM sys.sql_expression_dependencies AS d
			JOIN sys.objects AS o
				ON d.referencing_id = o.object_id
				AND o.type IN ('FN','IF','TF', 'V', 'P')
				AND is_schema_bound_reference = 1
			WHERE
				d.referencing_class = 1 AND referenced_entity_name = @TableName AND referenced_schema_name = @SchemaName
			UNION ALL
			SELECT o.object_id AS parentId, o.name, LEVEL +1
			FROM sys.sql_expression_dependencies AS d
			JOIN sys.objects AS o
					ON d.referencing_id = o.object_id
				AND o.type IN ('FN','IF','TF', 'V', 'P')
				AND is_schema_bound_reference = 1
			JOIN ReferencedDependencies AS rd
					ON d.referenced_id = rd.parentId
		) 	
		SELECT DISTINCT IDENTITY(INT, 1,1) AS id, name, OBJECT_DEFINITION(parentId) as obj_def, parentId as obj_Id , LEVEL
		INTO	#TEMP
		FROM	ReferencedDependencies
		WHERE	OBJECT_DEFINITION(parentId) LIKE '%SCHEMABINDING%'
		ORDER BY LEVEL DESC
		OPTION (Maxrecursion 1000);
	END 

	--prepere the query to remove all dependent indexes (this is nessesary to removing (with schemabinding) later)
	BEGIN 
		DECLARE @qryRemoveIndexes NVARCHAR(MAX);
		SELECT @qryRemoveIndexes = (
			SELECT	'DROP INDEX ' + i.name + ' ON ' + OBJECT_NAME(o.id) + '; ' 
			FROM	sys.sysobjects AS o INNER JOIN #TEMP 
						ON o.id = #TEMP.obj_Id
					INNER JOIN sys.sysindexes AS i 
						ON i.id = o.id
			WHERE	i.indid = 1 -- 1 = Clustered index (we are only interested in clusterd indexes)
			FOR XML PATH('')
		);
		exec sp_executesql @qryRemoveIndexes;
	END 
	 
	--change the definition for removing (with schemabinding) from those objects
	BEGIN 
		DECLARE @currentRecord INT

		DECLARE @qryRemoveWithSchemabinding NVARCHAR(MAX)
		SET		@currentRecord = 1
		WHILE	(@currentRecord <= (SELECT COUNT(1) FROM #TEMP) )
		BEGIN
				SET		@qryRemoveWithSchemabinding = ''
				
				SELECT	@qryRemoveWithSchemabinding = #TEMP.obj_def
				FROM	#TEMP
				WHERE	#TEMP.id = @currentRecord
				
				SET @qryRemoveWithSchemabinding = REPLACE(@qryRemoveWithSchemabinding,'CREATE', 'ALTER')
				SET @qryRemoveWithSchemabinding = REPLACE(@qryRemoveWithSchemabinding,'WITH SCHEMABINDING', ''); -- remove schema binding
				SET @qryRemoveWithSchemabinding = REPLACE(@qryRemoveWithSchemabinding,'with schemabinding', ''); -- remove schema binding
				
				EXEC sp_executesql @qryRemoveWithSchemabinding;
				SET @currentRecord = @currentRecord + 1
		END
	END 
END
