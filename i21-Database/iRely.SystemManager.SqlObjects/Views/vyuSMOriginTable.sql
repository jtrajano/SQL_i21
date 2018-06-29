CREATE VIEW [dbo].[vyuSMOriginTable]
AS

SELECT 
	name as strTableName,
	object_id as intTableId
FROM sys.tables 
WHERE name NOT LIKE 'tbl%' AND name NOT LIKE 'cst%'