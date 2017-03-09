CREATE PROCEDURE [dbo].[uspICRepostCosting]
	@strBatchId AS NVARCHAR(20)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
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
		,@dblQty AS NUMERIC(38, 20) 
		,@dblUOMQty AS NUMERIC(38, 20)
		,@dblCost AS NUMERIC(38, 20)
		,@dblSalesPrice AS NUMERIC(38, 20)
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS NUMERIC (38, 20) 
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT 
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 
		,@strActualCostId AS NVARCHAR(50)
		,@intForexRateTypeId AS INT
		,@dblForexRate NUMERIC(38, 20)


DECLARE @CostingMethod AS INT 
		,@strTransactionForm AS NVARCHAR(255)		

-- Declare the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	
		
-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_VARIANCE AS INT = 1
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
		--,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,strActualCostId
		,intForexRateTypeId
		,dblForexRate 
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
	--,@dblExchangeRate
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSubLocationId
	,@intStorageLocationId
	,@strActualCostId
	,@intForexRateTypeId
	,@dblForexRate;


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
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId 
			,@dblForexRate;
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
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId 
			,@dblForexRate;
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
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId 
			,@dblForexRate;
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
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId 
			,@dblForexRate;
	END

	-- ACTUAL COST 
	IF (@strActualCostId IS NOT NULL)
	BEGIN 
		-- Check if there is enough stock to reduce an actual stock.
		-- If it is not enought then use the default costing method of the item-location. 
		IF (ISNULL(@dblQty, 0) < 0) AND NOT EXISTS (
			SELECT TOP 1 1 
			FROM dbo.tblICInventoryActualCost
			WHERE	strActualCostId = @strActualCostId
					AND intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId
					AND intItemUOMId = @intItemUOMId
					AND (dblStockIn - dblStockOut) > 0 
					AND dbo.fnDateGreaterThanEquals(@dtmDate, dtmDate) = 1
		)
		BEGIN 
			DECLARE @intCostingMethod AS INT
			SELECT @intCostingMethod = dbo.fnGetCostingMethod(@intItemId, @intItemLocationId) 

			IF @intCostingMethod = @AVERAGECOST
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
					--,@dblExchangeRate
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId 
					,@dblForexRate;
			END 

			ELSE IF @intCostingMethod = @FIFO
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
					--,@dblExchangeRate
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId 
					,@dblForexRate;
			END 

			ELSE IF @intCostingMethod = @LIFO
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
					--,@dblExchangeRate
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId 
					,@dblForexRate;
			END 

			ELSE IF @intCostingMethod = @LOTCOST
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
					--,@dblExchangeRate
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId 
					,@dblForexRate;
			END 
		END 
		ELSE 
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
				--,@dblExchangeRate 
				,@intTransactionId 
				,@intTransactionDetailId 
				,@strTransactionId 
				,@strBatchId 
				,@intTransactionTypeId 
				,@strTransactionForm 
				,@intEntityUserSecurityId 
				,@intForexRateTypeId 
				,@dblForexRate;
		END 
	END

	--------------------------------------------------
	-- Adjust the average cost and units on hand. 
	--------------------------------------------------
	BEGIN 
		-- Get the current average cost and stock qty 
		DECLARE @CurrentStockQty AS NUMERIC(38, 20) = NULL 
		DECLARE @CurrentStockAveCost AS NUMERIC(38, 20) = NULL 

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
					,dblSalePrice = 
						CASE	WHEN StockToUpdate.Qty > 0 AND ISNULL(ItemPricing.dblStandardCost, 0) = 0 AND ItemPricing.strPricingMethod = 'Markup Standard Cost' THEN 
									StockToUpdate.Cost + (StockToUpdate.Cost * (ItemPricing.dblAmountPercent / 100))
								ELSE ItemPricing.dblSalePrice
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
		--,@dblExchangeRate
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSubLocationId
		,@intStorageLocationId
		,@strActualCostId
		,@intForexRateTypeId
		,@dblForexRate;
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
	DECLARE @ItemsForAutoNegative AS ItemCostingTableType
			,@intInventoryTransactionId AS INT 
			,@intIdAutoNegative AS INT 

	-- Get the qualified items for auto-negative. 
	INSERT INTO @ItemsForAutoNegative (
			intItemId
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
	)
	SELECT  intItemId
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
	WHERE	dbo.fnGetCostingMethod(intItemId, intItemLocationId) = @AVERAGECOST
			AND dblQty > 0 

	SET	@intInventoryTransactionId = NULL 
	SET @strTransactionForm = NULL 

	SELECT	TOP 1 
			@intInventoryTransactionId = intInventoryTransactionId
			,@strTransactionForm = strTransactionForm
	FROM	dbo.tblICInventoryTransaction
	WHERE	strBatchId = @strBatchId
			AND ISNULL(ysnIsUnposted, 0) = 0 
			AND dblQty > 0

	WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsForAutoNegative)
	BEGIN 
		SELECT TOP 1 
				@intItemId			= intItemId 
				,@intItemLocationId = intItemLocationId
				,@intIdAutoNegative	= intId 
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
				[intItemId]								= AutoNegative.intItemId
				,[intItemLocationId]					= AutoNegative.intItemLocationId
				,[intItemUOMId]							= AutoNegative.intItemUOMId
				,[intSubLocationId]						= AutoNegative.intSubLocationId
				,[intStorageLocationId]					= AutoNegative.intStorageLocationId
				,[dtmDate]								= AutoNegative.dtmDate
				,[dblQty]								= 0
				,[dblUOMQty]							= 0
				,[dblCost]								= 0
				,[dblValue]								= (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
				,[dblSalesPrice]						= 0
				,[intCurrencyId]						= AutoNegative.intCurrencyId
				,[dblExchangeRate]						= AutoNegative.dblExchangeRate
				,[intTransactionId]						= AutoNegative.intTransactionId
				,[strTransactionId]						= AutoNegative.strTransactionId
				,[strBatchId]							= @strBatchId
				,[intTransactionTypeId]					= @AUTO_VARIANCE
				,[intLotId]								= AutoNegative.intLotId
				,[ysnIsUnposted]						= 0
				,[intRelatedInventoryTransactionId]		= NULL 
				,[intRelatedTransactionId]				= NULL 
				,[strRelatedTransactionId]				= NULL 
				,[strTransactionForm]					= @strTransactionForm
				,[dtmCreated]							= GETDATE()
				,[intCreatedUserId]						= @intEntityUserSecurityId
				,[intConcurrencyId]						= 1
		FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
					ON ItemPricing.intItemId = Stock.intItemId
					AND ItemPricing.intItemLocationId = Stock.intItemLocationId
				INNER JOIN @ItemsForAutoNegative AutoNegative
					ON AutoNegative.intItemId = ItemPricing.intItemId
					AND AutoNegative.intItemLocationId = ItemPricing.intItemLocationId
				INNER JOIN dbo.tblICInventoryTransaction InvTrans
					ON InvTrans.intInventoryTransactionId = @intInventoryTransactionId
		WHERE	AutoNegative.intId = @intIdAutoNegative
				AND (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) <> 0

		-- Delete the item and item-location from the table variable. 
		DELETE FROM	@ItemsForAutoNegative
		WHERE	intItemId = @intItemId 
				AND intItemLocationId = @intItemLocationId
	END 
END

---------------------------------------------------------------------------------------
-- Make sure valuation is zero if stock is going to be zero. 
---------------------------------------------------------------------------------------
BEGIN 
	DECLARE @ItemsWithZeroStock AS ItemCostingZeroStockTableType
			,@currentItemValue AS NUMERIC(38, 20)

	-- Get the qualified items for auto-negative. 
	INSERT INTO @ItemsWithZeroStock (
			intItemId
			,intItemLocationId
	)
	SELECT	DISTINCT 
			i2p.intItemId
			,i2p.intItemLocationId
	FROM	@ItemsToPost i2p INNER JOIN tblICItemStock i
				on i2p.intItemId = i.intItemId
				AND i2p.intItemLocationId = i.intItemLocationId			
	WHERE	dbo.fnGetCostingMethod(i2p.intItemId, i2p.intItemLocationId) <> @AVERAGECOST
			AND i.dblUnitOnHand = 0 

	SELECT	TOP 1 
			@intInventoryTransactionId	= intInventoryTransactionId
			,@intCurrencyId				= intCurrencyId
			,@dtmDate					= dtmDate
			,@dblExchangeRate			= dblExchangeRate
			,@intTransactionId			= intTransactionId
			,@strTransactionId			= strTransactionId
			,@strTransactionForm		= strTransactionForm
			,@intCostingMethod			= intCostingMethod
	FROM	dbo.tblICInventoryTransaction
	WHERE	strBatchId = @strBatchId
			AND ISNULL(ysnIsUnposted, 0) = 0 

	IF EXISTS (SELECT TOP 1 1 FROM @ItemsWithZeroStock) 
	BEGIN 
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
					,[intCreatedEntityId]
					,[intConcurrencyId]
					,[intCostingMethod]
					,[strDescription]
			)			
		SELECT	
				[intItemId]								= iWithZeroStock.intItemId
				,[intItemLocationId]					= iWithZeroStock.intItemLocationId
				,[intItemUOMId]							= NULL 
				,[intSubLocationId]						= NULL 
				,[intStorageLocationId]					= NULL 
				,[dtmDate]								= @dtmDate
				,[dblQty]								= 0
				,[dblUOMQty]							= 0
				,[dblCost]								= 0
				,[dblValue]								= -currentValuation.floatingValue
				,[dblSalesPrice]						= 0
				,[intCurrencyId]						= @intCurrencyId
				,[dblExchangeRate]						= @dblExchangeRate
				,[intTransactionId]						= @intTransactionId
				,[strTransactionId]						= @strTransactionId
				,[strBatchId]							= @strBatchId
				,[intTransactionTypeId]					= @AUTO_VARIANCE
				,[intLotId]								= NULL 
				,[ysnIsUnposted]						= 0
				,[intRelatedInventoryTransactionId]		= NULL 
				,[intRelatedTransactionId]				= NULL 
				,[strRelatedTransactionId]				= NULL 
				,[strTransactionForm]					= @strTransactionForm
				,[dtmCreated]							= GETDATE()
				,[intCreatedEntityId]					= @intEntityUserSecurityId
				,[intConcurrencyId]						= 1
				,[intCostingMethod]						= @intCostingMethod
				,[strDescription]						=	-- Stock quantity is now zero on {Item} in {Location}. Auto variance is posted to zero out its inventory valuation.
															FORMATMESSAGE(
															80093
															,i.strItemNo
															,cl.strLocationName														
														)
		FROM	@ItemsWithZeroStock iWithZeroStock INNER JOIN tblICItemStock iStock
					ON iWithZeroStock.intItemId = iStock.intItemId
					AND iWithZeroStock.intItemLocationId = iStock.intItemLocationId
				INNER JOIN tblICItem i
					ON i.intItemId = iWithZeroStock.intItemId
				INNER JOIN tblICItemLocation il
					ON il.intItemId = iWithZeroStock.intItemId
					AND il.intItemLocationId = iWithZeroStock.intItemLocationId
				INNER JOIN tblSMCompanyLocation cl
					ON cl.intCompanyLocationId = il.intLocationId
				OUTER APPLY (
					SELECT	floatingValue = SUM(
								ROUND(t.dblQty * t.dblCost + t.dblValue, 2)
							)
					FROM	tblICInventoryTransaction t
					WHERE	t.intItemId = iWithZeroStock.intItemId
							AND t.intItemLocationId = iWithZeroStock.intItemLocationId
				) currentValuation
		WHERE	ISNULL(currentValuation.floatingValue, 0) <> 0
	END 
END 