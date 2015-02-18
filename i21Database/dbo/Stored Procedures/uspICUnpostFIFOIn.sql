CREATE PROCEDURE [dbo].[uspICUnpostFIFOIn]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
DECLARE @WRITE_OFF_SOLD AS INT = 2
DECLARE @REVALUE_SOLD AS INT = 3

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4 	

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it into the @InventoryToReverse variable
INSERT INTO #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
)
SELECT	Changes.intInventoryTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedTransactionId
		,Changes.strRelatedTransactionId
		,Changes.intTransactionTypeId
FROM	(
			-- Merge will help us get the records we need to unpost and update it at the same time. 
			MERGE	
				INTO	dbo.tblICInventoryTransaction 
				WITH	(HOLDLOCK) 
				AS		inventory_transaction	
				USING (
					SELECT	strTransactionId = @strTransactionId
							,intTransactionId = @intTransactionId
				) AS Source_Query  
					ON ISNULL(inventory_transaction.ysnIsUnposted, 0) = 0
					AND inventory_transaction.strTransactionId = Source_Query.strTransactionId
					AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
					AND dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) IN (@AVERAGECOST, @FIFO) 
					AND inventory_transaction.intTransactionTypeId <> @AUTO_NEGATIVE

				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT $action, Inserted.intInventoryTransactionId, Inserted.intTransactionId, Inserted.strTransactionId, Inserted.intRelatedTransactionId, Inserted.strRelatedTransactionId, Inserted.intTransactionTypeId
		) AS Changes (Action, intInventoryTransactionId, intTransactionId, strTransactionId, intRelatedTransactionId, strRelatedTransactionId, intTransactionTypeId)
WHERE	Changes.Action = 'UPDATE'
;

-- If there are revalue records, reduce the In-qty of the negative stock buckets
-- Since the In-qty is unposted, it must bring back these buckets back to negative qty. 
UPDATE	fifoBucket
SET		fifoBucket.dblStockIn = ISNULL(fifoBucket.dblStockIn, 0) - fifoOutGrouped.dblQty
FROM	dbo.tblICInventoryFIFO fifoBucket INNER JOIN (
			SELECT	fifoOut.intRevalueFifoId, dblQty = SUM(fifoOut.dblQty)
			FROM	dbo.tblICInventoryFIFOOut fifoOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON fifoOut.intInventoryTransactionId = Reversal.intInventoryTransactionId
			WHERE	fifoOut.intRevalueFifoId IS NOT NULL 	
			GROUP BY fifoOut.intRevalueFifoId
		) AS fifoOutGrouped
			ON fifoOutGrouped.intRevalueFifoId = fifoBucket.intInventoryFIFOId
;

-- If there are out records, create a negative stock cost bucket 
INSERT INTO dbo.tblICInventoryFIFO (
		intItemId
		,intItemLocationId
		,dtmDate
		,dblStockIn
		,dblStockOut
		,dblCost
		,intItemUOMId
		,strTransactionId
		,intTransactionId
		,dtmCreated
		,intCreatedUserId
		,intConcurrencyId
)
SELECT	intItemId = OutTransactions.intItemId
		,intItemLocationId = OutTransactions.intItemLocationId
		,dtmDate = OutTransactions.dtmDate
		,dblStockIn = 0 
		,dblStockOut = ABS(ISNULL(OutTransactions.dblQty, 0) * ISNULL(OutTransactions.dblUOMQty, 1))
		,dblCost = OutTransactions.dblCost
		,intItemUOMId = OutTransactions.intItemUOMId
		,strTransactionId = OutTransactions.strTransactionId
		,intTransactionId = OutTransactions.intTransactionId
		,dtmCreated = GETDATE()
		,intCreatedUserId = OutTransactions.intCreatedUserId
		,intConcurrencyId = 1
FROM	dbo.tblICInventoryFIFO fifo INNER JOIN dbo.tblICInventoryFIFOOut fifoOut
			ON fifo.intInventoryFIFOId = fifoOut.intInventoryFIFOId
		INNER JOIN dbo.tblICInventoryTransaction OutTransactions
			ON OutTransactions.intInventoryTransactionId = fifoOut.intInventoryTransactionId
			AND ISNULL(OutTransactions.dblQty, 0) * ISNULL(OutTransactions.dblUOMQty, 1) < 0 
WHERE	fifo.intTransactionId IN (SELECT intTransactionId FROM #tmpInventoryTransactionStockToReverse)
		AND fifo.strTransactionId IN (SELECT strTransactionId FROM #tmpInventoryTransactionStockToReverse)
		AND ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
;
-- Plug the Out-qty so that it can't be used for future out-transactions. 
-- Mark the record as unposted too. 
UPDATE	fifoBucket
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryFIFO fifoBucket INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON fifoBucket.intTransactionId = Reversal.intTransactionId
			AND fifoBucket.strTransactionId = Reversal.strTransactionId
WHERE	Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
;
