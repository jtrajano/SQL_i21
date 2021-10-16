﻿CREATE PROCEDURE [dbo].[uspICUnpostFIFOInFromStorage]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
BEGIN 
	CREATE TABLE #tmpInventoryTransactionStockToReverse (
		intInventoryTransactionStorageId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intRelatedTransactionId INT NULL 
		,intTransactionTypeId INT NOT NULL 
		,dblQty NUMERIC(38,20) 
	)
END

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
--DECLARE @strItemNo AS NVARCHAR(50)
--		,@strRelatedTransactionId AS NVARCHAR(50)

--SELECT TOP 1 
--		@strItemNo = Item.strItemNo
--		,@strRelatedTransactionId = InvTrans.strTransactionId
--FROM	dbo.tblICInventoryTransactionStorage InvTrans INNER JOIN dbo.tblICItem Item
--			ON InvTrans.intItemId = Item.intItemId
--WHERE	InvTrans.intRelatedTransactionId = @intTransactionId
--		AND InvTrans.strRelatedTransactionId = @strTransactionId
--		AND InvTrans.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
--		AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0 

--IF @strRelatedTransactionId IS NOT NULL 
--BEGIN 
--	-- 'Unable to unpost because {Item} has a cost adjustment from {Transaction Id}.'
--	EXEC uspICRaiseError 80063, @strItemNo, @strRelatedTransactionId;  
--	RETURN -1
--END 

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it into the @InventoryToReverse variable
INSERT INTO #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionStorageId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
	,dblQty 
)
SELECT	Changes.intInventoryTransactionStorageId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedTransactionId
		,Changes.strRelatedTransactionId
		,Changes.intTransactionTypeId
		,Changes.dblQty 
FROM	(
			-- Merge will help us get the records we need to unpost and update it at the same time. 
			MERGE	
				INTO	dbo.tblICInventoryTransactionStorage 
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
					AND dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) IN (@AVERAGECOST, @FIFO)
					AND inventory_transaction.intTransactionTypeId <> @AUTO_NEGATIVE
					
				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT 
					$action
					, inserted.intInventoryTransactionStorageId
					, inserted.intTransactionId
					, inserted.strTransactionId
					, inserted.intRelatedTransactionId
					, inserted.strRelatedTransactionId
					, inserted.intTransactionTypeId
					, inserted.dblQty 
		) AS Changes (
			action
			, intInventoryTransactionStorageId
			, intTransactionId, strTransactionId
			, intRelatedTransactionId
			, strRelatedTransactionId
			, intTransactionTypeId
			, dblQty 
		)
WHERE	Changes.action = 'UPDATE'
;

-- If there are revalue records, reduce the In-qty of the negative stock buckets
-- Since the In-qty is unposted, it must bring back these buckets back to negative qty. 
UPDATE	fifoStorageBucket
SET		fifoStorageBucket.dblStockIn = ISNULL(fifoStorageBucket.dblStockIn, 0) - fifoOutGrouped.dblQty
FROM	dbo.tblICInventoryFIFOStorage fifoStorageBucket INNER JOIN (
			SELECT	fifoOut.intRevalueFifoId, dblQty = SUM(fifoOut.dblQty)
			FROM	dbo.tblICInventoryFIFOStorageOut fifoOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON fifoOut.intInventoryTransactionStorageId = Reversal.intInventoryTransactionStorageId
					INNER JOIN dbo.tblICInventoryTransactionStorage OutTransactions
						ON OutTransactions.intInventoryTransactionStorageId = fifoOut.intInventoryTransactionStorageId
			WHERE	fifoOut.intRevalueFifoId IS NOT NULL 
					AND ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
			GROUP BY fifoOut.intRevalueFifoId
		) AS fifoOutGrouped
			ON fifoOutGrouped.intRevalueFifoId = fifoStorageBucket.intInventoryFIFOStorageId
;

-- If there are out records, create a negative stock cost bucket 
INSERT INTO dbo.tblICInventoryFIFOStorage (
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
FROM	dbo.tblICInventoryFIFOStorage fifo INNER JOIN dbo.tblICInventoryFIFOStorageOut fifoOut
			ON fifo.intInventoryFIFOStorageId = fifoOut.intInventoryFIFOStorageId
		INNER JOIN dbo.tblICInventoryTransactionStorage OutTransactions
			ON OutTransactions.intInventoryTransactionStorageId = fifoOut.intInventoryTransactionStorageId
			AND ISNULL(OutTransactions.dblQty, 0) < 0 
WHERE	fifo.intTransactionId IN (SELECT intTransactionId FROM #tmpInventoryTransactionStockToReverse)
		AND fifo.strTransactionId IN (SELECT strTransactionId FROM #tmpInventoryTransactionStockToReverse)
		AND ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
;
-- Plug the Out-qty so that it can't be used for future out-transactions. 
-- Mark the record as unposted too. 
UPDATE	fifoStorageBucket
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryFIFOStorage fifoStorageBucket INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON fifoStorageBucket.intTransactionId = Reversal.intTransactionId
			AND fifoStorageBucket.strTransactionId = Reversal.strTransactionId
WHERE	Reversal.intTransactionTypeId NOT IN (
			@WRITE_OFF_SOLD
			, @REVALUE_SOLD
			, @AUTO_NEGATIVE
			, @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK
		) 
		AND ISNULL(Reversal.dblQty, 0) <> 0 
;
