------------------------------------------------------------------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1610
-- Purpose: To populate the intTransactionDetailId on Cost Buckets. 
------------------------------------------------------------------------------------------------------------------
print('/*******************  BEGIN Populate the Transaction Detail Id on Cost Buckets *******************/')
GO

UPDATE FIFO
SET		FIFO.intTransactionDetailId = InvTrans.intTransactionDetailId
FROM	dbo.tblICInventoryTransaction InvTrans inner join dbo.tblICInventoryFIFO FIFO
			ON InvTrans.intTransactionId = FIFO.intTransactionId
			AND InvTrans.strTransactionId = FIFO.strTransactionId
			AND InvTrans.intItemUOMId = FIFO.intItemUOMId
			AND InvTrans.intItemLocationId = FIFO.intItemLocationId
			AND InvTrans.dblQty = FIFO.dblStockIn	
WHERE	FIFO.intTransactionDetailId IS NULL 
		AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
		AND InvTrans.intTransactionDetailId IS NOT NULL 
		AND InvTrans.intTransactionTypeId IN (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Inventory Receipt')

UPDATE	LIFO
SET		LIFO.intTransactionDetailId = InvTrans.intTransactionDetailId
FROM	dbo.tblICInventoryTransaction InvTrans inner join dbo.tblICInventoryLIFO LIFO
			ON InvTrans.intTransactionId = LIFO.intTransactionId
			AND InvTrans.strTransactionId = LIFO.strTransactionId
			AND InvTrans.intItemUOMId = LIFO.intItemUOMId
			AND InvTrans.intItemLocationId = LIFO.intItemLocationId
			AND InvTrans.dblQty = LIFO.dblStockIn	
WHERE	LIFO.intTransactionDetailId IS NULL 
		AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
		AND InvTrans.intTransactionDetailId IS NOT NULL 
		AND InvTrans.intTransactionTypeId IN (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Inventory Receipt')

UPDATE	ActualCost
SET		ActualCost.intTransactionDetailId = InvTrans.intTransactionDetailId
FROM	dbo.tblICInventoryTransaction InvTrans inner join dbo.tblICInventoryActualCost ActualCost
			ON InvTrans.intTransactionId = ActualCost.intTransactionId
			AND InvTrans.strTransactionId = ActualCost.strTransactionId
			AND InvTrans.intItemUOMId = ActualCost.intItemUOMId
			AND InvTrans.intItemLocationId = ActualCost.intItemLocationId
			AND InvTrans.dblQty = ActualCost.dblStockIn	
WHERE	ActualCost.intTransactionDetailId IS NULL 
		AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
		AND InvTrans.intTransactionDetailId IS NOT NULL 
		AND InvTrans.intTransactionTypeId IN (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Inventory Receipt')

UPDATE	Lot
SET		Lot.intTransactionDetailId = InvTrans.intTransactionDetailId
FROM	dbo.tblICInventoryTransaction InvTrans inner join dbo.tblICInventoryLot Lot
			ON InvTrans.intTransactionId = Lot.intTransactionId
			AND InvTrans.strTransactionId = Lot.strTransactionId
			AND InvTrans.intItemUOMId = Lot.intItemUOMId
			AND InvTrans.intItemLocationId = Lot.intItemLocationId
			AND InvTrans.dblQty = Lot.dblStockIn	
WHERE	Lot.intTransactionDetailId IS NULL 
		AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0
		AND InvTrans.intTransactionDetailId IS NOT NULL 
		AND InvTrans.intTransactionTypeId IN (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Inventory Receipt')

GO
print('/*******************  END Populate the Transaction Detail Id on Cost Buckets  *******************/')

