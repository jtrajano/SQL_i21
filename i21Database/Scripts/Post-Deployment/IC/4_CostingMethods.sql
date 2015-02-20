-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert the name of the costing methods used in Inventory. 
-- --------------------------------------------------

print('/*******************  BEGIN Populate Costing Methods *******************/')
GO

SET IDENTITY_INSERT dbo.tblICCostingMethod ON;

INSERT INTO dbo.[tblICCostingMethod] (
	[intCostingMethodId],
	[strCostingMethod]
)
SELECT 
	[intCostingMethodId] = 1,
	[strCostingMethod] = 'AVERAGE COST'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICCostingMethod] WHERE [intCostingMethodId] = 1)
UNION ALL
SELECT 
	[intCostingMethodId] = 2,
	[strCostingMethod] = 'FIFO'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICCostingMethod] WHERE [intCostingMethodId] = 2)
UNION ALL
SELECT 
	[intCostingMethodId] = 3,
	[strCostingMethod] = 'LIFO'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICCostingMethod] WHERE [intCostingMethodId] = 3)
UNION ALL
SELECT 
	[intCostingMethodId] = 4,
	[strCostingMethod] = 'STANDARD COST'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICCostingMethod] WHERE [intCostingMethodId] = 4)
UNION ALL
SELECT 
	[intCostingMethodId] = 5,
	[strCostingMethod] = 'LOT COST'
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblICCostingMethod] WHERE [intCostingMethodId] = 5)

SET IDENTITY_INSERT dbo.tblICCostingMethod OFF;

GO
print('/*******************  END Populate Costing Methods *******************/')