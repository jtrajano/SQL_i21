/*
	This stored procedure will post a Lot item under the company's custody. 
*/

CREATE PROCEDURE [dbo].[uspICPostLotInCustody]
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
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(18,6);
DECLARE @dblReduceQty AS NUMERIC(18,6);
DECLARE @dblAddQty AS NUMERIC(18,6);
DECLARE @CostUsed AS NUMERIC(18,6);

DECLARE @NewInventoryLotInCustodyId AS INT
DECLARE @UpdatedInventoryLotInCustodyId AS INT 
DECLARE @NewInventoryLotInCustodyTransactionId AS INT

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

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all available Lot In Custody. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInLotCustody
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
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
				,@UpdatedInventoryLotInCustodyId OUTPUT
			IF @@ERROR <> 0 GOTO _Exit

			-- Insert the inventory transaction record
			DECLARE @dblComputedReduceQty AS NUMERIC(18,6) = @dblReduceQty - ISNULL(@RemainingQty, 0) 
			DECLARE @dblCostToUse AS NUMERIC(18,6) = ISNULL(@CostUsed, @dblCost)

			EXEC [dbo].[uspICPostInventoryLotInCustodyTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = @dblComputedReduceQty
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
					,@strTransactionForm = @TransactionTypeName
					,@intUserId = @intUserId
					,@SourceInventoryLotInCustodyId = @UpdatedInventoryLotInCustodyId
					,@InventoryLotInCustodyTransactionId = @NewInventoryLotInCustodyTransactionId OUTPUT			
			
			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
		END 
	END

	-- Add stock 
	ELSE IF (ISNULL(@dblQty, 0) > 0)
	BEGIN 
		SET @dblAddQty = ISNULL(@dblQty, 0) 

		EXEC dbo.uspICIncreaseStockInLotCustody
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intLotId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblAddQty
			,@dblCost
			,@strTransactionId
			,@intTransactionId
			,@intUserId
			,@NewInventoryLotInCustodyId OUTPUT 
		IF @@ERROR <> 0 GOTO _Exit

		EXEC [dbo].[uspICPostInventoryLotInCustodyTransaction]
			@intItemId = @intItemId
			,@intItemLocationId = @intItemLocationId
			,@intItemUOMId = @intItemUOMId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId					 
			,@dtmDate = @dtmDate
			,@dblQty = @dblAddQty
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
			,@strTransactionForm = @TransactionTypeName
			,@intUserId = @intUserId
			,@SourceInventoryLotInCustodyId = @NewInventoryLotInCustodyId 
			,@InventoryLotInCustodyTransactionId = @NewInventoryLotInCustodyTransactionId OUTPUT			
	END 
END 

_Exit: