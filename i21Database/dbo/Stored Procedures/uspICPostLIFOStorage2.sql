/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICPostLIFOStorage]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblQty AS NUMERIC(38,20)
	,@dblUOMQty AS NUMERIC(38,20)
	,@dblCost AS NUMERIC(38,20)
	,@dblSalesPrice AS NUMERIC(18,6)
	,@intCurrencyId AS INT
	--,@dblExchangeRate AS NUMERIC(38,20)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@strTransactionForm AS NVARCHAR(255)
	,@intEntityUserSecurityId AS INT
	,@intForexRateTypeId AS INT
	,@dblForexRate AS NUMERIC(38, 20)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5

-- Create the variables for the internal transaction types used by costing. 
DECLARE @Inventory_Auto_Negative AS INT = 1;
DECLARE @Inventory_Write_Off_Sold AS INT = 2;
DECLARE @Inventory_Revalue_Sold AS INT = 3;
DECLARE @INVENTORY_AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35;

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(38,20);
DECLARE @dblReduceQty AS NUMERIC(38,20);
DECLARE @dblAddQty AS NUMERIC(38,20);
DECLARE @CostUsed AS NUMERIC(38,20);
DECLARE @FullQty AS NUMERIC(38,20);
DECLARE @QtyOffset AS NUMERIC(38,20);
DECLARE @TotalQtyOffset AS NUMERIC(38,20);

DECLARE @InventoryTransactionIdentityId AS INT

DECLARE @NewLIFOStorageId AS INT
DECLARE @UpdatedLIFOStorageId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @dblAutoVarianceOnUsedOrSoldStock AS NUMERIC(38, 20)

-------------------------------------------------
-- 1. Process the LIFO Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 

		-- Repeat call on uspICReduceStockInLIFOStorage until @dblReduceQty is completely distributed to all available LIFO buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInLIFOStorage
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intTransactionDetailId
				,@intEntityUserSecurityId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@UpdatedLIFOStorageId OUTPUT 

			---- Insert the inventory transaction record
			DECLARE @dblComputedUnitQty AS NUMERIC(38,20) = @dblReduceQty - ISNULL(@RemainingQty, 0) 
			DECLARE @dblCostToUse AS NUMERIC(38,20) = ISNULL(@CostUsed, @dblCost)

			EXEC [dbo].[uspICPostInventoryTransactionStorage]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = @dblComputedUnitQty
					,@dblUOMQty = @dblUOMQty
					,@dblCost = @dblCostToUse
					,@dblValue = NULL
					,@dblSalesPrice = @dblSalesPrice
					,@intCurrencyId = @intCurrencyId
					--,@dblExchangeRate = @dblExchangeRate
					,@intTransactionId = @intTransactionId
					,@intTransactionDetailId = @intTransactionDetailId
					,@strTransactionId = @strTransactionId
					,@strBatchId = @strBatchId
					,@intTransactionTypeId = @intTransactionTypeId
					,@intLotId = NULL 
					,@intRelatedInventoryTransactionId = NULL 
					,@intRelatedTransactionId = NULL 
					,@strRelatedTransactionId = NULL 
					,@strTransactionForm = @strTransactionForm
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@intCostingMethod = @LIFO
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
					,@intForexRateTypeId = @intForexRateTypeId
					,@dblForexRate = @dblForexRate
		
			-- Insert the record the the LIFO-out table
			INSERT INTO dbo.tblICInventoryLIFOStorageOut (
					intInventoryTransactionStorageId
					,intInventoryLIFOStorageId
					,dblQty
			)
			SELECT	intInventoryTransactionStorageId = @InventoryTransactionIdentityId
					,intInventoryLIFOStorageId = @UpdatedLIFOStorageId
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedLIFOStorageId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 
			
			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
		END 
	END

	-- Add stock 
	ELSE IF (ISNULL(@dblQty, 0) > 0)
	BEGIN 

		SET @dblAddQty = ISNULL(@dblQty, 0) 
		SET @FullQty = @dblAddQty
		SET @TotalQtyOffset = 0;

		-- Insert the inventory transaction record
		EXEC [dbo].[uspICPostInventoryTransactionStorage]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = @intItemUOMId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = @intStorageLocationId
				,@dtmDate = @dtmDate
				,@dblQty = @FullQty
				,@dblUOMQty = @dblUOMQty
				,@dblCost = @dblCost
				,@dblValue = NULL
				,@dblSalesPrice = @dblSalesPrice
				,@intCurrencyId = @intCurrencyId
				--,@dblExchangeRate = @dblExchangeRate
				,@intTransactionId = @intTransactionId
				,@intTransactionDetailId = @intTransactionDetailId
				,@strTransactionId = @strTransactionId
				,@strBatchId = @strBatchId
				,@intTransactionTypeId = @intTransactionTypeId
				,@intLotId = NULL 
				,@intRelatedInventoryTransactionId = NULL 
				,@intRelatedTransactionId = NULL 
				,@strRelatedTransactionId = NULL 
				,@strTransactionForm = @strTransactionForm
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@intCostingMethod = @LIFO
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
				,@intForexRateTypeId = @intForexRateTypeId
				,@dblForexRate = @dblForexRate

		-- Repeat call on uspICIncreaseStockInLIFO until @dblAddQty is completely distributed to the negative cost LIFO buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInLIFOStorage
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblAddQty
				,@dblCost
				,@intEntityUserSecurityId
				,@FullQty
				,@TotalQtyOffset
				,@strTransactionId
				,@intTransactionId
				,@intTransactionDetailId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@NewLIFOStorageId OUTPUT 
				,@UpdatedLIFOStorageId OUTPUT 
				,@strRelatedTransactionId OUTPUT
				,@intRelatedTransactionId OUTPUT 

			SET @dblAddQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Insert the inventory transaction record					
			IF @QtyOffset IS NOT NULL
			BEGIN 				
				-- If there is a cost difference, do an auto-variance. 
				IF (ISNULL(@CostUsed, 0) <> @dblCost)
				BEGIN
					-- Calculate the variance amount. 
					SET @dblAutoVarianceOnUsedOrSoldStock = 						
						- dbo.fnMultiply(@QtyOffset, @dblCost) -- Revalue Sold
						+ dbo.fnMultiply(@QtyOffset, ISNULL(@CostUsed, 0))  -- Write Off Sold

				EXEC [dbo].[uspICPostInventoryTransactionStorage]
						@intItemId = @intItemId
						,@intItemLocationId = @intItemLocationId
						,@intItemUOMId = @intItemUOMId
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId					 
						,@dtmDate = @dtmDate
						,@dblQty = 0
						,@dblCost = 0
						,@dblUOMQty = 0
						,@dblValue = @dblAutoVarianceOnUsedOrSoldStock
						,@dblSalesPrice = @dblSalesPrice
						,@intCurrencyId = @intCurrencyId
						--,@dblExchangeRate = @dblExchangeRate
						,@intTransactionId = @intTransactionId
						,@intTransactionDetailId = @intTransactionDetailId
						,@strTransactionId = @strTransactionId
						,@strBatchId = @strBatchId
						,@intTransactionTypeId = @INVENTORY_AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK
						,@intLotId = NULL 
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = @intRelatedTransactionId
						,@strRelatedTransactionId = @strRelatedTransactionId 
						,@strTransactionForm = @strTransactionForm
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@intCostingMethod = @FIFO
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
						,@intForexRateTypeId = @intForexRateTypeId
						,@dblForexRate = @dblForexRate
				END
			END

			-- Insert the record the the LIFO-out table
			INSERT INTO dbo.tblICInventoryLIFOStorageOut (
					intInventoryTransactionStorageId
					,intInventoryLIFOStorageId
					,dblQty
					,intRevalueLifoId
			)		
			SELECT	intInventoryTransactionStorageId = @InventoryTransactionIdentityId
					,intInventoryLIFOStorageId = NULL 
					,dblQty = @QtyOffset
					,intRevalueLifoId = @UpdatedLIFOStorageId
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedLIFOStorageId IS NOT NULL 
					AND @QtyOffset IS NOT NULL

			SET @dblAddQty = @RemainingQty;
		END 

		-- Update the LIFO out table and assign the correct LIFO id. 
		UPDATE	LIFOStorageOut
		SET		LIFOStorageOut.intInventoryLIFOStorageId = @NewLIFOStorageId
		FROM	dbo.tblICInventoryLIFOStorageOut LIFOStorageOut INNER JOIN dbo.tblICInventoryTransactionStorage TRANS
					ON LIFOStorageOut.intInventoryTransactionStorageId = TRANS.intInventoryTransactionStorageId 
					AND LIFOStorageOut.intInventoryLIFOStorageId IS NULL 
					AND TRANS.intItemId = @intItemId
					AND TRANS.intItemLocationId = @intItemLocationId
					AND TRANS.intItemUOMId = @intItemUOMId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
		WHERE	@NewLIFOStorageId IS NOT NULL 
	END 
END 