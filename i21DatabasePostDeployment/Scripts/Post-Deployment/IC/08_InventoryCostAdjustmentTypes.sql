-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory Cost Adjustment Types. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Inventory Cost Adjustment Types *******************/')
GO
-- Use UPSERT to populate the inventory Cost Adjustment Types
MERGE 
INTO	dbo.tblICInventoryCostAdjustmentType
WITH	(HOLDLOCK) 
AS		InventoryCostAdjustmentTypes
USING	(
		SELECT	id = 1
				,name = 'Original Cost'
		UNION ALL 
		SELECT	id = 2
				,name = 'New Cost'
		UNION ALL 
		SELECT	id = 3
				,name = 'Adjust Stock Value'

) AS InventoryCostAdjustmentTypeHardValues
	ON  InventoryCostAdjustmentTypes.intInventoryCostAdjustmentTypeId = InventoryCostAdjustmentTypeHardValues.id

-- When id is matched, make sure the name and form are up-to-date.
WHEN MATCHED THEN 
	UPDATE 
	SET 	strName = InventoryCostAdjustmentTypeHardValues.name

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intInventoryCostAdjustmentTypeId
		,strName
	)
	VALUES (
		InventoryCostAdjustmentTypeHardValues.id
		,InventoryCostAdjustmentTypeHardValues.name
	)
;
GO
print('/*******************  END Populate Inventory Cost Adjustment Types *******************/')