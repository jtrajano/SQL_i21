IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPDatabaseDate')
	DROP VIEW vwCPDatabaseDate
GO

CREATE VIEW [dbo].[vwCPDatabaseDate]
AS
select
	id = 1
	,dbdate = GETDATE()

GO