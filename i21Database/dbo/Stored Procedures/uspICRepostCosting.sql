/*
	This is a utility stored procedure used to reposting and rebuild the costing tables. 
	
	CAUTION!
	This will impact the inventory valuation and g/l entries. 
	Make sure a database backup is made prior to using this SP. 

*/
CREATE PROCEDURE [dbo].[uspICRepostCosting]
	@strBatchId AS NVARCHAR(20)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intUserId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@ItemsToPost AS ItemCostingTableType READONLY 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables to use for the cursor
DECLARE @intId AS INT 
		,@intItemId AS INT
		,@intItemLocationId AS INT 
		,@intItemUOMId AS INT 
		,@dtmDate AS DATETIME
		,@dblQty AS NUMERIC(18, 6) 
		,@dblUOMQty AS NUMERIC(18, 6)
		,@dblCost AS NUMERIC(38,20)
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT 
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 

DECLARE @CostingMethod AS INT 
		,@strTransactionForm AS NVARCHAR(255)


-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4
		,@LOTCOST AS INT = 5
		

-------------------------------------------------------------------------------------------------------------------------------
---- Do the Validation
-------------------------------------------------------------------------------------------------------------------------------
--BEGIN 
--	EXEC dbo.uspICValidateCostingOnPost
--		@ItemsToValidate = @ItemsToPost
--END

-----------------------------------------------------------------------------------------------------------------------------
-- Create the cursor
-- Make sure the following options are used: 
-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
-----------------------------------------------------------------------------------------------------------------------------
DECLARE loopItems CURSOR LOCAL FAST_FORWARD
FOR 
SELECT  intId
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
FROM	@ItemsToPost

OPEN loopItems;

-- Initial fetch attempt
FETCH NEXT FROM loopItems INTO 
	@intId
	,@intItemId
	,@intItemLocationId
	,@intItemUOMId
	,@dtmDate
	,@dblQty
	,@dblUOMQty
	,@dblCost
	,@dblSalesPrice
	,@intCurrencyId
	,@dblExchangeRate
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSubLocationId
	,@intStorageLocationId;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	-- Initialize the costing method and negative inventory option. 
	SET @CostingMethod = NULL;

	-- Initialize the transaction form
	SELECT	@strTransactionForm = strTransactionForm
	FROM	dbo.tblICInventoryTransactionType
	WHERE	intTransactionTypeId = @intTransactionTypeId
			AND strTransactionForm IS NOT NULL 

	-- Get the costing method of an item 
	SELECT	@CostingMethod = CostingMethod 
	FROM	dbo.fnGetCostingMethodAsTable(@intItemId, @intItemLocationId)

	--------------------------------------------------------------------------------
	-- Call the SP that can process the item's costing method
	--------------------------------------------------------------------------------
	-- Average Cost
	IF (@CostingMethod = @AVERAGECOST)
	BEGIN 
		EXEC dbo.uspICPostAverageCosting
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intUserId
	END

	-- FIFO 
	IF (@CostingMethod = @FIFO)
	BEGIN 
		EXEC dbo.uspICPostFIFO
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intUserId;
	END

	-- LIFO 
	IF (@CostingMethod = @LIFO)
	BEGIN 
		EXEC dbo.uspICPostLIFO
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intUserId;
	END

	-- LOT 
	IF (@CostingMethod = @LOTCOST)
	BEGIN 
		EXEC dbo.uspICPostLot
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@intLotId
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intUserId;
	END

	-- Update the Lot's Qty and Weights. 
	BEGIN 
		UPDATE	Lot 
		SET		Lot.dblQty = dbo.fnCalculateLotQty(Lot.intItemUOMId, @intItemUOMId, Lot.dblQty, Lot.dblWeight, @dblQty, Lot.dblWeightPerQty)
				,Lot.dblWeight = dbo.fnCalculateLotWeight(Lot.intItemUOMId, Lot.intWeightUOMId, @intItemUOMId, Lot.dblWeight, @dblQty, Lot.dblWeightPerQty)
				,Lot.dblLastCost = CASE WHEN @dblQty > 0 THEN dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty) ELSE Lot.dblLastCost END 
		FROM	dbo.tblICLot Lot
		WHERE	Lot.intItemLocationId = @intItemLocationId
				AND Lot.intLotId = @intLotId
	END 

	--------------------------------------------------
	-- Adjust the average cost and units on hand. 
	--------------------------------------------------
	BEGIN 
		-- Get the current average cost and stock qty 
		DECLARE @CurrentStockQty AS NUMERIC(18,6)
		DECLARE @CurrentStockAveCost AS NUMERIC(18,6)

		SELECT	@CurrentStockAveCost = dblAverageCost
		FROM	dbo.tblICItemPricing ItemPricing
		WHERE	ItemPricing.intItemId = @intItemId
				AND ItemPricing.intItemLocationId = @intItemLocationId

		SELECT	@CurrentStockQty = dblUnitOnHand
		FROM	dbo.tblICItemStock ItemStock
		WHERE	ItemStock.intItemId = @intItemId
				AND ItemStock.intItemLocationId = @intItemLocationId

		-----------------------------------
		-- Update the Item Stock table
		-----------------------------------
		MERGE	
		INTO	dbo.tblICItemStock 
		WITH	(HOLDLOCK) 
		AS		ItemStock	
		USING (
				SELECT	intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,Qty = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) 
		) AS StockToUpdate
			ON ItemStock.intItemId = StockToUpdate.intItemId
			AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

		-- If matched, update the unit on hand qty. 
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0) + StockToUpdate.Qty

		-- If none found, insert a new item stock record
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,dblUnitOnHand
				,dblOrderCommitted
				,dblOnOrder
				,dblLastCountRetail
				,intSort
				,intConcurrencyId
			)
			VALUES (
				StockToUpdate.intItemId
				,StockToUpdate.intItemLocationId
				,StockToUpdate.Qty -- dblUnitOnHand
				,0
				,0
				,0
				,NULL 
				,1	
			)
		;

		---------------------------------------
		-- Update the Item Stock UOM table
		---------------------------------------
		MERGE	
		INTO	dbo.tblICItemStockUOM 
		WITH	(HOLDLOCK) 
		AS		ItemStock	
		USING (
				SELECT	intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,intItemUOMId = @intItemUOMId
						,intSubLocationId = @intSubLocationId 
						,intStorageLocationId = @intStorageLocationId
						,Qty = ISNULL(@dblQty, 0)  
				
				-- If incoming Lot has a weight, then get value of the other UOM Id. 
				UNION ALL 
				SELECT	intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,intItemUOMId =	CASE	WHEN (@intItemUOMId = Lot.intItemUOMId) THEN Lot.intWeightUOMId -- Stock is in packs, then get the weight UOM id. 
												WHEN (@intItemUOMId = Lot.intWeightUOMId) THEN Lot.intItemUOMId -- Stock is in weight, then get the pack UOM id. 
												ELSE @intItemUOMId
										END 
						,intSubLocationId = @intSubLocationId 
						,intStorageLocationId = @intStorageLocationId
						,Qty =	CASE	WHEN (@intItemUOMId = Lot.intItemUOMId) THEN @dblQty * Lot.dblWeightPerQty -- Stock is in packs, then convert the qty to weight. 
										WHEN (@intItemUOMId = Lot.intWeightUOMId) THEN @dblQty / Lot.dblWeightPerQty -- Stock is in weights, then convert it to packs. 
										ELSE @dblQty
								END 
				FROM	dbo.tblICLot Lot 
				WHERE	Lot.intItemLocationId = @intItemLocationId
						AND Lot.intLotId = @intLotId
						AND Lot.intWeightUOMId IS NOT NULL 
						AND Lot.intItemUOMId <> Lot.intWeightUOMId
						AND ISNULL(Lot.dblWeightPerQty, 0) <> 0

		) AS StockToUpdate
			ON ItemStock.intItemId = StockToUpdate.intItemId
			AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId
			AND ItemStock.intItemUOMId = StockToUpdate.intItemUOMId
			AND ISNULL(ItemStock.intSubLocationId, 0) = ISNULL(StockToUpdate.intSubLocationId, 0)
			AND ISNULL(ItemStock.intStorageLocationId, 0) = ISNULL(StockToUpdate.intStorageLocationId, 0)

		-- If matched, update the unit on hand qty. 
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblOnHand = ISNULL(ItemStock.dblOnHand, 0) + StockToUpdate.Qty

		-- If none found, insert a new item stock record
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dblOnHand
				,dblOnOrder
				,intConcurrencyId
			)
			VALUES (
				StockToUpdate.intItemId
				,StockToUpdate.intItemLocationId
				,StockToUpdate.intItemUOMId
				,StockToUpdate.intSubLocationId
				,StockToUpdate.intStorageLocationId
				,StockToUpdate.Qty 
				,0
				,1	
			)
		;

		-- Update the Item Pricing table
		MERGE	
		INTO	dbo.tblICItemPricing 
		WITH	(HOLDLOCK) 
		AS		ItemPricing
		USING (
				SELECT	intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,Qty = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) 
						,Cost = dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty)
		) AS StockToUpdate
			ON ItemPricing.intItemId = StockToUpdate.intItemId
			AND ItemPricing.intItemLocationId = StockToUpdate.intItemLocationId

		-- If matched, update the average cost, last cost, and standard cost
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblAverageCost = dbo.fnCalculateAverageCost(StockToUpdate.Qty, StockToUpdate.Cost, @CurrentStockQty, ItemPricing.dblAverageCost)
					,dblLastCost = CASE WHEN StockToUpdate.Qty > 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblLastCost END 
					,dblStandardCost = 
									CASE WHEN StockToUpdate.Qty > 0 THEN 
											CASE WHEN ISNULL(ItemPricing.dblStandardCost, 0) = 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblStandardCost END 
										ELSE 
											ItemPricing.dblStandardCost
									END 

		-- If none found, insert a new item pricing record
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,dblAverageCost 
				,dblLastCost 
				,dblStandardCost
				,intConcurrencyId
			)
			VALUES (
				StockToUpdate.intItemId
				,StockToUpdate.intItemLocationId
				,dbo.fnCalculateAverageCost(StockToUpdate.Qty, StockToUpdate.Cost, @CurrentStockQty, @CurrentStockAveCost)
				,StockToUpdate.Cost
				,StockToUpdate.Cost
				,1
			)
		;
	END 

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItems INTO 
		@intId
		,@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@dblQty
		,@dblUOMQty
		,@dblCost
		,@dblSalesPrice
		,@intCurrencyId
		,@dblExchangeRate
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSubLocationId
		,@intStorageLocationId
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
IF @strAccountToCounterInventory IS NOT NULL 
BEGIN 
	EXEC dbo.uspICCreateGLEntries 
		@strBatchId
		,@strAccountToCounterInventory
		,@intUserId
		,@strGLDescription
END 
