/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 
	@intItemId - The item to process

	@intItemLocationId - The location where the item is being process. 
	
	@dtmDate - The date used in the transaction and posting. 

	@dblUnitQty - A positive qty indicates an increase of stock. A negative qty indicates a decrease in stock. 

	@dblUOMQty - The base qty associated with a UOM. For example, a box may have 10 pieces of an item. In this case, UOM qty will be 10. 

	@dblCost - The cost per base qty of the item. 

	@dblSalesPrice - The sales price of an item sold to the customer. 

	@intCurrencyId - The foreign currency associated with the transaction. 

	@dblExchangeRate - The conversion factor between the base currency and the foreign currency. 

	@intTransactionId - The primary key id used in a transaction. 

	@strTransactionId - The string value of a transaction id. 

	@strBatchId - The batch id to use in generating the g/l entries. 

	@intUserId - The user who initiated or called this stored procedure. 
*/

CREATE PROCEDURE [dbo].[uspICProcessMovingAverageCost]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblUnitQty AS NUMERIC(18,6)
	,@dblUOMQty AS NUMERIC(18,6)
	,@dblCost AS NUMERIC(18,6)
	,@dblSalesPrice AS NUMERIC(18,6)
	,@intCurrencyId AS INT
	,@dblExchangeRate AS NUMERIC(18,6)
	,@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables for the internal transaction types used by costing. 
DECLARE @WRITE_OFF_SOLD AS INT = -1
DECLARE @REVALUE_SOLD AS INT = -2
DECLARE @AUTO_NEGATIVE AS INT = -3

-- 1. Create the transaction record/s for moving average cost 
BEGIN 
	INSERT INTO tblICInventoryTransaction (
			[intItemId] 
			,[intItemLocationId] 
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
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 
	)
	-- If positive qty, add stock 
	SELECT	[intItemId] = @intItemId
			,[intItemLocationId] = @intItemLocationId
			,[dtmDate] = @dtmDate
			,[dblUnitQty] = @dblUnitQty * @dblUOMQty
			,[dblCost] = @dblCost
			,[dblValue] = NULL 
			,[dblSalesPrice] = @dblSalesPrice
			,[intCurrencyId] = @intCurrencyId
			,[dblExchangeRate] = @dblExchangeRate
			,[intTransactionId] = @intTransactionId
			,[strTransactionId] = @strTransactionId
			,[strBatchId] = @strBatchId
			,[intTransactionTypeId] = @intTransactionTypeId
			,[dtmCreated] = GETDATE()
			,[intCreatedUserId] = @intUserId
			,[intConcurrencyId] = 1
	WHERE	(@dblUnitQty * @dblUOMQty) > 0  

	-- If negative qty, reduce stock 
	UNION ALL 
	SELECT	[intItemId] = @intItemId
			,[intItemLocationId] = @intItemLocationId
			,[dtmDate] = @dtmDate
			,[dblUnitQty] = @dblUnitQty * @dblUOMQty
			,[dblCost] = dbo.fnGetItemAverageCost(@intItemId, @intItemLocationId) 
			,[dblValue] = NULL 
			,[dblSalesPrice] = @dblSalesPrice
			,[intCurrencyId] = @intCurrencyId
			,[dblExchangeRate] = @dblExchangeRate
			,[intTransactionId] = @intTransactionId
			,[strTransactionId] = @strTransactionId
			,[strBatchId] = @strBatchId
			,[intTransactionTypeId] = @intTransactionTypeId
			,[dtmCreated] = GETDATE()
			,[intCreatedUserId] = @intUserId
			,[intConcurrencyId] = 1
	WHERE	(@dblUnitQty * @dblUOMQty) < 0 

	-- Add Write-Off Sold (Use purchase cost)
	UNION ALL 
	SELECT	[intItemId] = @intItemId
			,[intItemLocationId] = @intItemLocationId
			,[dtmDate] = @dtmDate
			,[dblUnitQty] = (@dblUnitQty * @dblUOMQty) * -1
			,[dblCost] = @dblCost
			,[dblValue] = NULL 
			,[dblSalesPrice] = @dblSalesPrice
			,[intCurrencyId] = @intCurrencyId
			,[dblExchangeRate] = @dblExchangeRate
			,[intTransactionId] = @intTransactionId
			,[strTransactionId] = @strTransactionId
			,[strBatchId] = @strBatchId
			,[intTransactionTypeId] = @WRITE_OFF_SOLD
			,[dtmCreated] = GETDATE()
			,[intCreatedUserId] = @intUserId
			,[intConcurrencyId] = 1
	FROM	[dbo].[tblICItemStock] Stock
	WHERE	(@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand <= 0 
			AND (@dblUnitQty * @dblUOMQty) > 0 
			AND Stock.intItemId = @intItemId
			AND Stock.intLocationId = @intItemLocationId
		
	-- Add Revalue Sold (Use current average cost)
	UNION ALL 
	SELECT	[intItemId] = @intItemId
			,[intItemLocationId] = @intItemLocationId
			,[dtmDate] = @dtmDate
			,[dblUnitQty] = (@dblUnitQty * @dblUOMQty) 
			,[dblCost] = dbo.fnGetItemAverageCost(@intItemId, @intItemLocationId) 
			,[dblValue] = NULL 
			,[dblSalesPrice] = @dblSalesPrice
			,[intCurrencyId] = @intCurrencyId
			,[dblExchangeRate] = @dblExchangeRate
			,[intTransactionId] = @intTransactionId
			,[strTransactionId] = @strTransactionId
			,[strBatchId] = @strBatchId
			,[intTransactionTypeId] = @REVALUE_SOLD
			,[dtmCreated] = GETDATE()
			,[intCreatedUserId] = @intUserId
			,[intConcurrencyId] = 1
	FROM	[dbo].[tblICItemStock] Stock
	WHERE	(@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand <= 0 
			AND (@dblUnitQty * @dblUOMQty) > 0 
			AND Stock.intItemId = @intItemId
			AND Stock.intLocationId = @intItemLocationId

	-- Add Auto Negative 
	INSERT INTO tblICInventoryTransaction (
			[intItemId] 
			,[intItemLocationId] 
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
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 
	)
	SELECT	[intItemId] = @intItemId
			,[intItemLocationId] = @intItemLocationId
			,[dtmDate] = @dtmDate
			,[dblUnitQty] = 0
			,[dblCost] = 0
			,[dblValue] = 
						(((@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand) * @dblCost) 
						- [dbo].[fnGetItemTotalValueFromTransactions](@intItemId, @intItemLocationId)
			,[dblSalesPrice] = @dblSalesPrice
			,[intCurrencyId] = @intCurrencyId
			,[dblExchangeRate] = @dblExchangeRate
			,[intTransactionId] = @intTransactionId
			,[strTransactionId] = @strTransactionId
			,[strBatchId] = @strBatchId
			,[intTransactionTypeId] = @AUTO_NEGATIVE
			,[dtmCreated] = GETDATE()
			,[intCreatedUserId] = @intUserId
			,[intConcurrencyId] = 1
	FROM	[dbo].[tblICItemStock] Stock
	WHERE	(@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand <= 0 
			AND (@dblUnitQty * @dblUOMQty) > 0 
			AND Stock.intItemId = @intItemId
			AND Stock.intLocationId = @intItemLocationId
END