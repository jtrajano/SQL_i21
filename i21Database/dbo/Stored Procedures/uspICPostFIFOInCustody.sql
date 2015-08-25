﻿/*
	This stored procedure will post stocks that is not owned by the company. 
*/

CREATE PROCEDURE [dbo].[uspICPostFIFOInCustody]
	@intItemId AS INT
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

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(18,6);
DECLARE @dblReduceQty AS NUMERIC(18,6);
DECLARE @dblAddQty AS NUMERIC(18,6);
DECLARE @CostUsed AS NUMERIC(18,6);

DECLARE @NewInventoryCostBucketCustodyId AS INT
DECLARE @UpdatedCostBucketInCustodyId AS INT 
DECLARE @NewInventoryTransactionInCustodyId AS INT

-------------------------------------------------
-- 1. Process the FIFO Cost buckets
-------------------------------------------------
BEGIN 
	-- Reduce stock 
	IF (ISNULL(@dblQty, 0) < 0)
	BEGIN 
		SET @dblReduceQty = ISNULL(@dblQty, 0) 

		-- Repeat call on uspICReduceStockInLot until @dblReduceQty is completely distributed to all available Lot In Custody. 
		WHILE (ISNULL(@dblReduceQty, 0) < 0)
		BEGIN 
			EXEC dbo.uspICReduceStockInFIFOCustody
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@dtmDate
				,@dblQty
				,@dblCost
				,@strTransactionId
				,@intTransactionId
				,@intUserId
				,@RemainingQty OUTPUT
				,@CostUsed OUTPUT
				,@UpdatedCostBucketInCustodyId OUTPUT

			IF @@ERROR <> 0 GOTO _Exit

			-- Insert the inventory transaction record
			DECLARE @dblComputedReduceQty AS NUMERIC(18,6) = @dblReduceQty - ISNULL(@RemainingQty, 0) 
			DECLARE @dblCostToUse AS NUMERIC(18,6) = ISNULL(@CostUsed, @dblCost)

			EXEC [dbo].[uspICPostInventoryTransactionInCustody]
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
					,@intLotId = NULL 
					,@strTransactionForm = @strTransactionForm
					,@intUserId = @intUserId
					,@SourceCostBucketInCustodyId = @UpdatedCostBucketInCustodyId
					,@InventoryTransactionIdInCustodyId = @NewInventoryTransactionInCustodyId OUTPUT			
			
			-- Reduce the remaining qty
			SET @dblReduceQty = @RemainingQty;
		END 
	END

	-- Add stock 
	ELSE IF (ISNULL(@dblQty, 0) > 0)
	BEGIN 
		SET @dblAddQty = ISNULL(@dblQty, 0) 

		EXEC dbo.uspICIncreaseStockInFIFOCustody
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@dtmDate
			,@dblQty
			,@dblCost
			,@intUserId
			,@strTransactionId
			,@intTransactionId
			,@NewInventoryCostBucketCustodyId OUTPUT 


		IF @@ERROR <> 0 GOTO _Exit

		EXEC [dbo].[uspICPostInventoryTransactionInCustody]
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
			,@intLotId = NULL  
			,@strTransactionForm = @strTransactionForm
			,@intUserId = @intUserId
			,@SourceCostBucketInCustodyId = @NewInventoryCostBucketCustodyId
			,@InventoryTransactionIdInCustodyId = @NewInventoryTransactionInCustodyId OUTPUT						
	END 
END 

_Exit: