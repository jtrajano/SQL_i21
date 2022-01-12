CREATE PROCEDURE [dbo].[uspICPostInventoryLotTransactionStorage]
	@intItemId INT
	,@intLotId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(38,20)
	,@dblCost NUMERIC(38, 20)
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(40)
	,@intLotStatusId INT 
	,@intTransactionTypeId INT	
	,@strTransactionForm NVARCHAR (255)
	,@intEntityUserSecurityId INT
	,@SourceInventoryLotStorageId INT 
	,@intSourceEntityId INT = NULL 
	,@strSourceType NVARCHAR(100) = NULL 
	,@strSourceNumber NVARCHAR(100) = NULL 
	,@strBOLNumber NVARCHAR(100) = NULL 
	,@intTicketId INT = NULL 
	,@InventoryLotTransactionStorageId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

SET @InventoryLotTransactionStorageId = NULL

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
		,[intInventoryCostBucketStorageId]
		,[dtmCreated]
		,[intCreatedEntityId]
		,[intConcurrencyId]
		,[intSourceEntityId]
		,[strSourceType]
		,[strSourceNumber]
		,[strBOLNumber]
		,[intTicketId]
)
SELECT	[intItemId]								= @intItemId
		,[intLotId]								= @intLotId
		,[intLocationId]						= ItemLocation.intLocationId 
		,[intItemLocationId]					= @intItemLocationId
		,[intSubLocationId]						= @intSubLocationId
		,[intStorageLocationId]					= @intStorageLocationId
		,[dtmDate]								= @dtmDate
		,[dblQty]								= ISNULL(@dblQty, 0)
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
		,[intInventoryCostBucketStorageId]		= @SourceInventoryLotStorageId
		,[dtmCreated]							= GETDATE()
		,[intCreatedEntityId]					= @intEntityUserSecurityId
		,[intConcurrencyId]						= 1
		,[intSourceEntityId]					= @intSourceEntityId
		,[strSourceType]						= @strSourceType
		,[strSourceNumber]						= @strSourceNumber
		,[strBOLNumber]							= @strBOLNumber
		,[intTicketId]							= @intTicketId
FROM	dbo.tblICItemLocation ItemLocation
WHERE	@intItemId IS NOT NULL
		AND @intItemLocationId IS NOT NULL
		AND @intItemUOMId IS NOT NULL 
		AND ItemLocation.intItemLocationId  = @intItemLocationId

SET @InventoryLotTransactionStorageId = SCOPE_IDENTITY();
