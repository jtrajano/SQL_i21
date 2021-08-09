CREATE PROCEDURE [dbo].[uspICUnpostCategory]
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
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3
		,@AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31
		,@INV_TRANS_TYPE_MarkUpOrDown AS INT = 49
		,@INV_TRANS_TYPE_WriteOff AS INT = 50

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5
		,@CATEGORY AS INT = 6

-- Validate the unpost of the stock in. Do not allow unpost if it has cost adjustments. 
IF @ysnRecap = 0
	BEGIN 
	DECLARE @strItemNo AS NVARCHAR(50)
			,@strRelatedTransactionId AS NVARCHAR(50)

	SELECT TOP 1 
			@strItemNo = Item.strItemNo
			,@strRelatedTransactionId = InvTrans.strTransactionId
	FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN dbo.tblICItem Item
				ON InvTrans.intItemId = Item.intItemId
	WHERE	InvTrans.intRelatedTransactionId = @intTransactionId
			AND InvTrans.strRelatedTransactionId = @strTransactionId
			AND InvTrans.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
			AND ISNULL(InvTrans.ysnIsUnposted, 0) = 0 

	IF @strRelatedTransactionId IS NOT NULL 
	BEGIN 
		-- 'Unable to unpost because {Item} has a cost adjustment from {Transaction Id}.'
		EXEC uspICRaiseError 80063, @strItemNo, @strRelatedTransactionId;  
		RETURN -1
	END 
END
-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it into the @InventoryToReverse variable
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
					ON 
					(
						-- Link to the main transaction
						(	
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
						)
						-- Link to revalue, write-off sold, auto variance on sold or used stock. 
						OR (
							inventory_transaction.strTransactionId = Source_Query.strTransactionId
							AND inventory_transaction.intTransactionId = Source_Query.intTransactionId
							AND inventory_transaction.intTransactionTypeId IN (@REVALUE_SOLD, @WRITE_OFF_SOLD, @AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK)
						)
					)
					AND ISNULL(inventory_transaction.ysnIsUnposted, 0) = 0
					AND (
						dbo.fnGetCostingMethod(inventory_transaction.intItemId,inventory_transaction.intItemLocationId) = @CATEGORY 
						OR (
							inventory_transaction.intTransactionTypeId = @INV_TRANS_TYPE_MarkUpOrDown 
							AND inventory_transaction.dblCategoryRetailValue IS NOT NULL
						)
					)
					
				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT $action, inserted.intInventoryTransactionId, inserted.intTransactionId, inserted.strTransactionId, inserted.intRelatedTransactionId, inserted.strRelatedTransactionId, inserted.intTransactionTypeId
		) AS Changes (action, intInventoryTransactionId, intTransactionId, strTransactionId, intRelatedTransactionId, strRelatedTransactionId, intTransactionTypeId)
WHERE	Changes.action = 'UPDATE'
;

UPDATE	CategoryPricing
SET		dblTotalRetailValue = ISNULL(dblTotalRetailValue, 0) + ISNULL(StocksToUnpost.totalRetailValue, 0) 
		,dblTotalCostValue = ISNULL(dblTotalCostValue, 0) + ISNULL(StocksToUnpost.totalCostValue, 0)  
		,dblAverageMargin = 
			CASE 
				WHEN ISNULL(dblTotalRetailValue, 0) + ISNULL(StocksToUnpost.totalRetailValue, 0) <> 0 THEN 
					dbo.fnDivide(
						(
							(ISNULL(dblTotalRetailValue, 0) + ISNULL(StocksToUnpost.totalRetailValue, 0))
							- (ISNULL(dblTotalCostValue, 0) + ISNULL(StocksToUnpost.totalCostValue, 0))
						)
						, (ISNULL(dblTotalRetailValue, 0) + ISNULL(StocksToUnpost.totalRetailValue, 0))
					)						
				ELSE 
					0
			END
FROM	tblICCategoryPricing CategoryPricing INNER JOIN (
			SELECT	totalCostValue = -SUM(ISNULL(t.dblCategoryCostValue, 0))
					,totalRetailValue = -SUM(ISNULL(t.dblCategoryRetailValue, 0)) 
					,t.intCategoryId
					,t.intItemLocationId
			FROM	#tmpInventoryTransactionStockToReverse tmp INNER JOIN tblICInventoryTransaction t 
						ON tmp.intInventoryTransactionId = t.intInventoryTransactionId
			GROUP BY 
					t.intCategoryId
					,t.intItemLocationId
		) StocksToUnpost
			ON CategoryPricing.intCategoryId = StocksToUnpost.intCategoryId
			AND CategoryPricing.intItemLocationId = StocksToUnpost.intItemLocationId			
;