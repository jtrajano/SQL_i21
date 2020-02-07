-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory transaction types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Inventory Data Sources *******************/')
GO
-- Use UPSERT to populate the inventory transaction types
MERGE 
INTO	dbo.tblICDataSource
WITH	(HOLDLOCK) 
AS		ICDataSource
USING	(
		SELECT	id = 1 ,strType = 'CStore'
		UNION ALL
		SELECT id = 2, strType = 'Import CSV'
		UNION ALL
		SELECT id = 3, strType = 'i21 RESTful API'
) AS DataSourceTypes
	ON  ICDataSource.intDataSourceId = DataSourceTypes.id

-- When id is matched, make sure the name and form are up-to-date.
WHEN MATCHED THEN 
	UPDATE 
	SET 	strSourceName = DataSourceTypes.strType		

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intDataSourceId
		,strSourceName
	)
	VALUES (
		DataSourceTypes.id
		,DataSourceTypes.strType
	)
;
GO
print('/*******************  END Populate Inventory Data Sources *******************/')