/*
	Used to reverse the stocks from a posted transaction.
*/
CREATE PROCEDURE [dbo].[uspICUnpostCosting]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(20)
	,@intUserId AS INT
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
		,@InventoryReceipt AS INT = 4
		,@InventoryShipment AS INT = 5

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4

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
			,intSubLocationId
			,intStorageLocationId			
	)
	SELECT	ItemTrans.intItemId
			,ItemTrans.intItemLocationId
			,ItemTrans.intItemUOMId
			,ItemTrans.intLotId
			,SUM(ISNULL(ItemTrans.dblQty, 0) * -1)			
			,intSubLocationId
			,intStorageLocationId
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
	EXEC dbo.uspICValidateCostingOnUnpost @ItemsToUnpost
END 

-- Get the transaction type 
DECLARE @TransactionType AS INT 
SELECT TOP 1 
		@TransactionType = intTransactionTypeId
FROM	dbo.tblICInventoryTransaction
WHERE	intTransactionId = @intTransactionId
		AND strTransactionId = @strTransactionId

-----------------------------------------------------------------------------------------------------------------------------
-- Call the FIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Reverse the "IN" qty 
	IF @TransactionType IN (@InventoryReceipt)
	BEGIN 
		EXEC dbo.uspICUnpostFIFOIn 
			@strTransactionId
			,@intTransactionId
	END

	-- Reverse the "OUT" qty 
	IF @TransactionType IN (@InventoryShipment)
	BEGIN 
		EXEC dbo.uspICUnpostFIFOOut
			@strTransactionId
			,@intTransactionId
	END
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the LIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Reverse the "IN" qty 
	IF @TransactionType IN (@InventoryReceipt)
	BEGIN 
		EXEC dbo.uspICUnpostLIFOIn 
			@strTransactionId
			,@intTransactionId
	END

	-- Reverse the "OUT" qty 
	IF @TransactionType IN (@InventoryShipment)
	BEGIN 
		EXEC dbo.uspICUnpostLIFOOut
			@strTransactionId
			,@intTransactionId
	END
END


-----------------------------------------------------------------------------------------------------------------------------
-- Call the LOT unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Reverse the "IN" qty 
	IF @TransactionType IN (@InventoryReceipt)
	BEGIN 
		EXEC dbo.uspICUnpostLotIn 
			@strTransactionId
			,@intTransactionId
	END

	-- Reverse the "OUT" qty 
	IF @TransactionType IN (@InventoryShipment)
	BEGIN 
		EXEC dbo.uspICUnpostLotOut
			@strTransactionId
			,@intTransactionId
	END
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

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related transactions 
	--------------------------------------------------------------
	UPDATE	RelatedItemTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryTransaction RelatedItemTransactions 
	WHERE	RelatedItemTransactions.intRelatedTransactionId = @intTransactionId
			AND RelatedItemTransactions.strRelatedTransactionId = @strTransactionId
			AND RelatedItemTransactions.ysnIsUnposted = 0

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

		-- Update the Unit On Hand at the Item Stock table
		UPDATE	Stock
		SET		Stock.dblUnitOnHand = Stock.dblUnitOnHand +  ItemToUnpost.dblUnpostQty
		FROM	dbo.tblICItemStock AS Stock INNER JOIN (
					SELECT	intItemId
							,intItemLocationId
							,dblUnpostQty = SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty))
					FROM	@ItemsToUnpost 
					GROUP BY intItemId, intItemLocationId				
				) ItemToUnpost
					ON Stock.intItemId = ItemToUnpost.intItemId
					AND Stock.intItemLocationId = ItemToUnpost.intItemLocationId

		-- Update the Stock UOM
		UPDATE	StockUOM
		SET		StockUOM.dblOnHand = StockUOM.dblOnHand  +  ItemToUnpost.dblUnpostQty
		FROM	dbo.tblICItemStockUOM AS StockUOM INNER JOIN (
					SELECT	intItemId
							,intItemLocationId
							,intItemUOMId
							,intSubLocationId
							,intStorageLocationId
							,dblUnpostQty = SUM(ISNULL(dblQty, 0))
					FROM	@ItemsToUnpost 
					GROUP BY intItemId, intItemLocationId, intItemUOMId, intSubLocationId, intStorageLocationId
				) ItemToUnpost
					ON StockUOM.intItemId = ItemToUnpost.intItemId
					AND StockUOM.intItemLocationId = ItemToUnpost.intItemLocationId
					AND StockUOM.intItemUOMId = ItemToUnpost.intItemUOMId
					AND ISNULL(StockUOM.intSubLocationId, 0) =  ISNULL(ItemToUnpost.intSubLocationId, 0)
					AND ISNULL(StockUOM.intStorageLocationId, 0) =  ISNULL(ItemToUnpost.intStorageLocationId, 0)

		-- Update the stock quantity and weight at the Lot table (Two parts)
		-- 1 of 2: Calculate in favor of qty. 
		UPDATE	Lot
		SET		Lot.dblQty = ISNULL(Lot.dblQty, 0) + ItemToUnpost.dblQty
				,Lot.dblWeight = ISNULL(Lot.dblWeight, 0) + (ItemToUnpost.dblQty * ISNULL(Lot.dblWeightPerQty, 0)) 
		FROM	dbo.tblICLot Lot INNER JOIN @ItemsToUnpost ItemToUnpost
					ON Lot.intItemLocationId = ItemToUnpost.intItemLocationId
					AND Lot.intLotId = ItemToUnpost.intLotId
					AND Lot.intItemUOMId = ItemToUnpost.intItemUOMId
		-- 2 of 2: Calculate in favor of weights. 
		UPDATE	Lot
		SET		Lot.dblWeight = ISNULL(Lot.dblWeight, 0) + ItemToUnpost.dblQty
				,Lot.dblQty = ISNULL(Lot.dblQty, 0) + CASE WHEN ISNULL(Lot.dblWeightPerQty, 0) = 0 THEN 0 ELSE ISNULL(ItemToUnpost.dblQty, 0) / ISNULL(Lot.dblWeightPerQty, 0) END 
		FROM	dbo.tblICLot Lot INNER JOIN @ItemsToUnpost ItemToUnpost
					ON Lot.intItemLocationId = ItemToUnpost.intItemLocationId
					AND Lot.intLotId = ItemToUnpost.intLotId					
					AND ISNULL(Lot.intWeightUOMId, 0) = ItemToUnpost.intItemUOMId
					AND Lot.intItemUOMId <> ItemToUnpost.intItemUOMId
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
				,[dtmDate]								= TransactionToReverse.dtmDate
				,[dblQty]								= 0
				,[dblUOMQty]							= 0
				,[dblCost]								= 0
				,[dblValue]								= (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(ItemToUnpost.intItemId, ItemToUnpost.intItemLocationId)
				,[dblSalesPrice]						= 0
				,[intCurrencyId]						= TransactionToReverse.intCurrencyId
				,[dblExchangeRate]						= TransactionToReverse.dblExchangeRate
				,[intTransactionId]						= TransactionToReverse.intTransactionId
				,[strTransactionId]						= TransactionToReverse.strTransactionId
				,[strBatchId]							= @strBatchId
				,[intTransactionTypeId]					= @AUTO_NEGATIVE
				,[intLotId]								= ItemToUnpost.intLotId
				,[ysnIsUnposted]						= 0
				,[intRelatedInventoryTransactionId]		= NULL 
				,[intRelatedTransactionId]				= NULL 
				,[strRelatedTransactionId]				= NULL 
				,[strTransactionForm]					= TransactionToReverse.strTransactionForm
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
				,(
					SELECT TOP 1
							ItemTransaction.dtmDate
							,ItemTransaction.intCurrencyId
							,ItemTransaction.dblExchangeRate
							,ItemTransaction.intTransactionId
							,ItemTransaction.strTransactionId
							,ItemTransaction.strTransactionForm
					FROM	#tmpInventoryTransactionStockToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ItemTransaction
								ON ItemTransactionsToReverse.intInventoryTransactionId = ItemTransaction.intInventoryTransactionId
					WHERE	ItemTransaction.intTransactionId = @intTransactionId
							AND ItemTransaction.strTransactionId = @strTransactionId
				) TransactionToReverse 
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