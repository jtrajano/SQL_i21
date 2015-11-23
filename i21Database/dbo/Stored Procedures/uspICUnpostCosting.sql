/*
	Used to reverse the stocks from a posted transaction.
*/
CREATE PROCEDURE [dbo].[uspICUnpostCosting]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(20)
	,@intUserId AS INT
	,@ysnRecap AS BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
	DROP TABLE #tmpInventoryTransactionStockToReverse

-- Create the temp table 
CREATE TABLE #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionId INT NOT NULL 
	,intTransactionId INT NULL 
	,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,intRelatedTransactionId INT NULL 
	,intTransactionTypeId INT NOT NULL 
)

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5

DECLARE @ItemsToUnpost AS dbo.UnpostItemsTableType

DECLARE @intItemId AS INT
		,@intItemUOMId AS INT 
		,@intItemLocationId AS INT 
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 					
		,@dblQty AS NUMERIC(18, 6) 
		,@dblUOMQty AS NUMERIC(18, 6)
		,@dblCost AS NUMERIC(18, 6)
		,@intLotId AS INT
		,@dtmDate AS DATETIME
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS DECIMAL (38, 20) 
		,@strTransactionForm AS NVARCHAR(255)

-- Get the list of items to unpost
BEGIN 
	-- Insert the items per location, UOM, and if possible also by Lot. 
	INSERT INTO @ItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,dblCost
			,dblUOMQty
			,intSubLocationId
			,intStorageLocationId
			,intInventoryTransactionId
	)
	SELECT	ItemTrans.intItemId
			,ItemTrans.intItemLocationId
			,ItemTrans.intItemUOMId
			,ItemTrans.intLotId
			,-1 * ISNULL(ItemTrans.dblQty, 0) 
			,ItemTrans.dblCost
			,ItemTrans.dblUOMQty		
			,ItemTrans.intSubLocationId
			,ItemTrans.intStorageLocationId
			,ItemTrans.intInventoryTransactionId
	FROM	dbo.tblICInventoryTransaction ItemTrans
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0
			AND ISNULL(ItemTrans.dblQty, 0) <> 0 
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @ValidateItemsToUnpost AS dbo.UnpostItemsTableType
	DECLARE @returnValue AS INT 

	-- Aggregate the stock qty for a faster validation. 
	INSERT INTO @ValidateItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intSubLocationId
			,intStorageLocationId
			,intInventoryTransactionId	
	)
	SELECT	intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,SUM(ISNULL(dblQty, 0) * -1)				
			,intSubLocationId
			,intStorageLocationId
			,intInventoryTransactionId
	FROM	@ItemsToUnpost
	GROUP BY 
		intItemId
		, intItemLocationId
		, intItemUOMId
		, intLotId
		, intSubLocationId
		, intStorageLocationId
		, intInventoryTransactionId

	-- Fill-in the Unit qty from the UOM
	UPDATE	ValidateItemsToUnpost
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	@ValidateItemsToUnpost ValidateItemsToUnpost INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ValidateItemsToUnpost.intItemUOMId = ItemUOM.intItemUOMId

	EXEC @returnValue = dbo.uspICValidateCostingOnUnpost 
		@ValidateItemsToUnpost
		,@ysnRecap

	IF @returnValue < 0 RETURN -1;
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Call the FIFO unpost stored procedures. This is also used in Average Costing.
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostFIFOIn 
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostFIFOOut
		@strTransactionId
		,@intTransactionId
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the LIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLIFOIn 
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostLIFOOut
		@strTransactionId
		,@intTransactionId
END


-----------------------------------------------------------------------------------------------------------------------------
-- Call the LOT unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLotIn 
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostLotOut
		@strTransactionId
		,@intTransactionId
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the Actual Costing unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostActualCostIn
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostActualCostOut
		@strTransactionId
		,@intTransactionId
END

-----------------------------------------------------------------------------------------------------------------------------
-- Unpost the auto-negative gl entries
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostAutoNegative
		@strTransactionId
		,@intTransactionId
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpInventoryTransactionStockToReverse) 
BEGIN 
	-------------------------------------------------
	-- Create reversal of the inventory transactions
	-------------------------------------------------
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
			,[intTransactionDetailId]			
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
			,[intCostingMethod]
	)			
	SELECT	
			[intItemId]								= ActualTransaction.intItemId
			,[intItemLocationId]					= ActualTransaction.intItemLocationId
			,[intItemUOMId]							= ActualTransaction.intItemUOMId
			,[intSubLocationId]						= ActualTransaction.intSubLocationId
			,[intStorageLocationId]					= ActualTransaction.intStorageLocationId
			,[dtmDate]								= ActualTransaction.dtmDate
			,[dblQty]								= ActualTransaction.dblQty * -1
			,[dblUOMQty]							= ActualTransaction.dblUOMQty
			,[dblCost]								= ActualTransaction.dblCost
			,[dblValue]								= ActualTransaction.dblValue * -1
			,[dblSalesPrice]						= ActualTransaction.dblSalesPrice
			,[intCurrencyId]						= ActualTransaction.intCurrencyId
			,[dblExchangeRate]						= ActualTransaction.dblExchangeRate
			,[intTransactionId]						= ActualTransaction.intTransactionId
			,[intTransactionDetailId]				= ActualTransaction.intTransactionDetailId
			,[strTransactionId]						= ActualTransaction.strTransactionId
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= ActualTransaction.intTransactionTypeId
			,[intLotId]								= ActualTransaction.intLotId
			,[ysnIsUnposted]						= 1
			,[intRelatedInventoryTransactionId]		= ItemTransactionsToReverse.intInventoryTransactionId
			,[intRelatedTransactionId]				= ActualTransaction.intRelatedTransactionId
			,[strRelatedTransactionId]				= ActualTransaction.strRelatedTransactionId
			,[strTransactionForm]					= ActualTransaction.strTransactionForm
			,[dtmCreated]							= GETDATE()
			,[intCreatedUserId]						= @intUserId
			,[intConcurrencyId]						= 1
			,[intCostingMethod]						= ActualTransaction.intCostingMethod
	FROM	#tmpInventoryTransactionStockToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId
	
	----------------------------------------------------
	-- Create reversal of the inventory LOT transactions
	----------------------------------------------------
	DECLARE @ActiveLotStatus AS INT = 1
	INSERT INTO dbo.tblICInventoryLotTransaction (		
		[intItemId]
		,[intLotId]
		,[intLocationId]
		,[intItemLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dtmDate]
		,[dblQty]
		,[intItemUOMId]
		,[dblCost]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[strBatchId]
		,[intLotStatusId] 
		,[strTransactionForm]
		,[ysnIsUnposted]
		,[dtmCreated] 
		,[intCreatedUserId] 
		,[intConcurrencyId] 
	)
	SELECT	[intItemId]					= ActualTransaction.intItemId
			,[intLotId]					= ActualTransaction.intLotId
			,[intLocationId]			= ItemLocation.intLocationId
			,[intItemLocationId]		= ActualTransaction.intItemLocationId
			,[intSubLocationId]			= ActualTransaction.intSubLocationId
			,[intStorageLocationId]		= ActualTransaction.intStorageLocationId
			,[dtmDate]					= ActualTransaction.dtmDate
			,[dblQty]					= ActualTransaction.dblQty * -1
			,[intItemUOMId]				= ActualTransaction.intItemUOMId
			,[dblCost]					= ActualTransaction.dblCost
			,[intTransactionId]			= ActualTransaction.intTransactionId
			,[strTransactionId]			= ActualTransaction.strTransactionId
			,[intTransactionTypeId]		= ActualTransaction.intTransactionTypeId
			,[strBatchId]				= @strBatchId
			,[intLotStatusId]			= @ActiveLotStatus 
			,[strTransactionForm]		= ActualTransaction.strTransactionForm
			,[ysnIsUnposted]			= 1
			,[dtmCreated]				= GETDATE()
			,[intCreatedUserId]			= @intUserId
			,[intConcurrencyId]			= 1
	FROM	#tmpInventoryTransactionStockToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId
				AND ActualTransaction.intLotId IS NOT NULL 
				AND ActualTransaction.intItemUOMId IS NOT NULL
			INNER JOIN tblICItemLocation ItemLocation
				ON ActualTransaction.intItemLocationId = ItemLocation.intItemLocationId

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related transactions 
	--------------------------------------------------------------
	UPDATE	RelatedItemTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryTransaction RelatedItemTransactions 
	WHERE	RelatedItemTransactions.intRelatedTransactionId = @intTransactionId
			AND RelatedItemTransactions.strRelatedTransactionId = @strTransactionId
			AND RelatedItemTransactions.ysnIsUnposted = 0

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related LOT transactions 
	--------------------------------------------------------------
	UPDATE	RelatedLotTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryLotTransaction RelatedLotTransactions 
	WHERE	RelatedLotTransactions.intTransactionId = @intTransactionId
			AND RelatedLotTransactions.strTransactionId = @strTransactionId
			AND RelatedLotTransactions.ysnIsUnposted = 0

	------------------------------------------------------------
	-- Update the Stock Quantity and Average Cost
	------------------------------------------------------------
	BEGIN 
		BEGIN 
			DECLARE loopItemsToUnpost CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  intItemId 
					,intItemUOMId 
					,intItemLocationId 
					,intSubLocationId 
					,intStorageLocationId 
					,dblQty 
					,dblUOMQty 
					,dblCost
					,intLotId 
			FROM	@ItemsToUnpost

			OPEN loopItemsToUnpost;	

			-- Initial fetch attempt
			FETCH NEXT FROM loopItemsToUnpost INTO 
				@intItemId
				,@intItemUOMId
				,@intItemLocationId 
				,@intSubLocationId 
				,@intStorageLocationId 
				,@dblQty 
				,@dblUOMQty 
				,@dblCost
				,@intLotId;

			-----------------------------------------------------------------------------------------------------------------------------
			-- Start of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			WHILE @@FETCH_STATUS = 0
			BEGIN 

				-- Recalculate the average cost from the inventory transaction table. 
				UPDATE	ItemPricing
				SET		dblAverageCost = ISNULL(
							dbo.fnRecalculateAverageCost(intItemId, intItemLocationId)
							, dblAverageCost
						) 
				FROM	dbo.tblICItemPricing AS ItemPricing 
				WHERE	ItemPricing.intItemId = @intItemId
						AND ItemPricing.intItemLocationId = @intItemLocationId			

				-- Update the stock quantities on tblICItemStock and tblICItemStockUOM tables. 
				EXEC [dbo].[uspICPostStockQuantity]
					@intItemId
					,@intItemLocationId
					,@intSubLocationId
					,@intStorageLocationId
					,@intItemUOMId
					,@dblQty
					,@dblUOMQty
					,@intLotId

				FETCH NEXT FROM loopItemsToUnpost INTO 
					@intItemId
					,@intItemUOMId
					,@intItemLocationId 
					,@intSubLocationId 
					,@intStorageLocationId 
					,@dblQty 
					,@dblUOMQty 
					,@dblCost
					,@intLotId;
			END;

			-----------------------------------------------------------------------------------------------------------------------------
			-- End of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			CLOSE loopItemsToUnpost;
			DEALLOCATE loopItemsToUnpost;
		END

		-- Update the Lot's Qty and Weights. 
		UPDATE	Lot 
		SET		Lot.dblQty = dbo.fnCalculateLotQty(Lot.intItemUOMId, ItemToUnpost.intItemUOMId, Lot.dblQty, Lot.dblWeight, ItemToUnpost.dblQty, Lot.dblWeightPerQty)
				,Lot.dblWeight = dbo.fnCalculateLotWeight(Lot.intItemUOMId, Lot.intWeightUOMId, ItemToUnpost.intItemUOMId, Lot.dblWeight, ItemToUnpost.dblQty, Lot.dblWeightPerQty)
		FROM	dbo.tblICLot Lot INNER JOIN @ItemsToUnpost ItemToUnpost
					ON Lot.intItemLocationId = ItemToUnpost.intItemLocationId
					AND Lot.intLotId = ItemToUnpost.intLotId
	END
	
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
				,intInventoryTransactionId
		)
		SELECT 
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intSubLocationId
				,intStorageLocationId
				,intInventoryTransactionId
		FROM	@ItemsToUnpost
		WHERE	dbo.fnGetCostingMethod(intItemId, intItemLocationId) = @AVERAGECOST				
				AND dblQty > 0 

		SET @intInventoryTransactionId = NULL 

		SELECT	TOP 1 
				@intInventoryTransactionId	= intInventoryTransactionId
				,@intCurrencyId				= intCurrencyId
				,@dtmDate					= dtmDate
				,@dblExchangeRate			= dblExchangeRate
				,@intTransactionId			= intTransactionId
				,@strTransactionId			= strTransactionId
				,@strTransactionForm		= strTransactionForm
		FROM	dbo.tblICInventoryTransaction
		WHERE	strBatchId = @strBatchId
				AND ISNULL(ysnIsUnposted, 0) = 1 

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
						,[intCreatedUserId]
						,[intConcurrencyId]
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
					,[dblValue]								= (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
					,[dblSalesPrice]						= 0
					,[intCurrencyId]						= @intCurrencyId
					,[dblExchangeRate]						= @dblExchangeRate
					,[intTransactionId]						= @intTransactionId
					,[strTransactionId]						= @strTransactionId
					,[strBatchId]							= @strBatchId
					,[intTransactionTypeId]					= @AUTO_NEGATIVE
					,[intLotId]								= NULL 
					,[ysnIsUnposted]						= 1
					,[intRelatedInventoryTransactionId]		= NULL 
					,[intRelatedTransactionId]				= NULL 
					,[strRelatedTransactionId]				= NULL 
					,[strTransactionForm]					= @strTransactionForm
					,[dtmCreated]							= GETDATE()
					,[intCreatedUserId]						= @intUserId
					,[intConcurrencyId]						= 1
			FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
						ON ItemPricing.intItemId = Stock.intItemId
						AND ItemPricing.intItemLocationId = Stock.intItemLocationId
			WHERE	ItemPricing.intItemId = @intItemId
					AND ItemPricing.intItemLocationId = @intItemLocationId			
					AND (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) <> 0

			-- Delete the item and item-location from the table variable. 
			DELETE FROM	@ItemsForAutoNegative
			WHERE	intItemId = @intItemId 
					AND intItemLocationId = @intItemLocationId
		END 
	END

END

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
EXEC dbo.uspICCreateReversalGLEntries 
	@strBatchId
	,@intTransactionId
	,@strTransactionId
	,@intUserId
;