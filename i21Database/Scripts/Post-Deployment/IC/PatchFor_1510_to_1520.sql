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


print('/*******************  BEGIN Fix the account description for tblGLDetail *******************/')
GO

-- Restore the description back to the GL account description. 
UPDATE	tblGLDetail 
SET		strDescription = tblGLAccount.strDescription
FROM	tblGLDetail INNER JOIN tblGLAccount
			ON tblGLDetail.intAccountId = tblGLAccount.intAccountId
WHERE	tblGLDetail.strModuleName = 'Inventory' 

-- Update the description of the gl entries with the adjustment description. 
UPDATE	tblGLDetail 
SET		strDescription = tblICInventoryAdjustment.strDescription
FROM	tblGLDetail INNER JOIN tblICInventoryAdjustment
			ON tblGLDetail.intTransactionId = tblICInventoryAdjustment.intInventoryAdjustmentId
			AND tblGLDetail.strTransactionId = tblICInventoryAdjustment.strAdjustmentNo

GO
print('/*******************  END Fix the account description for tblGLDetail *******************/')