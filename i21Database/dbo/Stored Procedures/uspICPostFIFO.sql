/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICPostFIFO]
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
DECLARE @Inventory_Auto_Negative AS INT = 1;
DECLARE @Inventory_Write_Off_Sold AS INT = 2;
DECLARE @Inventory_Revalue_Sold AS INT = 3;

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
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 

-- Initialize the transaction name. Use this as the transaction form name
DECLARE @TransactionTypeName AS NVARCHAR(200) 
SELECT	TOP 1 
		@TransactionTypeName = strName
FROM	dbo.tblICInventoryTransactionType
WHERE	intTransactionTypeId = @intTransactionTypeId

-------------------------------------------------
-- 1. Process the Fifo Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0)

		-- Repeat call on uspICReduceStockInFIFO until @dblReduceQty is completely distributed to all available fifo buckets or added a new negative bucket. 
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
				,[strTransactionForm]
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId]
			)			
			SELECT	[intItemId] = @intItemId
					,[intLocationId] = @intLocationId
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
					,[strTransactionForm] = @TransactionTypeName
					,[dtmCreated] = GETDATE()
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId] = 1

			-- Get the id used in the inventory transaction insert 
			SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();
			
			-- Insert the record the the fifo-out table
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
			,[strTransactionForm]
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
				,[strTransactionForm] = @TransactionTypeName
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
				,@strRelatedTransactionId OUTPUT
				,@intRelatedTransactionId OUTPUT 

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
				,[strRelatedTransactionId]
				,[intRelatedTransactionId]
				,[strTransactionForm]
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId] 
			)
			-- Add Write-Off Sold
			SELECT	[intItemId] = @intItemId
					,[intLocationId] = @intLocationId
					,[dtmDate] = @dtmDate
					,[dblUnitQty] = 0
					,[dblCost] = 0
					,[dblValue] = @QtyOffset * @CostUsed
					,[dblSalesPrice] = @dblSalesPrice
					,[intCurrencyId] = @intCurrencyId
					,[dblExchangeRate] = @dblExchangeRate
					,[intTransactionId] = @intTransactionId
					,[strTransactionId] = @strTransactionId
					,[strBatchId] = @strBatchId
					,[intTransactionTypeId] = @Inventory_Write_Off_Sold
					,[strRelatedTransactionId] = @strRelatedTransactionId
					,[intRelatedTransactionId] = @intRelatedTransactionId
					,[strTransactionForm] = @TransactionTypeName
					,[dtmCreated] = GETDATE()
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId] = 1
			WHERE	@QtyOffset IS NOT NULL 			
			-- Add Revalue sold
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
					,[intTransactionTypeId] = @Inventory_Revalue_Sold
					,[strRelatedTransactionId] = @strRelatedTransactionId
					,[intRelatedTransactionId] = @intRelatedTransactionId
					,[strTransactionForm] = @TransactionTypeName
					,[dtmCreated] = GETDATE()
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId] = 1
			WHERE	@QtyOffset IS NOT NULL 

			-- Get the id used in the inventory transaction insert 
			SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();
			
			-- Insert the record the the fifo-out table
			INSERT INTO dbo.tblICInventoryFIFOOut (
					intInventoryTransactionId
					,intInventoryFIFOId
					,dblQty
					,intRevalueFifoId
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryFIFOId = NULL 
					,dblQty = @QtyOffset
					,intRevalueFifoId = @UpdatedFifoId
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
		WHERE	@NewFifoId IS NOT NULL 
	END 
END 