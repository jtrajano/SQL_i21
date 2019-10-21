CREATE VIEW [dbo].[vyuSMOriginTable]
AS

SELECT 
	name  COLLATE Latin1_General_CI_AS as strTableName,
	object_id as intTableId
FROM sys.tables 
WHERE name NOT LIKE 'tbl%' AND name NOT LIKE 'cst%'