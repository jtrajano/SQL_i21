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
DECLARE @WRITE_OFF_SOLD AS INT = -1;
DECLARE @REVALUE_SOLD AS INT = -2;
DECLARE @AUTO_NEGATIVE AS INT = -3;

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4 	

DECLARE @InventoryTransactionToReverse AS dbo.InventoryTranactionStockToReverse

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it to the @InventoryToReverse variable
INSERT INTO @InventoryTransactionToReverse (
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
					AND dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intLocationId) IN (@AVERAGECOST, @FIFO) 
				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1
							,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1

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
			FROM	dbo.tblICInventoryFIFOOut fifoOut INNER JOIN @InventoryTransactionToReverse Reversal
						ON fifoOut.intInventoryTransactionId = Reversal.intInventoryTransactionId
			WHERE	fifoOut.intRevalueFifoId IS NOT NULL 	
			GROUP BY fifoOut.intRevalueFifoId
		) AS fifoOutGrouped
			ON fifoOutGrouped.intRevalueFifoId = fifoBucket.intInventoryFIFOId
;
-- If there are out records, create a negative stock cost bucket 
INSERT INTO dbo.tblICInventoryFIFO (
		intItemId
		,intLocationId
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
		,intLocationId = OutTransactions.intLocationId
		,dtmDate = OutTransactions.dtmDate
		,dblStockIn = 0 
		,dblStockOut = ABS(OutTransactions.dblUnitQty)
		,dblCost = OutTransactions.dblCost
		,strTransactionId = OutTransactions.strTransactionId
		,intTransactionId = OutTransactions.intTransactionId
		,dtmCreated = GETDATE()
		,intCreatedUserId = OutTransactions.intCreatedUserId
		,intConcurrencyId = 1
FROM	dbo.tblICInventoryFIFO fifo INNER JOIN dbo.tblICInventoryFIFOOut fifoOut
			ON fifo.intInventoryFIFOId = fifoOut.intInventoryFIFOId
		INNER JOIN @InventoryTransactionToReverse Reversal
			ON Reversal.intTransactionId = fifo.intTransactionId
			AND Reversal.strTransactionId = fifo.strTransactionId
		INNER JOIN dbo.tblICInventoryTransaction OutTransactions
			ON OutTransactions.intInventoryTransactionId = fifoOut.intInventoryTransactionId
			AND OutTransactions.dblUnitQty < 0 
;
-- Plug the Out-qty so that it can't be used for future out-transactions. 
UPDATE	fifoBucket
SET		dblStockOut = dblStockIn
FROM	dbo.tblICInventoryFIFO fifoBucket INNER JOIN @InventoryTransactionToReverse Reversal
			ON fifoBucket.intTransactionId = Reversal.intTransactionId
			AND fifoBucket.strTransactionId = Reversal.strTransactionId
WHERE	Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
;
-- Return the transactions to reverse back to the calling code. 
SELECT * FROM @InventoryTransactionToReverse