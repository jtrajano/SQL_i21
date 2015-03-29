CREATE PROCEDURE [dbo].[uspICPostInventoryTransaction]
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
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intTransactionTypeId INT
	,@intLotId INT
	,@ysnIsUnposted BIT
	,@intRelatedInventoryTransactionId INT
	,@intRelatedTransactionId INT
	,@strRelatedTransactionId NVARCHAR(40)
	,@strTransactionForm NVARCHAR (255)
	,@intUserId INT
	,@InventoryTransactionIdentityId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET @InventoryTransactionIdentityId = NULL

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
		,[strTransactionId] 
		,[strBatchId] 
		,[intTransactionTypeId] 
		,[strRelatedTransactionId]
		,[intRelatedTransactionId]
		,[strTransactionForm]
		,[dtmCreated] 
		,[intCreatedUserId] 
		,[intConcurrencyId] 
)
SELECT	[intItemId]						= @intItemId
		,[intItemLocationId]			= @intItemLocationId
		,[intItemUOMId]					= @intItemUOMId
		,[intLotId]						= @intLotId
		,[dtmDate]						= @dtmDate
		,[dblQty]						= ISNULL(@dblQty, 0)
		,[dblUOMQty]					= ISNULL(@dblUOMQty, 0)
		,[dblCost]						= ISNULL(@dblCost, 0)
		,[dblValue]						= ISNULL(@dblValue, 0)
		,[dblSalesPrice]				= ISNULL(@dblSalesPrice, 0)
		,[intCurrencyId]				= @intCurrencyId
		,[dblExchangeRate]				= ISNULL(@dblExchangeRate, 1)
		,[intTransactionId]				= @intTransactionId
		,[strTransactionId]				= @strTransactionId
		,[strBatchId]					= @strBatchId
		,[intTransactionTypeId]			= @intTransactionTypeId
		,[strRelatedTransactionId]		= @strRelatedTransactionId
		,[intRelatedTransactionId]		= @intRelatedTransactionId
		,[strTransactionForm]			= @strTransactionForm
		,[dtmCreated]					= GETDATE()
		,[intCreatedUserId]				= @intUserId
		,[intConcurrencyId]				= 1
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
		,@ysnIsUnposted 
		,@strTransactionForm 
		,@intUserId 
		,NULL  
END