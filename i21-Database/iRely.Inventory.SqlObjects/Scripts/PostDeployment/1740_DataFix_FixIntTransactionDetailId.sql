
/*---------------------------------------------------------------------------------
Script for SQL Server 2005, 2008, and Azure
Purpose: 

There are existing cost buckets involved in the negative stock scenario that failed
to populate the intTransactionDetailId field. Right now, it has a NULL value. 

The script below will fix it. 
---------------------------------------------------------------------------------*/

--FIFO/AVG
UPDATE	cb
SET		cb.intTransactionDetailId = t.intTransactionDetailId
FROM	tblICInventoryFIFO cb LEFT JOIN tblICInventoryTransaction t
			ON cb.intTransactionId = t.intTransactionId
			AND cb.strTransactionId = t.strTransactionId
			AND cb.intItemId = t.intItemId
			AND cb.intItemLocationId = t.intItemLocationId
WHERE	cb.intTransactionDetailId IS NULL 
		AND t.intTransactionDetailId IS NOT NULL 
		AND t.ysnIsUnposted = 0 
		AND t.dblQty < 0 
		AND ABS(t.dblQty) = cb.dblStockOut

--LIFO 
UPDATE	cb
SET		cb.intTransactionDetailId = t.intTransactionDetailId
FROM	tblICInventoryLIFO cb LEFT JOIN tblICInventoryTransaction t
			ON cb.intTransactionId = t.intTransactionId
			AND cb.strTransactionId = t.strTransactionId
			AND cb.intItemId = t.intItemId
			AND cb.intItemLocationId = t.intItemLocationId
WHERE	cb.intTransactionDetailId IS NULL 
		AND t.intTransactionDetailId IS NOT NULL 
		AND t.ysnIsUnposted = 0 
		AND t.dblQty < 0 
		AND ABS(t.dblQty) = cb.dblStockOut

-- LOT 
UPDATE	cb
SET		cb.intTransactionDetailId = t.intTransactionDetailId
FROM	tblICInventoryLot cb LEFT JOIN tblICInventoryTransaction t
			ON cb.intTransactionId = t.intTransactionId
			AND cb.strTransactionId = t.strTransactionId
			AND cb.intItemId = t.intItemId
			AND cb.intItemLocationId = t.intItemLocationId
			AND cb.intLotId = t.intLotId
WHERE	cb.intTransactionDetailId IS NULL 
		AND t.intTransactionDetailId IS NOT NULL 
		AND t.ysnIsUnposted = 0 
		AND t.dblQty < 0 
		AND ABS(t.dblQty) = cb.dblStockOut

-- ACTUAL COST 
UPDATE	cb
SET		cb.intTransactionDetailId = t.intTransactionDetailId
FROM	tblICInventoryActualCost cb LEFT JOIN tblICInventoryTransaction t
			ON cb.intTransactionId = t.intTransactionId
			AND cb.strTransactionId = t.strTransactionId
			AND cb.intItemId = t.intItemId
			AND cb.intItemLocationId = t.intItemLocationId
WHERE	cb.intTransactionDetailId IS NULL 
		AND t.intTransactionDetailId IS NOT NULL 
		AND t.ysnIsUnposted = 0 
		AND t.dblQty < 0 
		AND ABS(t.dblQty) = cb.dblStockOut
