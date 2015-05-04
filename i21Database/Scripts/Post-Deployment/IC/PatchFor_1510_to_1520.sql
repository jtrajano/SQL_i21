---------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1530
-- Purpose: To populate data on only added fields. 
---------------------------------------------------------
print('/*******************  BEGIN Calculate Adjust By Quantity in Inventory Adjustment *******************/')
GO

UPDATE	dbo.tblICInventoryAdjustmentDetail
SET		dblAdjustByQuantity = dblNewQuantity - dblQuantity
WHERE	dblNewQuantity IS NOT NULL 
		AND dblAdjustByQuantity IS NULL 

GO
print('/*******************  END Calculate Adjust By Quantity in Inventory Adjustment  *******************/')