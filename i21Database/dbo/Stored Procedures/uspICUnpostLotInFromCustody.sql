﻿CREATE PROCEDURE [dbo].[uspICUnpostLotInFromCustody]
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
		intInventoryTransactionInCustodyId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intTransactionTypeId INT NOT NULL 
		,intInventoryCostBucketInCustodyId INT 
		,dblQty NUMERIC(38,20)
	)
END 

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
	intInventoryTransactionInCustodyId
	,intTransactionId
	,strTransactionId
	,intTransactionTypeId
	,intInventoryCostBucketInCustodyId
	,dblQty
)
SELECT	Changes.intInventoryTransactionInCustodyId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intTransactionTypeId
		,Changes.intInventoryCostBucketInCustodyId
		,Changes.dblQty
FROM	(
			-- Merge will help us get the records we need to unpost and update it at the same time. 
			MERGE	
				INTO	dbo.tblICInventoryTransactionInCustody 
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
						) IN (@LOTCOST)
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
					, Inserted.intInventoryTransactionInCustodyId
					, Inserted.intTransactionId
					, Inserted.strTransactionId
					, Inserted.intTransactionTypeId
					, Inserted.intInventoryCostBucketInCustodyId
					, Inserted.dblQty
		) AS Changes (
			Action
			, intInventoryTransactionInCustodyId
			, intTransactionId
			, strTransactionId
			, intTransactionTypeId
			, intInventoryCostBucketInCustodyId
			, dblQty
		)
WHERE	Changes.Action = 'UPDATE'
;

--IF NOT EXISTS (
--	SELECT TOP 1 1 
--	FROM	dbo.tblICInventoryLotInCustody LotBucket_In_Custody INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
--				ON LotBucket_In_Custody.intTransactionId = Reversal.intTransactionId
--				AND LotBucket_In_Custody.strTransactionId = Reversal.strTransactionId
--				AND LotBucket_In_Custody.intInventoryLotInCustodyId = Reversal.intInventoryCostBucketInCustodyId
--	WHERE	ISNULL(LotBucket_In_Custody.dblStockOut, 0) = 0	
--)
--BEGIN 
--	-- Negative stock quantity is not allowed.
--	RAISERROR(80003, 11, 1) 
--	GOTO _Exit;
--END 

-- Update the lot cost bucket. 
UPDATE	LotBucket_In_Custody
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLotInCustody LotBucket_In_Custody INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LotBucket_In_Custody.intTransactionId = Reversal.intTransactionId
			AND LotBucket_In_Custody.strTransactionId = Reversal.strTransactionId
			AND LotBucket_In_Custody.intInventoryLotInCustodyId = Reversal.intInventoryCostBucketInCustodyId
WHERE	ISNULL(LotBucket_In_Custody.dblStockOut, 0) = 0
;

_Exit: 