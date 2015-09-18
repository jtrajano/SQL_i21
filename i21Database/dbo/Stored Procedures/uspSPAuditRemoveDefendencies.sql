CREATE PROCEDURE [dbo].[uspSPAuditRemoveDefendencies]
	@Table NVARCHAR(150) = null,
	@Column NVARCHAR(150) = null
AS
BEGIN	
	SET NOCOUNT ON;

	-- REMOVE SCHEMA BINDING
	DECLARE @ViewName NVARCHAR(MAX), 
		@ViewScript NVARCHAR(MAX)

	DECLARE Cursor_View CURSOR FOR 
		SELECT TABLE_NAME, VIEW_DEFINITION FROM  INFORMATION_SCHEMA.VIEWS 
			where VIEW_DEFINITION like '%'+ @Table +'%'
			and VIEW_DEFINITION like '%WITH SCHEMABINDING%'
			and VIEW_DEFINITION like '%' + @Column +'%'

	OPEN Cursor_View FETCH NEXT FROM Cursor_View into @ViewName, @ViewScript
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		SET @ViewScript = REPLACE(@ViewScript,'CREATE', 'ALTER')
		SET @ViewScript = REPLACE(@ViewScript,'WITH SCHEMABINDING', '')
		EXEC sp_executesql @ViewScript
		FETCH NEXT FROM Cursor_View into @ViewName, @ViewScript
	END

	CLOSE Cursor_View
	DEALLOCATE Cursor_View

	--REMOVE CONTRAINTS
	DECLARE @TableConstrainName NVARCHAR(MAX)

	DECLARE Cursor_OwnConstraint CURSOR FOR
		SELECT CONSTRAINT_NAME FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			where TABLE_NAME = REPLACE(@Table,'dbo.','') 
			AND CONSTRAINT_TYPE <> 'PRIMARY KEY'

	OPEN Cursor_OwnConstraint FETCH NEXT FROM Cursor_OwnConstraint into @TableConstrainName
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
			
		--REMOVE REFERENCIAL CONTRAINTS
		DECLARE @RefConstrainName NVARCHAR(MAX),
			@RefTable NVARCHAR(MAX)

		DECLARE Cursor_RefConstraint CURSOR FOR
			SELECT R.CONSTRAINT_NAME, R.TABLE_NAME
				FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
					INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
						ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
						AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
						AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
					INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
						ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
						AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
						AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
					WHERE U.TABLE_NAME = REPLACE(@Table,'dbo.','') 
						AND U.CONSTRAINT_NAME = @TableConstrainName

		OPEN Cursor_RefConstraint FETCH NEXT FROM Cursor_RefConstraint into @RefConstrainName, @RefTable
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			--REMOVE REFERENCIAL CONTRAINTS
			DECLARE @RefConstrainScript NVARCHAR(MAX)
			SET @RefConstrainScript = 'ALTER TABLE ' + @RefTable + ' DROP CONSTRAINT [' +@RefConstrainName + ']'
			EXEC sp_executesql @RefConstrainScript
			FETCH NEXT FROM Cursor_RefConstraint into @RefConstrainName, @RefTable
		END	

		CLOSE Cursor_RefConstraint
		DEALLOCATE Cursor_RefConstraint

		--REMOVE TABLE CONTRAINTS
		DECLARE @TableConstrainScript NVARCHAR(MAX)
		SET @TableConstrainScript = 'ALTER TABLE ' + @Table + ' DROP CONSTRAINT [' + @TableConstrainName + ']'
		EXEC sp_executesql @TableConstrainScript
		FETCH NEXT FROM Cursor_OwnConstraint into @TableConstrainName
	END	

	CLOSE Cursor_OwnConstraint
	DEALLOCATE Cursor_OwnConstraint

	--REMOVE INDEX
	DECLARE @IndexName NVARCHAR(MAX)

	DECLARE Cursor_OwnIndex CURSOR FOR
		SELECT SysIndex.name As IndexName
		From sys.indexes As SysIndex
			Inner Join sys.index_columns As SysIndexCol On SysIndex.object_id = SysIndexCol.object_id And SysIndex.index_id = SysIndexCol.index_id 
			Inner Join sys.columns As SysCols On SysIndexCol.column_id = SysCols.column_id And SysIndexCol.object_id = SysCols.object_id 
		WHERE type <> 0 AND type <> 1
			AND SysIndex.object_id in (Select systbl.object_id from sys.tables as systbl Where systbl.name = REPLACE(@Table,'dbo.',''))
			AND SysCols.name = @Column

	OPEN Cursor_OwnIndex FETCH NEXT FROM Cursor_OwnIndex into @IndexName
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		DECLARE @DropIndexScript NVARCHAR(MAX)
		SET @DropIndexScript = 'DROP INDEX [' + @IndexName + '] ON ' + @Table
		PRINT(@DropIndexScript)
		EXEC sp_executesql @DropIndexScript
		FETCH NEXT FROM Cursor_OwnIndex into @IndexName
	END	

	CLOSE Cursor_OwnIndex
	DEALLOCATE Cursor_OwnIndex

END

