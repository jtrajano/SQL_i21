/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICPostFIFO]
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
	,@strBatchId AS NVARCHAR(40)
	,@intTransactionTypeId AS INT
	,@strTransactionForm AS NVARCHAR(255)
	,@intEntityUserSecurityId AS INT
	,@intForexRateTypeId AS INT
	,@dblForexRate NUMERIC(38, 20)
	,@dblUnitRetail NUMERIC(38, 20)
	,@intSourceEntityId INT = NULL
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

DECLARE @strDescription AS NVARCHAR(255)
		,@dblLastCost AS NUMERIC(38,20)

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_VARIANCE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
DECLARE @INVENTORY_AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35;
DECLARE @INVENTORY_MarkUpOrDown AS INT = 49;
DECLARE @INVENTORY_WriteOff AS INT = 50;

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(38,20);
DECLARE @dblReduceQty AS NUMERIC(38,20);
DECLARE @dblAddQty AS NUMERIC(38,20);
DECLARE @CostUsed AS NUMERIC(38,20);
DECLARE @FullQty AS NUMERIC(38,20);
DECLARE @QtyOffset AS NUMERIC(38,20);
DECLARE @TotalQtyOffset AS NUMERIC(38,20);
DECLARE @CategoryCostValue AS NUMERIC(38,20);
DECLARE @CategoryRetailValue AS NUMERIC(38,20);

DECLARE @InventoryTransactionIdentityId AS INT

DECLARE @NewFifoId AS INT
DECLARE @UpdatedFifoId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @dblAutoVarianceOnUsedOrSoldStock AS NUMERIC(38,20)

DECLARE @TransactionType_InventoryReceipt AS INT = 4
		,@TransactionType_InventoryReturn AS INT = 42
		,@TransactionType_InventoryAdjustment_OpeningInventory AS INT = 47

DECLARE @intReturnValue AS INT 
		,@dtmCreated AS DATETIME 

IF EXISTS (SELECT 1 FROM tblICItem i WHERE i.intItemId = @intItemId AND ISNULL(i.ysnSeparateStockForUOMs, 0) = 0) 
BEGIN 	
	-- Replace the UOM to 'Stock Unit'. 
	-- Convert the Qty, Cost, and Sales Price to stock UOM. 
	SELECT 
		@dblQty = dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblQty)
		,@dblCost = dbo.fnCalculateCostBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblCost)
		,@dblSalesPrice = dbo.fnCalculateCostBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblSalesPrice)
		,@intItemUOMId = iu.intItemUOMId
		,@dblUOMQty = iu.dblUnitQty
	FROM 
		tblICItemUOM iu 
	WHERE 
		iu.intItemId = @intItemId 		
		AND iu.ysnStockUnit = 1
		AND iu.intItemUOMId <> @intItemUOMId -- Do not do the conversion if @intItemUOMId is already the stock uom. 
END 

-------------------------------------------------
-- 1. Process the Fifo Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 

		-- Get the item's last cost when reducing stock or standard cost. 
		-- Except if (1) doing vendor stock returns using Inventory Receipt/Return or (2) if it is an Opening Inventory
		SELECT	@dblLastCost = COALESCE(
					NULLIF(ItemPricing.dblLastCost, 0)
					, ItemPricing.dblStandardCost
				)
		FROM	tblICItemPricing ItemPricing 
		WHERE	@intTransactionTypeId NOT IN (
					@TransactionType_InventoryReceipt
					,@TransactionType_InventoryReturn
					,@TransactionType_InventoryAdjustment_OpeningInventory
				)
				AND ItemPricing.intItemId = @intItemId
				AND ItemPricing.intItemLocationId = @intItemLocationId
		
		-- Convert the Cost from Stock UOM to @intItemUOMId 
		SELECT	@dblCost = dbo.fnCalculateCostBetweenUOM(StockUOM.intItemUOMId, @intItemUOMId, @dblLastCost) 
		FROM	tblICItemUOM StockUOM
		WHERE	StockUOM.intItemId = @intItemId
				AND StockUOM.ysnStockUnit = 1
				AND @dblLastCost IS NOT NULL 

		-- Make sure the cost is not null. 
		SET @dblCost = ISNULL(@dblCost, 0) 

		-- Repeat call on uspICReduceStockInFIFO until @dblReduceQty is completely distributed to all available fifo buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC @intReturnValue = dbo.uspICReduceStockInFIFO
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
				,@UpdatedFifoId OUTPUT 
				
			IF @intReturnValue < 0 RETURN @intReturnValue;			

			-- Insert the inventory transaction record
			DECLARE @dblComputedQty AS NUMERIC(38,20) = @dblReduceQty - ISNULL(@RemainingQty, 0) 
			DECLARE @dblCostToUse AS NUMERIC(38,20) = ISNULL(@CostUsed, @dblCost)

			EXEC @intReturnValue = [dbo].[uspICPostInventoryTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = @dblComputedQty
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
					,@intCostingMethod = @FIFO
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
					,@intForexRateTypeId = @intForexRateTypeId
					,@dblForexRate = @dblForexRate
					,@dblUnitRetail = @dblUnitRetail
					,@intSourceEntityId = @intSourceEntityId
					,@dtmCreated = @dtmCreated OUTPUT 

			IF @intReturnValue < 0 RETURN @intReturnValue;			
			
			-- Insert the record the the fifo-out table
			INSERT INTO dbo.tblICInventoryFIFOOut (
					intInventoryTransactionId
					,intInventoryFIFOId
					,dblQty
					,dtmCreated
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryFIFOId = @UpdatedFifoId
					,dblQty = @QtyOffset
					,@dtmCreated
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedFifoId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 
			
			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
		END 
	END

	-- Add stock 
	ELSE IF (ISNULL(@dblQty, 0) > 0 AND @intTransactionTypeId != @INVENTORY_MarkUpOrDown)
	BEGIN 

		SET @dblAddQty = ISNULL(@dblQty, 0) 
		SET @FullQty = @dblAddQty
		SET @TotalQtyOffset = 0;
		
		-- Insert the inventory transaction record
		EXEC @intReturnValue = [dbo].[uspICPostInventoryTransaction]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = @intItemUOMId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = @intStorageLocationId					 
				,@dtmDate = @dtmDate
				,@dblQty = @FullQty
				,@dblCost = @dblCost
				,@dblUOMQty = @dblUOMQty
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
				,@intCostingMethod = @FIFO
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 			
				,@intForexRateTypeId = @intForexRateTypeId
				,@dblForexRate = @dblForexRate
				,@dblUnitRetail = @dblUnitRetail
				,@intSourceEntityId = @intSourceEntityId
				,@dtmCreated = @dtmCreated OUTPUT 

		IF @intReturnValue < 0 RETURN @intReturnValue;

		-- Repeat call on uspICIncreaseStockInFIFO until @dblAddQty is completely distributed to the negative cost fifo buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC @intReturnValue = dbo.uspICIncreaseStockInFIFO
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

			IF @intReturnValue < 0 RETURN @intReturnValue;

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
					
					-- 'Inventory variance is created to adjust the negative stock from {Transaction Id}. Qty was {Quantity}. Cost was {Original Cost}. New cost is {New Cost}.'
					SET @strDescription =
							dbo.fnFormatMessage(
								dbo.fnICGetErrorMessage(80224)
								,@strRelatedTransactionId
								,@QtyOffset
								,@CostUsed
								,@dblCost
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
								, DEFAULT
							)

					EXEC @intReturnValue =  [dbo].[uspICPostInventoryTransaction]
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
							,@intCostingMethod = @FIFO
							,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
							,@intForexRateTypeId = @intForexRateTypeId
							,@dblForexRate = @dblForexRate
							,@dblUnitRetail = @dblUnitRetail
							,@strDescription = @strDescription
							,@intSourceEntityId = @intSourceEntityId
							,@dtmCreated = @dtmCreated OUTPUT 

					IF @intReturnValue < 0 RETURN @intReturnValue;
				END 
			END
			
			-- Insert the record the the fifo-out table
			INSERT INTO dbo.tblICInventoryFIFOOut (
					intInventoryTransactionId
					,intInventoryFIFOId
					,dblQty
					,intRevalueFifoId
					,dtmCreated
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryFIFOId = NULL 
					,dblQty = @QtyOffset
					,intRevalueFifoId = @UpdatedFifoId
					,@dtmCreated
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
					AND TRANS.intItemUOMId = @intItemUOMId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
		WHERE	@NewFifoId IS NOT NULL 
	END 

	-- Do Mark Up/Down. Only the Retail Value will be affected, not the cost.
	ELSE IF @intTransactionTypeId = @INVENTORY_MarkUpOrDown AND ISNULL(@dblUnitRetail, 0) <> 0 
	BEGIN
		SET @CategoryRetailValue = @dblUnitRetail 

		EXEC @intReturnValue = [dbo].[uspICPostInventoryTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = @dblComputedQty
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
					,@intCostingMethod = @FIFO
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
					,@intForexRateTypeId = @intForexRateTypeId
					,@dblForexRate = @dblForexRate
					,@dblUnitRetail = 0
					,@dblCategoryRetailValue = @CategoryRetailValue
					,@intSourceEntityId = @intSourceEntityId
					,@dtmCreated = @dtmCreated OUTPUT 

		IF @intReturnValue < 0 RETURN @intReturnValue;
	END
END 
