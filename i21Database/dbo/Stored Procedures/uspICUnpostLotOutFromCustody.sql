CREATE PROCEDURE [dbo].[uspICUnpostLotOutFromCustody]
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
-- Then grab the updated records and store it to the #tmpInventoryTransactionStockToReverse temp table
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
				AS		inventory_transaction_From_Custody	
				USING (
					SELECT	strTransactionId = @strTransactionId
							,intTransactionId = @intTransactionId
				) AS Source_Query  
					ON ISNULL(inventory_transaction_From_Custody.ysnIsUnposted, 0) = 0
					AND dbo.fnGetCostingMethod(
							inventory_transaction_From_Custody.intItemId,
							inventory_transaction_From_Custody.intItemLocationId
						) IN (@LOT) 
					AND 
					(
						-- Link to the main transaction
						(	
							inventory_transaction_From_Custody.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction_From_Custody.intTransactionId = Source_Query.intTransactionId
							AND ISNULL(inventory_transaction_From_Custody.dblQty, 0) < 0 -- Reverse Qty that is negative. 
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

-- If there are Lot out records, update the costing bucket. Return the out-qty back to the bucket where it came from. 
UPDATE	LotBucket_In_Custody
SET		LotBucket_In_Custody.dblStockOut = ISNULL(LotBucket_In_Custody.dblStockOut, 0) - Lot_Transactions_In_Custody.dblQty
FROM	dbo.tblICInventoryLotInCustody LotBucket_In_Custody INNER JOIN dbo.tblICInventoryLotInCustodyTransaction Lot_Transactions_In_Custody
			ON LotBucket_In_Custody.intInventoryLotInCustodyId = Lot_Transactions_In_Custody.intInventoryLotInCustodyId
WHERE	ISNULL(LotBucket_In_Custody.ysnIsUnposted, 0) = 0
;