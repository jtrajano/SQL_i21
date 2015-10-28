﻿CREATE PROCEDURE [dbo].[uspICUnpostLotIn]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
BEGIN 
	CREATE TABLE #tmpInventoryTransactionStockToReverse (
		intInventoryTransactionId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intRelatedTransactionId INT NULL 
		,intTransactionTypeId INT NOT NULL 
	)
END 

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
DECLARE @WRITE_OFF_SOLD AS INT = 2
DECLARE @REVALUE_SOLD AS INT = 3

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it into the #tmpInventoryTransactionStockToReverse temp table
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
					AND dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) IN (@LOTCOST)
					AND inventory_transaction.intTransactionTypeId <> @AUTO_NEGATIVE
					AND 
					(
						-- Link to the main transaction
						(	
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
							AND ISNULL(inventory_transaction.dblQty, 0) > 0 -- Reverse Qty that is positive. 
						)
						-- Link to revalue and write-off sold 
						OR (
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
							AND inventory_transaction.intTransactionTypeId IN (@REVALUE_SOLD, @WRITE_OFF_SOLD)
						)
					)

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
UPDATE	LotBucket
SET		LotBucket.dblStockIn = ISNULL(LotBucket.dblStockIn, 0) - LotOutGrouped.dblQty
FROM	dbo.tblICInventoryLot LotBucket INNER JOIN (
			SELECT	LotOut.intRevalueLotId
					, dblQty = SUM(LotOut.dblQty)
			FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON LotOut.intInventoryTransactionId = Reversal.intInventoryTransactionId
			WHERE	LotOut.intRevalueLotId IS NOT NULL 	
			GROUP BY LotOut.intRevalueLotId
		) AS LotOutGrouped
			ON LotOutGrouped.intRevalueLotId = LotBucket.intInventoryLotId
;

-- If there are out records, create a negative stock cost bucket 
INSERT INTO dbo.tblICInventoryLot (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,intLotId
		,intSubLocationId
		,intStorageLocationId
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
		,intLotId = OutTransactions.intLotId
		,intSubLocationId = OutTransactions.intSubLocationId
		,intStorageLocationId = OutTransactions.intStorageLocationId
		,dblStockIn = 0 
		,dblStockOut = ABS(ISNULL(OutTransactions.dblQty, 0))
		,dblCost = OutTransactions.dblCost
		,strTransactionId = OutTransactions.strTransactionId
		,intTransactionId = OutTransactions.intTransactionId
		,dtmCreated = GETDATE()
		,intCreatedUserId = OutTransactions.intCreatedUserId
		,intConcurrencyId = 1
FROM	dbo.tblICInventoryLot Lot INNER JOIN dbo.tblICInventoryLotOut LotOut
			ON Lot.intInventoryLotId = LotOut.intInventoryLotId
		INNER JOIN dbo.tblICInventoryTransaction OutTransactions
			ON OutTransactions.intInventoryTransactionId = LotOut.intInventoryTransactionId
			AND ISNULL(OutTransactions.dblQty, 0) < 0 
WHERE	ISNULL(OutTransactions.ysnIsUnposted, 0) = 0
		AND Lot.intTransactionId = @intTransactionId
		AND Lot.strTransactionId = @strTransactionId
;

-- Plug the Out-qty so that it can't be used for future out-transactions. 
-- Mark the record as unposted too. 
UPDATE	LotBucket
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLot LotBucket INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LotBucket.intTransactionId = Reversal.intTransactionId
			AND LotBucket.strTransactionId = Reversal.strTransactionId
WHERE	Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
;
