CREATE PROCEDURE [dbo].[uspICPostInventoryTransaction]
	@intItemId INT
	,@intItemLocationId INT
	,@dtmDate DATETIME
	,@dblUnitQty NUMERIC(18, 6)
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
		,[intLotId]
		,[dtmDate] 
		,[dblUnitQty] 
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
		,[intLotId]						= @intLotId
		,[dtmDate]						= @dtmDate
		,[dblUnitQty]					= @dblUnitQty
		,[dblCost]						= @dblCost
		,[dblValue]						= @dblValue 
		,[dblSalesPrice]				= @dblSalesPrice
		,[intCurrencyId]				= @intCurrencyId
		,[dblExchangeRate]				= @dblExchangeRate
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

SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();