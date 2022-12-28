﻿/*
	This stored procedure either inserts or updates a fifo cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative fifo buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInAvg
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(38,20) 
	,@dblCost AS NUMERIC(38,20)
	,@intEntityUserSecurityId AS INT
	,@FullQty AS NUMERIC(38,20) 
	,@TotalQtyOffset AS NUMERIC(38,20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intTransactionDetailId AS INT 
	,@RemainingQty AS NUMERIC(38,20) OUTPUT
	,@CostUsed AS NUMERIC(38,20) OUTPUT 
	,@QtyOffset AS NUMERIC(38,20) OUTPUT 
	,@NewFifoId AS INT OUTPUT 
	,@UpdatedFifoId AS INT OUTPUT 
	,@strRelatedTransactionId AS NVARCHAR(40) OUTPUT
	,@intRelatedTransactionId AS INT OUTPUT
	,@intCurrencyId AS INT 
	,@intForexRateTypeId AS INT
	,@dblForexRate AS NUMERIC(38, 20) 
	,@dblForexCost AS NUMERIC(38, 20) 
	,@ForexCostUsed AS NUMERIC(38,20) OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty);

-- Initialize the remaining qty to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @NewFifoId = NULL;
SET @UpdatedFifoId = NULL;
SET @strRelatedTransactionId = NULL;
SET @intRelatedTransactionId = NULL;
SET @ForexCostUsed = NULL; 

-- Upsert (update or insert) a record into the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryFIFO 
WITH	(HOLDLOCK) 
AS		fifo_bucket
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId	
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON fifo_bucket.intItemId = Source_Query.intItemId
	AND fifo_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND fifo_bucket.intItemUOMId = Source_Query.intItemUOMId

	-- Update an existing negative stock 
	AND fifo_bucket.dblStockIn < fifo_bucket.dblStockOut

-- Update an existing negative stock fifo bucket with the same UOM 
WHEN MATCHED AND fifo_bucket.intItemUOMId = Source_Query.intItemUOMId THEN 
	UPDATE 
	SET	fifo_bucket.dblStockIn = ISNULL(fifo_bucket.dblStockIn, 0) 
					+ CASE	WHEN (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) 
					END
		,fifo_bucket.intConcurrencyId = ISNULL(fifo_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) >= @dblQty THEN 0
							ELSE @dblQty - (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn)
					END
		-- retrieve the cost from the cost bucket. 
		,@CostUsed = fifo_bucket.dblCost
		,@ForexCostUsed = fifo_bucket.dblForexCost 

		-- retrieve the negative qty that was offset by the incoming stock 
		,@QtyOffset = 
					CASE	WHEN (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) 
					END 

		,@UpdatedFifoId = fifo_bucket.intInventoryFIFOId
		,@strRelatedTransactionId = fifo_bucket.strTransactionId
		,@intRelatedTransactionId = fifo_bucket.intTransactionId

-- Insert a new fifo bucket if there is no negative stock to offset. 
WHEN NOT MATCHED AND @FullQty > 0 THEN 
	INSERT (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]		
		,[strTransactionId]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[dtmCreated]
		,[intCreatedEntityId]		
		,[intCurrencyId] 
		,[intForexRateTypeId] 
		,[dblForexRate] 
		,[dblForexCost] 
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@FullQty
		,@TotalQtyOffset
		,@dblCost		
		,@strTransactionId
		,@intTransactionId
		,@intTransactionDetailId 
		,GETDATE()
		,@intEntityUserSecurityId
		,@intCurrencyId 
		,@intForexRateTypeId 
		,@dblForexRate 
		,@dblForexCost 
		,1	
	)
;

-- If the incoming stock was fully consumed by the negative stock, the "WHEN NOT MATCHED AND @PurchasedQty > 0 THEN" is not triggered.
-- Thus if remaining qty is zero (not null*),  then add a new stock bucket. 
--
-- Note: 
-- *	Why null in "remaining qty" is important? A null in "remaining qty" means update was not performed in the above statement. 
--      A follow-up insert statement is needed to complete the fifo buckets. 
IF @RemainingQty = 0 
BEGIN 
	INSERT dbo.tblICInventoryFIFO (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]		
		,[strTransactionId]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[dtmCreated]
		,[intCreatedEntityId]
		,[intCurrencyId] 
		,[intForexRateTypeId] 
		,[dblForexRate] 
		,[dblForexCost] 
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@FullQty
		,@FullQty
		,@dblCost
		,@strTransactionId
		,@intTransactionId
		,@intTransactionDetailId
		,GETDATE()
		,@intEntityUserSecurityId
		,@intCurrencyId 
		,@intForexRateTypeId 
		,@dblForexRate 
		,@dblForexCost 
		,1
	)

	-- Do a follow-up retrieval of the new fifo id.
	SELECT @NewFifoId = SCOPE_IDENTITY() WHERE @UpdatedFifoId IS NOT NULL; 
END 

-- If Update was not performed, assume an insert was done. 
SELECT @NewFifoId = SCOPE_IDENTITY() WHERE @UpdatedFifoId IS NULL; 

