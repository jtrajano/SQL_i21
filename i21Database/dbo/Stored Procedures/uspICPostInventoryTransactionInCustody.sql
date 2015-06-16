CREATE PROCEDURE [dbo].[uspICPostInventoryTransactionInCustody]
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(18, 6)
	,@dblUOMQty NUMERIC(18, 6)
	,@dblCost NUMERIC(18, 6)
	,@dblValue NUMERIC(18, 6)
	,@dblSalesPrice NUMERIC(18, 6)	
	,@intCurrencyId INT
	,@dblExchangeRate NUMERIC (38, 20)
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intTransactionTypeId INT
	,@intLotId INT
	,@strTransactionForm NVARCHAR (255)
	,@intUserId INT
	,@SourceCostBucketInCustodyId INT 
	,@InventoryTransactionIdInCustodyId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET @InventoryTransactionIdInCustodyId = NULL

INSERT INTO dbo.tblICInventoryTransactionInCustody (
		[intItemId] 
		,[intItemLocationId]
		,[intItemUOMId]
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
		,[strBatchId] 
		,[intTransactionTypeId] 
		,[strTransactionForm]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsUnposted]
		,[dtmCreated] 
		,[intCreatedUserId] 
		,[intConcurrencyId] 
		,[intInventoryCostBucketInCustodyId]
)
SELECT	[intItemId]								= @intItemId
		,[intItemLocationId]					= @intItemLocationId
		,[intItemUOMId]							= @intItemUOMId
		,[intLotId]								= @intLotId
		,[dtmDate]								= @dtmDate
		,[dblQty]								= ISNULL(@dblQty, 0)
		,[dblUOMQty]							= ISNULL(@dblUOMQty, 0)
		,[dblCost]								= ISNULL(@dblCost, 0)
		,[dblValue]								= ISNULL(@dblValue, 0)
		,[dblSalesPrice]						= ISNULL(@dblSalesPrice, 0)
		,[intCurrencyId]						= @intCurrencyId
		,[dblExchangeRate]						= ISNULL(@dblExchangeRate, 1)
		,[intTransactionId]						= @intTransactionId
		,[intTransactionDetailId]				= @intTransactionDetailId
		,[strTransactionId]						= @strTransactionId
		,[strBatchId]							= @strBatchId
		,[intTransactionTypeId]					= @intTransactionTypeId
		,[strTransactionForm]					= @strTransactionForm
		,[intSubLocationId]						= @intSubLocationId
		,[intStorageLocationId]					= @intStorageLocationId
		,[ysnIsUnposted]						= 0 
		,[dtmCreated]							= GETDATE()
		,[intCreatedUserId]						= @intUserId
		,[intConcurrencyId]						= 1
		,[intInventoryCostBucketInCustodyId]	= @SourceCostBucketInCustodyId
WHERE	@intItemId IS NOT NULL
		AND @intItemLocationId IS NOT NULL
		AND @intItemUOMId IS NOT NULL 

SET @InventoryTransactionIdInCustodyId = SCOPE_IDENTITY();

IF @intLotId IS NOT NULL 
BEGIN 
	DECLARE @ActiveLotStatus AS INT = 1

	EXEC dbo.uspICPostInventoryLotTransactionInCustody
		@intItemId 
		,@intLotId 
		,@intItemLocationId 
		,@intItemUOMId  
		,@intSubLocationId 
		,@intStorageLocationId 
		,@dtmDate 
		,@dblQty 
		,@dblCost 
		,@intTransactionId 
		,@intTransactionDetailId 
		,@strTransactionId 
		,@strBatchId 
		,@ActiveLotStatus
		,@intTransactionTypeId 		
		,@strTransactionForm
		,@intUserId 
		,@SourceCostBucketInCustodyId 
		,NULL 
END