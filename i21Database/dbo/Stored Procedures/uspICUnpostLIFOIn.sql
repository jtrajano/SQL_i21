CREATE PROCEDURE [dbo].[uspICUnpostLIFOIn]
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
					AND dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) IN (@LIFO) 
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
UPDATE	LIFOBucket
SET		LIFOBucket.dblStockIn = ISNULL(LIFOBucket.dblStockIn, 0) - LIFOOutGrouped.dblQty
FROM	dbo.tblICInventoryLIFO LIFOBucket INNER JOIN (
			SELECT	LIFOOut.intRevalueLifoId, dblQty = SUM(LIFOOut.dblQty)
			FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON LIFOOut.intInventoryTransactionId = Reversal.intInventoryTransactionId
			WHERE	LIFOOut.intRevalueLifoId IS NOT NULL 	
			GROUP BY LIFOOut.intRevalueLifoId
		) AS LIFOOutGrouped
			ON LIFOOutGrouped.intRevalueLifoId = LIFOBucket.intInventoryLIFOId
;

-- If there are out records, create a negative stock cost bucket 
INSERT INTO dbo.tblICInventoryLIFO (
		intItemId
		,intItemLocationId
		,dtmDate
		,dblStockIn
		,dblStockOut
		,dblCost
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
		,dblStockOut = ABS(OutTransactions.dblUnitQty)
		,dblCost = OutTransactions.dblCost
		,strTransactionId = OutTransactions.strTransactionId
		,intTransactionId = OutTransactions.intTransactionId
		,dtmCreated = GETDATE()
		,intCreatedUserId = OutTransactions.intCreatedUserId
		,intConcurrencyId = 1
FROM	dbo.tblICInventoryLIFO LIFO INNER JOIN dbo.tblICInventoryLIFOOut LIFOOut
			ON LIFO.intInventoryLIFOId = LIFOOut.intInventoryLIFOId
		INNER JOIN dbo.tblICInventoryTransaction OutTransactions
			ON OutTransactions.intInventoryTransactionId = LIFOOut.intInventoryTransactionId
			AND OutTransactions.dblUnitQty < 0 
WHERE	LIFO.intTransactionId IN (SELECT intTransactionId FROM #tmpInventoryTransactionStockToReverse)
		AND LIFO.strTransactionId IN (SELECT strTransactionId FROM #tmpInventoryTransactionStockToReverse)
		AND ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
;
-- Plug the Out-qty so that it can't be used for future out-transactions. 
-- Mark the record as unposted too. 
UPDATE	LIFOBucket
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLIFO LIFOBucket INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LIFOBucket.intTransactionId = Reversal.intTransactionId
			AND LIFOBucket.strTransactionId = Reversal.strTransactionId
WHERE	Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
;
