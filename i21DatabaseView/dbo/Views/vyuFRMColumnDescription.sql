
CREATE VIEW vyuFRMColumnDescription
AS

SELECT 
	CASE class 
		WHEN 1 THEN 
			(
				SELECT SCHEMA_NAME(o.schema_id)
				FROM sys.objects o
				WHERE o.object_id = major_id
			) 
		END AS [SCHEMA_NAME],
	CASE class 
		WHEN 0 THEN DB_NAME()
		WHEN 1 THEN OBJECT_NAME(major_id)
		WHEN 3 THEN SCHEMA_NAME(major_id)
		END AS [TABLE_NAME],
	CASE class
		WHEN 1 THEN
			(
				SELECT c.name
				FROM sys.columns c
				WHERE c.object_id = major_id
				AND c.column_id = minor_id
			)
		END AS [COLUMN_NAME],
	value AS [DESCRIPTION]
FROM sys.extended_properties
WHERE  
	class = 1 -- OBJECT_OR_COLUMN
	AND name = 'MS_Description'