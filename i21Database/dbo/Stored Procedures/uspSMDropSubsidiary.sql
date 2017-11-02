CREATE PROCEDURE [dbo].[uspSMDropSubsidiary]
 @dbname NVARCHAR(100)
  
AS
DECLARE @dropDB_SQL NVARCHAR(max)
BEGIN	
	IF EXISTS (SELECT name FROM master.sys.databases WHERE name =  @dbname) 
	BEGIN
		print @dbname		
		SET @dropDB_SQL = N'ALTER DATABASE [' +@dbname + N'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
							DROP DATABASE ' +  @dbname;
		exec(@dropDB_SQL);
		
	END
END
GO






