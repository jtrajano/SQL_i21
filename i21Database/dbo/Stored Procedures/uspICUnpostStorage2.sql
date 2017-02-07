/*
	Used to reverse the stocks from a posted transaction.
*/
CREATE PROCEDURE [dbo].[uspICUnpostStorage]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
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
	intInventoryTransactionStorageId INT NOT NULL 
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
DECLARE @DecreaseOnStorageQty AS ItemCostingTableType

DECLARE @intItemId AS INT
		,@intItemUOMId AS INT 
		,@intItemLocationId AS INT 
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 					
		,@dblQty AS NUMERIC(38,20) 
		,@dblUOMQty AS NUMERIC(38,20)
		,@dblCost AS NUMERIC(38,20)
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
			,ItemTrans.intInventoryTransactionStorageId
	FROM	dbo.tblICInventoryTransactionStorage ItemTrans
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0
			AND ISNULL(ItemTrans.dblQty, 0) <> 0 
	
	INSERT INTO @DecreaseOnStorageQty (
		intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intItemUOMId
		, dtmDate
		, dblQty
		, dblUOMQty
		, dblCost
		, dblValue
		, dblSalesPrice
		, dblExchangeRate
		, intTransactionId
		, strTransactionId 
		, intTransactionTypeId
	)
	SELECT 		
		intItemId
		, intItemLocationId
		, intSubLocationId
		, intStorageLocationId
		, intItemUOMId
		, dtmDate
		, dblQty * -1
		, dblUOMQty
		, dblCost
		, dblValue
		, dblSalesPrice
		, dblExchangeRate
		, intTransactionId
		, strTransactionId 
		, intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionStorage ItemTrans
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0
			AND dblQty <> 0
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
			,SUM(ISNULL(dblQty, 0))				
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

	EXEC @returnValue = dbo.uspICValidateCostingOnUnpostStorage 
		@ValidateItemsToUnpost
		,@ysnRecap

	IF @returnValue < 0 RETURN -1;
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Call the FIFO unpost stored procedures. This is also used in Average Costing.
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostFIFOInFromStorage
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostFIFOOutFromStorage
		@strTransactionId
		,@intTransactionId
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the LIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLIFOInFromStorage 
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostLIFOOutFromStorage
		@strTransactionId
		,@intTransactionId
END


-----------------------------------------------------------------------------------------------------------------------------
-- Call the LOT unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLotInFromStorage 
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostLotOutFromStorage
		@strTransactionId
		,@intTransactionId
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpInventoryTransactionStockToReverse) 
BEGIN 
	-------------------------------------------------
	-- Create reversal of the inventory transactions
	-------------------------------------------------
	INSERT INTO dbo.tblICInventoryTransactionStorage (
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
			,[intCreatedEntityId]
			,[intConcurrencyId]
			,[intCostingMethod]
			,[intForexRateTypeId]
			,[dblForexRate]
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
			,[intRelatedInventoryTransactionId]		= ItemTransactionsToReverse.intInventoryTransactionStorageId
			,[intRelatedTransactionId]				= ActualTransaction.intRelatedTransactionId
			,[strRelatedTransactionId]				= ActualTransaction.strRelatedTransactionId
			,[strTransactionForm]					= ActualTransaction.strTransactionForm
			,[dtmCreated]							= GETDATE()
			,[intCreatedEntityId]					= @intEntityUserSecurityId
			,[intConcurrencyId]						= 1
			,[intCostingMethod]						= ActualTransaction.intCostingMethod
			,[intForexRateTypeId]					= ActualTransaction.intForexRateTypeId
			,[dblForexRate]							= ActualTransaction.dblForexRate
	FROM	#tmpInventoryTransactionStockToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransactionStorage ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionStorageId = ActualTransaction.intInventoryTransactionStorageId
	
	----------------------------------------------------
	-- Create reversal of the inventory LOT transactions
	----------------------------------------------------
	DECLARE @ActiveLotStatus AS INT = 1
	INSERT INTO dbo.tblICInventoryLotTransactionStorage (		
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
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[strBatchId]
		,[intLotStatusId] 
		,[strTransactionForm]
		,[ysnIsUnposted]
		,[dtmCreated] 
		,[intCreatedEntityId] 
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
			,[intTransactionDetailId]	= ActualTransaction.intTransactionDetailId
			,[strTransactionId]			= ActualTransaction.strTransactionId
			,[intTransactionTypeId]		= ActualTransaction.intTransactionTypeId
			,[strBatchId]				= @strBatchId
			,[intLotStatusId]			= @ActiveLotStatus 
			,[strTransactionForm]		= ActualTransaction.strTransactionForm
			,[ysnIsUnposted]			= 1
			,[dtmCreated]				= GETDATE()
			,[intCreatedEntityId]			= @intEntityUserSecurityId
			,[intConcurrencyId]			= 1
	FROM	#tmpInventoryTransactionStockToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransactionStorage ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionStorageId = ActualTransaction.intInventoryTransactionStorageId
				AND ActualTransaction.intLotId IS NOT NULL 
				AND ActualTransaction.intItemUOMId IS NOT NULL
			INNER JOIN tblICItemLocation ItemLocation
				ON ActualTransaction.intItemLocationId = ItemLocation.intItemLocationId

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related transactions 
	--------------------------------------------------------------
	UPDATE	RelatedItemTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryTransactionStorage RelatedItemTransactions 
	WHERE	RelatedItemTransactions.intRelatedTransactionId = @intTransactionId
			AND RelatedItemTransactions.strRelatedTransactionId = @strTransactionId
			AND RelatedItemTransactions.ysnIsUnposted = 0

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related LOT transactions 
	--------------------------------------------------------------
	UPDATE	RelatedLotTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryLotTransactionStorage RelatedLotTransactions 
	WHERE	RelatedLotTransactions.intTransactionId = @intTransactionId
			AND RelatedLotTransactions.strTransactionId = @strTransactionId
			AND RelatedLotTransactions.ysnIsUnposted = 0

	------------------------------------------
	-- Update the Lot's Qty and Weights. 
	------------------------------------------
	UPDATE	Lot 
	SET		Lot.dblQty = dbo.fnCalculateLotQty(Lot.intItemUOMId, ItemToUnpost.intItemUOMId, Lot.dblQty, Lot.dblWeight, ItemToUnpost.dblQty, Lot.dblWeightPerQty)
			,Lot.dblWeight = dbo.fnCalculateLotWeight(Lot.intItemUOMId, Lot.intWeightUOMId, ItemToUnpost.intItemUOMId, Lot.dblWeight, ItemToUnpost.dblQty, Lot.dblWeightPerQty)
	FROM	dbo.tblICLot Lot INNER JOIN @ItemsToUnpost ItemToUnpost
				ON Lot.intItemLocationId = ItemToUnpost.intItemLocationId
				AND Lot.intLotId = ItemToUnpost.intLotId
END

-----------------------------------
-- Update the Item Stock table
-----------------------------------
BEGIN 
	EXEC uspICIncreaseOnStorageQty
		@DecreaseOnStorageQty
END
;