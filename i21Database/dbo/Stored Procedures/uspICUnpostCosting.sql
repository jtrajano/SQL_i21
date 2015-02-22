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
	-- Insert the items per location and UOM
	INSERT INTO @ItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dblQty
			
	)
	SELECT	ItemTrans.intItemId
			,ItemTrans.intItemLocationId
			,ItemTrans.intItemUOMId
			,SUM(ISNULL(ItemTrans.dblQty, 0) * -1)			
	FROM	dbo.tblICInventoryTransaction ItemTrans
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0
	GROUP BY ItemTrans.intItemId, ItemTrans.intItemLocationId, ItemTrans.intItemUOMId

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
			,[ysnIsUnposted]
			,[intRelatedInventoryTransactionId]
			,[intRelatedTransactionId]
			,[strRelatedTransactionId]
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 
	)			
	SELECT	[intItemId]				= ActualTransaction.intItemId
			,[intItemLocationId]	= ActualTransaction.intItemLocationId
			,[intItemUOMId]			= ActualTransaction.intItemUOMId
			,[dtmDate]				= ActualTransaction.dtmDate
			,[dblQty]				= ActualTransaction.dblQty * -1
			,[dblUOMQty]			= ActualTransaction.dblUOMQty
			,[dblCost]				= ActualTransaction.dblCost 
			,[dblValue]				= ActualTransaction.dblValue * -1			
			,[dblSalesPrice]		= ActualTransaction.dblSalesPrice
			,[intCurrencyId]		= ActualTransaction.intCurrencyId
			,[dblExchangeRate]		= ActualTransaction.dblExchangeRate
			,[intTransactionId]		= ActualTransaction.intTransactionId
			,[strTransactionId]		= ActualTransaction.strTransactionId
			,[strBatchId]			= @strBatchId
			,[intTransactionTypeId] = ActualTransaction.intTransactionTypeId
			,[ysnIsUnposted]		= 1
			,[intRelatedInventoryTransactionId] = ItemTransactionsToReverse.intInventoryTransactionId
			,[intRelatedTransactionId] = ActualTransaction.intRelatedTransactionId
			,[strRelatedTransactionId] = ActualTransaction.strRelatedTransactionId
			,[dtmCreated]			= GETDATE()
			,[intCreatedUserId]		= @intUserId
			,[intConcurrencyId]		= 1
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
		SET		dblAverageCost = CASE		WHEN ISNULL(Stock.dblUnitOnHand, 0) + (ISNULL(ItemToUnpost.dblQty, 0) * ISNULL(ItemToUnpost.dblUOMQty, 0)) > 0 THEN 
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
		SET		Stock.dblUnitOnHand = Stock.dblUnitOnHand + (ISNULL(ItemToUnpost.dblQty, 0) * ISNULL(ItemToUnpost.dblUOMQty, 0))
		FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
					ON ItemPricing.intItemId = Stock.intItemId
					AND ItemPricing.intItemLocationId = Stock.intItemLocationId		
				INNER JOIN @ItemsToUnpost ItemToUnpost
					ON Stock.intItemId = ItemToUnpost.intItemId
					AND Stock.intItemLocationId = ItemToUnpost.intItemLocationId

	END

	---------------------------------------------------------------------------------------
	-- Create the AUTO-Negative if costing method is average costing
	---------------------------------------------------------------------------------------
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (
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
				,[strTransactionId] 
				,[strTransactionForm] 
				,[strBatchId] 
				,[intTransactionTypeId] 
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
				,[ysnIsUnposted]
		)
		SELECT	[intItemId] = ItemToUnpost.intItemId
				,[intItemLocationId] = ItemToUnpost.intItemLocationId
				,[intItemUOMId] = ItemToUnpost.intItemUOMId 
				,[dtmDate] = TransactionToReverse.dtmDate
				,[dblQty] = 0
				,[dblUOMQty] = 0
				,[dblCost] = 0
				,[dblValue] = (Stock.dblUnitOnHand * ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(ItemToUnpost.intItemId, ItemToUnpost.intItemLocationId)				
				,[dblSalesPrice] = 0
				,[intCurrencyId] = TransactionToReverse.intCurrencyId
				,[dblExchangeRate] = TransactionToReverse.dblExchangeRate
				,[intTransactionId] = TransactionToReverse.intTransactionId
				,[strTransactionId] = TransactionToReverse.strTransactionId
				,[strTransactionForm] = TransactionToReverse.strTransactionForm
				,[strBatchId] = @strBatchId
				,[intTransactionTypeId] = @AUTO_NEGATIVE
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = @intUserId
				,[intConcurrencyId] = 1
				,[ysnIsUnposted] = 0
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