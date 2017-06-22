/*
	This stored procedure will post a Lotted Item. 
*/

CREATE PROCEDURE [dbo].[uspICPostReturnLot]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@intSubLocationId AS INT 
	,@intStorageLocationId AS INT 
	,@dtmDate AS DATETIME
	,@intLotId AS INT
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

DECLARE @NewInventoryLotId AS INT
DECLARE @UpdatedInventoryLotId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @intInventoryLotOutId AS INT 

DECLARE @intReturnValue AS INT 

-------------------------------------------------
-- 1. Process the Lot Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		
		----------------------------------------------------------------------------------------------
		-- Bagged vs Weight. 
		----------------------------------------------------------------------------------------------
		-- 1. If Costing Lot table is using a weight UOM, then convert the UOM and Qty to weight. 
		-- 2. Otherwise, keep the same Qty and UOM. 
		BEGIN 
			SET @dblReduceQty = ISNULL(@dblQty, 0) 

			IF EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryLot CostingLot INNER JOIN dbo.tblICLot Lot
							ON CostingLot.intLotId = Lot.intLotId
				WHERE	CostingLot.intLotId = @intLotId
						AND CostingLot.intItemUOMId = Lot.intWeightUOMId
						AND CostingLot.intItemUOMId <> @intItemUOMId
						AND Lot.intWeightUOMId IS NOT NULL 
						AND ISNULL(CostingLot.ysnIsUnposted, 0) = 0 
						AND (ISNULL(CostingLot.dblStockIn, 0) - ISNULL(CostingLot.dblStockOut, 0)) > 0 
			)			 
			BEGIN 
				-- Retrieve the correct UOM (Lot UOM or Weight UOM)
				-- and also compute the Qty if it has weights. 
				SELECT	@dblReduceQty =	dbo.fnMultiply(Lot.dblWeightPerQty, @dblQty) 
						,@intItemUOMId = Lot.intWeightUOMId 
				FROM	dbo.tblICLot Lot
				WHERE	Lot.intLotId = @intLotId
				
				SET @dblReduceQty = ISNULL(@dblReduceQty, 0) 

				-- Get the unit cost. 
				SET @dblCost = dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty)

				-- Adjust the Unit Qty 
				SELECT @dblUOMQty = dblUnitQty
				FROM dbo.tblICItemUOM
				WHERE intItemUOMId = @intItemUOMId

				-- Adjust the cost to the new UOM
				SET @dblCost = dbo.fnMultiply(@dblCost, @dblUOMQty)
			END 
		END 

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all available Lot buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC @intReturnValue = dbo.uspICReturnStockInLot
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@strBatchId
				,@dtmDate
				,@intLotId
				,@intSubLocationId
				,@intStorageLocationId
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intTransactionDetailId
				,@intEntityUserSecurityId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@UpdatedInventoryLotId OUTPUT 

			IF @intReturnValue < 0 GOTO _Exit_With_Error

			IF @UpdatedInventoryLotId IS NOT NULL 
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
						,@intLotId = @intLotId 
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = NULL 
						,@strRelatedTransactionId = NULL 
						,@strTransactionForm = @strTransactionForm
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@intCostingMethod = @LOTCOST
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
						,@intForexRateTypeId = @intForexRateTypeId
						,@dblForexRate = @dblForexRate

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
					,@intLotId

				IF @intReturnValue < 0 GOTO _Exit_With_Error

				--------------------------------------
				-- Update the Lot's Qty and Weights. 
				--------------------------------------
				BEGIN 
					UPDATE	Lot 
					SET		Lot.dblQty = dbo.fnCalculateLotQty(Lot.intItemUOMId, @intItemUOMId, Lot.dblQty, Lot.dblWeight, @dblQty, Lot.dblWeightPerQty)
							,Lot.dblWeight = dbo.fnCalculateLotWeight(Lot.intItemUOMId, Lot.intWeightUOMId, @intItemUOMId, Lot.dblWeight, @dblQty, Lot.dblWeightPerQty)
					FROM	dbo.tblICLot Lot
					WHERE	Lot.intItemLocationId = @intItemLocationId
							AND Lot.intLotId = @intLotId
				END 

				SET @QtyOffset = -@QtyOffset
				-- Insert the record to the fifo-out table
				INSERT INTO dbo.tblICInventoryLotOut (
						intInventoryTransactionId
						,intInventoryLotId
						,dblQty
				)
				SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
						,intInventoryLotId = @UpdatedInventoryLotId
						,dblQty = @QtyOffset
				WHERE	@InventoryTransactionIdentityId IS NOT NULL
						AND @UpdatedInventoryLotId IS NOT NULL 
						AND @QtyOffset IS NOT NULL 

				SET @intInventoryLotOutId = SCOPE_IDENTITY();

				-- Create a log of the return transaction. 
				INSERT INTO tblICInventoryReturned (
					intInventoryLotId
					,intInventoryTransactionId
					,intOutId
					,dblQtyReturned
					,dblCost
					,intTransactionId
					,strTransactionId
					,strBatchId
					,intTransactionTypeId 
					,intTransactionDetailId	
				)
				SELECT 
					intInventoryLotId			= @UpdatedInventoryLotId
					,intInventoryTransactionId	= @InventoryTransactionIdentityId 
					,intOutId					= @intInventoryLotOutId 
					,dblQtyReturned				= @QtyOffset
					,dblCost					= @CostUsed
					,intTransactionId			= @intTransactionId 
					,strTransactionId			= @strTransactionId
					,strBatchId					= @strBatchId
					,intTransactionTypeId		= @intTransactionTypeId
					,intTransactionDetailId		= @intTransactionDetailId
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