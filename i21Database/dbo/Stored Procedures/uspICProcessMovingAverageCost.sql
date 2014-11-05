/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 
	@intItemId - The item to process

	@intItemLocationId - The location where the item is being process. 
	
	@GLAccounts - The g/l accounts used when it generates the g/l entries for the costing. 

	@dblQty -	A positive qty indicates an increase of stock. A negative qty indicates a decrease in stock. 
				It uses the base qty. Any other unit of measure must be converted to base UOM. 
				
				For example: 				
				An item has a base unit of measure of PIECE. It also support BOX. A BOX cotains 10 PIECES.
				If receiving 7 BOXES, the qty is converted to PIECE which translates into 70 PIECES. 
				(7 BOXES x 10 PIECES per BOX). 

	@dblCost - The cost per @dblQty of the item. 
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
	,@GLAccounts AS ItemGLAccount READONLY 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- 1. Create the transaction record. 
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

	-- Add Write-Off Cost (Use purchase cost)
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
			,[intTransactionTypeId] = @intTransactionTypeId
			,[dtmCreated] = GETDATE()
			,[intCreatedUserId] = @intUserId
			,[intConcurrencyId] = 1
	FROM	[dbo].[tblICItemStock] Stock
	WHERE	(@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand <= 0 
			AND (@dblUnitQty * @dblUOMQty) > 0 
			AND Stock.intItemId = @intItemId
			AND Stock.intLocationId = @intItemLocationId
		
	-- Add Revalue Cost (Use current average cost)
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
			,[intTransactionTypeId] = @intTransactionTypeId
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
			,[intTransactionTypeId] = @intTransactionTypeId
			,[dtmCreated] = GETDATE()
			,[intCreatedUserId] = @intUserId
			,[intConcurrencyId] = 1
	FROM	[dbo].[tblICItemStock] Stock
	WHERE	(@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand <= 0 
			AND (@dblUnitQty * @dblUOMQty) > 0 
			AND Stock.intItemId = @intItemId
			AND Stock.intLocationId = @intItemLocationId
END

-- 2. Adjust the average cost and units on hand. 
BEGIN 
	UPDATE	Stock
	SET		Stock.dblAverageCost =	[dbo].[fnCalculateAverageCost]((@dblUnitQty * @dblUOMQty), @dblCost, Stock.dblUnitOnHand, Stock.dblAverageCost)
			,Stock.dblUnitOnHand = (@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand
			,Stock.intConcurrencyId = ISNULL(Stock.intConcurrencyId, 0) + 1 
	FROM	[dbo].[tblICItemStock] Stock
	WHERE	Stock.intItemId = @intItemId
			AND Stock.intLocationId = @intItemLocationId
END 


