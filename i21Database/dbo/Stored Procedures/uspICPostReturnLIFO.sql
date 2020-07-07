/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICPostReturnLIFO]
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

DECLARE @NewLIFOId AS INT
DECLARE @UpdatedLIFOId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @intInventoryLIFOOutId AS INT 

DECLARE @intReturnValue AS INT 
		,@dtmCreated AS DATETIME 
		,@intTransactionItemUOMId AS INT = @intItemUOMId 

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
-- 1. Process the LIFO Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 

		-- Repeat call on uspICReduceStockInLIFO until @dblReduceQty is completely distributed to all available LIFO buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC @intReturnValue = dbo.uspICReturnStockInLIFO
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@strBatchId
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
				,@UpdatedLIFOId OUTPUT 

			IF @intReturnValue < 0 GOTO _Exit_With_Error

			IF @UpdatedLIFOId IS NOT NULL 
			BEGIN 
				------------------------------------------------------------
				-- Create the Inventory Transaction 
				------------------------------------------------------------
				EXEC @intReturnValue = [dbo].[uspICPostInventoryTransaction]
						@intItemId = @intItemId
						,@intItemLocationId = @intItemLocationId
						,@intItemUOMId = @intItemUOMId
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId
						,@dtmDate = @dtmDate
						,@dblQty  = @QtyOffset --@dblQty
						,@dblUOMQty = @dblUOMQty
						,@dblCost = @CostUsed -- @dblCost
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
						,@intSourceEntityId = @intSourceEntityId
						,@intTransactionItemUOMId = @intTransactionItemUOMId
						,@dtmCreated = @dtmCreated OUTPUT 

				IF @intReturnValue < 0 GOTO _Exit_With_Error

				------------------------------------------------------------
				-- Update the Stock Quantity
				------------------------------------------------------------
				EXEC @intReturnValue = [dbo].[uspICPostStockQuantity]
					@intItemId
					,@intItemLocationId
					,@intSubLocationId
					,@intStorageLocationId
					,@intItemUOMId
					,@QtyOffset
					,@dblUOMQty
					,NULL --,@intLotId
					,@intTransactionTypeId
					,@dtmDate

				IF @intReturnValue < 0 GOTO _Exit_With_Error

				SET @QtyOffset = -@QtyOffset
				-- Insert the record to the fifo-out table
				INSERT INTO dbo.tblICInventoryLIFOOut (
						intInventoryTransactionId
						,intInventoryLIFOId
						,dblQty
						,dtmCreated
				)
				SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
						,intInventoryLIFOId = @UpdatedLIFOId
						,dblQty = @QtyOffset
						,@dtmCreated
				WHERE	@InventoryTransactionIdentityId IS NOT NULL
						AND @UpdatedLIFOId IS NOT NULL 
						AND @QtyOffset IS NOT NULL 

				SET @intInventoryLIFOOutId = SCOPE_IDENTITY();

				-- Create a log of the return transaction. 
				INSERT INTO tblICInventoryReturned (
					intInventoryLIFOId
					,intInventoryTransactionId
					,intOutId
					,dblQtyReturned
					,dblCost
					,intTransactionId
					,strTransactionId
					,strBatchId
					,intTransactionTypeId 
					,intTransactionDetailId
					,dtmCreated
				)
				SELECT 
					intInventoryLIFOId			= @UpdatedLIFOId
					,intInventoryTransactionId	= @InventoryTransactionIdentityId 
					,intOutId					= @intInventoryLIFOOutId 
					,dblQtyReturned				= @QtyOffset
					,dblCost					= @CostUsed
					,intTransactionId			= @intTransactionId 
					,strTransactionId			= @strTransactionId
					,strBatchId					= @strBatchId
					,intTransactionTypeId		= @intTransactionTypeId
					,intTransactionDetailId		= @intTransactionDetailId
					,dtmCreated					= @dtmCreated
			END 
			
			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
		END 
	END
END 

_Exit: 
RETURN 1

_Exit_With_Error: 
RETURN @intReturnValue