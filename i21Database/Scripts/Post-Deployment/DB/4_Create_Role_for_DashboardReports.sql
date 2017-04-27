
-- **************************************************************
-- 1 - db_dashboardreports
-- 1a - Create role
-- Create Role in Database
go
if not exists (select 1 from sys.database_principals where name='db_dashboardreports' and Type = 'R')
begin
	print 'db_dashboardreports does not exists'
	CREATE ROLE db_dashboardreports
end
else
begin
	print 'db_dashboardreports exists'
end
go
-- 1b - Grant permissions
-- CHANGE ROLE Name
GRANT EXECUTE TO db_dashboardreports

-- **************************************************************
-- 2 - Create permissions
DECLARE @Table_Name nvarchar(250);
DECLARE @CMDEXEC1 nvarchar(2000);
DECLARE db_cursor CURSOR FOR  
select name from sys.tables
where name like 'pr%' or name like 'tblPR%' order by name
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @Table_Name
WHILE @@FETCH_STATUS = 0   
BEGIN
   
-- CHANGE ROLE Name
 SET @CMDEXEC1 = 'deny select, insert, update, delete on [' + @Table_Name + '] TO db_dashboardreports;'
 SELECT @CMDEXEC1 
 EXEC(@CMDEXEC1)
 FETCH NEXT FROM db_cursor INTO @Table_Name
END
CLOSE db_cursor   
DEALLOCATE db_cursor
GO

-- 3 - Create permissions for Stored Procedures
DECLARE @Function_Name nvarchar(250);
DECLARE @CMDEXEC2 nvarchar(2000);
DECLARE db_cursor CURSOR FOR  
SELECT [Name] FROM [sys].[procedures]
where [Name] like '%Report'
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @Function_Name
WHILE @@FETCH_STATUS = 0   
BEGIN
   
-- CHANGE ROLE Name
 SET @CMDEXEC2 = 'GRANT EXECUTE ON [' + @Function_Name + '] TO db_dashboardreports;'
 SELECT @CMDEXEC2
 EXEC(@CMDEXEC2)
 FETCH NEXT FROM db_cursor INTO @Function_Name
END
CLOSE db_cursor   
DEALLOCATE db_cursor
GO

/*
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'irelydashboard')
	BEGIN
		CREATE LOGIN [irelydashboard] WITH PASSWORD=N'iRely@dash', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
		-- Password:iRely@dash
	END
else
	BEGIN
		ALTER LOGIN [irelydashboard] WITH PASSWORD=N'iRely@dash'
	END	
	
--EXEC sp_adduser 'irelydashboard';
--CREATE USER [irelydashboard]; --FOR LOGIN [irelydashboard];
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'irelydashboard')
BEGIN
	DROP USER [irelydashboard]
END

CREATE USER [irelydashboard] FOR LOGIN [irelydashboard] WITH DEFAULT_SCHEMA = [irelydashboard];
EXEC sp_addrolemember 'db_datareader', 'irelydashboard';
EXEC sp_addrolemember 'db_dashboardreports', 'irelydashboard';
--DROP SCHEMA irelydashboard
*/