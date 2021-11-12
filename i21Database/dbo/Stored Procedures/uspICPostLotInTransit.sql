﻿/*
	This stored procedure will post a Lotted Item. 
*/

CREATE PROCEDURE [dbo].[uspICPostLotInTransit]
	@strActualCostId AS NVARCHAR(50)
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
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
	,@strBatchId AS NVARCHAR(40)
	,@intTransactionTypeId AS INT
	,@strTransactionForm AS NVARCHAR(255)
	,@intEntityUserSecurityId AS INT
	,@intFobPointId AS TINYINT 
	,@intInTransitSourceLocationId AS INT 
	,@intForexRateTypeId AS INT
	,@dblForexRate AS NUMERIC(38, 20)
	,@intSourceEntityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5

DECLARE @strDescription AS NVARCHAR(255)

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

DECLARE @NewInventoryLotId AS INT
DECLARE @UpdatedInventoryLotId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(38,20)
DECLARE @dblAutoVarianceOnUsedOrSoldStock AS NUMERIC(38,20)

DECLARE @intReturnValue AS INT 
		,@dtmCreated DATETIME 

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
		-- 1. If Lot Cost bucket is using the weight UOM, then convert the UOM and Qty to weight. 
		-- 2. Otherwise, keep the same Qty and UOM. 
		BEGIN 
			SET @dblReduceQty = ISNULL(@dblQty, 0) 

			IF EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryLot cb INNER JOIN dbo.tblICLot Lot
							ON cb.intLotId = Lot.intLotId
				WHERE	cb.intLotId = @intLotId
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intItemUOMId = Lot.intWeightUOMId
						AND cb.intItemUOMId <> @intItemUOMId
						AND Lot.intWeightUOMId IS NOT NULL 
						AND ISNULL(cb.ysnIsUnposted, 0) = 0 
						AND (ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0)) > 0 
						AND (@strActualCostId IS NULL OR cb.strTransactionId = @strActualCostId) 
						--AND (
						--	Lot.intLotId = @intLotId
						--	AND Lot.intItemLocationId = @intItemLocationId
						--	AND Lot.intItemUOMId = @intItemUOMId
						--	AND ROUND((@dblQty % 1), 6) <> 0 -- Check if bagged qty is a whole number.
						--)
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
			EXEC @intReturnValue = dbo.uspICReduceStockInLotInTransit
				@strActualCostId
				,@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@intLotId
				,NULL -- @intSubLocationId
				,NULL -- @intStorageLocationId
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

			IF @intReturnValue < 0 RETURN @intReturnValue;

			-- Calculate the stock reduced
			-- Get the cost used. It is usually the cost from the cost bucket or the last cost. 
			DECLARE @dblReduceStockQty AS NUMERIC(38,20) = ISNULL(-@QtyOffset, @dblReduceQty - ISNULL(@RemainingQty, 0))
			DECLARE @dblCostToUse AS NUMERIC(38,20) = ISNULL(@CostUsed, @dblCost)

			-- Insert the inventory transaction record
			EXEC @intReturnValue = [dbo].[uspICPostInventoryTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = NULL -- @intSubLocationId
					,@intStorageLocationId = NULL -- @intStorageLocationId					 
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
					,@intFobPointId = @intFobPointId
					,@intInTransitSourceLocationId = @intInTransitSourceLocationId
					,@intForexRateTypeId = @intForexRateTypeId
					,@dblForexRate = @dblForexRate
					,@strActualCostId = @strActualCostId
					,@intSourceEntityId = @intSourceEntityId
					,@dtmCreated = @dtmCreated OUTPUT 

			IF @intReturnValue < 0 RETURN @intReturnValue;

			-- Insert the record the the Lot-out table
			INSERT INTO dbo.tblICInventoryLotOut (
					intInventoryTransactionId
					,intInventoryLotId
					,dblQty
					,dtmCreated
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryLotId = @UpdatedInventoryLotId
					,dblQty = @QtyOffset
					,@dtmCreated
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedInventoryLotId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 			
		
			-- Update the Lot's Qty and Weights. 
			BEGIN 
				UPDATE	Lot 
				SET		Lot.dblQtyInTransit =	
							dbo.fnCalculateLotQty(
								Lot.intItemUOMId
								, @intItemUOMId
								, Lot.dblQtyInTransit
								, Lot.dblWeightInTransit 
								, @dblReduceStockQty 
								, Lot.dblWeightPerQty
							)
						,Lot.dblWeightInTransit = 
							dbo.fnCalculateLotWeight(
								Lot.intItemUOMId
								, Lot.intWeightUOMId
								, @intItemUOMId 
								, Lot.dblWeightInTransit
								, @dblReduceStockQty 
								, Lot.dblWeightPerQty
							)
				FROM	dbo.tblICLot Lot
				WHERE	Lot.intItemLocationId = @intInTransitSourceLocationId
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
				SELECT	@dblAddQty = dbo.fnMultiply(Lot.dblWeightPerQty, @dblQty) 
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
				SET @dblCost = dbo.fnMultiply(@dblCost, @dblUOMQty) 
			END 
		END 
						
		SET @FullQty = @dblAddQty
		SET @TotalQtyOffset = 0;

		-- Insert the inventory transaction record
		EXEC @intReturnValue = [dbo].[uspICPostInventoryTransaction]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = @intItemUOMId
				,@intSubLocationId = NULL -- @intSubLocationId
				,@intStorageLocationId = NULL -- @intStorageLocationId
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
				,@intFobPointId = @intFobPointId	
				,@intInTransitSourceLocationId = @intInTransitSourceLocationId	
				,@intForexRateTypeId = @intForexRateTypeId
				,@dblForexRate = @dblForexRate
				,@strActualCostId = @strActualCostId
				,@intSourceEntityId = @intSourceEntityId
				,@dtmCreated = @dtmCreated OUTPUT 

		IF @intReturnValue < 0 RETURN @intReturnValue;

		-- Repeat call on uspICIncreaseStockInLot until @dblAddQty is completely distributed to the negative cost Lot buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC @intReturnValue = dbo.uspICIncreaseStockInLotInTransit
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@intLotId
				,NULL -- @intSubLocationId
				,NULL -- @intStorageLocationId
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
				,@NewInventoryLotId OUTPUT 
				,@UpdatedInventoryLotId OUTPUT 
				,@strRelatedTransactionId OUTPUT
				,@intRelatedTransactionId OUTPUT 

			IF @intReturnValue < 0 RETURN @intReturnValue;

			SET @dblAddQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Insert the inventory transaction record					
			IF ISNULL(@QtyOffset, 0) <> 0 
				AND ISNULL(@CostUsed, 0) <> ISNULL(@dblCost, 0)
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

					EXEC @intReturnValue = [dbo].[uspICPostInventoryTransaction]
							@intItemId = @intItemId
							,@intItemLocationId = @intItemLocationId
							,@intItemUOMId = @intItemUOMId
							,@intSubLocationId = NULL -- @intSubLocationId
							,@intStorageLocationId = NULL -- @intStorageLocationId
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
							,@intLotId = @intLotId 
							,@intRelatedInventoryTransactionId = NULL 
							,@intRelatedTransactionId = @intRelatedTransactionId
							,@strRelatedTransactionId = @strRelatedTransactionId 
							,@strTransactionForm = @strTransactionForm
							,@intEntityUserSecurityId = @intEntityUserSecurityId
							,@intCostingMethod = @LOTCOST
							,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
							,@intFobPointId = @intFobPointId
							,@intInTransitSourceLocationId = @intInTransitSourceLocationId
							,@intForexRateTypeId = @intForexRateTypeId
							,@dblForexRate = @dblForexRate
							,@strDescription = @strDescription
							,@strActualCostId = @strActualCostId
							,@intSourceEntityId = @intSourceEntityId
							,@dtmCreated = @dtmCreated OUTPUT 

					IF @intReturnValue < 0 RETURN @intReturnValue;
				END 
			END
			
			-- Insert the record to the Lot-out table
			INSERT INTO dbo.tblICInventoryLotOut (
					intInventoryTransactionId
					,intInventoryLotId
					,dblQty
					,intRevalueLotId
					,dtmCreated
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryLotId = NULL 
					,dblQty = @QtyOffset
					,intRevalueLotId = @UpdatedInventoryLotId
					,@dtmCreated
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedInventoryLotId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 

			SET @dblAddQty = @RemainingQty;
		END 

		-- Update the Lot out table and assign the correct Lot id. 
		UPDATE	LotOut
		SET		LotOut.intInventoryLotId = @NewInventoryLotId
		FROM	dbo.tblICInventoryLotOut LotOut INNER JOIN dbo.tblICInventoryTransaction TRANS
					ON LotOut.intInventoryTransactionId = TRANS.intInventoryTransactionId 
					AND LotOut.intInventoryLotId IS NULL 
					AND TRANS.intItemId = @intItemId
					AND TRANS.intItemLocationId = @intItemLocationId
					AND TRANS.intItemUOMId = @intItemUOMId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
		WHERE	@NewInventoryLotId IS NOT NULL 

		-- Increase the lot Qty and Weight. 
		BEGIN 
			UPDATE	Lot 
			SET		Lot.dblQtyInTransit =	
						dbo.fnCalculateLotQty(
							Lot.intItemUOMId
							, @intItemUOMId
							, Lot.dblQtyInTransit
							, Lot.dblWeightInTransit
							, @FullQty 
							, Lot.dblWeightPerQty
						)
					,Lot.dblWeightInTransit = 
						dbo.fnCalculateLotWeight(
							Lot.intItemUOMId
							, Lot.intWeightUOMId
							, @intItemUOMId 
							, Lot.dblWeightInTransit
							, @FullQty 
							, Lot.dblWeightPerQty
						)
			FROM	dbo.tblICLot Lot LEFT JOIN tblICItemUOM StockUOM
						ON StockUOM.intItemId = Lot.intItemId
						AND StockUOM.ysnStockUnit = 1
			WHERE	Lot.intItemLocationId = @intInTransitSourceLocationId
					AND Lot.intLotId = @intLotId
		END
	END 
END 