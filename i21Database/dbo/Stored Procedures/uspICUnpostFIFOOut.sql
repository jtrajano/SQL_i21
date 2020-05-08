﻿CREATE PROCEDURE [dbo].[uspICUnpostFIFOOut]
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

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	

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
					AND inventory_transaction.intCostingMethod IN (@AVERAGECOST, @FIFO)  --dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) IN (@AVERAGECOST, @FIFO) 
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

-- If fifoBucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	fifoBucket
SET		dblStockIn = dblStockOut
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryFIFO fifoBucket 
WHERE	EXISTS (
			SELECT	TOP 1 1 
			FROM	#tmpInventoryTransactionStockToReverse InventoryToReverse
			WHERE	InventoryToReverse.intTransactionId = fifoBucket.intTransactionId
					AND InventoryToReverse.strTransactionId = fifoBucket.strTransactionId
					AND InventoryToReverse.intTransactionTypeId NOT IN (
						@WRITE_OFF_SOLD
						, @REVALUE_SOLD
						, @AUTO_NEGATIVE
					) 
					AND ISNULL(InventoryToReverse.dblQty, 0) <> 0 
		)
;

-- If there are fifo out records, update the costing bucket. Return the out-qty back to the bucket where it came from. 
UPDATE	fifoBucket
SET		fifoBucket.dblStockOut = ISNULL(fifoBucket.dblStockOut, 0) - FIFOOutGrouped.dblQty
FROM	dbo.tblICInventoryFIFO fifoBucket INNER JOIN (
			SELECT	FIFOOut.intInventoryFIFOId
					, dblQty = SUM(FIFOOut.dblQty)
			FROM	dbo.tblICInventoryFIFOOut FIFOOut INNER JOIN #tmpInventoryTransactionStockToReverse InventoryToReverse
						ON FIFOOut.intInventoryTransactionId = InventoryToReverse.intInventoryTransactionId	
			GROUP BY FIFOOut.intInventoryFIFOId
		) AS FIFOOutGrouped
			ON FIFOOutGrouped.intInventoryFIFOId = fifoBucket.intInventoryFIFOId
WHERE	ISNULL(fifoBucket.ysnIsUnposted, 0) = 0
;

-- Update fifo out. Update dblQtyReturned. 
UPDATE	cbOut
SET		cbOut.dblQtyReturned = cbOut.dblQtyReturned - rtn.dblQtyReturned
FROM	tblICInventoryFIFOOut cbOut CROSS APPLY (
			SELECT	rtn.intInventoryFIFOId
					,rtn.intOutId
					,dblQtyReturned = SUM(rtn.dblQtyReturned) 
			FROM	tblICInventoryReturned rtn 
			WHERE	rtn.intTransactionId = @intTransactionId
					AND rtn.strTransactionId = @strTransactionId
			GROUP BY rtn.intInventoryFIFOId, rtn.intOutId
		) rtn
;
