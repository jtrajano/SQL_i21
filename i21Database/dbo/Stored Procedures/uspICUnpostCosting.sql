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

-- Create the variables for the internal transaction types used by costing. 
DECLARE @WRITE_OFF_SOLD AS INT = -1;
DECLARE @REVALUE_SOLD AS INT = -2;
DECLARE @AUTO_NEGATIVE AS INT = -3;

DECLARE @ItemsToUnpost AS dbo.UnpostItemsTableType

DECLARE @InventoryAdjustment AS INT = 1
		,@InventoryReceipt AS INT = 2
		,@InventoryShipment AS INT = 3

-- Get the list of items to unpost
BEGIN 
	INSERT INTO @ItemsToUnpost (
			intItemId
			,intLocationId
			,dblTotalQty
	)
	SELECT	ItemTrans.intItemId
			,ItemTrans.intLocationId
			,SUM(ISNULL(ItemTrans.dblUnitQty, 0) * -1)
	FROM	dbo.tblICInventoryTransaction ItemTrans
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
	GROUP BY ItemTrans.intItemId, ItemTrans.intLocationId
END 
-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICValidateCostingOnUnpost @ItemsToUnpost
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Call the FIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @TransactionType AS INT 
	DECLARE @InventoryTransactionToReverse AS dbo.InventoryTranactionStockToReverse

	-- Get the transaction type 
	SELECT TOP 1 
			@TransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransaction
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId

	-- Reverse the "IN" qty 
	IF @TransactionType IN (@InventoryAdjustment, @InventoryReceipt)
	BEGIN 
		INSERT INTO @InventoryTransactionToReverse 
		EXEC dbo.uspICUnpostFIFOIn 
			@strTransactionId
			,@intTransactionId
	END

	-- Reverse the "OUT" qty 
	IF @TransactionType IN (@InventoryAdjustment, @InventoryShipment)
	BEGIN 
		INSERT INTO @InventoryTransactionToReverse
		EXEC dbo.uspICUnpostFIFOOut
			@strTransactionId
			,@intTransactionId
	END
END

IF EXISTS (SELECT TOP 1 1 FROM @InventoryTransactionToReverse) 
BEGIN 
	-------------------------------------------------
	-- Create reversal of the inventory transactions
	-------------------------------------------------
	INSERT INTO dbo.tblICInventoryTransaction (
			[intItemId]
			,[intLocationId] 
			,[dtmDate] 
			,[dblUnitQty] 
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
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 
	)			
	SELECT	[intItemId]				= ActualTransaction.intItemId
			,[intLocationId]		= ActualTransaction.intLocationId
			,[dtmDate]				= ActualTransaction.dtmDate
			,[dblUnitQty]			= ActualTransaction.dblUnitQty * -1
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
			,[dtmCreated]			= GETDATE()
			,[intCreatedUserId]		= @intUserId
			,[intConcurrencyId]		= 1
	FROM	@InventoryTransactionToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related transactions 
	--------------------------------------------------------------
	UPDATE	RelatedItemTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryTransaction RelatedItemTransactions 
	WHERE	RelatedItemTransactions.intRelatedInventoryTransactionId = @intTransactionId
			AND RelatedItemTransactions.strRelatedInventoryTransactionId = @strTransactionId
			AND RelatedItemTransactions.ysnIsUnposted = 0

	---------------------------------------------------
	-- Calculate the new average cost (if applicable)
	---------------------------------------------------
	BEGIN 
		UPDATE	Stock
		SET		Stock.dblAverageCost = CASE		WHEN ISNULL(Stock.dblUnitOnHand, 0) + ItemToUnpost.dblTotalQty > 0 THEN 
													-- Recalculate the average cost
													dbo.fnRecalculateAverageCost(Stock.intItemId, Stock.intLocationId) 
												ELSE 
													-- Use the same average cost. 
													Stock.dblAverageCost
										END 
				,Stock.dblUnitOnHand = Stock.dblUnitOnHand + ItemToUnpost.dblTotalQty
				,Stock.intConcurrencyId = ISNULL(Stock.intConcurrencyId, 0) + 1 
		FROM	dbo.tblICItemStock AS Stock INNER JOIN @ItemsToUnpost ItemToUnpost
					ON Stock.intItemId = ItemToUnpost.intItemId
					AND Stock.intLocationId = ItemToUnpost.intLocationId
	END

	-----------------------------
	-- Create the AUTO-Negative
	-----------------------------
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (
				[intItemId] 
				,[intLocationId] 
				,[dtmDate] 
				,[dblUnitQty] 
				,[dblCost] 
				,[dblValue]
				,[dblSalesPrice] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[intTransactionId] 
				,[strTransactionId] 
				,[strBatchId] 
				,[intTransactionTypeId] 
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId] 
		)
		SELECT	[intItemId] = ItemToUnpost.intItemId
				,[intLocationId] = ItemToUnpost.intLocationId
				,[dtmDate] = TransactionToReverse.dtmDate
				,[dblUnitQty] = 0
				,[dblCost] = 0
				,[dblValue] = (Stock.dblUnitOnHand * Stock.dblAverageCost) - [dbo].[fnGetItemTotalValueFromTransactions](Stock.intItemId, Stock.intLocationId)
				,[dblSalesPrice] = 0
				,[intCurrencyId] = TransactionToReverse.intCurrencyId
				,[dblExchangeRate] = TransactionToReverse.dblExchangeRate
				,[intTransactionId] = TransactionToReverse.intTransactionId
				,[strTransactionId] = TransactionToReverse.strTransactionId
				,[strBatchId] = @strBatchId
				,[intTransactionTypeId] = @AUTO_NEGATIVE
				,[dtmCreated] = GETDATE()
				,[intCreatedUserId] = @intUserId
				,[intConcurrencyId] = 1
		FROM	dbo.tblICItemStock AS Stock INNER JOIN @ItemsToUnpost ItemToUnpost
						ON Stock.intItemId = ItemToUnpost.intItemId
						AND Stock.intLocationId = ItemToUnpost.intLocationId
				,(
					SELECT TOP 1
							ItemTransaction.dtmDate
							,ItemTransaction.intCurrencyId
							,ItemTransaction.dblExchangeRate
							,ItemTransaction.intTransactionId
							,ItemTransaction.strTransactionId
					FROM	@InventoryTransactionToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ItemTransaction
								ON ItemTransactionsToReverse.intInventoryTransactionId = ItemTransaction.intInventoryTransactionId
					WHERE	ItemTransaction.intTransactionId = @intTransactionId
							AND ItemTransaction.strTransactionId = @strTransactionId
				) TransactionToReverse 
		WHERE	(Stock.dblUnitOnHand * Stock.dblAverageCost) - [dbo].[fnGetItemTotalValueFromTransactions](Stock.intItemId, Stock.intLocationId) <> 0
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