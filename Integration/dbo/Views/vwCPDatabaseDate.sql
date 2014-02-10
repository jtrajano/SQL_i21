CREATE VIEW [dbo].[vwCPDatabaseDate]
AS
select
	id = 1
	,dbdate = GETDATE()