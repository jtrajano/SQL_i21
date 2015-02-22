/*
	This stored procedure will post a Lotted Item. 
*/

CREATE PROCEDURE [dbo].[uspICPostLot]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@dtmDate AS DATETIME
	,@intLotId AS INT
	,@dblQty AS NUMERIC(18,6)
	,@dblUOMQty AS NUMERIC(18,6)
	,@dblCost AS NUMERIC(18,6)
	,@dblSalesPrice AS NUMERIC(18,6)
	,@intCurrencyId AS INT
	,@dblExchangeRate AS NUMERIC(18,6)
	,@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
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
DECLARE @TransactionTypeName AS NVARCHAR(200) 
SELECT	TOP 1 
		@TransactionTypeName = strName
FROM	dbo.tblICInventoryTransactionType
WHERE	intTransactionTypeId = @intTransactionTypeId

-------------------------------------------------
-- 1. Process the Lot Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all available Lot buckets or added a new negative bucket. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInLot
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@intLotId
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
					,@dtmDate = @dtmDate
					,@dblQty = @dblComputedUnitQty
					,@dblUOMQty = @dblUOMQty
					,@dblCost = @dblCostToUse
					,@dblValue = NULL
					,@dblSalesPrice = @dblSalesPrice
					,@intCurrencyId = @intCurrencyId
					,@dblExchangeRate = @dblExchangeRate
					,@intTransactionId = @intTransactionId
					,@strTransactionId = @strTransactionId
					,@strBatchId = @strBatchId
					,@intTransactionTypeId = @intTransactionTypeId
					,@intLotId = @intLotId 
					,@ysnIsUnposted = 0
					,@intRelatedInventoryTransactionId = NULL 
					,@intRelatedTransactionId = NULL 
					,@strRelatedTransactionId = NULL 
					,@strTransactionForm = @TransactionTypeName
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

		SET @dblAddQty = ISNULL(@dblQty, 0) 
		SET @FullQty = @dblAddQty
		SET @TotalQtyOffset = 0;

		-- Insert the inventory transaction record
		EXEC [dbo].[uspICPostInventoryTransaction]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = @intItemUOMId
				,@dtmDate = @dtmDate
				,@dblQty = @FullQty
				,@dblUOMQty = @dblUOMQty
				,@dblCost = @dblCost
				,@dblValue = NULL
				,@dblSalesPrice = @dblSalesPrice
				,@intCurrencyId = @intCurrencyId
				,@dblExchangeRate = @dblExchangeRate
				,@intTransactionId = @intTransactionId
				,@strTransactionId = @strTransactionId
				,@strBatchId = @strBatchId
				,@intTransactionTypeId = @intTransactionTypeId
				,@intLotId = @intLotId 
				,@ysnIsUnposted = 0
				,@intRelatedInventoryTransactionId = NULL 
				,@intRelatedTransactionId = NULL 
				,@strRelatedTransactionId = NULL 
				,@strTransactionForm = @TransactionTypeName
				,@intUserId = @intUserId
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 			

		-- Repeat call on uspICIncreaseStockInLot until @dblAddQty is completely distributed to the negative cost Lot buckets or added as a new bucket. 
		WHILE (ISNULL(@dblAddQty, 0) > 0)
		BEGIN 
			EXEC dbo.uspICIncreaseStockInLot
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@intLotId
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
						,@dtmDate = @dtmDate
						,@dblQty = 0
						,@dblUOMQty = 0
						,@dblCost = 0
						,@dblValue = @dblValue
						,@dblSalesPrice = @dblSalesPrice
						,@intCurrencyId = @intCurrencyId
						,@dblExchangeRate = @dblExchangeRate
						,@intTransactionId = @intTransactionId
						,@strTransactionId = @strTransactionId
						,@strBatchId = @strBatchId
						,@intTransactionTypeId = @Inventory_Write_Off_Sold
						,@intLotId = @intLotId 
						,@ysnIsUnposted = 0
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = @intRelatedTransactionId
						,@strRelatedTransactionId = @strRelatedTransactionId 
						,@strTransactionForm = @TransactionTypeName
						,@intUserId = @intUserId
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 

				-- Add Revalue sold
				SET @dblValue = (@QtyOffset * ISNULL(@dblCost, 0) * -1) 
				EXEC [dbo].[uspICPostInventoryTransaction]
						@intItemId = @intItemId
						,@intItemLocationId = @intItemLocationId
						,@intItemUOMId = @intItemUOMId
						,@dtmDate = @dtmDate
						,@dblQty = 0
						,@dblUOMQty = 0
						,@dblCost = 0
						,@dblValue = @dblValue
						,@dblSalesPrice = @dblSalesPrice
						,@intCurrencyId = @intCurrencyId
						,@dblExchangeRate = @dblExchangeRate
						,@intTransactionId = @intTransactionId
						,@strTransactionId = @strTransactionId
						,@strBatchId = @strBatchId
						,@intTransactionTypeId = @Inventory_Revalue_Sold
						,@intLotId = @intLotId 
						,@ysnIsUnposted = 0
						,@intRelatedInventoryTransactionId = NULL 
						,@intRelatedTransactionId = @intRelatedTransactionId
						,@strRelatedTransactionId = @strRelatedTransactionId 
						,@strTransactionForm = @TransactionTypeName
						,@intUserId = @intUserId
						,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT 
			END
			
			-- Insert the record the the Lot-out table
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