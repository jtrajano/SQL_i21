-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory Cost Adjustment Types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Adjust Inventory Terms *******************/')
GO
SET IDENTITY_INSERT dbo.tblICAdjustInventoryTerms ON;

-- Use UPSERT to populate the inventory Cost Adjustment Types
MERGE 
INTO	dbo.tblICAdjustInventoryTerms
WITH	(HOLDLOCK) 
AS		AdjustInventoryTerms
USING	(
		SELECT	id = 1
				,strTerms = 'Origin'
		UNION ALL 
		SELECT	id = 2
				,strTerms = 'Destination'

) AS ValuesForAdjustInventoryTerms
	ON  AdjustInventoryTerms.intAdjustInventoryTermsId = ValuesForAdjustInventoryTerms.id

-- When id is matched, make sure the name and form are up-to-date.
WHEN MATCHED THEN 
	UPDATE 
	SET 	strTerms = ValuesForAdjustInventoryTerms.strTerms

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intAdjustInventoryTermsId
		,strTerms
	)
	VALUES (
		ValuesForAdjustInventoryTerms.id
		,ValuesForAdjustInventoryTerms.strTerms
	)
;

SET IDENTITY_INSERT dbo.tblICAdjustInventoryTerms OFF;

GO
print('/*******************  END Populate Adjust Inventory Terms *******************/')