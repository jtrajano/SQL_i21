﻿CREATE PROCEDURE [dbo].[uspICUnpostActualCostOut]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@ysnRecap AS BIT 
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

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it to the @InventoryToReverse variable
INSERT INTO #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
	,dblQty 
)
SELECT	Changes.intInventoryTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedTransactionId
		,Changes.strRelatedTransactionId
		,Changes.intTransactionTypeId
		,Changes.dblQty 
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
					ON  
					(
						-- Link to the main transaction
						(	
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
							AND ISNULL(inventory_transaction.dblQty, 0) < 0 -- Reverse Qty that is negative. 
						)
						-- Link to the related transactions 
						OR (
							inventory_transaction.strRelatedTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intRelatedTransactionId = Source_Query.intTransactionId
						)
					)
					AND ISNULL(inventory_transaction.ysnIsUnposted, 0) = 0
					AND inventory_transaction.intTransactionTypeId <> @AUTO_NEGATIVE
					
				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1, dtmDateModified = GETUTCDATE()

				OUTPUT 
					$action
					, inserted.intInventoryTransactionId
					, inserted.intTransactionId
					, inserted.strTransactionId
					, inserted.intRelatedTransactionId
					, inserted.strRelatedTransactionId
					, inserted.intTransactionTypeId
					, inserted.dblQty 
		) AS Changes (
			action
			, intInventoryTransactionId
			, intTransactionId
			, strTransactionId
			, intRelatedTransactionId
			, strRelatedTransactionId
			, intTransactionTypeId
			, dblQty 
		)
WHERE	Changes.action = 'UPDATE'
;

-- If ActualCostBucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	ActualCostBucket
SET		dblStockIn = ActualCostBucket.dblStockOut
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryActualCost ActualCostBucket INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON Reversal.intTransactionId = ActualCostBucket.intTransactionId
			AND Reversal.strTransactionId = ActualCostBucket.strTransactionId
			AND Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE)
			AND ISNULL(Reversal.dblQty, 0) <> 0 
		INNER JOIN dbo.tblICInventoryTransaction OutTransactions
			ON OutTransactions.intInventoryTransactionId = Reversal.intInventoryTransactionId
			AND ISNULL(OutTransactions.dblQty, 0) < 0 		
;

-- If there are ActualCost out records, update the costing bucket. Return the out-qty back to the bucket where it came from. 
UPDATE	ActualCostBucket
SET		ActualCostBucket.dblStockOut = ISNULL(ActualCostBucket.dblStockOut, 0) - ActualCostOutGrouped.dblQty
FROM	dbo.tblICInventoryActualCost ActualCostBucket INNER JOIN (
			SELECT	ActualCostOut.intInventoryActualCostId
					,dblQty = SUM(ActualCostOut.dblQty)
			FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON ActualCostOut.intInventoryTransactionId = Reversal.intInventoryTransactionId	
			GROUP BY ActualCostOut.intInventoryActualCostId
		) AS ActualCostOutGrouped
			ON ActualCostOutGrouped.intInventoryActualCostId = ActualCostBucket.intInventoryActualCostId
WHERE	ISNULL(ActualCostBucket.ysnIsUnposted, 0) = 0
;

-- Update actual cost out. Update dblQtyReturned. 
UPDATE	cbOut
SET		cbOut.dblQtyReturned = cbOut.dblQtyReturned - rtn.dblQtyReturned
FROM	tblICInventoryActualCostOut cbOut CROSS APPLY (
			SELECT	rtn.intInventoryActualCostId
					,rtn.intOutId
					,dblQtyReturned = SUM(rtn.dblQtyReturned) 
			FROM	tblICInventoryReturned rtn 
			WHERE	rtn.intTransactionId = @intTransactionId
					AND rtn.strTransactionId = @strTransactionId
			GROUP BY rtn.intInventoryActualCostId, rtn.intOutId
		) rtn
;