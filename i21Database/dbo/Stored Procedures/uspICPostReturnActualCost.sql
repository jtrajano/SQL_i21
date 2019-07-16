﻿/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICPostReturnActualCost]
	@strActualCostId AS NVARCHAR(50)
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@intSubLocationId AS INT 
	,@intStorageLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblQty AS NUMERIC(38,20)
	,@dblUOMQty AS NUMERIC(38,20)
	,@dblCost AS NUMERIC(38, 20)
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

DECLARE @NewActualCostId AS INT
DECLARE @UpdatedActualCostId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @intInventoryActualCostOutId AS INT 

DECLARE @intReturnValue AS INT 
		,@dtmCreated AS DATETIME 

-------------------------------------------------
-- 1. Process the Actual Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 

		-- Repeat call on uspICReduceStockInActual until @dblReduceQty is completely distributed to all available Actual buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC @intReturnValue = dbo.uspICReturnStockInActualCost
				@strActualCostId	
				,@intItemId
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
				,@UpdatedActualCostId OUTPUT 

			IF @intReturnValue < 0 GOTO _Exit_With_Error

			IF @UpdatedActualCostId IS NOT NULL 
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
						,@intCostingMethod = @ACTUALCOST
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
						,@intForexRateTypeId = @intForexRateTypeId
						,@dblForexRate = @dblForexRate
						,@strActualCostId = @strActualCostId
						,@intSourceEntityId = @intSourceEntityId
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
				INSERT INTO dbo.tblICInventoryActualCostOOut (
						intInventoryTransactionId
						,intInventoryActualCostId 
						,dblQty
						,dtmCreated
				)
				SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
						,intInventoryActualCostId = @UpdatedActualCostId
						,dblQty = @QtyOffset
						,@dtmCreated
				WHERE	@InventoryTransactionIdentityId IS NOT NULL
						AND @UpdatedActualCostId IS NOT NULL 
						AND @QtyOffset IS NOT NULL 

				SET @intInventoryActualCostOutId = SCOPE_IDENTITY();

				-- Create a log of the return transaction. 
				INSERT INTO tblICInventoryReturned (
					intInventoryActualCostId
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
					intInventoryLIFOId			= @UpdatedActualCostId
					,intInventoryTransactionId	= @InventoryTransactionIdentityId 
					,intOutId					= @intInventoryActualCostOutId 
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