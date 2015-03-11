CREATE PROCEDURE [dbo].[uspICPostInventoryLotTransaction]
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
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intLotStatusId INT 
	,@intTransactionTypeId INT
	,@ysnIsUnposted BIT
	,@strTransactionForm NVARCHAR (255)
	,@intUserId INT
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
		--,[dblWeight]
		--,[intWeightUOMId]
		,[dblCost]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[strBatchId]
		,[intLotStatusId] 
		,[strTransactionForm]
		,[ysnIsUnposted]
		,[dtmCreated] 
		,[intCreatedUserId] 
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
		--,[dblWeight]
		--,[intWeightUOMId]
		,[dblCost]					= ISNULL(@dblCost, 0)
		,[intTransactionId]			= @intTransactionId
		,[strTransactionId]			= @strTransactionId
		,[intTransactionTypeId]		= @intTransactionTypeId
		,[strBatchId]				= @strBatchId
		,[intLotStatusId]			= @intLotStatusId 
		,[strTransactionForm]		= @strTransactionForm
		,[ysnIsUnposted]			= @ysnIsUnposted
		,[dtmCreated]				= GETDATE()
		,[intCreatedUserId]			= @intUserId
		,[intConcurrencyId]			= 1
FROM	dbo.tblICItemLocation ItemLocation
WHERE	intItemLocationId = @intItemLocationId
		AND @intLotId IS NOT NULL
		AND @intItemUOMId IS NOT NULL

SET @InventoryLotTransactionIdentityId = SCOPE_IDENTITY();

