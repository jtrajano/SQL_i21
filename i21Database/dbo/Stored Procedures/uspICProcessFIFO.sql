/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICProcessFIFO]
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
DECLARE @FifoId AS INT

-------------------------------------------------
-- 1. Process the Fifo Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0)
		SET @FifoId = NULL
		SET @InventoryTransactionIdentityId = NULL 

		-- Repeat call on uspICReduceStockInFIFO until @dblReduceQty is completely distributed to all available fifo buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInFIFO
				@intItemId
				,@intItemLocationId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@FifoId OUTPUT 

			-- Insert the inventory transaction record
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
					,[dblUnitQty] = @dblReduceQty - ISNULL(@RemainingQty, 0) 
					,[dblCost] = ISNULL(@CostUsed, @dblCost)
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
			
			-- Insert the record the the fifo-out table
			INSERT INTO tblICInventoryFIFOOut (
					intInventoryTransactionId
					,intInventoryFIFOId
					,dblQty
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryFIFOId = @FifoId
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @FifoId IS NOT NULL 
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
		SET @FifoId = NULL
		SET @InventoryTransactionIdentityId = NULL 

		-- Insert the inventory transaction record
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
				,@intItemLocationId
				,@dtmDate
				,@dblAddQty
				,@dblCost
				,@intUserId
				,@FullQty
				,@TotalQtyOffset
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@FifoId OUTPUT 

			SET @dblAddQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Insert the inventory transaction record
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
			-- Add Revalue Sold			
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @intItemLocationId
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = @QtyOffset 
					,[dblCost] = @CostUsed
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
			WHERE	@QtyOffset IS NOT NULL 
			UNION ALL 
			-- Add Write-Off Sold
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @intItemLocationId
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = @QtyOffset * -1
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
			WHERE	@QtyOffset IS NOT NULL 

			-- Get the id used in the inventory transaction insert 
			SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();
			
			-- Insert the record the the fifo-out table
			INSERT INTO tblICInventoryFIFOOut (
					intInventoryTransactionId
					,intInventoryFIFOId
					,dblQty
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryFIFOId = @FifoId
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @FifoId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 

			SET @dblAddQty = @RemainingQty;
		END 
	END 
END 