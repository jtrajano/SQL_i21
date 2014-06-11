﻿CREATE PROCEDURE [dbo].[uspSMMigrateTransactionUser]
@Module NVARCHAR(10)
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @tablename NVARCHAR(100)
	
	SELECT [Table_Name]
	INTO #tmpGLTables
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE [Column_Name] = 'intEntityId'
	AND [Table_Name] LIKE 'tbl' + @Module + '%'
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpGLTables)
	BEGIN
		SELECT TOP 1 @tablename = [Table_Name] FROM #tmpGLTables
		
		IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'intUserId' AND OBJECT_ID = OBJECT_ID(@tablename))
		BEGIN
			EXEC('UPDATE ' + @tablename + ' SET intEntityId = dbo.fnGetEntityIdFromUser(intUserId) WHERE ISNULL(intEntityId, -1) = -1')
		END
		
		DELETE FROM #tmpGLTables WHERE [Table_Name] = @tablename
	END
	
	DROP TABLE #tmpGLTables
	
END