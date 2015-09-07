/*
	Write the description of the stored procedure here 
*/

CREATE PROCEDURE [dbo].[uspICPostActualCost]
	@strActualCostId AS NVARCHAR(50)
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@intSubLocationId AS INT 
	,@intStorageLocationId AS INT
	,@dtmDate AS DATETIME
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
DECLARE @RemainingQty AS NUMERIC(18,6);
DECLARE @dblReduceQty AS NUMERIC(18,6);
DECLARE @dblAddQty AS NUMERIC(18,6);
DECLARE @CostUsed AS NUMERIC(18,6);
DECLARE @FullQty AS NUMERIC(18,6);
DECLARE @QtyOffset AS NUMERIC(18,6);
DECLARE @TotalQtyOffset AS NUMERIC(18,6);

DECLARE @InventoryTransactionIdentityId AS INT

DECLARE @NewActualCostId AS INT
DECLARE @UpdatedActualCostId AS INT 
DECLARE @strRelatedTransactionId AS NVARCHAR(40)
DECLARE @intRelatedTransactionId AS INT 
DECLARE @dblValue AS NUMERIC(18,6)

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
			EXEC dbo.uspICReduceStockInActualCost
				@strActualCostId	
				,@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblReduceQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT 
				,@QtyOffset OUTPUT 
				,@UpdatedActualCostId OUTPUT 

			-- Insert the inventory transaction record
			DECLARE @dblComputedQty AS NUMERIC(18,6) = @dblReduceQty - ISNULL(@RemainingQty, 0) 
			DECLARE @dblCostToUse AS NUMERIC(18,6) = ISNULL(@CostUsed, @dblCost)

			EXEC [dbo].[uspICPostInventoryTransaction]
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
					,@intUserId = @intUserId
					,@intCostingMethod = @ACTUALCOST
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT

			
			-- Insert the record the the Actual-out table
			INSERT INTO dbo.tblICInventoryActualCostOut (
					intInventoryTransactionId
					,intInventoryActualCostId
					,dblQty
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryActualCostId = @UpdatedActualCostId
					,dblQty = @QtyOffset
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedActualCostId IS NOT NULL 
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
		
		-- Insert the inventory transaction record
		EXEC [dbo].[uspICPostInventoryTransaction]
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
				,@intUserId = @intUserId
				,@intCostingMethod = @ACTUALCOST
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 			

		-- Repeat call on uspICIncreaseStockInActual until @dblAddQty is completely distributed to the negative cost Actual buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInActualCost
				@strActualCostId	
				,@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
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
				,@NewActualCostId OUTPUT 
				,@UpdatedActualCostId OUTPUT 
				,@strRelatedTransactionId OUTPUT
				,@intRelatedTransactionId OUTPUT 

			SET @dblAddQty = @RemainingQty;

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
						,@dblCost = 0
						,@dblUOMQty = 0
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
						,@intUserId = @intUserId
						,@intCostingMethod = @ACTUALCOST
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
						,@dblCost = 0
						,@dblUOMQty = 0
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
						,@intUserId = @intUserId
						,@intCostingMethod = @ACTUALCOST
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
			END
			
			-- Insert the record the the Actual-out table
			INSERT INTO dbo.tblICInventoryActualCostOut (
					intInventoryTransactionId
					,intInventoryActualCostId
					,dblQty
					,intRevalueActualCostId
			)
			SELECT	intInventoryTransactionId = @InventoryTransactionIdentityId
					,intInventoryActualCostId = NULL 
					,dblQty = @QtyOffset
					,intRevalueActualCostId = @UpdatedActualCostId
			WHERE	@InventoryTransactionIdentityId IS NOT NULL
					AND @UpdatedActualCostId IS NOT NULL 
					AND @QtyOffset IS NOT NULL 

			SET @dblAddQty = @RemainingQty;
		END 

		-- Update the Actual out table and assign the correct Actual id. 
		UPDATE	ActualCostOut
		SET		ActualCostOut.intInventoryActualCostId = @NewActualCostId
		FROM	dbo.tblICInventoryActualCostOut ActualCostOut INNER JOIN dbo.tblICInventoryTransaction TRANS
					ON ActualCostOut.intInventoryTransactionId = TRANS.intInventoryTransactionId 
					AND ActualCostOut.intInventoryActualCostId IS NULL 
					AND TRANS.intItemId = @intItemId
					AND TRANS.intItemLocationId = @intItemLocationId
					AND TRANS.intItemUOMId = @intItemUOMId
					AND TRANS.intTransactionId = @intTransactionId
					AND TRANS.strBatchId = @strBatchId
		WHERE	@NewActualCostId IS NOT NULL 
	END 
END 