/*
	This is the stored procedure that handles the "posting" of items. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToPost, a table-valued parameter (variable). 
	
	In each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 
		2. Adjust the stock quantity and current average cost. 
		3. Calls another stored procedure that will return the generated G/L entries

	Parameters: 
	@ItemsToPost - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@strAccountDescription - The contra g/l account id to use when posting an item. By default, it is set to "Cost of Goods". 
				The calling code needs to specify it because each module may use a different contra g/l account against the 
				Inventory account. For example, a Sales transaction will contra Inventory account with "Cost of Goods" while 
				Receive stocks from AP module may use "AP Clearing".

	@intEntityUserSecurityId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostCosting]
	@ItemsToPost AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(40)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@ysnUpdateItemCostAndPrice AS BIT = 0
	,@ysnTransferOnSameLocation AS BIT = 0 
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
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
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
		,@dblUnitRetail AS NUMERIC(38, 20)
		,@intCategoryId INT 
		,@dblAdjustCostValue NUMERIC(38, 20)
		,@dblAdjustRetailValue NUMERIC(38, 20)
		,@intSourceEntityId INT 

DECLARE @CostingMethod AS INT 
		,@strTransactionForm AS NVARCHAR(255)

-- Declare the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	
		,@CATEGORY AS INT = 6

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_VARIANCE AS INT = 1
DECLARE @InventoryTransactionType_MarkUpOrDown AS INT = 49
DECLARE @InventoryTransactionType_WriteOff AS INT = 50

DECLARE @intReturnValue AS INT 

-----------------------------------------------------------------------------------------------------------------------------
-- Assemble the Stock to Post
-----------------------------------------------------------------------------------------------------------------------------
DECLARE @StockToPost AS ItemCostingTableType 
DECLARE @dtmSytemGeneratedPostDate AS DATETIME = dbo.fnRemoveTimeOnDate(GETDATE()) 
INSERT INTO @StockToPost (
	[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[dtmDate]
    ,[dblQty]
	,[dblUOMQty]
    ,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
    ,[intTransactionId]
	,[intTransactionDetailId]
	,[strTransactionId]
	,[intTransactionTypeId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[ysnIsStorage]
	,[strActualCostId]
    ,[intSourceTransactionId]
	,[strSourceTransactionId]
	,[intInTransitSourceLocationId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intStorageScheduleTypeId]
    ,[dblUnitRetail]
	,[intCategoryId]
	,[dblAdjustCostValue]
	,[dblAdjustRetailValue]
	,[intCostingMethod]
	,[ysnAllowVoucher]
	,[intSourceEntityId]
)
SELECT
	[intItemId] = p.intItemId 
	,[intItemLocationId] = p.intItemLocationId
	,[intItemUOMId] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN iu.intItemUOMId ELSE p.intItemUOMId END 
	,[dtmDate] = 
		CASE 			
			WHEN lastTransaction.dtmDate IS NOT NULL THEN @dtmSytemGeneratedPostDate
			ELSE p.dtmDate
		END 
    ,[dblQty] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateQtyBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblQty) ELSE p.dblQty END 
	,[dblUOMQty] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN iu.dblUnitQty ELSE p.dblUOMQty END 
    ,[dblCost] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblCost) ELSE p.dblCost END 
	,[dblValue] = p.dblValue 
	,[dblSalesPrice] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblSalesPrice) ELSE p.dblSalesPrice END 
	,[intCurrencyId] = p.intCurrencyId
	,[dblExchangeRate] = p.dblExchangeRate
    ,[intTransactionId] = p.intTransactionId
	,[intTransactionDetailId] = p.intTransactionDetailId
	,[strTransactionId] = p.strTransactionId 
	,[intTransactionTypeId] = p.intTransactionTypeId
	,[intLotId] = p.intLotId 
	,[intSubLocationId] = p.intSubLocationId 
	,[intStorageLocationId] = p.intStorageLocationId
	,[ysnIsStorage] = p.ysnIsStorage
	,[strActualCostId] = p.strActualCostId
    ,[intSourceTransactionId] = p.intSourceTransactionId
	,[strSourceTransactionId] = p.strSourceTransactionId
	,[intInTransitSourceLocationId] = p.intInTransitSourceLocationId
	,[intForexRateTypeId] = p.intForexRateTypeId
	,[dblForexRate] = p.dblForexRate
	,[intStorageScheduleTypeId] = p.intStorageScheduleTypeId
    ,[dblUnitRetail] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblUnitRetail) ELSE p.dblUnitRetail END 
	,[intCategoryId] = p.intCategoryId
	,[dblAdjustCostValue] = p.dblAdjustCostValue
	,[dblAdjustRetailValue] = p.dblAdjustRetailValue
	,[intCostingMethod] = p.intCostingMethod
	,[ysnAllowVoucher] = p.ysnAllowVoucher
	,[intSourceEntityId] = p.intSourceEntityId 
FROM 
	@ItemsToPost p 
	INNER JOIN tblICItem i 
		ON p.intItemId = i.intItemId 
	LEFT JOIN tblICItemUOM iu
		ON iu.intItemId = p.intItemId
		AND iu.ysnStockUnit = 1
	OUTER APPLY (
		SELECT TOP 1 
			t.dtmDate
		FROM 
			tblICInventoryTransaction t
		WHERE
			t.strTransactionId = p.strTransactionId	
			AND t.strBatchId <> @strBatchId 
		ORDER BY 
			t.intInventoryTransactionId DESC 
	) lastTransaction

ORDER BY 
	p.intId


-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @returnValue AS INT 

	EXEC @returnValue = dbo.uspICValidateCostingOnPost
		@ItemsToValidate = @StockToPost

	IF @returnValue < 0 RETURN -1;
END

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
		,dtmDate = dbo.fnRemoveTimeOnDate(dtmDate)
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
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
		,dblUnitRetail
		,intCategoryId
		,dblAdjustCostValue
		,dblAdjustRetailValue
		,intSourceEntityId
FROM	@StockToPost 

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
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSubLocationId
	,@intStorageLocationId
	,@strActualCostId
	,@intForexRateTypeId
	,@dblForexRate
	,@dblUnitRetail
	,@intCategoryId
	,@dblAdjustCostValue
	,@dblAdjustRetailValue
	,@intSourceEntityId
;
	
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

	-- Initialize the dblUOMQty
	SELECT	@dblUOMQty = dblUnitQty
	FROM	dbo.tblICItemUOM
	WHERE	intItemId = @intItemId
			AND intItemUOMId = @intItemUOMId

	--------------------------------------------------------------------------------
	-- Call the SP that can process the item's costing method
	--------------------------------------------------------------------------------
	-- Average Cost
	IF (@CostingMethod = @AVERAGECOST AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostAverageCosting
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
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@dblUnitRetail
			,@ysnTransferOnSameLocation
			,@intSourceEntityId

		IF @intReturnValue < 0 GOTO _TerminateLoop;
	END

	-- FIFO 
	IF (@CostingMethod = @FIFO AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostFIFO
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
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@dblUnitRetail
			,@intSourceEntityId

		IF @intReturnValue < 0 GOTO _TerminateLoop;
	END

	-- LIFO 
	IF (@CostingMethod = @LIFO AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostLIFO
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
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@dblUnitRetail
			,@intSourceEntityId

		IF @intReturnValue < 0 GOTO _TerminateLoop;
	END

	-- LOT 
	IF (@CostingMethod = @LOTCOST AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostLot
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
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@dblUnitRetail
			,@intSourceEntityId

		IF @intReturnValue < 0 GOTO _TerminateLoop;
	END

	-- CATEGORY 
	IF (@CostingMethod = @CATEGORY AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostCategory
			@intCategoryId
			,@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblUnitRetail
			,@dblSalesPrice
			,@intCurrencyId
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@dblAdjustCostValue 
			,@dblAdjustRetailValue
			,@intSourceEntityId

		IF @intReturnValue < 0 GOTO _TerminateLoop;
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
				EXEC @intReturnValue = dbo.uspICPostAverageCosting
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
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId
					,@dblForexRate
					,@dblUnitRetail
					,@intSourceEntityId

				IF @intReturnValue < 0 GOTO _TerminateLoop;
			END 

			ELSE IF @intCostingMethod = @FIFO
			BEGIN 
				EXEC @intReturnValue = dbo.uspICPostFIFO
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
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId
					,@dblForexRate
					,@dblUnitRetail
					,@intSourceEntityId

				IF @intReturnValue < 0 GOTO _TerminateLoop;
			END 

			ELSE IF @intCostingMethod = @LIFO
			BEGIN
				EXEC @intReturnValue = dbo.uspICPostLIFO
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
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId
					,@dblForexRate
					,@dblUnitRetail
					,@intSourceEntityId

				IF @intReturnValue < 0 GOTO _TerminateLoop;
			END 

			ELSE IF @intCostingMethod = @LOTCOST
			BEGIN 
				EXEC @intReturnValue = dbo.uspICPostLot
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
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId
					,@dblForexRate
					,@dblUnitRetail
					,@intSourceEntityId

				IF @intReturnValue < 0 GOTO _TerminateLoop;
			END 

			ELSE IF @intCostingMethod = @CATEGORY
			BEGIN 
				EXEC @intReturnValue = dbo.uspICPostCategory
					@intCategoryId
					,@intItemId
					,@intItemLocationId
					,@intItemUOMId
					,@intSubLocationId
					,@intStorageLocationId
					,@dtmDate
					,@dblQty
					,@dblUOMQty
					,@dblCost
					,@dblUnitRetail
					,@dblSalesPrice
					,@intCurrencyId
					,@intTransactionId
					,@intTransactionDetailId
					,@strTransactionId
					,@strBatchId
					,@intTransactionTypeId
					,@strTransactionForm
					,@intEntityUserSecurityId
					,@intForexRateTypeId
					,@dblForexRate
					,@dblAdjustCostValue
					,@dblAdjustRetailValue
					,@intSourceEntityId

				IF @intReturnValue < 0 GOTO _TerminateLoop;
			END
		END 
		ELSE 
		BEGIN 
			EXEC @intReturnValue = dbo.uspICPostActualCost
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
				,@intTransactionId 
				,@intTransactionDetailId 
				,@strTransactionId 
				,@strBatchId 
				,@intTransactionTypeId 
				,@strTransactionForm 
				,@intEntityUserSecurityId 
				,@intForexRateTypeId
				,@dblForexRate
				,@dblUnitRetail
				,@intSourceEntityId
				;

			IF @intReturnValue < 0 GOTO _TerminateLoop;
		END 
	END

	--------------------------------------------------
	-- Adjust the average cost and units on hand. 
	--------------------------------------------------
	IF(@intTransactionTypeId <> @InventoryTransactionType_MarkUpOrDown) -- Do not include update when Mark Up/Down
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
						,Qty = dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblQty) --dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) 
						,Cost = dbo.fnCalculateCostBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblCost) -- dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty)
				FROM	tblICItemUOM iu
				WHERE	iu.intItemId = @intItemId
						AND iu.ysnStockUnit = 1
		) AS StockToUpdate
			ON ItemPricing.intItemId = StockToUpdate.intItemId
			AND ItemPricing.intItemLocationId = StockToUpdate.intItemLocationId

		-- If matched, update the average cost, last cost, and standard cost
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblAverageCost = CASE WHEN @strActualCostId IS NULL THEN dbo.fnCalculateAverageCost(StockToUpdate.Qty, StockToUpdate.Cost, @CurrentStockQty, ItemPricing.dblAverageCost) ELSE ItemPricing.dblAverageCost END 
					,dblLastCost = CASE WHEN StockToUpdate.Qty > 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblLastCost END 
					,dblStandardCost = 
									CASE WHEN StockToUpdate.Qty > 0 THEN 
											CASE WHEN ISNULL(ItemPricing.dblStandardCost, 0) = 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblStandardCost END 
										ELSE 
											ItemPricing.dblStandardCost
									END 
					,ysnIsPendingUpdate = 
						CASE	WHEN 
									dblAverageCost <> CASE WHEN @strActualCostId IS NULL THEN dbo.fnCalculateAverageCost(StockToUpdate.Qty, StockToUpdate.Cost, @CurrentStockQty, ItemPricing.dblAverageCost) ELSE ItemPricing.dblAverageCost END 
									OR dblLastCost <> CASE WHEN StockToUpdate.Qty > 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblLastCost END 
									OR dblStandardCost <> (
											CASE WHEN StockToUpdate.Qty > 0 THEN 
												CASE WHEN ISNULL(ItemPricing.dblStandardCost, 0) = 0 THEN StockToUpdate.Cost ELSE ItemPricing.dblStandardCost END 
											ELSE 
												ItemPricing.dblStandardCost
											END 									
										)
									THEN 
									1 										
								ELSE 
									0
						END 

		-- If none found, insert a new item pricing record
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,dblAverageCost 
				,dblStandardCost
				,dblLastCost 
				,ysnIsPendingUpdate
				,intConcurrencyId
			)
			VALUES (
				StockToUpdate.intItemId
				,StockToUpdate.intItemLocationId
				,CASE WHEN @strActualCostId IS NULL THEN dbo.fnCalculateAverageCost(StockToUpdate.Qty, StockToUpdate.Cost, @CurrentStockQty, @CurrentStockAveCost) ELSE 0 END 
				,StockToUpdate.Cost
				,StockToUpdate.Cost
				,1
				,1
			)
		;

		------------------------------------------------------------
		-- Update the Item Pricing
		------------------------------------------------------------
		EXEC @intReturnValue = uspICUpdateItemPricing
			@intItemId
			,@intItemLocationId

		IF @intReturnValue < 0 GOTO _TerminateLoop;

		------------------------------------------------------------
		-- Update the Stock Quantity
		------------------------------------------------------------
		EXEC @intReturnValue = [dbo].[uspICPostStockQuantity]
			@intItemId
			,@intItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intItemUOMId
			,@dblQty
			,@dblUOMQty
			,@intLotId
			,@intTransactionTypeId
			,@dtmDate

		IF @intReturnValue < 0 GOTO _TerminateLoop;
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
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSubLocationId
		,@intStorageLocationId
		,@strActualCostId 
		,@intForexRateTypeId
		,@dblForexRate
		,@dblUnitRetail
		,@intCategoryId
		,@dblAdjustCostValue
		,@dblAdjustRetailValue
		,@intSourceEntityId
		;
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

_TerminateLoop:

CLOSE loopItems;
DEALLOCATE loopItems;

IF @intReturnValue < 0 RETURN @intReturnValue;

---------------------------------------------------------------------------------------
-- Create the AUTO-Negative if costing method is average costing
---------------------------------------------------------------------------------------
IF ISNULL(@ysnTransferOnSameLocation, 0) = 0
BEGIN 
	DECLARE @ItemsForAutoNegative AS ItemCostingTableType
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
			,dtmDate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT 
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intSubLocationId
			,intStorageLocationId
			,dtmDate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
	FROM	@StockToPost
	WHERE	dbo.fnGetCostingMethod(intItemId, intItemLocationId) = @AVERAGECOST
			AND dblQty > 0 
			AND intTransactionTypeId NOT IN (@InventoryTransactionType_MarkUpOrDown)

	SET @intInventoryTransactionId = NULL 

	SELECT	TOP 1 
			@intInventoryTransactionId	= intInventoryTransactionId
			--,@intCurrencyId				= intCurrencyId
			,@dtmDate					= dtmDate
			--,@dblExchangeRate			= dblExchangeRate
			,@intTransactionId			= intTransactionId
			,@strTransactionId			= strTransactionId
			,@strTransactionForm		= strTransactionForm
	FROM	dbo.tblICInventoryTransaction
	WHERE	strBatchId = @strBatchId
			AND ISNULL(ysnIsUnposted, 0) = 0 

	WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsForAutoNegative)
	BEGIN 
		SELECT TOP 1 
				@intItemId				= intItemId 
				,@intItemLocationId		= intItemLocationId
				,@intItemUOMId			= intItemUOMId
				,@intSubLocationId		= intSubLocationId
				,@intStorageLocationId	= intStorageLocationId
				,@intLotId				= intLotId
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
					,[intCreatedEntityId]
					,[intConcurrencyId]
					,[intCostingMethod]
					,[strDescription]
					,[intForexRateTypeId]
					,[dblForexRate]
					,[intCompanyLocationId]
					,[dtmDateCreated]
			)			
		SELECT	
				[intItemId]								= @intItemId
				,[intItemLocationId]					= @intItemLocationId
				,[intItemUOMId]							= NULL 
				,[intSubLocationId]						= NULL 
				,[intStorageLocationId]					= NULL 
				,[dtmDate]								= @dtmDate
				,[dblQty]								= 0
				,[dblUOMQty]							= 0
				,[dblCost]								= 0
				,[dblValue]								= dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
				,[dblSalesPrice]						= 0
				,[intCurrencyId]						= NULL -- @intCurrencyId
				,[dblExchangeRate]						= 1 -- @dblExchangeRate
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
				,[intCostingMethod]						= @AVERAGECOST
				,[strDescription]						= -- Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s. 
														-- 'Inventory variance is created. The current item valuation is %c. The new valuation is (Qty x New Average Cost) %c x %c = %c.'
														 dbo.fnFormatMessage(
															dbo.fnICGetErrorMessage(80078)
															,dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
															,Stock.dblUnitOnHand
															,ItemPricing.dblAverageCost
															,(Stock.dblUnitOnHand * ItemPricing.dblAverageCost)
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
														)
				,[intForexRateTypeId]					= NULL -- @intForexRateTypeId
				,[dblForexRate]							= 1 -- @dblForexRate
				,[intCompanyLocationId]					= [location].intCompanyLocationId
				,[dtmDateCreated]						= GETUTCDATE()
		FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
					ON ItemPricing.intItemId = Stock.intItemId
					AND ItemPricing.intItemLocationId = Stock.intItemLocationId
				CROSS APPLY [dbo].[fnICGetCompanyLocation](@intItemLocationId, DEFAULT) [location]
		WHERE	ItemPricing.intItemId = @intItemId
				AND ItemPricing.intItemLocationId = @intItemLocationId			
				AND ROUND(dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId), 2) <> 0

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
	FROM	@StockToPost i2p INNER JOIN tblICItemStock i
				on i2p.intItemId = i.intItemId
				AND i2p.intItemLocationId = i.intItemLocationId			
	WHERE	ROUND(i.dblUnitOnHand, 6) = 0 
			AND dbo.fnGetCostingMethod(i2p.intItemId, i2p.intItemLocationId) <> @CATEGORY

	SELECT	TOP 1 
			@dtmDate					= i2p.dtmDate
			,@intTransactionId			= i2p.intTransactionId
			,@strTransactionId			= i2p.strTransactionId
			,@intCurrencyId				= i2p.intCurrencyId
	FROM	@StockToPost i2p INNER JOIN tblICItemStock i
				on i2p.intItemId = i.intItemId
				AND i2p.intItemLocationId = i.intItemLocationId			
	WHERE	ROUND(i.dblUnitOnHand, 6) = 0 

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
					,[intForexRateTypeId]
					,[dblForexRate]
					,[intCompanyLocationId]
					,[dtmDateCreated]
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
				,[intCurrencyId]						= @intCurrencyId -- @intCurrencyId
				,[dblExchangeRate]						= 1 -- @dblExchangeRate
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
				,[intCostingMethod]						= il.intCostingMethod -- @intCostingMethod
				,[strDescription]						=	
														-- Stock quantity is now zero on {Item} in {Location}. Auto variance is posted to zero out its inventory valuation.
														dbo.fnFormatMessage(
															dbo.fnICGetErrorMessage(80093) 
															, i.strItemNo
															, cl.strLocationName
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
															, DEFAULT
														)
				,[intForexRateTypeId]					= NULL -- @intForexRateTypeId
				,[dblForexRate]							= 1 -- @dblForexRate
				,[intCompanyLocationId]					= cl.intCompanyLocationId
				,[dtmDateCreated]						= GETUTCDATE()
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

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
IF @strAccountToCounterInventory IS NOT NULL 
BEGIN 
	DECLARE @intContraInventory_ItemLocationId AS INT

	IF @strAccountToCounterInventory = 'Inventory In-Transit'
	BEGIN 
		SELECT TOP 1 @intContraInventory_ItemLocationId = intInTransitSourceLocationId
		FROM @StockToPost 
		WHERE intInTransitSourceLocationId IS NOT NULL 
	END 

	EXEC @intReturnValue = dbo.uspICCreateGLEntries 
		@strBatchId
		,@strAccountToCounterInventory
		,@intEntityUserSecurityId
		,@strGLDescription
		,@intContraInventory_ItemLocationId

	IF @intReturnValue < 0 RETURN @intReturnValue
END 


-----------------------------------------
-- Call the Risk Log sp
-----------------------------------------
BEGIN 
	EXEC @intReturnValue = dbo.uspICLogRiskPositionFromOnHand
		@strBatchId
		,@strTransactionId
		,@intEntityUserSecurityId

	IF @intReturnValue < 0 RETURN @intReturnValue
END 
