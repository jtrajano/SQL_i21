CREATE PROCEDURE [dbo].[uspICPostInventoryLotTransactionInCustody]
	@intItemId INT
	,@intLotId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(18, 6)
	,@dblCost NUMERIC(18, 6)
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intLotStatusId INT 
	,@intTransactionTypeId INT	
	,@strTransactionForm NVARCHAR (255)
	,@intUserId INT
	,@SourceInventoryLotInCustodyId INT 
	,@InventoryLotTransactionInCustodyId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET @InventoryLotTransactionInCustodyId = NULL

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
		,[intTransactionDetailId]
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
SELECT	[intItemId]								= @intItemId
		,[intLotId]								= @intLotId
		,[intLocationId]						= ItemLocation.intLocationId 
		,[intItemLocationId]					= @intItemLocationId
		,[intSubLocationId]						= @intSubLocationId
		,[intStorageLocationId]					= @intStorageLocationId
		,[dtmDate]								= @dtmDate
		,[dblQty]								= @dblQty
		,[intItemUOMId]							= @intItemUOMId
		,[dblCost]								= ISNULL(@dblCost, 0)
		,[intTransactionId]						= @intTransactionId
		,[intTransactionDetailId]				= @intTransactionDetailId
		,[strTransactionId]						= @strTransactionId
		,[intTransactionTypeId]					= @intTransactionTypeId
		,[strBatchId]							= @strBatchId
		,[intLotStatusId]						= @intLotStatusId
		,[strTransactionForm]					= @strTransactionForm
		,[ysnIsUnposted]						= 0 
		,[intInventoryCostBucketInCustodyId]	= @SourceInventoryLotInCustodyId
		,[dtmCreated]							= GETDATE()
		,[intCreatedUserId]						= @intUserId
		,[intConcurrencyId]						= 1
FROM	dbo.tblICItemLocation ItemLocation
WHERE	@intItemId IS NOT NULL
		AND @intItemLocationId IS NOT NULL
		AND @intItemUOMId IS NOT NULL 
		AND ItemLocation.intItemLocationId  = @intItemLocationId

SET @InventoryLotTransactionInCustodyId = SCOPE_IDENTITY();