CREATE PROCEDURE [dbo].[uspICUnpostLotInFromCustody]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
BEGIN 
	CREATE TABLE #tmpInventoryTransactionStockToReverse (
		intInventoryLotInCustodyTransactionId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intTransactionTypeId INT NOT NULL 
		,intInventoryLotInCustodyId INT 
		,dblQty NUMERIC(38,20)
	)
END 

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4 	
		,@LOT AS INT = 5

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it into the #tmpInventoryTransactionStockToReverse temp table
INSERT INTO #tmpInventoryTransactionStockToReverse (
	intInventoryLotInCustodyTransactionId
	,intTransactionId
	,strTransactionId
	,intTransactionTypeId
	,intInventoryLotInCustodyId
	,dblQty
)
SELECT	Changes.intInventoryLotInCustodyTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intTransactionTypeId
		,Changes.intInventoryLotInCustodyId
		,Changes.dblQty
FROM	(
			-- Merge will help us get the records we need to unpost and update it at the same time. 
			MERGE	
				INTO	dbo.tblICInventoryLotInCustodyTransaction 
				WITH	(HOLDLOCK) 
				AS		inventory_transaction_in_custody
				USING (
					SELECT	strTransactionId = @strTransactionId
							,intTransactionId = @intTransactionId
				) AS Source_Query  
					ON ISNULL(inventory_transaction_in_custody.ysnIsUnposted, 0) = 0					
					AND dbo.fnGetCostingMethod (
							inventory_transaction_in_custody.intItemId,
							inventory_transaction_in_custody.intItemLocationId
						) IN (@LOT)
					AND 
					(
						-- Link to the main transaction
						(	
							inventory_transaction_in_custody.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction_in_custody.intTransactionId = Source_Query.intTransactionId
							AND ISNULL(inventory_transaction_in_custody.dblQty, 0) > 0 -- Reverse Qty that is positive. 
						)
					)

				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT $action
					, Inserted.intInventoryLotInCustodyTransactionId
					, Inserted.intTransactionId
					, Inserted.strTransactionId
					, Inserted.intTransactionTypeId
					, Inserted.intInventoryLotInCustodyId
					, Inserted.dblQty
		) AS Changes (
			Action
			, intInventoryLotInCustodyTransactionId
			, intTransactionId
			, strTransactionId
			, intTransactionTypeId
			, intInventoryLotInCustodyId
			, dblQty
		)
WHERE	Changes.Action = 'UPDATE'
;

IF NOT EXISTS (
	SELECT	TOP 1 1
	FROM	dbo.tblICInventoryLotInCustody LotBucket_In_Custody INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LotBucket_In_Custody.intTransactionId = Reversal.intTransactionId
			AND LotBucket_In_Custody.strTransactionId = Reversal.strTransactionId
			AND LotBucket_In_Custody.intInventoryLotInCustodyId = Reversal.intInventoryLotInCustodyId
	WHERE	ISNULL(LotBucket_In_Custody.dblStockOut, 0) = 0
)
BEGIN 
	-- Unable to unpost the transaction.
	RAISERROR(51130, 11, 1)
END 

-- Update the lot cost bucket. 
UPDATE	LotBucket_In_Custody
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLotInCustody LotBucket_In_Custody INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LotBucket_In_Custody.intTransactionId = Reversal.intTransactionId
			AND LotBucket_In_Custody.strTransactionId = Reversal.strTransactionId
			AND LotBucket_In_Custody.intInventoryLotInCustodyId = Reversal.intInventoryLotInCustodyId
;