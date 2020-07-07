CREATE PROCEDURE [dbo].[uspICPostInventoryTransactionStorage]
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(38,20)
	,@dblUOMQty NUMERIC(38,20)
	,@dblCost NUMERIC(38,20)
	,@dblValue NUMERIC(38,20)
	,@dblSalesPrice NUMERIC(18, 6)	
	,@intCurrencyId INT
	--,@dblExchangeRate NUMERIC (38,20)
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(40)
	,@intTransactionTypeId INT
	,@intLotId INT
	,@intRelatedInventoryTransactionId INT
	,@intRelatedTransactionId INT
	,@strRelatedTransactionId NVARCHAR(40)
	,@strTransactionForm NVARCHAR (255)
	,@intEntityUserSecurityId INT
	,@intCostingMethod INT
	,@InventoryTransactionIdentityId INT OUTPUT 
	,@intForexRateTypeId INT = NULL
	,@dblForexRate NUMERIC(38, 20) = 1
	,@strDescription NVARCHAR(255) = NULL 
	,@intSourceEntityId INT = NULL 
	,@intTransactionItemUOMId INT = NULL 
	,@dtmCreated DATETIME = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @InventoryStockMovementId AS INT
SET @InventoryTransactionIdentityId = NULL
SET @dtmCreated = GETDATE()

INSERT INTO dbo.tblICInventoryTransactionStorage (
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
		,[intInventoryCostBucketStorageId]
		,[strBatchId]
		,[intTransactionTypeId]
		,[strTransactionForm]
		,[intRelatedInventoryTransactionId]
		,[intRelatedTransactionId]
		,[strRelatedTransactionId]
		,[intCostingMethod]
		,[intCreatedEntityId]
		,[intConcurrencyId]
		,[intForexRateTypeId]
		,[dblForexRate]
		,[ysnIsUnposted]
		,[dtmCreated]
		,[intSourceEntityId]
		,[intTransactionItemUOMId]
)
SELECT	[intItemId]								= @intItemId
		,[intItemLocationId]					= @intItemLocationId
		,[intItemUOMId]							= @intItemUOMId
		,[intSubLocationId]						= @intSubLocationId
		,[intStorageLocationId]					= @intStorageLocationId
		,[intLotId]								= @intLotId
		,[dtmDate]								= @dtmDate
		,[dblQty]								= ISNULL(@dblQty, 0)
		,[dblUOMQty]							= ISNULL(@dblUOMQty, 0)
		,[dblCost]								= ISNULL(@dblCost, 0)
		,[dblValue]								= ISNULL(@dblValue, 0)
		,[dblSalesPrice]						= ISNULL(@dblSalesPrice, 0)
		,[intCurrencyId]						= @intCurrencyId
		,[dblExchangeRate]						= ISNULL(@dblForexRate, 1) 
		,[intTransactionId]						= @intTransactionId
		,[intTransactionDetailId]				= @intTransactionDetailId
		,[strTransactionId]						= @strTransactionId
		,[intInventoryCostBucketStorageId]		= NULL 
		,[strBatchId]							= @strBatchId
		,[intTransactionTypeId]					= @intTransactionTypeId
		,[strTransactionForm]					= @strTransactionForm
		,[intRelatedInventoryTransactionId]		= @intRelatedInventoryTransactionId
		,[intRelatedTransactionId]				= @intRelatedTransactionId
		,[strRelatedTransactionId]				= @strRelatedTransactionId
		,[intCostingMethod]						= @intCostingMethod
		,[intCreatedEntityId]					= @intEntityUserSecurityId
		,[intConcurrencyId]						= 1
		,[intForexRateTypeId]					= @intForexRateTypeId
		,[dblForexRate]							= @dblForexRate
		,[ysnIsUnposted]						= 0
		,[dtmCreated]							= @dtmCreated
		,[intSourceEntityId]					= @intSourceEntityId
		,[intTransactionItemUOMId]				= @intTransactionItemUOMId
WHERE	@intItemId IS NOT NULL
		AND @intItemLocationId IS NOT NULL
		AND @intItemUOMId IS NOT NULL 

SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();

IF @InventoryTransactionIdentityId IS NOT NULL 
BEGIN 
	EXEC uspICPostInventoryStockMovement
		@InventoryTransactionId = NULL
		,@InventoryTransactionStorageId = @InventoryTransactionIdentityId
		,@InventoryStockMovementId = @InventoryStockMovementId OUTPUT 
END 

IF @intLotId IS NOT NULL 
BEGIN 
	DECLARE @ActiveLotStatus AS INT = 1

	EXEC dbo.uspICPostInventoryLotTransactionStorage
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
		,@intEntityUserSecurityId 
		,NULL -- @SourceCostBucketStorageId 
		,@intSourceEntityId	
		,NULL 
END