/*
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPDatabaseDate')
	DROP VIEW vyuCPDatabaseDate
GO

CREATE VIEW [dbo].[vyuCPDatabaseDate]
AS
select
	id = 1
	,dbdate = GETDATE()

GO
*/

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPDatabaseDate')
	DROP VIEW vyuCPDatabaseDate
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPDatabaseDate]
		AS
		select
			id = 1
			,dbdate = GETDATE()
		')
GO