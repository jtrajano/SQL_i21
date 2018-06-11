﻿CREATE PROCEDURE [dbo].[uspICUnpostFIFOOutFromStorage]
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
		,@LOTCOST AS INT = 4 	

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it to the @InventoryToReverse variable
INSERT INTO #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionStorageId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
)
SELECT	Changes.intInventoryTransactionStorageId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedTransactionId
		,Changes.strRelatedTransactionId
		,Changes.intTransactionTypeId
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
					ON ISNULL(inventory_transaction.ysnIsUnposted, 0) = 0					
					AND dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) IN (@AVERAGECOST, @FIFO) 
					AND inventory_transaction.intTransactionTypeId <> @AUTO_NEGATIVE
					AND 
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
							AND ISNULL(inventory_transaction.dblQty, 0) <> 0
						)
					)
				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT $action, Inserted.intInventoryTransactionStorageId, Inserted.intTransactionId, Inserted.strTransactionId, Inserted.intRelatedTransactionId, Inserted.strRelatedTransactionId, Inserted.intTransactionTypeId
		) AS Changes (Action, intInventoryTransactionStorageId, intTransactionId, strTransactionId, intRelatedTransactionId, strRelatedTransactionId, intTransactionTypeId)
WHERE	Changes.Action = 'UPDATE'
;

-- If fifoStorageBucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	fifoStorageBucket
SET		dblStockIn = dblStockOut
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryFIFOStorage fifoStorageBucket 
WHERE	EXISTS (
			SELECT	TOP 1 1 
			FROM	#tmpInventoryTransactionStockToReverse InventoryToReverse
			WHERE	InventoryToReverse.intTransactionId = fifoStorageBucket.intTransactionId
					AND InventoryToReverse.strTransactionId = fifoStorageBucket.strTransactionId
					AND InventoryToReverse.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
		)
;

-- If there are fifo out records, update the costing bucket. Return the out-qty back to the bucket where it came from. 
UPDATE	fifoStorageBucket
SET		fifoStorageBucket.dblStockOut = ISNULL(fifoStorageBucket.dblStockOut, 0) - FIFOOutGrouped.dblQty
FROM	dbo.tblICInventoryFIFOStorage fifoStorageBucket INNER JOIN (
			SELECT	FIFOOut.intInventoryFIFOStorageId
					,dblQty = SUM(FIFOOut.dblQty)
			FROM	dbo.tblICInventoryFIFOStorageOut FIFOOut INNER JOIN #tmpInventoryTransactionStockToReverse InventoryToReverse
						ON FIFOOut.intInventoryTransactionStorageId = InventoryToReverse.intInventoryTransactionStorageId	
			GROUP BY FIFOOut.intInventoryFIFOStorageId
		) AS FIFOOutGrouped
			ON FIFOOutGrouped.intInventoryFIFOStorageId = fifoStorageBucket.intInventoryFIFOStorageId
WHERE	ISNULL(fifoStorageBucket.ysnIsUnposted, 0) = 0
;
