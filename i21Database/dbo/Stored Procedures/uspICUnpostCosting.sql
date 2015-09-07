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

-- Get the list of items to unpost
BEGIN 
	-- Insert the items per location, UOM, and if it exists, Lot
	INSERT INTO @ItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			--,dblUOMQty
			,intSubLocationId
			,intStorageLocationId			
	)
	SELECT	ItemTrans.intItemId
			,ItemTrans.intItemLocationId
			,ItemTrans.intItemUOMId
			,ItemTrans.intLotId
			,SUM(ISNULL(ItemTrans.dblQty, 0) * -1)	
			--,ItemTrans.dblUOMQty		
			,ItemTrans.intSubLocationId
			,ItemTrans.intStorageLocationId
	FROM	dbo.tblICInventoryTransaction ItemTrans
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0
	GROUP BY ItemTrans.intItemId, ItemTrans.intItemLocationId, ItemTrans.intItemUOMId, ItemTrans.intLotId, ItemTrans.intSubLocationId, ItemTrans.intStorageLocationId

	-- Fill-in the Unit qty from the UOM
	UPDATE	ItemToUnpost
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	@ItemsToUnpost ItemToUnpost INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ItemToUnpost.intItemUOMId = ItemUOM.intItemUOMId
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICValidateCostingOnUnpost 
		@ItemsToUnpost
		,@ysnRecap
END 

---- Get the transaction type 
--DECLARE @TransactionType AS INT 
--SELECT TOP 1 
--		@TransactionType = intTransactionTypeId
--FROM	dbo.tblICInventoryTransaction
--WHERE	intTransactionId = @intTransactionId
--		AND strTransactionId = @strTransactionId

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

	---------------------------------------------------
	-- Calculate the new average cost (if applicable)
	---------------------------------------------------
	BEGIN 
		-- Update the avearge cost at the Item Pricing table
		UPDATE	ItemPricing
		SET		dblAverageCost = CASE		WHEN ISNULL(Stock.dblUnitOnHand, 0) +  dbo.fnCalculateStockUnitQty(ItemToUnpost.dblQty, ItemToUnpost.dblUOMQty) > 0 THEN 
													-- Recalculate the average cost
													dbo.fnRecalculateAverageCost(ItemToUnpost.intItemId, ItemToUnpost.intItemLocationId, ItemPricing.dblAverageCost) 
												ELSE 
													-- Use the same average cost. 
													ItemPricing.dblAverageCost
										END
		FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
					ON ItemPricing.intItemId = Stock.intItemId
					AND ItemPricing.intItemLocationId = Stock.intItemLocationId		
				INNER JOIN @ItemsToUnpost ItemToUnpost
					ON Stock.intItemId = ItemToUnpost.intItemId
					AND Stock.intItemLocationId = ItemToUnpost.intItemLocationId

		------------------------------------------------------------
		-- Update the Stock Quantity
		------------------------------------------------------------
		BEGIN 
			DECLARE @intItemId AS INT
					,@intItemUOMId AS INT 
					,@intItemLocationId AS INT 
					,@intSubLocationId AS INT
					,@intStorageLocationId AS INT 					
					,@dblQty AS NUMERIC(18, 6) 
					,@dblUOMQty AS NUMERIC(18, 6)
					,@intLotId AS INT

			DECLARE loopItems CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  intItemId 
					,intItemUOMId 
					,intItemLocationId 
					,intSubLocationId 
					,intStorageLocationId 
					,dblQty 
					,dblUOMQty 
					,intLotId 
			FROM	@ItemsToUnpost

			OPEN loopItems;	

			-- Initial fetch attempt
			FETCH NEXT FROM loopItems INTO 
				@intItemId
				,@intItemUOMId
				,@intItemLocationId 
				,@intSubLocationId 
				,@intStorageLocationId 
				,@dblQty 
				,@dblUOMQty 
				,@intLotId;

			-----------------------------------------------------------------------------------------------------------------------------
			-- Start of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			WHILE @@FETCH_STATUS = 0
			BEGIN 
				EXEC [dbo].[uspICPostStockQuantity]
					@intItemId
					,@intItemLocationId
					,@intSubLocationId
					,@intStorageLocationId
					,@intItemUOMId
					,@dblQty
					,@dblUOMQty
					,@intLotId

				FETCH NEXT FROM loopItems INTO 
					@intItemId
					,@intItemUOMId
					,@intItemLocationId 
					,@intSubLocationId 
					,@intStorageLocationId 
					,@dblQty 
					,@dblUOMQty 
					,@intLotId;
			END;

			-----------------------------------------------------------------------------------------------------------------------------
			-- End of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			CLOSE loopItems;
			DEALLOCATE loopItems;
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
				[intItemId]								= ItemToUnpost.intItemId
				,[intItemLocationId]					= ItemToUnpost.intItemLocationId
				,[intItemUOMId]							= ItemToUnpost.intItemUOMId
				,[intSubLocationId]						= ItemToUnpost.intSubLocationId
				,[intStorageLocationId]					= ItemToUnpost.intStorageLocationId
				,[dtmDate]								= InvTrans.dtmDate
				,[dblQty]								= 0
				,[dblUOMQty]							= 0
				,[dblCost]								= 0
				,[dblValue]								= (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(ItemToUnpost.intItemId, ItemToUnpost.intItemLocationId)
				,[dblSalesPrice]						= 0
				,[intCurrencyId]						= InvTrans.intCurrencyId
				,[dblExchangeRate]						= InvTrans.dblExchangeRate
				,[intTransactionId]						= InvTrans.intTransactionId
				,[strTransactionId]						= InvTrans.strTransactionId
				,[strBatchId]							= @strBatchId
				,[intTransactionTypeId]					= @AUTO_NEGATIVE
				,[intLotId]								= ItemToUnpost.intLotId
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
				INNER JOIN @ItemsToUnpost ItemToUnpost
						ON Stock.intItemId = ItemToUnpost.intItemId
						AND Stock.intItemLocationId = ItemToUnpost.intItemLocationId
						AND dbo.fnGetCostingMethod(ItemToUnpost.intItemId, ItemToUnpost.intItemLocationId) = @AVERAGECOST
				INNER JOIN (
					SELECT	DISTINCT 
							intItemId
							,intItemLocationId
					FROM	dbo.tblICInventoryTransaction
					WHERE	intTransactionId = @intTransactionId
							AND strTransactionId = @strTransactionId
							-- AND intCostingMethod = @AVERAGECOST
				) InvItemsToReverse
					ON InvItemsToReverse.intItemId = ItemToUnpost.intItemId 
					AND InvItemsToReverse.intItemLocationId = ItemToUnpost.intItemLocationId 
				,(
					SELECT	TOP 1 
							*
					FROM	dbo.tblICInventoryTransaction InvTrans
					WHERE	intTransactionId = @intTransactionId
							AND strTransactionId = @strTransactionId
				) InvTrans
		WHERE	(Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(ItemToUnpost.intItemId, ItemToUnpost.intItemLocationId) <> 0
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

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
	DROP TABLE #tmpInventoryTransactionStockToReverse