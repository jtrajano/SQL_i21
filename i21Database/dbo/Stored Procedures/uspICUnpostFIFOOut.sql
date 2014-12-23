CREATE PROCEDURE [dbo].[uspICUnpostFIFOOut]
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

DECLARE @InventoryTransactionToReverse AS dbo.InventoryTranactionStockToReverse

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it to the @InventoryToReverse variable
INSERT INTO @InventoryTransactionToReverse (
	intInventoryTransactionId
	,intTransactionId
	,strTransactionId
	,intRelatedInventoryTransactionId
	,strRelatedInventoryTransactionId
	,intTransactionTypeId
)
SELECT	Changes.intInventoryTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedInventoryTransactionId
		,Changes.strRelatedInventoryTransactionId
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
					AND 
					(
						-- Link to the main transaction
						(	
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
						)
						-- Link to the related transactions 
						OR (
							inventory_transaction.strRelatedInventoryTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intRelatedInventoryTransactionId = Source_Query.intTransactionId
						)
					)
				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT $action, Inserted.intInventoryTransactionId, Inserted.intTransactionId, Inserted.strTransactionId, Inserted.intRelatedInventoryTransactionId, Inserted.strRelatedInventoryTransactionId, Inserted.intTransactionTypeId
		) AS Changes (Action, intInventoryTransactionId, intTransactionId, strTransactionId, intRelatedInventoryTransactionId, strRelatedInventoryTransactionId, intTransactionTypeId)
WHERE	Changes.Action = 'UPDATE'
;

-- If fifo_bucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	fifoBucket
SET		dblStockIn = dblStockOut
FROM	dbo.tblICInventoryFIFO fifoBucket INNER JOIN @InventoryTransactionToReverse InventoryToReverse
			ON fifoBucket.intTransactionId = InventoryToReverse.intTransactionId
			AND fifoBucket.strTransactionId = InventoryToReverse.strTransactionId
WHERE	InventoryToReverse.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
;

-- If there are fifo out records, update the costing bucket. Return the out-qty back to the bucket where it came from. 
UPDATE	fifoBucket
SET		fifoBucket.dblStockOut = ISNULL(fifoBucket.dblStockOut, 0) - fifoOutGrouped.dblQty
FROM	dbo.tblICInventoryFIFO fifoBucket INNER JOIN (
			SELECT	fifoOut.intInventoryFIFOId, dblQty = SUM(fifoOut.dblQty)
			FROM	dbo.tblICInventoryFIFOOut fifoOut INNER JOIN @InventoryTransactionToReverse InventoryToReverse
						ON fifoOut.intInventoryTransactionId = InventoryToReverse.intInventoryTransactionId	
			GROUP BY fifoOut.intInventoryFIFOId
		) AS fifoOutGrouped
			ON fifoOutGrouped.intInventoryFIFOId = fifoBucket.intInventoryFIFOId
;

-- Return the transactions to reverse back to the calling code. 
SELECT * FROM @InventoryTransactionToReverse