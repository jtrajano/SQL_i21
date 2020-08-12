CREATE PROCEDURE [dbo].[uspICUnpostLIFOIn]
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
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3
		,@AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	

---- Validate the unpost of the stock in. Do not allow unpost if it has cost adjustments. 
--IF @ysnRecap = 0 
--BEGIN 
--	DECLARE @strItemNo AS NVARCHAR(50)
--			,@strRelatedTransactionId AS NVARCHAR(50)

--	SELECT TOP 1 
--			@strItemNo = Item.strItemNo
--			,@strRelatedTransactionId = InvTrans.strTransactionId
--	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICItem Item
--				ON InvTrans.intItemId = Item.intItemId
--	WHERE	InvTrans.intRelatedTransactionId = @intTransactionId
--			AND InvTrans.strRelatedTransactionId = @strTransactionId
--			AND InvTrans.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
--			AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0 

--	IF @strRelatedTransactionId IS NOT NULL 
--	BEGIN 
--		-- 'Unable to unpost because {Item} has a cost adjustment from {Transaction Id}.'
--		EXEC uspICRaiseError 80063, @strItemNo, @strRelatedTransactionId;  
--		RETURN -1;
--	END 
--END 

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
							AND ISNULL(inventory_transaction.dblQty, 0) > 0 -- Reverse Qty that is positive. 
						)
						-- Link to revalue, write-off sold, auto variance on sold or used stock. 
						OR (
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
							AND inventory_transaction.intTransactionTypeId IN (@REVALUE_SOLD, @WRITE_OFF_SOLD, @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK)
						)
					)
					AND ISNULL(inventory_transaction.ysnIsUnposted, 0) = 0					
					AND dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) IN (@LIFO) 				
					AND inventory_transaction.intTransactionTypeId <> @AUTO_NEGATIVE

				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

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

-- If there are revalue records, reduce the In-qty of the negative stock buckets
-- Since the In-qty is unposted, it must bring back these buckets back to negative qty. 
UPDATE	LIFOBucket
SET		LIFOBucket.dblStockIn = ISNULL(LIFOBucket.dblStockIn, 0) - LIFOOutGrouped.dblQty
FROM	dbo.tblICInventoryLIFO LIFOBucket INNER JOIN (
			SELECT	LIFOOut.intRevalueLifoId, dblQty = SUM(LIFOOut.dblQty)
			FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON LIFOOut.intInventoryTransactionId = Reversal.intInventoryTransactionId
					INNER JOIN dbo.tblICInventoryTransaction OutTransactions
						ON OutTransactions.intInventoryTransactionId = LIFOOut.intInventoryTransactionId
			WHERE	LIFOOut.intRevalueLifoId IS NOT NULL 	
					AND ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
			GROUP BY LIFOOut.intRevalueLifoId
		) AS LIFOOutGrouped
			ON LIFOOutGrouped.intRevalueLifoId = LIFOBucket.intInventoryLIFOId
;

-- If there are out records, create a negative stock cost bucket 
INSERT INTO dbo.tblICInventoryLIFO (
		intItemId
		,intItemLocationId
		,intItemUOMId
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
		,intItemUOMId = OutTransactions.intItemUOMId
		,dtmDate = OutTransactions.dtmDate
		,dblStockIn = 0 
		,dblStockOut = ABS(ISNULL(OutTransactions.dblQty, 0))
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
			AND ISNULL(OutTransactions.dblQty, 0) < 0 
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
WHERE	Reversal.intTransactionTypeId NOT IN (
			@WRITE_OFF_SOLD
			, @REVALUE_SOLD
			, @AUTO_NEGATIVE
			, @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK
		) 
		AND ISNULL(Reversal.dblQty, 0) <> 0 
;	
