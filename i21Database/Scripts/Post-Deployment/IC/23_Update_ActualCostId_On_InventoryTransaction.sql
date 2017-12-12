
/****************************************************************************************************************
	Remove this after 18.1. 
	The strActualCostId is new in 17.3 (Blocker Release) and in 18.1. 
	This script will populate all inventory transactions with the missing actual cost id. 
	The Actual Cost Id is needed when rebuilding stocks. 
****************************************************************************************************************/

UPDATE	t
SET		t.strActualCostId = cb.strActualCostId
FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryActualCostOut cbOut
			ON t.intInventoryTransactionId = cbOut.intInventoryTransactionId
		INNER JOIN tblICInventoryActualCost cb
			ON cb.intInventoryActualCostId = cbOut.intInventoryActualCostId
WHERE	t.strActualCostId IS NULL 

UPDATE	t
SET		t.strActualCostId = cb.strActualCostId
FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryActualCost cb
			ON t.intTransactionId = cb.intTransactionId
			AND t.strTransactionId = cb.strTransactionId
			AND t.intTransactionDetailId = cb.intTransactionDetailId
			AND t.intItemId = cb.intItemId
			AND t.intItemLocationId = cb.intItemLocationId
WHERE	t.strActualCostId IS NULL 