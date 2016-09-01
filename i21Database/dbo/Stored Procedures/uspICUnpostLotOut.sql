CREATE PROCEDURE [dbo].[uspICUnpostLotOut]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@ysnRecap AS BIT 
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
-- Then grab the updated records and store it to the #tmpInventoryTransactionStockToReverse temp table
INSERT INTO #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
)
SELECT	Data_Changes.intInventoryTransactionId
		,Data_Changes.intTransactionId
		,Data_Changes.strTransactionId
		,Data_Changes.intRelatedTransactionId
		,Data_Changes.strRelatedTransactionId
		,Data_Changes.intTransactionTypeId
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
							AND ISNULL(inventory_transaction.dblQty, 0) < 0 -- Reverse Qty that is negative. 
						)
						-- Link to the related transactions 
						OR (
							inventory_transaction.strRelatedTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intRelatedTransactionId = Source_Query.intTransactionId
						)
					)

				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT $action, Inserted.intInventoryTransactionId, Inserted.intTransactionId, Inserted.strTransactionId, Inserted.intRelatedTransactionId, Inserted.strRelatedTransactionId, Inserted.intTransactionTypeId
		) AS Data_Changes (Action, intInventoryTransactionId, intTransactionId, strTransactionId, intRelatedTransactionId, strRelatedTransactionId, intTransactionTypeId)
WHERE	Data_Changes.Action = 'UPDATE'
;

-- If Lot_bucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	LotBucket
SET		dblStockIn = dblStockOut
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLot LotBucket INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LotBucket.intTransactionId = Reversal.intTransactionId
			AND LotBucket.strTransactionId = Reversal.strTransactionId
WHERE	Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
;

-- If LIFOBucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	LotBucket 
SET		dblStockIn = dblStockOut
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLot LotBucket 
WHERE	EXISTS (
			SELECT	TOP 1 1 
			FROM	#tmpInventoryTransactionStockToReverse Reversal
			WHERE	Reversal.intTransactionId = LotBucket.intTransactionId
					AND Reversal.strTransactionId = LotBucket.strTransactionId
					AND Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
		)
;

-- If there are Lot out records, update the costing bucket. Return the out-qty back to the bucket where it came from. 
UPDATE	LotBucket
SET		LotBucket.dblStockOut = ISNULL(LotBucket.dblStockOut, 0) - LotOutGrouped.dblQty
FROM	dbo.tblICInventoryLot LotBucket INNER JOIN (
			SELECT	LotOut.intInventoryLotId
					, dblQty = SUM(LotOut.dblQty)
			FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON LotOut.intInventoryTransactionId = Reversal.intInventoryTransactionId	
			GROUP BY LotOut.intInventoryLotId
		) AS LotOutGrouped
			ON LotOutGrouped.intInventoryLotId = LotBucket.intInventoryLotId
WHERE	ISNULL(LotBucket.ysnIsUnposted, 0) = 0
;