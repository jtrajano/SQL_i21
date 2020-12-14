-- =============================================
-- Author:		Jeffrey Trajano
-- Create date: 27/11/2020
-- Description:	Data source for combo box in Consolidate screen
-- =============================================
CREATE FUNCTION fnGLGetRelativeDatabase()
RETURNS @tbl TABLE (intDatabaseId int, strDatabase nvarchar(30))
AS
BEGIN
declare @dbId int
select @dbId = DB_ID()
INSERT INTO @tbl(intDatabaseId, strDatabase)
select database_id, [name] from master.sys.databases where database_id <> @dbId
and [name] not in( 'master' , 'tempdb', 'msdb', 'model','i21Hangfire')
and [name] not like ('%cfg')
and database_id not in (select intDatabaseId from tblGLSubsidiaryCompany)
RETURN
END