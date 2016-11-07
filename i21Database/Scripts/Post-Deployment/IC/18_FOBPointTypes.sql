-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory transaction types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Fob Point Types *******************/')
GO
-- Use UPSERT to populate the inventory transaction types
MERGE 
INTO	dbo.tblICFobPoint
WITH	(HOLDLOCK) 
AS		FobPoint
USING	(
		SELECT	intFobPointId = 1
				,strFobPoint = 'Origin'
		UNION ALL 
		SELECT	intFobPointId = 2
				,strFobPoint = 'Destination'
) AS FobPointTypes
	ON  FobPoint.intFobPointId = FobPointTypes.intFobPointId

-- When id is matched, make sure the strFobPoint name is intact. 
WHEN MATCHED THEN 
	UPDATE 
	SET 	strFobPoint = FobPointTypes.strFobPoint

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intFobPointId
		,strFobPoint
	)
	VALUES (
		FobPointTypes.intFobPointId
		,FobPointTypes.strFobPoint
	)
;
GO
print('/*******************  END Populate Fob Point Types *******************/')