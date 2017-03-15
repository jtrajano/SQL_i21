CREATE PROCEDURE [dbo].[uspICPostInventoryTransaction]
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
	--,@dblExchangeRate NUMERIC (38,20) -- OBSOLETE 
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intTransactionTypeId INT
	,@intLotId INT
	,@intRelatedInventoryTransactionId INT
	,@intRelatedTransactionId INT
	,@strRelatedTransactionId NVARCHAR(40)
	,@strTransactionForm NVARCHAR (255)
	,@intEntityUserSecurityId INT
	,@intCostingMethod INT
	,@InventoryTransactionIdentityId INT OUTPUT 
	,@intFobPointId TINYINT = NULL 
	,@intInTransitSourceLocationId INT = NULL 
	,@intForexRateTypeId INT = NULL
	,@dblForexRate NUMERIC(38, 20) = 1
	,@strDescription NVARCHAR(255) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET @InventoryTransactionIdentityId = NULL

-- Initialize the UOM Qty
SELECT	TOP 1
		@dblUOMQty = ItemUOM.dblUnitQty
FROM	tblICItemUOM ItemUOM
WHERE	intItemUOMId = @intItemUOMId

INSERT INTO dbo.tblICInventoryTransaction (
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
		,[strRelatedTransactionId]
		,[intRelatedTransactionId]
		,[strTransactionForm]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsUnposted]
		,[intRelatedInventoryTransactionId]
		,[dtmCreated] 
		,[intCreatedEntityId] 
		,[intConcurrencyId] 
		,[intCostingMethod]
		,[intFobPointId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate]
		,[strDescription]
)
SELECT	[intItemId]							= @intItemId
		,[intItemLocationId]				= @intItemLocationId
		,[intItemUOMId]						= @intItemUOMId
		,[intLotId]							= @intLotId
		,[dtmDate]							= @dtmDate
		,[dblQty]							= ISNULL(@dblQty, 0)
		,[dblUOMQty]						= ISNULL(@dblUOMQty, 0)
		,[dblCost]							= ISNULL(@dblCost, 0)
		,[dblValue]							= ISNULL(@dblValue, 0)
		,[dblSalesPrice]					= ISNULL(@dblSalesPrice, 0)
		,[intCurrencyId]					= @intCurrencyId
		,[dblExchangeRate]					= ISNULL(@dblForexRate, 1)
		,[intTransactionId]					= @intTransactionId
		,[intTransactionDetailId]			= @intTransactionDetailId
		,[strTransactionId]					= @strTransactionId
		,[strBatchId]						= @strBatchId
		,[intTransactionTypeId]				= @intTransactionTypeId
		,[strRelatedTransactionId]			= @strRelatedTransactionId
		,[intRelatedTransactionId]			= @intRelatedTransactionId
		,[strTransactionForm]				= @strTransactionForm
		,[intSubLocationId]					= @intSubLocationId
		,[intStorageLocationId]				= @intStorageLocationId
		,[ysnIsUnposted]					= 0 
		,[intRelatedInventoryTransactionId] = @intRelatedInventoryTransactionId
		,[dtmCreated]						= GETDATE()
		,[intCreatedEntityId]				= @intEntityUserSecurityId
		,[intConcurrencyId]					= 1
		,[intCostingMethod]					= @intCostingMethod
		,[intFobPointId]					= @intFobPointId
		,[intInTransitSourceLocationId]		= @intInTransitSourceLocationId
		,[intForexRateTypeId]				= @intForexRateTypeId
		,[dblForexRate]						= @dblForexRate
		,[strDescription]					= @strDescription
WHERE	@intItemId IS NOT NULL
		AND @intItemLocationId IS NOT NULL
		AND @intItemUOMId IS NOT NULL 

SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();

IF @intLotId IS NOT NULL 
BEGIN 
	DECLARE @ActiveLotStatus AS INT = 1
	EXEC dbo.uspICPostInventoryLotTransaction
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
		,@strTransactionId 
		,@strBatchId 
		,@ActiveLotStatus 
		,@intTransactionTypeId 
		,@strTransactionForm 
		,@intEntityUserSecurityId 
		,NULL  
END