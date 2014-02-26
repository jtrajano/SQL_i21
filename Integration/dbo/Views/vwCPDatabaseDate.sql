/*
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPDatabaseDate')
	DROP VIEW vwCPDatabaseDate
GO

CREATE VIEW [dbo].[vwCPDatabaseDate]
AS
select
	id = 1
	,dbdate = GETDATE()

GO
*/

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPDatabaseDate')
	DROP VIEW vwCPDatabaseDate
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwCPDatabaseDate]
		AS
		select
			id = 1
			,dbdate = GETDATE()
		')
GO