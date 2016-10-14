CREATE PROCEDURE [dbo].[uspICPostInventoryLotTransaction]
	@intItemId INT
	,@intLotId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(38,20)
	,@dblCost NUMERIC(38,20)
	,@intTransactionId INT
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intLotStatusId INT 
	,@intTransactionTypeId INT
	,@strTransactionForm NVARCHAR (255)
	,@intEntityUserSecurityId INT
	,@InventoryLotTransactionIdentityId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET @InventoryLotTransactionIdentityId = NULL

INSERT INTO dbo.tblICInventoryLotTransaction (		
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
		,[dtmCreated] 
		,[intCreatedEntityId] 
		,[intConcurrencyId] 
)
SELECT	[intItemId]					= @intItemId
		,[intLotId]					= @intLotId
		,[intLocationId]			= ItemLocation.intLocationId
		,[intItemLocationId]		= @intItemLocationId
		,[intSubLocationId]			= @intSubLocationId
		,[intStorageLocationId]		= @intStorageLocationId
		,[dtmDate]					= @dtmDate
		,[dblQty]					= ISNULL(@dblQty, 0)
		,[intItemUOMId]				= @intItemUOMId
		,[dblCost]					= ISNULL(@dblCost, 0)
		,[intTransactionId]			= @intTransactionId
		,[strTransactionId]			= @strTransactionId
		,[intTransactionTypeId]		= @intTransactionTypeId
		,[strBatchId]				= @strBatchId
		,[intLotStatusId]			= @intLotStatusId 
		,[strTransactionForm]		= @strTransactionForm
		,[ysnIsUnposted]			= 0
		,[dtmCreated]				= GETDATE()
		,[intCreatedEntityId]		= @intEntityUserSecurityId
		,[intConcurrencyId]			= 1
FROM	dbo.tblICItemLocation ItemLocation
WHERE	intItemLocationId = @intItemLocationId
		AND @intLotId IS NOT NULL
		AND @intItemUOMId IS NOT NULL
		AND intLocationId IS NOT NULL 

SET @InventoryLotTransactionIdentityId = SCOPE_IDENTITY();

