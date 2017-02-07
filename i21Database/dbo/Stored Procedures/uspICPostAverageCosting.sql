/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 
	@intItemId - The item to process

	@intLocationId - The location where the item is being process. 

	@intItemUOMId - The UOM used for the item in a transaction. Each transaction can use different kinds of UOM on its items. 
	
	@dtmDate - The date used in the transaction and posting. 

	@dblQty - A positive qty indicates an increase of stock. A negative qty indicates a decrease in stock. 

	@dblUOMQty - The stock unit qty associated with the UOM. For example, a box may have 10 pieces of an item. In this case, UOM qty will be 10. 

	@dblCost - The cost per base qty of the item. 

	@dblSalesPrice - The sales price of an item sold to the customer. 

	@intCurrencyId - The foreign currency associated with the transaction. 

	@dblExchangeRate - The conversion factor between the base currency and the foreign currency. 

	@intTransactionId - The primary key id used in a transaction. 

	@strTransactionId - The string value of a transaction id. 

	@strBatchId - The batch id to use in generating the g/l entries. 

	@intEntityUserSecurityId - The user who initiated or called this stored procedure. 
*/

CREATE PROCEDURE [dbo].[uspICPostAverageCosting]
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
	,@dblForexRate NUMERIC(38, 20) 
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
DECLARE @INVENTORY_AUTO_VARIANCE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
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

DECLARE @NewFifoId AS INT
DECLARE @UpdatedFifoId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @dblAutoVarianceOnUsedOrSoldStock AS NUMERIC(38,20)

DECLARE @TransactionType_InventoryReceipt AS INT = 4

-------------------------------------------------
-- 1. Process the Fifo Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0)

		-- Get the average cost when reducing stock. 
		-- Except if doing vendor stock returns using Inventory Receipt. 
		SELECT	@dblCost = AverageCost
		FROM	dbo.fnGetItemAverageCostAsTable(@intItemId, @intItemLocationId, @intItemUOMId)
		WHERE	@intTransactionTypeId <> @TransactionType_InventoryReceipt

		EXEC [dbo].[uspICPostInventoryTransaction]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = @intItemUOMId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = @intStorageLocationId
				,@dtmDate = @dtmDate
				,@dblQty  = @dblQty
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
				,@intCostingMethod = @AVERAGECOST
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
				,@intForexRateTypeId = @intForexRateTypeId
				,@dblForexRate = @dblForexRate

		-- Repeat call on uspICReduceStockInFIFO until @dblReduceQty is completely distributed to all available fifo buckets 
		-- If there is no avaiable fifo buckets, it will add a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInFIFO
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intEntityUserSecurityId
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
	ELSE IF (ISNULL(@dblQty, 0) > 0)
	BEGIN 

		SET @dblAddQty = ISNULL(@dblQty, 0)
		SET @FullQty = @dblAddQty
		SET @TotalQtyOffset = 0;
		
		EXEC [dbo].[uspICPostInventoryTransaction]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = @intItemUOMId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = @intStorageLocationId
				,@dtmDate = @dtmDate
				,@dblQty = @dblQty
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
				,@intCostingMethod = @AVERAGECOST
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT			
				,@intForexRateTypeId = @intForexRateTypeId
				,@dblForexRate = @dblForexRate

		-- Repeat call on uspICIncreaseStockInFIFO until @dblAddQty is completely distributed to the negative cost fifo buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInFIFO
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
				,@NewFifoId OUTPUT 
				,@UpdatedFifoId OUTPUT
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

					EXEC [dbo].[uspICPostInventoryTransaction]
							@intItemId = @intItemId
							,@intItemLocationId = @intItemLocationId
							,@intItemUOMId = @intItemUOMId
							,@intSubLocationId = @intSubLocationId
							,@intStorageLocationId = @intStorageLocationId
							,@dtmDate = @dtmDate
							,@dblQty = 0
							,@dblUOMQty = 0
							,@dblCost = 0
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
							,@intCostingMethod = @AVERAGECOST
							,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
							,@intForexRateTypeId = @intForexRateTypeId
							,@dblForexRate = @dblForexRate
				END 
			END
			
			-- Insert the record to the fifo-out table
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
					AND TRANS.intItemLocationId = @intItemLocationId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
					AND @NewFifoId IS NOT NULL  	

		SET @dblValue = 0
		SELECT	@dblValue = dbo.fnMultiply(
								(dbo.fnMultiply(@dblQty, @dblUOMQty) + Stock.dblUnitOnHand) 								
								,dbo.fnDivide(@dblCost, @dblUOMQty)
							) 
							- [dbo].[fnGetItemTotalValueFromTransactions](@intItemId, @intItemLocationId)
		FROM	[dbo].[tblICItemStock] Stock
		WHERE	dbo.fnMultiply(@dblQty, @dblUOMQty) + Stock.dblUnitOnHand < 0 
				AND dbo.fnMultiply(@dblQty, @dblUOMQty) > 0 
				AND Stock.intItemId = @intItemId
				AND Stock.intItemLocationId = @intItemLocationId				

		IF ISNULL(@dblValue, 0) <> 0
		BEGIN 
			EXEC [dbo].[uspICPostInventoryTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId
					,@dtmDate = @dtmDate
					,@dblQty = 0
					,@dblUOMQty = 0
					,@dblCost = 0
					,@dblValue = @dblValue
					,@dblSalesPrice = @dblSalesPrice
					,@intCurrencyId = @intCurrencyId
					--,@dblExchangeRate = @dblExchangeRate
					,@intTransactionId = @intTransactionId
					,@intTransactionDetailId = @intTransactionDetailId
					,@strTransactionId = @strTransactionId
					,@strBatchId = @strBatchId
					,@intTransactionTypeId = @INVENTORY_AUTO_VARIANCE
					,@intLotId = NULL 
					,@intRelatedInventoryTransactionId = NULL 
					,@intRelatedTransactionId = NULL
					,@strRelatedTransactionId = NULL 
					,@strTransactionForm = @strTransactionForm
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@intCostingMethod = @AVERAGECOST
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
					,@intForexRateTypeId = @intForexRateTypeId
					,@dblForexRate = @dblForexRate
		END 
	END 
END 