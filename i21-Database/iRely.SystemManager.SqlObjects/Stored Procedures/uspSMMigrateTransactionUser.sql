CREATE PROCEDURE [dbo].[uspSMMigrateTransactionUser]
@Module NVARCHAR(10)
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @tablename NVARCHAR(100)
	
	SELECT TABLE_NAME
	INTO #tmpGLTables
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE COLUMN_NAME = 'intEntityId'
	AND TABLE_NAME LIKE 'tbl' + @Module + '%'
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpGLTables)
	BEGIN
		SELECT TOP 1 @tablename = [TABLE_NAME] FROM #tmpGLTables
		
		IF EXISTS(SELECT * FROM sys.columns WHERE name = N'intUserId' AND object_id = OBJECT_ID(@tablename))
		BEGIN
			EXEC('UPDATE ' + @tablename + ' SET intEntityId = dbo.fnGetEntityIdFromUser(intUserId) WHERE ISNULL(intEntityId, -1) = -1')
		END
		
		DELETE FROM #tmpGLTables WHERE [TABLE_NAME] = @tablename
	END
	
	DROP TABLE #tmpGLTables
	
END