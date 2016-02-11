/*
	This stored procedure will post stocks that is not owned by the company. 
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
	,@dblExchangeRate AS NUMERIC(38,20)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@strTransactionForm AS NVARCHAR(255) 
	,@intEntityUserSecurityId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(38,20);
DECLARE @dblReduceQty AS NUMERIC(38,20);
DECLARE @dblAddQty AS NUMERIC(38,20);
DECLARE @CostUsed AS NUMERIC(38,20);

DECLARE @NewInventoryCostBucketStorageId AS INT
DECLARE @UpdatedCostBucketStorageId AS INT 
DECLARE @NewInventoryTransactionStorageId AS INT

-------------------------------------------------
-- 1. Process the LIFO Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all available Lot In Storage. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInLIFOStorage
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intEntityUserSecurityId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@UpdatedCostBucketStorageId OUTPUT

			IF @@ERROR <> 0 GOTO _Exit

			-- Insert the inventory transaction record
			DECLARE @dblComputedReduceQty AS NUMERIC(38,20) = @dblReduceQty - ISNULL(@RemainingQty, 0) 
			DECLARE @dblCostToUse AS NUMERIC(38,20) = ISNULL(@CostUsed, @dblCost)

			EXEC [dbo].[uspICPostInventoryTransactionStorage]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = @dblComputedReduceQty
					,@dblUOMQty = @dblUOMQty
					,@dblCost = @dblCostToUse
					,@dblValue = NULL
					,@dblSalesPrice = @dblSalesPrice
					,@intCurrencyId = @intCurrencyId
					,@dblExchangeRate = @dblExchangeRate
					,@intTransactionId = @intTransactionId
					,@intTransactionDetailId = @intTransactionDetailId
					,@strTransactionId = @strTransactionId
					,@strBatchId = @strBatchId
					,@intTransactionTypeId = @intTransactionTypeId
					,@intLotId = NULL 
					,@strTransactionForm = @strTransactionForm
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@SourceCostBucketStorageId = @UpdatedCostBucketStorageId
					,@InventoryTransactionIdStorageId = @NewInventoryTransactionStorageId OUTPUT			
			
			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
		END 
	END

	-- Add stock 
	ELSE IF (ISNULL(@dblQty, 0) > 0)
	BEGIN 
		SET @dblAddQty = ISNULL(@dblQty, 0) 

		EXEC dbo.uspICIncreaseStockInLIFOStorage
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@dtmDate
			,@dblQty
			,@dblCost
			,@intEntityUserSecurityId
			,@strTransactionId
			,@intTransactionId
			,@intTransactionDetailId
			,@NewInventoryCostBucketStorageId OUTPUT 


		IF @@ERROR <> 0 GOTO _Exit

		EXEC [dbo].[uspICPostInventoryTransactionStorage]
			@intItemId = @intItemId
			,@intItemLocationId = @intItemLocationId
			,@intItemUOMId = @intItemUOMId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId					 
			,@dtmDate = @dtmDate
			,@dblQty = @dblAddQty
			,@dblUOMQty = @dblUOMQty
			,@dblCost = @dblCost
			,@dblValue = NULL
			,@dblSalesPrice = @dblSalesPrice
			,@intCurrencyId = @intCurrencyId
			,@dblExchangeRate = @dblExchangeRate
			,@intTransactionId = @intTransactionId
			,@intTransactionDetailId = @intTransactionDetailId
			,@strTransactionId = @strTransactionId
			,@strBatchId = @strBatchId
			,@intTransactionTypeId = @intTransactionTypeId
			,@intLotId = NULL  
			,@strTransactionForm = @strTransactionForm
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@SourceCostBucketStorageId = @NewInventoryCostBucketStorageId
			,@InventoryTransactionIdStorageId = @NewInventoryTransactionStorageId OUTPUT						
	END 
END 

_Exit: