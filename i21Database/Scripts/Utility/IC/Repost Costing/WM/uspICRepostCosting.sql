-- use irely98 

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspICRepostCosting' AND type = 'P')
	DROP PROCEDURE [dbo].[uspICRepostCosting]
	
GO 

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
		,@dblCost AS NUMERIC(18, 6)
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
		,@strActualCostId AS NVARCHAR(50)

DECLARE @CostingMethod AS INT 
		,@strTransactionForm AS NVARCHAR(255)		

-- Declare the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	
		
-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

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
		,strActualCostId
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
	,@intStorageLocationId
	,@strActualCostId;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	-- Initialize the costing method and negative inventory option. 
	SET @CostingMethod = NULL
	SET @strTransactionForm = NULL 

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
	IF (@CostingMethod = @AVERAGECOST AND @strActualCostId IS NULL)
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
			,@intUserId;
	END

	-- FIFO 
	IF (@CostingMethod = @FIFO AND @strActualCostId IS NULL)
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
	IF (@CostingMethod = @LIFO AND @strActualCostId IS NULL)
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
	IF (@CostingMethod = @LOTCOST AND @strActualCostId IS NULL)
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

	-- ACTUAL COST 
	IF (@strActualCostId IS NOT NULL)
	BEGIN 
		EXEC dbo.uspICPostActualCost
			@strActualCostId 
			,@intItemId 
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

	----------------------------------------------------
	---- Adjust the average cost and units on hand. 
	----------------------------------------------------
	--BEGIN 
	--	-- Get the current average cost and stock qty 
	--	DECLARE @CurrentStockQty AS NUMERIC(18,6)
	--	DECLARE @CurrentStockAveCost AS NUMERIC(18,6)

	--	SELECT	@CurrentStockAveCost = dblAverageCost
	--	FROM	dbo.tblICItemPricing ItemPricing
	--	WHERE	ItemPricing.intItemId = @intItemId
	--			AND ItemPricing.intItemLocationId = @intItemLocationId

	--	SELECT	@CurrentStockQty = dblUnitOnHand
	--	FROM	dbo.tblICItemStock ItemStock
	--	WHERE	ItemStock.intItemId = @intItemId
	--			AND ItemStock.intItemLocationId = @intItemLocationId

		-------------------------------------
		---- Update the Item Stock table
		-------------------------------------
		--MERGE	
		--INTO	dbo.tblICItemStock 
		--WITH	(HOLDLOCK) 
		--AS		ItemStock	
		--USING (
		--		SELECT	intItemId = @intItemId
		--				,intItemLocationId = @intItemLocationId
		--				,Qty = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) 
		--) AS StockToUpdate
		--	ON ItemStock.intItemId = StockToUpdate.intItemId
		--	AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

		---- If matched, update the unit on hand qty. 
		--WHEN MATCHED THEN 
		--	UPDATE 
		--	SET		dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0) + StockToUpdate.Qty

		---- If none found, insert a new item stock record
		--WHEN NOT MATCHED THEN 
		--	INSERT (
		--		intItemId
		--		,intItemLocationId
		--		,dblUnitOnHand
		--		,dblOrderCommitted
		--		,dblOnOrder
		--		,dblLastCountRetail
		--		,intSort
		--		,intConcurrencyId
		--	)
		--	VALUES (
		--		StockToUpdate.intItemId
		--		,StockToUpdate.intItemLocationId
		--		,StockToUpdate.Qty -- dblUnitOnHand
		--		,0
		--		,0
		--		,0
		--		,NULL 
		--		,1	
		--	)
		--;

		-----------------------------------------
		---- Update the Item Stock UOM table
		-----------------------------------------
		--MERGE	
		--INTO	dbo.tblICItemStockUOM 
		--WITH	(HOLDLOCK) 
		--AS		ItemStock	
		--USING (
		--		SELECT	intItemId = @intItemId
		--				,intItemLocationId = @intItemLocationId
		--				,intItemUOMId = @intItemUOMId
		--				,intSubLocationId = @intSubLocationId 
		--				,intStorageLocationId = @intStorageLocationId
		--				,Qty = ISNULL(@dblQty, 0)  
				
		--		-- If incoming Lot has a weight, then get value of the other UOM Id. 
		--		UNION ALL 
		--		SELECT	intItemId = @intItemId
		--				,intItemLocationId = @intItemLocationId
		--				,intItemUOMId =	CASE	WHEN (@intItemUOMId = Lot.intItemUOMId) THEN Lot.intWeightUOMId -- Stock is in packs, then get the weight UOM id. 
		--										WHEN (@intItemUOMId = Lot.intWeightUOMId) THEN Lot.intItemUOMId -- Stock is in weight, then get the pack UOM id. 
		--										ELSE @intItemUOMId
		--								END 
		--				,intSubLocationId = @intSubLocationId 
		--				,intStorageLocationId = @intStorageLocationId
		--				,Qty =	CASE	WHEN (@intItemUOMId = Lot.intItemUOMId) THEN @dblQty * Lot.dblWeightPerQty -- Stock is in packs, then convert the qty to weight. 
		--								WHEN (@intItemUOMId = Lot.intWeightUOMId) THEN @dblQty / Lot.dblWeightPerQty -- Stock is in weights, then convert it to packs. 
		--								ELSE @dblQty
		--						END 
		--		FROM	dbo.tblICLot Lot 
		--		WHERE	Lot.intItemLocationId = @intItemLocationId
		--				AND Lot.intLotId = @intLotId
		--				AND Lot.intWeightUOMId IS NOT NULL 
		--				AND Lot.intItemUOMId <> Lot.intWeightUOMId
		--				AND ISNULL(Lot.dblWeightPerQty, 0) <> 0

		--) AS StockToUpdate
		--	ON ItemStock.intItemId = StockToUpdate.intItemId
		--	AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId
		--	AND ItemStock.intItemUOMId = StockToUpdate.intItemUOMId
		--	AND ISNULL(ItemStock.intSubLocationId, 0) = ISNULL(StockToUpdate.intSubLocationId, 0)
		--	AND ISNULL(ItemStock.intStorageLocationId, 0) = ISNULL(StockToUpdate.intStorageLocationId, 0)

		---- If matched, update the unit on hand qty. 
		--WHEN MATCHED THEN 
		--	UPDATE 
		--	SET		dblOnHand = ISNULL(ItemStock.dblOnHand, 0) + StockToUpdate.Qty

		---- If none found, insert a new item stock record
		--WHEN NOT MATCHED THEN 
		--	INSERT (
		--		intItemId
		--		,intItemLocationId
		--		,intItemUOMId
		--		,intSubLocationId
		--		,intStorageLocationId
		--		,dblOnHand
		--		,dblOnOrder
		--		,intConcurrencyId
		--	)
		--	VALUES (
		--		StockToUpdate.intItemId
		--		,StockToUpdate.intItemLocationId
		--		,StockToUpdate.intItemUOMId
		--		,StockToUpdate.intSubLocationId
		--		,StockToUpdate.intStorageLocationId
		--		,StockToUpdate.Qty 
		--		,0
		--		,1	
		--	)
		--;

	--	-- Update the Item Pricing table
	--	MERGE	
	--	INTO	dbo.tblICItemPricing 
	--	WITH	(HOLDLOCK) 
	--	AS		ItemPricing
	--	USING (
	--			SELECT	intItemId = @intItemId
	--					,intItemLocationId = @intItemLocationId
	--					,Qty = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) 
	--					,Cost = dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty)
	--	) AS StockToUpdate
	--		ON ItemPricing.intItemId = StockToUpdate.intItemId
	--		AND ItemPricing.intItemLocationId = StockToUpdate.intItemLocationId

	--	-- If matched, update the average cost, last cost, and standard cost
	--	WHEN MATCHED THEN 
	--		UPDATE 
	--		SET		dblAverageCost = dbo.fnCalculateAverageCost(StockToUpdate.Qty, StockToUpdate.Cost, @CurrentStockQty, ItemPricing.dblAverageCost)
	--				,dblLastCost = CASE WHEN StockToUpdate.Qty > 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblLastCost END 
	--				,dblStandardCost = 
	--								CASE WHEN StockToUpdate.Qty > 0 THEN 
	--										CASE WHEN ISNULL(ItemPricing.dblStandardCost, 0) = 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblStandardCost END 
	--									ELSE 
	--										ItemPricing.dblStandardCost
	--								END 

	--	-- If none found, insert a new item pricing record
	--	WHEN NOT MATCHED THEN 
	--		INSERT (
	--			intItemId
	--			,intItemLocationId
	--			,dblAverageCost 
	--			,dblLastCost 
	--			,dblStandardCost
	--			,intConcurrencyId
	--		)
	--		VALUES (
	--			StockToUpdate.intItemId
	--			,StockToUpdate.intItemLocationId
	--			,dbo.fnCalculateAverageCost(StockToUpdate.Qty, StockToUpdate.Cost, @CurrentStockQty, @CurrentStockAveCost)
	--			,StockToUpdate.Cost
	--			,StockToUpdate.Cost
	--			,1
	--		)
	--	;
	--END 

	--------------------------------------------------
	-- Adjust the average cost and units on hand. 
	--------------------------------------------------
	BEGIN 
		-- Get the current average cost and stock qty 
		DECLARE @CurrentStockQty AS NUMERIC(18,6) = NULL 
		DECLARE @CurrentStockAveCost AS NUMERIC(18,6) = NULL 

		SELECT	@CurrentStockAveCost = dblAverageCost
		FROM	dbo.tblICItemPricing ItemPricing
		WHERE	ItemPricing.intItemId = @intItemId
				AND ItemPricing.intItemLocationId = @intItemLocationId

		SELECT	@CurrentStockQty = dblUnitOnHand
		FROM	dbo.tblICItemStock ItemStock
		WHERE	ItemStock.intItemId = @intItemId
				AND ItemStock.intItemLocationId = @intItemLocationId

		--------------------------------------------------------------------------------
		-- Update average cost, last cost, and standard cost in the Item Pricing table
		--------------------------------------------------------------------------------
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
				,dblStandardCost
				,dblLastCost 
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

		------------------------------------------------------------
		-- Update the Stock Quantity
		------------------------------------------------------------
		EXEC [dbo].[uspICPostStockQuantity]
			@intItemId
			,@intItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intItemUOMId
			,@dblQty
			,@dblUOMQty
			,@intLotId
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
		,@strActualCostId
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;

---------------------------------------------------------------------------------------
-- Create the AUTO-Negative if costing method is average costing
---------------------------------------------------------------------------------------
BEGIN 
	DECLARE @ItemsForAutoNegative AS UnpostItemsTableType
			,@intInventoryTransactionId AS INT 

	-- Get the qualified items for auto-negative. 
	INSERT INTO @ItemsForAutoNegative (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intSubLocationId
			,intStorageLocationId
	FROM	@ItemsToPost
	WHERE	dbo.fnGetCostingMethod(intItemId, intItemLocationId) = @AVERAGECOST
			AND dblQty > 0 

	SET @intInventoryTransactionId = NULL 

	SELECT	TOP 1 
			@intInventoryTransactionId = intInventoryTransactionId
	FROM	dbo.tblICInventoryTransaction
	WHERE	strBatchId = @strBatchId
			AND ISNULL(ysnIsUnposted, 0) = 0 

	WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsForAutoNegative)
	BEGIN 
		SELECT TOP 1 
				@intItemId			= intItemId 
				,@intItemLocationId = intItemLocationId
		FROM	@ItemsForAutoNegative

		INSERT INTO dbo.tblICInventoryTransaction (
					[intItemId]
					,[intItemLocationId]
					,[intItemUOMId]
					,[intSubLocationId]
					,[intStorageLocationId]
					,[dtmDate]
					,[dblQty]
					,[dblUOMQty]
					,[dblCost]
					,[dblValue]
					,[dblSalesPrice]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[intTransactionId]
					,[strTransactionId]
					,[strBatchId]
					,[intTransactionTypeId]
					,[intLotId]
					,[ysnIsUnposted]
					,[intRelatedInventoryTransactionId]
					,[intRelatedTransactionId]
					,[strRelatedTransactionId]
					,[strTransactionForm]
					,[dtmCreated]
					,[intCreatedUserId]
					,[intConcurrencyId]
			)			
		SELECT	
				[intItemId]								= InvTrans.intItemId
				,[intItemLocationId]					= InvTrans.intItemLocationId
				,[intItemUOMId]							= InvTrans.intItemUOMId
				,[intSubLocationId]						= InvTrans.intSubLocationId
				,[intStorageLocationId]					= InvTrans.intStorageLocationId
				,[dtmDate]								= InvTrans.dtmDate
				,[dblQty]								= 0
				,[dblUOMQty]							= 0
				,[dblCost]								= 0
				,[dblValue]								= (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
				,[dblSalesPrice]						= 0
				,[intCurrencyId]						= InvTrans.intCurrencyId
				,[dblExchangeRate]						= InvTrans.dblExchangeRate
				,[intTransactionId]						= InvTrans.intTransactionId
				,[strTransactionId]						= InvTrans.strTransactionId
				,[strBatchId]							= @strBatchId
				,[intTransactionTypeId]					= @AUTO_NEGATIVE
				,[intLotId]								= InvTrans.intLotId
				,[ysnIsUnposted]						= 0
				,[intRelatedInventoryTransactionId]		= NULL 
				,[intRelatedTransactionId]				= NULL 
				,[strRelatedTransactionId]				= NULL 
				,[strTransactionForm]					= InvTrans.strTransactionForm
				,[dtmCreated]							= GETDATE()
				,[intCreatedUserId]						= @intUserId
				,[intConcurrencyId]						= 1
		FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
					ON ItemPricing.intItemId = Stock.intItemId
					AND ItemPricing.intItemLocationId = Stock.intItemLocationId
				INNER JOIN dbo.tblICInventoryTransaction InvTrans
					ON InvTrans.intInventoryTransactionId = @intInventoryTransactionId
		WHERE	ItemPricing.intItemId = @intItemId
				AND ItemPricing.intItemLocationId = @intItemLocationId			
				AND (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) <> 0

		-- Delete the item and item-location from the table variable. 
		DELETE FROM	@ItemsForAutoNegative
		WHERE	intItemId = @intItemId 
				AND intItemLocationId = @intItemLocationId
	END 
END

-------------------------------------------
---- Generate the g/l entries
-------------------------------------------
--IF @strAccountToCounterInventory IS NOT NULL 
--BEGIN 
--	EXEC dbo.uspICCreateGLEntries 
--		@strBatchId
--		,@strAccountToCounterInventory
--		,@intUserId
--		,@strGLDescription
--END 
