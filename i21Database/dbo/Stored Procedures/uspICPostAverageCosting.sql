﻿/*
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

DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5

-- Create the variables for the internal transaction types used by costing. 
DECLARE @Inventory_Auto_Negative AS INT = 1;
DECLARE @Inventory_Write_Off_Sold AS INT = 2;
DECLARE @Inventory_Revalue_Sold AS INT = 3;

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
				,@dblExchangeRate = @dblExchangeRate
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
				,@dblExchangeRate = @dblExchangeRate
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
				-- Add Write-Off Sold				
				SELECT @dblValue = @QtyOffset * ISNULL(@CostUsed, 0) --dbo.fnGetItemAverageCost(@intItemId, @intItemLocationId)
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
						,@dblExchangeRate = @dblExchangeRate
						,@intTransactionId = @intTransactionId
						,@intTransactionDetailId = @intTransactionDetailId
						,@strTransactionId = @strTransactionId
						,@strBatchId = @strBatchId
						,@intTransactionTypeId = @Inventory_Write_Off_Sold
						,@intLotId = NULL 
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = @intRelatedTransactionId
						,@strRelatedTransactionId = @strRelatedTransactionId 
						,@strTransactionForm = @strTransactionForm
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@intCostingMethod = @AVERAGECOST
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 

				-- Add Revalue sold
				SET @dblValue =  @QtyOffset * @dblCost * -1
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
						,@dblExchangeRate = @dblExchangeRate
						,@intTransactionId = @intTransactionId
						,@intTransactionDetailId = @intTransactionDetailId
						,@strTransactionId = @strTransactionId
						,@strBatchId = @strBatchId
						,@intTransactionTypeId = @Inventory_Revalue_Sold
						,@intLotId = NULL 
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = @intRelatedTransactionId
						,@strRelatedTransactionId = @strRelatedTransactionId 
						,@strTransactionForm = @strTransactionForm
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@intCostingMethod = @AVERAGECOST
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
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
		SELECT	@dblValue = (((@dblQty * @dblUOMQty) + Stock.dblUnitOnHand) * (@dblCost / @dblUOMQty)) 
							- [dbo].[fnGetItemTotalValueFromTransactions](@intItemId, @intItemLocationId)
		FROM	[dbo].[tblICItemStock] Stock
		WHERE	(@dblQty * @dblUOMQty) + Stock.dblUnitOnHand < 0 
				AND (@dblQty * @dblUOMQty) > 0 
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
					,@dblExchangeRate = @dblExchangeRate
					,@intTransactionId = @intTransactionId
					,@intTransactionDetailId = @intTransactionDetailId
					,@strTransactionId = @strTransactionId
					,@strBatchId = @strBatchId
					,@intTransactionTypeId = @Inventory_Auto_Negative
					,@intLotId = NULL 
					,@intRelatedInventoryTransactionId = NULL 
					,@intRelatedTransactionId = NULL
					,@strRelatedTransactionId = NULL 
					,@strTransactionForm = @strTransactionForm
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@intCostingMethod = @AVERAGECOST
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
		END 
	END 
END 