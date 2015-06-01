CREATE PROCEDURE [dbo].[uspICUnpostLotInFromCustody]
	@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
	intInventoryTransactionId
	,intTransactionId
	,strTransactionId
	,intTransactionTypeId
)
SELECT	Changes.intInventoryLotInCustodyTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intTransactionTypeId
FROM	(
			-- Merge will help us get the records we need to unpost and update it at the same time. 
			MERGE	
				INTO	dbo.tblICInventoryLotInCustodyTransaction 
				WITH	(HOLDLOCK) 
				AS		inventory_transaction_from_Custody
				USING (
					SELECT	strTransactionId = @strTransactionId
							,intTransactionId = @intTransactionId
				) AS Source_Query  
					ON ISNULL(inventory_transaction_from_Custody.ysnIsUnposted, 0) = 0					
					AND dbo.fnGetCostingMethod (
							inventory_transaction_from_Custody.intItemId,
							inventory_transaction_from_Custody.intItemLocationId
						) IN (@LOT)
					AND 
					(
						-- Link to the main transaction
						(	
							inventory_transaction_from_Custody.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction_from_Custody.intTransactionId = Source_Query.intTransactionId
							AND ISNULL(inventory_transaction_from_Custody.dblQty, 0) > 0 -- Reverse Qty that is positive. 
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
		) AS Changes (
			Action
			, intInventoryLotInCustodyTransactionId
			, intTransactionId
			, strTransactionId
			, intTransactionTypeId
		)
WHERE	Changes.Action = 'UPDATE'
;

-- Mark the record as unposted too. 
UPDATE	LotBucket_InCustody
SET		dblStockOut = dblStockIn
		,ysnIsUnposted = 1
FROM	dbo.tblICInventoryLotInCustody LotBucket_InCustody INNER JOIN #tmpInventoryTransactionStockToReverse Reversal
			ON LotBucket_InCustody.intTransactionId = Reversal.intTransactionId
			AND LotBucket_InCustody.strTransactionId = Reversal.strTransactionId
;
