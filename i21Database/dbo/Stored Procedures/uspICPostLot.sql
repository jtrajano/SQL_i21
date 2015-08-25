/*
	This stored procedure will post a Lotted Item. 
*/

CREATE PROCEDURE [dbo].[uspICPostLot]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@intSubLocationId AS INT 
	,@intStorageLocationId AS INT 
	,@dtmDate AS DATETIME
	,@intLotId AS INT
	,@dblQty AS NUMERIC(18,6)
	,@dblUOMQty AS NUMERIC(18,6)
	,@dblCost AS NUMERIC(18,6)
	,@dblSalesPrice AS NUMERIC(18,6)
	,@intCurrencyId AS INT
	,@dblExchangeRate AS NUMERIC(18,6)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT 
	,@strTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@strTransactionForm AS NVARCHAR(255)
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables for the internal transaction types used by costing. 
DECLARE @Inventory_Auto_Negative AS INT = 1;
DECLARE @Inventory_Write_Off_Sold AS INT = 2;
DECLARE @Inventory_Revalue_Sold AS INT = 3;

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(18,6);
DECLARE @dblReduceQty AS NUMERIC(18,6);
DECLARE @dblAddQty AS NUMERIC(18,6);
DECLARE @CostUsed AS NUMERIC(18,6);
DECLARE @FullQty AS NUMERIC(18,6);
DECLARE @QtyOffset AS NUMERIC(18,6);
DECLARE @TotalQtyOffset AS NUMERIC(18,6);

DECLARE @InventoryTransactionIdentityId AS INT

DECLARE @NewInventoryLotId AS INT
DECLARE @UpdatedInventoryLotId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(18,6)

-- Initialize the transaction name. Use this as the transaction form name
--DECLARE @TransactionTypeName AS NVARCHAR(200) 
--SELECT	TOP 1 
--		@TransactionTypeName = strName
--FROM	dbo.tblICInventoryTransactionType
--WHERE	intTransactionTypeId = @intTransactionTypeId

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
				SELECT	@dblReduceQty =	Lot.dblWeightPerQty * @dblQty
						,@intItemUOMId = Lot.intWeightUOMId 
				FROM	dbo.tblICLot Lot
				WHERE	Lot.intLotId = @intLotId
				
				SET @dblReduceQty = ISNULL(@dblReduceQty, 0) 

				-- Adjust the Unit Qty 
				SELECT @dblUOMQty = dblUnitQty
				FROM dbo.tblICItemUOM
				WHERE intItemUOMId = @intItemUOMId
			END 
		END 

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all available Lot buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInLot
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
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@UpdatedInventoryLotId OUTPUT 

			-- Insert the inventory transaction record
			DECLARE @dblComputedUnitQty AS NUMERIC(18,6) = @dblReduceQty - ISNULL(@RemainingQty, 0) 
			DECLARE @dblCostToUse AS NUMERIC(18,6) = ISNULL(@CostUsed, @dblCost)

			EXEC [dbo].[uspICPostInventoryTransaction]
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
					,@dblExchangeRate = @dblExchangeRate
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
					,@intUserId = @intUserId
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT			

			-- Insert the record the the Lot-out table
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
			
			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
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
		EXEC [dbo].[uspICPostInventoryTransaction]
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
				,@dblExchangeRate = @dblExchangeRate
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
				,@intUserId = @intUserId
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 			

		-- Repeat call on uspICIncreaseStockInLot until @dblAddQty is completely distributed to the negative cost Lot buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInLot
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@intLotId
				,@intSubLocationId
				,@intStorageLocationId
				,@dblAddQty
				,@dblCost
				,@intUserId
				,@FullQty
				,@TotalQtyOffset
				,@strTransactionId
				,@intTransactionId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@QtyOffset OUTPUT 
				,@NewInventoryLotId OUTPUT 
				,@UpdatedInventoryLotId OUTPUT 
				,@strRelatedTransactionId OUTPUT
				,@intRelatedTransactionId OUTPUT 

			SET @dblAddQty = @RemainingQty;
			SET @TotalQtyOffset += ISNULL(@QtyOffset, 0)

			-- Insert the inventory transaction record					
			IF @QtyOffset IS NOT NULL
			BEGIN 				
				-- Add Write-Off Sold				
				SET @dblValue = (@QtyOffset * ISNULL(@CostUsed, 0))
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
						,@intLotId = @intLotId 
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = @intRelatedTransactionId
						,@strRelatedTransactionId = @strRelatedTransactionId 
						,@strTransactionForm = @strTransactionForm
						,@intUserId = @intUserId
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 

				-- Add Revalue sold
				SET @dblValue = (@QtyOffset * ISNULL(@dblCost, 0) * -1) 
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
						,@intLotId = @intLotId 
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = @intRelatedTransactionId
						,@strRelatedTransactionId = @strRelatedTransactionId 
						,@strTransactionForm = @strTransactionForm
						,@intUserId = @intUserId
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
			END
			
			-- Insert the record to the Lot-out table
			INSERT INTO dbo.tblICInventoryLotOut (
					intInventoryTransactionId
					,intInventoryLotId
					,dblQty
					,intRevalueLotId
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryLotId = NULL 
					,dblQty = @QtyOffset
					,intRevalueLotId = @UpdatedInventoryLotId
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
	END 
END 