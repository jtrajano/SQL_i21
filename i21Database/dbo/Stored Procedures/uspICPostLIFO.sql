/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICPostLIFO]
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

DECLARE @NewLIFOId AS INT
DECLARE @UpdatedLIFOId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 

-- Initialize the transaction name. Use this as the transaction form name
DECLARE @TransactionTypeName AS NVARCHAR(200) 
SELECT	TOP 1 
		@TransactionTypeName = strName
FROM	dbo.tblICInventoryTransactionType
WHERE	intTransactionTypeId = @intTransactionTypeId

-------------------------------------------------
-- 1. Process the LIFO Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0)

		-- Repeat call on uspICReduceStockInLIFO until @dblReduceQty is completely distributed to all available LIFO buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInLIFO
				@intItemId
				,@intItemLocationId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@UpdatedLIFOId OUTPUT 

			-- Insert the inventory transaction record
			INSERT INTO dbo.tblICInventoryTransaction (
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
				,[strTransactionForm]
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
					,[strTransactionForm] = @TransactionTypeName
					,[dtmCreated] = GETDATE()
					,[intCreatedUserId] = @intUserId
					,[intConcurrencyId] = 1

			-- Get the id used in the inventory transaction insert 
			SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();
			
			-- Insert the record the the LIFO-out table
			INSERT INTO dbo.tblICInventoryLIFOOut (
					intInventoryTransactionId
					,intInventoryLIFOId
					,dblQty
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryLIFOId = @UpdatedLIFOId
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedLIFOId IS NOT NULL 
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
			,[strTransactionForm]
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 
		)			
		SELECT	[intItemId] = @intItemId
				,[intLocationId] = @intItemLocationId
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

		-- Repeat call on uspICIncreaseStockInLIFO until @dblAddQty is completely distributed to the negative cost LIFO buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInLIFO
				@intItemId
				,@intItemLocationId
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
				,@NewLIFOId OUTPUT 
				,@UpdatedLIFOId OUTPUT 
				,@strRelatedTransactionId OUTPUT
				,@intRelatedTransactionId OUTPUT 

			SET @dblAddQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Insert the inventory transaction record
			INSERT INTO dbo.tblICInventoryTransaction (
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
				,[strRelatedTransactionId]
				,[intRelatedTransactionId]
				,[strTransactionForm]
				,[dtmCreated] 
				,[intCreatedUserId] 
				,[intConcurrencyId] 
			)
			-- Add Write-Off Sold
			SELECT	[intItemId] = @intItemId
					,[intItemLocationId] = @intItemLocationId
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
					,[intItemLocationId] = @intItemLocationId
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
			
			-- Insert the record the the LIFO-out table
			INSERT INTO dbo.tblICInventoryLIFOOut (
					intInventoryTransactionId
					,intInventoryLIFOId
					,dblQty
					,intRevalueLifoId
			)		
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryLIFOId = NULL 
					,dblQty = @QtyOffset
					,intRevalueLifoId = @UpdatedLIFOId
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedLIFOId IS NOT NULL 
					AND @QtyOffset IS NOT NULL

			SET @dblAddQty = @RemainingQty;
		END 

		-- Update the LIFO out table and assign the correct LIFO id. 
		UPDATE	LIFOOut
		SET		LIFOOut.intInventoryLIFOId = @NewLIFOId
		FROM	dbo.tblICInventoryLIFOOut LIFOOut INNER JOIN dbo.tblICInventoryTransaction TRANS
					ON LIFOOut.intInventoryTransactionId = TRANS.intInventoryTransactionId 
					AND LIFOOut.intInventoryLIFOId IS NULL 
					AND TRANS.intItemId = @intItemId
					AND TRANS.intItemLocationId = @intItemLocationId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
		WHERE	@NewLIFOId IS NOT NULL 
	END 
END 