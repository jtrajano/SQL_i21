/*
	This is the stored procedure that handles the returns and "posting" of items. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToReturn, a table-valued parameter (variable). 
	
	In each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 
		2. Adjust the stock quantity and current average cost. 
		3. Calls another stored procedure that will return the generated G/L entries

	Parameters: 
	@ItemsToReturn - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@strAccountDescription - The contra g/l account id to use when posting an item. By default, it is set to "Cost of Goods". 
				The calling code needs to specify it because each module may use a different contra g/l account against the 
				Inventory account. For example, a Sales transaction will contra Inventory account with "Cost of Goods" while 
				Receive stocks from AP module may use "AP Clearing".

	@intEntityUserSecurityId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostReturnCosting]
	@ItemsToReturn AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'AP Clearing'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
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
		,@dblQty AS NUMERIC(38,20) 
		,@dblUOMQty AS NUMERIC(38,20)
		,@dblCost AS NUMERIC(38,20)
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		--,@dblExchangeRate AS NUMERIC (38,20) 
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
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

DECLARE @intReturnValue AS INT 

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @returnValue AS INT 

	EXEC @returnValue = dbo.uspICValidateCostingOnPost
		@ItemsToValidate = @ItemsToReturn

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
		,dtmDate
		,-dblQty
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
FROM	@ItemsToReturn

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
		EXEC @intReturnValue = dbo.uspICPostReturnAverageCosting
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
			,@dblForexRate

		IF @intReturnValue < 0 GOTO _Exit_With_Error
	END

	-- FIFO 
	IF (@CostingMethod = @FIFO AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostReturnFIFO
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
			,@dblForexRate

		IF @intReturnValue < 0 GOTO _Exit_With_Error
	END

	-- LIFO 
	IF (@CostingMethod = @LIFO AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostReturnLIFO
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
			,@dblForexRate

		IF @intReturnValue < 0 GOTO _Exit_With_Error
	END

	-- LOT 
	IF (@CostingMethod = @LOTCOST AND @strActualCostId IS NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostReturnLot
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
			,@dblForexRate

		IF @intReturnValue < 0 GOTO _Exit_With_Error
	END

	-- ACTUAL COST 
	IF (@strActualCostId IS NOT NULL)
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostReturnActualCost
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
			,@dblForexRate

		IF @intReturnValue < 0 GOTO _Exit_With_Error
	END

	--------------------------------------------------
	-- Adjust the average cost and units on hand. 
	--------------------------------------------------
	BEGIN 
		-- Recalculate the average cost from the inventory transaction table. 
		UPDATE	ItemPricing
		SET		dblAverageCost = ISNULL(
					dbo.fnRecalculateAverageCost(intItemId, intItemLocationId)
					, dblAverageCost
				) 
		FROM	dbo.tblICItemPricing ItemPricing	
		WHERE	ItemPricing.intItemId = @intItemId
				AND ItemPricing.intItemLocationId = @intItemLocationId
				AND @strActualCostId IS NULL 
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
		,@dblForexRate
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;

-----------------------------------------------------------------------------------------
---- Create the AUTO-Negative if costing method is average costing
-----------------------------------------------------------------------------------------
--BEGIN 
--	DECLARE @ItemsForAutoNegative AS ItemCostingTableType
--			,@intInventoryTransactionId AS INT 

--	-- Get the qualified items for auto-negative. 
--	INSERT INTO @ItemsForAutoNegative (
--			intItemId
--			,intItemLocationId
--			,intItemUOMId
--			,intLotId
--			,dblQty
--			,intSubLocationId
--			,intStorageLocationId
--			,dtmDate
--			,intTransactionId
--			,strTransactionId
--			,intTransactionTypeId
--	)
--	SELECT 
--			intItemId
--			,intItemLocationId
--			,intItemUOMId
--			,intLotId
--			,dblQty
--			,intSubLocationId
--			,intStorageLocationId
--			,dtmDate
--			,intTransactionId
--			,strTransactionId
--			,intTransactionTypeId
--	FROM	@ItemsToReturn
--	WHERE	dbo.fnGetCostingMethod(intItemId, intItemLocationId) = @AVERAGECOST
--			AND dblQty > 0 
--			AND strActualCostId IS NULL 

--	SET @intInventoryTransactionId = NULL 

--	SELECT	TOP 1 
--			@intInventoryTransactionId	= intInventoryTransactionId
--			,@intCurrencyId				= intCurrencyId
--			,@dtmDate					= dtmDate
--			,@dblExchangeRate			= dblExchangeRate
--			,@intTransactionId			= intTransactionId
--			,@strTransactionId			= strTransactionId
--			,@strTransactionForm		= strTransactionForm
--	FROM	dbo.tblICInventoryTransaction
--	WHERE	strBatchId = @strBatchId
--			AND ISNULL(ysnIsUnposted, 0) = 0 

--	WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsForAutoNegative)
--	BEGIN 
--		SELECT TOP 1 
--				@intItemId				= intItemId 
--				,@intItemLocationId		= intItemLocationId
--				,@intItemUOMId			= intItemUOMId
--				,@intSubLocationId		= intSubLocationId
--				,@intStorageLocationId	= intStorageLocationId
--				,@intLotId				= intLotId
--		FROM	@ItemsForAutoNegative

--		INSERT INTO dbo.tblICInventoryTransaction (
--					[intItemId]
--					,[intItemLocationId]
--					,[intItemUOMId]
--					,[intSubLocationId]
--					,[intStorageLocationId]
--					,[dtmDate]
--					,[dblQty]
--					,[dblUOMQty]
--					,[dblCost]
--					,[dblValue]
--					,[dblSalesPrice]
--					,[intCurrencyId]
--					,[dblExchangeRate]
--					,[intTransactionId]
--					,[strTransactionId]
--					,[strBatchId]
--					,[intTransactionTypeId]
--					,[intLotId]
--					,[ysnIsUnposted]
--					,[intRelatedInventoryTransactionId]
--					,[intRelatedTransactionId]
--					,[strRelatedTransactionId]
--					,[strTransactionForm]
--					,[dtmCreated]
--					,[intCreatedEntityId]
--					,[intConcurrencyId]
--			)			
--		SELECT	
--				[intItemId]								= @intItemId
--				,[intItemLocationId]					= @intItemLocationId
--				,[intItemUOMId]							= NULL 
--				,[intSubLocationId]						= NULL 
--				,[intStorageLocationId]					= NULL 
--				,[dtmDate]								= @dtmDate
--				,[dblQty]								= 0
--				,[dblUOMQty]							= 0
--				,[dblCost]								= 0
--				,[dblValue]								= dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
--				,[dblSalesPrice]						= 0
--				,[intCurrencyId]						= @intCurrencyId
--				,[dblExchangeRate]						= @dblExchangeRate
--				,[intTransactionId]						= @intTransactionId
--				,[strTransactionId]						= @strTransactionId
--				,[strBatchId]							= @strBatchId
--				,[intTransactionTypeId]					= @AUTO_NEGATIVE
--				,[intLotId]								= NULL 
--				,[ysnIsUnposted]						= 0
--				,[intRelatedInventoryTransactionId]		= NULL 
--				,[intRelatedTransactionId]				= NULL 
--				,[strRelatedTransactionId]				= NULL 
--				,[strTransactionForm]					= @strTransactionForm
--				,[dtmCreated]							= GETDATE()
--				,[intCreatedEntityId]					= @intEntityUserSecurityId
--				,[intConcurrencyId]						= 1
--		FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
--					ON ItemPricing.intItemId = Stock.intItemId
--					AND ItemPricing.intItemLocationId = Stock.intItemLocationId
--		WHERE	ItemPricing.intItemId = @intItemId
--				AND ItemPricing.intItemLocationId = @intItemLocationId			
--				AND dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) <> 0

--		-- Delete the item and item-location from the table variable. 
--		DELETE FROM	@ItemsForAutoNegative
--		WHERE	intItemId = @intItemId 
--				AND intItemLocationId = @intItemLocationId
--	END 
--END

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
IF @strAccountToCounterInventory IS NOT NULL 
BEGIN 
	EXEC dbo.uspICCreateReturnGLEntries 
		@strBatchId
		,@strAccountToCounterInventory
		,@intEntityUserSecurityId
		,@strGLDescription
	;
END 

_Exit: 
RETURN 1

_Exit_With_Error: 
RETURN @intReturnValue