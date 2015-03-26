---------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1520 OR LATER
-- Purpose: Fix data discrepancies between GL and IC
---------------------------------------------------------
print('/*******************  BEGIN Fix GL decimal values discrepancy between GL and Inventory Transaction *******************/')
GO

-- Correct the debit
UPDATE	GLDetail
SET		GLDetail.dblDebit = ABS(ISNULL(InventoryTransaction.dblQty, 0) * ISNULL(InventoryTransaction.dblCost, 0) + ISNULL(InventoryTransaction.dblValue, 0))
FROM	tblGLDetail GLDetail INNER JOIN tblICInventoryTransaction InventoryTransaction
			ON GLDetail.intJournalLineNo = InventoryTransaction.intInventoryTransactionId
WHERE	1 = CASE	WHEN GLDetail.dblDebit <> 0 THEN 
						CASE WHEN ABS(GLDetail.dblDebit) = ABS(ISNULL(InventoryTransaction.dblQty, 0) * ISNULL(InventoryTransaction.dblCost, 0) + ISNULL(InventoryTransaction.dblValue, 0)) THEN 0 ELSE 1 END 
					ELSE 0
			END 
		AND GLDetail.strCode = 'IC'

-- Correct the credit
UPDATE	GLDetail
SET		GLDetail.dblCredit = ABS(ISNULL(InventoryTransaction.dblQty, 0) * ISNULL(InventoryTransaction.dblCost, 0) + ISNULL(InventoryTransaction.dblValue, 0))
FROM	tblGLDetail GLDetail INNER JOIN tblICInventoryTransaction InventoryTransaction
			ON GLDetail.intJournalLineNo = InventoryTransaction.intInventoryTransactionId
WHERE	1 = CASE	WHEN GLDetail.dblCredit <> 0 THEN 
						CASE WHEN ABS(GLDetail.dblCredit) = ABS(ISNULL(InventoryTransaction.dblQty, 0) * ISNULL(InventoryTransaction.dblCost, 0) + ISNULL(InventoryTransaction.dblValue, 0) ) THEN 0 ELSE 1 END 
					ELSE 0
			END 
		AND GLDetail.strCode = 'IC'

GO
print('/*******************  END Fix GL decimal values discrepancy between GL and Inventory Transaction *******************/')