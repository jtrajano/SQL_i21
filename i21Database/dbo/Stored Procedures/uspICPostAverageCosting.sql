/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 
	@intItemId - The item to process

	@intLocationId - The location where the item is being process. 
	
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

CREATE PROCEDURE [dbo].[uspICPostAverageCosting]
	@intItemId AS INT
	,@intLocationId AS INT
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
DECLARE @WRITE_OFF_SOLD AS INT = -1;
DECLARE @REVALUE_SOLD AS INT = -2;
DECLARE @AUTO_NEGATIVE AS INT = -3;

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(18,6);
DECLARE @dblReduceQty AS NUMERIC(18,6);
DECLARE @dblAddQty AS NUMERIC(18,6);
DECLARE @CostUsed AS NUMERIC(18,6);
DECLARE @FullQty AS NUMERIC(18,6);
DECLARE @QtyOffset AS NUMERIC(18,6);
DECLARE @TotalQtyOffset AS NUMERIC(18,6);

DECLARE @InventoryTransactionIdentityId AS INT

DECLARE @NewFifoId AS INT
DECLARE @UpdatedFifoId AS INT 

-------------------------------------------------
-- 1. Process the Fifo Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0)

		SELECT @dblCost = AverageCost
		FROM dbo.fnGetItemAverageCostAsTable(@intItemId, @intLocationId)

		-- Insert the inventory transaction record
		INSERT INTO dbo.tblICInventoryTransaction (
			[intItemId] 
			,[intLocationId] 
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
				,[intLocationId] = @intLocationId
				,[dtmDate] = @dtmDate
				,[dblUnitQty] = @dblReduceQty
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

		-- Get the id used in the inventory transaction insert 
		SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();

		-- Repeat call on uspICReduceStockInFIFO until @dblReduceQty is completely distributed to all available fifo buckets 
		-- If there is no avaiable fifo buckets, it will add a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInFIFO
				@intItemId
				,@intLocationId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@UpdatedFifoId OUTPUT 
			
			-- Insert the record to the fifo-out table
			INSERT INTO dbo.tblICInventoryFIFOOut (
					intInventoryTransactionId
					,intInventoryFIFOId
					,dblQty
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryFIFOId = @UpdatedFifoId
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedFifoId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 

			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
		END 
	END

	-- Add stock 
	ELSE IF (ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0) > 0)
	BEGIN 

		SET @dblAddQty = ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0)
		SET @FullQty = @dblAddQty
		SET @TotalQtyOffset = 0;

		-- Insert the inventory transaction record
		INSERT INTO dbo.tblICInventoryTransaction (
			[intItemId] 
			,[intLocationId] 
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
				,[intLocationId] = @intLocationId
				,[dtmDate] = @dtmDate
				,[dblUnitQty] = @FullQty
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

		-- Repeat call on uspICIncreaseStockInFIFO until @dblAddQty is completely distributed to the negative cost fifo buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInFIFO
				@intItemId
				,@intLocationId
				,@dtmDate
				,@dblAddQty
				,@dblCost
				,@intUserId
				,@FullQty
				,@TotalQtyOffset
				,@strTransactionId
				,@intTransactionId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@NewFifoId OUTPUT 
				,@UpdatedFifoId OUTPUT 

			SET @dblAddQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Insert the inventory transaction record
			INSERT INTO dbo.tblICInventoryTransaction (
				[intItemId] 
				,[intLocationId] 
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
			-- Add Write-Off Sold (using the current average cost)
			SELECT	[intItemId] = @intItemId
					,[intLocationId] = @intLocationId
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = @QtyOffset * dbo.fnGetItemAverageCost(@intItemId, @intLocationId)
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
			WHERE	@QtyOffset IS NOT NULL 			
			-- Add Revalue Sold (to the new cost)
			UNION ALL 
			SELECT	[intItemId] = @intItemId
					,[intLocationId] = @intLocationId
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = @QtyOffset * @dblCost * -1
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
			WHERE	@QtyOffset IS NOT NULL 

			-- Get the id inserted for Revalue-Sold
			SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();
			
			-- Insert the record to the fifo-out table
			INSERT INTO dbo.tblICInventoryFIFOOut (
					intInventoryTransactionId
					,intInventoryFIFOId
					,dblQty
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryFIFOId = NULL 
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedFifoId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 

			SET @dblAddQty = @RemainingQty;
		END 

		-- Update the fifo out table and assign the correct fifo id. 
		UPDATE	FifoOut
		SET		FifoOut.intInventoryFIFOId = @NewFifoId
		FROM	dbo.tblICInventoryFIFOOut FifoOut INNER JOIN dbo.tblICInventoryTransaction TRANS
					ON FifoOut.intInventoryTransactionId = TRANS.intInventoryTransactionId 
					AND FifoOut.intInventoryFIFOId IS NULL 
					AND TRANS.intItemId = @intItemId
					AND TRANS.intLocationId = @intLocationId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
					AND @NewFifoId IS NOT NULL  

		-- Add Auto Negative (if current stock qty is still negative after adding it) 
		INSERT INTO dbo.tblICInventoryTransaction (
				[intItemId] 
				,[intLocationId] 
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
				,[intLocationId] = @intLocationId
				,[dtmDate] = @dtmDate
				,[dblUnitQty] = 0
				,[dblCost] = 0
				,[dblValue] = 
							(((@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand) * @dblCost) 
							- [dbo].[fnGetItemTotalValueFromTransactions](@intItemId, @intLocationId)
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
		WHERE	(@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand < 0 
				AND (@dblUnitQty * @dblUOMQty) > 0 
				AND Stock.intItemId = @intItemId
				AND Stock.intLocationId = @intLocationId	
	END 
END 