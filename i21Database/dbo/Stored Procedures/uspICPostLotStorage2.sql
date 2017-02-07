/*
	This stored procedure will post a Lotted Item. 
*/

CREATE PROCEDURE [dbo].[uspICPostLotStorage]
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

DECLARE @NewInventoryLotStorageId AS INT
DECLARE @UpdatedInventoryLotId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @dblAutoVarianceOnUsedOrSoldStock AS NUMERIC(38, 20)

-------------------------------------------------
-- 1. Process the Lot Storage Cost buckets
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
				FROM	dbo.tblICInventoryLotStorage CostingLot INNER JOIN dbo.tblICLot Lot
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
				SELECT	@dblReduceQty =	Lot.dblWeightPerQty * @dblQty
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
				SET @dblCost = @dblCost * @dblUOMQty
			END 
		END 

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all available Lot buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInLotStorage
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
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

			-- Calculate the stock reduced
			-- Get the cost used. It is usually the cost from the cost bucket or the last cost. 
			DECLARE @dblReduceStockQty AS NUMERIC(38,20) = ISNULL(-@QtyOffset, @dblReduceQty - ISNULL(@RemainingQty, 0))
			DECLARE @dblCostToUse AS NUMERIC(38,20) = ISNULL(@CostUsed, @dblCost)

			EXEC [dbo].[uspICPostInventoryTransactionStorage]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = @dblReduceStockQty
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

			-- Insert the record the the Lot-out table
			INSERT INTO dbo.tblICInventoryLotStorageOut (
					intInventoryTransactionStorageId
					,intInventoryLotStorageId
					,dblQty
			)
			SELECT	intInventoryTransactionStorageId = @InventoryTransactionIdentityId
					,intInventoryLotStorageId = @UpdatedInventoryLotId
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedInventoryLotId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 
			
			-- Update the Lot's Qty and Weights. 
			BEGIN 
				UPDATE	Lot 
				SET		Lot.dblQty =	
							dbo.fnCalculateLotQty(
								Lot.intItemUOMId
								, @intItemUOMId
								, Lot.dblQty
								, Lot.dblWeight
								, @dblReduceStockQty 
								, Lot.dblWeightPerQty
							)
						,Lot.dblWeight = 
							dbo.fnCalculateLotWeight(
								Lot.intItemUOMId
								, Lot.intWeightUOMId
								, @intItemUOMId 
								, Lot.dblWeight
								, @dblReduceStockQty 
								, Lot.dblWeightPerQty
							)
				FROM	dbo.tblICLot Lot
				WHERE	Lot.intItemLocationId = @intItemLocationId
						AND Lot.intLotId = @intLotId
			END 
			
			-- Reduce the remaining qty
			-- Round it to the sixth decimal place. If it turns out as zero, the system has fully consumed the stock. 
			SET @dblReduceQty = ROUND(@RemainingQty, 6);
		END 
	END

	-- Add stock 
	ELSE IF (ISNULL(@dblQty, 0) > 0)
	BEGIN 

		----------------------------------------------------------------------------------------------
		-- Bagged vs Weight. 
		----------------------------------------------------------------------------------------------
		-- 1. If Costing Lot table is using a weight UOM, then convert the UOM and Qty to weight. 
		-- 2. Otherwise, keep the same Qty, Cost, and UOM Id. 
		BEGIN 
			SET @dblAddQty = ISNULL(@dblQty, 0) 

			IF EXISTS (
				SELECT	TOP 1 1 
				FROM	tblICLot Lot
				WHERE	Lot.intLotId = @intLotId
						AND Lot.intItemUOMId = @intItemUOMId
						AND Lot.intWeightUOMId <> @intItemUOMId
						AND Lot.intWeightUOMId IS NOT NULL 
			)			 
			BEGIN 
				-- Retrieve the correct UOM (Lot UOM or Weight UOM)
				-- and also compute the Qty if it has weights. 
				SELECT	@dblAddQty =	Lot.dblWeightPerQty * @dblQty
						,@intItemUOMId = Lot.intWeightUOMId 				
				FROM	dbo.tblICLot Lot
				WHERE	Lot.intLotId = @intLotId

				SET @dblAddQty = ISNULL(@dblAddQty, 0)

				-- Get the unit cost. 
				SET @dblCost = dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty)

				-- Adjust the Unit Qty 
				SELECT @dblUOMQty = dblUnitQty
				FROM dbo.tblICItemUOM
				WHERE intItemUOMId = @intItemUOMId

				-- Adjust the cost to the new UOM
				SET @dblCost = @dblCost * @dblUOMQty
			END 
		END 
						
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

		-- Repeat call on uspICIncreaseStockInLot until @dblAddQty is completely distributed to the negative cost Lot buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInLotStorage
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@intLotId
				,@intSubLocationId
				,@intStorageLocationId
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
				,@NewInventoryLotStorageId OUTPUT 
				,@UpdatedInventoryLotId OUTPUT 
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
			
			-- Insert the record to the Lot-out table
			INSERT INTO dbo.tblICInventoryLotStorageOut (
					intInventoryTransactionStorageId
					,intInventoryLotStorageId
					,dblQty
					,intRevalueLotId
			)
			SELECT	intInventoryTransactionStorageId = @InventoryTransactionIdentityId
					,intInventoryLotStorageId = NULL 
					,dblQty = @QtyOffset
					,intRevalueLotId = @UpdatedInventoryLotId
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedInventoryLotId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 

			SET @dblAddQty = @RemainingQty;
		END 

		-- Update the Lot out table and assign the correct Lot id. 
		UPDATE	LotStorageOut
		SET		LotStorageOut.intInventoryLotStorageId = @NewInventoryLotStorageId
		FROM	dbo.tblICInventoryLotStorageOut LotStorageOut INNER JOIN dbo.tblICInventoryTransactionStorage TRANS
					ON LotStorageOut.intInventoryTransactionStorageId = TRANS.intInventoryTransactionStorageId 
					AND LotStorageOut.intInventoryLotStorageId IS NULL 
					AND TRANS.intItemId = @intItemId
					AND TRANS.intItemLocationId = @intItemLocationId
					AND TRANS.intItemUOMId = @intItemUOMId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
		WHERE	@NewInventoryLotStorageId IS NOT NULL 

		-- Increase the lot Qty and Weight. 
		BEGIN 
			UPDATE	Lot 
			SET		Lot.dblQty =	
						dbo.fnCalculateLotQty(
							Lot.intItemUOMId
							, @intItemUOMId
							, Lot.dblQty
							, Lot.dblWeight
							, @FullQty 
							, Lot.dblWeightPerQty
						)
					,Lot.dblWeight = 
						dbo.fnCalculateLotWeight(
							Lot.intItemUOMId
							, Lot.intWeightUOMId
							, @intItemUOMId 
							, Lot.dblWeight
							, @FullQty 
							, Lot.dblWeightPerQty
						)
					,Lot.dblLastCost = dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty) 
			FROM	dbo.tblICLot Lot
			WHERE	Lot.intItemLocationId = @intItemLocationId
					AND Lot.intLotId = @intLotId
		END 
	END 
END 