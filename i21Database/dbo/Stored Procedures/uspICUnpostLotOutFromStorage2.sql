CREATE PROCEDURE [dbo].[uspICUnpostLotOutFromStorage]
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
	intInventoryTransactionStorageId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
	,dblQty 
)
SELECT	Data_Changes.intInventoryTransactionStorageId
		,Data_Changes.intTransactionId
		,Data_Changes.strTransactionId
		,Data_Changes.intRelatedTransactionId
		,Data_Changes.strRelatedTransactionId
		,Data_Changes.intTransactionTypeId
		,Data_Changes.dblQty 
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

				OUTPUT 
					$action
					, Inserted.intInventoryTransactionStorageId
					, Inserted.intTransactionId
					, Inserted.strTransactionId
					, Inserted.intRelatedTransactionId
					, Inserted.strRelatedTransactionId
					, Inserted.intTransactionTypeId
					, Inserted.dblQty 
		) AS Data_Changes (
			Action
			, intInventoryTransactionStorageId
			, intTransactionId
			, strTransactionId
			, intRelatedTransactionId
			, strRelatedTransactionId
			, intTransactionTypeId
			, dblQty 
		)
WHERE	Data_Changes.Action = 'UPDATE'
;

-- If Lot_bucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	LotBucket
SET		dblStockIn = dblStockOut
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLotStorage LotBucket INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LotBucket.intTransactionId = Reversal.intTransactionId
			AND LotBucket.strTransactionId = Reversal.strTransactionId
WHERE	Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
		AND ISNULL(Reversal.dblQty, 0) <> 0 
;

-- If LIFOBucket was from a negative stock, let dblStockIn equal to dblStockOut. 
UPDATE	LotBucket 
SET		dblStockIn = dblStockOut
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLotStorage LotBucket 
WHERE	EXISTS (
			SELECT	TOP 1 1 
			FROM	#tmpInventoryTransactionStockToReverse Reversal
			WHERE	Reversal.intTransactionId = LotBucket.intTransactionId
					AND Reversal.strTransactionId = LotBucket.strTransactionId
					AND Reversal.intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE) 
					AND ISNULL(Reversal.dblQty, 0) <> 0 
		)		
;

-- If there are Lot out records, update the costing bucket. Return the out-qty back to the bucket where it came from. 
UPDATE	LotBucket
SET		LotBucket.dblStockOut = ISNULL(LotBucket.dblStockOut, 0) - LotOutGrouped.dblQty
FROM	dbo.tblICInventoryLotStorage LotBucket INNER JOIN (
			SELECT	LotOut.intInventoryLotStorageId
					, dblQty = SUM(LotOut.dblQty)
			FROM	dbo.tblICInventoryLotStorageOut LotOut INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
						ON LotOut.intInventoryTransactionStorageId = Reversal.intInventoryTransactionStorageId	
			GROUP BY LotOut.intInventoryLotStorageId
		) AS LotOutGrouped
			ON LotOutGrouped.intInventoryLotStorageId = LotBucket.intInventoryLotStorageId
WHERE	ISNULL(LotBucket.ysnIsUnposted, 0) = 0
;