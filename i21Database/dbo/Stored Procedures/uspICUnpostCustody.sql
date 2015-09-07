/*
	Used to reverse the stocks from a posted transaction.
*/
CREATE PROCEDURE [dbo].[uspICUnpostCustody]
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

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
BEGIN 
	CREATE TABLE #tmpInventoryTransactionStockToReverse (
		intInventoryTransactionInCustodyId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intTransactionTypeId INT NOT NULL 
		,intInventoryCostBucketInCustodyId INT 
		,dblQty NUMERIC(38,20)
	)
END 

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4

DECLARE @ItemsToUnpost AS dbo.UnpostItemsTableType

-- Get the list of items to unpost
BEGIN 
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
	FROM	dbo.tblICInventoryTransactionInCustody ItemTrans
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
	EXEC dbo.uspICValidateCostingOnUnpostInCustody 
		@ItemsToUnpost
		,@ysnRecap 
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Call the FIFO unpost stored procedures. This is also used in Average Costing.
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostFIFOInFromCustody
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostFIFOOutFromCustody
		@strTransactionId
		,@intTransactionId
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the LIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLIFOInFromCustody
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostLIFOOutFromCustody
		@strTransactionId
		,@intTransactionId
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Call the LOT unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLotInFromCustody
		@strTransactionId
		,@intTransactionId

	EXEC dbo.uspICUnpostLotOutFromCustody
		@strTransactionId
		,@intTransactionId
END

-- Validate if there is something to reverse. 
IF NOT EXISTS (
	SELECT	TOP 1 1 
	FROM	#tmpInventoryTransactionStockToReverse 
)
BEGIN 
	-- 'A consigned or custodial item is no longer available. Unable to continue and unpost the transaction.'
	RAISERROR(51135, 11, 1)
	GOTO _Exit
END 

-- Create the reversal 
BEGIN 
	-------------------------------------------------
	-- Create reversal of the inventory transactions
	-------------------------------------------------
	INSERT INTO dbo.tblICInventoryTransactionInCustody (
			[intItemId]
			,[intItemLocationId] 
			,[intItemUOMId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intLotId]
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
			,[intInventoryCostBucketInCustodyId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[ysnIsUnposted] 
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
			,[intLotId]								= ActualTransaction.intLotId
			,[dtmDate]								= ActualTransaction.dtmDate
			,[dblQty]								= ActualTransaction.dblQty * -1
			,[dblUOMQty]							= ActualTransaction.dblUOMQty
			,[dblCost]								= ActualTransaction.dblCost
			,[dblValue]								= ActualTransaction.dblValue
			,[dblSalesPrice]						= ActualTransaction.dblSalesPrice
			,[intCurrencyId]						= ActualTransaction.intCurrencyId
			,[dblExchangeRate]						= ActualTransaction.dblExchangeRate
			,[intTransactionId]						= ActualTransaction.intTransactionId
			,[intTransactionDetailId]				= ActualTransaction.intTransactionDetailId
			,[strTransactionId]						= ActualTransaction.strTransactionId
			,[intInventoryCostBucketInCustodyId]	= ActualTransaction.intInventoryCostBucketInCustodyId
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= ActualTransaction.intTransactionTypeId
			,[ysnIsUnposted]						= 1
			,[strTransactionForm]					= ActualTransaction.strTransactionForm
			,[dtmCreated]							= GETDATE()
			,[intCreatedUserId]						= @intUserId
			,[intConcurrencyId]						= 1
	FROM	#tmpInventoryTransactionStockToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransactionInCustody ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionInCustodyId = ActualTransaction.intInventoryTransactionInCustodyId	

	------------------------------------------------------
	-- Create reversal of the inventory LOT transactions
	------------------------------------------------------
	DECLARE @ActiveLotStatus AS INT = 1
	INSERT INTO dbo.tblICInventoryLotTransactionInCustody (
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
			,[intInventoryCostBucketInCustodyId] 
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 
	)
	SELECT 	[intItemId]								= ActualTransaction.intItemId
			,[intLotId]								= ActualTransaction.intLotId
			,[intLocationId]						= ItemLocation.intLocationId
			,[intItemLocationId]					= ActualTransaction.intItemLocationId
			,[intSubLocationId]						= ActualTransaction.intSubLocationId
			,[intStorageLocationId]					= ActualTransaction.intStorageLocationId
			,[dtmDate]								= ActualTransaction.dtmDate
			,[dblQty]								= ActualTransaction.dblQty * -1
			,[intItemUOMId]							= ActualTransaction.intItemUOMId
			,[dblCost]								= ActualTransaction.dblCost
			,[intTransactionId]						= ActualTransaction.intTransactionId
			,[strTransactionId]						= ActualTransaction.strTransactionId
			,[intTransactionTypeId]					= ActualTransaction.intTransactionTypeId
			,[strBatchId]							= @strBatchId
			,[intLotStatusId]						= @ActiveLotStatus
			,[strTransactionForm]					= ActualTransaction.strTransactionForm
			,[ysnIsUnposted]						= 1
			,[intInventoryCostBucketInCustodyId]	= ActualTransaction.intInventoryCostBucketInCustodyId
			,[dtmCreated]							= GETDATE()
			,[intCreatedUserId]						= @intUserId
			,[intConcurrencyId]						= 1
	FROM	#tmpInventoryTransactionStockToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransactionInCustody ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionInCustodyId = ActualTransaction.intInventoryTransactionInCustodyId	
				AND ActualTransaction.intLotId IS NOT NULL 
				AND ActualTransaction.intItemUOMId IS NOT NULL
			INNER JOIN tblICItemLocation ItemLocation
				ON ActualTransaction.intItemLocationId = ItemLocation.intItemLocationId
END

_Exit: 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
	DROP TABLE #tmpInventoryTransactionStockToReverse

