-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert the name of the costing methods used in Inventory. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Costing Methods *******************/')
GO

SET IDENTITY_INSERT dbo.tblICCostingMethod ON;

-- Use UPSERT to populate the inventory transaction types
MERGE 
INTO	dbo.[tblICCostingMethod]
WITH	(HOLDLOCK) 
AS		CostingMethods
USING	(
		SELECT 
			[intCostingMethodId] = 1,
			[strCostingMethod] = 'AVERAGE COST'
		UNION ALL
		SELECT 
			[intCostingMethodId] = 2,
			[strCostingMethod] = 'FIFO'
		UNION ALL
		SELECT 
			[intCostingMethodId] = 3,
			[strCostingMethod] = 'LIFO'
		UNION ALL
		SELECT 
			[intCostingMethodId] = 4,
			[strCostingMethod] = 'LOT COST'
		UNION ALL
		SELECT 
			[intCostingMethodId] = 5,
			[strCostingMethod] = 'ACTUAL COST'

) AS HardCodedCostingMethods
	ON  CostingMethods.intCostingMethodId = HardCodedCostingMethods.intCostingMethodId

-- When id is matched, make sure the name and form are up-to-date.
WHEN MATCHED THEN 
	UPDATE 
	SET 	strCostingMethod = HardCodedCostingMethods.strCostingMethod

-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
	INSERT (
		intCostingMethodId
		,strCostingMethod
	)
	VALUES (
		HardCodedCostingMethods.intCostingMethodId
		,HardCodedCostingMethods.strCostingMethod
	)
;

SET IDENTITY_INSERT dbo.tblICCostingMethod OFF;

GO
print('/*******************  END Populate Costing Methods *******************/')