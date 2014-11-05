/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 
	@intItemId - The item to process

	@intItemLocationId - The location where the item is being process. 
	
	@dtmDate - The date used in the transaction and posting. 

	@dblUnitQty - A positive qty indicates an increase of stock. A negative qty indicates a decrease in stock. 

	@dblUOMQty - The base qty associated with a UOM. For example, a box may have 10 pieces of an item. In this case, UOM qty will be 10. 

	@dblCost - The cost per base qty of the item. 

	@dblSalesPrice - The sales price of an item sold to the customer. 

	@intCurrencyId - The foreign currency associated with the transaction. 

	@dblExchangeRate - The conversion factor between the base currency and the foreign currency. 

	@intTransactionId - The primary key id used in a transaction. 

	@strTransactionId - The string value of a transaction id. 

	@strBatchId - The batch id to use in generating the g/l entries. 

	@intUserId - The user who initiated or called this stored procedure. 
*/

CREATE PROCEDURE [dbo].[uspICProcessFIFO]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblUnitQty AS NUMERIC(18,6)
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

-- Create the variables 
DECLARE @RemainingQty AS NUMERIC(18,6)
DECLARE @dblReduceQty AS NUMERIC(18,6)

-------------------------------------------------
-- 1. Process the Fifo Cost buckets
-------------------------------------------------

-- Process reduce stock in the fifo bucket table
IF (@dblUnitQty < 0)
BEGIN 
	SET @dblReduceQty = ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0)

	-- Repeat call on uspICReduceStockInFIFO until @dblReduceQty is completed assigned to the fifo buckets
	WHILE (ISNULL(@dblReduceQty, 0) < 0)
	BEGIN 
		EXEC [dbo].[uspICReduceStockInFIFO]
			@intItemId
			,@intItemLocationId
			,@dtmDate
			,@dblReduceQty
			,@dblCost
			,@intUserId
			,@RemainingQty OUTPUT

		SET @dblReduceQty = @RemainingQty;
	END 
END

-- Add new cost bucket if unit quantity is positive
ELSE IF (@dblUnitQty > 0)
BEGIN 
	INSERT [dbo].[tblICInventoryFIFO] (
		[intItemId]
		,[intItemLocationId]
		,[dtmDate]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]
		,[dtmCreated]
		,[intCreatedUserId]
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@dtmDate
		,ISNULL(@dblUnitQty, 0) * ISNULL(@dblUOMQty, 0)
		,0
		,@dblCost
		,GETDATE()
		,@intUserId
		,1	
	)
END 

-------------------------------------------------
-- 2. Process the inventory transaction records -- TODO
-------------------------------------------------
